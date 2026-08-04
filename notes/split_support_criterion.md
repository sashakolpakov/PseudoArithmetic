# Split-support criterion for pseudo-arithmeticity in even dimension

Status: theorem draft, 4 August 2026.  The normalized descent statement is a
short consequence of classical Hasse--Minkowski and ABHN machinery.  A
targeted literature check found Emery--Mila's isometry-sensitive Scharlau
transfer criterion, but no explicit similarity-normalized split-support
criterion for pseudo-arithmeticity.  The appropriate print claim is therefore
"to the best of our knowledge," not an unqualified priority claim.

## 1. Canonical normalization in odd rank

Let `K` be a number field and let `q` be a regular quadratic form over `K` of
odd rank

```text
m = 2r + 1 >= 5.
```

Choose a representative `delta(q)` of the determinant square class and put

```text
q# = <delta(q)^(-1)> q.
```

This is well-defined up to isometry.  Indeed,

```text
det(q#) = delta(q)^(1-m) is a square,
```

and replacing `q` by `a q` replaces `q#` by `a^(1-m) q#`, where `1-m` is
even.  Thus `q#` depends only on the similarity class of `q`, hence only on
`PO(q)`.  Moreover,

```text
q similarity-descends to k  <=>  q# isometry-descends to k.
```

Write

```text
c(q) = [C^0(q#)] in Br(K)[2]
```

for the Brauer class of the even Clifford algebra of the normalized form.

## 2. The exact number-field descent criterion

### Theorem (normalized Clifford descent)

Let `K/k` be a nontrivial finite multiquadratic extension of number fields,
with Galois group `H`.  Let `q/K` have odd rank `m >= 3`.  Then `q` is similar
to the scalar extension of a form over `k` if and only if both conditions hold:

1. for every real place `v` of `k`, the signatures of `q#` at all real places
   `w | v` of `K` are equal;
2. `c(q)` belongs to the image of
   `res: Br(k)[2] -> Br(K)[2]`.

For a totally real multiquadratic extension, condition 2 has the following
completely local form.  The finite ramification set of `c(q)` must

- be `H`-stable; and
- contain only primes `w` whose decomposition group in `H` is trivial.

Equivalently, each finite ramified prime lies above a prime of `k` that splits
completely in `K/k`, and over each such prime either the entire fiber ramifies
or none of it does.

### Proof

Necessity is functorial.  If `q# = (q0)_K`, signatures are constant on each
real fiber and

```text
C^0(q#) = C^0(q0) tensor_k K.
```

For a place `w | v`, restriction of Brauer classes satisfies

```text
inv_w(res beta) = [K_w : k_v] inv_v(beta).
```

Every nontrivial local degree in a multiquadratic extension is even.  A
2-torsion invariant `1/2` therefore dies at every nonsplit place.  At a
completely split place the local degree is one, so all primes in the fiber
receive the same invariant.  This proves the split-support condition.

Conversely, suppose the signatures descend and the split-support condition
holds.  Prescribe a class `beta0 in Br(k)[2]` as follows.  At every completely
split place, give it the common invariant of `c(q)`; at real places use the
invariant forced by the common signature; and set all other invariants to
zero.  If the number of prescribed ramified places of `k` is odd, add one
finite nonsplit place.  Such a place exists by Chebotarev, and its invariant
dies after restriction because its local degree is even.  The
Albert--Brauer--Hasse--Noether theorem produces `beta0`, and the local formula
shows that `res(beta0) = c(q)`.

Quadratic forms over local and global number fields are classified by rank,
determinant, Hasse/Clifford invariant, and real signature.  At every place of
`k`, choose the odd-rank, square-determinant local form having Clifford class
`beta0` and the prescribed real signature.  The local choices satisfy the
global compatibility relation: ABHN reciprocity for `beta0`, together with
Hilbert reciprocity, is precisely the product relation for their Hasse
invariants.  The global existence theorem for quadratic forms therefore
gives a form `q0/k` with those localizations.  Its scalar extension has the
same complete set of local invariants as `q#`, so Hasse--Minkowski gives

```text
(q0)_K isometric to q#.
```

This proves sufficiency.

## 3. The lightweight obstruction and its agreement with the criterion

For rejection, most of the preceding theorem is unnecessary.  The even
Clifford algebra of an odd-rank form is invariant under similarity, so put

```text
alpha(q) = [C^0(q)] in Br(K)[2].
```

This is the type-`B` Tits class of `PO(q)`.  In particular
`alpha(q) = c(q)`: determinant normalization changes neither its algebra
isomorphism class nor its finite ramification.

### Theorem (lightweight Clifford-support obstruction)

Let `Gamma < PO(2r,1)`, with `r >= 2`, have adjoint trace field `K` and
ambient group `PO(q)` for an odd-rank form `q/K`.  If `Gamma` is
pseudo-arithmetic, then `K` is totally real and there is an elementary
abelian `2`-subgroup

```text
H <= Aut_Q(K),        k = K^H,
```

such that the projective real signatures have the admissible `H`-orbit
pattern and the finite ramification of `alpha(q)` satisfies split support:

- it is `H`-stable; and
- every ramified prime has trivial decomposition group in `H`.

Equivalently, the finite ramification is a union of complete fibers over
primes of `k` that split completely in `K/k`.

### Proof

Pseudo-arithmeticity supplies an admissible `k`-group whose scalar extension
is the ambient `K`-group.  In type `B`, functoriality of the Tits algebra gives

```text
alpha(q) = res(beta),        beta in Br(k)[2].
```

For `w | v`, the local invariant formula is

```text
inv_w(res(beta)) = [K_w : k_v] inv_v(beta).
```

The local degree in a Galois `2`-extension is a power of two.  If `alpha(q)`
ramifies at `w`, its invariant is `1/2`; hence the local degree must be odd,
and therefore equal to one.  Thus `v` splits completely.  All places above a
completely split `v` receive the same invariant, which gives the complete
fiber and `H`-stability assertions.  Admissibility supplies the real-signature
condition.

This proof uses neither determinant normalization nor ABHN, Chebotarev,
quadratic-form realization, or Hasse--Minkowski.

### Agreement contract

The lightweight test is the necessary half of the complete criterion above:

```text
full criterion accepts a candidate H  =>  lightweight test passes H,
lightweight test rejects H            =>  full criterion rejects H.
```

When the same real-signature screen is imposed and both nonsplit ramified
primes and incomplete ramified fibers are checked, the finite split-support
answers coincide.  A lightweight pass by itself is not a declaration of
pseudo-arithmeticity: another descent candidate or the real signatures may
still decide the question.  In particular, the trivial subgroup must be
retained; it has no finite-place obstruction and represents the
quasi-arithmetic candidate.

## 4. Pseudo-arithmeticity criterion

Let `Gamma < PO(n,1)` be a lattice with even `n >= 4`, adjoint trace field
`K`, and ambient group `PO(q)` for a rank `n+1` form `q/K`.  In even
hyperbolic dimension every field form is of quadratic-form (type `B`) type.

For every elementary abelian 2-subgroup

```text
H <= Aut_Q(K),        k = K^H,
```

test the following:

1. `K` is totally real;
2. the normalized signatures are constant on `H`-orbits, exactly one orbit
   has signature `(1,n)`, and every other orbit is positive definite;
3. the finite ramification set of `C^0(q#)` is `H`-stable and every ramified
   prime has trivial decomposition group in `H`.

### Corollary (finite obstruction)

`Gamma` is pseudo-arithmetic if and only if at least one such `H` passes all
three tests.  In particular, to prove that `Gamma` is not pseudo-arithmetic it
is enough to find, for every `H` surviving the signature test, either

- a ramified Clifford prime with nontrivial decomposition group; or
- an incomplete `H`-orbit of ramified primes over a completely split prime.

The trivial subgroup is allowed: it recovers the quasi-arithmetic case and
has no finite-place descent obstruction.

## 5. Smallest relevant countermodel

Take

```text
K = Q(sqrt(5)),
B = (-4-sqrt(5), -6)_K.
```

The quaternion algebra `B` ramifies at both real places and at the unique
primes above `2` and `3`.  Both rational primes are inert.  Its pure-quaternion
norm form is

```text
phi = <4+sqrt(5), 6, 24+6sqrt(5)>.
```

Set

```text
q = phi + H.
```

At both real embeddings, `q` has signature `(4,1)`.  Its determinant is
`-36(4+sqrt(5))^2`, so `q#` is represented by `-q`, and

```text
[C^0(q#)] = [B].
```

The signatures therefore pass perfectly, but the finite Clifford class
ramifies over the inert primes `2` and `3`.  The theorem proves that `q` does
not similarity-descend to `Q`.  Thus `PO(q)` is a rank-five, type-`B2`
non-pseudo-admissible algebraic group with the desired real local forms.

This particular obstructed algebraic group has not been realized here as a
lattice. That realization problem is now logically separate from the main
existence question: `notes/p11_6_8_non_total_family.md` gives actual
non-pseudo-arithmetic lattices by the simpler non-total-reality obstruction.

### Infinite supply

For any real quadratic `K/Q`, choose two finite inert rational primes and let
`B/K` ramify at the two real places and at the unique primes above the two
chosen inert primes.  The same pure-norm-plus-hyperbolic-plane construction
gives infinitely many rank-five algebraic countermodels.  The realization
problem, not the algebraic obstruction, is the remaining difficulty.

### Stabilization: there is no high-rank escape

The obstruction is not a low-dimensional accident.  Let `r5 = q#` be the
normalized rank-five form above and, for `s >= 0`, put

```text
r_(5+2s) = r5 + s<-1,-1>,
q_(5+2s) = -r_(5+2s).
```

Then `r_(5+2s)` has square determinant and signature `(1,4+2s)` at both real
places, while `q_(5+2s)` has Lorentzian signature `(4+2s,1)` and normalized
form `r_(5+2s)`.  If `H0 = (-1,-1)_K`, the rank-mod-eight Clifford formula
gives

```text
c(q_(5+2s)) = B       for s = 0,1 mod 4,
c(q_(5+2s)) = B + H0  for s = 2,3 mod 4.
```

But `H0` is restricted from `(-1,-1)_Q`.  Hence every stabilized class has
the same nonzero coset as `B` modulo `res Br(Q)[2]`, and its finite support
still contains the inert primes above `2` and `3`.  Thus there are explicit
non-pseudo-admissible algebraic groups in every even hyperbolic dimension
`n >= 4`.  More variables cannot force the split-support condition; any
positive theorem for lattices must use geometry, not quadratic-form rank
alone.  The four rank-mod-eight cases are checked by
`scripts/stable_obstruction.gp`.

## 6. Scope and caveats

- The rank must be odd for the canonical determinant normalization used here.
  This is exactly even hyperbolic dimension.
- Do not transplant the statement verbatim to type `D` (odd hyperbolic
  dimension): discriminant centers, Clifford components, nonsplit central
  simple algebras with orthogonal involution, and `D4` triality enter.
- A single candidate base field is not enough.  Non-pseudo-arithmeticity
  requires failure for every eligible elementary-2 subgroup of
  `Aut_Q(K)`.
- The ABHN, local-invariant, and Hasse--Minkowski ingredients are classical.
  The potentially new contribution is the similarity-sensitive normalized
  packaging, the complete-fibers-over-completely-split-primes formulation,
  and its application as an effective pseudo-arithmeticity obstruction.

## 7. Primary references

- V. Emery and O. Mila, *Hyperbolic manifolds and pseudo-arithmeticity*,
  [arXiv:1810.12837](https://arxiv.org/abs/1810.12837), especially the
  definitions in Section 1 and the Scharlau-transfer criterion in Section 4.
- J. Voight, [*Quaternion Algebras*](https://jvoight.github.io/quat-book.pdf),
  Chapter 14, Exercise 19, for the general odd-local-degree description of
  ramification after scalar extension.
- M. Belolipetsky, N. Bogachev, A. Kolpakov, and L. Slavich, *Subspace
  stabilisers in hyperbolic lattices*,
  [Proposition 3.15](https://doi.org/10.56994/JAMR.004.001.003), for the
  quadratic split-pair precursor in hyperbolic dimension three.
- R. Elman, T. Y. Lam, and A. Wadsworth, *Quadratic forms under
  multiquadratic extensions*,
  [DOI 10.1016/1385-7258(80)90017-7](https://doi.org/10.1016/1385-7258(80)90017-7).
- K. J. Becher, N. Grenier-Boley, and J.-P. Tignol, *Transfer of quadratic
  forms and of quaternion algebras over quadratic field extensions*,
  [arXiv:1610.06096](https://arxiv.org/abs/1610.06096).
- J. S. Milne, *Class Field Theory*,
  [course notes](https://www.jmilne.org/math/CourseNotes/CFT310.pdf), for the
  local invariant formula and the global Brauer exact sequence.
