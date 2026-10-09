import PseudoArithmetic.FaceAudit

/-! Semantic controls for face enumeration: closed incidences, completeness,
dimension, and the insufficiency of Euler consistency. -/
namespace PseudoArithmetic.FaceAudit

set_option maxRecDepth 10000
set_option maxHeartbeats 8000000

theorem closure_extensive (V : Finset Facets) (S : Facets) : S ⊆ closure V S := by
  intro i hi
  apply Finset.mem_filter.mpr
  refine ⟨Finset.mem_univ _, ?_⟩
  intro v hv
  exact (Finset.mem_filter.mp hv).2 hi

theorem vertex_is_face {V : Finset Facets} {v : Facets} (hv : v ∈ V) :
    v ∈ faces V := by
  apply Finset.mem_filter.mpr
  refine ⟨Finset.mem_univ _, ⟨v, Finset.mem_filter.mpr ⟨hv, Finset.Subset.refl _⟩⟩, ?_⟩
  apply Finset.Subset.antisymm
  · intro i hi
    exact (Finset.mem_filter.mp hi).2 v (Finset.mem_filter.mpr ⟨hv, Finset.Subset.refl _⟩)
  · exact closure_extensive V v

theorem dimension_zero_iff (V : Finset Facets) (S : Facets) :
    dimension V S = 0 ↔ ∀ T ∈ faces V, ¬ S ⊂ T := by
  rw [dimension, depth]
  change _ = (⊥ : ℕ) ↔ _
  rw [Finset.sup_eq_bot_iff]
  constructor
  · intro h T hT hST
    have := h T (Finset.mem_filter.mpr ⟨hT, hST⟩)
    change depth (faces V) 6 T + 1 = 0 at this
    omega
  · intro h T hT
    exact False.elim (h T (Finset.mem_filter.mp hT).1 (Finset.mem_filter.mp hT).2)

def Irredundant (V : Finset Facets) : Prop :=
  ∀ v ∈ V, ∀ w ∈ V, v ⊆ w → v = w

theorem irredundant_mono {V W : Finset Facets} (hWV : W ⊆ V)
    (hV : Irredundant V) : Irredundant W := by
  intro v hv w hw hsub
  exact hV v (hWV hv) w (hWV hw) hsub

/-- Counting minimal nonempty faces counts the vertices exactly when the
incidence list contains no comparable, redundant entries. -/
theorem faceCount_zero {V : Finset Facets} (hV : Irredundant V) :
    faceCount V 0 = V.card := by
  unfold faceCount
  congr 1
  ext S
  simp only [Finset.mem_filter]
  constructor
  · rintro ⟨hS, hdim⟩
    obtain ⟨v, hv⟩ := (Finset.mem_filter.mp hS).2.1
    have hvV := (Finset.mem_filter.mp hv).1
    have hSv := (Finset.mem_filter.mp hv).2
    have heq : S = v := by
      by_contra hne
      exact (dimension_zero_iff V S).mp hdim v (vertex_is_face hvV)
        (Finset.ssubset_iff_subset_ne.mpr ⟨hSv, hne⟩)
    simpa [heq] using hvV
  · intro hS
    refine ⟨vertex_is_face hS, (dimension_zero_iff V S).mpr ?_⟩
    intro T hT hST
    obtain ⟨v, hv⟩ := (Finset.mem_filter.mp hT).2.1
    have hTv := (Finset.mem_filter.mp hv).2
    have heq := hV S hS v (Finset.mem_filter.mp hv).1 (hST.subset.trans hTv)
    exact hST.not_subset (heq ▸ hTv)

set_option maxRecDepth 10000 in
theorem vertices_irredundant : Irredundant vertices := by unfold Irredundant; decide

/-- All ten vertex deletions change the actual vertex count. -/
theorem every_vertex_deletion_changes_count (v : Facets) (hv : v ∈ vertices) :
    faceCount (vertices.erase v) 0 = 9 := by
  rw [faceCount_zero (irredundant_mono (Finset.erase_subset _ _) vertices_irredundant)]
  rw [Finset.card_erase_of_mem hv]
  decide

/-- Without irredundancy, two listed incidence sets can represent only one
minimal nonempty face. -/
theorem redundant_vertex_negative :
    ({{0}, {0,1}} : Finset Facets).card = 2 ∧
      faceCount {{0}, {0,1}} 0 = 1 := by decide

/-- At the nonsimple ideal vertex, counting facet subsets would count the
same geometric intersection repeatedly. Closure identifies them. -/
theorem nonsimple_closure_controls :
    closure vertices {2,3,4,6} = {2,3,4,5,6} ∧
      {2,3,4,6} ∉ faces vertices ∧ {2,3,4,5,6} ∈ faces vertices := by decide

theorem empty_face_controls :
    (∅ : Facets) ∈ faces vertices ∧
      (Finset.univ : Facets) ∉ faces vertices ∧
      ¬ (incidentVertices vertices Finset.univ).Nonempty := by decide

/-- A fixed point of the chain recursion remains fixed at every larger
cutoff. This prevents a bounded search from silently defining dimension. -/
theorem depth_stable (F : Finset Facets) (k : ℕ)
    (h : ∀ S, depth F (k+1) S = depth F k S) (n : ℕ) :
    ∀ S, depth F (k+n) S = depth F k S := by
  induction n with
  | zero => simp
  | succ n ih =>
    intro S
    rw [Nat.add_succ, depth]
    simp_rw [ih]
    exact h S

theorem depth_stabilizes : ∀ S : Facets,
    depth (faces vertices) 5 S = depth (faces vertices) 4 S := by decide

/-- The computed dimension agrees with chain height at every cutoff ≥ 4. -/
theorem dimension_is_stable (n : ℕ) (S : Facets) :
    depth (faces vertices) (4+n) S = dimension vertices S := by
  have hn := depth_stable (faces vertices) 4 depth_stabilizes n S
  have h7 := depth_stable (faces vertices) 4 depth_stabilizes 3 S
  exact hn.trans h7.symm

/-- Infinitely many wrong face vectors pass the Euler alternating-sum check. -/
theorem euler_false_positive_family (t : ℕ) (ht : 0 < t) :
    (10 : ℤ) - (21 + t) + (18 + t) - 7 + 1 = 1 ∧
      faceCount vertices 1 ≠ 21 + t ∧ faceCount vertices 2 ≠ 18 + t := by
  obtain ⟨_, h1, h2, _, _⟩ := face_vector
  constructor
  · ring
  · rw [h1, h2]
    omega

end PseudoArithmetic.FaceAudit
