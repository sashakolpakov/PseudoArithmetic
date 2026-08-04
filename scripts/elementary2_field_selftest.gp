\\ Exact regression for the trace-field condition used by the census checker.
\\ Galois of degree 4 is not enough: the automorphism group could be C4.

elementary2_certificate(P) =
{
  my(K = nfinit(P), z = Mod(y, P), A = nfgaloisconj(K));
  my(involutive = vector(#A, i,
    lift(nfgaloisapply(K, A[i], Mod(A[i], P)) - z) == 0
  ));
  return([#A == poldegree(P) && vecmin(involutive), #A, involutive]);
};

run_elementary2_selftest() =
{
  my(cyclic_quartic = elementary2_certificate(y^4 - 4*y^2 + 2));
  my(biquadratic = elementary2_certificate(y^4 - 10*y^2 + 1));

  if (cyclic_quartic[1] || cyclic_quartic[2] != 4,
    error("the cyclic quartic regression was falsely accepted")
  );
  if (!biquadratic[1] || biquadratic[2] != 4,
    error("the biquadratic regression was falsely rejected")
  );

  print("cyclic quartic: count=", cyclic_quartic[2],
        ", involutive=", cyclic_quartic[3], ", elementary-2=0");
  print("biquadratic: count=", biquadratic[2],
        ", involutive=", biquadratic[3], ", elementary-2=1");
};

run_elementary2_selftest();
