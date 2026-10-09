import PseudoArithmetic.CensusAudit
import Mathlib.LinearAlgebra.Matrix.PosDef
import Mathlib.LinearAlgebra.Matrix.Block
import Mathlib.LinearAlgebra.Matrix.Rank
import Mathlib.Algebra.Order.Star.Real

/-! Kernel-checked classification of every principal submatrix of the actual
P₁₁,₈ Gram matrix. The finite certificates below are matrix identities and
positive diagonal pivots, not imported answers from a numerical program. -/

namespace PseudoArithmetic.SubdiagramAudit

open Manuscript SemanticAudit GramAudit Matrix

abbrev Facet := Fin 7
abbrev Facets := Finset Facet

noncomputable def block {n : ℕ} (f : Fin n → Facet) : Matrix (Fin n) (Fin n) ℝ :=
  (gram .p11_8).submatrix f f

noncomputable def principal (S : Facets) : Matrix S S ℝ :=
  (gram .p11_8).submatrix Subtype.val Subtype.val

theorem principal_hermitian (S : Facets) : (principal S).IsHermitian := by
  ext i j
  exact gram_symmetric .p11_8 j.val i.val

theorem positive_of_index_cover {n : ℕ} (f : Fin n → Facet) (S : Facets)
    (h : (block f).PosDef) (hcover : ∀ i ∈ S, ∃ k, f k = i) :
    (principal S).PosDef := by
  classical
  let e : S → Fin n := fun i => Classical.choose (hcover i.val i.property)
  have he (i : S) : f (e i) = i.val := Classical.choose_spec (hcover i.val i.property)
  have hinj : Function.Injective e := by
    intro i j hij
    apply Subtype.ext
    rw [← he i, ← he j, hij]
  convert h.submatrix hinj using 1
  ext i j
  simp only [principal, block, submatrix_apply, he]

theorem nonnegative_of_index_cover {n : ℕ} (f : Fin n → Facet) (S : Facets)
    (h : (block f).PosSemidef) (hcover : ∀ i ∈ S, ∃ k, f k = i) :
    (principal S).PosSemidef := by
  classical
  let e : S → Fin n := fun i => Classical.choose (hcover i.val i.property)
  have he (i : S) : f (e i) = i.val := Classical.choose_spec (hcover i.val i.property)
  convert h.submatrix e using 1
  ext i j
  simp only [principal, block, submatrix_apply, he]

theorem positive_mono {S T : Facets} (hST : S ⊆ T) (h : (principal T).PosDef) :
    (principal S).PosDef :=
  h.submatrix (e := fun x : S => (⟨x.val, hST x.property⟩ : T))
    (fun _ _ he => Subtype.ext (congrArg (fun x : T => x.val) he))

theorem nonnegative_mono {S T : Facets} (hST : S ⊆ T)
    (h : (principal T).PosSemidef) : (principal S).PosSemidef :=
  h.submatrix (fun x : S => (⟨x.val, hST x.property⟩ : T))

theorem unitriangular_isUnit {n : ℕ} (U : Matrix (Fin n) (Fin n) ℝ)
    (ht : U.BlockTriangular id) (hd : ∀ i, U i i = 1) : IsUnit U := by
  apply (Matrix.isUnit_iff_isUnit_det U).mpr
  rw [Matrix.det_of_upperTriangular ht]
  simp [hd]

def indices346 : Fin 3 → Facet := ![3, 4, 6]

noncomputable def transform346 : Matrix (Fin 3) (Fin 3) ℝ :=
  !![1, -radicalR/2, 0;
     0, 1, 0;
     0, 0, 1]

noncomputable def pivots346 : Fin 3 → ℝ :=
  ![1, 1/2, 1]

set_option maxHeartbeats 800000 in
set_option maxRecDepth 4096 in
theorem factorization346 : block indices346 =
    (transform346)ᴴ * diagonal pivots346 * transform346 := by
  have hs := radicalS_square
  have hs3 : radicalS^3 = 5*radicalS := by rw [pow_succ, hs]
  have hr : radicalR^2 = 2 := Real.sq_sqrt (by norm_num)
  have hb : block indices346 =
      (!![1, -radicalR/2, 0; -radicalR/2, 1, 0; 0, 0, 1] : Matrix (Fin 3) (Fin 3) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> rfl
  rw [hb]
  ext i j
  fin_cases i <;> fin_cases j <;>
    norm_num [transform346, pivots346,
      Matrix.mul_apply, Fin.sum_univ_succ, Matrix.diagonal, Matrix.conjTranspose,
      ] <;> ring_nf <;> norm_num [hs, hs3, hr] <;> ring

theorem transform346_unit : IsUnit transform346 := by
  apply unitriangular_isUnit
  · intro i j hij
    fin_cases i <;> fin_cases j <;> norm_num [transform346] at *
  · intro i
    fin_cases i <;> norm_num [transform346]

theorem positive346 : (block indices346).PosDef := by
  rw [factorization346]
  apply Matrix.PosDef.conjTranspose_mul_mul_same
    (Matrix.PosDef.diagonal (fun i => ?_))
    (Matrix.mulVec_injective_of_isUnit transform346_unit)
  fin_cases i <;> norm_num [pivots346] <;> linarith [radical_bounds.2.1]

def indices0123 : Fin 4 → Facet := ![0, 1, 2, 3]

noncomputable def transform0123 : Matrix (Fin 4) (Fin 4) ℝ :=
  !![1, 0, 0, -1/2;
     0, 1, -radicalS/4 - 1/4, 0;
     0, 0, 1, 0;
     0, 0, 0, 1]

noncomputable def pivots0123 : Fin 4 → ℝ :=
  ![1, 1, 5/8 - radicalS/8, 3/4]

set_option maxHeartbeats 800000 in
set_option maxRecDepth 4096 in
theorem factorization0123 : block indices0123 =
    (transform0123)ᴴ * diagonal pivots0123 * transform0123 := by
  have hs := radicalS_square
  have hs3 : radicalS^3 = 5*radicalS := by rw [pow_succ, hs]
  have hr : radicalR^2 = 2 := Real.sq_sqrt (by norm_num)
  have hb : block indices0123 =
      (!![1, 0, 0, -1/2; 0, 1, -(1+radicalS)/4, 0; 0, -(1+radicalS)/4, 1, 0; -1/2, 0, 0, 1] : Matrix (Fin 4) (Fin 4) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> rfl
  rw [hb]
  ext i j
  fin_cases i <;> fin_cases j <;>
    norm_num [transform0123, pivots0123,
      Matrix.mul_apply, Fin.sum_univ_succ, Matrix.diagonal, Matrix.conjTranspose,
      ] <;> ring_nf <;> norm_num [hs, hs3, hr] <;> ring

theorem transform0123_unit : IsUnit transform0123 := by
  apply unitriangular_isUnit
  · intro i j hij
    fin_cases i <;> fin_cases j <;> norm_num [transform0123] at *
  · intro i
    fin_cases i <;> norm_num [transform0123]

theorem positive0123 : (block indices0123).PosDef := by
  rw [factorization0123]
  apply Matrix.PosDef.conjTranspose_mul_mul_same
    (Matrix.PosDef.diagonal (fun i => ?_))
    (Matrix.mulVec_injective_of_isUnit transform0123_unit)
  fin_cases i <;> norm_num [pivots0123] <;> linarith [radical_bounds.2.1]

def indices0124 : Fin 4 → Facet := ![0, 1, 2, 4]

noncomputable def transform0124 : Matrix (Fin 4) (Fin 4) ℝ :=
  !![1, 0, 0, 0;
     0, 1, -radicalS/4 - 1/4, -1/2;
     0, 0, 1, -3*radicalS/10 - 1/2;
     0, 0, 0, 1]

noncomputable def pivots0124 : Fin 4 → ℝ :=
  ![1, 1, 5/8 - radicalS/8, 1/2 - radicalS/10]

set_option maxHeartbeats 800000 in
set_option maxRecDepth 4096 in
theorem factorization0124 : block indices0124 =
    (transform0124)ᴴ * diagonal pivots0124 * transform0124 := by
  have hs := radicalS_square
  have hs3 : radicalS^3 = 5*radicalS := by rw [pow_succ, hs]
  have hr : radicalR^2 = 2 := Real.sq_sqrt (by norm_num)
  have hb : block indices0124 =
      (!![1, 0, 0, 0; 0, 1, -(1+radicalS)/4, -1/2; 0, -(1+radicalS)/4, 1, 0; 0, -1/2, 0, 1] : Matrix (Fin 4) (Fin 4) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> rfl
  rw [hb]
  ext i j
  fin_cases i <;> fin_cases j <;>
    norm_num [transform0124, pivots0124,
      Matrix.mul_apply, Fin.sum_univ_succ, Matrix.diagonal, Matrix.conjTranspose,
      ] <;> ring_nf <;> norm_num [hs, hs3, hr] <;> ring

theorem transform0124_unit : IsUnit transform0124 := by
  apply unitriangular_isUnit
  · intro i j hij
    fin_cases i <;> fin_cases j <;> norm_num [transform0124] at *
  · intro i
    fin_cases i <;> norm_num [transform0124]

theorem positive0124 : (block indices0124).PosDef := by
  rw [factorization0124]
  apply Matrix.PosDef.conjTranspose_mul_mul_same
    (Matrix.PosDef.diagonal (fun i => ?_))
    (Matrix.mulVec_injective_of_isUnit transform0124_unit)
  fin_cases i <;> norm_num [pivots0124] <;> linarith [radical_bounds.2.1]

def indices0134 : Fin 4 → Facet := ![0, 1, 3, 4]

noncomputable def transform0134 : Matrix (Fin 4) (Fin 4) ℝ :=
  !![1, 0, -1/2, 0;
     0, 1, 0, -1/2;
     0, 0, 1, -2*radicalR/3;
     0, 0, 0, 1]

noncomputable def pivots0134 : Fin 4 → ℝ :=
  ![1, 1, 3/4, 1/12]

set_option maxHeartbeats 800000 in
set_option maxRecDepth 4096 in
theorem factorization0134 : block indices0134 =
    (transform0134)ᴴ * diagonal pivots0134 * transform0134 := by
  have hs := radicalS_square
  have hs3 : radicalS^3 = 5*radicalS := by rw [pow_succ, hs]
  have hr : radicalR^2 = 2 := Real.sq_sqrt (by norm_num)
  have hb : block indices0134 =
      (!![1, 0, -1/2, 0; 0, 1, 0, -1/2; -1/2, 0, 1, -radicalR/2; 0, -1/2, -radicalR/2, 1] : Matrix (Fin 4) (Fin 4) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> rfl
  rw [hb]
  ext i j
  fin_cases i <;> fin_cases j <;>
    norm_num [transform0134, pivots0134,
      Matrix.mul_apply, Fin.sum_univ_succ, Matrix.diagonal, Matrix.conjTranspose,
      ] <;> ring_nf <;> norm_num [hs, hs3, hr] <;> ring

theorem transform0134_unit : IsUnit transform0134 := by
  apply unitriangular_isUnit
  · intro i j hij
    fin_cases i <;> fin_cases j <;> norm_num [transform0134] at *
  · intro i
    fin_cases i <;> norm_num [transform0134]

theorem positive0134 : (block indices0134).PosDef := by
  rw [factorization0134]
  apply Matrix.PosDef.conjTranspose_mul_mul_same
    (Matrix.PosDef.diagonal (fun i => ?_))
    (Matrix.mulVec_injective_of_isUnit transform0134_unit)
  fin_cases i <;> norm_num [pivots0134] <;> linarith [radical_bounds.2.1]

def indices0234 : Fin 4 → Facet := ![0, 2, 3, 4]

noncomputable def transform0234 : Matrix (Fin 4) (Fin 4) ℝ :=
  !![1, 0, -1/2, 0;
     0, 1, 0, 0;
     0, 0, 1, -2*radicalR/3;
     0, 0, 0, 1]

noncomputable def pivots0234 : Fin 4 → ℝ :=
  ![1, 1, 3/4, 1/3]

set_option maxHeartbeats 800000 in
set_option maxRecDepth 4096 in
theorem factorization0234 : block indices0234 =
    (transform0234)ᴴ * diagonal pivots0234 * transform0234 := by
  have hs := radicalS_square
  have hs3 : radicalS^3 = 5*radicalS := by rw [pow_succ, hs]
  have hr : radicalR^2 = 2 := Real.sq_sqrt (by norm_num)
  have hb : block indices0234 =
      (!![1, 0, -1/2, 0; 0, 1, 0, 0; -1/2, 0, 1, -radicalR/2; 0, 0, -radicalR/2, 1] : Matrix (Fin 4) (Fin 4) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> rfl
  rw [hb]
  ext i j
  fin_cases i <;> fin_cases j <;>
    norm_num [transform0234, pivots0234,
      Matrix.mul_apply, Fin.sum_univ_succ, Matrix.diagonal, Matrix.conjTranspose,
      ] <;> ring_nf <;> norm_num [hs, hs3, hr] <;> ring

theorem transform0234_unit : IsUnit transform0234 := by
  apply unitriangular_isUnit
  · intro i j hij
    fin_cases i <;> fin_cases j <;> norm_num [transform0234] at *
  · intro i
    fin_cases i <;> norm_num [transform0234]

theorem positive0234 : (block indices0234).PosDef := by
  rw [factorization0234]
  apply Matrix.PosDef.conjTranspose_mul_mul_same
    (Matrix.PosDef.diagonal (fun i => ?_))
    (Matrix.mulVec_injective_of_isUnit transform0234_unit)
  fin_cases i <;> norm_num [pivots0234] <;> linarith [radical_bounds.2.1]

def indices1235 : Fin 4 → Facet := ![1, 2, 3, 5]

noncomputable def transform1235 : Matrix (Fin 4) (Fin 4) ℝ :=
  !![1, -radicalS/4 - 1/4, 0, 0;
     0, 1, 0, 0;
     0, 0, 1, -radicalR/2;
     0, 0, 0, 1]

noncomputable def pivots1235 : Fin 4 → ℝ :=
  ![1, 5/8 - radicalS/8, 1, 1/2]

set_option maxHeartbeats 800000 in
set_option maxRecDepth 4096 in
theorem factorization1235 : block indices1235 =
    (transform1235)ᴴ * diagonal pivots1235 * transform1235 := by
  have hs := radicalS_square
  have hs3 : radicalS^3 = 5*radicalS := by rw [pow_succ, hs]
  have hr : radicalR^2 = 2 := Real.sq_sqrt (by norm_num)
  have hb : block indices1235 =
      (!![1, -(1+radicalS)/4, 0, 0; -(1+radicalS)/4, 1, 0, 0; 0, 0, 1, -radicalR/2; 0, 0, -radicalR/2, 1] : Matrix (Fin 4) (Fin 4) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> rfl
  rw [hb]
  ext i j
  fin_cases i <;> fin_cases j <;>
    norm_num [transform1235, pivots1235,
      Matrix.mul_apply, Fin.sum_univ_succ, Matrix.diagonal, Matrix.conjTranspose,
      ] <;> ring_nf <;> norm_num [hs, hs3, hr] <;> ring

theorem transform1235_unit : IsUnit transform1235 := by
  apply unitriangular_isUnit
  · intro i j hij
    fin_cases i <;> fin_cases j <;> norm_num [transform1235] at *
  · intro i
    fin_cases i <;> norm_num [transform1235]

theorem positive1235 : (block indices1235).PosDef := by
  rw [factorization1235]
  apply Matrix.PosDef.conjTranspose_mul_mul_same
    (Matrix.PosDef.diagonal (fun i => ?_))
    (Matrix.mulVec_injective_of_isUnit transform1235_unit)
  fin_cases i <;> norm_num [pivots1235] <;> linarith [radical_bounds.2.1]

def indices1245 : Fin 4 → Facet := ![1, 2, 4, 5]

noncomputable def transform1245 : Matrix (Fin 4) (Fin 4) ℝ :=
  !![1, -radicalS/4 - 1/4, -1/2, 0;
     0, 1, -3*radicalS/10 - 1/2, 0;
     0, 0, 1, 0;
     0, 0, 0, 1]

noncomputable def pivots1245 : Fin 4 → ℝ :=
  ![1, 5/8 - radicalS/8, 1/2 - radicalS/10, 1]

set_option maxHeartbeats 800000 in
set_option maxRecDepth 4096 in
theorem factorization1245 : block indices1245 =
    (transform1245)ᴴ * diagonal pivots1245 * transform1245 := by
  have hs := radicalS_square
  have hs3 : radicalS^3 = 5*radicalS := by rw [pow_succ, hs]
  have hr : radicalR^2 = 2 := Real.sq_sqrt (by norm_num)
  have hb : block indices1245 =
      (!![1, -(1+radicalS)/4, -1/2, 0; -(1+radicalS)/4, 1, 0, 0; -1/2, 0, 1, 0; 0, 0, 0, 1] : Matrix (Fin 4) (Fin 4) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> rfl
  rw [hb]
  ext i j
  fin_cases i <;> fin_cases j <;>
    norm_num [transform1245, pivots1245,
      Matrix.mul_apply, Fin.sum_univ_succ, Matrix.diagonal, Matrix.conjTranspose,
      ] <;> ring_nf <;> norm_num [hs, hs3, hr] <;> ring

theorem transform1245_unit : IsUnit transform1245 := by
  apply unitriangular_isUnit
  · intro i j hij
    fin_cases i <;> fin_cases j <;> norm_num [transform1245] at *
  · intro i
    fin_cases i <;> norm_num [transform1245]

theorem positive1245 : (block indices1245).PosDef := by
  rw [factorization1245]
  apply Matrix.PosDef.conjTranspose_mul_mul_same
    (Matrix.PosDef.diagonal (fun i => ?_))
    (Matrix.mulVec_injective_of_isUnit transform1245_unit)
  fin_cases i <;> norm_num [pivots1245] <;> linarith [radical_bounds.2.1]

def indices1356 : Fin 4 → Facet := ![1, 3, 5, 6]

noncomputable def transform1356 : Matrix (Fin 4) (Fin 4) ℝ :=
  !![1, 0, 0, -radicalR/2;
     0, 1, -radicalR/2, 0;
     0, 0, 1, 0;
     0, 0, 0, 1]

noncomputable def pivots1356 : Fin 4 → ℝ :=
  ![1, 1, 1/2, 1/2]

set_option maxHeartbeats 800000 in
set_option maxRecDepth 4096 in
theorem factorization1356 : block indices1356 =
    (transform1356)ᴴ * diagonal pivots1356 * transform1356 := by
  have hs := radicalS_square
  have hs3 : radicalS^3 = 5*radicalS := by rw [pow_succ, hs]
  have hr : radicalR^2 = 2 := Real.sq_sqrt (by norm_num)
  have hb : block indices1356 =
      (!![1, 0, 0, -(radicalR/2); 0, 1, -radicalR/2, 0; 0, -radicalR/2, 1, 0; -(radicalR/2), 0, 0, 1] : Matrix (Fin 4) (Fin 4) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> rfl
  rw [hb]
  ext i j
  fin_cases i <;> fin_cases j <;>
    norm_num [transform1356, pivots1356,
      Matrix.mul_apply, Fin.sum_univ_succ, Matrix.diagonal, Matrix.conjTranspose,
      ] <;> ring_nf <;> norm_num [hs, hs3, hr] <;> ring

theorem transform1356_unit : IsUnit transform1356 := by
  apply unitriangular_isUnit
  · intro i j hij
    fin_cases i <;> fin_cases j <;> norm_num [transform1356] at *
  · intro i
    fin_cases i <;> norm_num [transform1356]

theorem positive1356 : (block indices1356).PosDef := by
  rw [factorization1356]
  apply Matrix.PosDef.conjTranspose_mul_mul_same
    (Matrix.PosDef.diagonal (fun i => ?_))
    (Matrix.mulVec_injective_of_isUnit transform1356_unit)
  fin_cases i <;> norm_num [pivots1356] <;> linarith [radical_bounds.2.1]

def indices1456 : Fin 4 → Facet := ![1, 4, 5, 6]

noncomputable def transform1456 : Matrix (Fin 4) (Fin 4) ℝ :=
  !![1, -1/2, 0, -radicalR/2;
     0, 1, 0, -radicalR/3;
     0, 0, 1, 0;
     0, 0, 0, 1]

noncomputable def pivots1456 : Fin 4 → ℝ :=
  ![1, 3/4, 1, 1/3]

set_option maxHeartbeats 800000 in
set_option maxRecDepth 4096 in
theorem factorization1456 : block indices1456 =
    (transform1456)ᴴ * diagonal pivots1456 * transform1456 := by
  have hs := radicalS_square
  have hs3 : radicalS^3 = 5*radicalS := by rw [pow_succ, hs]
  have hr : radicalR^2 = 2 := Real.sq_sqrt (by norm_num)
  have hb : block indices1456 =
      (!![1, -1/2, 0, -(radicalR/2); -1/2, 1, 0, 0; 0, 0, 1, 0; -(radicalR/2), 0, 0, 1] : Matrix (Fin 4) (Fin 4) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> rfl
  rw [hb]
  ext i j
  fin_cases i <;> fin_cases j <;>
    norm_num [transform1456, pivots1456,
      Matrix.mul_apply, Fin.sum_univ_succ, Matrix.diagonal, Matrix.conjTranspose,
      ] <;> ring_nf <;> norm_num [hs, hs3, hr] <;> ring

theorem transform1456_unit : IsUnit transform1456 := by
  apply unitriangular_isUnit
  · intro i j hij
    fin_cases i <;> fin_cases j <;> norm_num [transform1456] at *
  · intro i
    fin_cases i <;> norm_num [transform1456]

theorem positive1456 : (block indices1456).PosDef := by
  rw [factorization1456]
  apply Matrix.PosDef.conjTranspose_mul_mul_same
    (Matrix.PosDef.diagonal (fun i => ?_))
    (Matrix.mulVec_injective_of_isUnit transform1456_unit)
  fin_cases i <;> norm_num [pivots1456] <;> linarith [radical_bounds.2.1]

def indices1346 : Fin 4 → Facet := ![1, 3, 4, 6]

noncomputable def transform1346 : Matrix (Fin 4) (Fin 4) ℝ :=
  !![1, 0, -1/2, -radicalR/2;
     0, 1, -radicalR/2, 0;
     0, 0, 1, -radicalR;
     0, 0, 0, 1]

noncomputable def pivots1346 : Fin 4 → ℝ :=
  ![1, 1, 1/4, 0]

set_option maxHeartbeats 800000 in
set_option maxRecDepth 4096 in
theorem factorization1346 : block indices1346 =
    (transform1346)ᴴ * diagonal pivots1346 * transform1346 := by
  have hs := radicalS_square
  have hs3 : radicalS^3 = 5*radicalS := by rw [pow_succ, hs]
  have hr : radicalR^2 = 2 := Real.sq_sqrt (by norm_num)
  have hb : block indices1346 =
      (!![1, 0, -1/2, -(radicalR/2); 0, 1, -radicalR/2, 0; -1/2, -radicalR/2, 1, 0; -(radicalR/2), 0, 0, 1] : Matrix (Fin 4) (Fin 4) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> rfl
  rw [hb]
  ext i j
  fin_cases i <;> fin_cases j <;>
    norm_num [transform1346, pivots1346,
      Matrix.mul_apply, Fin.sum_univ_succ, Matrix.diagonal, Matrix.conjTranspose,
      ] <;> ring_nf <;> norm_num [hs, hs3, hr] <;> ring

theorem transform1346_unit : IsUnit transform1346 := by
  apply unitriangular_isUnit
  · intro i j hij
    fin_cases i <;> fin_cases j <;> norm_num [transform1346] at *
  · intro i
    fin_cases i <;> norm_num [transform1346]

theorem nonnegative1346 : (block indices1346).PosSemidef := by
  rw [factorization1346]
  apply Matrix.PosSemidef.conjTranspose_mul_mul_same
    (Matrix.PosSemidef.diagonal (fun i => ?_))
  fin_cases i <;> norm_num [pivots1346]

def indices23456 : Fin 5 → Facet := ![2, 3, 4, 5, 6]

noncomputable def transform23456 : Matrix (Fin 5) (Fin 5) ℝ :=
  !![1, 0, 0, 0, -1;
     0, 1, -radicalR/2, -radicalR/2, 0;
     0, 0, 1, -1, 0;
     0, 0, 0, 1, 0;
     0, 0, 0, 0, 1]

noncomputable def pivots23456 : Fin 5 → ℝ :=
  ![1, 1, 1/2, 0, 0]

set_option maxHeartbeats 800000 in
set_option maxRecDepth 4096 in
theorem factorization23456 : block indices23456 =
    (transform23456)ᴴ * diagonal pivots23456 * transform23456 := by
  have hs := radicalS_square
  have hs3 : radicalS^3 = 5*radicalS := by rw [pow_succ, hs]
  have hr : radicalR^2 = 2 := Real.sq_sqrt (by norm_num)
  have hb : block indices23456 =
      (!![1, 0, 0, 0, -1; 0, 1, -radicalR/2, -radicalR/2, 0; 0, -radicalR/2, 1, 0, 0; 0, -radicalR/2, 0, 1, 0; -1, 0, 0, 0, 1] : Matrix (Fin 5) (Fin 5) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> rfl
  rw [hb]
  ext i j
  fin_cases i <;> fin_cases j <;>
    norm_num [transform23456, pivots23456,
      Matrix.mul_apply, Fin.sum_univ_succ, Matrix.diagonal, Matrix.conjTranspose,
      ] <;> ring_nf <;> norm_num [hs, hs3, hr] <;> ring

theorem transform23456_unit : IsUnit transform23456 := by
  apply unitriangular_isUnit
  · intro i j hij
    fin_cases i <;> fin_cases j <;> norm_num [transform23456] at *
  · intro i
    fin_cases i <;> norm_num [transform23456]

theorem nonnegative23456 : (block indices23456).PosSemidef := by
  rw [factorization23456]
  apply Matrix.PosSemidef.conjTranspose_mul_mul_same
    (Matrix.PosSemidef.diagonal (fun i => ?_))
  fin_cases i <;> norm_num [pivots23456]

end PseudoArithmetic.SubdiagramAudit
