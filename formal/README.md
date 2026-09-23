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
- packaging of those facts as a `TwoCycleCertificate`;
- the implication from that certificate to non-total reality;
- the main non-pseudo-arithmeticity implication; and
- the finite-index manifold corollary.

Geometry and literature facts are typed fields of `CoxeterExternalInputs` and
`ManifoldExternalInputs`. They are local theorem hypotheses, not project
axioms. The `CoxeterCase` type has exactly the three constructors `p11_6`,
`p11_7`, and `p11_8`.

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

### `PseudoArithmetic/ConditionalDescent.lean`

This supplementary module checks the normalized-Clifford and split-support
implication graph conditionally. ABHN, Hasse--Minkowski, local Brauer
functoriality, and the pseudo-arithmetic candidate characterization are
explicit hypotheses because the required end-to-end quadratic-form API is not
currently present in mathlib. This module is not needed for the manuscript's
two-cycle obstruction.

## Trust statement

The project defines no `axiom` or `opaque` declaration and uses no `sorry`,
`admit`, or `native_decide`. The external geometric identifications are
visible in theorem signatures. See
[`../FORMAL_VERIFICATION.md`](../FORMAL_VERIFICATION.md) for the complete
boundary and the manuscript's external-input register for the corresponding
citations.
