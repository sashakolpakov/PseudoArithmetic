# Lean formalization

This directory contains a portable Lean 4 project pinned to Lean and mathlib
`v4.32.0`.

## Build

```sh
lake build
```

`lake-manifest.json` locks mathlib to commit
`81a5d257c8e410db227a6665ed08f64fea08e997` and locks its transitive package
graph.  The package configuration passes `-j 1` to every Lean elaboration.

For an offline build, Lake path overrides can redirect the nine locked
packages to any existing compiled mathlib cache without copying it.  A
machine-local override may be placed at `.lake/package-overrides.json`, or
passed explicitly with
`lake --packages=/path/to/package-overrides.json build`.  The `.lake/`
directory is ignored by version control; the portable lockfile is independent
of such overrides.

`PseudoArithmetic/NonTotalReality.lean` kernel-checks the algebraic heart of
the two-cycle obstruction:

- the conjugate quadratic
  `(s - 1) u^2 + 2 (s - 3) u + s - 7` has no real zero when
  `s^2 = 5` and `s < 0`;
- an embedding of a number field sending `s` to `-sqrt 5` is therefore
  non-real;
- hence a field admitting that embedding is not totally real;
- if `minpoly ℚ s = X^2 - 5`, the standard number-field embedding theorem
  supplies that embedding, so the conclusion follows from only the minpoly
  and two-cycle relation.

`PseudoArithmetic/ConditionalDescent.lean` records the project's larger
normalized-descent application chains conditionally.  Classical facts not
yet represented in mathlib's quadratic-form API (normalized Clifford
descent, the ABHN local criterion, and the pseudo-arithmetic field criterion)
are explicit theorem hypotheses, never new axioms.  Lean then checks the
combined equivalences and the nonsplit-prime and non-total-reality
contradiction arguments.  It also checks explicitly that the direct
Clifford/Tits split-support test is a necessary consequence of similarity
descent, and hence that a lightweight rejection is logically compatible with
the full normalized criterion.  This direct implication has no normalization,
ABHN, or Hasse--Minkowski sufficiency hypothesis.

The external geometric identifications—that the cyclic-product field is the
adjoint trace field of the Coxeter lattice, and that pseudo-arithmetic trace
fields are totally real—remain explicit hypotheses at the application
boundary.
