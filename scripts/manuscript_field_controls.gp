\\ Exact positive and negative controls for the full-field assertions.
auditcheck(c, message) = if(!c, error(message));

audit() = {
  my(p = x^8-8*x^7-252*x^6-1392*x^5-3524*x^4-5280*x^3-5712*x^2-3968*x-1136);
  my(q = x^8-156*x^7+3498*x^6-36920*x^5+233027*x^4-929928*x^3+2312714*x^2-3302756*x+2050849);
  auditcheck(polisirreducible(p), "primitive polynomial is reducible");
  auditcheck(nfinit(p).sign == [4,2], "incorrect full-field signature");
  auditcheck(nfdisc(p) == 40960000, "incorrect field discriminant");
  auditcheck(nfisisom(p,q) != 0, "the two primitive routes give nonisomorphic fields");
  auditcheck(!polisirreducible(p*(x-1)), "reducibility control failed");
  auditcheck(nfinit(x^2-5).sign == [2,0], "totally real control failed");
  auditcheck(nfinit(x^2+1).sign == [0,1], "totally complex control failed");
  auditcheck(nfinit(x^4-5).sign == [2,1], "one real embedding is not total reality");
  auditcheck(poldisc(x^2-5) == 20 && nfdisc(x^2-5) == 5,
    "polynomial and field discriminants must be distinguished");
  my(a=x^3-6*x^2-9*x-1, b=x^3-21*x-28);
  auditcheck(polisirreducible(a) && polisirreducible(b), "cubic controls are reducible");
  auditcheck(nfinit(a).sign == [3,0] && nfinit(b).sign == [3,0], "cubic signatures differ");
  auditcheck(nfdisc(a) == 3969 && nfdisc(b) == 3969, "cubic discriminants differ");
  auditcheck(nfisisom(a,b) == 0, "nonisomorphic-fields control failed");
  print("positive: degree 8, signature [4,2], field discriminant 40960000");
  print("positive: both primitive-element routes are isomorphic");
  print("negative: reducible polynomial rejected; real and complex quadratic fields distinguished");
  print("negative: polynomial discriminant 20 differs from field discriminant 5");
  print("negative: two nonisomorphic cubic fields share degree 3, signature [3,0], discriminant 3969");
  print("RESULT=PASS");
};
audit();
quit;
