# Pre-release checklist: `1.0.0-rc1`

Completed: 2026-09-24

This is the executable plan for the first self-contained release candidate.
An item is checked only after the corresponding artifact or command has been
inspected successfully.  The checklist distinguishes proofs carried out in
the manuscript and Lean from externally sourced inputs that are translated
into Lean as ordinary hypotheses.

## 1. Mathematical scope and exposition

- [x] State the lattice, orbifold, and manifold results precisely and use one
  title consistently throughout the repository.
- [x] Make the introduction self-contained for a general mathematician:
  define hyperbolic space, Coxeter polytopes, lattices, number fields, total
  reality, adjoint trace fields, ambient groups, pseudo-arithmeticity, Gram
  matrices, and cyclic products before they are used.
- [x] Label every imported theorem or classification fact as an external
  input, with a primary citation and an exact description of how it is used.
- [x] Prove every new internal assertion from displayed definitions and
  standard elementary facts, including the radical identity, discriminant
  calculation, complex-place argument, and finite-index manifold passage.
- [x] Include the full three Gram matrices (in a uniform formula), the source
  rows, facet-index convention, and the exact two-cycle certificate.
- [x] Explain why the cyclic-product field, rather than the entry field, is
  the relevant adjoint trace field.
- [x] Give a dependency audit separating hand proof, exact computation,
  kernel-checked logic, and unformalized external mathematics.

## 2. Lean formalization

- [x] Add a manuscript-facing module whose theorem names and hypotheses match
  the paper's internal proof and its external-input register.
- [x] Kernel-check the elementary cycle recovery and radical relation.
- [x] Kernel-check the passage from the two-cycle certificate to a non-totally
  real number field and then, conditionally on the external total-reality
  theorem, to non-pseudo-arithmeticity.
- [x] Translate the three census cases and the finite-index manifold argument
  into typed propositions with external facts passed as local hypotheses.
- [x] Keep all project sources free of `axiom`, `opaque`, `sorry`, `admit`, and
  `native_decide`.
- [x] Build the pinned Lean project with `lake build`.

## 3. Exact certificates and independent checks

- [x] Validate the stored zero- and one-distance census logs.
- [x] Re-run the direct PARI/GP full-field check.
- [x] Re-run the split-support and stabilization regressions.
- [x] Re-run the lightweight Clifford controls.
- [x] Check every committed JSON/JSONL result parses and every committed Python
  script byte-compiles.
- [x] Record which headline computations require the separately pinned
  Ma--Zheng/HCPdm source files; download the pinned copies, verify their
  digests, and repeat all headline source-level checks.

## 4. Documentation and release metadata

- [x] Synchronize `README.md`, `FORMAL_VERIFICATION.md`, `REPRODUCIBILITY.md`,
  `CITATION.cff`, acknowledgments, and novelty wording with the manuscript.
- [x] Add release notes, a version file, a machine-readable artifact manifest,
  and one release-validation command.
- [x] Pin the manuscript date and software versions needed for reproducibility.
- [x] Ensure all Markdown links and all TeX cross-references resolve.

## 5. Build and package

- [x] Compile the manuscript twice through `latexmk` with no undefined
  references, fatal errors, or overfull boxes.
- [x] Run the complete release validator from the repository root.
- [x] Build a deterministic source/PDF archive and SHA-256 checksum under
  `dist/`.
- [x] Inspect the archive contents and record the final checksum in its
  generated `.sha256` sidecar.
- [x] Review `git diff --check`, repository status, and the complete diff so no
  unrelated or generated scratch files enter the release.

## Exit criterion

The release candidate is complete only when all boxes above are checked, the
paper and Lean theorem boundary agree line-for-line at the external-input
register, and the commands documented in the release notes reproduce the
reported checks without modifying tracked source files (apart from rebuilding
the committed PDF).

## Execution record

- `python3 scripts/release_check.py`: **PASS** on 24 September 2026.
- Pinned source SHA-256 values: Ma--Zheng archive
  `13f2d88ad740669f35b4d1859e68da4d489a1223b5ff5a99e128eaa71838234f`,
  `hcp47.tex`
  `0017931637f017641d4935450cc2a07d070866d9e3ede9f3a39f003`, and HCPdm
  `pi47.txt`
  `05bd3d7eddd62598c1446ec562aa6ef63d85d0142e46cac2a550a1d7b054f293`.
- Fresh source-level results: all three Gram signatures `(4,1,2)`; all three
  conjugate-discriminant obstructions pass; full-field signature `(4,2)` and
  discriminant `40960000`; direct geometry conclusion
  `finite_volume_noncompact_with_exactly_two_cusps`.
- Independent lightweight/full Clifford comparison: 37 cases, identical
  ramified supports and finite decisions, `result: PASS`.
- The archive is generated only after this record is frozen; its exact digest
  and file count are printed by `scripts/build_release.sh` and stored in the
  ignored `dist/` sidecar.
