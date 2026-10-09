import PseudoArithmetic.SemanticAudit
import Mathlib.LinearAlgebra.Matrix.Trace
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.Tactic.FinCases

/-! Trace definitions, basis changes, and representation-sensitive controls. -/

namespace PseudoArithmetic.TraceAudit

theorem trace_basis_independent {n R : Type*} [Fintype n] [DecidableEq n] [CommRing R]
    (A P Q : Matrix n n R) (hQP : Q * P = 1) :
    Matrix.trace (P * A * Q) = Matrix.trace A := by
  rw [Matrix.trace_mul_comm, ← mul_assoc, hQP, one_mul]

theorem wrong_basis_change_control :
    Matrix.trace ( !![12] : Matrix (Fin 1) (Fin 1) ℚ) ≠
      Matrix.trace ( !![3] : Matrix (Fin 1) (Fin 1) ℚ) := by
  norm_num [Matrix.trace]

noncomputable def representationTraceField {ι n : Type*} [Fintype n]
    (ρ : ι → Matrix n n ℝ) : IntermediateField ℚ ℝ :=
  IntermediateField.adjoin ℚ (Set.range (fun g => Matrix.trace (ρ g)))

theorem traceField_restrict_le {ι κ n : Type*} [Fintype n]
    (ρ : ι → Matrix n n ℝ) (f : κ → ι) :
    representationTraceField (ρ ∘ f) ≤ representationTraceField ρ := by
  apply IntermediateField.adjoin_le_iff.mpr
  rintro x ⟨g,rfl⟩
  exact IntermediateField.subset_adjoin ℚ _ ⟨f g,rfl⟩

/-- Conjugation on the traceless two-by-two matrices, in coordinates.
This gives a concrete check of the distinction between defining and adjoint traces. -/
theorem sl2_diagonal_conjugation (t h e f : ℝ) (ht : t ≠ 0) :
    ( !![t,0;0,t⁻¹] : Matrix (Fin 2) (Fin 2) ℝ) * !![h,e;f,-h] * !![t⁻¹,0;0,t] =
      !![h,t^2*e;t⁻¹^2*f,-h] := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, Fin.sum_univ_succ, ht, pow_two, mul_assoc]
  all_goals field_simp

theorem adjoint_trace_is_not_defining_trace :
    Matrix.trace ( !![1,0,0;0,4,0;0,0,1/4] : Matrix (Fin 3) (Fin 3) ℚ) = 21/4 ∧
      Matrix.trace ( !![2,0;0,1/2] : Matrix (Fin 2) (Fin 2) ℚ) = 5/2 ∧
      (21/4 : ℚ) ≠ 5/2 := by
  norm_num [Matrix.trace, Fin.sum_univ_succ]

end PseudoArithmetic.TraceAudit
