import PseudoArithmetic.Manuscript

/-!
# Semantic audit of the two-cycle obstruction

These are examples and counterexamples to possible mistranslations, not
additional assumptions of the manuscript theorem.  The concrete positive
example proves that its hypotheses can hold.  Negative controls refute
specific weakened hypotheses or strengthened conclusions.
-/

namespace PseudoArithmetic.SemanticAudit

open Manuscript

/-- The polynomial in the English statement, with its coefficients unchanged. -/
def cyclePolynomial {R : Type*} [CommRing R] (s u : R) : R :=
  (s - 1) * u ^ 2 + 2 * (s - 3) * u + s - 7

/-- An independent expansion checks the discriminant transcription. -/
theorem discriminant_identity (s : ℝ) :
    (2 * (s - 3)) ^ 2 - 4 * (s - 1) * (s - 7) = 8 * (1 + s) := by
  ring

/-- The two signatures describe equivalent algebraic data in characteristic
zero; using the square identity does not silently weaken the minimal polynomial. -/
theorem square_iff_minpoly {K : Type*} [Field K] [CharZero K] (s : K) :
    s ^ 2 = (5 : K) ↔ minpoly ℚ s = Polynomial.X ^ 2 - Polynomial.C 5 := by
  refine ⟨minpoly_eq_of_square_five, ?_⟩
  intro h
  have hz := minpoly.aeval ℚ s
  rw [h] at hz
  simpa [sub_eq_zero] using hz

/-- Every real root forces the parameter to lie on the correct side of the boundary. -/
theorem parameter_bound_of_real_root {s u : ℝ} (h : cyclePolynomial s u = 0) :
    -1 ≤ s := by
  have hid :
      (2 * (s - 1) * u + 2 * (s - 3)) ^ 2 - 8 * (1 + s) =
        4 * (s - 1) * cyclePolynomial s u := by
    dsimp [cyclePolynomial]
    ring
  rw [h, mul_zero] at hid
  nlinarith [sq_nonneg (2 * (s - 1) * u + 2 * (s - 3))]

/-- Exact classification, including the double root at `s = -1` and the
linear equation at `s = 1`. -/
theorem real_root_iff (s : ℝ) :
    (∃ u : ℝ, cyclePolynomial s u = 0) ↔ -1 ≤ s := by
  constructor
  · rintro ⟨u, hu⟩
    exact parameter_bound_of_real_root hu
  · intro hs
    by_cases hdeg : s = 1
    · subst s
      exact ⟨-3 / 2, by norm_num [cyclePolynomial]⟩
    · refine ⟨(3 - s + Real.sqrt (2 + 2 * s)) / (s - 1), ?_⟩
      apply cycle_relation_of_radical_identities hdeg
        (t := Real.sqrt (2 + 2 * s))
      · field_simp [sub_ne_zero.mpr hdeg]
        ring
      · exact Real.sq_sqrt (by linarith)

/-- An infinite family of exact positive examples; no sampling is involved. -/
theorem rational_root_family (v : ℚ) (hv : v ≠ -1) :
    cyclePolynomial ((v ^ 2 + 6 * v + 7) / (v + 1) ^ 2) v = 0 := by
  have hden : v + 1 ≠ 0 := by
    intro h
    apply hv
    linarith
  dsimp [cyclePolynomial]
  field_simp [hden]
  ring

/-- Every nonzero rational perturbation of the parameter breaks the equation
at the same proposed root.  This gives an infinite family of near misses. -/
theorem rational_perturbation_family (v δ : ℚ) (hv : v ≠ -1) (hδ : δ ≠ 0) :
    cyclePolynomial ((v ^ 2 + 6 * v + 7) / (v + 1) ^ 2 + δ) v ≠ 0 := by
  have hden : v + 1 ≠ 0 := by
    intro h
    apply hv
    linarith
  have hshift (s : ℚ) :
      cyclePolynomial (s + δ) v = cyclePolynomial s v + δ * (v + 1) ^ 2 := by
    dsimp [cyclePolynomial]
    ring
  rw [hshift, rational_root_family v hv, zero_add]
  exact mul_ne_zero hδ (pow_ne_zero _ hden)

/-- An infinite family of exact negative examples: every value of `u` fails. -/
theorem negative_parameter_family (n : ℕ) (u : ℝ) :
    cyclePolynomial (-2 - (n : ℝ)) u ≠ 0 := by
  intro h
  have hb := parameter_bound_of_real_root h
  have hn : (0 : ℝ) ≤ n := Nat.cast_nonneg n
  linarith

/-- The strict inequality cannot be replaced by a non-strict one. -/
theorem double_root_boundary : cyclePolynomial (-1 : ℝ) (-2) = 0 := by
  norm_num [cyclePolynomial]

/-- The vanished quadratic coefficient still leaves a real linear root. -/
theorem linear_boundary : cyclePolynomial (1 : ℝ) (-3 / 2) = 0 := by
  norm_num [cyclePolynomial]

/-- Omitting `s² = 5` would incorrectly exclude this real root at negative `s`. -/
theorem negative_sign_alone_insufficient :
    ∃ s u : ℝ, s < 0 ∧ cyclePolynomial s u = 0 ∧ s ^ 2 ≠ 5 := by
  exact ⟨-1, -2, by norm_num [cyclePolynomial]⟩

/-- Omitting the square/minimal-polynomial hypothesis gives a totally real
number field satisfying the remaining equation. -/
theorem square_hypothesis_necessary :
    NumberField.IsTotallyReal ℚ ∧
      ∃ s u : ℚ, cyclePolynomial s u = 0 ∧ s ^ 2 ≠ 5 := by
  exact ⟨inferInstance, 7, 0, by norm_num [cyclePolynomial]⟩

theorem radicalS_square : radicalS ^ 2 = 5 := Real.sq_sqrt (by norm_num)

theorem radicalS_integral : IsIntegral ℚ radicalS := by
  refine ⟨Polynomial.X ^ 2 - Polynomial.C 5,
    Polynomial.monic_X_pow_sub_C (5 : ℚ) (by norm_num), ?_⟩
  simp [radicalS_square]

/-- An annihilating polynomial used only to construct the concrete number field. -/
theorem radicalU_quartic :
    radicalU ^ 4 + 2 * radicalU ^ 3 - 5 * radicalU ^ 2 - 16 * radicalU - 11 = 0 := by
  have hlin : radicalS * (radicalU + 1) ^ 2 =
      radicalU ^ 2 + 6 * radicalU + 7 := by
    nlinarith [explicit_radical_cycle_relation]
  have hsq : (radicalU ^ 2 + 6 * radicalU + 7) ^ 2 =
      5 * (radicalU + 1) ^ 4 := by
    calc
      _ = (radicalS * (radicalU + 1) ^ 2) ^ 2 :=
        (congrArg (fun x : ℝ => x ^ 2) hlin).symm
      _ = _ := by rw [mul_pow, radicalS_square]; ring
  nlinarith [hsq]

theorem radicalU_integral : IsIntegral ℚ radicalU := by
  apply isAlgebraic_iff_isIntegral.mp
  refine ⟨Polynomial.X ^ 4 + Polynomial.C 2 * Polynomial.X ^ 3 -
    Polynomial.C 5 * Polynomial.X ^ 2 - Polynomial.C 16 * Polynomial.X -
    Polynomial.C 11, ?_, ?_⟩
  · intro h
    have hc := congrArg (fun p : Polynomial ℚ => p.coeff 4) h
    norm_num at hc
  · simpa using radicalU_quartic

/-- The actual field generated by the manuscript's two real radicals. -/
noncomputable def witnessField : IntermediateField ℚ ℝ :=
  IntermediateField.adjoin ℚ {radicalS, radicalU}

instance witnessField_numberField : NumberField witnessField where
  to_finiteDimensional :=
    IntermediateField.finiteDimensional_adjoin_pair radicalS_integral radicalU_integral

noncomputable def witnessS : witnessField :=
  ⟨radicalS, IntermediateField.mem_adjoin_pair_left ℚ radicalS radicalU⟩

noncomputable def witnessU : witnessField :=
  ⟨radicalU, IntermediateField.mem_adjoin_pair_right ℚ radicalS radicalU⟩

theorem witness_square : witnessS ^ 2 = (5 : witnessField) := by
  apply Subtype.ext
  exact radicalS_square

theorem witness_relation : cyclePolynomial witnessS witnessU = 0 := by
  apply Subtype.ext
  exact explicit_radical_cycle_relation

/-- The main theorem has a fully constructed input, with both equations proved. -/
theorem concrete_positive_example :
    witnessS ^ 2 = (5 : witnessField) ∧
      cyclePolynomial witnessS witnessU = 0 ∧
      ¬ NumberField.IsTotallyReal witnessField :=
  ⟨witness_square, witness_relation,
    not_totallyReal_of_cycle_square witnessS witnessU witness_square witness_relation⟩

/-- A real embedding exists even though the field is not totally real.  This
refutes the mistaken conclusion that there are no real embeddings. -/
theorem real_embedding_does_not_mean_totallyReal :
    Nonempty (witnessField →+* ℝ) ∧ ¬ NumberField.IsTotallyReal witnessField :=
  ⟨⟨witnessField.subtype⟩, concrete_positive_example.2.2⟩

/-- Exercise the manuscript-facing constructor too, using actual cycle values. -/
theorem concrete_cycle_constructor : ¬ NumberField.IsTotallyReal witnessField := by
  apply not_totallyReal_of_real_cycles witnessField.subtype
    ((3 + witnessS) / 2) (-2 * witnessU)
  · rfl
  · rfl

/-- Non-total reality does not mean total complexity: the chosen embedding
of this field is real. -/
theorem witness_not_totallyComplex : ¬ NumberField.IsTotallyComplex witnessField := by
  intro h
  letI := h
  let φ : witnessField →+* ℂ := Complex.ofRealHom.comp witnessField.subtype
  have hreal : NumberField.ComplexEmbedding.IsReal φ := by
    apply NumberField.ComplexEmbedding.isReal_iff.mpr
    ext x
    simp [φ]
  exact NumberField.IsTotallyComplex.complexEmbedding_not_isReal φ hreal

/-- The missing realness is existential, not universal. -/
theorem witness_has_nonreal_embedding :
    ∃ φ : witnessField →+* ℂ, ¬ NumberField.ComplexEmbedding.IsReal φ := by
  classical
  by_contra h
  push Not at h
  apply concrete_positive_example.2.2
  exact ⟨fun v => NumberField.InfinitePlace.isReal_iff.mpr (h v.embedding)⟩

/-- The smaller, totally real field used to test deletion of the relation. -/
noncomputable def baseField : IntermediateField ℚ ℝ :=
  IntermediateField.adjoin ℚ {radicalS}

instance baseField_numberField : NumberField baseField where
  to_finiteDimensional := IntermediateField.adjoin.finiteDimensional radicalS_integral

noncomputable def baseS : baseField :=
  ⟨radicalS, IntermediateField.subset_adjoin ℚ {radicalS} (Set.mem_singleton radicalS)⟩

theorem baseS_square : baseS ^ 2 = (5 : baseField) := by
  apply Subtype.ext
  exact radicalS_square

/-- Every complex embedding of `ℚ(√5)` is real: its generator can only map
to one of the two real square roots of five. -/
theorem baseField_embedding_real (φ : baseField →+* ℂ) :
    NumberField.ComplexEmbedding.IsReal φ := by
  have hgen : star (φ baseS) = φ baseS := by
    have hsq : (φ baseS) ^ 2 = (5 : ℂ) := by
      simpa only [map_pow, map_ofNat] using congrArg φ baseS_square
    have hsqrt : (radicalS : ℂ) ^ 2 = (5 : ℂ) := by
      exact_mod_cast radicalS_square
    rcases eq_or_eq_neg_of_sq_eq_sq _ _ (hsq.trans hsqrt.symm) with h | h
    · simp [h]
    · simp [h]
  apply NumberField.ComplexEmbedding.isReal_iff.mpr
  have hext : (NumberField.ComplexEmbedding.conjugate φ).toRatAlgHom = φ.toRatAlgHom := by
    apply IntermediateField.adjoin_algHom_ext ℚ
    intro x hx
    have hx' : x = radicalS := Set.mem_singleton_iff.mp hx
    subst x
    exact hgen
  exact congrArg AlgHom.toRingHom hext

theorem baseField_totallyReal : NumberField.IsTotallyReal baseField where
  isReal v := NumberField.InfinitePlace.isReal_iff.mpr (baseField_embedding_real v.embedding)

/-- Omitting the relation leaves a totally real number field satisfying
the square hypothesis.  The relation actually fails at the chosen `u = 0`. -/
theorem relation_hypothesis_necessary :
    NumberField.IsTotallyReal baseField ∧ baseS ^ 2 = (5 : baseField) ∧
      cyclePolynomial baseS 0 ≠ 0 := by
  refine ⟨baseField_totallyReal, baseS_square, ?_⟩
  intro h
  have hs : baseS = 7 := by simpa [cyclePolynomial, sub_eq_zero] using h
  have hsq := baseS_square
  rw [hs] at hsq
  norm_num at hsq

/-- The real radical is not in the smaller field.  Replacing `u : K` by
an unrelated real root would therefore make the theorem false. -/
theorem field_membership_necessary :
    NumberField.IsTotallyReal baseField ∧
      cyclePolynomial (baseS : ℝ) radicalU = 0 ∧ radicalU ∉ baseField := by
  refine ⟨baseField_totallyReal, explicit_radical_cycle_relation, ?_⟩
  intro hu
  let u : baseField := ⟨radicalU, hu⟩
  have hrel : cyclePolynomial baseS u = 0 := by
    apply Subtype.ext
    exact explicit_radical_cycle_relation
  exact not_totallyReal_of_cycle_square baseS u baseS_square hrel baseField_totallyReal

/-- The scalar no-real-root lemma needs its negative-sign hypothesis:
the positive radical gives a real root with `s² = 5`. -/
theorem negative_sign_necessary :
    ∃ s u : ℝ, s ^ 2 = 5 ∧ 0 < s ∧ cyclePolynomial s u = 0 := by
  exact ⟨radicalS, radicalU, radicalS_square,
    Real.sqrt_pos.mpr (by norm_num), explicit_radical_cycle_relation⟩

/-- A deliberate mistranscription still gives a provable field theorem:
changing the middle sign amounts to replacing `u` by `-u`.  A successful
build alone therefore cannot certify the English-to-Lean translation. -/
theorem changed_middle_sign_also_provable
    {K : Type*} [Field K] [NumberField K] (s u : K)
    (hsq : s ^ 2 = (5 : K))
    (hchanged : (s - 1) * u ^ 2 - 2 * (s - 3) * u + s - 7 = 0) :
    ¬ NumberField.IsTotallyReal K := by
  apply not_totallyReal_of_cycle_square s (-u) hsq
  calc
    (s - 1) * (-u) ^ 2 + 2 * (s - 3) * (-u) + s - 7 =
        (s - 1) * u ^ 2 - 2 * (s - 3) * u + s - 7 := by ring
    _ = 0 := hchanged

/-- The actual manuscript radicals reject that same sign change, so the
positive example distinguishes the intended statement from a true mutation. -/
theorem middle_sign_mutation_rejected :
    (radicalS - 1) * radicalU ^ 2 -
      2 * (radicalS - 3) * radicalU + radicalS - 7 ≠ 0 := by
  intro hchanged
  have hsq := radicalS_square
  have hcorrect := explicit_radical_cycle_relation
  have hproduct : (radicalS - 3) * radicalU = 0 := by
    nlinarith
  rcases mul_eq_zero.mp hproduct with hs | hu
  · nlinarith
  · rw [hu] at hcorrect
    nlinarith

end PseudoArithmetic.SemanticAudit
