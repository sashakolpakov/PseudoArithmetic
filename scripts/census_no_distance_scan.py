#!/usr/bin/env python3
"""Exact bounded screen for the 19 Ma--Zheng cases without dotted lengths."""

from __future__ import annotations

import argparse
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys

from sympy import Rational, sqrt
from sympy.polys.numberfields import to_number_field


def load_scanner():
    path = Path(__file__).with_name("census_one_distance_scan.py")
    specification = importlib.util.spec_from_file_location("census_scan", path)
    assert specification is not None and specification.loader is not None
    module = importlib.util.module_from_spec(specification)
    specification.loader.exec_module(module)
    return module


SCAN = load_scanner()


def analyze_label(tex: Path, label: tuple[int, int]) -> dict[str, object]:
    rows = SCAN.parse_census(tex)
    vector = rows[label]
    if any(token in "abc" for token in vector):
        raise ValueError(f"P_{label} is not a zero-distance case")
    gram = SCAN.gram_matrix(vector, Rational(0))
    if gram.rank() != 5:
        raise ValueError(f"P_{label} does not have exact rank five")
    vinberg = SCAN.vinberg_matrix(gram)
    minor = SCAN.rational_rank_five_minor(vinberg)
    if minor is None:
        raise ValueError(f"P_{label} has no rational rank-five restriction")

    # This exact containment proves that the coefficient/trace field is an
    # intermediate field of an elementary-2, totally real Galois extension.
    container = to_number_field(sqrt(2) + sqrt(3) + sqrt(5))
    for entry in vinberg:
        if entry.is_Rational is not True:
            to_number_field(entry, container)
    return {
        "label": f"P_{{{label[0]},{label[1]}}}",
        "gram_rank": 5,
        "ambient_indices": list(minor),
        "status": "rational_descent",
        "trace_field_container": "Q(sqrt(2),sqrt(3),sqrt(5))",
        "field_elementary_2_over_Q": True,
    }


def run_all(tex: Path, output_path: Path | None = None) -> int:
    rows = SCAN.parse_census(tex)
    labels = sorted(
        label
        for label, vector in rows.items()
        if not any(token in "abc" for token in vector)
    )
    if len(labels) != 19:
        raise ValueError(f"expected 19 zero-distance cases, found {len(labels)}")

    log = None
    checkpoint_path = None
    completed_all = False
    if output_path is not None:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        checkpoint_path = output_path.with_name(output_path.name + ".partial")
        log = checkpoint_path.open("w")

    def emit(payload: dict[str, object]) -> None:
        line = json.dumps(payload, sort_keys=True)
        print(line, flush=True)
        if log is not None:
            log.write(line + "\n")
            log.flush()
            os.fsync(log.fileno())

    passed = []
    try:
        for first, second in labels:
            completed = subprocess.run(
                [
                    sys.executable,
                    str(Path(__file__).resolve()),
                    str(tex),
                    "--label",
                    f"{first},{second}",
                ],
                capture_output=True,
                text=True,
                check=False,
                timeout=60,
            )
            if completed.returncode != 0:
                print(completed.stderr, file=sys.stderr)
                raise RuntimeError(f"worker failed for P_{{{first},{second}}}")
            result = json.loads(completed.stdout)
            passed.append(str(result["label"]))
            emit(result)
        emit(
            {
                "cases": len(labels),
                "rational_descent": len(passed),
                "labels": passed,
            }
        )
        completed_all = True
    finally:
        if log is not None:
            log.close()
        if completed_all and checkpoint_path is not None and output_path is not None:
            os.replace(checkpoint_path, output_path)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("tex", type=Path)
    parser.add_argument("--label")
    parser.add_argument(
        "--output",
        type=Path,
        help="durable JSONL log; each case is flushed before the next worker",
    )
    arguments = parser.parse_args()
    if arguments.label:
        first, second = (int(part) for part in arguments.label.split(","))
        print(json.dumps(analyze_label(arguments.tex, (first, second)), sort_keys=True))
        return 0
    return run_all(arguments.tex, arguments.output)


if __name__ == "__main__":
    raise SystemExit(main())
