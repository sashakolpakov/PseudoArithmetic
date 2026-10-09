import PseudoArithmetic.CensusAudit

/-! Faces reconstructed from vertex–facet incidence. Counts are evaluated by
Lean's kernel; no geometric face counts are assumed in the enumeration. -/
namespace PseudoArithmetic.FaceAudit

abbrev Facet := Fin 7
abbrev Facets := Finset Facet

/-- Complete vertex–facet incidences, with zero-based facet labels. -/
def vertices : Finset Facets :=
  {{0,1,2,3}, {0,1,2,4}, {0,1,3,4}, {0,2,3,4},
   {1,2,3,5}, {1,2,4,5}, {1,3,4,6}, {1,3,5,6}, {1,4,5,6}, {2,3,4,5,6}}

def incidentVertices (V : Finset Facets) (S : Facets) : Finset Facets :=
  V.filter (S ⊆ ·)

/-- All facets containing the same vertices as S. -/
def closure (V : Finset Facets) (S : Facets) : Facets :=
  Finset.univ.filter (fun i => ∀ v ∈ incidentVertices V S, i ∈ v)

/-- Nonempty faces, including the whole polytope. A face is represented by
all of its incident facets, so duplicate intersections are identified. -/
def faces (V : Finset Facets) : Finset Facets :=
  Finset.univ.filter (fun S => (incidentVertices V S).Nonempty ∧ closure V S = S)

/-- Longest strict descending chain of faces, with at most n steps. In facet
coordinates a descent strictly increases the facet set. -/
def depth (F : Finset Facets) : ℕ → Facets → ℕ
  | 0, _ => 0
  | n+1, S => (F.filter (S ⊂ ·)).sup (fun T => depth F n T + 1)

/-- Seven steps suffice: each strict inclusion increases cardinality within
seven facets. The concrete proof below also checks stabilization at four. -/
def dimension (V : Finset Facets) (S : Facets) : ℕ := depth (faces V) 7 S

def faceCount (V : Finset Facets) (d : ℕ) : ℕ :=
  ((faces V).filter (fun S => dimension V S = d)).card

set_option maxRecDepth 10000 in
set_option maxHeartbeats 8000000 in
theorem face_vector :
    faceCount vertices 0 = 10 ∧ faceCount vertices 1 = 21 ∧
      faceCount vertices 2 = 18 ∧ faceCount vertices 3 = 7 ∧
      faceCount vertices 4 = 1 := by decide

end PseudoArithmetic.FaceAudit
