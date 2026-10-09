#!/usr/bin/env python3
"""Run the complete offline validation for a PseudoArithmetic release."""

from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import py_compile
import re
import subprocess
import sys
import tempfile

from manuscript_audit import declarations as statement_declarations


ROOT = Path(__file__).resolve().parents[1]
EXPECTED_VERSION = "1.0.0-rc1"
EXPECTED_DATE = "2026-09-24"


class CheckError(RuntimeError):
    """A release invariant failed."""


def announce(label: str) -> None:
    print(f"[check] {label}", flush=True)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise CheckError(message)


def run_command(
    label: str,
    argv: list[str],
    *,
    cwd: Path = ROOT,
    required_output: tuple[str, ...] = (),
) -> str:
    announce(label)
    environment = os.environ.copy()
    environment["PYTHONDONTWRITEBYTECODE"] = "1"
    process = subprocess.run(
        argv,
        cwd=cwd,
        env=environment,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    if process.returncode != 0:
        raise CheckError(
            f"{label} failed with exit code {process.returncode}\n{process.stdout}"
        )
    for marker in required_output:
        require(marker in process.stdout, f"{label} did not report {marker!r}")
    return process.stdout


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def check_required_files() -> None:
    announce("required release files")
    required = [
        "VERSION",
        "README.md",
        "RELEASE_NOTES.md",
        "PRE_RELEASE_CHECKLIST.md",
        "FORMAL_VERIFICATION.md",
        "REPRODUCIBILITY.md",
        "NOVELTY_AUDIT.md",
        "CITATION.cff",
        "release/manifest.json",
        "formal/PseudoArithmetic/Manuscript.lean",
        "formal/PseudoArithmetic/SemanticAudit.lean",
        "formal/PseudoArithmetic/ExternalContracts.lean",
        "formal/PseudoArithmetic/SubdiagramAudit.lean",
        "formal/PseudoArithmetic/SubdiagramClassify.lean",
        "formal/PseudoArithmetic/SubdiagramControls.lean",
        "formal/PseudoArithmetic/FaceAudit.lean",
        "formal/PseudoArithmetic/FaceControls.lean",
        "formal/PseudoArithmetic/DiagramFaceAudit.lean",
        "notes/two_cycle_semantic_audit.md",
        "results/two_cycle_semantic_audit.json",
        "audit/manuscript_statements.json",
        "notes/manuscript_semantic_audit.md",
        "notes/external_translation_audit.md",
        "notes/subdiagram_face_semantic_audit.md",
        "results/manuscript_computation_audit.json",
        "scripts/manuscript_audit.py",
        "scripts/manuscript_computation_audit.py",
        "scripts/manuscript_field_controls.gp",
        "manuscript/non_pseudo_arithmetic_4_manifolds.tex",
        "manuscript/non_pseudo_arithmetic_4_manifolds.pdf",
    ]
    missing = [item for item in required if not (ROOT / item).is_file()]
    require(not missing, f"missing release files: {missing}")


def check_version_consistency() -> None:
    announce("version and date consistency")
    require((ROOT / "VERSION").read_text().strip() == EXPECTED_VERSION, "VERSION mismatch")
    citation = (ROOT / "CITATION.cff").read_text()
    require(f"version: {EXPECTED_VERSION}" in citation, "CITATION.cff version mismatch")
    require(f"date-released: {EXPECTED_DATE}" in citation, "CITATION.cff date mismatch")
    readme = (ROOT / "README.md").read_text()
    notes = (ROOT / "RELEASE_NOTES.md").read_text()
    manuscript = (ROOT / "manuscript/non_pseudo_arithmetic_4_manifolds.tex").read_text()
    require(EXPECTED_VERSION in readme, "README version mismatch")
    require(EXPECTED_VERSION in notes, "release-notes version mismatch")
    require("24 September 2026" in manuscript, "manuscript date mismatch")


def check_json_results() -> None:
    announce("JSON and JSONL result parsing")
    result_dir = ROOT / "results"
    for path in sorted(result_dir.glob("*.json")):
        with path.open(encoding="utf-8") as stream:
            json.load(stream)
    for path in sorted(result_dir.glob("*.jsonl")):
        with path.open(encoding="utf-8") as stream:
            for line_number, line in enumerate(stream, start=1):
                if line.strip():
                    try:
                        json.loads(line)
                    except json.JSONDecodeError as error:
                        raise CheckError(f"{path}:{line_number}: {error}") from error

    family = json.loads((result_dir / "p11_6_7_non_total_trace_certificate.json").read_text())
    require(family["both_non_pseudo_arithmetic"] is True, "P11,6--7 conclusion mismatch")
    require([case["label"] for case in family["cases"]] == ["P_{11,6}", "P_{11,7}"],
            "P11,6--7 labels mismatch")
    for case in family["cases"]:
        cycle = case["cyclic_subfield_certificate"]
        require(cycle["conjugate_discriminant_negative_exact"] is True,
                f"{case['label']} lacks exact negative discriminant")
        require(case["rank_certificate"]["exact_signature_positive_negative_zero"] == [4, 1, 2],
                f"{case['label']} signature mismatch")

    p118 = json.loads((result_dir / "p11_8_non_total_trace_certificate.json").read_text())
    require(p118["non_total_reality_certificate"]["conjugate_discriminant_negative_exact"] is True,
            "P11,8 lacks exact negative discriminant")
    require(p118["rank_certificate"]["exact_signature_positive_negative_zero"] == [4, 1, 2],
            "P11,8 Gram signature mismatch")
    require(p118["whole_field_certificate"]["field_signature"] == [4, 2],
            "P11,8 field signature mismatch")
    require(p118["whole_field_certificate"]["field_discriminant"] == 40960000,
            "P11,8 field discriminant mismatch")
    source_digest = p118["source"]["sha256"]
    require(re.fullmatch(r"[0-9a-f]{64}", source_digest) is not None,
            "invalid source SHA-256 in the P11,8 certificate")
    for name in (
        "manuscript/non_pseudo_arithmetic_4_manifolds.tex",
        "REPRODUCIBILITY.md",
        "PRE_RELEASE_CHECKLIST.md",
    ):
        require(source_digest in (ROOT / name).read_text(),
                f"missing or incorrect source SHA-256 in {name}")

    geometry = json.loads((result_dir / "p11_8_finite_volume_validation.json").read_text())
    require(geometry["conclusion"] == "finite_volume_noncompact_with_exactly_two_cusps",
            "P11,8 geometry conclusion mismatch")
    require((geometry["ordinary_vertex_count"], geometry["ideal_vertex_count"]) == (8, 2),
            "P11,8 vertex counts mismatch")


def check_python_sources() -> None:
    announce("Python byte-compilation")
    with tempfile.TemporaryDirectory(prefix="pseudo-arithmetic-pyc-") as temporary:
        output_dir = Path(temporary)
        for index, path in enumerate(sorted((ROOT / "scripts").glob("*.py"))):
            destination = output_dir / f"{index}.pyc"
            try:
                py_compile.compile(str(path), cfile=str(destination), doraise=True)
            except py_compile.PyCompileError as error:
                raise CheckError(str(error)) from error


def check_semantic_examples() -> None:
    output = run_command(
        "exact rational semantic examples",
        [sys.executable, "scripts/semantic_audit_examples.py"],
    )
    fresh = json.loads(output)
    stored = json.loads((ROOT / "results/two_cycle_semantic_audit.json").read_text())
    require(fresh == stored, "semantic example report differs from the fresh exact checks")
    require(fresh["all_checks_passed"] is True, "semantic example checks did not pass")


def check_manuscript_audit() -> None:
    run_command("statement-by-statement source coverage and examples",
                [sys.executable, "scripts/manuscript_audit.py", "--check"])
    output = run_command("independent exact matrix and field mutation barrage",
                         [sys.executable, "scripts/manuscript_computation_audit.py"])
    fresh = json.loads(output)
    stored = json.loads((ROOT / "results/manuscript_computation_audit.json").read_text())
    require(fresh == stored, "manuscript computation report differs from the fresh exact checks")
    require(fresh["all_checks_passed"] is True, "manuscript computation checks did not pass")
    run_command("full-field positive and negative controls",
                ["gp", "-q", "scripts/manuscript_field_controls.gp"],
                required_output=("RESULT=PASS",))


def strip_lean_comments(source: str) -> str:
    """Remove the comment forms used in these project files for token audit."""
    previous = None
    while previous != source:
        previous = source
        source = re.sub(r"/-.*?-/", "", source, flags=re.DOTALL)
    return re.sub(r"--[^\n]*", "", source)


def check_lean_source_audit() -> None:
    announce("Lean source trust audit")
    declaration = re.compile(r"(?m)^\s*(axiom|opaque)\s+")
    escape = re.compile(r"\b(sorry|admit|native_decide)\b")
    for path in sorted((ROOT / "formal").rglob("*.lean")):
        if ".lake" in path.relative_to(ROOT / "formal").parts:
            continue
        source = strip_lean_comments(path.read_text())
        require(not declaration.search(source), f"forbidden declaration in {path}")
        require(not escape.search(source), f"proof escape in {path}")


def check_lean_axioms() -> None:
    """Inspect the transitive axioms of the main algebra and implication theorems."""
    declarations = (
        "PseudoArithmetic.minpoly_eq_of_square_five",
        "PseudoArithmetic.not_totallyReal_of_cycle_square",
        "PseudoArithmetic.Manuscript.explicit_radical_cycle_relation",
        "PseudoArithmetic.Manuscript.TwoCycleCertificate.of_real_cycles",
        "PseudoArithmetic.Manuscript.not_totallyReal_of_real_cycles",
        "PseudoArithmetic.Manuscript.coxeter_case_main_theorem",
        "PseudoArithmetic.Manuscript.finiteIndex_manifold_corollary",
        "PseudoArithmetic.DescentBridge.simDesc_iff",
        "PseudoArithmetic.SemanticAudit.square_iff_minpoly",
        "PseudoArithmetic.SemanticAudit.real_root_iff",
        "PseudoArithmetic.SemanticAudit.rational_root_family",
        "PseudoArithmetic.SemanticAudit.rational_perturbation_family",
        "PseudoArithmetic.SemanticAudit.negative_parameter_family",
        "PseudoArithmetic.SemanticAudit.concrete_positive_example",
        "PseudoArithmetic.SemanticAudit.concrete_cycle_constructor",
        "PseudoArithmetic.SemanticAudit.square_hypothesis_necessary",
        "PseudoArithmetic.SemanticAudit.relation_hypothesis_necessary",
        "PseudoArithmetic.SemanticAudit.field_membership_necessary",
        "PseudoArithmetic.SemanticAudit.real_embedding_does_not_mean_totallyReal",
        "PseudoArithmetic.SemanticAudit.witness_not_totallyComplex",
        "PseudoArithmetic.SemanticAudit.witness_has_nonreal_embedding",
        "PseudoArithmetic.SemanticAudit.negative_sign_necessary",
        "PseudoArithmetic.SemanticAudit.negative_sign_alone_insufficient",
        "PseudoArithmetic.SemanticAudit.changed_middle_sign_also_provable",
        "PseudoArithmetic.SemanticAudit.middle_sign_mutation_rejected",
    )
    catalog = json.loads((ROOT / "audit/manuscript_statements.json").read_text())
    declarations = tuple(sorted(set(declarations) | set(statement_declarations(catalog))))
    source = "import PseudoArithmetic\n" + "".join(
        f"#print axioms {name}\n" for name in declarations
    )
    with tempfile.TemporaryDirectory(prefix="pseudo-arithmetic-axioms-") as temporary:
        path = Path(temporary) / "Audit.lean"
        path.write_text(source, encoding="utf-8")
        output = run_command(
            "Lean theorem axiom audit", ["lake", "env", "lean", "-j", "1", str(path)],
            cwd=ROOT / "formal",
        )
    allowed = {"propext", "Classical.choice", "Quot.sound"}
    for name in declarations:
        match = re.search(
            rf"'{re.escape(name)}' depends on axioms: \[([^\]]*)\]", output
        )
        if match is None:
            require(f"'{name}' does not depend on any axioms" in output,
                    f"missing axiom report for {name}:\n{output}")
            continue
        actual = {item.strip() for item in match.group(1).split(",") if item.strip()}
        require(actual <= allowed, f"unexpected axioms for {name}: {sorted(actual - allowed)}")


def check_markdown() -> None:
    announce("Markdown macros and local links")
    link_pattern = re.compile(r"\[[^\]]*\]\(([^)]+)\)")
    scheme_pattern = re.compile(r"^[A-Za-z][A-Za-z0-9+.-]*:")
    for path in sorted(ROOT.rglob("*.md")):
        if ".lake" in path.parts:
            continue
        text = path.read_text()
        require("\\operatorname" not in text, f"unsupported Markdown macro in {path}")
        for match in link_pattern.finditer(text):
            target = match.group(1).strip()
            if not target or target.startswith("#") or scheme_pattern.match(target):
                continue
            if target.startswith("<") and target.endswith(">"):
                target = target[1:-1]
            target = target.split("#", 1)[0]
            target = target.split(" ", 1)[0]
            if not target:
                continue
            resolved = (path.parent / target).resolve()
            require(resolved.exists(), f"broken local link {target!r} in {path.relative_to(ROOT)}")


def check_manifest() -> None:
    announce("release manifest hashes")
    manifest = json.loads((ROOT / "release/manifest.json").read_text())
    require(manifest["schema_version"] == 1, "manifest schema mismatch")
    require(manifest["version"] == EXPECTED_VERSION, "manifest version mismatch")
    require(manifest["date"] == EXPECTED_DATE, "manifest date mismatch")
    for artifact in manifest["artifacts"]:
        path = ROOT / artifact["path"]
        require(path.is_file(), f"manifest artifact is missing: {artifact['path']}")
        require(sha256(path) == artifact["sha256"], f"manifest hash mismatch: {artifact['path']}")


def check_tex_log() -> None:
    announce("TeX log diagnostics")
    log_path = ROOT / "manuscript/non_pseudo_arithmetic_4_manifolds.log"
    require(log_path.is_file(), "manuscript log was not generated")
    log = log_path.read_text(errors="replace")
    forbidden = (
        "Overfull \\hbox",
        "There were undefined references",
        "undefined on input line",
        "LaTeX Error",
        "Fatal error",
    )
    for marker in forbidden:
        require(marker not in log, f"TeX log contains {marker!r}")
    pdf = ROOT / "manuscript/non_pseudo_arithmetic_4_manifolds.pdf"
    require(pdf.stat().st_size > 100_000, "compiled manuscript PDF is unexpectedly small")


def main() -> int:
    try:
        check_required_files()
        check_version_consistency()
        check_json_results()
        check_python_sources()
        check_semantic_examples()
        check_manuscript_audit()
        check_lean_source_audit()
        check_markdown()
        check_manifest()

        run_command("stored census-log audit", [sys.executable, "scripts/verify_census_logs.py"],
                    required_output=('"result": "PASS"',))
        run_command("independent P11,8 PARI field check", ["gp", "-q", "scripts/p118_field_independent.gp"],
                    required_output=("number-field signature = [4, 2]", "field discriminant = 40960000"))
        run_command("normalized Clifford regression", ["gp", "-q", "scripts/quadratic_split_support.gp"],
                    required_output=("RESULT: q does not similarity-descend",))
        run_command("stabilization regression", ["gp", "-q", "scripts/stable_obstruction.gp"],
                    required_output=("ranks 5, 7, 9, and 11",))
        run_command("lightweight Clifford controls", ["gp", "-q", "scripts/lightweight_clifford_support.gp"],
                    required_output=("RESULT=PASS",))
        run_command("elementary-2 field self-test", ["gp", "-q", "scripts/elementary2_field_selftest.gp"],
                    required_output=("elementary-2=0", "elementary-2=1"))
        run_command("Makarov positive control", ["gp", "-q", "scripts/makarov_block_check.gp"],
                    required_output=("RESULT: local degree 2 kills the discrepancies",))
        run_command("Lean build", ["lake", "build"], cwd=ROOT / "formal",
                    required_output=("Build completed successfully",))
        check_lean_axioms()
        run_command(
            "manuscript build",
            ["latexmk", "-pdf", "-interaction=nonstopmode", "-halt-on-error",
             "non_pseudo_arithmetic_4_manifolds.tex"],
            cwd=ROOT / "manuscript",
        )
        check_tex_log()
        run_command("git whitespace audit", ["git", "diff", "--check"])
    except CheckError as error:
        print(f"[FAIL] {error}", file=sys.stderr)
        return 1

    print("[PASS] all offline release checks completed successfully")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
