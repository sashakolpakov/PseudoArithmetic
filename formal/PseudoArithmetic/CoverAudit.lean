import PseudoArithmetic.SemanticAudit
import Mathlib.GroupTheory.Index
import Mathlib.GroupTheory.Schreier
import Mathlib.Algebra.GroupWithZero.Units.Fintype

/-! Group-index and topological content of the finite-cover argument.
The identification with hyperbolic quotients is a separate external input. -/

namespace PseudoArithmetic.CoverAudit

theorem finite_index_subgroup_finitely_generated {G : Type*} [Group G] [Group.FG G]
    (H : Subgroup G) [H.FiniteIndex] : Group.FG H := inferInstance

theorem orientation_kernel_index_le_two {G : Type*} [Group G] (χ : G →* ℤˣ) :
    χ.ker.index ≤ 2 := by
  rw [Subgroup.index_ker]
  have h := Nat.card_le_card_of_injective (fun x : χ.range => (x : ℤˣ)) Subtype.val_injective
  simpa [Nat.card_eq_fintype_card] using h

theorem orientation_kernel_index_eq_two {G : Type*} [Group G] (χ : G →* ℤˣ)
    (h : ∃ g, χ g = -1) : χ.ker.index = 2 := by
  rw [Subgroup.index_ker]
  have hsurj : Function.Surjective χ := by
    intro u
    rcases Int.units_eq_one_or u with hu | hu
    · exact ⟨1, by simpa using hu.symm⟩
    · obtain ⟨g, hg⟩ := h
      exact ⟨g, hg.trans hu.symm⟩
  rw [MonoidHom.range_eq_top.mpr hsurj]
  simp [Nat.card_eq_fintype_card]

theorem orientation_positive_example : (MonoidHom.id ℤˣ).ker.index = 2 := by
  apply orientation_kernel_index_eq_two
  exact ⟨-1, rfl⟩

theorem orientation_surjectivity_needed :
    (1 : ℤˣ →* ℤˣ).ker.index = 1 ∧ (1 : ℤˣ →* ℤˣ).ker.index ≠ 2 := by
  simp

/-- The trivial subgroup supplies a torsion-free finite-index subgroup of
the order-two reflection group.  The whole group still has torsion. -/
theorem selberg_finite_group_control :
    (⊥ : Subgroup ℤˣ).index = 2 ∧
      (∀ g : (⊥ : Subgroup ℤˣ), g = 1) ∧
      (-1 : ℤˣ) ≠ 1 ∧ (-1 : ℤˣ) ^ 2 = 1 := by
  constructor
  · simp [Nat.card_eq_fintype_card]
  constructor
  · intro g
    apply Subtype.ext
    exact g.property
  norm_num

/-- Noncompactness needs only a continuous surjection, not the stronger
finite-cover hypothesis used in the application. -/
theorem noncompact_of_continuous_surjective {X Y : Type*}
    [TopologicalSpace X] [TopologicalSpace Y]
    (f : X → Y) (hf : Continuous f) (hsurj : Function.Surjective f)
    (hY : ¬ CompactSpace Y) : ¬ CompactSpace X := by
  intro hX
  letI := hX
  exact hY (hsurj.compactSpace hf)

theorem noncompact_cover_positive : ¬ CompactSpace (ℝ × Fin 2) := by
  apply noncompact_of_continuous_surjective Prod.fst continuous_fst
    (fun y => ⟨(y,0), rfl⟩)
  exact not_compactSpace_iff.mpr inferInstance

theorem surjectivity_needed_for_noncompactness :
    CompactSpace PUnit ∧ ¬ CompactSpace ℝ ∧
      Continuous (fun _ : PUnit => (0 : ℝ)) ∧
      ¬ Function.Surjective (fun _ : PUnit => (0 : ℝ)) := by
  refine ⟨inferInstance, not_compactSpace_iff.mpr inferInstance, continuous_const, ?_⟩
  intro h
  obtain ⟨x, hx⟩ := h 1
  norm_num at hx

theorem positive_degree_volume_scale (d : ℕ) (hd : 0 < d) (v : ℝ) :
    0 < (d : ℝ) * v ↔ 0 < v := by
  have hd' : (0 : ℝ) < d := by exact_mod_cast hd
  exact mul_pos_iff_of_pos_left hd'

theorem volume_scale_controls :
    (2 : ℚ) * (19/864) = 19/432 ∧
      (2 : ℚ) * (19/864) ≠ 19/864 ∧ (0 : ℚ) * 1 = 0 := by norm_num

end PseudoArithmetic.CoverAudit
