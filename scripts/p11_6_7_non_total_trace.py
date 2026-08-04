#!/usr/bin/env python3
"""Bounded exact certificates for the Ma--Zheng lattices P_{11,6}, P_{11,7}.

The default driver launches one fresh worker for each case.  Both cases share
the same short obstruction as P_{11,8}: two Cartan cyclic products put
``sqrt(5)`` and ``u=sqrt(2)*a`` in the adjoint trace field, while the relative
quadratic polynomial of ``u`` has negative discriminant at the conjugate
place of ``Q(sqrt(5))``.
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
import subprocess
import sys
import time

import numpy as np
from sympy import Matrix, Rational, factor, simplify, sqrt


SOURCE_SHA256 = "0017931637f017641d4935450cc2a07d070866d9c749443d9e3ede9f3a39f003"
PAIRS = list(combinations(range(7), 2))
CASES = {
    6: {
        "vector": "2232ab523222220442222",
        "line": 1602,
        "cusps": 1,
        "volume_over_pi_squared": "13/864",
    },
    7: {
        "vector": "2232ab523232220442222",
        "line": 1603,
        "cusps": 1,
        "volume_over_pi_squared": "1/54",
    },
}


def parse_source(path: Path, second: int) -> tuple[str, int, str]:
    data = path.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    pattern = rf"P_{{11,{second}}}"
    for line_number, line in enumerate(data.decode().splitlines(), start=1):
        if pattern not in line:
            continue
        fields = line.split("&")
        tokens = []
        for field in fields[1:7]:
            field = re.sub(r"\\color\{[^}]+\}", "", field)
            tokens.append(re.sub(r"[^0-9abcX]", "", field.replace("$", "")))
        return "".join(tokens), line_number, digest
    raise ValueError(f"P_{{11,{second}}} not found")


def distances(second: int):
    s = sqrt(5)
    r = sqrt(2)
    a = sqrt(7 + s + 2 * sqrt(2 * (1 + s))) / 2
    if second == 6:
        b = sqrt(Rational(9, 2) + 2 * s + sqrt(38 + 17 * s))
    elif second == 7:
        b = r + sqrt(Rational(5, 2)) + sqrt(29 + 13 * s) / 2
    else:
        raise ValueError(f"unsupported case P_{{11,{second}}}")
    return a, b


def gram_matrix(vector: str, a, b) -> Matrix:
    s = sqrt(5)
    r = sqrt(2)
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
    matrix = Matrix.eye(7)
    for (i, j), token in zip(PAIRS, vector, strict=True):
        matrix[i, j] = matrix[j, i] = values[token]
    return matrix


def certify_one(tex: Path, second: int) -> dict[str, object]:
    started = time.monotonic()
    metadata = CASES[second]
    vector, line_number, digest = parse_source(tex, second)
    if digest != SOURCE_SHA256:
        raise ValueError(f"source hash changed: {digest}")
    if vector != metadata["vector"] or line_number != metadata["line"]:
        raise ValueError(
            f"source row changed: vector={vector}, line={line_number}"
        )

    s = sqrt(5)
    r = sqrt(2)
    a, b = distances(second)
    if (a - 1).is_positive is not True or (b - 1).is_positive is not True:
        raise ValueError("a dotted length was not certified greater than one")
    gram = gram_matrix(vector, a, b)

    principal_six = []
    for omitted in range(7):
        indices = [index for index in range(7) if index != omitted]
        principal_six.append(
            simplify(gram.extract(indices, indices).det(method="berkowitz"))
        )
    rank = gram.rank()
    ambient_block = gram.extract(range(5), range(5))
    leading_principal_minors = [
        factor(ambient_block[:size, :size].det(method="berkowitz"))
        for size in range(1, 6)
    ]
    rank_five_minor = leading_principal_minors[-1]
    if principal_six != [0] * 7 or rank != 5:
        raise ValueError("the exact Gram rank conditions failed")
    if simplify(rank_five_minor + (1 + s) / 32) != 0:
        raise ValueError("the expected nonsingular rank-five minor changed")
    if not all(value.is_positive is True for value in leading_principal_minors[:4]):
        raise ValueError("a leading ambient minor was not certified positive")
    if rank_five_minor.is_negative is not True:
        raise ValueError("the rank-five ambient determinant was not certified negative")

    eigenvalues = np.linalg.eigvalsh(np.array(gram.evalf(40).tolist(), dtype=float))
    tolerance = 1e-10
    signature = [
        int(np.count_nonzero(eigenvalues > tolerance)),
        int(np.count_nonzero(eigenvalues < -tolerance)),
        int(np.count_nonzero(np.abs(eigenvalues) <= tolerance)),
    ]
    if signature != [4, 1, 2]:
        raise ValueError(f"unexpected numerical signature: {signature}")

    cartan = 2 * gram
    c12 = simplify(cartan[1, 2] * cartan[2, 1])
    c035 = simplify(cartan[0, 3] * cartan[3, 5] * cartan[5, 0])
    u = r * a
    if simplify(2 * c12 - 3 - s) != 0 or simplify(-c035 / 2 - u) != 0:
        raise ValueError("the two cyclic products did not recover sqrt(5),u")

    relation = simplify((s - 1) * u**2 + 2 * (s - 3) * u + s - 7)
    conjugate_discriminant = 8 * (1 - s)
    if relation != 0 or conjugate_discriminant.is_negative is not True:
        raise ValueError("the non-total-reality certificate failed")

    return {
        "label": f"P_{{11,{second}}}",
        "source": {
            "path": str(tex.resolve()),
            "line": line_number,
            "sha256": digest,
            "vector": vector,
            "cusps": metadata["cusps"],
            "volume_over_pi_squared": metadata["volume_over_pi_squared"],
        },
        "distances": {
            "a": str(a),
            "b": str(b),
            "a_numeric": str(a.evalf(18)),
            "b_numeric": str(b.evalf(18)),
            "both_greater_than_one_exact": True,
        },
        "rank_certificate": {
            "principal_six_minors": [str(value) for value in principal_six],
            "gram_rank": rank,
            "rank_five_minor_01234": str(rank_five_minor),
            "leading_principal_minors_ambient_01234": [
                str(value) for value in leading_principal_minors
            ],
            "exact_signature_positive_negative_zero": [4, 1, 2],
            "numerical_signature_positive_negative_zero": signature,
            "numerical_eigenvalues": [float(value) for value in eigenvalues],
        },
        "cyclic_subfield_certificate": {
            "c12": str(c12),
            "c035": str(c035),
            "recovers_sqrt5": True,
            "recovers_u_equals_sqrt2_times_a": True,
            "u_relative_polynomial": (
                "(sqrt(5)-1)u^2+2(sqrt(5)-3)u+(sqrt(5)-7)"
            ),
            "u_discriminant": "8*(1+sqrt(5))",
            "conjugate_discriminant": str(conjugate_discriminant),
            "conjugate_discriminant_negative_exact": True,
        },
        "conclusion": "adjoint_trace_field_not_totally_real_implies_not_pseudo_arithmetic",
        "wall_seconds": round(time.monotonic() - started, 3),
        "peak_rss_raw": resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
    }


def run_driver(tex: Path, output: Path | None) -> int:
    results = []
    for second in (6, 7):
        completed = subprocess.run(
            [
                sys.executable,
                str(Path(__file__).resolve()),
                str(tex),
                "--label",
                str(second),
            ],
            text=True,
            capture_output=True,
            check=False,
            timeout=60,
        )
        if completed.returncode != 0:
            raise RuntimeError(
                f"worker P_{{11,{second}}} failed:\n{completed.stderr}"
            )
        results.append(json.loads(completed.stdout))
    payload = {
        "cases": results,
        "shared_obstruction": {
            "subfield": "Q(sqrt(5),u), u=sqrt(2)*a",
            "relative_polynomial": (
                "(sqrt(5)-1)u^2+2(sqrt(5)-3)u+(sqrt(5)-7)"
            ),
            "conjugate_discriminant": "8*(1-sqrt(5)) < 0",
        },
        "both_non_pseudo_arithmetic": True,
        "memory_policy": "one fresh Python worker per case",
    }
    encoded = json.dumps(payload, indent=2, sort_keys=True) + "\n"
    print(encoded, end="", flush=True)
    if output is not None:
        output.parent.mkdir(parents=True, exist_ok=True)
        temporary = output.with_name(output.name + ".partial")
        with temporary.open("w") as stream:
            stream.write(encoded)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, output)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "tex",
        type=Path,
        nargs="?",
        default=Path("/private/tmp/paperarXiv/hcp47.tex"),
    )
    parser.add_argument("--label", type=int, choices=(6, 7))
    parser.add_argument("--output", type=Path)
    arguments = parser.parse_args()
    if arguments.label is not None:
        print(json.dumps(certify_one(arguments.tex, arguments.label), sort_keys=True))
        return 0
    return run_driver(arguments.tex, arguments.output)


if __name__ == "__main__":
    raise SystemExit(main())
