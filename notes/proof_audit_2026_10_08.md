# Proof, formalization, and language audit

Date: 8 October 2026.

This records the initial proof/language pass. The subsequent
[manuscript-wide semantic audit](manuscript_semantic_audit.md) extends it to
135 statement entries with positive and negative examples, actual Lean
matrix/cycle-field constructions, and additional exact mutation checks.
The [external translation review](external_translation_audit.md) subsequently
separates translation fidelity from proof provenance, strengthens the actual
matrix/field and cover contracts, and accounts for all 21 original partial
entries. The 9 October [subdiagram and face audit](subdiagram_face_semantic_audit.md)
completes the two local computations in Lean. The current register references
290 checked Lean declarations.
The current manuscript is 20 pages; the 19-page build and eight-declaration
audit below describe the earlier checkpoint.

The audit found no change needed to the main conclusion: the two cyclic
products give a number subfield with a nonreal embedding, which obstructs
pseudo-arithmeticity under the cited field-identification and total-reality
results. The changes below repair explanations, connect previously separate
formal lemmas, and state the external assumptions more precisely.

## Mathematical corrections

- The conjugate-quadratic proof called a nonmonic polynomial a minimal
  polynomial. The revised proof uses the extension-of-embeddings theorem
  directly, after establishing algebraicity; irreducibility of that relative
  quadratic is unnecessary.
- The rescaling explanation now uses reflection coefficients
  $a_{ij}=2\langle e_i,e_j\rangle/\langle e_i,e_i\rangle$.
  Their factors cancel around cycles. Raw bilinear Gram entries have a
  different transformation law.
- The passage from $G$ to $2G$ changes the displayed cycle values by rational
  powers of two and leaves the generated field unchanged.
- “Real multiquadratic” is explained at every real place, with totally
  positive generators. The cited total-reality consequence is located
  immediately before Question 1.10 of
  [Emery–Mila, Section 1.4](https://arxiv.org/html/1810.12837#S1.SS4).
- The main proof now explicitly establishes that the entry field, and hence
  the cyclic-product field, is a number field. The finite-index argument
  explains finite generation of the orientation subgroup.
- The supplementary descent note now explains the real places that become
  complex in its general number-field statement. The three-dimensional
  note supplies the normal-closure argument behind its field-degree bound.

## Formalization changes

- `sqrt5_polynomial_irreducible` and `minpoly_eq_of_square_five` prove the
  minimal-polynomial input from $s^2=5$.
- `not_totallyReal_of_cycle_square` states the obstruction using only the
  square identity and the quadratic relation.
- `TwoCycleCertificate.of_real_cycles` recovers $s,u$ in the abstract number
  field from the two cycle elements at a real embedding. It transports the
  proved radical identity by injectivity and derives the minimal polynomial.
  `not_totallyReal_of_real_cycles` completes this implication within Lean.
- `ManifoldExternalInputs` now requires base noncompactness explicitly, and
  `quotient_geometry` uses both that fact and finite volume. The conclusion's
  predicate names the hyperbolic dimension four.
- Documentation now states that the geometric predicates and case labels
  are abstract. There are no concrete Lean constructions of the census
  polytopes, their reflection groups, or their adjoint trace fields.
- The release validator excludes `.lake/` dependencies from the project
  source scan and checks transitive axioms of eight principal declarations.
  Only `propext`, `Classical.choice`, and `Quot.sound` are allowed.

## Source and language checks

The three vectors, radicals, cusp counts, and volumes agree with the
[Ma–Zheng source rows](https://arxiv.org/html/2401.13698v3).
Fresh downloads of the source archive, `hcp47.tex`, and HCPdm incidence file
match all three hashes in [REPRODUCIBILITY.md](../REPRODUCIBILITY.md).
The manuscript and release checklist contained truncated copies of the TeX
source hash; both now contain the full 64-digit value. The validator checks
these copies against the stored source certificate.

The abstract and section titles are shorter. Claims about formal verification
now distinguish proved algebra from conditional geometry. The external-input
register no longer describes the embedding-extension proof as unproved, the
dependency diagram refers to the image of $u$ under an embedding, and the
missing backslashes in the principal-minor display are restored. The
full-field certificate is described as additional information rather than
as logically weaker than the short obstruction.

## Validation

- Lean build: passed with the pinned Lean/mathlib `v4.32.0`.
- Project source scan and transitive axiom audit: passed.
- Fresh source-dependent arithmetic checks for all three cases: passed;
  the Gram inertias remain $(4,1,2)$.
- Independent second primitive-element route for $P_{11,8}$: passed.
- The full-field signature remains $(4,2)$ and its discriminant is
  $40960000$.
- Direct finite-volume rerun: passed, with eight ordinary vertices and two
  ideal vertices. All four regenerated certificates match the stored
  mathematical fields, excluding execution metadata and source paths.
- `python3 scripts/release_check.py`: passed, including the stored census-log
  audit and all PARI/GP regressions.
- Manuscript: rebuilt as a 19-page PDF, with no overfull boxes or unresolved
  references. The revised proof, formalization, and dependency pages were
  also inspected visually.

The arithmetic scripts were run serially in a temporary environment using
Python 3.14.6, SymPy 1.14.0, and NumPy 2.4.4. The recorded CoxIter output
was reviewed; CoxIter itself was not rebuilt or rerun. This audit did not
repeat the full census search or extend the dated literature-priority search.
