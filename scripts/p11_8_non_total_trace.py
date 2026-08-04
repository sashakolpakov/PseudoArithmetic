#!/usr/bin/env python3
"""Exact certificate that the Ma--Zheng lattice P_{11,8} is not pseudo-arithmetic.

The decisive point is elementary: its Vinberg cyclic-product field contains
``Q(sqrt(5), sqrt(2)*a)``, and this subfield has a complex place.  The fuller
primitive-element calculation is included as an independent check.

This is deliberately a single-case script.  It uses one Python process and
one short-lived GP process, and may write one fsynced JSON result.
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
import time

import numpy as np
from sympy import Matrix, Poly, Rational, factor, minimal_polynomial, simplify, sqrt, symbols
from sympy.polys.numberfields import to_number_field


EXPECTED_SOURCE_SHA256 = "0017931637f017641d4935450cc2a07d070866d9c749443d9e3ede9f3a39f003"
EXPECTED_VECTOR = "2232ab523242220442222"
EXPECTED_MINPOLY = (
    "x^8 - 8*x^7 - 252*x^6 - 1392*x^5 - 3524*x^4 - 5280*x^3 "
    "- 5712*x^2 - 3968*x - 1136"
)
PAIRS = list(combinations(range(7), 2))


def source_vector(path: Path) -> tuple[str, int, str]:
    data = path.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    for line_number, raw_line in enumerate(data.decode().splitlines(), start=1):
        if r"P_{11,8}" not in raw_line:
            continue
        fields = raw_line.split("&")
        tokens: list[str] = []
        for field in fields[1:7]:
            field = re.sub(r"\\color\{[^}]+\}", "", field)
            tokens.append(re.sub(r"[^0-9abcX]", "", field.replace("$", "")))
        return "".join(tokens), line_number, digest
    raise ValueError("P_{11,8} was not found in the source table")


def gram_matrix(a, b, *, symbolic: bool = False) -> Matrix:
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
    for (i, j), token in zip(PAIRS, EXPECTED_VECTOR, strict=True):
        matrix[i, j] = matrix[j, i] = values[token]
    return matrix


def gp_field_check(polynomial: str) -> dict[str, object]:
    program = f"""
P={polynomial};
print("IRRED=",polisirreducible(P));
K=nfinit(P);
print("SIGN=",K.sign);
print("DISC=",nfdisc(P));
quit;
"""
    completed = subprocess.run(
        ["gp", "-q"],
        input=program,
        text=True,
        capture_output=True,
        check=False,
        timeout=30,
    )
    output = completed.stdout + completed.stderr
    if completed.returncode != 0 or "***" in output:
        raise RuntimeError(f"GP failed:\n{output}")
    irreducible = re.search(r"^IRRED=(\d+)$", output, re.MULTILINE)
    signature = re.search(r"^SIGN=\[(\d+), (\d+)\]$", output, re.MULTILINE)
    discriminant = re.search(r"^DISC=(-?\d+)$", output, re.MULTILINE)
    if irreducible is None or signature is None or discriminant is None:
        raise ValueError(f"incomplete GP output:\n{output}")
    return {
        "irreducible": irreducible.group(1) == "1",
        "field_signature": [int(signature.group(1)), int(signature.group(2))],
        "field_discriminant": int(discriminant.group(1)),
    }


def rational_strings(values) -> list[str]:
    return [str(value) for value in values]


def certify(tex: Path) -> dict[str, object]:
    started = time.monotonic()
    vector, line_number, source_sha256 = source_vector(tex)
    if vector != EXPECTED_VECTOR:
        raise ValueError(f"source vector changed: {vector}")
    if source_sha256 != EXPECTED_SOURCE_SHA256:
        raise ValueError(f"source hash changed: {source_sha256}")

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

    avar, bvar = symbols("a b", real=True)
    symbolic = gram_matrix(avar, bvar, symbolic=True)
    omit_six = [0, 1, 2, 3, 4, 5]
    omit_five = [0, 1, 2, 3, 4, 6]
    equation_a = factor(
        32
        * symbolic.extract(omit_six, omit_six).det(method="berkowitz")
    )
    equation_b = factor(
        32
        * symbolic.extract(omit_five, omit_five).det(method="berkowitz")
    )
    expected_a = 2 * (s - 1) * avar**2 + 2 * r * (s - 3) * avar + s - 7
    expected_b = (
        2 * (s - 1) * bvar**2
        - 2 * (4 + r * (1 + s)) * bvar
        - (7 + s + 2 * r * (1 + s))
    )
    if simplify(equation_a - expected_a) != 0:
        raise ValueError("unexpected isolated equation for a")
    if simplify(equation_b - expected_b) != 0:
        raise ValueError("unexpected isolated equation for b")
    if (a - 1).is_positive is not True or (b - 1).is_positive is not True:
        raise ValueError("the geometric roots were not certified to exceed one")

    gram = gram_matrix(a, b)
    principal_six_minors = []
    for omitted in range(7):
        indices = [index for index in range(7) if index != omitted]
        principal_six_minors.append(
            simplify(gram.extract(indices, indices).det(method="berkowitz"))
        )
    if principal_six_minors != [0] * 7:
        raise ValueError(f"a principal rank condition failed: {principal_six_minors}")
    rank = gram.rank()
    ambient_block = gram.extract(range(5), range(5))
    leading_principal_minors = [
        factor(ambient_block[:size, :size].det(method="berkowitz"))
        for size in range(1, 6)
    ]
    rank_five_minor = leading_principal_minors[-1]
    if rank != 5 or simplify(rank_five_minor + (1 + s) / 32) != 0:
        raise ValueError("the Gram matrix does not have certified rank five")
    if not all(value.is_positive is True for value in leading_principal_minors[:4]):
        raise ValueError("a leading ambient minor was not certified positive")
    if rank_five_minor.is_negative is not True:
        raise ValueError("the rank-five ambient determinant was not certified negative")

    eigenvalues = np.linalg.eigvalsh(np.array(gram.evalf(40).tolist(), dtype=float))
    tolerance = 1e-10
    numerical_signature = [
        int(np.count_nonzero(eigenvalues > tolerance)),
        int(np.count_nonzero(eigenvalues < -tolerance)),
        int(np.count_nonzero(np.abs(eigenvalues) <= tolerance)),
    ]
    if numerical_signature != [4, 1, 2]:
        raise ValueError(f"unexpected numerical Gram signature: {numerical_signature}")

    # These four Cartan cyclic products recover every non-rational raw entry.
    # Hence the cyclic-product field is exactly Q(sqrt(5),sqrt(2),a,b).
    cartan = 2 * gram
    cycle_12 = simplify(cartan[1, 2] * cartan[2, 1])
    cycle_126 = simplify(cartan[1, 2] * cartan[2, 6] * cartan[6, 1])
    cycle_035 = simplify(cartan[0, 3] * cartan[3, 5] * cartan[5, 0])
    cycle_03416 = simplify(
        cartan[0, 3]
        * cartan[3, 4]
        * cartan[4, 1]
        * cartan[1, 6]
        * cartan[6, 0]
    )
    recovered = [
        simplify(2 * cycle_12 - 3 - s),
        simplify(-cycle_126 / (1 + s) - r),
        simplify(-cycle_035 / (2 * r) - a),
        simplify(-cycle_03416 / 4 - b),
    ]
    if recovered != [0] * 4:
        raise ValueError(f"cyclic products failed to recover generators: {recovered}")

    # A hand-checkable obstruction: u=sqrt(2)*a generates a quadratic over
    # Q(sqrt(5)) whose discriminant is negative at the conjugate real place.
    u = r * a
    u_relation = simplify((s - 1) * u**2 + 2 * (s - 3) * u + s - 7)
    u_discriminant = simplify((2 * (s - 3)) ** 2 - 4 * (s - 1) * (s - 7))
    conjugate_discriminant = 8 * (1 - s)
    if u_relation != 0 or simplify(u_discriminant - 8 * (1 + s)) != 0:
        raise ValueError("the quadratic subfield relation failed")
    if conjugate_discriminant.is_negative is not True:
        raise ValueError("the conjugate discriminant was not certified negative")

    # Independent whole-field check.  The exact conversions below prove that
    # the simple primitive element contains all four raw generators.
    w = 2 * (r + a + b)
    polynomial = minimal_polynomial(w)
    expected_polynomial = Poly(EXPECTED_MINPOLY.replace("^", "**"), symbols("x"))
    if Poly(polynomial).all_coeffs() != expected_polynomial.all_coeffs():
        raise ValueError(f"primitive polynomial changed: {polynomial}")
    theta = to_number_field(w)
    coordinates = {
        "sqrt5": rational_strings(to_number_field(s, theta).native_coeffs()),
        "sqrt2": rational_strings(to_number_field(r, theta).native_coeffs()),
        "a": rational_strings(to_number_field(a, theta).native_coeffs()),
        "b": rational_strings(to_number_field(b, theta).native_coeffs()),
    }
    gp = gp_field_check(EXPECTED_MINPOLY)
    if (
        not gp["irreducible"]
        or gp["field_signature"] != [4, 2]
        or gp["field_discriminant"] != 40960000
    ):
        raise ValueError(f"whole-field GP certificate failed: {gp}")

    return {
        "label": "P_{11,8}",
        "source": {
            "path": str(tex.resolve()),
            "line": line_number,
            "sha256": source_sha256,
            "vector": vector,
            "cusps": 2,
            "volume_over_pi_squared": "19/864",
        },
        "distances": {
            "a": str(a),
            "b": str(b),
            "a_numeric": str(a.evalf(18)),
            "b_numeric": str(b.evalf(18)),
            "both_greater_than_one_exact": True,
        },
        "rank_certificate": {
            "equation_a": str(equation_a),
            "equation_b": str(equation_b),
            "principal_six_minors": [str(value) for value in principal_six_minors],
            "gram_rank": rank,
            "rank_five_minor_01234": str(rank_five_minor),
            "leading_principal_minors_ambient_01234": [
                str(value) for value in leading_principal_minors
            ],
            "exact_signature_positive_negative_zero": [4, 1, 2],
            "numerical_signature_positive_negative_zero": numerical_signature,
            "numerical_eigenvalues": [float(value) for value in eigenvalues],
        },
        "cyclic_product_certificate": {
            "field": "Q(sqrt(5),sqrt(2),a,b)",
            "c12": str(cycle_12),
            "c126": str(cycle_126),
            "c035": str(cycle_035),
            "c03416": str(cycle_03416),
            "recovers_all_raw_generators": True,
        },
        "non_total_reality_certificate": {
            "subfield_generator": "u=sqrt(2)*a",
            "relative_polynomial": "(sqrt(5)-1)u^2+2(sqrt(5)-3)u+(sqrt(5)-7)",
            "discriminant": str(u_discriminant),
            "discriminant_at_sqrt5_conjugate": str(conjugate_discriminant),
            "conjugate_discriminant_negative_exact": True,
        },
        "whole_field_certificate": {
            "primitive_generator": "w=2*(sqrt(2)+a+b)",
            "minimal_polynomial": EXPECTED_MINPOLY,
            "degree": 8,
            "generator_coordinate_vectors_high_to_low": coordinates,
            **gp,
        },
        "conclusion": "adjoint_trace_field_not_totally_real_implies_not_pseudo_arithmetic",
        "wall_seconds": round(time.monotonic() - started, 3),
        "peak_rss_raw": resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "tex",
        type=Path,
        nargs="?",
        default=Path("/private/tmp/paperarXiv/hcp47.tex"),
    )
    parser.add_argument("--output", type=Path)
    arguments = parser.parse_args()
    result = certify(arguments.tex)
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
