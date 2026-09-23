# Formal verification boundary

Release candidate: `1.0.0-rc1`

The project in [`formal/`](formal/README.md) is pinned to Lean and mathlib
`v4.32.0`. It formalizes the manuscript's internal implication graph while
leaving cited geometry and classification results as explicit local
hypotheses. A successful build therefore checks the new algebra and every
downstream logical step; it does not claim a new formal proof of the external
literature.

## Unconditional manuscript results

[`Manuscript.lean`](formal/PseudoArithmetic/Manuscript.lean) proves:

1. `recover_s_from_twoCycle`: from
   $c_{12}=(3+s)/2$, recover $s=2c_{12}-3$;
2. `recover_u_from_threeCycle`: from $c_{035}=-2u$, recover
   $u=-c_{035}/2$;
3. `cycle_relation_of_radical_identities`: the final ring-theoretic
   elimination in the nested-radical calculation;
4. `explicit_radical_cycle_relation`: for the actual positive radicals

   $$
   s=\sqrt5,\quad
   a=\frac12\sqrt{7+s+2\sqrt{2+2s}},\quad
   u=\sqrt2a,
   $$

   prove

   $$
   (s-1)u^2+2(s-3)u+s-7=0;
   $$

5. a typed `TwoCycleCertificate`, together with the theorem that any number
   field carrying such a certificate is not totally real.

[`NonTotalReality.lean`](formal/PseudoArithmetic/NonTotalReality.lean) proves
the field-theoretic core:

- the conjugate quadratic has no real zero when $s^2=5$ and $s<0$;
- a complex embedding carrying $s$ to $-\sqrt5$ cannot be real; and
- for a number field $K$ and $s,u\in K$,

  $$
  \mathrm{minpoly}_{\mathbf Q}(s)=X^2-5,
  \qquad
  (s-1)u^2+2(s-3)u+s-7=0
  $$

  imply that $K$ is not totally real.

The last theorem uses mathlib's number-field embedding theorem to obtain an
embedding with $s\mapsto-\sqrt5$ from the minimal polynomial. The bad
embedding is a conclusion, not an input.

## Manuscript-facing external boundary

The structures `CoxeterExternalInputs` and `ManifoldExternalInputs` translate
the paper's imported statements into Lean propositions.

`coxeter_case_main_theorem` takes:

- a case name among $P_{11,6}$, $P_{11,7}$, and $P_{11,8}$;
- the external assertion that its reflection group is a finite-volume
  lattice;
- the external identification of $K$ as its adjoint trace field;
- the external Emery--Mila implication from pseudo-arithmeticity to total
  reality; and
- the internally checked `TwoCycleCertificate`.

Lean concludes finite volume, the trace-field identification, non-total
reality, and non-pseudo-arithmeticity as one conjunction.

`finiteIndex_manifold_corollary` additionally takes typed versions of:

- the orientation-subgroup/Selberg finite-cover construction;
- quotient geometry for a torsion-free orientation-preserving subgroup;
- finite-index invariance of the adjoint trace field; and
- the equivalence between pseudo-arithmeticity of a quotient and its
  fundamental group.

Lean then proves existence of an orientable, noncompact, finite-volume
hyperbolic manifold that is not pseudo-arithmetic.

These inputs are structure fields supplied to individual theorems. They are
not global Lean axioms.

## External statements not newly verified

The project does not formalize from first principles:

- the Ma--Zheng census or its finite-volume classification;
- the source-file transcription of the three rows into Gram matrices;
- Vinberg's identification of the cyclic-product field with the adjoint
  trace field;
- Emery--Mila's theorem that a pseudo-arithmetic trace field is totally real;
- Selberg's lemma;
- the hyperbolic orbifold/manifold quotient construction; or
- finite-index invariance of the adjoint trace field.

The exact arithmetic scripts verify the concrete transcription and radical
relations independently, but script execution is not conflated with kernel
verification of the cited theorems.

## Conditional supplementary development

[`ConditionalDescent.lean`](formal/PseudoArithmetic/ConditionalDescent.lean)
checks the repository's separate normalized-Clifford and split-support proof
graph. Classical inputs absent from mathlib's current quadratic-form API are
ordinary hypotheses:

- normalization of odd-rank similarity descent;
- Clifford-class necessity;
- local Brauer restriction;
- ABHN/Chebotarev sufficiency;
- quadratic-form realization and Hasse--Minkowski; and
- the pseudo-arithmetic candidate characterization.

From those inputs Lean proves the complete conditional criterion, its
necessary lightweight direction, and the incompatibility of a nonsplit or
incomplete ramified orbit with similarity descent. This module is not used by
the manuscript's two-cycle proof.

## Build and source audit

Run:

```sh
cd formal
lake build
```

The release validator also checks every project `.lean` file for forbidden
declarations or proof escapes. The project contains no declaration of
`axiom` or `opaque` and no use of `sorry`, `admit`, or `native_decide`.

As usual, the trusted base consists of the Lean kernel, the pinned Lean
compiler and mathlib declarations, and Lean's standard logical foundations.
