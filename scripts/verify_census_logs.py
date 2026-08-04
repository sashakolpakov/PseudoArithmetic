#!/usr/bin/env python3
"""Audit the durable zero-/one-distance census certificate logs."""

from __future__ import annotations

from collections import Counter
import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ONE = ROOT / "results" / "one_distance_certificates.jsonl"
ZERO = ROOT / "results" / "no_distance_certificates.jsonl"
SUMMARY = ROOT / "results" / "one_distance_summary.json"


def load(path: Path) -> list[dict[str, object]]:
    return [json.loads(line) for line in path.read_text().splitlines()]


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    one = load(ONE)
    zero = load(ZERO)
    summary = json.loads(SUMMARY.read_text())
    if len(one) != 77 or len(zero) != 20:
        raise ValueError("unexpected certificate-log length")

    one_cases, one_summary = one[:-1], one[-1]
    zero_cases, zero_summary = zero[:-1], zero[-1]
    if len({case["label"] for case in one_cases}) != 76:
        raise ValueError("one-distance labels are not unique")
    if len({case["label"] for case in zero_cases}) != 19:
        raise ValueError("zero-distance labels are not unique")

    expected = {
        "rational_descent": 31,
        "pseudo_via_quadratic_descent": 26,
        "pseudo_via_multiquadratic_descent": 11,
        "quasi_arithmetic": 8,
    }
    counts = Counter(str(case["status"]) for case in one_cases)
    if dict(counts) != expected or one_summary != {
        "counts": expected,
        "obstructions": [],
    }:
        raise ValueError(f"unexpected one-distance classification: {counts}")
    if zero_summary["cases"] != 19 or zero_summary["rational_descent"] != 19:
        raise ValueError("unexpected zero-distance summary")

    for case in one_cases:
        status = case["status"]
        if case.get("gram_rank") != 5 or "distance" not in case:
            raise ValueError(f"missing exact Gram certificate in {case['label']}")
        if case.get("complex_pairs", 0) != 0:
            raise ValueError(f"non-totally-real field in {case['label']}")
        if status == "quasi_arithmetic":
            if case["signatures"] != [[4, 1], [5, 0]]:
                raise ValueError(f"invalid quasi signature in {case['label']}")
        elif not all(signature == [4, 1] for signature in case["signatures"]):
            raise ValueError(f"nonconstant Lorentz signatures in {case['label']}")
        if status != "quasi_arithmetic" and not case["field_elementary_2_over_Q"]:
            raise ValueError(f"uncertified trace field in {case['label']}")
        if status == "pseudo_via_multiquadratic_descent":
            degree = case["trace_degree"]
            if case["field_automorphism_count"] != degree:
                raise ValueError(f"non-Galois higher field in {case['label']}")
            if case["field_automorphisms_involutive"] != [1] * degree:
                raise ValueError(f"non-elementary-2 field in {case['label']}")
        if status.startswith("pseudo_via_"):
            if case["finite_ramified_rational_primes"]:
                raise ValueError(f"unexpected finite Clifford support in {case['label']}")

    if not all(case.get("gram_rank") == 5 for case in zero_cases):
        raise ValueError("a zero-distance Gram matrix lacks its rank certificate")
    if not all(case["field_elementary_2_over_Q"] for case in zero_cases):
        raise ValueError("a zero-distance trace field lacks its container proof")

    one_digest = digest(ONE)
    zero_digest = digest(ZERO)
    recorded = summary["certificate_logs"]
    if recorded["results/one_distance_certificates.jsonl"]["sha256"] != one_digest:
        raise ValueError("the summary has a stale one-distance log hash")
    if recorded["results/no_distance_certificates.jsonl"]["sha256"] != zero_digest:
        raise ValueError("the summary has a stale zero-distance log hash")

    print(
        json.dumps(
            {
                "one_distance_counts": expected,
                "one_distance_sha256": one_digest,
                "zero_distance_cases": 19,
                "zero_distance_sha256": zero_digest,
                "result": "PASS",
            },
            sort_keys=True,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
