#!/usr/bin/env python3
"""Memory-bounded cross-check of the lightweight Clifford obstruction.

The arithmetic in this program is intentionally independent of the complete
normalized-descent implementation.  It imports only the census parser and
raw Gram/Vinberg reconstruction, then asks
``scripts/lightweight_clifford_support.gp`` to compute ``C^0(q)`` directly
from an *unnormalized* rank-five representative.  The parent process compares
the resulting finite-place decision with the durable output of the earlier
criterion; it never imports or calls ``census_quadratic_clifford.py`` or
``quadratic_split_support.gp``.

With ``--all``, every case is run in a fresh Python process, which in turn
uses one fresh PARI/GP process.  Each JSON line is flushed and synced before
the next case, and the complete output replaces its predecessor atomically.
"""

from __future__ import annotations

import argparse
import ast
from fractions import Fraction
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import subprocess
import sys

from sympy import Poly, Rational
from sympy.polys.numberfields import to_number_field


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PRIOR = ROOT / "results" / "one_distance_certificates.jsonl"
EXPECTED_SOURCE_SHA256 = (
    "0017931637f017641d4935450cc2a07d070866d9c749443d9e3ede9f3a39f003"
)
PRIOR_STATUSES = {
    "pseudo_via_quadratic_descent",
    "pseudo_via_multiquadratic_descent",
}


def load_raw_scanner():
    path = Path(__file__).with_name("census_one_distance_scan.py")
    specification = importlib.util.spec_from_file_location("raw_one_distance", path)
    assert specification is not None and specification.loader is not None
    module = importlib.util.module_from_spec(specification)
    specification.loader.exec_module(module)
    return module


RAW = load_raw_scanner()


def source_digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def gp_rational(value) -> str:
    rational = Rational(value)
    if rational.q == 1:
        return str(rational.p)
    return f"({rational.p}/{rational.q})"


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
    terms: list[str] = []
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
    terms: list[str] = []
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


def gp_matrix(matrix, theta) -> str:
    rows: list[str] = []
    for row in range(matrix.rows):
        rows.append(
            ",".join(
                gp_primitive_element(matrix[row, column], theta)
                for column in range(matrix.cols)
            )
        )
    return "[" + ";".join(rows) + "]"


def parse_literal(output: str, key: str):
    match = re.search(rf"^{re.escape(key)}=(\[[^\n]*\])$", output, re.MULTILINE)
    if match is None:
        raise ValueError(f"missing {key} in GP output:\n{output}")
    return ast.literal_eval(match.group(1))


def prior_cases(path: Path) -> dict[str, dict[str, object]]:
    records = [json.loads(line) for line in path.read_text().splitlines()]
    cases = {
        str(record["label"]): record
        for record in records
        if "label" in record and record.get("status") in PRIOR_STATUSES
    }
    if not cases:
        raise ValueError(f"no prior finite-descent cases in {path}")
    return cases


def run_direct_gp(matrix, theta) -> dict[str, object]:
    polynomial = gp_polynomial(theta.minpoly)
    program = f"""
lightweight_clifford_library_mode=1;
read(\"scripts/lightweight_clifford_support.gp\");
P={polynomial};
if(!polisirreducible(P),error(\"the reconstructed field polynomial is reducible\"));
K=nfinit(P);
z=Mod(y,P);
Q={gp_matrix(matrix, theta)};
D=lw_diagonalize_symmetric(Q);
if(#D!=5,error(\"the direct representative does not have rank five\"));
R=lw_finite_ramification(K,D);
W=lw_split_support_witnesses_over_Q(K,R);
print(\"RAM_RECORDS=\",R);
print(\"BAD_NONSPLIT=\",W[1]);
print(\"BAD_INCOMPLETE=\",W[2]);
quit;
"""
    completed = subprocess.run(
        ["gp", "-q"],
        input=program,
        text=True,
        capture_output=True,
        check=False,
        timeout=90,
        cwd=ROOT,
    )
    output = completed.stdout + completed.stderr
    if completed.returncode != 0 or "***" in output:
        raise RuntimeError(f"independent GP worker failed:\n{output}")

    ramified_records = parse_literal(output, "RAM_RECORDS")
    bad_nonsplit = parse_literal(output, "BAD_NONSPLIT")
    bad_incomplete = parse_literal(output, "BAD_INCOMPLETE")
    places = [
        {
            "rational_prime": record[0],
            "prime_index": record[1],
            "ramification_index": record[2],
            "residue_degree": record[3],
            "local_degree": record[2] * record[3],
        }
        for record in ramified_records
    ]
    nonsplit_witnesses = [
        {
            "kind": "ramified_prime_has_nontrivial_decomposition_group",
            "rational_prime": record[0],
            "prime_index": record[1],
            "ramification_index": record[2],
            "residue_degree": record[3],
            "local_degree": record[4],
        }
        for record in bad_nonsplit
    ]
    incomplete_witnesses = [
        {
            "kind": "ramification_is_not_a_complete_split_fibre",
            "rational_prime": record[0],
            "ramified_count": record[1],
            "fibre_size": record[2],
            "ramified_prime_indices": record[3],
        }
        for record in bad_incomplete
    ]
    return {
        "finite_ramified_places": places,
        "nonsplit_place_witnesses": nonsplit_witnesses,
        "incomplete_split_fibre_witnesses": incomplete_witnesses,
        "lightweight_split_support_pass": not (
            nonsplit_witnesses or incomplete_witnesses
        ),
    }


def analyze_label(
    tex: Path, label: tuple[int, int], prior_path: Path
) -> dict[str, object]:
    if source_digest(tex) != EXPECTED_SOURCE_SHA256:
        raise ValueError("hcp47.tex does not have the pinned Ma--Zheng digest")
    name = f"P_{{{label[0]},{label[1]}}}"
    prior = prior_cases(prior_path).get(name)
    if prior is None:
        raise ValueError(f"{name} is not a prior nontrivial finite-descent case")

    rows = RAW.parse_census(tex)
    vector = rows[label]
    distance = RAW.exact_distance(vector)
    gram = RAW.gram_matrix(vector, distance)
    vinberg = RAW.vinberg_matrix(gram)
    indices = tuple(int(index) for index in prior["ambient_indices"])
    ambient = vinberg.extract(indices, indices)
    if ambient.det(method="berkowitz") == 0:
        raise ValueError("the recorded raw rank-five representative is singular")

    generators = []
    for entry in vinberg:
        if entry.is_Rational is not True and entry not in generators:
            generators.append(entry)
    if not generators:
        raise ValueError("a nontrivial descent case unexpectedly has rational entries")
    theta = integral_primitive_element(generators)
    direct = run_direct_gp(ambient, theta)

    direct_primes = sorted(
        int(place["rational_prime"])
        for place in direct["finite_ramified_places"]
    )
    prior_primes = sorted(
        int(prime) for prime in prior["finite_ramified_rational_primes"]
    )
    prior_pass = bool(prior["split_support_pass"])
    support_agreement = direct_primes == prior_primes
    decision_agreement = direct["lightweight_split_support_pass"] == prior_pass
    if not support_agreement or not decision_agreement:
        raise ValueError(
            f"{name}: direct C^0(q) disagrees with the normalized criterion"
        )

    return {
        "label": name,
        "source_sha256": EXPECTED_SOURCE_SHA256,
        "rank": 5,
        "representative": "unnormalized Vinberg cyclic-product form",
        "normalization_used": False,
        "trace_degree": prior["trace_degree"],
        **direct,
        "prior_criterion_status": prior["status"],
        "prior_split_support_pass": prior_pass,
        "ramified_support_agreement": support_agreement,
        "finite_decision_agreement": decision_agreement,
    }


def parse_label(value: str) -> tuple[int, int]:
    parts = value.split(",")
    if len(parts) != 2:
        raise argparse.ArgumentTypeError("a label must be i,j")
    return int(parts[0]), int(parts[1])


def run_all(tex: Path, prior_path: Path, output_path: Path | None) -> int:
    cases = prior_cases(prior_path)
    labels = sorted(
        (
            tuple(int(part) for part in re.fullmatch(r"P_\{(\d+),(\d+)\}", name).groups())
            for name in cases
        )
    )
    log = None
    checkpoint = None
    completed_all = False
    if output_path is not None:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        checkpoint = output_path.with_name(output_path.name + ".partial")
        log = checkpoint.open("w")

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
                    "--prior",
                    str(prior_path),
                ],
                text=True,
                capture_output=True,
                check=False,
                timeout=180,
            )
            if completed.returncode != 0:
                print(completed.stderr, file=sys.stderr)
                raise RuntimeError(f"worker failed for P_{{{first},{second}}}")
            emit(json.loads(completed.stdout))

        summary = {
            "cases_cross_checked": len(labels),
            "all_ramified_supports_agree": True,
            "all_finite_decisions_agree": True,
            "normalization_used": False,
            "full_descent_code_imported_or_called": False,
            "result": "PASS",
        }
        emit(summary)
        completed_all = True
    finally:
        if log is not None:
            log.close()
        if completed_all and checkpoint is not None and output_path is not None:
            os.replace(checkpoint, output_path)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("tex", type=Path)
    parser.add_argument("--prior", type=Path, default=DEFAULT_PRIOR)
    parser.add_argument("--label", type=parse_label)
    parser.add_argument("--all", action="store_true")
    parser.add_argument("--output", type=Path)
    arguments = parser.parse_args()
    if arguments.label is not None:
        print(
            json.dumps(
                analyze_label(arguments.tex, arguments.label, arguments.prior),
                sort_keys=True,
            )
        )
        return 0
    if arguments.all:
        return run_all(arguments.tex, arguments.prior, arguments.output)
    parser.error("choose --label i,j or --all")
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
