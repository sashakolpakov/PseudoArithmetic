import PseudoArithmetic.SubdiagramAudit

/-! Exhaustive real-matrix classification and adversarial controls. -/
namespace PseudoArithmetic.SubdiagramClassify

open Manuscript SemanticAudit GramAudit SubdiagramAudit Matrix

set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

def positiveMaxima : Finset Facets :=
  {{3,4,6}, {0,1,2,3}, {0,1,2,4}, {0,1,3,4}, {0,2,3,4},
   {1,2,3,5}, {1,2,4,5}, {1,3,5,6}, {1,4,5,6}}

def nonnegativeMaxima : Finset Facets :=
  {{0,1,2,3}, {0,1,2,4}, {0,1,3,4}, {0,2,3,4},
   {1,2,3,5}, {1,2,4,5}, {1,3,4,6}, {1,3,5,6}, {1,4,5,6}, {2,3,4,5,6}}

def negativeMinima : Finset Facets :=
  {{0,5}, {0,6}, {1,2,6}, {1,2,3,4}, {1,3,4,5}}

def singularMinima : Finset Facets := {{2,6}, {3,4,5}, {1,3,4,6}}

def positiveTest (S : Facets) : Prop := ∃ T ∈ positiveMaxima, S ⊆ T
def nonnegativeTest (S : Facets) : Prop := ∃ T ∈ nonnegativeMaxima, S ⊆ T

instance (S : Facets) : Decidable (positiveTest S) := inferInstanceAs (Decidable (∃ T ∈ positiveMaxima, S ⊆ T))
instance (S : Facets) : Decidable (nonnegativeTest S) := inferInstanceAs (Decidable (∃ T ∈ nonnegativeMaxima, S ⊆ T))

theorem block_nonnegative_of_mem {n : ℕ} (f : Fin n → Facet) (S : Facets)
    (h : (principal S).PosSemidef) (hf : ∀ i, f i ∈ S) : (block f).PosSemidef :=
  h.submatrix (fun i => (⟨f i, hf i⟩ : S))

theorem block_positive_of_mem {n : ℕ} (f : Fin n → Facet) (S : Facets)
    (h : (principal S).PosDef) (hf : ∀ i, f i ∈ S)
    (hinj : Function.Injective f) : (block f).PosDef :=
  h.submatrix (e := fun i => (⟨f i, hf i⟩ : S))
    (fun _ _ he => hinj (congrArg (fun x : S => x.val) he))

theorem positive_maxima_checked (S : Facets) (h : S ∈ positiveMaxima) :
    (principal S).PosDef := by
  simp only [positiveMaxima, Finset.mem_insert, Finset.mem_singleton] at h
  rcases h with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · exact positive_of_index_cover indices346 _ positive346 (by decide)
  · exact positive_of_index_cover indices0123 _ positive0123 (by decide)
  · exact positive_of_index_cover indices0124 _ positive0124 (by decide)
  · exact positive_of_index_cover indices0134 _ positive0134 (by decide)
  · exact positive_of_index_cover indices0234 _ positive0234 (by decide)
  · exact positive_of_index_cover indices1235 _ positive1235 (by decide)
  · exact positive_of_index_cover indices1245 _ positive1245 (by decide)
  · exact positive_of_index_cover indices1356 _ positive1356 (by decide)
  · exact positive_of_index_cover indices1456 _ positive1456 (by decide)

theorem nonnegative_maxima_checked (S : Facets) (h : S ∈ nonnegativeMaxima) :
    (principal S).PosSemidef := by
  simp only [nonnegativeMaxima, Finset.mem_insert, Finset.mem_singleton] at h
  rcases h with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · exact nonnegative_of_index_cover indices0123 _ positive0123.posSemidef (by decide)
  · exact nonnegative_of_index_cover indices0124 _ positive0124.posSemidef (by decide)
  · exact nonnegative_of_index_cover indices0134 _ positive0134.posSemidef (by decide)
  · exact nonnegative_of_index_cover indices0234 _ positive0234.posSemidef (by decide)
  · exact nonnegative_of_index_cover indices1235 _ positive1235.posSemidef (by decide)
  · exact nonnegative_of_index_cover indices1245 _ positive1245.posSemidef (by decide)
  · exact nonnegative_of_index_cover indices1346 _ nonnegative1346 (by decide)
  · exact nonnegative_of_index_cover indices1356 _ positive1356.posSemidef (by decide)
  · exact nonnegative_of_index_cover indices1456 _ positive1456.posSemidef (by decide)
  · exact nonnegative_of_index_cover indices23456 _ nonnegative23456 (by decide)

theorem narrow_radical_bounds : (11/5 : ℝ) < radicalS ∧ (7/5 : ℝ) < radicalR := by
  have hs := radicalS_square
  have hr : radicalR^2 = 2 := Real.sq_sqrt (by norm_num)
  have hspos := radical_bounds.1
  have hrpos : 0 ≤ radicalR := Real.sqrt_nonneg _
  constructor <;> nlinarith

theorem negative05 : ¬ (block ![0,5]).PosSemidef := by
  intro h
  have hq := h.dotProduct_mulVec_nonneg ![1,1]
  have hblock : block ![0,5] = (!![1, -radicalA; -radicalA, 1] : Matrix (Fin 2) (Fin 2) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> first | rfl | (change -(radicalR/2) = -radicalR/2; ring)
  rw [hblock] at hq
  norm_num [Matrix.mulVec, dotProduct, Fin.sum_univ_succ] at hq
  have ha := radicalA_gt_one
  have hb := radicalB_gt_one .p11_8
  have hs := narrow_radical_bounds.1
  have hr := narrow_radical_bounds.2
  linarith

theorem negative_set05 : ¬ (principal {0,5}).PosSemidef := by
  intro h
  exact negative05 (block_nonnegative_of_mem ![0,5] _ h (by decide))

theorem negative06 : ¬ (block ![0,6]).PosSemidef := by
  intro h
  have hq := h.dotProduct_mulVec_nonneg ![1,1]
  have hblock : block ![0,6] = (!![1, -(radicalB .p11_8); -(radicalB .p11_8), 1] : Matrix (Fin 2) (Fin 2) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> first | rfl | (change -(radicalR/2) = -radicalR/2; ring)
  rw [hblock] at hq
  norm_num [Matrix.mulVec, dotProduct, Fin.sum_univ_succ] at hq
  have ha := radicalA_gt_one
  have hb := radicalB_gt_one .p11_8
  have hs := narrow_radical_bounds.1
  have hr := narrow_radical_bounds.2
  linarith

theorem negative_set06 : ¬ (principal {0,6}).PosSemidef := by
  intro h
  exact negative06 (block_nonnegative_of_mem ![0,6] _ h (by decide))

theorem negative126 : ¬ (block ![1,2,6]).PosSemidef := by
  intro h
  have hq := h.dotProduct_mulVec_nonneg ![1,1,1]
  have hblock : block ![1,2,6] = (!![1, -(1+radicalS)/4, -radicalR/2; -(1+radicalS)/4, 1, -1; -radicalR/2, -1, 1] : Matrix (Fin 3) (Fin 3) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> first | rfl | (change -(radicalR/2) = -radicalR/2; ring)
  rw [hblock] at hq
  norm_num [Matrix.mulVec, dotProduct, Fin.sum_univ_succ] at hq
  have ha := radicalA_gt_one
  have hb := radicalB_gt_one .p11_8
  have hs := narrow_radical_bounds.1
  have hr := narrow_radical_bounds.2
  linarith

theorem negative_set126 : ¬ (principal {1,2,6}).PosSemidef := by
  intro h
  exact negative126 (block_nonnegative_of_mem ![1,2,6] _ h (by decide))

theorem negative1234 : ¬ (block ![1,2,3,4]).PosSemidef := by
  intro h
  have hq := h.dotProduct_mulVec_nonneg ![1,1,1,1]
  have hblock : block ![1,2,3,4] = (!![1, -(1+radicalS)/4, 0, -1/2; -(1+radicalS)/4, 1, 0, 0; 0, 0, 1, -radicalR/2; -1/2, 0, -radicalR/2, 1] : Matrix (Fin 4) (Fin 4) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> first | rfl | (change -(radicalR/2) = -radicalR/2; ring)
  rw [hblock] at hq
  norm_num [Matrix.mulVec, dotProduct, Fin.sum_univ_succ] at hq
  have ha := radicalA_gt_one
  have hb := radicalB_gt_one .p11_8
  have hs := narrow_radical_bounds.1
  have hr := narrow_radical_bounds.2
  linarith

theorem negative_set1234 : ¬ (principal {1,2,3,4}).PosSemidef := by
  intro h
  exact negative1234 (block_nonnegative_of_mem ![1,2,3,4] _ h (by decide))

theorem negative1345 : ¬ (block ![1,3,4,5]).PosSemidef := by
  intro h
  have hq := h.dotProduct_mulVec_nonneg ![1,2,2,1]
  have hblock : block ![1,3,4,5] = (!![1, 0, -1/2, 0; 0, 1, -radicalR/2, -radicalR/2; -1/2, -radicalR/2, 1, 0; 0, -radicalR/2, 0, 1] : Matrix (Fin 4) (Fin 4) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> first | rfl | (change -(radicalR/2) = -radicalR/2; ring)
  rw [hblock] at hq
  norm_num [Matrix.mulVec, dotProduct, Fin.sum_univ_succ] at hq
  have ha := radicalA_gt_one
  have hb := radicalB_gt_one .p11_8
  have hs := narrow_radical_bounds.1
  have hr := narrow_radical_bounds.2
  linarith

theorem negative_set1345 : ¬ (principal {1,3,4,5}).PosSemidef := by
  intro h
  exact negative1345 (block_nonnegative_of_mem ![1,3,4,5] _ h (by decide))

theorem singular26_not_positive : ¬ (block ![2,6]).PosDef := by
  intro h
  have hx : (![1,1] : Fin 2 → ℝ) ≠ 0 := by
    intro he
    have := congrFun he 1
    change (1 : ℝ) = 0 at this
    norm_num at this
  have hq := h.dotProduct_mulVec_pos hx
  have hr : radicalR^2 = 2 := Real.sq_sqrt (by norm_num)
  have hblock : block ![2,6] = (!![1, -1; -1, 1] : Matrix (Fin 2) (Fin 2) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> first | rfl | (change -(radicalR/2) = -radicalR/2; ring)
  rw [hblock] at hq
  norm_num [Matrix.mulVec, dotProduct, Fin.sum_univ_succ] at hq <;> nlinarith

theorem singular_set26_not_positive : ¬ (principal {2,6}).PosDef := by
  intro h
  exact singular26_not_positive (block_positive_of_mem ![2,6] _ h (by decide) (by decide))

theorem singular345_not_positive : ¬ (block ![3,4,5]).PosDef := by
  intro h
  have hx : (![radicalR,1,1] : Fin 3 → ℝ) ≠ 0 := by
    intro he
    have := congrFun he 2
    change (1 : ℝ) = 0 at this
    norm_num at this
  have hq := h.dotProduct_mulVec_pos hx
  have hr : radicalR^2 = 2 := Real.sq_sqrt (by norm_num)
  have hblock : block ![3,4,5] = (!![1, -radicalR/2, -radicalR/2; -radicalR/2, 1, 0; -radicalR/2, 0, 1] : Matrix (Fin 3) (Fin 3) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> first | rfl | (change -(radicalR/2) = -radicalR/2; ring)
  rw [hblock] at hq
  norm_num [Matrix.mulVec, dotProduct, Fin.sum_univ_succ] at hq <;> nlinarith

theorem singular_set345_not_positive : ¬ (principal {3,4,5}).PosDef := by
  intro h
  exact singular345_not_positive (block_positive_of_mem ![3,4,5] _ h (by decide) (by decide))

theorem singular1346_not_positive : ¬ (block ![1,3,4,6]).PosDef := by
  intro h
  have hx : (![radicalR,1,radicalR,1] : Fin 4 → ℝ) ≠ 0 := by
    intro he
    have := congrFun he 3
    change (1 : ℝ) = 0 at this
    norm_num at this
  have hq := h.dotProduct_mulVec_pos hx
  have hr : radicalR^2 = 2 := Real.sq_sqrt (by norm_num)
  have hblock : block ![1,3,4,6] = (!![1, 0, -1/2, -radicalR/2; 0, 1, -radicalR/2, 0; -1/2, -radicalR/2, 1, 0; -radicalR/2, 0, 0, 1] : Matrix (Fin 4) (Fin 4) ℝ) := by
    ext i j
    fin_cases i <;> fin_cases j <;> first | rfl | (change -(radicalR/2) = -radicalR/2; ring)
  rw [hblock] at hq
  norm_num [Matrix.mulVec, dotProduct, Fin.sum_univ_succ] at hq <;> nlinarith

theorem singular_set1346_not_positive : ¬ (principal {1,3,4,6}).PosDef := by
  intro h
  exact singular1346_not_positive (block_positive_of_mem ![1,3,4,6] _ h (by decide) (by decide))

theorem negative_minima_checked (S : Facets) (h : S ∈ negativeMinima) :
    ¬ (principal S).PosSemidef := by
  simp only [negativeMinima, Finset.mem_insert, Finset.mem_singleton] at h
  rcases h with rfl | rfl | rfl | rfl | rfl
  · exact negative_set05
  · exact negative_set06
  · exact negative_set126
  · exact negative_set1234
  · exact negative_set1345

theorem singular_minima_not_positive (S : Facets) (h : S ∈ singularMinima) :
    ¬ (principal S).PosDef := by
  simp only [singularMinima, Finset.mem_insert, Finset.mem_singleton] at h
  rcases h with rfl | rfl | rfl
  · exact singular_set26_not_positive
  · exact singular_set345_not_positive
  · exact singular_set1346_not_positive

/-- The finite search is proved exhaustive, not sampled. -/
theorem nonnegative_coverage : ∀ S : Facets,
    nonnegativeTest S ∨ ∃ T ∈ negativeMinima, T ⊆ S := by decide

theorem positive_coverage : ∀ S : Facets,
    positiveTest S ∨ (∃ T ∈ negativeMinima, T ⊆ S) ∨
      ∃ T ∈ singularMinima, T ⊆ S := by decide

theorem principal_nonnegative_iff (S : Facets) :
    (principal S).PosSemidef ↔ nonnegativeTest S := by
  constructor
  · intro h
    rcases nonnegative_coverage S with hp | ⟨T, hT, hTS⟩
    · exact hp
    · exact False.elim (negative_minima_checked T hT (nonnegative_mono hTS h))
  · rintro ⟨T, hT, hST⟩
    exact nonnegative_mono hST (nonnegative_maxima_checked T hT)

theorem principal_positive_iff (S : Facets) :
    (principal S).PosDef ↔ positiveTest S := by
  constructor
  · intro h
    rcases positive_coverage S with hp | ⟨T, hT, hTS⟩ | ⟨T, hT, hTS⟩
    · exact hp
    · exact False.elim (negative_minima_checked T hT (nonnegative_mono hTS h.posSemidef))
    · exact False.elim (singular_minima_not_positive T hT (positive_mono hTS h))
  · rintro ⟨T, hT, hST⟩
    exact positive_mono hST (positive_maxima_checked T hT)

def positiveSubsets : Finset Facets := Finset.univ.filter (fun S => S.Nonempty ∧ positiveTest S)
def singularSubsets : Finset Facets := Finset.univ.filter (fun S => S.Nonempty ∧ nonnegativeTest S ∧ ¬ positiveTest S)
def negativeSubsets : Finset Facets := Finset.univ.filter (fun S => S.Nonempty ∧ ¬ nonnegativeTest S)

theorem classification_counts :
    positiveSubsets.card = 54 ∧ singularSubsets.card = 12 ∧ negativeSubsets.card = 61 := by decide

/-- English: for every nonempty principal subset of the actual real Gram
matrix, the reported class is exactly its mathematical class. -/
theorem classification_correct (S : Facets) (hne : S.Nonempty) :
    ((principal S).PosDef ↔ S ∈ positiveSubsets) ∧
    ((principal S).PosSemidef ∧ ¬ (principal S).PosDef ↔ S ∈ singularSubsets) ∧
    (¬ (principal S).PosSemidef ↔ S ∈ negativeSubsets) := by
  simp [positiveSubsets, singularSubsets, negativeSubsets, hne,
    principal_positive_iff, principal_nonnegative_iff]

theorem negative_direction (S : Facets) (h : S ∈ negativeSubsets) :
    ∃ x : S → ℝ, star x ⬝ᵥ (principal S *ᵥ x) < 0 := by
  have hn : ¬ (principal S).PosSemidef := by
    simpa [negativeSubsets, principal_nonnegative_iff] using (Finset.mem_filter.mp h).2.2
  rw [Matrix.posSemidef_iff_dotProduct_mulVec] at hn
  have hh := principal_hermitian S
  simp only [hh, true_and, not_forall, not_le] at hn
  exact hn

end PseudoArithmetic.SubdiagramClassify
