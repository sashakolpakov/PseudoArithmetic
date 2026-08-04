#!/usr/bin/env python3
"""Independent exact finite-volume certificate for Ma--Zheng P_{11,8}.

This does not use the trace-field certificate.  It pins the P_11 vertex-facet
incidence from HCPdm, classifies every principal Coxeter subdiagram exactly,
and verifies Vinberg's edge-completion criterion for finite volume.

The computation is deliberately tiny: there are only 2^7-1 principal
submatrices, all of order at most seven.
"""

from __future__ import annotations

import argparse
import hashlib
from itertools import combinations
import json
import os
from pathlib import Path
import re
import resource
import time

from sympy import Matrix, Rational, factor, simplify, sqrt


EXPECTED_TEX_SHA256 = (
    "0017931637f017641d4935450cc2a07d070866d9c749443d9e3ede9f3a39f003"
)
EXPECTED_INCIDENCE_SHA256 = (
    "05bd3d7eddd62598c1446ec562aa6ef63d85d0142e46cac2a550a1d7b054f293"
)
EXPECTED_VECTOR = "2232ab523242220442222"
P11_SOURCE_LINE = 17
PAIRS = tuple(combinations(range(7), 2))

# Zero-based facet indices, as in Ma--Zheng's tables and HCPdm.
EXPECTED_VERTICES = {
    (2, 3, 4, 5, 6),
    (1, 4, 5, 6),
    (1, 3, 5, 6),
    (1, 3, 4, 6),
    (1, 2, 4, 5),
    (1, 2, 3, 5),
    (0, 2, 3, 4),
    (0, 1, 3, 4),
    (0, 1, 2, 4),
    (0, 1, 2, 3),
}
EXPECTED_IDEAL_VERTICES = {(1, 3, 4, 6), (2, 3, 4, 5, 6)}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source_vector(path: Path) -> tuple[str, int]:
    for line_number, raw_line in enumerate(path.read_text().splitlines(), start=1):
        if r"P_{11,8}" not in raw_line:
            continue
        fields = raw_line.split("&")
        tokens: list[str] = []
        for field in fields[1:7]:
            field = re.sub(r"\\color\{[^}]+\}", "", field)
            tokens.append(re.sub(r"[^0-9abcX]", "", field.replace("$", "")))
        return "".join(tokens), line_number
    raise ValueError("P_{11,8} was not found in the Ma--Zheng table")


def source_incidence(path: Path) -> tuple[set[tuple[int, ...]], str]:
    lines = path.read_text().splitlines()
    raw_line = lines[P11_SOURCE_LINE - 1]
    vertices = {
        tuple(sorted(int(value) for value in bracket.split(",")))
        for bracket in re.findall(r"\[([^]]+)\]", raw_line)
    }
    return vertices, raw_line


def gram_matrix():
    s = sqrt(5)
    r = sqrt(2)
    a = sqrt(7 + s + 2 * sqrt(2 * (1 + s))) / 2
    b = (
        2
        + 3 * r
        + 2 * s
        + sqrt(10)
        + 2 * sqrt(19 + 14 * r + 9 * s + 6 * sqrt(10))
    ) / 4
    values = {
        "0": -1,
        "2": 0,
        "3": -Rational(1, 2),
        "4": -r / 2,
        "5": -(1 + s) / 4,
        "6": -sqrt(3) / 2,
        "a": -a,
        "b": -b,
    }
    gram = Matrix.eye(7)
    for (i, j), token in zip(PAIRS, EXPECTED_VECTOR, strict=True):
        gram[i, j] = gram[j, i] = values[token]
    return gram, a, b


def principal(gram: Matrix, indices: tuple[int, ...]) -> Matrix:
    return gram.extract(indices, indices)


def leading_minors(matrix: Matrix) -> tuple[object, ...]:
    return tuple(
        factor(matrix[:size, :size].det(method="berkowitz"))
        for size in range(1, matrix.rows + 1)
    )


def exactly_positive(value) -> bool:
    value = simplify(value)
    if value.is_positive is True:
        return True
    if value.is_positive is False or value.is_zero is True:
        return False
    raise ValueError(f"SymPy could not determine the exact sign of {value}")


def is_elliptic(gram: Matrix, indices: tuple[int, ...]) -> bool:
    # Sylvester's criterion, with exact algebraic signs.
    return all(exactly_positive(value) for value in leading_minors(principal(gram, indices)))


def components(gram: Matrix, indices: tuple[int, ...]) -> tuple[tuple[int, ...], ...]:
    remaining = set(indices)
    answer: list[tuple[int, ...]] = []
    while remaining:
        seed = min(remaining)
        component = {seed}
        frontier = [seed]
        remaining.remove(seed)
        while frontier:
            current = frontier.pop()
            neighbours = {
                other
                for other in remaining
                if gram[current, other].is_zero is not True
            }
            component.update(neighbours)
            remaining.difference_update(neighbours)
            frontier.extend(neighbours)
        answer.append(tuple(sorted(component)))
    return tuple(answer)


def is_connected_parabolic(gram: Matrix, indices: tuple[int, ...]) -> bool:
    matrix = principal(gram, indices)
    if simplify(matrix.det(method="berkowitz")) != 0:
        return False
    if matrix.rank() != len(indices) - 1:
        return False
    # For an indecomposable Coxeter matrix this is the affine criterion:
    # corank one and every proper principal subdiagram elliptic.  It is enough
    # to check the maximal proper principal subdiagrams.
    return all(
        is_elliptic(gram, tuple(index for index in indices if index != omitted))
        for omitted in indices
    )


def is_parabolic(gram: Matrix, indices: tuple[int, ...]) -> bool:
    return all(
        is_connected_parabolic(gram, component)
        for component in components(gram, indices)
    )


def all_subsets() -> tuple[tuple[int, ...], ...]:
    return tuple(
        subset
        for size in range(1, 8)
        for subset in combinations(range(7), size)
    )


def sorted_sets(values) -> list[list[int]]:
    return [list(value) for value in sorted(values, key=lambda item: (len(item), item))]


def one_based(values: tuple[int, ...]) -> list[int]:
    return [value + 1 for value in values]


def certify(tex: Path, incidence: Path) -> dict[str, object]:
    started = time.monotonic()

    tex_digest = sha256(tex)
    incidence_digest = sha256(incidence)
    if tex_digest != EXPECTED_TEX_SHA256:
        raise ValueError(f"unexpected hcp47.tex SHA-256: {tex_digest}")
    if incidence_digest != EXPECTED_INCIDENCE_SHA256:
        raise ValueError(f"unexpected pi47.txt SHA-256: {incidence_digest}")

    vector, vector_line = source_vector(tex)
    if vector != EXPECTED_VECTOR:
        raise ValueError(f"unexpected P_{{11,8}} Coxeter vector: {vector}")
    vertices, incidence_line = source_incidence(incidence)
    if vertices != EXPECTED_VERTICES:
        raise ValueError(f"unexpected P_11 incidence: {vertices}")

    gram, a, b = gram_matrix()
    if (a - 1).is_positive is not True or (b - 1).is_positive is not True:
        raise ValueError("the two dotted entries were not certified to exceed one")
    if len(components(gram, tuple(range(7)))) != 1:
        raise ValueError("the Coxeter Gram matrix is decomposable")
    for row in range(7):
        for column in range(7):
            if row != column and gram[row, column].is_nonpositive is not True:
                raise ValueError("a Gram off-diagonal entry is not non-positive")

    # Exact ambient Lorentzian certificate.  The positive 4-by-4 block on
    # facets 0,1,2,3 and its negative 5-by-5 extension give inertia (4,1)
    # on a rank-five principal block.  Exact Gaussian elimination gives full
    # Gram rank five, hence full inertia (4,1,2).
    rank = gram.rank()
    rank_five_indices = (0, 1, 2, 3, 4)
    rank_five_minor = factor(principal(gram, rank_five_indices).det(method="berkowitz"))
    positive_four_minors = leading_minors(principal(gram, (0, 1, 2, 3)))
    if rank != 5:
        raise ValueError(f"the full Gram rank is {rank}, not five")
    if simplify(rank_five_minor + (1 + sqrt(5)) / 32) != 0:
        raise ValueError(f"unexpected rank-five minor: {rank_five_minor}")
    if not all(exactly_positive(value) for value in positive_four_minors):
        raise ValueError("the four-dimensional positive block failed")

    subsets = all_subsets()
    elliptic = {subset for subset in subsets if is_elliptic(gram, subset)}
    parabolic = {
        subset
        for subset in subsets
        if subset not in elliptic and is_parabolic(gram, subset)
    }
    elliptic_or_parabolic = elliptic | parabolic
    maximal = {
        subset
        for subset in elliptic_or_parabolic
        if not any(set(subset) < set(other) for other in elliptic_or_parabolic)
    }
    if maximal != vertices:
        raise ValueError(
            f"maximal elliptic/parabolic subsets differ from P_11 vertices: {maximal}"
        )

    ideal_vertices = {vertex for vertex in vertices if vertex in parabolic}
    finite_vertices = {vertex for vertex in vertices if vertex in elliptic}
    if ideal_vertices != EXPECTED_IDEAL_VERTICES:
        raise ValueError(f"unexpected ideal vertices: {ideal_vertices}")
    if finite_vertices != vertices - EXPECTED_IDEAL_VERTICES:
        raise ValueError(f"unexpected finite vertices: {finite_vertices}")

    simple_ideal = (1, 3, 4, 6)
    nonsimple_ideal = (2, 3, 4, 5, 6)
    if components(gram, simple_ideal) != (simple_ideal,):
        raise ValueError("the simple ideal link is not connected")
    if components(gram, nonsimple_ideal) != ((2, 6), (3, 4, 5)):
        raise ValueError("the nonsimple ideal link does not split as expected")
    simple_null = Matrix([sqrt(2), 1, sqrt(2), 1])
    if principal(gram, simple_ideal) * simple_null != Matrix.zeros(4, 1):
        raise ValueError("the affine C3 null vector failed")
    prism_null_vectors = (
        Matrix([1, 0, 0, 0, 1]),
        Matrix([0, sqrt(2), 1, 1, 0]),
    )
    if any(
        principal(gram, nonsimple_ideal) * vector != Matrix.zeros(5, 1)
        for vector in prism_null_vectors
    ):
        raise ValueError("an affine prism-link null vector failed")

    local_vertices: list[dict[str, object]] = []
    for vertex in sorted(vertices, key=lambda item: (len(item), item)):
        matrix = principal(gram, vertex)
        entry: dict[str, object] = {
            "facets_zero_based": list(vertex),
            "facets_one_based": one_based(vertex),
            "rank": matrix.rank(),
            "determinant": str(factor(matrix.det(method="berkowitz"))),
            "leading_principal_minors": [str(value) for value in leading_minors(matrix)],
        }
        if vertex in finite_vertices:
            entry["kind"] = "ordinary"
            entry["coxeter_class"] = "elliptic_rank_4"
        elif vertex == simple_ideal:
            entry["kind"] = "ideal"
            entry["coxeter_class"] = "affine_C3"
            entry["null_vector_in_listed_order"] = ["sqrt(2)", "1", "sqrt(2)", "1"]
        else:
            entry["kind"] = "ideal_nonsimple"
            entry["coxeter_class"] = "affine_A1_disjoint_union_affine_C2"
            entry["components"] = [[2, 6], [3, 4, 5]]
            entry["nullity"] = 2
        local_vertices.append(entry)

    # In dimension four, elliptic triples are precisely the edges.  Vinberg's
    # finite-volume criterion says every such edge must have exactly two
    # ordinary-or-ideal endpoints.  We verify this globally, not merely for
    # triples visible in the supplied incidence list.
    edges = sorted(subset for subset in elliptic if len(subset) == 3)
    edge_endpoints: list[dict[str, object]] = []
    for edge in edges:
        endpoints = sorted(vertex for vertex in maximal if set(edge) <= set(vertex))
        if len(endpoints) != 2:
            raise ValueError(f"edge {edge} has {len(endpoints)} endpoints: {endpoints}")
        edge_endpoints.append(
            {
                "edge_facets_zero_based": list(edge),
                "endpoints_zero_based": [list(vertex) for vertex in endpoints],
            }
        )
    if len(edges) != 21:
        raise ValueError(f"expected 21 edges, found {len(edges)}")
    incident_edge_counts = {
        vertex: sum(set(edge) <= set(vertex) for edge in edges)
        for vertex in maximal
    }
    if incident_edge_counts[nonsimple_ideal] != 6:
        raise ValueError("the prism-link vertex does not have six incident edges")
    if any(
        count != 4
        for vertex, count in incident_edge_counts.items()
        if vertex != nonsimple_ideal
    ):
        raise ValueError(f"an ordinary/simple-ideal vertex has the wrong valence: {incident_edge_counts}")

    return {
        "label": "P_{11,8}",
        "source": {
            "tex_path": str(tex.resolve()),
            "tex_sha256": tex_digest,
            "coxeter_vector_line": vector_line,
            "coxeter_vector": vector,
            "incidence_path": str(incidence.resolve()),
            "incidence_sha256": incidence_digest,
            "incidence_line": P11_SOURCE_LINE,
            "incidence_raw": incidence_line,
            "facet_indexing": "zero_based",
        },
        "ambient_gram": {
            "rank": rank,
            "exact_inertia_positive_negative_zero": [4, 1, 2],
            "rank_five_indices": list(rank_five_indices),
            "rank_five_minor": str(rank_five_minor),
            "positive_four_indices": [0, 1, 2, 3],
            "positive_four_leading_minors": [str(value) for value in positive_four_minors],
            "indecomposable": True,
            "all_off_diagonal_nonpositive": True,
        },
        "vertex_gram_checks": local_vertices,
        "maximal_elliptic_or_parabolic_subsets": sorted_sets(maximal),
        "ordinary_vertex_count": len(finite_vertices),
        "ideal_vertex_count": len(ideal_vertices),
        "nonsimple_ideal_link": {
            "facets": list(nonsimple_ideal),
            "type": "affine_A1_disjoint_union_affine_C2",
            "rank": 3,
            "nullity": 2,
            "combinatorial_link": "triangular_prism",
        },
        "edge_completion": {
            "elliptic_rank_three_edge_count": len(edges),
            "every_edge_has_exactly_two_vertices": True,
            "incident_edge_counts": [
                {"vertex": list(vertex), "count": incident_edge_counts[vertex]}
                for vertex in sorted(incident_edge_counts, key=lambda item: (len(item), item))
            ],
            "edges": edge_endpoints,
        },
        "finite_volume_argument": (
            "Vinberg existence from the indecomposable Gram matrix of exact inertia "
            "(4,1,2), followed by Vinberg's finite-volume edge criterion: the maximal "
            "elliptic/parabolic subdiagrams are exactly the ten P_11 vertices, and "
            "each of the 21 elliptic rank-three edges has exactly two such endpoints."
        ),
        "conclusion": "finite_volume_noncompact_with_exactly_two_cusps",
        "wall_seconds": round(time.monotonic() - started, 3),
        "peak_rss_raw": resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--tex",
        type=Path,
        default=Path("/private/tmp/paperarXiv/hcp47.tex"),
    )
    parser.add_argument(
        "--incidence",
        type=Path,
        default=Path("/private/tmp/HCPdm-main/polytopeDATA/pi47.txt"),
    )
    parser.add_argument("--output", type=Path)
    arguments = parser.parse_args()
    result = certify(arguments.tex, arguments.incidence)
    encoded = json.dumps(result, indent=2, sort_keys=True) + "\n"
    print(encoded, end="", flush=True)
    if arguments.output is not None:
        arguments.output.parent.mkdir(parents=True, exist_ok=True)
        temporary = arguments.output.with_name(arguments.output.name + ".partial")
        with temporary.open("w") as stream:
            stream.write(encoded)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, arguments.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
