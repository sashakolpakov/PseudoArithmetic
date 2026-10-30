# arXiv submission package

Prepared locally on 30 October 2026 for **Non-Pseudo-Arithmetic Hyperbolic
4-Manifolds**, by Alexander Kolpakov. Nothing has been submitted to arXiv.

- [Submission source](non_pseudo_arithmetic_4_manifolds/main.tex)
- [Reading PDF](build/non_pseudo_arithmetic_4_manifolds.pdf)
- [Submission metadata](SUBMISSION.md)
- [Build record](../results/arxiv_submission_build_20261030.json)
- [Source and sampled layout review](../results/arxiv_submission_review_20261030.json)

Rebuild from the repository root:

```sh
python3 scripts/prepare_arxiv.py
```

Requires PDFLaTeX and the Python package `pypdf` (the recorded build uses
`pypdf==6.13.0`). The reading PDF has 20 pages. Its isolated build has no TeX
warnings or undefined references or citations, and all fonts are embedded.

The upload archive contains the self-contained `main.tex`, with its inline
bibliography. The reading PDF and build products remain outside the upload
archive. The builder writes `dist/PseudoArithmetic-arxiv-2026-10-30.zip` and
its checksum locally; these generated files are excluded from Git.

This separate submission edition preserves the accepted source and PDF in
`manuscript/`. It updates the date to 30 October 2026, adds the existing
tool-use acknowledgment from `ACKNOWLEDGMENTS.md`, cites the accompanying
repository at commit `736246d60d56a9be955fd8a8f8060fa5263c3e6b`, and uses
ragged-right bibliography formatting. The mathematical proof body is unchanged;
the reproducibility introduction gains the repository citation.

Preparation checks concern source packaging and TeX compilation. The existing
scientific and Lean checks were not rerun.

The preparation follows arXiv's [TeX submission guidance](https://info.arxiv.org/help/submit_tex.html)
and [submission overview](https://info.arxiv.org/help/submit/index.html), consulted
on 30 October 2026. Review the PDF produced by arXiv before completing submission.
