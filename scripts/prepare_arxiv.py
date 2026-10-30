#!/usr/bin/env python3
"""Build the isolated arXiv source package and its matching reading PDF.

Requires pdflatex and pypdf. Runs typesetting only; never runs Lean or CAS jobs.
Generated files are replaced on a subsequent successful build.
"""

from __future__ import annotations

import hashlib
import io
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import zipfile

from pypdf import PdfReader


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "arxiv/non_pseudo_arithmetic_4_manifolds/main.tex"
PDF = ROOT / "arxiv/build/non_pseudo_arithmetic_4_manifolds.pdf"
ARCHIVE = ROOT / "dist/PseudoArithmetic-arxiv-2026-10-30.zip"
REPORT = ROOT / "results/arxiv_submission_build_20261030.json"
EPOCH = "1793318400"  # 30 October 2026, 00:00 UTC


def sha(payload: bytes) -> str:
    return hashlib.sha256(payload).hexdigest()


def identity(path: Path, payload: bytes) -> dict:
    return {"path": str(path.relative_to(ROOT)), "bytes": len(payload),
            "sha256": sha(payload)}


def save(path: Path, payload: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    # Replace only after the full build succeeds, without partial file writes.
    with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as stream:
        temporary = Path(stream.name)
        try:
            stream.write(payload)
            stream.close()
            temporary.replace(path)
        finally:
            temporary.unlink(missing_ok=True)


def main() -> None:
    engine = shutil.which("pdflatex")
    if engine is None:
        raise SystemExit("pdflatex is required")
    payload = SOURCE.read_bytes()
    if sorted(p.name for p in SOURCE.parent.iterdir()) != ["main.tex"]:
        raise ValueError("The upload folder must contain only main.tex")
    if not 0 < len(payload) <= 256 * 1024:
        raise ValueError("Unexpected source size")

    buffer = io.BytesIO()
    info = zipfile.ZipInfo("main.tex", date_time=(2026, 10, 30, 0, 0, 0))
    info.create_system = 3
    info.external_attr = 0o100644 << 16
    info.compress_type = zipfile.ZIP_DEFLATED
    with zipfile.ZipFile(buffer, "w") as archive:
        archive.writestr(info, payload)
    archive_payload = buffer.getvalue()

    report = {"schema_version": 1, "edition_date": "2026-10-30",
              "status": "PASS_ISOLATED_TEX_BUILD_AND_PACKAGING_ONLY",
              "builder": identity(Path(__file__), Path(__file__).read_bytes()),
              "source": identity(SOURCE, payload), "passes": [],
              "mathematical_checks_rerun": False, "lean_rerun": False,
              "arxiv_submission_performed": False,
              "source_date_epoch": int(EPOCH)}
    with tempfile.TemporaryDirectory(prefix="pseudo-arxiv-") as temporary:
        folder = Path(temporary).resolve()
        # Compile the actual ZIP member, rather than a second source copy.
        with zipfile.ZipFile(io.BytesIO(archive_payload)) as archive:
            if archive.namelist() != ["main.tex"] or archive.read("main.tex") != payload:
                raise ValueError("Archive round-trip failed")
            (folder / "main.tex").write_bytes(archive.read("main.tex"))

        environment = dict(os.environ)
        for name in ("TEXINPUTS", "BIBINPUTS", "BSTINPUTS", "TEXMFOUTPUT"):
            environment.pop(name, None)
        environment.update(SOURCE_DATE_EPOCH=EPOCH, FORCE_SOURCE_DATE="1",
                           openin_any="p", openout_any="p")
        command = [engine, "-no-shell-escape", "-interaction=nonstopmode",
                   "-halt-on-error", "-file-line-error", "-recorder", "main.tex"]
        report["engine_version"] = subprocess.check_output(
            [engine, "--version"], text=True, timeout=5).splitlines()[0]
        report["command"] = ["pdflatex", *command[1:]]
        for iteration in range(3):
            result = subprocess.run(command, cwd=folder, env=environment,
                                    stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                    timeout=30)
            report["passes"].append({"pass": iteration + 1, "exit_code": result.returncode})
            if result.returncode:
                raise RuntimeError(result.stdout[-7000:].decode(errors="replace"))
            log = (folder / "main.log").read_text(errors="replace")
            rerun = bool(re.search(r"Rerun to get|Label\(s\) may have changed|rerunfilecheck Warning", log))
            if iteration >= 1 and not rerun:
                break
        if rerun:
            raise RuntimeError("Cross-references have not stabilized after three passes")
        report["warnings"] = [line.strip() for line in log.splitlines()
                              if re.search(r"Warning|Overfull|Underfull", line)]
        if report["warnings"]:
            raise RuntimeError("Resolve TeX diagnostics before packaging: " + repr(report["warnings"]))
        report["undefined_references_or_citations"] = bool(re.search(
            r"(?:Reference|Citation).*undefined|undefined references|undefined citations", log))
        if report["undefined_references_or_citations"]:
            raise RuntimeError("Undefined references or citations")

        inputs = set()
        for line in (folder / "main.fls").read_text().splitlines():
            if line.startswith("INPUT "):
                item = Path(line[6:])
                inputs.add((item if item.is_absolute() else folder / item).resolve())
        unexpected = sorted(str(p.relative_to(ROOT)) for p in inputs if p.is_relative_to(ROOT))
        report["repository_inputs_read_by_tex"] = unexpected
        if unexpected:
            raise RuntimeError("TeX read additional repository inputs")
        report["local_source_inputs"] = sorted(str(p.relative_to(folder)) for p in inputs
                                                if p.is_relative_to(folder) and p.suffix == ".tex")
        if report["local_source_inputs"] != ["main.tex"]:
            raise RuntimeError("Unexpected local TeX source inputs")
        pdf_payload = (folder / "main.pdf").read_bytes()
        reader = PdfReader(io.BytesIO(pdf_payload))
        report["pages"] = len(reader.pages)
        report["pdf_metadata"] = dict(reader.metadata or {})
        fonts = {}
        for page in reader.pages:
            for reference in page["/Resources"].get("/Font", {}).values():
                font = reference.get_object()
                descriptor = font.get("/FontDescriptor")
                descriptor = descriptor.get_object() if descriptor else {}
                fonts[str(font.get("/BaseFont"))] = {
                    "subtype": str(font.get("/Subtype")),
                    "embedded": any(key in descriptor for key in ("/FontFile", "/FontFile2", "/FontFile3"))}
        report["fonts"] = fonts
        if any(f["subtype"] == "/Type3" or not f["embedded"] for f in fonts.values()):
            raise RuntimeError("PDF contains a bitmap or unembedded font")
    if SOURCE.read_bytes() != payload:
        raise RuntimeError("Submission source changed during compilation")
    report.update(pdf=identity(PDF, pdf_payload), archive=identity(ARCHIVE, archive_payload),
                  archive_members=["main.tex"], temporary_auxiliaries_removed=True)
    checksum = f"{sha(archive_payload)}  {ARCHIVE.name}\n".encode()
    save(PDF, pdf_payload)
    save(ARCHIVE, archive_payload)
    save(ARCHIVE.with_suffix(ARCHIVE.suffix + ".sha256"), checksum)
    save(REPORT, (json.dumps(report, indent=2) + "\n").encode())
    print(f"PDF: {PDF.relative_to(ROOT)} ({report['pages']} pages)")
    print(f"Upload: {ARCHIVE.relative_to(ROOT)} (main.tex only)")
    print(f"Build record: {REPORT.relative_to(ROOT)}")
    print("No TeX warnings; all fonts embedded; no additional repository inputs.")


if __name__ == "__main__":
    main()
