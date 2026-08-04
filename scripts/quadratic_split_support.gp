\\ Exact split-support test for an odd-rank form over a quadratic field.
\\
\\ The core routine computes the finite ramification of the even Clifford
\\ class from diagonal Hasse symbols and the universal dimension-mod-8
\\ correction (Lam, Introduction to Quadratic Forms over Fields, III.3.20).
\\ It examines the dyadic primes and every prime occurring in the fractional
\\ principal ideal of an individual coefficient.  Factoring only the product
\\ (or its norm) is not exact: valuations can cancel.
\\
\\ The local support routine handles a nontrivial multiquadratic K/Q; the
\\ quadratic wrapper supplies the smallest useful lattice screen.  The full
\\ criterion for multiquadratic K/k is recorded in
\\ notes/split_support_criterion.md.

diagonalize_symmetric(M) =
{
  my(A = M, diagonal = List());
  while(matsize(A)[1] > 0,
    my(n = matsize(A)[1], pivot_index = 0);
    for (i = 1, n,
      if (!pivot_index && A[i, i] != 0, pivot_index = i);
    );

    \\ If every diagonal entry vanishes, replace one basis vector e_i by
    \\ e_i+e_j for a nonzero off-diagonal entry.  This creates the pivot
    \\ 2*A[i,j] without changing the represented form.
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

normalized_diagonal(M) =
{
  my(delta = matdet(M), diagonal = diagonalize_symmetric(M));
  return(vector(#diagonal, i, diagonal[i] / delta));
};

\\ The Clifford class of an odd-dimensional diagonal form.  Return +1 when
\\ split and -1 when ramified at the finite prime P.  The Hasse invariant is
\\ the product of (a_i,a_j); the correction below converts it to [C^0(q)].
clifford_local_sign(K, a, P) =
{
  my(n = #a, hasse = 1, determinant = prod(i = 1, n, a[i]));
  my(residue = n % 8, correction = 1);
  if (n % 2 == 0, error("the form must have odd rank"));

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

rational_support_primes(K, a) =
{
  my(result = List());
  listput(result, 2);
  for (i = 1, #a,
    if (a[i] == 0, error("the diagonal form is singular"));
    my(factors = idealfactor(K, a[i]));
    for (j = 1, matsize(factors)[1],
      listput(result, factors[j, 1][1]);
    );
  );
  return(Set(Vec(result)));
};

clifford_finite_ramification(K, a) =
{
  my(rational_primes = rational_support_primes(K, a));
  my(ramified = List());
  if (#a % 2 == 0, error("the form must have odd rank"));

  for (i = 1, #rational_primes,
    my(decomposition = idealprimedec(K, rational_primes[i]));
    for (j = 1, #decomposition,
      if (clifford_local_sign(K, a, decomposition[j]) == -1,
        listput(ramified, decomposition[j]);
      );
    );
  );
  return(Vec(ramified));
};

\\ Return [bad_non_split_places, bad_incomplete_split_fibres].
\\ For a nontrivial multiquadratic K/Q this is the exact finite obstruction
\\ to belonging to res_{K/Q} Br(Q)[2].
split_support_over_Q_obstructions(K, ramified) =
{
  my(degree = poldegree(K.pol));
  my(bad_local_degree = List(), bad_fibre = List());
  if (degree <= 1, error("a nontrivial extension K/Q is required"));

  for (i = 1, #ramified,
    my(place = ramified[i]);
    if (type(place) != "t_VEC",
      error("unexpected PARI prime-ideal representation")
    );
    my(p = place[1], decomposition = idealprimedec(K, p));
    my(ramified_count = 0, all_local_degrees_one = 1);
    for (j = 1, #decomposition,
      my(P = decomposition[j]);
      if (P[3] * P[4] != 1, all_local_degrees_one = 0);
      for (k = 1, #ramified,
        if (ramified[k] == P, ramified_count++);
      );
    );
    if (!all_local_degrees_one,
      listput(bad_local_degree, place),
      if (ramified_count != #decomposition,
        listput(bad_fibre, [p, ramified_count, #decomposition]);
      );
    );
  );
  return([Vec(bad_local_degree), Vec(bad_fibre)]);
};

quadratic_split_support_obstructions(K, ramified) =
{
  if (poldegree(K.pol) != 2,
    error("quadratic_split_support_obstructions requires [K:Q]=2")
  );
  return(split_support_over_Q_obstructions(K, ramified));
};

\\ Recovered rank-five countermodel over Q(sqrt(5)).
verify_recovered_countermodel() =
{
  my(K = nfinit(y^2 - 5));

  \\ Regression for the support bug that motivated individual ideal
  \\ factorization: the valuations of y and 1/y cancel in their product.
  my(cancellation_support = rational_support_primes(K, [y, y/5, 1]));
  if (!setsearch(cancellation_support, 5),
    error("coefficient support lost a prime through valuation cancellation")
  );

  \\ q=phi+H has determinant -36(4+y)^2.  Its normalized form q# is
  \\ represented by -q.  The displayed integral diagonal is exactly -q.
  my(q_normalized = [-4-y, -6, -24-6*y, -1, 1]);
  my(ramified = clifford_finite_ramification(K, q_normalized));
  my(expected = alginit(K, [-4-y, -6]));
  my(expected_places = algramifiedplaces(expected));
  my(expected_finite = List());
  my(obstructions = quadratic_split_support_obstructions(K, ramified));

  for (i = 1, #expected_places,
    if (type(expected_places[i]) == "t_VEC",
      listput(expected_finite, expected_places[i]);
    );
  );

  if (#ramified != 2 || ramified[1][1] != 2 || ramified[2][1] != 3,
    error("computed C^0(q#) has unexpected finite ramification")
  );
  for (i = 1, #ramified,
    if (alghasse(expected, ramified[i]) != 1/2,
      error("computed C^0(q#) does not match the expected quaternion class")
    );
  );
  if (#expected_finite != #ramified,
    error("the checker missed a finite ramified place of the quaternion")
  );
  if (#obstructions[1] != 2 || #obstructions[2] != 0,
    error("expected exactly the inert-prime obstructions above 2 and 3")
  );

  print("C^0(q#) finite ramification = ", ramified);
  print("bad non-split finite places = ", obstructions[1]);
  print("bad incomplete split fibres = ", obstructions[2]);
  print("RESULT: q does not similarity-descend from Q(sqrt(5)) to Q.");
};

run_default_selftest() =
{
  if (type(split_support_library_mode) == "t_INT",
    if (!split_support_library_mode, verify_recovered_countermodel()),
    verify_recovered_countermodel()
  );
};

run_default_selftest();
