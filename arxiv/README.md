# Manuscript and arXiv package

This folder contains the single current manuscript, incorporating the
editorial revisions of 4 November 2026.

- [TeX source](main.tex)
- [Compiled PDF](main.pdf)
- [Bibliography](references.bib)
- [Prepared bibliography](main.bbl)
- [Submission metadata](SUBMISSION.md)
- [Current build record](../results/arxiv_build.json)

From the repository root, rebuild the PDF and upload package with:

```sh
python3 -B scripts/prepare_arxiv.py
```

This replaces `arxiv/main.pdf`, `arxiv/main.bbl`,
`dist/PseudoArithmetic-arxiv.zip`, its SHA-256 checksum, and the build record.
It also updates the page count in `SUBMISSION.md`. The ZIP contains exactly
`main.tex`, `references.bib`, and `main.bbl`.

The builder requires `latexmk`, PDFLaTeX, BibTeX, and Python's `pypdf` package.
It compiles in a clean temporary directory, checks for TeX warnings and
unresolved references, and verifies that all PDF fonts are embedded. The
paper date remains 30 October 2026. Scientific checks and Lean verification
are run separately with `python3 scripts/release_check.py`.

For direct editing, open `main.tex` and run `latexmk -pdf main.tex`, or use
PDFLaTeX → BibTeX → PDFLaTeX → PDFLaTeX in a TeX editor. `main.pdf` sits beside
the source so there is one place to edit and read the paper.

Nothing has been submitted to arXiv. Follow [arXiv's TeX submission guidance](https://info.arxiv.org/help/submit_tex.html)
and review the PDF produced by arXiv before completing submission.
