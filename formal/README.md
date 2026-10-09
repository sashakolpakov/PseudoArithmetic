# Lean formalization

This directory contains the Lean 4 formal companion to
*Non-Pseudo-Arithmetic Hyperbolic 4-Manifolds*. It is pinned to Lean and
mathlib `v4.32.0`.

## Build

```sh
lake build
```

`lake-manifest.json` locks mathlib to commit
`81a5d257c8e410db227a6665ed08f64fea08e997` and locks its transitive package
graph. The package configuration passes `-j 1` to Lean elaboration.

For an offline build, Lake path overrides can redirect the locked packages to
an existing compiled mathlib cache. A machine-local override may be placed at
`.lake/package-overrides.json` or passed with
`lake --packages=/path/to/package-overrides.json build`. The ignored `.lake/`
directory is not part of the portable release.

## Modules

### `PseudoArithmetic/Manuscript.lean`

This is the manuscript-facing proof graph. It kernel-checks:

- exact recovery of $s$ and $u$ from the two displayed cyclic products;
- the nested positive-radical calculation;
- construction of a `TwoCycleCertificate` from the two cycle values under a
  real embedding, with the radical relation and minimal polynomial proved
  internally;
- the implication from that certificate to non-total reality;
- the main non-pseudo-arithmeticity implication; and
- the finite-index manifold corollary.

Geometry and literature facts are typed fields of `CoxeterExternalInputs` and
`ManifoldExternalInputs`. They are local theorem hypotheses, not project
axioms. These structures use abstract predicates; they do not define the
geometry. The `CoxeterCase` type labels the three rows `p11_6`, `p11_7`, and
`p11_8`, without constructing the polytopes. The manifold interface requires
finite volume and noncompactness of the base as separate hypotheses.

### `PseudoArithmetic/NonTotalReality.lean`

This module proves the algebraic heart in a reusable intrinsic form:

$$
\mathrm{minpoly}_{\mathbf Q}(s)=X^2-5,
\qquad
(s-1)u^2+2(s-3)u+s-7=0
\quad\Longrightarrow\quad
K\text{ is not totally real}.
$$

Mathlib's number-field embedding theorem supplies an embedding sending $s$
to $-\sqrt5$. Lean proves that this embedding cannot be real.
The theorem `minpoly_eq_of_square_five` now proves the minimal-polynomial
hypothesis from $s^2=5$; `not_totallyReal_of_cycle_square` uses this weaker
input.

### `PseudoArithmetic/ConditionalDescent.lean`

This supplementary module checks the normalized-Clifford and split-support
implication graph conditionally. ABHN, Hasse--Minkowski, local Brauer
functoriality, and the pseudo-arithmetic candidate characterization are
explicit hypotheses because the required end-to-end quadratic-form API is not
developed in this project. Candidate finiteness and enumeration are also
outside this abstract interface. This module is not needed for the
manuscript's two-cycle obstruction.

### `PseudoArithmetic/SemanticAudit.lean`

This worked English-to-Lean audit supplies a constructed positive example
for the two-cycle theorem, proved counterexamples to specific
mistranslations, and infinite families of roots and non-roots. It checks
both the field-level meaning of non-total reality and the scalar
quadratic's boundary cases. The module is part of the default build.
See the [audit with examples](../notes/two_cycle_semantic_audit.md) for the
clause-by-clause comparison and the companion rational barrage.

### Manuscript-wide audit modules

The [complete register](../notes/manuscript_semantic_audit.md) assigns a
positive example, negative control, Lean mapping, and explicit scope to
135 entries. All modules below are imported by the default build.

| Module | Checked mathematical content |
| --- | --- |
| `FieldAudit` | Minimal polynomials, primitive elements, quotient-root embeddings, both √5 embeddings, extension, discriminants, total-positivity equivalence, arbitrary complex solution fields |
| `GramAudit` | Actual matrices, closed products, generated number fields, non-total reality, literal four-generator equality, strict cycle/entry-field example |
| `RadicalAudit` | Radical identities, roots of unity, positivity, cancellation, all five leading-minor identities and signs |
| `GeometryAudit` | Lorentz form, reflections, rescaling, Coxeter-label controls |
| `CoverAudit` | Orientation indices, finite-index finite generation, noncompactness, scalar volume controls |
| `TraceAudit` | Basis invariance, generated trace-field inclusion, adjoint versus defining trace |
| `CensusAudit` | Pair ordering, equality of decoded rows with actual matrices, numerical census-data controls |
| `InterfaceAudit` | Positive and negative logical models of the external interfaces |
| `ExternalContracts` | Dimension-four input contracts with actual matrix and field equalities, shared cover witnesses, and mutation controls |
| `SubdiagramAudit`, `SubdiagramClassify`, `SubdiagramControls` | Exact real-matrix certificates; exhaustive classification of all 127 nonempty subsets, vertex ranks, endpoint counts, and incidence mutations |
| `FaceAudit`, `FaceControls`, `DiagramFaceAudit` | Closed face incidences, stable chain dimension, full face vector, geometric transfer, deletion controls, and infinite Euler false positives |

The geometric interpretation of the matrices, Lie-group adjoint construction,
Selberg theorem, and hyperbolic quotient construction remain external.
The register labels written examples and computation-only evidence explicitly.
It assesses translation separately from proof provenance; imported geometric
theorems and mathlib proofs are accepted. See the
[external translation review](../notes/external_translation_audit.md) for the
seven contracts and the disposition of the original 21 partial entries.

## Trust statement

The project defines no `axiom` or `opaque` declaration and uses no `sorry`,
`admit`, or `native_decide`. The external geometric identifications are
visible in theorem signatures. See
[`../FORMAL_VERIFICATION.md`](../FORMAL_VERIFICATION.md) for the complete
boundary and the manuscript's external-input register for the corresponding
citations.

The repository validator also inspects the transitive axioms of all registered
declarations using `#print axioms`, allowing only `propext`,
`Classical.choice`, and `Quot.sound`.
