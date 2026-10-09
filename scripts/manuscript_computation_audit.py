#!/usr/bin/env python3
"""Independent exact arithmetic and negative controls for manuscript claims.

Uses only the Python standard library. Computations take place in the
degree-eight polynomial quotient recorded in the existing certificate.
Sturm isolation and rational interval arithmetic identify the positive
radical embedding. These checks are computational evidence, not Lean proofs.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction as Q
from functools import lru_cache
from itertools import combinations
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def trim(p):
    p = list(map(Q, p))
    while p and p[-1] == 0:
        p.pop()
    return tuple(p)


def padd(a, b):
    return trim([(a[i] if i < len(a) else Q(0)) +
                 (b[i] if i < len(b) else Q(0)) for i in range(max(len(a), len(b)))])


def pneg(a):
    return tuple(-x for x in a)


def pmul(a, b):
    if not a or not b:
        return ()
    result = [Q(0)] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        for j, y in enumerate(b):
            result[i + j] += x * y
    return trim(result)


def pdiv(a, b):
    require(bool(b), "Polynomial division by zero")
    a = list(trim(a))
    quotient = [Q(0)] * max(0, len(a) - len(b) + 1)
    while a and len(a) >= len(b):
        index = len(a) - len(b)
        coefficient = a[-1] / b[-1]
        quotient[index] = coefficient
        for j, x in enumerate(b):
            a[index + j] -= coefficient * x
        a = list(trim(a))
    return trim(quotient), tuple(a)


def peval(p, x):
    value = Q(0)
    for coefficient in reversed(p):
        value = value * x + coefficient
    return value


P = trim([-1136, -3968, -5712, -5280, -3524, -1392, -252, -8, 1])


@dataclass(frozen=True, init=False)
class E:
    coefficients: tuple[Q, ...]

    def __init__(self, value=0):
        if isinstance(value, E):
            coefficients = value.coefficients
        elif isinstance(value, (tuple, list)):
            coefficients = pdiv(trim(value), P)[1]
        else:
            coefficients = trim([Q(value)])
        object.__setattr__(self, "coefficients", coefficients)

    def __add__(self, other):
        return E(padd(self.coefficients, E(other).coefficients))

    __radd__ = __add__

    def __neg__(self):
        return E(pneg(self.coefficients))

    def __sub__(self, other):
        return self + -E(other)

    def __rsub__(self, other):
        return E(other) + -self

    def __mul__(self, other):
        return E(pmul(self.coefficients, E(other).coefficients))

    __rmul__ = __mul__

    def __truediv__(self, other):
        return self * inverse(E(other))

    def __rtruediv__(self, other):
        return E(other) * inverse(self)

    def __pow__(self, n):
        require(n >= 0, "Only nonnegative powers are used")
        value, base = E(1), self
        while n:
            if n % 2:
                value *= base
            base *= base
            n //= 2
        return value

    def __bool__(self):
        return bool(self.coefficients)


@lru_cache(maxsize=512)
def inverse(x):
    require(bool(x), "Field division by zero")
    a, b, u, v = P, x.coefficients, (), (Q(1),)
    while b:
        q, r = pdiv(a, b)
        a, b, u, v = b, r, v, padd(u, pneg(pmul(q, v)))
    require(len(a) == 1, "Nonunit encountered in the polynomial quotient")
    result = E(tuple(t / a[0] for t in u))
    require(x * result == E(1), "Inverse failed its exact multiplication check")
    return result


def sturm_sequence(p):
    sequence = [p, trim([i * p[i] for i in range(1, len(p))])]
    while sequence[-1]:
        remainder = pdiv(sequence[-2], sequence[-1])[1]
        if not remainder:
            break
        sequence.append(pneg(remainder))
    return sequence


STURM = sturm_sequence(P)
ROOT_INTERVAL = [Q(22), Q(23)]


def variations(x):
    values = [peval(p, x) for p in STURM]
    signs = [1 if value > 0 else -1 for value in values if value]
    return sum(a != b for a, b in zip(signs, signs[1:]))


def variations_at_infinity(positive):
    signs = []
    for p in STURM:
        leading_sign = 1 if p[-1] > 0 else -1
        signs.append(leading_sign if positive or (len(p)-1) % 2 == 0 else -leading_sign)
    return sum(a != b for a,b in zip(signs,signs[1:]))


def refine_root(steps):
    for _ in range(steps):
        lo, hi = ROOT_INTERVAL
        middle = (lo + hi) / 2
        value = peval(P, middle)
        require(value != 0, "Unexpected rational primitive root")
        if value * peval(P, lo) > 0:
            ROOT_INTERVAL[0] = middle
        else:
            ROOT_INTERVAL[1] = middle


def interval_evaluate(p):
    lower = upper = Q(0)
    lo, hi = ROOT_INTERVAL
    for coefficient in reversed(p):
        products = [lower * lo, lower * hi, upper * lo, upper * hi]
        lower, upper = min(products) + coefficient, max(products) + coefficient
    return lower, upper


@lru_cache(maxsize=2048)
def sign(x):
    x = E(x)
    if not x:
        return 0
    for _ in range(16):
        lo, hi = interval_evaluate(x.coefficients)
        if lo > 0:
            return 1
        if hi < 0:
            return -1
        refine_root(32)
    raise RuntimeError("Exact sign isolation did not separate zero")


def determinant(matrix):
    a = [list(row) for row in matrix]
    value = E(1)
    for i in range(len(a)):
        pivot = next((j for j in range(i, len(a)) if a[j][i]), None)
        if pivot is None:
            return E(0)
        if pivot != i:
            a[i], a[pivot] = a[pivot], a[i]
            value = -value
        diagonal = a[i][i]
        value *= diagonal
        for j in range(i + 1, len(a)):
            ratio = a[j][i] / diagonal
            for k in range(i + 1, len(a)):
                a[j][k] -= ratio * a[i][k]
    return value


def inertia(matrix):
    """Symmetric elimination with exact one- or two-dimensional pivots."""
    a = [list(row) for row in matrix]
    positive = negative = 0
    while a:
        size = len(a)
        pivot = next((i for i in range(size) if a[i][i]), None)
        if pivot is not None:
            others = [i for i in range(size) if i != pivot]
            diagonal = a[pivot][pivot]
            positive += sign(diagonal) > 0
            negative += sign(diagonal) < 0
            a = [[a[i][j] - a[i][pivot] * a[pivot][j] / diagonal
                  for j in others] for i in others]
            continue
        pair = next(((i, j) for i in range(size) for j in range(i + 1, size)
                     if a[i][j]), None)
        if pair is None:
            return [positive, negative, size]
        i, j = pair
        others = [k for k in range(size) if k not in pair]
        off = a[i][j]
        a = [[a[k][l] - (a[k][i] * a[j][l] + a[k][j] * a[i][l]) / off
              for l in others] for k in others]
        positive += 1
        negative += 1
    return [positive, negative, 0]


def principal(matrix, indices):
    return [[matrix[i][j] for j in indices] for i in indices]


def cycle(matrix, vertices):
    result = E(1)
    for i, j in zip(vertices, vertices[1:] + vertices[:1]):
        result *= matrix[i][j]
    return result


def gram(s, r, a, b, cosine):
    return [[E(x) for x in row] for row in [
        [1, 0, 0, Q(-1, 2), 0, -a, -b],
        [0, 1, -(1+s)/4, 0, Q(-1, 2), 0, -cosine],
        [0, -(1+s)/4, 1, 0, 0, 0, -1],
        [Q(-1, 2), 0, 0, 1, -r/2, -r/2, 0],
        [0, Q(-1, 2), 0, -r/2, 1, 0, 0],
        [-a, 0, 0, -r/2, 0, 1, 0],
        [-b, -cosine, -1, 0, 0, 0, 1],
    ]]


def audit():
    require(variations(Q(22)) - variations(Q(23)) == 1,
            "The primitive polynomial must have exactly one root in (22,23)")
    require(peval(P, Q(22)) * peval(P, Q(23)) < 0, "Invalid root bracket")
    refine_root(128)
    source = json.loads((ROOT / "results/p11_8_non_total_trace_certificate.json").read_text())
    coordinates = source["whole_field_certificate"]["generator_coordinate_vectors_high_to_low"]
    generators = {name: E(list(reversed([Q(x) for x in vector])))
                  for name, vector in coordinates.items()}
    s, r, a, b8 = (generators[name] for name in ("sqrt5", "sqrt2", "a", "b"))
    require(s*s == E(5) and r*r == E(2), "Square-root reconstruction failed")
    require(sign(s) == sign(r) == 1, "Wrong square-root branches")
    t = 2*a*a - (7+s)/2
    require(t*t == 2+2*s and sign(t) == 1 and sign(a-1) == 1,
            "The reconstructed a is not the manuscript's positive radical")
    require(2*(r+a+b8) == E([0,1]), "The primitive element does not reconstruct")
    real_roots = variations_at_infinity(False) - variations_at_infinity(True)
    require(real_roots == 4, "The primitive polynomial does not have four real roots")
    rejected_coordinate_mutations = 0
    relations = {
        "sqrt5": lambda x: x*x-5,
        "sqrt2": lambda x: x*x-2,
        "a": lambda x: (2*x*x-(7+s)/2)**2-(2+2*s),
        "b": lambda x: (2*x-(2+3*r+2*s+r*s)/2)**2-(19+14*r+9*s+6*r*s),
    }
    for name, value in generators.items():
        for power in range(8):
            perturbation = E([0]*power + [Q(1,1000)])
            require(bool(relations[name](value+perturbation)),
                    f"An incorrect power-basis coefficient survived: {name}, {power}")
            rejected_coordinate_mutations += 1

    matrices = []
    cases = []
    rejected_cycle_mutations = 0
    expected_minors = [E(1), E(1), (5-s)/8, 3*(5-s)/32, -(1+s)/32]
    for label, cosine in ((6,E(0)), (7,E(Q(1,2))), (8,r/2)):
        # The off-diagonal Schur equation reconstructs b in the same quotient.
        b = r*(1+s)/2 * (a+r) * (cosine+(1+s)/4) / (a-r*s/4+r/4)
        require(sign(b-1) == 1, f"Wrong positive b branch for row {label}")
        if label == 6:
            inner = b*b - Q(9,2) - 2*s
            require(inner*inner == 38+17*s and sign(inner) == 1, "b6 radical mismatch")
        elif label == 7:
            inner = 2*(b-r)-r*s
            require(inner*inner == 29+13*s and sign(inner) == 1, "b7 radical mismatch")
        else:
            require(b == b8, "b8 coordinate mismatch")
            inner = 2*b-(2+3*r+2*s+r*s)/2
            require(inner*inner == 19+14*r+9*s+6*r*s and sign(inner) == 1,
                    "b8 radical mismatch")
        matrix = gram(s,r,a,b,cosine)
        matrices.append(matrix)
        signature = inertia(matrix)
        require(signature == [4,1,2], f"Incorrect inertia for row {label}")
        for size, expected in enumerate(expected_minors, start=1):
            require(determinant(principal(matrix, range(size))) == expected,
                    f"Leading minor mismatch in row {label}, size {size}")
        require(all(determinant(principal(matrix, indices)) == E(0)
                    for indices in combinations(range(7),6)), "Nonzero six-by-six minor")
        doubled = [[2*x for x in row] for row in matrix]
        c12, c035 = cycle(doubled,[1,2]), cycle(doubled,[0,3,5])
        require(c12 == (3+s)/2 and c035 == -2*r*a, "Cyclic product mismatch")
        for i,j in ((1,2),(0,3),(3,5),(0,5)):
            for delta in (Q(-1,1000), Q(1,1000)):
                changed = [row[:] for row in doubled]
                changed[i][j] += delta
                changed[j][i] += delta
                bad_s = 2*cycle(changed,[1,2])-3
                bad_u = -cycle(changed,[0,3,5])/2
                relation = (bad_s-1)*bad_u**2+2*(bad_s-3)*bad_u+bad_s-7
                require(bad_s**2 != E(5) or relation != E(0),
                        f"Unexpected surviving cycle mutation: row {label}, edge {(i,j)}")
                rejected_cycle_mutations += 1
        cases.append({"row": label, "inertia": signature, "rank": sum(signature[:2]),
                      "leading_minors_checked": 5, "zero_six_by_six_minors": 7})

    # Recompute all principal-subdiagram signatures and incidence consequences.
    geometry_source = json.loads((ROOT / "results/p11_8_finite_volume_validation.json").read_text())
    third = matrices[-1]
    subdiagrams = {indices: inertia(principal(third, indices))
                   for size in range(1,8) for indices in combinations(range(7),size)}
    require(len(subdiagrams) == 127, "The principal-subdiagram enumeration is incomplete")
    nonnegative = [indices for indices, signature in subdiagrams.items() if signature[1] == 0]
    vertices = [indices for indices in nonnegative
                if not any(set(indices) < set(other) for other in nonnegative)]
    stored_vertices = [tuple(vertex) for vertex in
                       geometry_source["maximal_elliptic_or_parabolic_subsets"]]
    require(set(vertices) == set(stored_vertices), "Maximal vertex-subdiagram mismatch")
    ordinary = [indices for indices in vertices if subdiagrams[indices] == [4,0,0]]
    ideal = [indices for indices in vertices if subdiagrams[indices][2] > 0]
    require(len(ordinary) == 8 and set(ideal) == {(1,3,4,6), (2,3,4,5,6)},
            "Ordinary/ideal vertex classification mismatch")
    require(subdiagrams[(1,3,4,6)] == [3,0,1] and
            subdiagrams[(2,3,4,5,6)] == [3,0,2], "Parabolic ranks or nullities changed")
    edges = [indices for indices, signature in subdiagrams.items() if signature == [3,0,0]]
    endpoints = {edge: [vertex for vertex in vertices if set(edge) <= set(vertex)] for edge in edges}
    require(len(edges) == 21 and all(len(values) == 2 for values in endpoints.values()),
            "An elliptic rank-three edge lacks its two endpoints")
    rejected_vertex_deletions = 0
    for omitted in vertices:
        remaining = [vertex for vertex in vertices if vertex != omitted]
        require(any(sum(set(edge) <= set(vertex) for vertex in remaining) != 2 for edge in edges),
                "Deleting a vertex unexpectedly preserved every edge endpoint count")
        rejected_vertex_deletions += 1

    # Controls target the rank and sign interpretation, not merely stored flags.
    require(inertia([[E(0),E(1)],[E(1),E(0)]]) == [1,1,0],
            "The zero-diagonal indefinite control failed")
    require(inertia([[E(1),E(0)],[E(0),E(0)]]) == [1,0,1],
            "The singular positive-semidefinite control failed")
    # All adjacent-size principal minors can vanish even in an invertible
    # symmetric matrix: -I_7 + J_7/6 has eigenvalues 1/6,-1,...,-1.
    rank_control = [[E(Q(1,6) - int(i == j)) for j in range(7)] for i in range(7)]
    require(inertia(rank_control) == [1,6,0] and
            all(determinant(principal(rank_control, indices)) == E(0)
                for indices in combinations(range(7),6)) and
            determinant(principal(rank_control, range(5))) != E(0),
            "The principal-minor-only rank counterexample failed")
    rejected_diagonal_mutations = 0
    for matrix in matrices:
        changed = [row[:] for row in matrix]
        changed[6][6] += Q(1,1000)
        require(sum(inertia(changed)[:2]) != 5, "A rank mutation unexpectedly retained rank five")
        rejected_diagonal_mutations += 1

    return {"arithmetic": "exact polynomial quotient, Sturm isolation, rational intervals",
            "root_isolating_interval": ["22", "23"],
            "radical_branches_verified": True, "cases": cases,
            "primitive_polynomial_real_roots": real_roots,
            "rejected_power_basis_coordinate_mutations": rejected_coordinate_mutations,
            "rejected_cycle_mutations": rejected_cycle_mutations,
            "principal_subdiagrams_checked": len(subdiagrams),
            "ordinary_vertices": len(ordinary), "ideal_vertices": len(ideal),
            "elliptic_edges_with_two_endpoints": len(edges),
            "rejected_vertex_deletions": rejected_vertex_deletions,
            "rejected_diagonal_rank_mutations": rejected_diagonal_mutations,
            "inertia_boundary_controls": 2,
            "principal_minor_rank_counterexample_verified": True,
            "all_checks_passed": True}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    report = json.dumps(audit(), indent=2) + "\n"
    if args.output:
        args.output.write_text(report)
    print(report, end="")


if __name__ == "__main__":
    main()
