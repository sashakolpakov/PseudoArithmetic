\\ Exact normalized Clifford test for Ma--Zheng's P_{4,3}.
\\
\\ The one-distance scanner derives distance 3+sqrt(3), Vinberg trace
\\ field Q(sqrt(3)), and the rank-five cyclic-product matrix below.
\\ Both real embeddings have signature (4,1), so finite split support is
\\ the remaining test for similarity descent to Q.

split_support_library_mode = 1;
read("scripts/quadratic_split_support.gp");

check_p43() =
{
  my(K = nfinit(y^2 - 3), z = Mod(y, y^2 - 3));
  my(Q =
    [1,             0, 24 + 12*z, 1/2,       0;
     0, 576 + 288*z,           0,   0, 6 + 6*z;
     24 + 12*z,     0, 48 + 24*z,   0,       0;
     1/2,           0,           0,   1,     1/2;
     0,       6 + 6*z,           0, 1/2,       1]);
  my(D = normalized_diagonal(Q));
  my(R = clifford_finite_ramification(K, D));
  my(O = quadratic_split_support_obstructions(K, R));

  print("P_{4,3}: det(Q) = ", matdet(Q));
  print("P_{4,3}: normalized diagonal = ", D);
  print("P_{4,3}: finite Ram C^0(Q#) = ", R);
  print("P_{4,3}: bad non-split places = ", O[1]);
  print("P_{4,3}: bad incomplete split fibres = ", O[2]);
  if (#O[1] || #O[2],
    print("RESULT: finite split support obstructs pseudo-arithmeticity."),
    print("RESULT: the normalized Clifford class descends to Q.")
  );
};

check_p43();
