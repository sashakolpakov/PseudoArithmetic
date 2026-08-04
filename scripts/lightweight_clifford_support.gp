\\ Independent finite-place obstruction from the type-B Tits algebra.
\\
\\ This file deliberately does not read quadratic_split_support.gp and never
\\ constructs the determinant-normalized form q#.  In odd rank the Brauer
\\ class of C^0(q) is invariant under similarity, so its finite ramification
\\ can be computed directly from any diagonalization of the supplied Gram
\\ matrix.  For an odd-dimensional diagonal form <a_1,...,a_n>, the local
\\ Clifford invariant is its Hasse invariant times the standard
\\ dimension-mod-8 correction.
\\
\\ The output records a finite place by [p,j,e,f], where it is the j-th
\\ prime in idealprimedec(K,p), with ramification index e and residue degree
\\ f.  Thus e*f is its local degree.  This is enough to make every negative
\\ witness independently checkable with PARI.

lw_diagonalize_symmetric(M) =
{
  my(A = M, diagonal = List());
  while (matsize(A)[1] > 0,
    my(n = matsize(A)[1], pivot_index = 0);
    for (i = 1, n,
      if (!pivot_index && A[i, i] != 0, pivot_index = i);
    );

    if (!pivot_index,
      my(first = 0, second = 0);
      for (i = 1, n,
        for (j = i + 1, n,
          if (!first && A[i, j] != 0, first = i; second = j);
        );
      );
      if (!first, error("the symmetric matrix is singular"));
      my(change = matid(n));
      change[second, first] = 1;
      A = change~ * A * change;
      pivot_index = first;
    );

    my(pivot = A[pivot_index, pivot_index]);
    listput(diagonal, pivot);
    if (n == 1, break);
    my(others = vector(n - 1, i, if (i < pivot_index, i, i + 1)));
    my(column = vecextract(A, others, [pivot_index]));
    A = vecextract(A, others, others) - column * column~ / pivot;
  );
  return(Vec(diagonal));
};

\\ Return +1 when C^0(<a>) is split at P and -1 when it is ramified.
lw_even_clifford_local_sign(K, a, P) =
{
  my(n = #a, hasse = 1, determinant = prod(i = 1, n, a[i]));
  my(residue = n % 8, correction = 1);
  if (n % 2 == 0, error("the type-B test requires odd rank"));

  for (i = 1, n,
    for (j = i + 1, n,
      hasse *= nfhilbert(K, a[i], a[j], P);
    );
  );
  if (residue == 3, correction = nfhilbert(K, -1, -determinant, P));
  if (residue == 5, correction = nfhilbert(K, -1, -1, P));
  if (residue == 7, correction = nfhilbert(K, -1, determinant, P));
  return(hasse * correction);
};

\\ It is essential to factor the coefficients separately: factoring only
\\ their product can lose a prime when positive and negative valuations
\\ cancel.
lw_candidate_rational_primes(K, diagonal) =
{
  my(result = List());
  listput(result, 2);
  for (i = 1, #diagonal,
    if (diagonal[i] == 0, error("the diagonal form is singular"));
    my(factors = idealfactor(K, diagonal[i]));
    for (j = 1, matsize(factors)[1],
      listput(result, factors[j, 1][1]);
    );
  );
  return(Set(Vec(result)));
};

lw_finite_ramification(K, diagonal) =
{
  my(rational_primes = lw_candidate_rational_primes(K, diagonal));
  my(records = List());
  if (#diagonal % 2 == 0, error("the type-B test requires odd rank"));

  for (i = 1, #rational_primes,
    my(p = rational_primes[i], decomposition = idealprimedec(K, p));
    for (j = 1, #decomposition,
      my(P = decomposition[j]);
      if (lw_even_clifford_local_sign(K, diagonal, P) == -1,
        listput(records, [p, j, P[3], P[4]]);
      );
    );
  );
  return(Vec(records));
};

\\ Necessary condition for a 2-torsion Brauer class over a nontrivial
\\ multiquadratic K/Q to be restricted from Q.  Return
\\ [nonsplit_place_witnesses, incomplete_split_fibre_witnesses].
\\ A nonsplit record is [p,j,e,f,e*f].  An incomplete-fibre record is
\\ [p,number_ramified,number_above_p,ramified_prime_indices].
lw_split_support_witnesses_over_Q(K, ramified_records) =
{
  my(degree = poldegree(K.pol));
  my(bad_nonsplit = List(), bad_incomplete = List());
  my(rational_primes = Set(vector(#ramified_records, i,
    ramified_records[i][1])));
  if (degree <= 1, error("a nontrivial extension K/Q is required"));

  for (i = 1, #ramified_records,
    my(record = ramified_records[i], local_degree = record[3] * record[4]);
    if (local_degree != 1,
      listput(bad_nonsplit,
        [record[1], record[2], record[3], record[4], local_degree]);
    );
  );

  for (i = 1, #rational_primes,
    my(p = rational_primes[i], decomposition = idealprimedec(K, p));
    my(all_split = 1, indices = List());
    for (j = 1, #decomposition,
      if (decomposition[j][3] * decomposition[j][4] != 1,
        all_split = 0);
    );
    for (j = 1, #ramified_records,
      if (ramified_records[j][1] == p,
        listput(indices, ramified_records[j][2]));
    );
    if (all_split && #indices != #decomposition,
      listput(bad_incomplete, [p, #indices, #decomposition, Vec(indices)]);
    );
  );
  return([Vec(bad_nonsplit), Vec(bad_incomplete)]);
};

lw_verify_selftests() =
{
  my(K = nfinit(y^2 - 5), z = Mod(y, y^2 - 5));

  \\ This is q itself, not q#=-q, in the recovered rank-five
  \\ countermodel.  Its two ramified finite places lie over inert primes.
  my(q = [4+z, 6, 24+6*z, 1, -1]);
  my(direct = lw_finite_ramification(K, q));
  my(witnesses = lw_split_support_witnesses_over_Q(K, direct));
  if (direct != [[2, 1, 1, 2], [3, 1, 1, 2]],
    error("unexpected direct Clifford support for the countermodel"));
  if (#witnesses[1] != 2 || #witnesses[2] != 0,
    error("the inert-prime negative test failed"));

  \\ A non-square similarity factor is a regression against accidentally
  \\ reintroducing determinant normalization.
  my(scale = 2 + z);
  my(scaled = lw_finite_ramification(K, vector(#q, i, scale*q[i])));
  if (scaled != direct,
    error("direct C^0 support changed under an odd-rank similarity"));

  \\ Exercise the other failure mode independently of Clifford arithmetic:
  \\ 11 splits in Q(sqrt(5)), and one of its two primes is not a full fibre.
  my(over_11 = idealprimedec(K, 11));
  my(fake_half_fibre = [[11, 1, over_11[1][3], over_11[1][4]]]);
  my(half_witness = lw_split_support_witnesses_over_Q(K, fake_half_fibre));
  if (#over_11 != 2 || #half_witness[1] != 0 || #half_witness[2] != 1,
    error("the incomplete split-fibre regression failed"));

  \\ A pass must mean complete split support, not empty support.  This form
  \\ ramifies at both primes over the split prime 11 and therefore passes.
  my(complete_11 = lw_finite_ramification(K, [1, 11, 11, 1, -1]));
  my(complete_witness =
    lw_split_support_witnesses_over_Q(K, complete_11));
  if (#complete_11 != 2 || complete_11[1][1] != 11 ||
      complete_11[2][1] != 11 || #complete_witness[1] != 0 ||
      #complete_witness[2] != 0,
    error("the nonempty complete split-fibre regression failed"));

  \\ Direct, unnormalized versions of the rank 5,7,9,11 stabilization
  \\ controls must retain exactly the inert-prime witnesses at 2 and 3.
  for (stabilization = 0, 3,
    my(q_stable = concat(q, vector(2*stabilization, i, 1)));
    my(stable_ramification = lw_finite_ramification(K, q_stable));
    my(stable_witnesses =
      lw_split_support_witnesses_over_Q(K, stable_ramification));
    if (stable_ramification != [[2, 1, 1, 2], [3, 1, 1, 2]] ||
        #stable_witnesses[1] != 2 || #stable_witnesses[2] != 0,
      error("direct stabilization regression failed in rank ", #q_stable));
  );

  \\ P_{4,3} is a positive control from the earlier normalized computation.
  \\ Feed its unnormalized Vinberg form directly to this implementation.
  my(K43 = nfinit(t^2 - 3), z3 = Mod(t, t^2 - 3));
  my(Q43 =
    [1,              0, 24 + 12*z3, 1/2,        0;
     0, 576 + 288*z3,            0,   0, 6 + 6*z3;
     24 + 12*z3,     0, 48 + 24*z3,   0,        0;
     1/2,           0,           0,   1,     1/2;
     0,        6 + 6*z3,           0, 1/2,        1]);
  my(p43 = lw_finite_ramification(K43, lw_diagonalize_symmetric(Q43)));
  if (#p43 != 0,
    error("the direct P_{4,3} result disagrees with the normalized result"));

  print("COUNTERMODEL_RAMIFIED=[2,3]");
  print("COUNTERMODEL_WITNESSES=", witnesses[1]);
  print("SIMILARITY_REGRESSION=PASS");
  print("INCOMPLETE_FIBRE_REGRESSION=", half_witness[2]);
  print("NONEMPTY_COMPLETE_FIBRE_REGRESSION=PASS");
  print("DIRECT_STABILIZATION_RANKS_5_7_9_11=PASS");
  print("P43_NORMALIZED_DIRECT_AGREEMENT=PASS");
  print("RESULT=PASS");
};

lw_run_default_selftest() =
{
  if (type(lightweight_clifford_library_mode) == "t_INT",
    if (!lightweight_clifford_library_mode, lw_verify_selftests()),
    lw_verify_selftests()
  );
};

lw_run_default_selftest();
