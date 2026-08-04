# Lean formalization boundary

Status: feasibility audit, 4 August 2026.

The most important new algebraic step in the counterexample theorem can be
kernel-checked in Lean 4/mathlib without formalizing the Coxeter census.  The
full normalized Clifford descent theorem cannot currently be proved from
mathlib's existing library without substantial new foundations.

## Immediate publication target

The first target should be an abstract theorem of the following form.

```lean
theorem not_totallyReal_of_cycle_relation
    (K : Type*) [Field K] [NumberField K]
    (s u : K)
    (hs : minpoly ℚ s = X ^ 2 - C 5)
    (hu : (s - 1) * u ^ 2 + 2 * (s - 3) * u + s - 7 = 0) :
    ¬ NumberField.IsTotallyReal K
```

The proof uses existing number-field embedding and total-reality APIs:

1. realize the conjugate root `-sqrt 5` as the value of a complex embedding;
2. map the relation for `u` through that embedding;
3. prove by square completion (or discriminant) that the conjugate quadratic
   has no real root, since its discriminant is `8*(1-sqrt 5) < 0`;
4. contradict `NumberField.IsTotallyReal.complexEmbedding_isReal`.

The library theorem `NumberField.IsTotallyReal.of_algebra` also formalizes the
step saying that a field containing a non-totally-real algebraic subfield is
not totally real. Recovery of `sqrt 5` and `u` from the two cyclic products is
elementary `ring`/`field_simp` algebra. Thus Lean can check essentially every
new deduction between the exact Coxeter entries and non-total reality.

The trusted external boundary remains explicit:

- Ma--Zheng's three rows are finite-volume Coxeter polytopes;
- Vinberg's cyclic-product field is the adjoint trace field;
- pseudo-arithmetic trace fields are totally real.

## Odd-rank normalization

A second, realistic target is the normalization

```text
q# = <det(q)^(-1)> q
```

for odd-rank forms. Mathlib already supplies quadratic forms, discriminants,
isometries, base change, signatures, and Clifford algebras. After defining
similarity and similarity descent, Lean can verify that:

- `q#` has square determinant;
- its isometry class is independent of the determinant representative;
- it is unchanged up to isometry when `q` is rescaled; and
- similarity descent of `q` is equivalent to isometry descent of `q#`.

A coordinate model on `Fin m -> K` is the economical first implementation.
This proves the manuscript's normalization step without first constructing a
quadratic-form Witt group.

## What mathlib does not yet provide

The present library has no quadratic-form Witt group or Witt ring. Its Brauer
group file currently defines the quotient set, but not the group law,
functorial scalar extension, 2-torsion, local invariants, or ramification
support. The following classical inputs needed by the full descent theorem are
also absent as a usable package:

- Albert--Brauer--Hasse--Noether;
- the local-degree formula for restricted Brauer invariants;
- Hasse--Minkowski and local/global classification of quadratic forms;
- existence with prescribed local invariants;
- the required Chebotarev consequence; and
- the Hilbert-symbol/quaternion ramification infrastructure.

Accordingly, the split-support theorem should first be formalized from an
explicit abstract interface containing these classical inputs as hypotheses.
That would be a genuine conditional kernel certificate of the logical
assembly, in the same transparent style as the StickNumbers formalization. It
should not be described as an unconditional formalization of ABHN or
Hasse--Minkowski.

## Recommended order

1. Fully prove the non-total-reality theorem and the two-cycle algebra.
2. Prove canonical odd-rank normalization and the similarity/isometry descent
   equivalence.
3. Prove the split-support deduction from typed local-global hypotheses.
4. Treat Witt/Brauer infrastructure as a separate upstream formalization
   project, not as a prerequisite for the present paper.

For bounded memory, pin Lean and mathlib, use narrow imports and the compiled
mathlib cache, and build only the named target with one job.
