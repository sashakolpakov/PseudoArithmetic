import PseudoArithmetic.SubdiagramControls
import PseudoArithmetic.FaceControls

/-! Connect the exact Gram classification, the complete incidence poset,
and the explicitly imported geometric interpretation of faces. -/
namespace PseudoArithmetic.FaceAudit

open SubdiagramAudit SubdiagramClassify

set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

/-- The incidence list used in the face count is exactly the maximal
positive-semidefinite principal subdiagram list of the actual Gram matrix. -/
theorem vertices_are_maximal_nonnegative (S : Facets) :
    S ∈ vertices ↔ ((principal S).PosSemidef ∧
      ∀ T : Facets, S ⊆ T → (principal T).PosSemidef → T = S) :=
  (maximal_nonnegative_iff S).symm

/-- The geometric input is a complete correspondence of nonempty faces
(including the polytope) with the computed incidence poset, preserving
dimension. It does not contain the claimed numerical face counts. -/
theorem face_count_transfer {GeometricFace : Type*} [Fintype GeometricFace]
    (V : Finset Facets) (e : GeometricFace ≃ {S : Facets // S ∈ faces V})
    (dim : GeometricFace → ℕ)
    (hd : ∀ f, dim f = dimension V (e f).val) (d : ℕ) :
    Fintype.card {f : GeometricFace // dim f = d} = faceCount V d := by
  classical
  let e₁ := e.subtypeEquiv (p := fun f => dim f = d)
    (q := fun S => dimension V S.val = d) (fun f => by rw [hd f])
  let e₂ := Equiv.subtypeSubtypeEquivSubtypeInter
    (fun S : Facets => S ∈ faces V) (fun S => dimension V S = d)
  let e₃ := Equiv.subtypeEquivRight (fun S : Facets =>
    (Finset.mem_filter (s := faces V) (p := fun S => dimension V S = d) (a := S)).symm)
  exact (Fintype.card_congr ((e₁.trans e₂).trans e₃)).trans (Fintype.card_coe _)

/-- The concrete face vector transfers to any geometric realization with
the stated complete, dimension-preserving face correspondence. -/
theorem geometric_face_vector {GeometricFace : Type*} [Fintype GeometricFace]
    (e : GeometricFace ≃ {S : Facets // S ∈ faces vertices})
    (dim : GeometricFace → ℕ)
    (hd : ∀ f, dim f = dimension vertices (e f).val) :
    Fintype.card {f // dim f = 0} = 10 ∧ Fintype.card {f // dim f = 1} = 21 ∧
      Fintype.card {f // dim f = 2} = 18 ∧ Fintype.card {f // dim f = 3} = 7 ∧
      Fintype.card {f // dim f = 4} = 1 := by
  simp_rw [face_count_transfer vertices e dim hd]
  exact face_vector

/-- Satisfying instance for every face and every dimension, using the
computed face poset itself as the realization. -/
theorem face_correspondence_positive (d : ℕ) :
    Fintype.card {f : {S : Facets // S ∈ faces vertices} //
      dimension vertices f.val = d} = faceCount vertices d :=
  face_count_transfer vertices (Equiv.refl _) _ (fun _ => rfl) d

/-- Dropping dimension preservation allows all 57 faces to be mislabeled
as vertices, although the actual vertex count is ten. -/
theorem wrong_dimension_negative :
    ((faces vertices).filter (fun _ => (0 : ℕ) = 0)).card = 57 ∧
      faceCount vertices 0 = 10 := by
  constructor
  · decide
  · exact face_vector.1

end PseudoArithmetic.FaceAudit
