import PseudoArithmetic.SubdiagramClassify

/-! Positive cases and rejected mutations for the complete diagram census. -/
namespace PseudoArithmetic.SubdiagramClassify

open Manuscript SemanticAudit GramAudit SubdiagramAudit Matrix

set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

theorem maxima_antichain : ∀ S ∈ nonnegativeMaxima, ∀ T ∈ nonnegativeMaxima,
    S ⊆ T → S = T := by decide

/-- Exactly the ten listed sets are maximal positive-semidefinite principal
subdiagrams; completeness is a conclusion, not an input. -/
theorem maximal_nonnegative_iff (S : Facets) :
    ((principal S).PosSemidef ∧
      ∀ T : Facets, S ⊆ T → (principal T).PosSemidef → T = S) ↔
      S ∈ nonnegativeMaxima := by
  constructor
  · rintro ⟨hS, hmax⟩
    obtain ⟨T, hT, hST⟩ := (principal_nonnegative_iff S).mp hS
    have heq := hmax T hST (nonnegative_maxima_checked T hT)
    simpa [heq] using hT
  · intro hS
    refine ⟨nonnegative_maxima_checked S hS, ?_⟩
    intro T hST hT
    obtain ⟨U, hU, hTU⟩ := (principal_nonnegative_iff T).mp hT
    have heq := maxima_antichain S hS U hU (hST.trans hTU)
    exact Finset.Subset.antisymm (heq ▸ hTU) hST

theorem positive_rank (S : Facets) (h : (principal S).PosDef) :
    (principal S).rank = S.card := by
  simpa using Matrix.rank_of_isUnit (principal S) h.isUnit

def ordinaryVertices : Finset Facets := nonnegativeMaxima.filter positiveTest
def idealVertices : Finset Facets := nonnegativeMaxima.filter (fun S => ¬ positiveTest S)

theorem ordinary_vertex_controls :
    ordinaryVertices.card = 8 ∧
      (∀ S ∈ ordinaryVertices, S.card = 4) ∧
      idealVertices = {{1,3,4,6}, {2,3,4,5,6}} := by decide

theorem ordinary_vertices_positive_rank_four (S : Facets) (h : S ∈ ordinaryVertices) :
    (principal S).PosDef ∧ (principal S).rank = 4 := by
  have hp := (principal_positive_iff S).mpr (Finset.mem_filter.mp h).2
  exact ⟨hp, (positive_rank S hp).trans (ordinary_vertex_controls.2.1 S h)⟩

theorem rank_congruence_diagonal {n : ℕ} (U : Matrix (Fin n) (Fin n) ℝ)
    (d : Fin n → ℝ) (hU : IsUnit U) :
    (Uᴴ * diagonal d * U).rank = (diagonal d).rank := by
  rw [Matrix.rank_mul_eq_left_of_isUnit_det U _ ((Matrix.isUnit_iff_isUnit_det U).mp hU)]
  exact Matrix.rank_mul_eq_right_of_isUnit_det Uᴴ _
    ((Matrix.isUnit_iff_isUnit_det Uᴴ).mp ((Matrix.isUnit_conjTranspose U).mpr hU))

theorem ideal1346_rank : (block indices1346).rank = 3 := by
  classical
  rw [factorization1346, rank_congruence_diagonal _ _ transform1346_unit, Matrix.rank_diagonal]
  have he : ∀ i : Fin 4, pivots1346 i ≠ 0 ↔ i.val < 3 := by
    intro i
    fin_cases i <;> norm_num [pivots1346]
  simp_rw [he]
  decide

theorem ideal23456_rank : (block indices23456).rank = 3 := by
  classical
  rw [factorization23456, rank_congruence_diagonal _ _ transform23456_unit, Matrix.rank_diagonal]
  have he : ∀ i : Fin 5, pivots23456 i ≠ 0 ↔ i.val < 3 := by
    intro i
    fin_cases i <;> norm_num [pivots23456]
  simp_rw [he]
  decide

theorem ideal_nullity_controls :
    4 - (block indices1346).rank = 1 ∧
      5 - (block indices23456).rank = 2 ∧
      5 - (block indices23456).rank ≠ 1 := by
  rw [ideal1346_rank, ideal23456_rank]
  decide

/-- All 21 elliptic edge diagrams have exactly two endpoints. -/
theorem edge_endpoint_barrage : ∀ S : Facets, positiveTest S → S.card = 3 →
    (nonnegativeMaxima.filter (S ⊆ ·)).card = 2 := by decide

theorem elliptic_edges_card :
    ((Finset.univ : Finset Facets).filter (fun S => positiveTest S ∧ S.card = 3)).card = 21 := by
  decide

theorem elliptic_edge_endpoints (S : Facets) (h : (principal S).PosDef)
    (hrank : (principal S).rank = 3) :
    (nonnegativeMaxima.filter (S ⊆ ·)).card = 2 :=
  edge_endpoint_barrage S ((principal_positive_iff S).mp h) ((positive_rank S h).symm.trans hrank)

/-- Each of the ten possible vertex deletions breaks an endpoint check. -/
theorem vertex_deletion_endpoint_barrage : ∀ v ∈ nonnegativeMaxima,
    ∃ S : Facets, positiveTest S ∧ S.card = 3 ∧
      ((nonnegativeMaxima.erase v).filter (S ⊆ ·)).card ≠ 2 := by decide

/-- Flipping any of the 70 vertex–facet incidence bits corrupts the maximal
subdiagram list. Both added and removed incidences are tested. -/
theorem incidence_flip_barrage : ∀ v ∈ nonnegativeMaxima, ∀ i : Facet,
    (if i ∈ v then v.erase i else insert i v) ∉ nonnegativeMaxima := by decide

/-- Every proper subset of each minimal negative example is nonnegative. -/
theorem negative_minima_are_minimal : ∀ T ∈ negativeMinima, ∀ S : Facets,
    S ⊂ T → nonnegativeTest S := by decide

theorem explicit_classification_controls :
    (principal {0,1,2,3}).PosDef ∧
      ((principal {2,6}).PosSemidef ∧ ¬ (principal {2,6}).PosDef) ∧
      ¬ (principal {0,5}).PosSemidef := by
  rw [principal_positive_iff, principal_nonnegative_iff,
    principal_positive_iff, principal_nonnegative_iff]
  decide

/-- Dropping nonemptiness invalidates the reported 127-case classification:
the empty matrix is positive definite, but it is deliberately not counted. -/
theorem empty_subset_negative :
    (principal ∅).PosDef ∧ (∅ : Facets) ∉ positiveSubsets := by
  rw [principal_positive_iff]
  decide

/-- Merely being positive definite does not make a subset a vertex. -/
theorem nonmaximal_positive_negative :
    (principal {0}).PosDef ∧ ({0} : Facets) ∉ nonnegativeMaxima := by
  rw [principal_positive_iff]
  decide

end PseudoArithmetic.SubdiagramClassify
