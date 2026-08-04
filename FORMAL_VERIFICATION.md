# Formal verification boundary

## What Lean proves unconditionally

The project in [`formal/`](formal/README.md) is pinned to Lean and mathlib
`v4.32.0`.  Its field-theoretic module
[`NonTotalReality.lean`](formal/PseudoArithmetic/NonTotalReality.lean) proves:

1. the conjugate quadratic

   $$
   (s-1)u^2+2(s-3)u+s-7
   $$

   has no real zero when $s^2=5$ and $s<0$;
2. a complex embedding carrying $s$ to $-\sqrt5$ is not real; and
3. for any number field $K$ and $s,u\in K$,

   $$
   \mathrm{minpoly}_{\mathbf Q}(s)=X^2-5,\qquad
   (s-1)u^2+2(s-3)u+s-7=0
   $$

   imply that $K$ is not totally real.

The third theorem uses mathlib's number-field embedding theorem to obtain the
embedding $s\mapsto-\sqrt5$ from the minimal polynomial.  Thus the bad
embedding is a conclusion, not an input.

## Conditional classical bridge

[`ConditionalDescent.lean`](formal/PseudoArithmetic/ConditionalDescent.lean)
implements the distinction suggested in the manuscript:

- unavailable classical theorems are ordinary hypotheses of the theorem that
  uses them;
- Lean verifies the case-specific obstruction and the entire downstream
  implication chain; and
- no global Lean axiom is introduced.

The `DescentBridge` interface separates odd-rank normalization,
Clifford-class necessity, the local split-support criterion, ABHN/Chebotarev
sufficiency, Hasse–Minkowski sufficiency, and the pseudo-arithmetic
characterization.  From these named inputs Lean proves

$$
\text{similarity descent}
\iff
\text{signature descent and split support}
$$

and the resulting finite pseudo-arithmeticity criterion.  Separate
kernel-checked lemmas prove that either a ramified nonsplit prime or an
incomplete ramified orbit violates split support.  For a negative obstruction
only the necessary directions are used; ABHN and Hasse–Minkowski enter the
positive converse.  Two explicit agreement lemmas prove

$$
\text{full similarity descent}\Longrightarrow\text{lightweight split support}
$$

and its contrapositive.  The direct versions use only similarity invariance
and functoriality of the Clifford/Tits class together with local Brauer
necessity: determinant normalization and both sufficiency hypotheses are
absent.  Thus a lightweight rejection cannot conflict with a positive
conclusion of the full criterion.

The module also proves the manuscript-facing conditional theorem:
if pseudo-arithmeticity of the object implies total reality of $K$, then the
minimal-polynomial and two-cycle relation above imply that the object is not
pseudo-arithmetic.

## Explicit external inputs

The present Lean project does not formalize:

- the Ma–Zheng census and finite-volume classification;
- the transcription of the radical values or the derivation of the displayed
  relation from those radicals;
- extraction of $s$ and $u$ from the two Coxeter cyclic products;
- Vinberg's identification of the cyclic-product field with the adjoint trace
  field;
- Emery–Mila's theorem that a pseudo-arithmetic trace field is totally real;
  or
- the underlying ABHN, local Brauer, Chebotarev, and Hasse–Minkowski
  infrastructure.

These facts are explicit hypotheses at the relevant application boundary.
Replacing any one of them by a future mathlib theorem will not require
changing the verified downstream proof.

## Build and audit

After downloading mathlib and its binary cache, run:

```sh
cd formal
lake exe cache get
lake build
```

The root module and both leaf modules compile with the pinned toolchain.  A
source audit finds no project-defined `axiom` or `opaque` declaration and no
`sorry`, `admit`, or `native_decide`.  As usual, the trusted base consists of
the Lean kernel, the pinned mathlib definitions and theorems, and Lean's
standard logical foundations.
