\\ Independent exact field check for the P_{11,8} certificate.

run_p118_field_check() =
{
  my(P = y^8 - 156*y^7 + 3498*y^6 - 36920*y^5 + 233027*y^4
             - 929928*y^3 + 2312714*y^2 - 3302756*y + 2050849);
  if (!polisirreducible(P), error("P_{11,8} trace polynomial is reducible"));
  my(K = nfinit(P));
  if (K.sign != [4, 2], error("unexpected P_{11,8} field signature"));
  if (K.disc != 40960000, error("unexpected P_{11,8} field discriminant"));
  if (polsturm(P) != 4, error("Sturm count did not find exactly four real roots"));
  print("P irreducible = 1");
  print("Sturm real-root count = ", polsturm(P));
  print("number-field signature = ", K.sign);
  print("field discriminant = ", K.disc);
};

run_p118_field_check();
