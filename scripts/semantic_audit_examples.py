#!/usr/bin/env python3
"""Exact rational examples for the two-cycle semantic audit.

This finite test complements the universal Lean proofs in SemanticAudit.lean.
It tests the polynomial and its transcription, not number-field embeddings.
Only Python's standard library is required; no floating-point arithmetic is used.
"""

from __future__ import annotations

import argparse
from fractions import Fraction
import json
from pathlib import Path


def cycle_polynomial(s: Fraction, u: Fraction) -> Fraction:
    """Evaluate the manuscript's coefficients by Horner's rule."""
    return ((s - 1) * u + 2 * (s - 3)) * u + s - 7


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def audit() -> dict:
    positive_count = 0
    perturbation_count = 0
    no_root_count = 0
    discriminant_count = 0

    for integer in range(-1000, 1001):
        u = Fraction(integer)
        if u == -1:
            continue
        s = (u * u + 6 * u + 7) / (u + 1) ** 2
        require(cycle_polynomial(s, u) == 0, f"Root failed: {s=}, {u=}")
        require(s >= -1, f"Root below the boundary: {s=}, {u=}")
        positive_count += 1
        for delta in (Fraction(-1, 1000), Fraction(1, 1000)):
            value = cycle_polynomial(s + delta, u)
            require(value != 0, f"Perturbed root survived: {s=}, {u=}, {delta=}")
            require(value == delta * (u + 1) ** 2,
                    f"Perturbation identity failed: {s=}, {u=}, {delta=}")
            perturbation_count += 1

    for n in range(101):
        s = Fraction(-2 - n)
        for numerator in range(-100, 101):
            u = Fraction(numerator, 8)
            require(cycle_polynomial(s, u) != 0,
                    f"Unexpected root below the boundary: {s=}, {u=}")
            no_root_count += 1

    for numerator in range(-1000, 1001):
        s = Fraction(numerator, 8)
        discriminant = (2 * (s - 3)) ** 2 - 4 * (s - 1) * (s - 7)
        require(discriminant == 8 * (1 + s), f"Discriminant mismatch: {s=}")
        discriminant_count += 1

    # Named cases make the boundary and hypothesis mutations easy to inspect.
    cases = (
        ("double_root_boundary", Fraction(-1), Fraction(-2), True),
        ("linear_boundary", Fraction(1), Fraction(-3, 2), True),
        ("square_hypothesis_missing", Fraction(7), Fraction(0), True),
        ("ordinary_rational_root", Fraction(7, 2), Fraction(1), True),
        ("below_boundary", Fraction(-2), Fraction(0), False),
        ("incorrect_root_at_boundary", Fraction(-1), Fraction(0), False),
        ("wrong_root_in_linear_case", Fraction(1), Fraction(0), False),
        ("excluded_parameter_denominator", Fraction(7), Fraction(-1), False),
    )
    examples = []
    for name, s, u, is_root in cases:
        value = cycle_polynomial(s, u)
        require((value == 0) == is_root, f"Named case failed: {name}")
        examples.append({
            "name": name, "s": str(s), "u": str(u),
            "polynomial_value": str(value), "is_root": is_root,
        })

    return {
        "arithmetic": "exact fractions; no floating point",
        "scope": "quadratic relation and discriminant; field examples are checked in Lean",
        "positive_root_cases": positive_count,
        "nonzero_perturbation_cases": perturbation_count,
        "below_boundary_nonroot_cases": no_root_count,
        "discriminant_identity_cases": discriminant_count,
        "named_examples": examples,
        "all_checks_passed": True,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, help="Also write the JSON report to this path")
    args = parser.parse_args()
    report = json.dumps(audit(), indent=2) + "\n"
    if args.output is not None:
        args.output.write_text(report, encoding="utf-8")
    print(report, end="")


if __name__ == "__main__":
    main()
