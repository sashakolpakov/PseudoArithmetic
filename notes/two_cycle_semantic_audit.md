# Worked semantic audit: the two-cycle obstruction

The [manuscript-wide register](manuscript_semantic_audit.md) extends this
worked example to every mathematical source block, with explicit status and
positive/negative controls for each statement entry.

Date: 8 October 2026.

This is one completed example of an English-to-Lean audit. It covers the
non-total-reality certificate and its scalar quadratic argument. It does
not certify the translation of every statement in the manuscript.

The executable evidence is in
[`SemanticAudit.lean`](../formal/PseudoArithmetic/SemanticAudit.lean), which
is imported by the normal Lean build, and
[`semantic_audit_examples.py`](../scripts/semantic_audit_examples.py).
The latter uses exact rational arithmetic; its stored report is
[`two_cycle_semantic_audit.json`](../results/two_cycle_semantic_audit.json).

## 1. What the English statement actually says

Put

$$
F(s,u)=(s-1)u^2+2(s-3)u+s-7.
$$

The intrinsic version of the manuscript's non-total-reality certificate is:

> For every number field $K$ and every pair $s,u\in K$, if $s^2=5$ and
> $F(s,u)=0$, then $K$ is not totally real.

The conclusion means that **some** embedding $K\hookrightarrow\mathbf C$
has image not contained in $\mathbf R$. It allows other embeddings to have
real image. The main Lean signature, in
[`NonTotalReality.lean`](../formal/PseudoArithmetic/NonTotalReality.lean), is:

```lean
theorem not_totallyReal_of_cycle_square
    {K : Type*} [Field K] [NumberField K]
    (s u : K)
    (hsq : s ^ 2 = (5 : K))
    (hrel : (s - 1) * u ^ 2 + 2 * (s - 3) * u + s - 7 = 0) :
    ¬ NumberField.IsTotallyReal K
```

| English clause | Lean representation | Semantic check |
|---|---|---|
| Every number field | `{K : Type*} [Field K] [NumberField K]` | The examples construct actual number fields, including proofs of finite dimension; $K$ is not an arbitrary predicate. |
| Both elements belong to that field | `(s u : K)` | `field_membership_necessary` refutes allowing $u$ to live only in a larger field. |
| $s^2=5$ | `hsq` | `square_hypothesis_necessary` refutes deleting it. |
| The displayed relation, with its exact coefficients | `hrel` | The radical example satisfies it; the relation-deletion and perturbation controls fail it. |
| If the hypotheses hold, the conclusion follows | Explicit arguments followed by `:` | `concrete_positive_example` supplies the hypotheses by construction, so the implication is not vacuous. |
| Not totally real | `¬ NumberField.IsTotallyReal K` | The witness has both a real embedding and a nonreal embedding; it is also proved not totally complex. |

Mathlib defines `IsTotallyReal` using all infinite places and proves that it
is equivalent to every complex embedding being real. The audit inspects that
definition as well as the surface signature.

The manuscript initially chooses $s=\sqrt5$ at a distinguished real place.
The intrinsic Lean statement is more general: it does not choose a positive
root or require $K=\mathbf Q(s,u)$. It works in any containing number field.
This generalization preserves the desired implication. The concrete cycle
constructor checks the original positive-root interpretation separately.

The alternative hypothesis
$\mathrm{minpoly}_{\mathbf Q}(s)=X^2-5$ is equivalent to $s^2=5$ in a
characteristic-zero field. `square_iff_minpoly` proves both directions.
The irreducibility of $X^2-5$ is essential to this equivalence and is proved
in the main module; annihilating polynomials cannot generally be substituted
for minimal polynomials.

## 2. A positive example with no assumed certificate

Take the actual radicals used in the manuscript:

$$
s=\sqrt5,\qquad t=\sqrt{2+2s},\qquad
a=\frac12\sqrt{7+s+2t},\qquad u=\sqrt2\,a,
$$

and construct $L=\mathbf Q(s,u)$ as an intermediate field of $\mathbf R$.
Lean verifies all of the following:

1. $s^2=5$ and $F(s,u)=0$, using the positive radical definitions.
2. $L$ is a number field. The construction proves integrality of $s$ and
   $u$; an annihilating polynomial for $u$ is
   $X^4+2X^3-5X^2-16X-11$. No unproved degree or signature is assumed.
3. Applying the main theorem to these constructed elements gives
   $\neg\mathrm{IsTotallyReal}(L)$.
4. Inclusion $L\hookrightarrow\mathbf R$ is a real embedding, while some
   embedding into $\mathbf C$ is nonreal. Thus the conclusion has the
   intended quantifier and does not accidentally assert total complexity.
5. The concrete cycle values $c_{12}=(3+s)/2$ and $c_{035}=-2u$ also pass
   through `not_totallyReal_of_real_cycles`. This exercises the constructor
   that connects the manuscript's cycle data to the algebraic theorem.

The principal declarations are `concrete_positive_example`,
`concrete_cycle_constructor`, `real_embedding_does_not_mean_totallyReal`,
`witness_has_nonreal_embedding`, and `witness_not_totallyComplex`.
Their theorem statements have no additional mathematical hypotheses.

## 3. Negative controls that distinguish plausible mistranslations

A true implication cannot have an example satisfying all its hypotheses and
falsifying its conclusion. Each negative control therefore identifies a
specific change to the statement and gives a counterexample to that change.
A failed tactic would not establish such a counterexample; the field
counterexamples below are themselves proved in Lean.

| Incorrect statement or change | Counterexample | What Lean verifies |
|---|---|---|
| Delete $s^2=5$ from the field theorem. | $K=\mathbf Q$, $s=7$, $u=0$. | $F(7,0)=0$ and $7^2\ne5$, while $\mathbf Q$ is totally real (`square_hypothesis_necessary`). |
| Delete $F(s,u)=0$. | $K=\mathbf Q(\sqrt5)$, $s=\sqrt5$, $u=0$. | $s^2=5$, $F(s,0)=s-7\ne0$, and this field is totally real (`relation_hypothesis_necessary`). |
| Permit $u\in\mathbf R$ without requiring $u\in K$. | The same $K=\mathbf Q(\sqrt5)$, with the manuscript's real radical $u$. | The real equation holds but $u\notin K$, and $K$ remains totally real (`field_membership_necessary`). |
| Replace “some embedding is nonreal” by “every embedding is nonreal,” or by “the field is totally complex.” | The constructed $L\subset\mathbf R$. | Its inclusion is real, although another embedding is nonreal; total complexity is false. |
| In the scalar no-real-root lemma, delete $s<0$ while retaining $s^2=5$. | $s=\sqrt5$ and the positive radical $u$. | Both algebraic equations hold over $\mathbf R$ (`negative_sign_necessary`). |
| In that scalar lemma, retain only $s<0$ and delete $s^2=5$. | $s=-1$, $u=-2$. | The relation holds, $s<0$, and $s^2\ne5$ (`negative_sign_alone_insufficient`). |
| Replace “negative discriminant” by “nonpositive discriminant.” | $s=-1$, $u=-2$. | The discriminant is zero and there is a double real root (`double_root_boundary`). |
| Treat the polynomial as quadratic for every $s$. | $s=1$, $u=-3/2$. | The leading coefficient vanishes and the remaining linear equation has this root (`linear_boundary`). |

Total reality of $\mathbf Q(\sqrt5)$ is proved, not supplied as a local
assumption. Every complex embedding sends its generator to one of
$\pm\sqrt5$; agreement with complex conjugation on the generator implies
agreement on the generated field (`baseField_embedding_real`).

Some changes to a theorem preserve its truth, and some hypotheses can be
redundant. An audit should record those facts rather than demand a
counterexample to every possible edit. Likewise, these counterexamples
establish necessity of the indicated hypotheses for the stated general
implication; they do not establish a converse to the field theorem.

### A mistranslation that still has a valid Lean proof

Deliberately change the middle term from $+2(s-3)u$ to $-2(s-3)u$.
The resulting field theorem is still true: replace $u$ by $-u$ and apply
the original theorem. Its discriminant is also still $8(1+s)$.
`changed_middle_sign_also_provable` checks this fact in Lean.

Nevertheless, the manuscript's actual $s$ and positive radical $u$ do
**not** satisfy that altered equation. `middle_sign_mutation_rejected`
proves the failure. Thus a successful proof and the correct discriminant
would both miss this transcription error, while the concrete positive
example detects it. This is a direct demonstration of why a semantic
audit needs examples tied to the intended mathematical objects.

## 4. An infinite barrage, including the boundary cases

The scalar tests are strengthened to a complete classification:

$$
\bigl(\exists u\in\mathbf R:\ F(s,u)=0\bigr)
\quad\Longleftrightarrow\quad s\geq-1.
$$

This is `real_root_iff`. Its forward direction uses the polynomial identity

$$
\bigl(2(s-1)u+2(s-3)\bigr)^2-8(1+s)=4(s-1)F(s,u).
$$

For the reverse direction, if $s\ne1$, a root is

$$
u=\frac{3-s+\sqrt{2+2s}}{s-1}.
$$

The exceptional value $s=1$ is handled by the linear root $-3/2$.
The value $s=-1$ gives the double root $-2$. These cases protect against
division by zero and a mistaken strict/non-strict inequality.

Three further universal Lean theorems provide exact families:

- **Roots:** for every $v\in\mathbf Q\setminus\{-1\}$,
  $F(S(v),v)=0$, where
  $S(v)=(v^2+6v+7)/(v+1)^2$ (`rational_root_family`).
- **Near misses:** for every such $v$ and every nonzero rational $\delta$,
  $F(S(v)+\delta,v)=\delta(v+1)^2\ne0$
  (`rational_perturbation_family`). This tests exact satisfaction of the
  equation, even when a proposed input is very close to a valid one.
- **No roots below the boundary:** for every natural number $n$ and every
  real $u$, $F(-2-n,u)\ne0$ (`negative_parameter_family`).

The finite Python barrage uses the manuscript's coefficients in Horner
form and checks the following exact rational cases:

| Family | Inputs | Cases |
|---|---|---:|
| Roots | Integer $v=-1000,\ldots,1000$, excluding $-1$, with $s=S(v)$ | 2,000 |
| Near misses | The same $v$, with $s=S(v)\pm1/1000$ | 4,000 |
| Below the boundary | $s=-2-n$, $n=0,\ldots,100$; $u=m/8$, $m=-100,\ldots,100$ | 20,301 |
| Discriminant identity | $s=m/8$, $m=-1000,\ldots,1000$ | 2,001 |
| Named examples | Four roots and four non-roots, including both exceptional values | 8 |

All 28,310 cases pass. Cases in different families may overlap. None uses
floating-point tolerances. The universal claims above are Lean proofs;
the Python runs provide additional executable checks and inspectable data.
The rational examples test the quadratic, not the number-field conclusion:
no rational $s$ can satisfy $s^2=5$.

## 5. Language changes and verification

The manuscript now specifies the ambient fields in the certificate:
$s=\sqrt5\in\mathbf R$ and $u\in\mathbf C$. It also explains that the
positive-radical field has a distinguished real embedding and that
non-total reality concerns its other embeddings. The comment for
`real_radical_calculation` now correctly says that it has seven hypotheses,
rather than four.

Run the worked audit from the repository root:

```sh
python3 scripts/semantic_audit_examples.py
cd formal
lake build
```

The release validator regenerates and compares the rational report, builds
the Lean module, and inspects the transitive axioms of the main example and
counterexample declarations. The permitted logical axioms remain
`propext`, `Classical.choice`, and `Quot.sound`.

## 6. Applying this standard to the rest of the manuscript

For each mathematical statement, record its English location, full Lean
signature, definitions behind its predicates, quantifiers, domains,
coercions, hypotheses, and conclusion. Then provide a constructed positive
instance and a negative control with the exact mutation it refutes, followed
by boundary cases and parameterized families where useful. Definitions and
equivalences should receive examples on both sides of the classification;
identities should receive controls for a plausible altered identity.

Mark statements that are unformalized or represented by external assumptions
explicitly. An abstract predicate with a geometric name does not establish
that its Lean meaning matches the geometry. Here the concrete radical and
field portion has been exercised, but the census polytopes, Gram-cycle
identification, lattice predicates, and manifold construction still have the
external boundary described in
[`FORMAL_VERIFICATION.md`](../FORMAL_VERIFICATION.md).

Examples test mathematical meaning and guard against mistakes in translation.
They supplement the clause-by-clause review and the general kernel proof;
even many successful examples cannot by themselves certify every English
statement.
