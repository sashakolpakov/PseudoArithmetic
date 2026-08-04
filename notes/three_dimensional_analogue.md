# A quaternionic three-dimensional analogue

This note is a laboratory for the Emery--Mila question, not an answer to it:
their definition of pseudo-arithmeticity explicitly assumes `n > 3`.

## The canonical object

For a finite-covolume orientable Kleinian group
`Gamma < PSL(2,C)`, the canonical commensurability data are its invariant
trace field and invariant quaternion algebra

```text
K = Q(tr Gamma^(2)),       A = K[Gamma^(2)] inside M_2(C).
```

These replace a canonical four-variable Lorentz form.  There is nevertheless
a canonical quadratic avatar: on the trace-zero subspace `A^0`, take reduced
norm.  If `A = (a,b)_K`, then

```text
q_A = Nrd|A^0 = <-a,-b,ab>,
C^0(q_A) = A,
PGL_1(A) = SO(q_A).
```

Thus quaternion descent is similarity descent of a ternary form.  The full
quaternion norm is `<1,-a,-b,ab>`, but over a real place it is either definite
or has signature `(2,2)`, never `(3,1)`.  The usual Lorentz form on
`Herm_2(C)` uses complex conjugation, and therefore does not in general
descend to a canonical rank-four form over `K`.

Primary references: [Coulson--Goodman--Hodgson--Neumann, Section
4](https://www.math.columbia.edu/department/neumann/preprints/snappaper3.pdf)
for the canonical invariants and exact census data; [Quinn](https://arxiv.org/abs/1701.06712)
for the special rank-four construction when a suitable involution of the
second kind exists.

## Proposed quaternion-pseudo condition

Call `Gamma` *quaternion-pseudo* if there are

1. a number field `k` with exactly one complex place;
2. a finite elementary-2 extension `K/k`; and
3. a quaternion algebra `B/k`, ramified at every real place of `k`,

such that `A` is isomorphic to `B tensor_k K`.

For a fixed nontrivial elementary-2 extension `K/k`, ABHN gives an exact
criterion:

- `A` ramifies at every real place of `K`;
- every finite ramified place of `A` lies over a prime splitting completely
  in `K/k`; and
- above each such prime, the entire fiber ramifies or none of it does.

Indeed,

```text
inv_w(B_K) = [K_w:k_v] inv_v(B).
```

A nontrivial local degree in an elementary-2 extension is even and kills a
quaternion invariant.  Conversely, the stated fiber data define `B` by ABHN;
if reciprocity parity needs correction, ramify `B` at one nonsplit finite
prime, which becomes invisible after restriction.  This is exactly the
split-support obstruction from the odd-rank orthogonal problem, now with
`[A]` itself as the Brauer class.

## Actual failures in dimension three

- The `5_2` knot complement (`m015`) has invariant field
  `Q[x]/(x^3-x^2+1)`, of signature `(1,1)`.  A cusped Kleinian group's
  invariant quaternion algebra is split, so `A` splits at its real place.
  Since the field degree is odd, `K/k` cannot be a nontrivial elementary-2
  extension.  This is a quaternion-pseudo obstruction.

- The closed filling `m009(1,2)` has invariant field of degree five and
  signature `(3,1)`.  Its invariant quaternion algebra ramifies at only two
  of its three real places.  Again no nontrivial elementary-2 descent is
  possible, so it also fails.

The exact field signatures and quaternion ramification for both examples are
tabulated by
[Coulson--Goodman--Hodgson--Neumann](https://www.math.columbia.edu/department/neumann/preprints/snappaper3.pdf).
Long--Reid independently record the cubic invariant field of `m015`
[here](https://intlpress.com/site/pub/files/_fulltext/journals/mrl/1999/0006/0005/MRL-1999-0006-0005-a011.pdf).

More generally, every cusped hyperbolic three-manifold whose invariant trace
field has a real place fails this proposed condition.  Twist-knot families
provide systematic odd-degree examples; see
[Hoste--Shanahan](https://digitalcommons.lmu.edu/math_fac/165/).

## Lesson for `n = 4`

The three-dimensional failures isolate the desired higher-dimensional
pattern:

```text
canonical ambient Brauer class
  + an unavoidable non-admissible real place
  or ramification at a nonsplit finite place
  = non-descent.
```

In `H^4`, the canonical type-`B_2` ambient group is represented by a
rank-five similarity class.  Its normalized even-Clifford algebra is the
direct replacement for `A`. The split-support countermodel gives one route;
the Ma--Zheng cases in `notes/p11_6_8_non_total_family.md` now give actual
lattice counterexamples by the still smaller non-total-trace-field route.

## Codimension-one promotion to dimension four

There is also a precise version of the proposed embedding argument. Let
`Delta < PO(3,1)` be a finite-volume totally geodesic hypersurface subgroup of
`Gamma < PO(4,1)`, and let `L` be the Kleinian invariant trace field of
`Delta`. If `Gamma` is pseudo-arithmetic, its rank-five ambient group is
`PO(q)` for a form obtained from an admissible form over a totally real base;
in particular its adjoint trace field `K` is totally real.

In dimension four every pseudo-admissible ambient group is of quadratic-form
type. After passing to a finite-index subgroup that kills the normal sign,
`Delta` has a unique invariant normal line in the five-dimensional standard
representation. The ambient matrices and the Zariski closure of `Delta` are
defined over `K`; uniqueness makes this line Galois-stable, hence `K`-rational.
Its orthogonal rank-four subspace is therefore also defined over `K`. Write
`r` for the restricted rank-four form and

```text
E = Z(C^0(r)).
```

The center `E` is a quadratic etale `K`-algebra (and is a quadratic field in
the Lorentzian situation). The exceptional `D_2` description gives

```text
PSO(r) = Res_(E/K) PGL_1(B)
```

for a quaternion algebra `B/E`, with the analogous product description if
`E` is split. Projection to the geometric half-spin factor identifies the
intrinsic `PSL(2,C)` representation. For a projective two-by-two matrix its
trace-square character is `(tr(g))^2/det(g)`, so every generator of the
Kleinian invariant trace field belongs to `E`. Thus `L` embeds in `E`, and
consequently

```text
[L : L intersection K] <= 2.                         (*)
```

This yields a useful promotion criterion:

> If a finite-volume hyperbolic 3-manifold has odd absolute degree
> `[L:Q]`, and has non-totally-real
> invariant trace field and embeds or immerses as a finite-volume totally
> geodesic hypersurface in a finite-volume hyperbolic 4-orbifold, then the
> ambient 4-lattice is not pseudo-arithmetic.

Indeed, odd degree and (*) force `L` to lie in the totally real field `K`, a
contradiction. Thus either `m015` or the closed `m009(1,2)` would immediately
promote to a four-dimensional counterexample if such a hypersurface
realization were found.

The codimension-one hypothesis is essential to this short argument. For an
embedding of `H^3` in `H^n` with `n>4`, the normal space has dimension greater
than one and the minimal rational subspace may arise by Weil restriction;
the invariant field need not sit in a quadratic extension of the ambient
field. No general higher-codimension heredity assertion is being made here.

Kolpakov--Reid--Riolo note that they knew no finite-volume hyperbolic
3-manifold with odd-degree invariant trace field that even embeds
geodesically, so `m015` remains a target rather than a known promotion.
