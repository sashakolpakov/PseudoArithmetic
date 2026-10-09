import PseudoArithmetic.SemanticAudit
import PseudoArithmetic.FieldAudit
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.Tactic.FinCases

/-!
Concrete matrices, closed products, and their generated number fields.
The assertions identifying these matrices with geometric census polytopes
remain external; the algebra of the displayed matrices is proved here.
-/

namespace PseudoArithmetic.GramAudit

open Manuscript SemanticAudit

def chain {ι R : Type*} [CommRing R] (A : ι → ι → R) (last first : ι) : List ι → R
  | [] => A first last
  | next :: rest => A first next * chain A last next rest

def cyclicProduct {ι R : Type*} [CommRing R] (A : ι → ι → R)
    (first : ι) (rest : List ι) : R := chain A first first rest

theorem chain_scale {ι R : Type*} [CommRing R] (A : ι → ι → R) (q : R)
    (last first : ι) (rest : List ι) :
    chain (fun i j => q * A i j) last first rest =
      q ^ (rest.length + 1) * chain A last first rest := by
  induction rest generalizing first with
  | nil => simp [chain]
  | cons next rest ih => simp [chain, ih, pow_succ]; ring

theorem cyclicProduct_scale {ι R : Type*} [CommRing R] (A : ι → ι → R)
    (q : R) (first : ι) (rest : List ι) :
    cyclicProduct (fun i j => q * A i j) first rest =
      q ^ (rest.length + 1) * cyclicProduct A first rest :=
  chain_scale A q first first rest

theorem chain_rescale {ι R : Type*} [Field R] (A : ι → ι → R)
    (scale : ι → R) (hscale : ∀ i, scale i ≠ 0) (last first : ι) (rest : List ι) :
    chain (fun i j => (scale j / scale i) * A i j) last first rest =
      (scale last / scale first) * chain A last first rest := by
  induction rest generalizing first with
  | nil => rfl
  | cons next rest ih =>
    simp only [chain, ih]
    field_simp [hscale first, hscale next]

theorem cyclicProduct_rescale {ι R : Type*} [Field R] (A : ι → ι → R)
    (scale : ι → R) (hscale : ∀ i, scale i ≠ 0) (first : ι) (rest : List ι) :
    cyclicProduct (fun i j => (scale j / scale i) * A i j) first rest =
      cyclicProduct A first rest := by
  rw [cyclicProduct, chain_rescale A scale hscale, div_self (hscale first), one_mul]
  rfl

theorem three_cycle_reverse {ι R : Type*} [CommRing R] (A : ι → ι → R)
    (hsymm : ∀ i j, A i j = A j i) (i j k : ι) :
    cyclicProduct A i [j, k] = cyclicProduct A i [k, j] := by
  simp only [cyclicProduct, chain]
  rw [hsymm j k, hsymm k i, hsymm j i]
  ring

theorem chain_append {ι R : Type*} [CommRing R] (A : ι → ι → R)
    (last first next : ι) (rest : List ι) :
    chain A last first (rest ++ [next]) = chain A next first rest * A next last := by
  induction rest generalizing first with
  | nil => rfl
  | cons i tail ih => simp only [List.cons_append, chain, ih]; ring

theorem chain_reverse {ι R : Type*} [CommRing R] (A : ι → ι → R)
    (hsymm : ∀ i j, A i j = A j i) (last first : ι) (rest : List ι) :
    chain A last first rest = chain A first last rest.reverse := by
  induction rest generalizing first last with
  | nil => exact hsymm first last
  | cons i tail ih =>
    simp only [chain, List.reverse_cons, chain_append]
    rw [ih last i, hsymm first i]
    ring

theorem cyclicProduct_reverse {ι R : Type*} [CommRing R] (A : ι → ι → R)
    (hsymm : ∀ i j, A i j = A j i) (first : ι) (rest : List ι) :
    cyclicProduct A first rest = cyclicProduct A first rest.reverse :=
  chain_reverse A hsymm first first rest

noncomputable def generatedCycleField {ι : Type*} (A : ι → ι → ℝ) : IntermediateField ℚ ℝ :=
  IntermediateField.adjoin ℚ {x | ∃ first rest, x = cyclicProduct A first rest}

theorem generatedCycleField_scale {ι : Type*} (A : ι → ι → ℝ)
    (q : ℚ) (hq : q ≠ 0) :
    generatedCycleField (fun i j => (q : ℝ) * A i j) = generatedCycleField A := by
  have hq' : (q : ℝ) ≠ 0 := by exact_mod_cast hq
  apply le_antisymm
  · apply IntermediateField.adjoin_le_iff.mpr
    rintro x ⟨first, rest, rfl⟩
    rw [cyclicProduct_scale]
    exact (generatedCycleField A).mul_mem
      (pow_mem (SubfieldClass.ratCast_mem (generatedCycleField A) q)
        (rest.length+1))
      (IntermediateField.subset_adjoin ℚ _ ⟨first, rest, rfl⟩)
  · apply IntermediateField.adjoin_le_iff.mpr
    rintro x ⟨first, rest, rfl⟩
    have h : cyclicProduct A first rest =
        cyclicProduct (fun i j => (q : ℝ) * A i j) first rest / (q : ℝ) ^ (rest.length+1) := by
      rw [cyclicProduct_scale]
      field_simp
    rw [h]
    exact (generatedCycleField (fun i j => (q : ℝ) * A i j)).div_mem
      (IntermediateField.subset_adjoin ℚ _ ⟨first, rest, rfl⟩)
      (pow_mem
        (SubfieldClass.ratCast_mem (generatedCycleField (fun i j => (q : ℝ) * A i j)) q)
        (rest.length+1))

theorem repeated_indices_are_allowed :
    cyclicProduct (fun _ _ : Fin 1 => (2 : ℚ)) 0 [0, 0] = 8 := by
  norm_num [cyclicProduct, chain]

theorem doubling_changes_cycle_values :
    cyclicProduct (fun _ _ : Fin 1 => (2 : ℚ)) 0 [0] = 4 ∧
      cyclicProduct (fun _ _ : Fin 1 => (1 : ℚ)) 0 [0] = 1 := by
  norm_num [cyclicProduct, chain]

theorem open_product_not_rescaling_invariant :
    ((3 : ℚ) / 2) * 1 ≠ 1 := by norm_num

theorem symmetry_needed_for_reversal :
    let A : Matrix (Fin 3) (Fin 3) ℚ := !![1,2,13; 7,1,3; 5,11,1]
    cyclicProduct A 0 [1,2] = 30 ∧ cyclicProduct A 0 [2,1] = 1001 := by
  change (2 : ℚ)*(3*5) = 30 ∧ (13 : ℚ)*(11*7) = 1001
  norm_num

noncomputable def radicalR : ℝ := Real.sqrt 2

noncomputable def radicalB : CoxeterCase → ℝ
  | .p11_6 => Real.sqrt (9 / 2 + 2 * radicalS + Real.sqrt (38 + 17 * radicalS))
  | .p11_7 => radicalR + Real.sqrt 10 / 2 + Real.sqrt (29 + 13 * radicalS) / 2
  | .p11_8 => (2 + 3 * radicalR + 2 * radicalS + radicalR * radicalS +
      2 * Real.sqrt (19 + 14 * radicalR + 9 * radicalS + 6 * radicalR * radicalS)) / 4

noncomputable def edgeCos : CoxeterCase → ℝ
  | .p11_6 => 0
  | .p11_7 => 1 / 2
  | .p11_8 => radicalR / 2

theorem edgeCos_matches_angle (j : CoxeterCase) :
    edgeCos j = Real.cos (Real.pi / j.edge16) := by
  cases j <;> simp [edgeCos, CoxeterCase.edge16, radicalR]

theorem special_angles :
    Real.cos (Real.pi / 3) = 1 / 2 ∧
      Real.cos (Real.pi / 4) = radicalR / 2 ∧
      Real.cos (Real.pi / 5) = (1 + radicalS) / 4 := by
  simp [radicalR, radicalS]

theorem angle_label_mutation : Real.cos (Real.pi / 3) ≠ Real.cos (Real.pi / 2) := by simp

noncomputable def gram (j : CoxeterCase) : Matrix (Fin 7) (Fin 7) ℝ :=
  !![1, 0, 0, -1/2, 0, -radicalA, -radicalB j;
     0, 1, -(1+radicalS)/4, 0, -1/2, 0, -edgeCos j;
     0, -(1+radicalS)/4, 1, 0, 0, 0, -1;
     -1/2, 0, 0, 1, -radicalR/2, -radicalR/2, 0;
     0, -1/2, 0, -radicalR/2, 1, 0, 0;
     -radicalA, 0, 0, -radicalR/2, 0, 1, 0;
     -radicalB j, -edgeCos j, -1, 0, 0, 0, 1]

noncomputable def doubledGram (j : CoxeterCase) (i k : Fin 7) : ℝ := 2 * gram j i k

theorem gram_symmetric (j : CoxeterCase) (i k : Fin 7) : gram j i k = gram j k i := by
  fin_cases i <;> fin_cases k <;> rfl

theorem gram_diagonal (j : CoxeterCase) (i : Fin 7) : gram j i i = 1 := by
  fin_cases i <;> rfl

theorem four_entries (j : CoxeterCase) :
    doubledGram j 1 2 = -(1 + radicalS) / 2 ∧
      doubledGram j 0 3 = -1 ∧ doubledGram j 3 5 = -radicalR ∧
      doubledGram j 5 0 = -2 * radicalA := by
  change 2 * (-(1+radicalS)/4) = -(1+radicalS)/2 ∧
    (2 : ℝ) * (-1/2) = -1 ∧ 2 * (-radicalR/2) = -radicalR ∧
    2 * (-radicalA) = -2 * radicalA
  constructor
  · ring
  constructor
  · norm_num
  constructor <;> ring

theorem cycle12_value (j : CoxeterCase) :
    cyclicProduct (doubledGram j) 1 [2] = (3 + radicalS) / 2 := by
  change (2 * (-(1+radicalS)/4)) * (2 * (-(1+radicalS)/4)) = (3+radicalS)/2
  nlinarith [radicalS_square]

theorem cycle035_value (j : CoxeterCase) :
    cyclicProduct (doubledGram j) 0 [3, 5] = -2 * radicalU := by
  change (2 * (-1/2)) * ((2 * (-radicalR/2)) * (2 * (-radicalA))) =
    -2 * (Real.sqrt 2 * radicalA)
  dsimp [radicalR]
  ring

theorem cycle126_value :
    cyclicProduct (doubledGram .p11_8) 1 [2, 6] = -radicalR * (1 + radicalS) := by
  change (2 * (-(1+radicalS)/4)) * ((2 * (-1)) * (2 * (-(radicalR/2)))) =
    -radicalR * (1+radicalS)
  ring

theorem cycle03416_value :
    cyclicProduct (doubledGram .p11_8) 0 [3, 4, 1, 6] = -4 * radicalB .p11_8 := by
  change (2 * (-1/2)) * ((2 * (-radicalR/2)) * ((2 * (-1/2)) *
    ((2 * (-(radicalR/2))) * (2 * (-radicalB .p11_8))))) = -4 * radicalB .p11_8
  have hr : radicalR ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  calc
    _ = -2 * radicalR ^ 2 * radicalB .p11_8 := by ring
    _ = _ := by rw [hr]; ring

theorem cycle_recovery_controls :
    (7 : ℚ) = 2 * ((3 + 7) / 2) - 3 ∧
      (7 : ℚ) ≠ ((3 + 7) / 2) - 3 ∧
      (3 : ℚ) = -(-2 * 3) / 2 ∧ (3 : ℚ) ≠ (-2 * 3) / 2 := by norm_num

theorem radical_bounds : 1 < radicalS ∧ radicalS < 3 ∧ 1 < radicalR ∧ radicalR < 2 := by
  have hs0 : 0 ≤ radicalS := Real.sqrt_nonneg 5
  have hr0 : 0 ≤ radicalR := Real.sqrt_nonneg 2
  have hs := radicalS_square
  have hr : radicalR ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  constructor
  · nlinarith
  constructor
  · nlinarith
  constructor <;> nlinarith

theorem radicands_positive :
    0 < 2 + 2 * radicalS ∧ 0 < 7 + radicalS + 2 * radicalT ∧
      0 < 38 + 17 * radicalS ∧ 0 < 29 + 13 * radicalS ∧
      0 < 19 + 14 * radicalR + 9 * radicalS + 6 * radicalR * radicalS := by
  have hs := radical_bounds.1
  have hr := radical_bounds.2.2.1
  have ht : 0 ≤ radicalT := Real.sqrt_nonneg _
  have hrs : 0 ≤ radicalR * radicalS := mul_nonneg (by linarith) (by linarith)
  constructor
  · linarith
  constructor
  · linarith
  constructor
  · linarith
  constructor <;> nlinarith

theorem radicalA_gt_one : 1 < radicalA := by
  have hs := radical_bounds.1
  have ht : 0 ≤ radicalT := Real.sqrt_nonneg _
  have hsq := Real.sq_sqrt radicands_positive.2.1.le
  have hp := Real.sqrt_nonneg (7 + radicalS + 2 * radicalT)
  dsimp [radicalA]
  nlinarith

theorem radicalB_gt_one (j : CoxeterCase) : 1 < radicalB j := by
  have hs := radical_bounds.1
  have hr := radical_bounds.2.2.1
  cases j with
  | p11_6 =>
    have ht := Real.sqrt_nonneg (38 + 17 * radicalS)
    have hp : 0 ≤ 9 / 2 + 2 * radicalS + Real.sqrt (38 + 17 * radicalS) := by linarith
    have hsq := Real.sq_sqrt hp
    have hroot := Real.sqrt_nonneg (9 / 2 + 2 * radicalS + Real.sqrt (38 + 17 * radicalS))
    dsimp [radicalB]
    nlinarith
  | p11_7 =>
    have h1 := Real.sqrt_nonneg 10
    have h2 := Real.sqrt_nonneg (29 + 13 * radicalS)
    dsimp [radicalB]
    linarith
  | p11_8 =>
    have ht := Real.sqrt_nonneg (19 + 14 * radicalR + 9 * radicalS + 6 * radicalR * radicalS)
    have hrs : 0 ≤ radicalR * radicalS := mul_nonneg (by linarith) (by linarith)
    dsimp [radicalB]
    nlinarith

theorem radical_negative_branch_rejected : ¬ 1 < -radicalA := by
  have := radicalA_gt_one
  linarith

theorem integral_rat (q : ℚ) : IsIntegral ℚ (q : ℝ) := isIntegral_algebraMap

theorem integral_sqrt {x : ℝ} (hx : IsIntegral ℚ x) : IsIntegral ℚ (Real.sqrt x) := by
  by_cases h : 0 ≤ x
  · apply IsIntegral.of_pow (n := 2) (by norm_num)
    rwa [Real.sq_sqrt h]
  · rw [Real.sqrt_eq_zero_of_nonpos (le_of_not_ge h)]
    exact isIntegral_zero

theorem radicalR_integral : IsIntegral ℚ radicalR := integral_sqrt (integral_rat 2)

theorem radicalA_integral : IsIntegral ℚ radicalA := by
  simpa [radicalA, radicalT] using (integral_rat (1/2)).mul (integral_sqrt
    (((integral_rat 7).add radicalS_integral).add
      ((integral_rat 2).mul (integral_sqrt
        ((integral_rat 2).add ((integral_rat 2).mul radicalS_integral))))))

theorem radicalB_integral (j : CoxeterCase) : IsIntegral ℚ (radicalB j) := by
  have hs := radicalS_integral
  have hr := radicalR_integral
  cases j with
  | p11_6 =>
    simpa [radicalB] using integral_sqrt (((integral_rat (9/2)).add ((integral_rat 2).mul hs)).add
      (integral_sqrt ((integral_rat 38).add ((integral_rat 17).mul hs))))
  | p11_7 =>
    change IsIntegral ℚ (radicalR + Real.sqrt 10 / 2 + Real.sqrt (29 + 13 * radicalS) / 2)
    simp only [div_eq_mul_inv]
    exact (hr.add ((integral_sqrt (integral_rat 10)).mul (integral_rat 2).inv)).add
      ((integral_sqrt ((integral_rat 29).add ((integral_rat 13).mul hs))).mul
        (integral_rat 2).inv)
  | p11_8 =>
    change IsIntegral ℚ ((2 + 3 * radicalR + 2 * radicalS + radicalR * radicalS +
      2 * Real.sqrt (19 + 14 * radicalR + 9 * radicalS + 6 * radicalR * radicalS)) / 4)
    rw [div_eq_mul_inv]
    exact (((((integral_rat 2).add ((integral_rat 3).mul hr)).add
      ((integral_rat 2).mul hs)).add (hr.mul hs)).add
      ((integral_rat 2).mul (integral_sqrt
        ((((integral_rat 19).add ((integral_rat 14).mul hr)).add
          ((integral_rat 9).mul hs)).add (((integral_rat 6).mul hr).mul hs))))).mul
      (integral_rat 4).inv

theorem gram_entries_integral (j : CoxeterCase) (i k : Fin 7) :
    IsIntegral ℚ (gram j i k) := by
  have h0 : IsIntegral ℚ (0 : ℝ) := isIntegral_zero
  have h1 : IsIntegral ℚ (1 : ℝ) := isIntegral_one
  have hhalf : IsIntegral ℚ (-1/2 : ℝ) := by simpa using integral_rat (-1/2)
  have hs : IsIntegral ℚ (-(1+radicalS)/4) := by
    rw [div_eq_mul_inv]
    simpa using ((integral_rat 1).add radicalS_integral).neg.mul (integral_rat 4).inv
  have hr : IsIntegral ℚ (-radicalR/2) := by
    rw [div_eq_mul_inv]
    exact radicalR_integral.neg.mul (integral_rat 2).inv
  have hq : IsIntegral ℚ (-edgeCos j) := by
    cases j with
    | p11_6 => simpa [edgeCos] using h0
    | p11_7 => simpa [edgeCos] using integral_rat (1/2)
    | p11_8 => simpa [edgeCos, neg_div] using hr
  have ha := radicalA_integral.neg
  have hb := (radicalB_integral j).neg
  have hn : IsIntegral ℚ (-1 : ℝ) := h1.neg
  fin_cases i <;> fin_cases k <;>
    first | exact h0 | exact h1 | exact hhalf | exact hs | exact hr | exact hq |
      exact ha | exact hb | exact hn

noncomputable def entryField (j : CoxeterCase) : IntermediateField ℚ ℝ :=
  IntermediateField.adjoin ℚ (Set.range (fun p : Fin 7 × Fin 7 => gram j p.1 p.2))

instance entryField_numberField (j : CoxeterCase) : NumberField (entryField j) where
  to_finiteDimensional := IntermediateField.finiteDimensional_adjoin (by
    rintro x ⟨p, rfl⟩
    exact gram_entries_integral j p.1 p.2)

noncomputable def cycleField (j : CoxeterCase) : IntermediateField ℚ ℝ :=
  IntermediateField.adjoin ℚ
    {x | ∃ first rest, x = cyclicProduct (doubledGram j) first rest}

theorem cycle_mem (j : CoxeterCase) (first : Fin 7) (rest : List (Fin 7)) :
    cyclicProduct (doubledGram j) first rest ∈ cycleField j :=
  IntermediateField.subset_adjoin ℚ _ ⟨first, rest, rfl⟩

theorem cycleField_le_entryField (j : CoxeterCase) : cycleField j ≤ entryField j := by
  apply IntermediateField.adjoin_le_iff.mpr
  rintro x ⟨first, rest, rfl⟩
  have hentry (i k : Fin 7) : doubledGram j i k ∈ entryField j := by
    apply (entryField j).mul_mem ((entryField j).natCast_mem 2)
    exact IntermediateField.subset_adjoin ℚ _ ⟨(i,k), rfl⟩
  have hchain (last initial : Fin 7) (path : List (Fin 7)) :
      chain (doubledGram j) last initial path ∈ entryField j := by
    induction path generalizing initial with
    | nil => exact hentry _ _
    | cons k tail hk => exact (entryField j).mul_mem (hentry _ _) (hk k)
  exact hchain first first rest

instance cycleField_numberField (j : CoxeterCase) : NumberField (cycleField j) where
  to_finiteDimensional := FiniteDimensional.of_injective
    (IntermediateField.inclusion (cycleField_le_entryField j)).toLinearMap
    (IntermediateField.inclusion (cycleField_le_entryField j)).injective

/-- The displayed matrices now supply the certificate themselves. -/
theorem all_three_cycleFields_not_totallyReal (j : CoxeterCase) :
    ¬ NumberField.IsTotallyReal (cycleField j) := by
  let c12 : cycleField j := ⟨cyclicProduct (doubledGram j) 1 [2], cycle_mem j 1 [2]⟩
  let c035 : cycleField j := ⟨cyclicProduct (doubledGram j) 0 [3,5], cycle_mem j 0 [3,5]⟩
  apply not_totallyReal_of_real_cycles (cycleField j).subtype c12 c035
  · exact cycle12_value j
  · exact cycle035_value j

theorem radicalS_mem_cycleField (j : CoxeterCase) : radicalS ∈ cycleField j := by
  have h : radicalS = 2 * cyclicProduct (doubledGram j) 1 [2] - 3 := by
    rw [cycle12_value]
    ring
  rw [h]
  exact (cycleField j).sub_mem
    ((cycleField j).mul_mem ((cycleField j).natCast_mem 2) (cycle_mem j 1 [2]))
    ((cycleField j).natCast_mem 3)

theorem radicalU_mem_cycleField (j : CoxeterCase) : radicalU ∈ cycleField j := by
  have h : radicalU = -cyclicProduct (doubledGram j) 0 [3,5] / 2 := by
    rw [cycle035_value]
    ring
  rw [h]
  exact (cycleField j).div_mem ((cycleField j).neg_mem (cycle_mem j 0 [3,5]))
    ((cycleField j).natCast_mem 2)

theorem third_case_generators_mem :
    radicalS ∈ cycleField .p11_8 ∧ radicalR ∈ cycleField .p11_8 ∧
      radicalA ∈ cycleField .p11_8 ∧ radicalB .p11_8 ∈ cycleField .p11_8 := by
  let K := cycleField .p11_8
  have hs : radicalS ∈ K := radicalS_mem_cycleField .p11_8
  have hden : 1 + radicalS ≠ 0 := by have := radical_bounds.1; linarith
  have hr : radicalR ∈ K := by
    have h : radicalR = -cyclicProduct (doubledGram .p11_8) 1 [2,6] / (1+radicalS) := by
      rw [cycle126_value]
      field_simp
    rw [h]
    exact K.div_mem (K.neg_mem (cycle_mem .p11_8 1 [2,6])) (K.add_mem K.one_mem hs)
  have ha : radicalA ∈ K := by
    have hrne : radicalR ≠ 0 := by have := radical_bounds.2.2.1; linarith
    have h : radicalA = radicalU / radicalR := by
      change radicalA = (radicalR * radicalA) / radicalR
      field_simp
    rw [h]
    exact K.div_mem (radicalU_mem_cycleField .p11_8) hr
  have hb : radicalB .p11_8 ∈ K := by
    have h : radicalB .p11_8 = -cyclicProduct (doubledGram .p11_8) 0 [3,4,1,6] / 4 := by
      rw [cycle03416_value]
      ring
    rw [h]
    exact K.div_mem (K.neg_mem (cycle_mem .p11_8 0 [3,4,1,6])) (K.natCast_mem 4)
  exact ⟨hs, hr, ha, hb⟩

/-- For the third case the cycle field contains every matrix entry, not just
the two elements used by the obstruction. -/
theorem third_cycleField_eq_entryField : cycleField .p11_8 = entryField .p11_8 := by
  apply le_antisymm (cycleField_le_entryField .p11_8)
  apply IntermediateField.adjoin_le_iff.mpr
  rintro x ⟨⟨i,k⟩, rfl⟩
  let K := cycleField .p11_8
  obtain ⟨hs, hr, ha, hb⟩ := third_case_generators_mem
  have h0 := K.zero_mem
  have h1 := K.one_mem
  have hh : (-1/2 : ℝ) ∈ K := K.div_mem (K.neg_mem K.one_mem) (K.natCast_mem 2)
  have h5 : -(1+radicalS)/4 ∈ K := K.div_mem (K.neg_mem (K.add_mem K.one_mem hs)) (K.natCast_mem 4)
  have h2 : -radicalR/2 ∈ K := K.div_mem (K.neg_mem hr) (K.natCast_mem 2)
  have hq : -edgeCos .p11_8 ∈ K := by simpa [edgeCos, neg_div] using h2
  have hna := K.neg_mem ha
  have hnb := K.neg_mem hb
  have hn := K.neg_mem K.one_mem
  fin_cases i <;> fin_cases k <;>
    first | exact h0 | exact h1 | exact hh | exact h5 | exact h2 | exact hq |
      exact hna | exact hnb | exact hn

noncomputable def fourGeneratorField : IntermediateField ℚ ℝ :=
  IntermediateField.adjoin ℚ {radicalS, radicalR, radicalA, radicalB .p11_8}

theorem third_cycleField_eq_fourGeneratorField : cycleField .p11_8 = fourGeneratorField := by
  apply le_antisymm
  · rw [third_cycleField_eq_entryField]
    apply IntermediateField.adjoin_le_iff.mpr
    rintro x ⟨⟨i,k⟩, rfl⟩
    let K := fourGeneratorField
    have hs : radicalS ∈ K := IntermediateField.subset_adjoin ℚ _ (by simp)
    have hr : radicalR ∈ K := IntermediateField.subset_adjoin ℚ _ (by simp)
    have ha : radicalA ∈ K := IntermediateField.subset_adjoin ℚ _ (by simp)
    have hb : radicalB .p11_8 ∈ K := IntermediateField.subset_adjoin ℚ _ (by simp)
    have h0 := K.zero_mem
    have h1 := K.one_mem
    have hh : (-1/2 : ℝ) ∈ K := K.div_mem (K.neg_mem K.one_mem) (K.natCast_mem 2)
    have h5 : -(1+radicalS)/4 ∈ K := K.div_mem (K.neg_mem (K.add_mem K.one_mem hs)) (K.natCast_mem 4)
    have h2 : -radicalR/2 ∈ K := K.div_mem (K.neg_mem hr) (K.natCast_mem 2)
    have hq : -edgeCos .p11_8 ∈ K := by simpa [edgeCos, neg_div] using h2
    have hna := K.neg_mem ha
    have hnb := K.neg_mem hb
    have hn := K.neg_mem K.one_mem
    fin_cases i <;> fin_cases k <;>
      first | exact h0 | exact h1 | exact hh | exact h5 | exact h2 | exact hq |
        exact hna | exact hnb | exact hn
  · apply IntermediateField.adjoin_le_iff.mpr
    intro x hx
    obtain ⟨hs,hr,ha,hb⟩ := third_case_generators_mem
    rcases hx with rfl | rfl | rfl | rfl <;> assumption

theorem generatedCycleField_rescale {ι : Type*} (A : ι → ι → ℝ)
    (scale : ι → ℝ) (hscale : ∀ i, scale i ≠ 0) :
    generatedCycleField (fun i j => (scale j / scale i) * A i j) =
      generatedCycleField A := by
  simp only [generatedCycleField, cyclicProduct_rescale A scale hscale]

/-- A genuine symmetric unit-diagonal matrix whose entry field is larger
than its cycle field. Rescaling reduces all coefficients to rational ones. -/
noncomputable def strictEntryExample : Matrix (Fin 2) (Fin 2) ℝ :=
  !![1,-radicalS; -radicalS,1]

theorem strictEntryExample_cycleField : generatedCycleField strictEntryExample = ⊥ := by
  let scale : Fin 2 → ℝ := ![1,radicalS]
  let B : Matrix (Fin 2) (Fin 2) ℝ := !![1,-5; -1,1]
  have hs : radicalS ≠ 0 := ne_of_gt (lt_trans (by norm_num) radical_bounds.1)
  have hscale : ∀ i, scale i ≠ 0 := by
    intro i
    fin_cases i
    · norm_num [scale]
    · exact hs
  have hB : (fun i j => (scale j / scale i) * strictEntryExample i j) = B := by
    funext i j
    fin_cases i <;> fin_cases j <;> simp [scale, B, strictEntryExample, hs]
    nlinarith [radicalS_square]
  rw [← generatedCycleField_rescale strictEntryExample scale hscale, hB]
  apply le_antisymm ?_ bot_le
  apply IntermediateField.adjoin_le_iff.mpr
  rintro x ⟨first, rest, rfl⟩
  have hentry (i j : Fin 2) : B i j ∈ (⊥ : IntermediateField ℚ ℝ) := by
    have h1 := (⊥ : IntermediateField ℚ ℝ).one_mem
    have hm1 := (⊥ : IntermediateField ℚ ℝ).neg_mem h1
    have hm5 := (⊥ : IntermediateField ℚ ℝ).neg_mem
      ((⊥ : IntermediateField ℚ ℝ).natCast_mem 5)
    fin_cases i <;> fin_cases j <;> first | exact h1 | exact hm1 | exact hm5
  have hchain (last initial : Fin 2) (path : List (Fin 2)) :
      chain B last initial path ∈ (⊥ : IntermediateField ℚ ℝ) := by
    induction path generalizing initial with
    | nil => exact hentry _ _
    | cons k tail ih => exact (⊥ : IntermediateField ℚ ℝ).mul_mem (hentry _ _) (ih k)
  exact hchain first first rest

theorem strictEntryExample_entry_not_in_cycleField :
    strictEntryExample 0 1 ∉ generatedCycleField strictEntryExample := by
  rw [strictEntryExample_cycleField]
  change -radicalS ∉ (⊥ : IntermediateField ℚ ℝ)
  intro h
  have hs : radicalS ∈ (⊥ : IntermediateField ℚ ℝ) := by
    simpa using (⊥ : IntermediateField ℚ ℝ).neg_mem h
  obtain ⟨q,hq⟩ := hs
  exact FieldAudit.sqrt_five_irrational q hq

end PseudoArithmetic.GramAudit
