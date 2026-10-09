import PseudoArithmetic.GramAudit
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic

/-! Intermediate identities and branch controls in the written radical proof. -/

namespace PseudoArithmetic.RadicalAudit

open Manuscript SemanticAudit GramAudit

theorem radicalU_square : radicalU ^ 2 = (7 + radicalS) / 2 + radicalT := by
  simp only [radicalU, radicalA, mul_pow]
  rw [Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 2),
    Real.sq_sqrt radicands_positive.2.1.le]
  ring

theorem radicalU_positive : 0 < radicalU :=
  mul_pos (Real.sqrt_pos.mpr (by norm_num)) (by have := radicalA_gt_one; linarith)

theorem radicalT_positive : 0 < radicalT := Real.sqrt_pos.mpr radicands_positive.1

theorem radical_linear_identity : (radicalS - 1) * radicalU = 3 - radicalS + radicalT := by
  have hs := radicalS_square
  have hu := radicalU_square
  have ht : radicalT ^ 2 = 2 + 2 * radicalS := Real.sq_sqrt radicands_positive.1.le
  have hl : 0 < (radicalS-1)*radicalU :=
    mul_pos (sub_pos.mpr radical_bounds.1) radicalU_positive
  have hr : 0 < 3-radicalS+radicalT := by
    have := radical_bounds.2.1
    have := radicalT_positive
    linarith
  have heq : ((radicalS-1)*radicalU)^2 = (3-radicalS+radicalT)^2 := by nlinarith
  nlinarith

theorem radicalT_linear : radicalT = (radicalS-1)*radicalU+radicalS-3 := by
  linarith [radical_linear_identity]

theorem elimination_factorization {R : Type*} [CommRing R] (s u : R) :
    ((s-1)*u+s-3)^2-(2+2*s) =
      (s-1)*((s-1)*u^2+2*(s-3)*u+s-7) := by ring

theorem cancellation_hypothesis_necessary :
    (-2 : ℚ) = (1-1)*0+1-3 ∧ (-2 : ℚ)^2 = 2+2*1 ∧
      (1-1 : ℚ)*0^2+2*(1-3)*0+1-7 ≠ 0 := by norm_num

theorem positive_branch_is_necessary :
    (1 : ℝ)^2 = (-1)^2 ∧ (1 : ℝ) ≠ -1 := by norm_num

theorem leading_minor_signs :
    0 < (5-radicalS)/8 ∧ 0 < 3*(5-radicalS)/32 ∧
      -(1+radicalS)/32 < 0 := by
  have h1 := radical_bounds.1
  have h3 := radical_bounds.2.1
  constructor
  · linarith
  constructor <;> linarith

theorem leading_minor_sign_boundary :
    (5-(5 : ℝ))/8 = 0 ∧ ¬ 0 < (5-(5 : ℝ))/8 := by norm_num

theorem fifth_root_quotient (z : ℂ) (hz : z^5 = -1) (hne : z ≠ -1) :
    z^4-z^3+z^2-z+1 = 0 := by
  have hn : z+1 ≠ 0 := by intro h; apply hne; linear_combination h
  have h : (z+1)*(z^4-z^3+z^2-z+1) = 0 := by
    calc
      _ = z^5+1 := by ring
      _ = 0 := by rw [hz]; ring
  exact (mul_eq_zero.mp h).resolve_left hn

theorem fifth_root_golden_relation (z : ℂ) (hz : z^5 = -1) (hne : z ≠ -1) :
    (z+z⁻¹)^2-(z+z⁻¹)-1 = 0 := by
  have hz0 : z ≠ 0 := by intro h; simp [h] at hz
  have h := fifth_root_quotient z hz hne
  field_simp
  linear_combination h

theorem fifth_root_excluded_boundary :
    (-1 : ℂ)^5 = -1 ∧ (-1 : ℂ)^4-(-1)^3+(-1)^2-(-1)+1 ≠ 0 := by norm_num

theorem golden_root_positive (x : ℝ) (hx : 0 < x) (h : x^2-x-1 = 0) :
    x = (1+radicalS)/2 := by
  have hs := radicalS_square
  have hp := radical_bounds.1
  have hx1 : 1 < x := by nlinarith
  have he : (2*x-1)^2 = radicalS^2 := by nlinarith
  nlinarith

noncomputable def fifthRoot : ℂ := Complex.exp ((Real.pi : ℂ) / 5 * Complex.I)

theorem fifthRoot_power : fifthRoot ^ 5 = -1 := by
  rw [fifthRoot, ← Complex.exp_nat_mul]
  convert Complex.exp_pi_mul_I using 1
  congr 1
  ring

theorem fifthRoot_sum : fifthRoot + fifthRoot⁻¹ = ((1+radicalS)/2 : ℝ) := by
  rw [fifthRoot, ← Complex.exp_neg]
  rw [show -((Real.pi : ℂ)/5*Complex.I) = -((Real.pi : ℂ)/5)*Complex.I by ring]
  rw [← Complex.two_cos]
  norm_cast
  rw [Real.cos_pi_div_five]
  simp only [radicalS]
  ring

theorem fifthRoot_ne_neg_one : fifthRoot ≠ -1 := by
  intro h
  have he := congrArg Complex.re fifthRoot_sum
  rw [h] at he
  norm_num at he
  have hs := radical_bounds.1
  linarith

theorem fifthRoot_golden_relation :
    (fifthRoot+fifthRoot⁻¹)^2-(fifthRoot+fifthRoot⁻¹)-1 = 0 :=
  fifth_root_golden_relation fifthRoot fifthRoot_power fifthRoot_ne_neg_one

noncomputable def leadingGram (j : CoxeterCase) (n : ℕ) (hn : n ≤ 7) :
    Matrix (Fin n) (Fin n) ℝ := (gram j).submatrix (Fin.castLE hn) (Fin.castLE hn)

set_option maxRecDepth 4096 in
set_option maxHeartbeats 800000 in
theorem leading_minor_values (j : CoxeterCase) :
    (leadingGram j 1 (by decide)).det = 1 ∧
      (leadingGram j 2 (by decide)).det = 1 ∧
      (leadingGram j 3 (by decide)).det = (5-radicalS)/8 ∧
      (leadingGram j 4 (by decide)).det = 3*(5-radicalS)/32 ∧
      (leadingGram j 5 (by decide)).det = -(1+radicalS)/32 := by
  have hs := radicalS_square
  have hr : radicalR^2 = 2 := Real.sq_sqrt (by norm_num)
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · norm_num [leadingGram, gram, Fin.castLE, Matrix.cons_val_succ', Matrix.cons_val_zero', Matrix.det_fin_one]
  · norm_num [leadingGram, gram, Fin.castLE, Matrix.cons_val_succ', Matrix.cons_val_zero', Matrix.det_fin_two]
  · norm_num [leadingGram, gram, Fin.castLE, Matrix.cons_val_succ', Matrix.cons_val_zero', Matrix.det_fin_three]
    nlinarith
  · rw [Matrix.det_succ_row_zero]
    norm_num [Fin.sum_univ_succ, leadingGram, gram, Matrix.submatrix,
      Fin.succAbove, Fin.castLE, Matrix.cons_val_succ', Matrix.cons_val_zero', Matrix.det_fin_three]
    simp only [Fin.lt_def, Fin.val_succ]
    norm_num [Matrix.cons_val_succ', Matrix.cons_val_zero']
    nlinarith
  · rw [Matrix.det_succ_row_zero]
    norm_num [Fin.sum_univ_succ, leadingGram, gram, Matrix.submatrix, Fin.succAbove,
      Fin.castLE, Matrix.cons_val_succ', Matrix.cons_val_zero']
    simp only [Matrix.det_succ_row_zero]
    norm_num [Fin.sum_univ_succ, Matrix.submatrix, Fin.succAbove, Fin.castLE,
      Matrix.cons_val_succ', Matrix.cons_val_zero', Matrix.det_fin_three]
    simp only [Fin.lt_def, Fin.le_def, Fin.ext_iff, Fin.val_succ, Fin.val_castSucc]
    norm_num [Matrix.cons_val_succ', Matrix.cons_val_zero']
    ring_nf
    norm_num [hs, hr]
    ring

end PseudoArithmetic.RadicalAudit
