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
        source = strip_lean_comments(path.read_text())
        require(not declaration.search(source), f"forbidden declaration in {path}")
        require(not escape.search(source), f"proof escape in {path}")


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
