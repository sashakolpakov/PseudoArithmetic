# Reproducibility

All symbolic jobs below are intended to run serially.  The three case workers
were measured below 100 MB resident memory on the reference machine, and none
of the commands needs to retain a previous symbolic process.

## Reference environment

- Python 3.14.6
- SymPy 1.14.0
- NumPy 2.4.4
- PARI/GP 2.17.4
- Lean and mathlib `v4.32.0`
- TeX Live 2026 and `latexmk` 4.87

The proofs use exact arithmetic.  These versions record the tested
environment; they are not all expected to be mathematically essential.

## Pinned source data

Choose a temporary source directory:

```sh
export PA_REPRO_DIR=/private/tmp/pseudo-arithmetic-repro
mkdir -p "$PA_REPRO_DIR/paperarXiv"
mkdir -p "$PA_REPRO_DIR/HCPdm-main/polytopeDATA"
```

Download Ma–Zheng's arXiv v3 source and extract the one TeX file read by the
certifiers:

```sh
curl -L --fail \
  -o "$PA_REPRO_DIR/ma-zheng-2401.13698.tar.gz" \
  https://arxiv.org/e-print/2401.13698v3
tar -xzf "$PA_REPRO_DIR/ma-zheng-2401.13698.tar.gz" \
  -C "$PA_REPRO_DIR" paperarXiv/hcp47.tex
```

Expected SHA-256 values are

```text
13f2d88ad740669f35b4d1859e68da4d489a1223b5ff5a99e128eaa71838234f  archive
0017931637f017641d4935450cc2a07d070866d9c749443d9e3ede9f3a39f003  hcp47.tex
```

The independent incidence check uses HCPdm at commit
`159738898cbedbd7093145287315322c1d75b3bd`:

```sh
curl -L --fail \
  -o "$PA_REPRO_DIR/HCPdm-main/polytopeDATA/pi47.txt" \
  https://raw.githubusercontent.com/GeoTopChristy/HCPdm/159738898cbedbd7093145287315322c1d75b3bd/polytopeDATA/pi47.txt
```

Its expected SHA-256 is
`05bd3d7eddd62598c1446ec562aa6ef63d85d0142e46cac2a550a1d7b054f293`.
Each Python certifier also checks its source digest before doing algebra.

## Headline arithmetic certificates

From the repository root, run these commands one at a time:

```sh
python3 scripts/p11_6_7_non_total_trace.py \
  "$PA_REPRO_DIR/paperarXiv/hcp47.tex" \
  --output "$PA_REPRO_DIR/p11_6_7.json"

python3 scripts/p11_8_non_total_trace.py \
  "$PA_REPRO_DIR/paperarXiv/hcp47.tex" \
  --output "$PA_REPRO_DIR/p11_8.json"

python3 scripts/p118_trace_field.py \
  "$PA_REPRO_DIR/paperarXiv/hcp47.tex" \
  --output "$PA_REPRO_DIR/p118_second_route.json"

gp -q scripts/p118_field_independent.gp

python3 scripts/p11_8_finite_volume.py \
  --tex "$PA_REPRO_DIR/paperarXiv/hcp47.tex" \
  --incidence "$PA_REPRO_DIR/HCPdm-main/polytopeDATA/pi47.txt" \
  --output "$PA_REPRO_DIR/p11_8_geometry.json"
```

The expected conclusions are:

- `P_{11,6}`, `P_{11,7}`, and `P_{11,8}` have Gram rank 5 and inertia
  \((4,1,2)\);
- their cyclic-product fields contain \(s=\sqrt5\) and \(u\) satisfying

  $$
  (s-1)u^2+2(s-3)u+s-7=0;
  $$

- the conjugate discriminant is \(8(1-\sqrt5)<0\);
- the full \(P_{11,8}\) field has signature \((4,2)\) and discriminant
  \(40960000\); and
- the direct geometry check finds ten vertices, two cusps, and finite volume.

The durable certificates in `results/` are reference outputs.  Some contain
wall-clock and peak-memory metadata, so regenerated JSON files need not have
identical bytes even when all mathematical fields agree.

## Independent CoxIter record

The repository includes the pinned input, captured output, and build
provenance:

- `results/p11_8_finite_volume.coxiter`
- `results/p11_8_coxiter_validation.output`
- `results/p11_8_coxiter_provenance.json`

The recorded CoxIter 1.3 binary was built from commit
`b800be48d8240fbabd2d1c9542e61054584ad7fe` with one compile job.  Its output
reports finite covolume, two ideal vertices, f-vector
\((10,21,18,7,1)\), and volume \(19\pi^2/864\).

## Regression checks

The normalized-Clifford examples and the saved census logs can be checked
serially with:

```sh
gp -q scripts/quadratic_split_support.gp
gp -q scripts/stable_obstruction.gp
python3 scripts/verify_census_logs.py
```

The lightweight negative test is a separate implementation: it computes
`C^0(q)` directly from the supplied unnormalized form and never loads
`quadratic_split_support.gp`.  Its exact positive and negative controls are:

```sh
gp -q scripts/lightweight_clifford_support.gp
```

The final line is `RESULT=PASS`.  The output includes the inert-prime
witnesses over 2 and 3 and passes regressions for an incomplete fibre, a
nonempty complete fibre, similarity invariance, and ranks 5, 7, 9, and 11.

Compare it with every earlier nontrivial one-distance finite-criterion
calculation, using one fresh Python worker and one fresh GP process per case:

```sh
python3 scripts/lightweight_clifford_crosscheck.py \
  "$PA_REPRO_DIR/paperarXiv/hcp47.tex" --all \
  --output "$PA_REPRO_DIR/lightweight_clifford_crosscheck.jsonl"
```

The summary reports 37 cases, identical ramified supports and finite
decisions, no determinant normalization, and `result: PASS`.  The reference
output is `results/lightweight_clifford_crosscheck.jsonl`, with SHA-256
`1378b5ffad6ddb76edf607dee50053a5dc97d1373ea712c81bb2c63adebb9be4`.

This executable comparison is the `K/Q` specialization used by the saved
census calculations.  The theorem applies to `K/K^H`; a general search must
repeat the decomposition-group and complete-orbit check for every eligible
fixed field rather than treating the `K/Q` answer as conclusive.

## Lean

The project is pinned by `formal/lean-toolchain`, `formal/lakefile.toml`, and
`formal/lake-manifest.json`.  On a networked first run:

```sh
cd formal
lake exe cache get
lake build
```

See [FORMAL_VERIFICATION.md](FORMAL_VERIFICATION.md) for the exact distinction
between kernel-checked deductions and explicit classical hypotheses.

## Manuscript

```sh
cd manuscript
latexmk -pdf -interaction=nonstopmode -halt-on-error \
  non_pseudo_arithmetic_4_manifolds.tex
```

The expected output is the seven-page
`manuscript/non_pseudo_arithmetic_4_manifolds.pdf`.  The build has no undefined
references, fatal errors, or overfull boxes; the only layout notices are
harmless underfull bibliography lines.
