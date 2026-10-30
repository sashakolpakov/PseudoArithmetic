#!/usr/bin/env python3
"""Replace both reading PDFs and the arXiv ZIP using normal BibTeX builds.

Requires latexmk, pdflatex, bibtex and pypdf. Builds run in clean temporary
folders with no prebuilt bibliography. No Lean or scientific jobs are run.
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
MANUSCRIPT = ROOT / "manuscript/non_pseudo_arithmetic_4_manifolds.tex"
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
    with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as stream:
        temporary = Path(stream.name)
        try:
            stream.write(payload)
            stream.close()
            temporary.chmod(0o644)
            temporary.replace(path)
        finally:
            temporary.unlink(missing_ok=True)


def describe_pdf(payload: bytes) -> dict:
    reader = PdfReader(io.BytesIO(payload))
    fonts = {}
    for page in reader.pages:
        for reference in page["/Resources"].get("/Font", {}).values():
            font = reference.get_object()
            descriptor = font.get("/FontDescriptor")
            descriptor = descriptor.get_object() if descriptor else {}
            fonts[str(font.get("/BaseFont"))] = {
                "subtype": str(font.get("/Subtype")),
                "embedded": any(k in descriptor for k in ("/FontFile", "/FontFile2", "/FontFile3"))}
    if any(f["subtype"] == "/Type3" or not f["embedded"] for f in fonts.values()):
        raise RuntimeError("PDF contains a bitmap or unembedded font")
    return {"pages": len(reader.pages), "pdf_metadata": dict(reader.metadata or {}), "fonts": fonts}


def build(source: Path, pdf: Path) -> tuple[dict, bytes, bytes]:
    bibliography = source.with_name("references.bib")
    inputs = {source.name: source.read_bytes(), "references.bib": bibliography.read_bytes()}
    report = {"source": identity(source, inputs[source.name]),
              "bibliography": identity(bibliography, inputs["references.bib"])}
    with tempfile.TemporaryDirectory(prefix="pseudo-bibtex-") as temporary:
        folder = Path(temporary).resolve()
        for name, payload in inputs.items():
            (folder / name).write_bytes(payload)
        environment = dict(os.environ)
        for name in ("TEXINPUTS", "BIBINPUTS", "BSTINPUTS", "TEXMFOUTPUT"):
            environment.pop(name, None)
        environment.update(SOURCE_DATE_EPOCH=EPOCH, FORCE_SOURCE_DATE="1",
                           openin_any="p", openout_any="p")
        command = ["latexmk", "-norc", "-pdf", "-no-shell-escape", "-interaction=nonstopmode",
                   "-halt-on-error", "-file-line-error", "-recorder", source.name]
        result = subprocess.run(command, cwd=folder, env=environment,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=59)
        if result.returncode:
            raise RuntimeError(result.stdout[-9000:].decode(errors="replace"))
        stem = source.stem
        log = (folder / f"{stem}.log").read_text(errors="replace")
        blg = (folder / f"{stem}.blg").read_text(errors="replace")
        if "Database file #1: references.bib" not in blg or re.search(r"Warning|error message", blg):
            raise RuntimeError("BibTeX failed or reported diagnostics: " + blg)
        report.update(command=command, exit_code=result.returncode,
                      bibtex_ran_from_clean_inputs=True, bibtex_log=blg,
                      warnings=[s.strip() for s in log.splitlines()
                                if re.search(r"Warning|Overfull|Underfull", s)],
                      undefined_references_or_citations=bool(re.search(
                          r"(?:Reference|Citation).*undefined|undefined references|undefined citations", log)))
        if report["warnings"] or report["undefined_references_or_citations"]:
            raise RuntimeError("Resolve TeX diagnostics before packaging: " + repr(report["warnings"]))
        tex_inputs = set()
        for line in (folder / f"{stem}.fls").read_text().splitlines():
            if line.startswith("INPUT "):
                item = Path(line[6:])
                tex_inputs.add((item if item.is_absolute() else folder / item).resolve())
        report["repository_inputs_read_by_tex"] = sorted(str(p.relative_to(ROOT)) for p in tex_inputs
                                                         if p.is_relative_to(ROOT))
        if report["repository_inputs_read_by_tex"]:
            raise RuntimeError("TeX read additional repository inputs")
        report["local_source_inputs"] = sorted(str(p.relative_to(folder)) for p in tex_inputs
                                                if p.is_relative_to(folder) and p.suffix in {".tex", ".bbl"})
        pdf_payload = (folder / f"{stem}.pdf").read_bytes()
        bbl_payload = (folder / f"{stem}.bbl").read_bytes()
        report.update(describe_pdf(pdf_payload))
    for name, payload in inputs.items():
        if source.with_name(name).read_bytes() != payload:
            raise RuntimeError("An input changed during compilation")
    report.update(pdf=identity(pdf, pdf_payload),
                  bbl=identity(source.with_suffix(".bbl"), bbl_payload),
                  temporary_auxiliaries_removed=True)
    return report, pdf_payload, bbl_payload


def main() -> None:
    for executable in ("latexmk", "pdflatex", "bibtex"):
        if shutil.which(executable) is None:
            raise SystemExit(f"{executable} is required")
    if SOURCE.with_name("references.bib").read_bytes() != MANUSCRIPT.with_name("references.bib").read_bytes():
        raise ValueError("The two bibliography databases differ")
    allowed = {"main.tex", "references.bib", "main.bbl"}
    if any(p.name not in allowed for p in SOURCE.parent.iterdir()):
        raise ValueError("Remove temporary build files from the upload folder")

    # Both builds start with only .tex/.bib: latexmk must actually run BibTeX.
    manuscript_report, manuscript_pdf, manuscript_bbl = build(MANUSCRIPT, MANUSCRIPT.with_suffix(".pdf"))
    report, pdf_payload, bbl_payload = build(SOURCE, PDF)
    report.update(schema_version=2, edition_date="2026-10-30",
                  status="PASS_ISOLATED_LATEXMK_BIBTEX_BUILDS_AND_PACKAGING_ONLY",
                  builder=identity(Path(__file__), Path(__file__).read_bytes()),
                  mathematical_checks_rerun=False, lean_rerun=False,
                  arxiv_submission_performed=False, source_date_epoch=int(EPOCH),
                  manuscript_build=manuscript_report)

    members = {"main.tex": SOURCE.read_bytes(), "references.bib": SOURCE.with_name("references.bib").read_bytes(),
               "main.bbl": bbl_payload}
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, "w") as archive:
        for name, payload in sorted(members.items()):
            info = zipfile.ZipInfo(name, date_time=(2026, 10, 30, 0, 0, 0))
            info.create_system = 3
            info.external_attr = 0o100644 << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            archive.writestr(info, payload)
    archive_payload = buffer.getvalue()
    with zipfile.ZipFile(io.BytesIO(archive_payload)) as archive:
        if archive.testzip() or set(archive.namelist()) != set(members):
            raise ValueError("Archive integrity check failed")
        if any(archive.read(name) != payload for name, payload in members.items()):
            raise ValueError("Archive round-trip failed")
    report.update(archive=identity(ARCHIVE, archive_payload), archive_members=sorted(members))
    save(MANUSCRIPT.with_suffix(".pdf"), manuscript_pdf)
    save(MANUSCRIPT.with_suffix(".bbl"), manuscript_bbl)
    save(PDF, pdf_payload)
    save(SOURCE.with_suffix(".bbl"), bbl_payload)
    save(ARCHIVE, archive_payload)
    save(ARCHIVE.with_suffix(ARCHIVE.suffix + ".sha256"), f"{sha(archive_payload)}  {ARCHIVE.name}\n".encode())
    save(REPORT, (json.dumps(report, indent=2) + "\n").encode())
    print(f"Replaced manuscript PDF ({manuscript_report['pages']} pages): {MANUSCRIPT.with_suffix('.pdf').relative_to(ROOT)}")
    print(f"Replaced submission PDF ({report['pages']} pages): {PDF.relative_to(ROOT)}")
    print(f"Upload: {ARCHIVE.relative_to(ROOT)} ({', '.join(sorted(members))})")
    print("Both clean latexmk builds ran BibTeX successfully, with no final TeX warnings.")


if __name__ == "__main__":
    main()
