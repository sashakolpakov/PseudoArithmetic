import PseudoArithmetic.SemanticAudit
import Mathlib.GroupTheory.Coxeter.Matrix
import Mathlib.LinearAlgebra.Matrix.Notation

/-! Concrete tests for the elementary geometric definitions and Lorentz algebra.
These do not identify a matrix with a finite-volume hyperbolic polytope. -/

namespace PseudoArithmetic.GeometryAudit

abbrev Space (n : ℕ) := (Fin n → ℝ) × ℝ

def lorentz {n : ℕ} (x y : Space n) : ℝ :=
  (∑ i, x.1 i * y.1 i) - x.2 * y.2

def upperSheet (n : ℕ) : Set (Space n) := {x | lorentz x x = -1 ∧ 0 < x.2}

def orthogonalHyperplane {n : ℕ} (e : Space n) : Set (Space n) :=
  {x | x ∈ upperSheet n ∧ lorentz x e = 0}

def outwardHalfSpace {n : ℕ} (e : Space n) : Set (Space n) :=
  {x | x ∈ upperSheet n ∧ lorentz x e ≤ 0}

theorem outward_halfspace_iff {n : ℕ} (e x : Space n) :
    x ∈ outwardHalfSpace e ↔ x ∈ upperSheet n ∧ lorentz x e ≤ 0 := Iff.rfl

theorem outward_halfspace_controls :
    ((fun _ : Fin 1 => -1), Real.sqrt 2) ∈ outwardHalfSpace ((fun _ => 1),0) ∧
      ((fun _ : Fin 1 => -1), Real.sqrt 2) ∉ outwardHalfSpace ((fun _ => -1),0) := by
  norm_num [outwardHalfSpace, upperSheet, lorentz, ← pow_two]

def Spacelike {n : ℕ} (x : Space n) : Prop := x ≠ 0 ∧ 0 < lorentz x x
def Null {n : ℕ} (x : Space n) : Prop := x ≠ 0 ∧ lorentz x x = 0
def Timelike {n : ℕ} (x : Space n) : Prop := x ≠ 0 ∧ lorentz x x < 0

def reflect {n : ℕ} (e x : Space n) : Space n := x - (2 * lorentz x e) • e

theorem lorentz_symmetric {n : ℕ} (x y : Space n) : lorentz x y = lorentz y x := by
  simp only [lorentz]
  congr 1
  · apply Finset.sum_congr rfl
    intro i _
    ring
  · ring

theorem lorentz_sub_left {n : ℕ} (x y z : Space n) :
    lorentz (x-y) z = lorentz x z - lorentz y z := by
  simp [lorentz, sub_mul, Finset.sum_sub_distrib]
  ring

theorem lorentz_smul_left {n : ℕ} (a : ℝ) (x y : Space n) :
    lorentz (a • x) y = a * lorentz x y := by
  simp [lorentz, mul_sub, Finset.mul_sum, mul_assoc]

theorem lorentz_sub_right {n : ℕ} (x y z : Space n) :
    lorentz x (y-z) = lorentz x y - lorentz x z := by
  rw [lorentz_symmetric, lorentz_sub_left, lorentz_symmetric y x, lorentz_symmetric z x]

theorem lorentz_smul_right {n : ℕ} (a : ℝ) (x y : Space n) :
    lorentz x (a • y) = a * lorentz x y := by
  rw [lorentz_symmetric, lorentz_smul_left, lorentz_symmetric y x]

theorem reflection_fixes_orthogonal {n : ℕ} (e x : Space n) (hx : lorentz x e = 0) :
    reflect e x = x := by simp [reflect, hx]

theorem reflection_negates_normal {n : ℕ} (e : Space n) (he : lorentz e e = 1) :
    reflect e e = -e := by
  ext i <;> simp [reflect, he] <;> ring

theorem reflection_preserves_form {n : ℕ} (e x y : Space n) (he : lorentz e e = 1) :
    lorentz (reflect e x) (reflect e y) = lorentz x y := by
  simp only [reflect, lorentz_sub_left, lorentz_sub_right,
    lorentz_smul_left, lorentz_smul_right, he]
  rw [lorentz_symmetric e y]
  ring

theorem reflection_involutive {n : ℕ} (e : Space n) (he : lorentz e e = 1) :
    Function.Involutive (reflect e) := by
  intro x
  have hx : lorentz (reflect e x) e = -lorentz x e := by
    simp only [reflect, lorentz_sub_left, lorentz_smul_left, he]
    ring
  unfold reflect
  change x - (2 * lorentz x e) • e - (2 * lorentz (reflect e x) e) • e = x
  rw [hx]
  ext i <;> simp

theorem upper_sheet_positive (n : ℕ) : ((0, 1) : Space n) ∈ upperSheet n := by
  simp [upperSheet, lorentz]

theorem lower_sheet_negative (n : ℕ) :
    lorentz ((0, -1) : Space n) (0, -1) = -1 ∧
      ((0, -1) : Space n) ∉ upperSheet n := by simp [upperSheet, lorentz]

theorem space_time_null_examples :
    Spacelike ((fun _ : Fin 1 => 1), 0) ∧
      Timelike ((0,1) : Space 1) ∧ Null ((fun _ : Fin 1 => 1), 1) := by
  norm_num [Spacelike, Timelike, Null, lorentz, Prod.ext_iff, funext_iff]

theorem zero_is_not_null : ¬ Null (0 : Space 1) := by simp [Null]

theorem nonunit_reflection_fails :
    lorentz (reflect ((fun _ : Fin 1 => 2), 0) ((fun _ => 1), 0))
      (reflect ((fun _ : Fin 1 => 2), 0) ((fun _ => 1), 0)) ≠
        lorentz ((fun _ : Fin 1 => 1), 0) ((fun _ => 1), 0) := by
  norm_num [reflect, lorentz]

theorem reflection_positive_example :
    reflect ((fun _ : Fin 1 => 1), 0) ((fun _ => 3), 5) = ((fun _ => -3), 5) := by
  ext i <;> norm_num [reflect, lorentz]

theorem reflection_sign_mutation :
    ((3 : ℝ) + 2 * (3 * 1) * 1) ≠ -3 := by norm_num

theorem nonunit_normal_not_negated :
    reflect ((fun _ : Fin 1 => 2), 0) ((fun _ => 2), 0) = ((fun _ => -14), 0) := by
  ext i <;> norm_num [reflect, lorentz]

noncomputable def reflectionCoefficient {n : ℕ} (e f : Space n) : ℝ :=
  2 * lorentz e f / lorentz e e

theorem reflectionCoefficient_rescale {n : ℕ} (e f : Space n)
    (a b : ℝ) (ha : a ≠ 0) (he : lorentz e e ≠ 0) :
    reflectionCoefficient (a • e) (b • f) = (b/a) * reflectionCoefficient e f := by
  simp only [reflectionCoefficient, lorentz_smul_left, lorentz_smul_right]
  field_simp

theorem raw_gram_rescaling_control :
    lorentz ((fun _ : Fin 1 => 2),0) ((fun _ => 3),0) = 6 ∧
      (6 : ℝ) ≠ 3/2 := by norm_num [lorentz]

def twoMirrorLabels : CoxeterMatrix (Fin 2) where
  M := !![1,3;3,1]

def parallelMirrorLabels : CoxeterMatrix (Fin 2) where
  M := !![1,0;0,1]

theorem coxeter_label_examples :
    twoMirrorLabels 0 1 = 3 ∧ parallelMirrorLabels 0 1 = 0 := by decide

theorem coxeter_symmetry_required :
    ¬ ( !![1,3;4,1] : Matrix (Fin 2) (Fin 2) ℕ).IsSymm := by
  intro h
  have := congrArg (fun A : Matrix (Fin 2) (Fin 2) ℕ => A 0 1) h
  norm_num [Matrix.transpose_apply] at this

theorem off_diagonal_one_forbidden (M : CoxeterMatrix (Fin 2)) : M 0 1 ≠ 1 :=
  M.off_diagonal 0 1 (by decide)

end PseudoArithmetic.GeometryAudit
