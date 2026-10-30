# arXiv submission package

Prepared locally on 30 October 2026 for **Non-Pseudo-Arithmetic Hyperbolic
4-Manifolds**, by Alexander Kolpakov. Nothing has been submitted to arXiv.

- [Submission source](non_pseudo_arithmetic_4_manifolds/main.tex)
- [Bibliography database](non_pseudo_arithmetic_4_manifolds/references.bib)
- [Reading PDF](build/non_pseudo_arithmetic_4_manifolds.pdf)
- [Submission metadata](SUBMISSION.md)
- [Build record](../results/arxiv_submission_build_20261030.json)
- [Source and sampled layout review](../results/arxiv_submission_review_20261030.json)

To compile the submission, open its source folder and run:

```sh
latexmk -pdf main.tex
```

In a TeX editor, select PDFLaTeX and the standard sequence
**PDFLaTeX → BibTeX → PDFLaTeX → PDFLaTeX**. The source uses the standard
`plain` BibTeX style and `references.bib`. A matching `main.bbl` is supplied
so PDFLaTeX can also use the prepared bibliography immediately.

To replace both reading PDFs and regenerate the upload ZIP from the repository
root, run:

```sh
python3 -B scripts/prepare_arxiv.py
```

The builder requires `latexmk`, PDFLaTeX, BibTeX, and the Python package
`pypdf` (the recorded build uses `pypdf==6.13.0`). It starts each build with
only the `.tex` and `.bib` inputs, runs BibTeX, and replaces the PDFs and
matching `.bbl` files in place. Both reading PDFs have 20 pages; their isolated
builds have no final TeX warnings or unresolved citations or references, and
all fonts are embedded.

The upload ZIP contains `main.tex`, `references.bib`, and the current generated
`main.bbl`. The builder writes `dist/PseudoArithmetic-arxiv-2026-10-30.zip` and
its checksum locally; these generated packages are excluded from Git. The
`.bbl` is intentional submission material. Other temporary build files are
removed.

The mathematical proof body in `manuscript/` is unchanged. Its date remains
24 September 2026, and its PDF has been rebuilt and replaced. The submission
edition is dated 30 October 2026, includes the existing tool-use acknowledgment
from `ACKNOWLEDGMENTS.md`, and cites the accompanying repository at commit
`736246d60d56a9be955fd8a8f8060fa5263c3e6b`. Each path holds its current source
or PDF; no historical copies are added.

Preparation checks concern source packaging and TeX compilation. The existing
scientific and Lean checks were not rerun.

The preparation follows arXiv's [TeX submission guidance](https://info.arxiv.org/help/submit_tex.html)
and [submission overview](https://info.arxiv.org/help/submit/index.html), consulted
on 30 October 2026. Review the PDF produced by arXiv before completing submission.
