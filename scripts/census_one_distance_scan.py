#!/usr/bin/env python3
"""Bounded exact screen for one-distance cases in the Ma--Zheng census.

Each worker handles one 7-facet Gram matrix, derives its unique distance from
a rank-five minor, constructs a Vinberg cyclic-product basis, and looks for a
nonsingular rational rank-five restriction.  A rational restriction is an
exact pseudo-arithmeticity certificate (descent to Q); a miss is only a queue
for the Clifford checker, not an obstruction.

The ``--all`` driver deliberately starts one fresh worker per case.  This is
slower than retaining all SymPy expressions, but bounds memory and releases
the algebraic-expression cache after every matrix.
"""

from __future__ import annotations

import argparse
from itertools import combinations
import json
from pathlib import Path
import re
import subprocess
import sys

import numpy as np
from sympy import Matrix, Rational, cos, expand, pi, simplify, solve, sqrt
from sympy.polys.numberfields import to_number_field
from sympy.simplify.sqrtdenest import sqrtdenest


PAIRS = list(combinations(range(7), 2))


def parse_census(path: Path) -> dict[tuple[int, int], str]:
    rows: dict[tuple[int, int], str] = {}
    label_pattern = re.compile(r"P_\{(\d+),(\d+)\}")
    with path.open() as source:
        for line in source:
            match = label_pattern.search(line)
            if match is None or "&" not in line:
                continue
            fields = line.split("&")
            tokens: list[str] = []
            for field in fields[1:7]:
                field = re.sub(r"\\color\{[^}]+\}", "", field)
                field = field.replace(r"\underline{10}", "X")
                tokens.append(re.sub(r"[^0-9abcX]", "", field.replace("$", "")))
            vector = "".join(tokens)
            label = (int(match.group(1)), int(match.group(2)))
            if len(vector) == 21 and set(vector) <= set("0234568Xabc"):
                rows.setdefault(label, vector)
    if len(rows) != 331:
        raise ValueError(f"expected 331 census rows, found {len(rows)}")
    return rows


def gram_matrix(vector: str, distance) -> Matrix:
    values = {
        "0": -1,
        "2": 0,
        "3": -Rational(1, 2),
        "4": -sqrt(2) / 2,
        "5": -(1 + sqrt(5)) / 4,
        "6": -sqrt(3) / 2,
        "8": -cos(pi / 8),
        "X": -cos(pi / 10),
        "a": -distance,
        "b": -distance,
        "c": -distance,
    }
    matrix = Matrix.eye(7)
    for (i, j), token in zip(PAIRS, vector, strict=True):
        matrix[i, j] = matrix[j, i] = values[token]
    return matrix


def exact_distance(vector: str):
    from sympy import symbols

    variable = symbols("distance", real=True)
    symbolic = gram_matrix(vector, variable)
    equation = None
    for omitted in range(7):
        indices = [index for index in range(7) if index != omitted]
        # Berkowitz is division-free.  Bareiss/domain elimination can leave a
        # large rational function before cancellation even though the
        # determinant is only quadratic in the single unknown entry.
        determinant = expand(
            symbolic.extract(indices, indices).det(method="berkowitz")
        )
        if determinant != 0:
            equation = determinant
            break
    if equation is None:
        raise ValueError("every principal 6-minor vanished identically")

    candidates = []
    for root in solve(equation, variable):
        root = sqrtdenest(simplify(root))
        is_real = root.is_real
        is_geometric = (root - 1).is_positive
        if is_real is True and is_geometric is True:
            candidates.append(root)
        elif is_real is None or (is_real is True and is_geometric is None):
            raise ValueError(f"could not certify the geometric root exactly: {root}")
    if len(candidates) != 1:
        raise ValueError(f"expected one geometric distance, found {candidates}")
    return candidates[0]


def vinberg_matrix(gram: Matrix) -> Matrix:
    adjacency = {index: [] for index in range(7)}
    for i, j in PAIRS:
        if gram[i, j] != 0:
            adjacency[i].append(j)
            adjacency[j].append(i)

    parent: dict[int, int | None] = {0: None}
    order = [0]
    for vertex in order:
        for neighbor in adjacency[vertex]:
            if neighbor not in parent:
                parent[neighbor] = vertex
                order.append(neighbor)
    if len(order) != 7:
        raise ValueError("Coxeter graph is disconnected")

    scale = [None] * 7
    scale[0] = Rational(1)
    for vertex in order[1:]:
        previous = parent[vertex]
        assert previous is not None
        scale[vertex] = sqrtdenest(simplify(scale[previous] * 2 * gram[previous, vertex]))

    diagonal = Matrix.diag(*scale)
    result = diagonal * gram * diagonal
    return result.applyfunc(lambda entry: sqrtdenest(simplify(entry)))


def rational_rank_five_minor(form: Matrix) -> tuple[int, ...] | None:
    for indices in combinations(range(7), 5):
        candidate = form.extract(indices, indices)
        determinant = simplify(candidate.det(method="berkowitz"))
        if all(entry.is_Rational is True for entry in candidate) and determinant != 0:
            return indices
    return None


def first_numeric_rank_five_minor(form: Matrix) -> tuple[int, ...]:
    """Scout a minor numerically, then prove its determinant is nonzero exactly."""

    numeric = np.array(form.evalf(40).tolist(), dtype=float)
    for indices in combinations(range(7), 5):
        numeric_determinant = float(
            np.linalg.det(numeric[np.ix_(indices, indices)])
        )
        if abs(numeric_determinant) <= 1e-12:
            continue
        candidate = form.extract(indices, indices)
        determinant = simplify(candidate.det(method="berkowitz"))
        if determinant != 0:
            return indices
    raise ValueError("no nonsingular rank-five principal restriction")


def field_and_signatures(form: Matrix) -> dict[str, object]:
    """Return a numerical signature scout, never a proof certificate.

    The exact classifier in ``census_quadratic_clifford.py`` diagonalizes the
    form over its number field and uses PARI ``nfeltsign``.  This lightweight
    routine remains useful for deciding which expensive exact branch to try.
    """
    generators = []
    for entry in form:
        if entry.is_Rational is not True and entry not in generators:
            generators.append(entry)
    if not generators:
        return {
            "trace_degree": 1,
            "trace_minpoly": "_x - 1",
            "real_places": 1,
            "numerical_signature_scout": [[4, 1]],
        }

    theta = to_number_field(generators)
    polynomial = theta.minpoly
    roots = polynomial.nroots(n=40, maxsteps=300)
    real_roots = [
        float(root.as_real_imag()[0])
        for root in roots
        if abs(float(root.as_real_imag()[1])) < 1e-25
    ]

    indices = first_numeric_rank_five_minor(form)
    ambient = form.extract(indices, indices)
    coefficient_rows: list[list[list[float]]] = []
    for row in range(5):
        coefficient_row: list[list[float]] = []
        for column in range(5):
            algebraic = to_number_field(ambient[row, column], theta)
            coefficient_row.append([float(value) for value in algebraic.native_coeffs()])
        coefficient_rows.append(coefficient_row)

    signatures: list[list[int]] = []
    for root in real_roots:
        numeric = np.empty((5, 5), dtype=float)
        for row in range(5):
            for column in range(5):
                numeric[row, column] = float(np.polyval(coefficient_rows[row][column], root))
        eigenvalues = np.linalg.eigvalsh(numeric)
        tolerance = max(1.0, float(np.max(np.abs(eigenvalues)))) * 1e-8
        positive = int(np.count_nonzero(eigenvalues > tolerance))
        negative = int(np.count_nonzero(eigenvalues < -tolerance))
        if positive + negative != 5:
            raise ValueError("numerically ambiguous signature at a trace-field embedding")
        signatures.append([positive, negative])

    return {
        "trace_degree": int(polynomial.degree()),
        "trace_minpoly": str(polynomial.as_expr()),
        "real_places": len(real_roots),
        "numerical_signature_scout": sorted(signatures),
    }


def scan_one(
    path: Path, label: tuple[int, int], analyze_field: bool = False
) -> dict[str, object]:
    rows = parse_census(path)
    vector = rows[label]
    if sum(token in "abc" for token in vector) != 1:
        raise ValueError(f"P_{label} is not a one-distance case")
    distance = exact_distance(vector)
    gram = gram_matrix(vector, distance)
    if gram.rank() != 5:
        raise ValueError("derived Gram matrix does not have rank five")
    vinberg = vinberg_matrix(gram)
    minor = rational_rank_five_minor(vinberg)
    result: dict[str, object] = {
        "label": f"P_{{{label[0]},{label[1]}}}",
        "distance": str(distance),
        "rational_minor": list(minor) if minor is not None else None,
    }
    if analyze_field:
        result.update(field_and_signatures(vinberg))
    return result


def scan_all(path: Path, analyze_fields: bool = False) -> int:
    rows = parse_census(path)
    labels = sorted(
        label
        for label, vector in rows.items()
        if sum(token in "abc" for token in vector) == 1
    )
    passed = 0
    unresolved: list[str] = []
    for first, second in labels:
        command = [
            sys.executable,
            str(Path(__file__).resolve()),
            str(path),
            "--label",
            f"{first},{second}",
        ]
        if analyze_fields:
            command.append("--field")
        completed = subprocess.run(
            command,
            check=False,
            capture_output=True,
            text=True,
            timeout=60,
        )
        if completed.returncode != 0:
            print(completed.stderr.strip(), file=sys.stderr)
            raise RuntimeError(f"worker failed for P_{{{first},{second}}}")
        result = json.loads(completed.stdout)
        if result["rational_minor"] is None:
            unresolved.append(result["label"])
        else:
            passed += 1
        print(json.dumps(result, sort_keys=True), flush=True)
    print(
        json.dumps(
            {
                "one_distance_cases": len(labels),
                "rational_form_passes": passed,
                "queued_for_clifford": unresolved,
            },
            sort_keys=True,
        )
    )
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("tex", type=Path)
    parser.add_argument("--label", help="one label as i,j")
    parser.add_argument("--all", action="store_true")
    parser.add_argument("--field", action="store_true", help="also compute trace field and signatures")
    arguments = parser.parse_args()
    if arguments.label:
        first, second = (int(part) for part in arguments.label.split(","))
        print(
            json.dumps(
                scan_one(arguments.tex, (first, second), arguments.field),
                sort_keys=True,
            )
        )
        return 0
    if arguments.all:
        return scan_all(arguments.tex, arguments.field)
    parser.error("choose --label i,j or --all")
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
