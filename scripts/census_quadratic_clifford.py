#!/usr/bin/env python3
"""Exact bounded Clifford screen for one-distance census cases.

Every ``--all`` case runs in a fresh Python process, and every relevant form
uses a fresh PARI/GP process.  No matrices or number fields accumulate across
cases.  PARI certifies signatures at every real embedding and verifies that
the trace-field Galois group has exponent two before a descent to Q is called
pseudo-arithmetic.  Only constant-Lorentzian forms reach the local
split-support test; rational descents and exact quasi-arithmetic signature
patterns are reported and skipped.
"""

from __future__ import annotations

import argparse
import ast
from fractions import Fraction
import importlib.util
import json
import os
from pathlib import Path
import re
import subprocess
import sys

from sympy import Poly, Rational, factorint, sqrt
from sympy.polys.numberfields import to_number_field


def load_scanner():
    path = Path(__file__).with_name("census_one_distance_scan.py")
    specification = importlib.util.spec_from_file_location("one_distance", path)
    assert specification is not None and specification.loader is not None
    module = importlib.util.module_from_spec(specification)
    specification.loader.exec_module(module)
    return module


SCAN = load_scanner()


def squarefree_radicand(polynomial: Poly) -> int:
    if polynomial.degree() != 2:
        raise ValueError("quadratic trace polynomial required")
    leading, linear, constant = polynomial.all_coeffs()
    discriminant = Rational(linear**2 - 4 * leading * constant)
    if discriminant <= 0:
        raise ValueError("trace field is not real quadratic")
    rational = Fraction(int(discriminant.p), int(discriminant.q))
    product = abs(rational.numerator * rational.denominator)
    result = 1
    for prime, exponent in factorint(product).items():
        if exponent % 2:
            result *= int(prime)
    return result


def gp_rational(value) -> str:
    rational = Rational(value)
    if rational.q == 1:
        return str(rational.p)
    return f"({rational.p}/{rational.q})"


def gp_quadratic_element(expression, radicand: int) -> str:
    algebraic = to_number_field(expression, sqrt(radicand))
    coefficients = algebraic.native_coeffs()
    if len(coefficients) == 1:
        return gp_rational(coefficients[0])
    if len(coefficients) != 2:
        raise ValueError(f"entry is not quadratic: {expression}")
    linear, constant = coefficients
    return f"({gp_rational(linear)})*z+({gp_rational(constant)})"


def gp_matrix(matrix, radicand: int) -> str:
    rows = []
    for row in range(matrix.rows):
        rows.append(
            ",".join(
                gp_quadratic_element(matrix[row, column], radicand)
                for column in range(matrix.cols)
            )
        )
    return "[" + ";".join(rows) + "]"


def integral_primitive_element(generators):
    theta = to_number_field(generators)
    leading = Rational(theta.minpoly.LC())
    if leading != 1:
        theta = to_number_field(leading * theta.as_expr())
    if Rational(theta.minpoly.LC()) != 1:
        raise ValueError("failed to construct a monic primitive polynomial")
    return theta


def gp_polynomial(polynomial: Poly) -> str:
    degree = polynomial.degree()
    terms = []
    for index, coefficient in enumerate(polynomial.all_coeffs()):
        power = degree - index
        if coefficient == 0:
            continue
        term = gp_rational(coefficient)
        if power:
            term += "*y"
        if power > 1:
            term += f"^{power}"
        terms.append(term)
    return "+".join(terms).replace("+-", "-")


def gp_primitive_element(expression, theta) -> str:
    algebraic = to_number_field(expression, theta)
    coefficients = algebraic.native_coeffs()
    degree = len(coefficients) - 1
    terms = []
    for index, coefficient in enumerate(coefficients):
        power = degree - index
        if coefficient == 0:
            continue
        term = f"({gp_rational(coefficient)})"
        if power:
            term += "*z"
        if power > 1:
            term += f"^{power}"
        terms.append(term)
    return "+".join(terms).replace("+-", "-") if terms else "0"


def gp_primitive_matrix(matrix, theta) -> str:
    rows = []
    for row in range(matrix.rows):
        rows.append(
            ",".join(
                gp_primitive_element(matrix[row, column], theta)
                for column in range(matrix.cols)
            )
        )
    return "[" + ";".join(rows) + "]"


def parse_vector(output: str, key: str) -> list[int]:
    match = re.search(rf"^{re.escape(key)}=(\[[^\n]*\])$", output, re.MULTILINE)
    if match is None:
        raise ValueError(f"missing {key} in GP output:\n{output}")
    return [int(value) for value in ast.literal_eval(match.group(1))]


def parse_integer(output: str, key: str) -> int:
    match = re.search(rf"^{re.escape(key)}=(-?\d+)$", output, re.MULTILINE)
    if match is None:
        raise ValueError(f"missing {key} in GP output:\n{output}")
    return int(match.group(1))


def run_gp_field_certificate(matrix, theta) -> dict[str, object]:
    """Certify real signatures and the elementary-2 Galois condition."""

    polynomial = gp_polynomial(theta.minpoly)
    program = f"""
split_support_library_mode=1;
read(\"scripts/quadratic_split_support.gp\");
P={polynomial};
if(!polisirreducible(P),error("the primitive polynomial is reducible"));
K=nfinit(P);
z=Mod(y,P);
Q={gp_primitive_matrix(matrix, theta)};
D=diagonalize_symmetric(Q);
r1=K.sign[1];
r2=K.sign[2];
positive=vector(r1,j,sum(i=1,#D,nfeltsign(K,D[i],j)>0));
negative=vector(r1,j,sum(i=1,#D,nfeltsign(K,D[i],j)<0));
A=nfgaloisconj(K);
involutive=vector(#A,i,lift(nfgaloisapply(K,A[i],Mod(A[i],P))-z)==0);
print(\"FIELD_DEGREE=\",poldegree(P));
print(\"MINPOLY_IRREDUCIBLE=1\");
print(\"REAL_PLACES=\",r1);
print(\"COMPLEX_PAIRS=\",r2);
print(\"SIG_POS=\",positive);
print(\"SIG_NEG=\",negative);
print(\"AUT_COUNT=\",#A);
print(\"AUT_INVOLUTIVE=\",involutive);
quit;
"""
    completed = subprocess.run(
        ["gp", "-q"],
        input=program,
        text=True,
        capture_output=True,
        check=False,
        timeout=30,
        cwd=Path(__file__).resolve().parents[1],
    )
    output = completed.stdout + completed.stderr
    if completed.returncode != 0 or "***" in output:
        raise RuntimeError(f"GP failed:\n{output}")

    degree = parse_integer(output, "FIELD_DEGREE")
    minpoly_irreducible = parse_integer(output, "MINPOLY_IRREDUCIBLE") == 1
    real_places = parse_integer(output, "REAL_PLACES")
    complex_pairs = parse_integer(output, "COMPLEX_PAIRS")
    positive = parse_vector(output, "SIG_POS")
    negative = parse_vector(output, "SIG_NEG")
    automorphism_count = parse_integer(output, "AUT_COUNT")
    involutive = parse_vector(output, "AUT_INVOLUTIVE")
    if len(positive) != real_places or len(negative) != real_places:
        raise ValueError("PARI returned an incomplete signature vector")
    signatures = sorted(
        [max(pos, neg), min(pos, neg)]
        for pos, neg in zip(positive, negative, strict=True)
    )
    if any(sum(signature) != matrix.rows for signature in signatures):
        raise ValueError("the exact diagonalization produced a zero real pivot")
    elementary_2 = (
        automorphism_count == degree
        and len(involutive) == degree
        and all(value == 1 for value in involutive)
    )
    return {
        "trace_degree": degree,
        "trace_minpoly_irreducible": minpoly_irreducible,
        "real_places": real_places,
        "complex_pairs": complex_pairs,
        "signatures": signatures,
        "field_automorphism_count": automorphism_count,
        "field_automorphisms_involutive": involutive,
        "field_elementary_2_over_Q": elementary_2,
    }


def run_gp(matrix, radicand: int) -> dict[str, object]:
    program = f"""
split_support_library_mode=1;
read(\"scripts/quadratic_split_support.gp\");
K=nfinit(y^2-{radicand});
z=Mod(y,y^2-{radicand});
Q={gp_matrix(matrix, radicand)};
D=normalized_diagonal(Q);
R=clifford_finite_ramification(K,D);
obs=quadratic_split_support_obstructions(K,R);
print(\"RAM=\",vector(#R,i,R[i][1]));
print(\"BAD_LOCAL=\",vector(#obs[1],i,obs[1][i][1]));
print(\"BAD_FIBRE=\",vector(#obs[2],i,obs[2][i][1]));
quit;
"""
    completed = subprocess.run(
        ["gp", "-q"],
        input=program,
        text=True,
        capture_output=True,
        check=False,
        timeout=30,
        cwd=Path(__file__).resolve().parents[1],
    )
    output = completed.stdout + completed.stderr
    if completed.returncode != 0 or "***" in output:
        raise RuntimeError(f"GP failed:\n{output}")
    ramified = parse_vector(output, "RAM")
    bad_local = parse_vector(output, "BAD_LOCAL")
    bad_fibre = parse_vector(output, "BAD_FIBRE")
    return {
        "finite_ramified_rational_primes": ramified,
        "bad_non_split_rational_primes": bad_local,
        "bad_incomplete_split_fibres": bad_fibre,
        "split_support_pass": not bad_local and not bad_fibre,
    }


def run_gp_multiquadratic(matrix, theta) -> dict[str, object]:
    polynomial = gp_polynomial(theta.minpoly)
    program = f"""
split_support_library_mode=1;
read(\"scripts/quadratic_split_support.gp\");
P={polynomial};
K=nfinit(P);
z=Mod(y,P);
Q={gp_primitive_matrix(matrix, theta)};
D=normalized_diagonal(Q);
R=clifford_finite_ramification(K,D);
obs=split_support_over_Q_obstructions(K,R);
print(\"RAM=\",vector(#R,i,R[i][1]));
print(\"BAD_LOCAL=\",vector(#obs[1],i,obs[1][i][1]));
print(\"BAD_FIBRE=\",vector(#obs[2],i,obs[2][i][1]));
quit;
"""
    completed = subprocess.run(
        ["gp", "-q"],
        input=program,
        text=True,
        capture_output=True,
        check=False,
        timeout=90,
        cwd=Path(__file__).resolve().parents[1],
    )
    output = completed.stdout + completed.stderr
    if completed.returncode != 0 or "***" in output:
        raise RuntimeError(f"GP failed:\n{output}")
    ramified = parse_vector(output, "RAM")
    bad_local = parse_vector(output, "BAD_LOCAL")
    bad_fibre = parse_vector(output, "BAD_FIBRE")
    return {
        "finite_ramified_rational_primes": ramified,
        "bad_non_split_rational_primes": bad_local,
        "bad_incomplete_split_fibres": bad_fibre,
        "split_support_pass": not bad_local and not bad_fibre,
    }


def analyze_label(tex: Path, label: tuple[int, int]) -> dict[str, object]:
    rows = SCAN.parse_census(tex)
    vector = rows[label]
    distance = SCAN.exact_distance(vector)
    gram = SCAN.gram_matrix(vector, distance)
    gram_rank = gram.rank()
    if gram_rank != 5:
        raise ValueError(f"the exact Gram matrix has rank {gram_rank}, not five")
    vinberg = SCAN.vinberg_matrix(gram)
    name = f"P_{{{label[0]},{label[1]}}}"
    base: dict[str, object] = {
        "label": name,
        "distance": str(distance),
        "gram_rank": gram_rank,
    }
    rational_minor = SCAN.rational_rank_five_minor(vinberg)

    generators = []
    for entry in vinberg:
        if entry.is_Rational is not True and entry not in generators:
            generators.append(entry)

    if not generators:
        if rational_minor is None:
            raise ValueError("a rational rank-five form had no rational restriction")
        return {
            **base,
            "trace_degree": 1,
            "trace_minpoly": "y - 1",
            "real_places": 1,
            "complex_pairs": 0,
            "signatures": [[4, 1]],
            "field_elementary_2_over_Q": True,
            "ambient_indices": list(rational_minor),
            "status": "rational_descent",
        }

    theta = integral_primitive_element(generators)
    indices = (
        rational_minor
        if rational_minor is not None
        else SCAN.first_numeric_rank_five_minor(vinberg)
    )
    ambient = vinberg.extract(indices, indices)
    field_data = run_gp_field_certificate(ambient, theta)
    result: dict[str, object] = {
        **base,
        "trace_minpoly": str(theta.minpoly.as_expr()),
        **field_data,
    }
    result["ambient_indices"] = list(indices)

    trace_degree = int(field_data["trace_degree"])
    if int(field_data["complex_pairs"]) != 0:
        result["status"] = "non_totally_real_trace_field_obstruction"
        return result

    signatures = field_data["signatures"]
    lorentzian_places = sum(signature == [4, 1] for signature in signatures)
    definite_places = sum(signature == [5, 0] for signature in signatures)
    if lorentzian_places == 1 and definite_places == trace_degree - 1:
        result["status"] = "quasi_arithmetic"
        return result
    if lorentzian_places != trace_degree:
        result["status"] = "unresolved_signature_pattern"
        return result
    if not bool(field_data["field_elementary_2_over_Q"]):
        result["status"] = "non_multiquadratic_trace_field_obstruction"
        return result
    if rational_minor is not None:
        result["status"] = "rational_descent"
        return result
    if trace_degree not in (2, 4, 8):
        result["status"] = "unsupported_trace_degree"
        return result

    if trace_degree == 2:
        radicand = squarefree_radicand(theta.minpoly)
        result["quadratic_radicand"] = radicand
        result.update(run_gp(ambient, radicand))
        result["status"] = (
            "pseudo_via_quadratic_descent"
            if result["split_support_pass"]
            else "split_support_obstruction"
        )
    else:
        result.update(run_gp_multiquadratic(ambient, theta))
        if not result["field_elementary_2_over_Q"]:
            result["status"] = "non_multiquadratic_trace_field_obstruction"
        else:
            result["status"] = (
                "pseudo_via_multiquadratic_descent"
                if result["split_support_pass"]
                else "split_support_obstruction"
            )
    return result


def run_all(tex: Path, output_path: Path | None = None) -> int:
    rows = SCAN.parse_census(tex)
    labels = sorted(
        label
        for label, vector in rows.items()
        if sum(token in "abc" for token in vector) == 1
    )
    counts: dict[str, int] = {}
    obstructions: list[str] = []
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
                text=True,
                capture_output=True,
                check=False,
                timeout=180,
            )
            if completed.returncode != 0:
                print(completed.stderr, file=sys.stderr)
                raise RuntimeError(f"worker failed for P_{{{first},{second}}}")
            result = json.loads(completed.stdout)
            status = str(result["status"])
            counts[status] = counts.get(status, 0) + 1
            if status.endswith("obstruction"):
                obstructions.append(str(result["label"]))
            emit(result)
        emit({"counts": counts, "obstructions": obstructions})
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
    parser.add_argument("--all", action="store_true")
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
    if arguments.all:
        return run_all(arguments.tex, arguments.output)
    parser.error("choose --label i,j or --all")
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
