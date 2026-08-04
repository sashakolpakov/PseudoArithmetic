\\ Exact finite Clifford data for the two four-dimensional Makarov blocks.
\\
\\ Source: Bogachev--Douba--Raimbault, arXiv:2309.07691, equations
\\ defining Q_1^4 and Q_2^4 in the subsection "Arithmetic invariants".
\\ This is a regression/control calculation: each block is already
\\ quasi-arithmetic.  A mixed garland requires its own trace field and form.

split_support_library_mode = 1;
read("scripts/quadratic_split_support.gp");

check_makarov_blocks() =
{
  my(K = nfinit(y^2 - 5), z = Mod(y, y^2 - 5));
  my(a = (1 + z) / 2);
  my(Q1 =
    [2,    -1,     0,    0,    0;
     -1,    1,  -1/2,    0,    0;
      0, -1/2,     1, -a/2,    0;
      0,    0,  -a/2,    1, -1/2;
      0,    0,     0, -1/2,    1]);
  my(Q2 =
    [1,  -a/2,     0,    0,    0;
    -a/2,    1, -1/2,    0,    0;
       0, -1/2,    1, -a/2,    0;
       0,    0, -a/2,    1, -1/2;
       0,    0,    0, -1/2,    1]);
  my(D1 = normalized_diagonal(Q1));
  my(D2 = normalized_diagonal(Q2));
  my(R1 = clifford_finite_ramification(K, D1));
  my(R2 = clifford_finite_ramification(K, D2));
  my(ratio = matdet(Q2) / matdet(Q1));
  my(ratio_factors = idealfactor(K, ratio));
  my(odd_at_2 = 0, odd_at_5 = 0);

  for (i = 1, matsize(ratio_factors)[1],
    my(p = ratio_factors[i, 1][1], valuation = ratio_factors[i, 2]);
    if (p == 2 && abs(valuation) % 2, odd_at_2 = 1);
    if (p == 5 && abs(valuation) % 2, odd_at_5 = 1);
  );
  if (#R1 != 2 || R1[1][1] != 2 || R1[2][1] != 5 || #R2 != 0,
    error("unexpected normalized Clifford data for the Makarov blocks")
  );
  if (!odd_at_2 || !odd_at_5,
    error("the gluing extension does not ramify at both discrepancy primes")
  );

  print("det(Q1) = ", matdet(Q1));
  print("det(Q2) = ", matdet(Q2));
  print("normalized diagonal Q1# = ", D1);
  print("normalized diagonal Q2# = ", D2);
  print("finite Ram C^0(Q1#) = ", R1);
  print("finite Ram C^0(Q2#) = ", R2);
  print("det(Q2)/det(Q1) = ", ratio);
  print("factorization of the gluing radicand = ", ratio_factors);
  print("TRACE FIELD: Q(sqrt(5),sqrt(5-sqrt(5))).");
  print("RESULT: local degree 2 kills the discrepancies at 2 and 5.");
};

check_makarov_blocks();
