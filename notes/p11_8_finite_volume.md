# Independent finite-volume validation of `P_{11,8}`

## Outcome

The Ma--Zheng Coxeter matrix `2232ab523242220442222` realizes a
noncompact finite-volume Coxeter polytope in hyperbolic dimension four.  It
has f-vector

\[
(f_0,f_1,f_2,f_3,f_4)=(10,21,18,7,1)
\]

and exactly two ideal vertices.  This was verified both by a small exact
principal-submatrix computation and independently by CoxIter.

The exact calculation is separate from the trace-field certificate:
[`scripts/p11_8_finite_volume.py`](../scripts/p11_8_finite_volume.py) writes
[`results/p11_8_finite_volume_validation.json`](../results/p11_8_finite_volume_validation.json).

## Source incidence

HCPdm's `polytopeDATA/pi47.txt`, line 17, gives the following ten vertices
of `P_11` (facet indices are zero-based):

\[
\begin{aligned}
&\{2,3,4,5,6\},\\
&\{1,4,5,6\},\{1,3,5,6\},\{1,3,4,6\},
  \{1,2,4,5\},\{1,2,3,5\},\\
&\{0,2,3,4\},\{0,1,3,4\},\{0,1,2,4\},\{0,1,2,3\}.
\end{aligned}
\]

The source file has SHA-256
`05bd3d7eddd62598c1446ec562aa6ef63d85d0142e46cac2a550a1d7b054f293`.
The independent enumeration below recovers exactly these ten sets as the
maximal elliptic-or-parabolic principal subdiagrams; the source incidence is
therefore checked rather than simply assumed.

## Exact local checks

Let `G` be the unit-normal Gram matrix.  Exact Gaussian elimination gives
rank five.  The principal block on facets `0,1,2,3` is positive definite,
while

\[
 \det G_{\{0,1,2,3,4\}}=-\frac{1+\sqrt5}{32}<0.
\]

Thus the exact inertia of the full seven-by-seven matrix is `(4,1,2)`.
All off-diagonal entries are nonpositive and the diagram is connected, so
Vinberg's existence theorem produces the corresponding acute-angled
polytope in `H^4`.

Eight vertex matrices are elliptic of rank four.  Their facet sets and
determinants are:

| facets | determinant |
|---|---:|
| `{0,1,2,3}` | `3(5-sqrt(5))/32` |
| `{0,1,2,4}`, `{1,2,4,5}` | `(3-sqrt(5))/8` |
| `{0,1,3,4}` | `1/16` |
| `{0,2,3,4}`, `{1,3,5,6}`, `{1,4,5,6}` | `1/4` |
| `{1,2,3,5}` | `(5-sqrt(5))/16` |

The JSON certificate records every leading principal minor; Sylvester's
criterion proves positivity exactly.

The remaining two vertices are parabolic of rank three:

- `{1,3,4,6}` is connected affine `C_3`, with positive null vector
  `(sqrt(2),1,sqrt(2),1)` in the displayed facet order.
- The nonsimple vertex `{2,3,4,5,6}` splits orthogonally as affine
  `A_1` on `{2,6}` and affine `C_2` on `{3,4,5}`.  Its matrix has rank
  three and nullity two, exactly the Euclidean triangular-prism link.

An exhaustive exact check of all 127 nonempty principal submatrices finds
no other maximal elliptic or parabolic subdiagram.

## Concise finite-volume proof

The elliptic rank-three subdiagrams are precisely the edges of this
four-polytope.  There are 21.  For each one, the verifier enumerates the
maximal elliptic/parabolic supersets and finds exactly two endpoints.  Nine
vertices have four incident edges and the nonsimple prism-link vertex has
six.

Vinberg's finite-volume edge criterion now applies: an acute-angled
polytope containing a vertex has finite volume exactly when each edge from
an ordinary or ideal vertex has one other ordinary or ideal endpoint.
Hence `P_{11,8}` has finite volume.  Since the two parabolic maximal
subdiagrams above exist, it is noncompact with exactly two cusps.

## Independent CoxIter check

The pinned input is
[`results/p11_8_finite_volume.coxiter`](../results/p11_8_finite_volume.coxiter).
CoxIter reports:

```text
Cocompact: no
Finite covolume: yes
f-vector: (10, 21, 18, 7, 1)
Number of vertices at infinity: 2
Euler characteristic: 19/1152
Covolume: pi^2 * 19/864
```

The complete captured output is
[`results/p11_8_coxiter_validation.output`](../results/p11_8_coxiter_validation.output),
with build provenance in
[`results/p11_8_coxiter_provenance.json`](../results/p11_8_coxiter_provenance.json).
The check used official CoxIter version 1.3 source at commit
`b800be48d8240fbabd2d1c9542e61054584ad7fe`; the downloaded source archive
had SHA-256
`ad0635f5c2d35a4a892c1737e26140c190a5906eaa6125b6f1999abc718a5c6c`,
and the arm64 executable used for the run had SHA-256
`cad0b97caa8ab1dc25b86dff65252e1869382ed079d6ec949dbe006b3588f957`.
It was built in release mode with one compile job.
