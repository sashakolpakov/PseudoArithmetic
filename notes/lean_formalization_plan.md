# Lean formalization plan and completion record

Status: manuscript target completed for `1.0.0-rc1`, 24 September 2026.

This file records the design choice behind the formal companion. The release
formalizes the manuscript's internal proof and translates every external
statement it uses into a typed local hypothesis. It does not introduce axioms
for, or claim new verification of, the external geometry and literature.

## Completed manuscript target

[`NonTotalReality.lean`](../formal/PseudoArithmetic/NonTotalReality.lean)
proves the intrinsic theorem

```lean
theorem not_totallyReal_of_cycle_minpoly
    {K : Type*} [Field K] [NumberField K]
    (s u : K)
    (hmin : minpoly ℚ s = Polynomial.X ^ 2 - Polynomial.C 5)
    (hrel : (s - 1) * u ^ 2 + 2 * (s - 3) * u + s - 7 = 0) :
    ¬ NumberField.IsTotallyReal K
```

The proof uses mathlib's number-field embedding and total-reality APIs:

1. realize the conjugate root $-\sqrt5$ as the value of a complex embedding;
2. map the relation for $u$ through that embedding;
3. prove that the conjugate quadratic has no real root; and
4. contradict `NumberField.IsTotallyReal.complexEmbedding_isReal`.

[`Manuscript.lean`](../formal/PseudoArithmetic/Manuscript.lean) additionally
checks:

- recovery of $\sqrt5$ and $u$ from the two cyclic products;
- the concrete positive nested-radical identity;
- a `TwoCycleCertificate` matching the paper;
- the main non-pseudo-arithmeticity implication; and
- the finite-index manifold corollary.

The external boundary is represented by `CoxeterExternalInputs` and
`ManifoldExternalInputs`. Their fields translate:

- the Ma--Zheng finite-volume census statements;
- Vinberg's cyclic-product/adjoint-trace-field identification;
- the Emery--Mila total-reality obstruction;
- Selberg's finite-index construction;
- hyperbolic quotient geometry; and
- finite-index trace-field invariance.

These are theorem parameters, not Lean axioms.

## Conditional normalized-descent target

[`ConditionalDescent.lean`](../formal/PseudoArithmetic/ConditionalDescent.lean)
implements the larger split-support implication graph through an abstract
interface. It checks the normalization/descent equivalences and all negative
obstruction chains once the following classical inputs are supplied:

- normalized Clifford descent;
- Albert--Brauer--Hasse--Noether and local-degree formulas;
- Hasse--Minkowski and local/global classification of quadratic forms;
- existence with prescribed local invariants;
- the required Chebotarev consequence; and
- the pseudo-arithmetic candidate characterization.

The current mathlib version does not expose this complete Witt/Brauer and
quadratic-form package. The module is therefore correctly described as a
conditional kernel certificate, not as an unconditional formalization of
ABHN or Hasse--Minkowski.

## Deferred upstream work

The following remain separate possible projects rather than release blockers:

1. define odd-rank determinant normalization using mathlib quadratic forms;
2. develop the necessary Brauer-group functoriality and local invariants;
3. formalize Hasse--Minkowski and prescribed local form existence;
4. formalize hyperbolic Coxeter polytopes and Vinberg fields; and
5. replace each manuscript external-input field with the corresponding future
   library theorem.

For bounded memory, the project remains pinned, uses narrow imports, and
builds with one Lean job.
