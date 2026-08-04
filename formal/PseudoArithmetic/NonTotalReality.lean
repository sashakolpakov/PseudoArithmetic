import Mathlib.NumberTheory.NumberField.InfinitePlace.TotallyRealComplex
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

/-!
# The non-total-reality obstruction

This file formalizes the field-theoretic core of the two-cycle obstruction
used for the Coxeter lattices `P_{11,6}`, `P_{11,7}`, and `P_{11,8}`.
-/

namespace PseudoArithmetic

/-- The conjugate quadratic from the two-cycle certificate has no real root.

The hypotheses `s ^ 2 = 5` and `s < 0` select the conjugate value
`s = -sqrt 5` without introducing square-root expressions into the algebraic
argument.
-/
theorem conjugateQuadratic_no_real_root
    {s u : ℝ}
    (hsq : s ^ 2 = 5)
    (hsneg : s < 0)
    (hrel : (s - 1) * u ^ 2 + 2 * (s - 3) * u + s - 7 = 0) :
    False := by
  have hslt : s < -1 := by
    nlinarith
  have hsquare : 0 ≤ (2 * (s - 1) * u + 2 * (s - 3)) ^ 2 := sq_nonneg _
  nlinarith

/-- A complex embedding that sends `s` to the negative square root of `5`
cannot be real when `s` and `u` satisfy the two-cycle relation.

This isolates the only analytic input: a real embedding would turn the
relation into the impossible real quadratic handled above.
-/
theorem cycleEmbedding_not_real
    {K : Type*} [Field K]
    (s u : K)
    (hsq : s ^ 2 = (5 : K))
    (hrel : (s - 1) * u ^ 2 + 2 * (s - 3) * u + s - 7 = 0)
    (phi : K →+* ℂ)
    (hphi : phi s = -(Real.sqrt 5 : ℂ)) :
    ¬ NumberField.ComplexEmbedding.IsReal phi := by
  intro hreal
  let psi : K →+* ℝ := hreal.embedding
  have hpsi_s : psi s = -Real.sqrt 5 := by
    apply Complex.ofReal_injective
    simpa [psi] using hphi
  have hpsi_sq : (psi s) ^ 2 = (5 : ℝ) := by
    have h := congrArg psi hsq
    simp only [map_pow, map_ofNat] at h
    exact h
  have hpsi_neg : psi s < 0 := by
    rw [hpsi_s]
    exact neg_neg_of_pos (Real.sqrt_pos.2 (by norm_num))
  have hpsi_rel :
      (psi s - 1) * (psi u) ^ 2 + 2 * (psi s - 3) * psi u + psi s - 7 = 0 := by
    have h := congrArg psi hrel
    simp only [map_sub, map_mul, map_add, map_pow, map_one, map_ofNat, map_zero] at h
    exact h
  exact conjugateQuadratic_no_real_root hpsi_sq hpsi_neg hpsi_rel

/-- The two-cycle relation obstructs total reality as soon as the number field
has an embedding carrying `s` to `-sqrt 5`.
-/
theorem not_totallyReal_of_cycle_embedding
    {K : Type*} [Field K] [NumberField K]
    (s u : K)
    (hsq : s ^ 2 = (5 : K))
    (hrel : (s - 1) * u ^ 2 + 2 * (s - 3) * u + s - 7 = 0)
    (phi : K →+* ℂ)
    (hphi : phi s = -(Real.sqrt 5 : ℂ)) :
    ¬ NumberField.IsTotallyReal K := by
  intro htotallyReal
  letI : NumberField.IsTotallyReal K := htotallyReal
  exact cycleEmbedding_not_real s u hsq hrel phi hphi
    (NumberField.IsTotallyReal.complexEmbedding_isReal phi)

/-- The intrinsic minpoly form of the two-cycle obstruction.

If `s` has minimal polynomial `X^2 - 5`, then `-sqrt 5` is one of its
complex conjugates.  The corresponding complex embedding is supplied by the
standard number-field embedding theorem, and the preceding result shows that
it is not real.
-/
theorem not_totallyReal_of_cycle_minpoly
    {K : Type*} [Field K] [NumberField K]
    (s u : K)
    (hmin : minpoly ℚ s = Polynomial.X ^ 2 - Polynomial.C 5)
    (hrel : (s - 1) * u ^ 2 + 2 * (s - 3) * u + s - 7 = 0) :
    ¬ NumberField.IsTotallyReal K := by
  have hsq : s ^ 2 = (5 : K) := by
    have hzero := minpoly.aeval ℚ s
    rw [hmin] at hzero
    have hzero' : s ^ 2 - (5 : K) = 0 := by
      simpa using hzero
    exact sub_eq_zero.mp hzero'
  let z : ℂ := -(Real.sqrt 5 : ℂ)
  have hzsq : z ^ 2 = (5 : ℂ) := by
    dsimp [z]
    rw [neg_sq]
    norm_cast
    exact Real.sq_sqrt (by norm_num)
  have hzroot : z ∈ (minpoly ℚ s).rootSet ℂ := by
    rw [hmin, (Polynomial.monic_X_pow_sub_C (5 : ℚ) (by norm_num : 2 ≠ 0)).mem_rootSet]
    simp [hzsq]
  have hzrange :
      z ∈ Set.range (fun phi : K →+* ℂ => phi s) := by
    rw [NumberField.Embeddings.range_eval_eq_rootSet_minpoly K ℂ s]
    exact hzroot
  obtain ⟨phi, hphi⟩ := hzrange
  exact not_totallyReal_of_cycle_embedding s u hsq hrel phi hphi

end PseudoArithmetic
