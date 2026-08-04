# Detailed whole-field certificate for $P_{11,8}$

The two-cycle proof for the full family $P_{11,6}$--$P_{11,8}$ is in
`notes/p11_6_8_non_total_family.md`. This appendix records the stronger
calculation identifying the entire adjoint trace field of $P_{11,8}$.

The Ma--Zheng row has two cusps, volume $19\pi^2/864$, and Coxeter vector

```text
2232ab 52324 2220 442 22 2.
```

Put $s=\sqrt5$ and $r=\sqrt2$. Its two dotted Gram entries are

$$
a=\frac12\sqrt{7+s+2\sqrt{2+2s}},
$$

$$
b=\frac14\left(2+3r+2s+\sqrt{10}
       +2\sqrt{19+14r+9s+6\sqrt{10}}\right).
$$

They are the unique roots greater than one of the isolated rank equations

$$
2(s-1)a^2+2r(s-3)a+s-7=0,
$$

$$
2(s-1)b^2-2(4+r(1+s))b-(7+s+2r(1+s))=0.
$$

Exact calculation gives all seven principal $6\times6$ minors zero, Gram
rank five, and

$$
\det G_{\{0,1,2,3,4\}}=-\frac{1+s}{32}\ne0.
$$

The leading principal minors of this block have signs $+,+,+,+,-$, so the
full Gram inertia is exactly $(4,1,2)$.

## Exact Vinberg field

Let $A=2G$, and let $K$ be the Vinberg cyclic-product field, equivalently the
adjoint trace field of the reflection lattice. Four cycles are

$$
c_{12}=\frac{3+s}{2},\qquad
c_{126}=-r(1+s),\qquad
c_{035}=-2ra,\qquad
c_{03416}=-4b.
$$

They recover $s,r,a,b$, respectively. Conversely, every cyclic product is
formed from entries in $\mathbf Q(s,r,a,b)$. Therefore

$$
K=\mathbf Q(s,r,a,b).
$$

In particular, $u=ra\in K$ and

$$
(s-1)u^2+2(s-3)u+s-7=0.
$$

Its discriminant over $\mathbf Q(s)$ is $8(1+s)$, which becomes
$8(1-s)<0$ under $s\mapsto-s$. Hence $K$ is not totally real and the
lattice is not pseudo-arithmetic.

## Independent primitive-element check

The element

$$
w=2(r+a+b)
$$

generates $K$. Its minimal polynomial is

$$
\begin{aligned}
p(x)={}&x^8-8x^7-252x^6-1392x^5-3524x^4\\
       &-5280x^3-5712x^2-3968x-1136.
\end{aligned}
$$

PARI/GP certifies irreducibility, signature $(r_1,r_2)=(4,2)$, and field
discriminant $40960000=2^{16}5^4$. Exact power-basis coordinates for all four
raw generators certify that this is the full cyclic-product field, not an
artifact of Gram-matrix rescaling.

The reproducer is `scripts/p11_8_non_total_trace.py`, with durable output in
`results/p11_8_non_total_trace_certificate.json`. The independent generic
Vinberg-form route is `scripts/p118_trace_field.py`, with output in
`results/p118_trace_field_certificate.json`.

Source provenance:

- `hcp47.tex` line 1604, SHA-256
  `0017931637f017641d4935450cc2a07d070866d9c749443d9e3ede9f3a39f003`;
- source tarball SHA-256
  `13f2d88ad740669f35b4d1859e68da4d489a1223b5ff5a99e128eaa71838234f`.
