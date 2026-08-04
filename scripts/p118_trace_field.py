#!/usr/bin/env python3
"""Exact isolated certificate for the two-distance Coxeter case P_{11,8}."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path

from sympy import expand, simplify, solve, symbols


def load_module(name: str, filename: str):
    path = Path(__file__).with_name(filename)
    specification = importlib.util.spec_from_file_location(name, path)
    assert specification is not None and specification.loader is not None
    module = importlib.util.module_from_spec(specification)
    specification.loader.exec_module(module)
    return module


SCAN = load_module("p118_scanner", "census_one_distance_scan.py")
CHECK = load_module("p118_checker", "census_quadratic_clifford.py")
LABEL = (11, 8)
SOURCE_SHA256 = "0017931637f017641d4935450cc2a07d070866d9c749443d9e3ede9f3a39f003"


def geometric_root(equation, variable):
    candidates = []
    for root in solve(equation, variable):
        root = simplify(root)
        if root.is_real is True and (root - 1).is_positive is True:
            candidates.append(root)
        elif root.is_real is None or (
            root.is_real is True and (root - 1).is_positive is None
        ):
            raise ValueError(f"could not certify a root exactly: {root}")
    if len(candidates) != 1:
        raise ValueError(f"expected one geometric root, found {candidates}")
    return candidates[0]


def certificate(tex: Path) -> dict[str, object]:
    source_sha256 = hashlib.sha256(tex.read_bytes()).hexdigest()
    if source_sha256 != SOURCE_SHA256:
        raise ValueError(f"source hash changed: {source_sha256}")
    rows = SCAN.parse_census(tex)
    vector = rows[LABEL]
    if vector != "2232ab523242220442222":
        raise ValueError(f"unexpected pinned Coxeter vector: {vector}")

    a, b = symbols("a b", real=True)
    symbolic = SCAN.gram_matrix(vector, a)
    symbolic[0, 6] = symbolic[6, 0] = -b

    omit_six = list(range(6))
    omit_five = [0, 1, 2, 3, 4, 6]
    equation_a = simplify(
        expand(symbolic.extract(omit_six, omit_six).det(method="berkowitz"))
    )
    equation_b = simplify(
        expand(symbolic.extract(omit_five, omit_five).det(method="berkowitz"))
    )
    if equation_a.has(b) or equation_b.has(a):
        raise ValueError("the isolated rank equations did not separate")

    root_a = geometric_root(equation_a, a)
    root_b = geometric_root(equation_b, b)
    gram = symbolic.subs({a: root_a, b: root_b}).applyfunc(simplify)
    gram_rank = gram.rank()
    if gram_rank != 5:
        raise ValueError(f"the exact Gram rank is {gram_rank}, not five")
    principal_six = []
    for omitted in range(7):
        indices = [index for index in range(7) if index != omitted]
        determinant = simplify(
            gram.extract(indices, indices).det(method="berkowitz")
        )
        principal_six.append(str(determinant))
        if determinant != 0:
            raise ValueError(f"principal 6-minor {omitted} did not vanish")

    vinberg = SCAN.vinberg_matrix(gram)
    generators = []
    for entry in vinberg:
        if entry.is_Rational is not True and entry not in generators:
            generators.append(entry)
    theta = CHECK.integral_primitive_element(generators)
    indices = SCAN.first_numeric_rank_five_minor(vinberg)
    ambient = vinberg.extract(indices, indices)
    field = CHECK.run_gp_field_certificate(ambient, theta)
    if field["trace_degree"] != 8 or field["complex_pairs"] != 2:
        raise ValueError(f"unexpected trace-field signature: {field}")
    if field["signatures"] != [[4, 1]] * 4:
        raise ValueError(f"unexpected real form signatures: {field['signatures']}")

    return {
        "label": "P_{11,8}",
        "source": "Ma--Zheng, arXiv:2401.13698, hcp47.tex",
        "source_sha256": source_sha256,
        "coxeter_vector": vector,
        "distance_edges": {"a": [0, 5], "b": [0, 6]},
        "rank_equations": {"a": str(equation_a), "b": str(equation_b)},
        "distances": {"a": str(root_a), "b": str(root_b)},
        "principal_six_minors": principal_six,
        "gram_rank": gram_rank,
        "ambient_indices": list(indices),
        "trace_field_construction": "coefficient field of Vinberg cyclic-product form DGD",
        "trace_minpoly": str(theta.minpoly.as_expr()),
        **field,
        "status": "non_pseudo_non_totally_real_trace_field",
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("tex", type=Path)
    parser.add_argument("--output", type=Path)
    arguments = parser.parse_args()
    result = certificate(arguments.tex)
    encoded = json.dumps(result, sort_keys=True)
    print(encoded, flush=True)
    if arguments.output is not None:
        arguments.output.parent.mkdir(parents=True, exist_ok=True)
        checkpoint = arguments.output.with_name(arguments.output.name + ".partial")
        with checkpoint.open("w") as destination:
            destination.write(encoded + "\n")
            destination.flush()
            os.fsync(destination.fileno())
        os.replace(checkpoint, arguments.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
