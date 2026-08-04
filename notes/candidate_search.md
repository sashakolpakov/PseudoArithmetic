# Candidate search ledger

Status: exact calculations completed 4 August 2026. A pass means that the
ambient group is proved pseudo-admissible; it is not merely a failure to find
an obstruction. The first three fully resolved two-distance cases below are
counterexamples.

## Makarov's shortest mixed four-dimensional garland

For the blocks of Bogachev--Douba--Raimbault, put

```text
k = Q(sqrt(5)).
```

Their exact rank-five forms `Q1` and `Q2` have normalized finite Clifford
ramification

```text
Ram_f C^0(Q1#) = {p_2, p_5},
Ram_f C^0(Q2#) = empty.
```

The shortest mixed garland has trace field

```text
K = Q(sqrt(5), sqrt(5-sqrt(5))).
```

Indeed, the common gluing hyperplane is the restriction to the final four
coordinates, and the ratio of the two normal coefficients is, modulo squares,

```text
det(Q2)/det(Q1) = (5-sqrt(5))/5.
```

Its fractional ideal has odd valuation at the primes over both `2` and `5`.
Consequently those primes have local degree two in `K/k`, and restriction
kills both normalized Clifford discrepancies.  Mila's trace-field theorem
identifies this quadratic field with the exact adjoint trace field of the
gluing.  Thus the mixed garland is non-quasi-arithmetic but pseudo-arithmetic.
The certificate is `scripts/makarov_block_check.gp`.

## Ma--Zheng seven-facet census in H^4

The 331 Coxeter vectors divide by number of dotted-edge variables as follows:

| variables | cases | status |
|---:|---:|---|
| 0 | 19 | all have an explicit rational rank-five ambient restriction |
| 1 | 76 | all exactly classified below |
| 2 | 155 | 3 proved non-pseudo-arithmetic; 152 not yet screened |
| 3 | 81 | not yet screened |

For the 76 one-distance cases, the worker derives the distance from a
rank-five determinant, constructs a Vinberg cyclic-product form, determines
the trace field, diagonalizes a rank-five restriction exactly, and uses PARI
`nfeltsign` at every real embedding.  It invokes the finite Clifford checker
only for constant-Lorentzian nonrational restrictions.  The exact outcome is:

| certificate | count |
|---|---:|
| rational ambient restriction | 31 |
| quadratic descent to `Q` by normalized Clifford support | 26 |
| degree 4 or 8 multiquadratic descent to `Q` | 11 |
| quasi-arithmetic signature pattern | 8 |
| split-support violation | **0** |

All 37 nontrivial descent cases have exactly certified constant Lorentzian
signature at every real embedding and empty finite ramification of
`C^0(q#)`.  For each of the eleven higher-degree fields, PARI finds as many
automorphisms as the field degree and proves that every automorphism squares
to the identity.  This certifies an elementary-abelian-2 Galois group, rather
than merely Galoisness.  The separate cyclic-quartic regression in
`scripts/elementary2_field_selftest.gp` verifies that the test rejects a
degree-four `C4` field.

The 31 rational restrictions still require the trace field to be
multiquadratic over `Q`: because the rational form is Lorentzian at every
embedding, no larger totally real admissible base field is possible.  This is
now checked exactly too.  The 19 zero-distance trace fields are explicitly
contained in the totally real elementary-2 field
`Q(sqrt(2),sqrt(3),sqrt(5))`.

Together with the 19 zero-distance cases, this gives 95 exact positive
pseudo-arithmeticity certificates in the census.  The result is reproducible
with:

```text
python3 scripts/census_no_distance_scan.py /path/to/hcp47.tex \
  --output results/no_distance_certificates.jsonl
python3 scripts/census_quadratic_clifford.py /path/to/hcp47.tex --all \
  --output results/one_distance_certificates.jsonl
```

Each `--all` calculation launches one fresh worker per Coxeter vector and one
fresh GP process per Clifford computation.  No symbolic number fields are
retained between cases.  The durable per-case outputs are
`results/no_distance_certificates.jsonl` and
`results/one_distance_certificates.jsonl`; every line is flushed and synced
before the next worker starts.  Regeneration writes to a recoverable
`.partial` checkpoint and atomically replaces the preceding complete log only
after the final summary is synced.  `results/one_distance_summary.json` also
records SHA-256 hashes for both logs, the parsed `hcp47.tex`, and the arXiv
source archive.

### Two-distance breakthrough

The consecutive cases `P_{11,6}`, `P_{11,7}`, and `P_{11,8}` are exact
non-pseudo-arithmetic lattices. They share the dotted distance

```text
a = 1/2 sqrt(7 + sqrt(5) + 2 sqrt(2 + 2 sqrt(5))).
```

For `A=2G`, two common Cartan cycles are

```text
c_12  = (3 + sqrt(5))/2,
c_035 = -2 sqrt(2) a.
```

Hence every adjoint trace field contains `s=sqrt(5)` and
`u=sqrt(2)*a`. The exact rank equation becomes

```text
(s-1)u^2 + 2(s-3)u + s-7 = 0.
```

Its discriminant `8(1+s)` becomes negative under `s -> -s`, so the
adjoint trace field has a complex place. This violates the necessary total
reality of every pseudo-arithmetic trace field. The theorem proof and exact
artifacts are recorded in `notes/p11_6_8_non_total_family.md`.

Thus 98 of the 331 cases are now exactly resolved: 95 positive and 3
negative. Existence no longer depends on completing the remaining census.

## Three-dimensional laboratory

For a hyperbolic three-manifold the canonical object is the invariant trace
field together with the invariant quaternion algebra, not generally a
rank-four Lorentz form.  Its trace-zero reduced norm is a canonical ternary
form, and the same ABHN split-support obstruction gives many failures of a
natural three-dimensional quaternion-pseudo analogue.  Concrete cusped and
closed examples, and the precise distinction from the `n > 3` problem, are
recorded in `notes/three_dimensional_analogue.md`.

## Other recovered exact controls

The recovered Scharlau-transfer certificates prove pseudo-arithmeticity for
the recent non-quasi seeds `P_{16,5}`, `P_{16,1}`, and `P_{39,3}`.  They give,
respectively, `5H`, `5H`, and `6H` after the stated transfers.  These are
positive controls rather than obstruction candidates.

## Optional bounded continuation

The remaining 152 two-distance cases can determine how common the new
phenomenon is. The safe order is:

1. stream one vector in a fresh process;
2. derive both distances from two independent rank conditions;
3. retain one nonsingular rank-five cyclic-product restriction;
4. test total reality of the cyclic-product field first and stop on any
   complex place;
5. discard quasi-arithmetic signature patterns immediately;
6. compute only primes in the individual coefficient ideals and the dyadic
   fibers;
7. stop and save a certificate at the first non-split or incomplete ramified
   fiber.

The signature filter should make this substantially cheaper than a blind
Clifford sweep.
