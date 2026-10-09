import PseudoArithmetic.GramAudit

/-! Exact encoding and arithmetic controls for the published census data.
The values are records of external data, not proofs of the classification. -/

namespace PseudoArithmetic.CensusAudit

open Manuscript GramAudit

def pairOrder : List (Fin 7 × Fin 7) :=
  [(0,1),(0,2),(0,3),(0,4),(0,5),(0,6),
   (1,2),(1,3),(1,4),(1,5),(1,6),(2,3),(2,4),(2,5),(2,6),
   (3,4),(3,5),(3,6),(4,5),(4,6),(5,6)]

theorem pair_order_complete :
    pairOrder.length = 21 ∧ pairOrder.Nodup ∧
      ∀ i j : Fin 7, (i,j) ∈ pairOrder ↔ i < j := by decide

theorem pair_order_controls :
    pairOrder[2]? = some (0,3) ∧ pairOrder[6]? = some (1,2) ∧
      pairOrder[3]? ≠ some (0,3) ∧ (1,0) ∉ pairOrder := by decide

/-- `100` and `101` encode the two letters, not Coxeter angle labels. -/
def encodedRow (j : CoxeterCase) : List ℕ :=
  [2,2,3,2,100,101,5,2,3,2,j.edge16,2,2,2,0,4,4,2,2,2,2]

/-- Source-code interpretation: 0 is the parallel entry, and 100/101 are
the two dotted-edge symbols. They are not large Coxeter angle labels. -/
noncomputable def decodeGramEntry (j : CoxeterCase) (code : ℕ) : ℝ :=
  if code = 0 then -1 else if code = 100 then -radicalA
  else if code = 101 then -radicalB j else -Real.cos (Real.pi / code)

theorem decoded_row_eq_gram (j : CoxeterCase) :
    (encodedRow j).map (decodeGramEntry j) = pairOrder.map (fun p => gram j p.1 p.2) := by
  change (encodedRow j).map (decodeGramEntry j) =
    [0,0,-1/2,0,-radicalA,-radicalB j,-(1+radicalS)/4,0,-1/2,0,-edgeCos j,
      0,0,0,-1,-radicalR/2,-radicalR/2,0,0,0,0]
  cases j <;> norm_num [encodedRow, decodeGramEntry, edgeCos,
    CoxeterCase.edge16, Real.cos_pi_div_three, Real.cos_pi_div_four,
    Real.cos_pi_div_five, radicalS, radicalR, neg_div] <;> ring

theorem parallel_code_is_not_zero_entry (j : CoxeterCase) :
    decodeGramEntry j 0 = -1 ∧ decodeGramEntry j 0 ≠ 0 := by
  norm_num [decodeGramEntry]

theorem row_controls :
    encodedRow .p11_6 ≠ encodedRow .p11_7 ∧
      encodedRow .p11_7 ≠ encodedRow .p11_8 ∧
      (encodedRow .p11_8)[10]? = some 4 ∧
      (encodedRow .p11_8)[14]? = some 0 := by decide

def cuspCount : CoxeterCase → ℕ
  | .p11_6 => 1
  | .p11_7 => 1
  | .p11_8 => 2

def volumeCoefficient : CoxeterCase → ℚ
  | .p11_6 => 13/864
  | .p11_7 => 1/54
  | .p11_8 => 19/864

theorem all_cases_have_cusps (j : CoxeterCase) : 0 < cuspCount j := by cases j <;> decide

theorem positive_volume_coefficients (j : CoxeterCase) : 0 < volumeCoefficient j := by
  cases j <;> norm_num [volumeCoefficient]

theorem census_value_controls :
    cuspCount .p11_8 = 2 ∧ cuspCount .p11_8 ≠ 1 ∧
      volumeCoefficient .p11_6 = 13/864 ∧
      volumeCoefficient .p11_7 = 1/54 ∧
      volumeCoefficient .p11_8 = 19/864 ∧
      volumeCoefficient .p11_8 ≠ volumeCoefficient .p11_7 := by
  norm_num [cuspCount, volumeCoefficient]

set_option maxRecDepth 4096 in
theorem principal_subset_count :
    ((Finset.univ : Finset (Fin 7)).powerset.erase ∅).card = 127 := by decide

theorem face_vector_euler_controls :
    (10 - 21 + 18 - 7 + 1 : ℤ) = 1 ∧ (10 - 20 + 18 - 7 + 1 : ℤ) ≠ 1 := by norm_num

theorem field_signature_controls :
    (4 + 2*2 : ℕ) = 8 ∧ (4 + 2 : ℕ) ≠ 8 ∧ (2^16 * 5^4 : ℕ) = 40960000 := by norm_num

end PseudoArithmetic.CensusAudit
