\\ Exact rank-mod-eight regression for the stabilized split-support
\\ countermodels in notes/split_support_criterion.md.

split_support_library_mode = 1;
read("scripts/quadratic_split_support.gp");

verify_stabilization() =
{
  my(K = nfinit(y^2 - 5));
  my(r5 = [-4-y, -6, -24-6*y, -1, 1]);

  for (s = 0, 3,
    my(r = concat(r5, vector(2*s, i, -1)));
    my(ramified = clifford_finite_ramification(K, r));
    my(obstructions = quadratic_split_support_obstructions(K, ramified));
    my(signatures = vector(2, place,
      my(positive = 0, negative = 0);
      for (i = 1, #r,
        my(sign = nfeltsign(K, r[i])[place]);
        if (sign == 1, positive++, negative++);
      );
      [positive, negative]
    ));

    if (signatures != [[1, #r-1], [1, #r-1]],
      error("unexpected stabilized signatures at rank ", #r)
    );
    if (#ramified != 2 || ramified[1][1] != 2 || ramified[2][1] != 3,
      error("unexpected finite Clifford support at rank ", #r)
    );
    if (#obstructions[1] != 2 || #obstructions[2] != 0,
      error("the inert-prime obstruction disappeared at rank ", #r)
    );

    print("rank ", #r, ": signatures=", signatures,
          ", finite ramification rational primes=[",
          ramified[1][1], ",", ramified[2][1], "]");
  );
  print("RESULT: the obstruction survives in ranks 5, 7, 9, and 11, hence periodically in every odd rank >= 5.");
};

verify_stabilization();
