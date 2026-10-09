import PseudoArithmetic.SemanticAudit
import Mathlib.FieldTheory.PrimitiveElement
import Mathlib.RingTheory.AdjoinRoot

/-! Statement-level audit of the field facts used throughout the manuscript. -/

namespace PseudoArithmetic.FieldAudit

open Manuscript SemanticAudit

theorem embedding_injective {K : Type*} [Field K] (φ : K →+* ℂ) :
    Function.Injective φ := φ.injective

theorem embedding_fixes_rationals {K : Type*} [Field K] [CharZero K]
    (φ : K →+* ℂ) (q : ℚ) : φ (q : K) = (q : ℂ) := by simp

/-- A constant function is not a field embedding: preserving one is essential. -/
theorem zero_function_not_embedding :
    ¬ ∃ φ : ℚ →+* ℂ, ∀ q, φ q = 0 := by
  rintro ⟨φ, hφ⟩
  have := hφ 1
  simp at this

theorem sqrt_five_irrational : ∀ q : ℚ, (q : ℝ) ≠ radicalS := by
  intro q h
  have hsq : q ^ 2 = (5 : ℚ) := by
    have : (q : ℝ) ^ 2 = 5 := by rw [h]; exact radicalS_square
    exact_mod_cast this
  have hn : ¬ IsSquare (5 : ℚ) := by
    intro hh
    exact (show Nat.Prime 5 by decide).not_isSquare (Rat.isSquare_natCast_iff.mp hh)
  exact hn ⟨q, by nlinarith⟩

theorem sqrt_four_rational : Real.sqrt 4 = (2 : ℝ) := by
  rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]

theorem negative_real_sqrt_control :
    Real.sqrt (-1) = 0 ∧ (Real.sqrt (-1)) ^ 2 ≠ (-1 : ℝ) := by
  rw [Real.sqrt_eq_zero_of_nonpos (by norm_num : (-1 : ℝ) ≤ 0)]
  norm_num

/-- A vanishing polynomial is minimal precisely up to divisibility; monicity
and least degree cannot be omitted from the definition. -/
theorem vanishes_iff_minpoly_dvd {K : Type*} [Field K] [CharZero K]
    (x : K) (p : Polynomial ℚ) :
    Polynomial.aeval x p = 0 ↔ minpoly ℚ x ∣ p := by
  constructor
  · exact minpoly.dvd ℚ x
  · rintro ⟨q, rfl⟩
    simp

theorem annihilating_polynomial_need_not_be_minimal :
    Polynomial.aeval radicalS ((Polynomial.X ^ 2 - Polynomial.C 5) ^ 2 : Polynomial ℚ) = 0 ∧
      (Polynomial.X ^ 2 - Polynomial.C 5) ^ 2 ≠ minpoly ℚ radicalS := by
  constructor
  · simp [radicalS_square]
  · rw [minpoly_eq_of_square_five radicalS_square]
    intro h
    have hexpand : (Polynomial.X ^ 2 - Polynomial.C 5) ^ 2 =
        Polynomial.X ^ 4 - Polynomial.C (10 : ℚ) * Polynomial.X ^ 2 + Polynomial.C 25 := by
      simp only [Polynomial.C_ofNat]
      ring
    rw [hexpand] at h
    have := congrArg (fun p : Polynomial ℚ => p.coeff 4) h
    norm_num at this

theorem base_embedding_ext {φ ψ : baseField →+* ℂ}
    (h : φ baseS = ψ baseS) : φ = ψ := by
  have hext : φ.toRatAlgHom = ψ.toRatAlgHom := by
    apply IntermediateField.adjoin_algHom_ext ℚ
    intro x hx
    have hx' : x = radicalS := Set.mem_singleton_iff.mp hx
    subst x
    exact h
  exact congrArg AlgHom.toRingHom hext

theorem base_embedding_negative_exists :
    ∃ φ : baseField →+* ℂ, φ baseS = -(radicalS : ℂ) := by
  have hm := minpoly_eq_of_square_five baseS_square
  have hzsq : (-(radicalS : ℂ)) ^ 2 = (5 : ℂ) := by
    rw [neg_sq]
    exact_mod_cast radicalS_square
  have hz : -(radicalS : ℂ) ∈ (minpoly ℚ baseS).rootSet ℂ := by
    rw [hm, (Polynomial.monic_X_pow_sub_C (5 : ℚ) (by norm_num : 2 ≠ 0)).mem_rootSet]
    simp [hzsq]
  have hr : -(radicalS : ℂ) ∈ Set.range (fun φ : baseField →+* ℂ => φ baseS) := by
    rw [NumberField.Embeddings.range_eval_eq_rootSet_minpoly baseField ℂ baseS]
    exact hz
  exact hr

/-- Both embeddings exist, are distinct, and exhaust all embeddings. -/
theorem sqrt_five_exactly_two_embeddings :
    ∃ φ ψ : baseField →+* ℂ,
      φ baseS = (radicalS : ℂ) ∧ ψ baseS = -(radicalS : ℂ) ∧
      φ ≠ ψ ∧ ∀ χ : baseField →+* ℂ, χ = φ ∨ χ = ψ := by
  let φ : baseField →+* ℂ := Complex.ofRealHom.comp baseField.subtype
  obtain ⟨ψ, hψ⟩ := base_embedding_negative_exists
  refine ⟨φ, ψ, rfl, hψ, ?_, ?_⟩
  · intro h
    have hz : (radicalS : ℂ) = -(radicalS : ℂ) := by
      calc
        _ = φ baseS := rfl
        _ = ψ baseS := congrArg (fun f : baseField →+* ℂ => f baseS) h
        _ = _ := hψ
    have hr : radicalS = -radicalS := by exact_mod_cast hz
    have hp : 0 < radicalS := Real.sqrt_pos.mpr (by norm_num)
    linarith
  · intro χ
    have hsq : (χ baseS) ^ 2 = (radicalS : ℂ) ^ 2 := by
      have h1 : (χ baseS) ^ 2 = (5 : ℂ) := by
        simpa only [map_pow, map_ofNat] using congrArg χ baseS_square
      have h2 : (radicalS : ℂ) ^ 2 = (5 : ℂ) := by exact_mod_cast radicalS_square
      exact h1.trans h2.symm
    rcases eq_or_eq_neg_of_sq_eq_sq _ _ hsq with h | h
    · exact Or.inl (base_embedding_ext h)
    · exact Or.inr (base_embedding_ext (h.trans hψ.symm))

theorem embedding_extension {L K : Type*} [Field L] [NumberField L]
    [Field K] [NumberField K] [Algebra L K] (σ : L →+* ℂ) :
    ∃ τ : K →+* ℂ, τ.comp (algebraMap L K) = σ := by
  exact ⟨NumberField.ComplexEmbedding.lift K σ,
    NumberField.ComplexEmbedding.lift_comp_algebraMap K σ⟩

/-- Extension need not be unique: the rational embedding has two extensions. -/
theorem embedding_extension_not_unique :
    ∃ φ ψ : baseField →+* ℂ, φ ≠ ψ ∧
      φ.comp (algebraMap ℚ baseField) = ψ.comp (algebraMap ℚ baseField) := by
  obtain ⟨φ, ψ, _, _, hne, _⟩ := sqrt_five_exactly_two_embeddings
  exact ⟨φ, ψ, hne, Subsingleton.elim _ _⟩

theorem nonreal_subfield_persists {L K : Type*} [Field L] [NumberField L]
    [Field K] [NumberField K] [Algebra L K]
    (h : ¬ NumberField.IsTotallyReal L) : ¬ NumberField.IsTotallyReal K := by
  intro hK
  letI := hK
  exact h (NumberField.IsTotallyReal.of_algebra L K)

/-- The converse fails: a non-totally-real field still contains the totally
real rational field. -/
theorem persistence_converse_false :
    NumberField.IsTotallyReal ℚ ∧ ¬ NumberField.IsTotallyReal witnessField :=
  ⟨inferInstance, concrete_positive_example.2.2⟩

theorem quadratic_root_iff (a b c : ℝ) (ha : a ≠ 0) :
    (∃ x : ℝ, a * x ^ 2 + b * x + c = 0) ↔ 0 ≤ b ^ 2 - 4 * a * c := by
  constructor
  · rintro ⟨x, hx⟩
    have hid : (2 * a * x + b) ^ 2 - (b ^ 2 - 4 * a * c) =
        4 * a * (a * x ^ 2 + b * x + c) := by ring
    rw [hx, mul_zero] at hid
    nlinarith [sq_nonneg (2 * a * x + b)]
  · intro hd
    refine ⟨(-b + Real.sqrt (b ^ 2 - 4 * a * c)) / (2 * a), ?_⟩
    have hs := Real.sq_sqrt hd
    have hroot (t : ℝ) (ht : t ^ 2 = b ^ 2 - 4 * a * c) :
        a * ((-b + t) / (2 * a)) ^ 2 + b * ((-b + t) / (2 * a)) + c = 0 := by
      field_simp
      nlinarith
    exact hroot _ hs

theorem quadratic_positive_and_negative :
    (∃ x : ℝ, x ^ 2 - 1 = 0) ∧ ¬ ∃ x : ℝ, x ^ 2 + 1 = 0 := by
  refine ⟨⟨1, by norm_num⟩, ?_⟩
  rintro ⟨x, hx⟩
  nlinarith [sq_nonneg x]

theorem quadratic_leading_coefficient_necessary :
    (0 : ℝ) ^ 2 - 4 * 0 * 1 ≥ 0 ∧
      ¬ ∃ x : ℝ, 0 * x ^ 2 + 0 * x + 1 = 0 := by norm_num

theorem discriminant_zero_has_root :
    (2 : ℝ) ^ 2 - 4 * 1 * 1 = 0 ∧ (1 : ℝ) * (-1) ^ 2 + 2 * (-1) + 1 = 0 := by
  norm_num

/-- A positive real square forces a complex square root to be real. -/
theorem complex_square_positive_is_real {z : ℂ} {d : ℝ}
    (hd : 0 < d) (hz : z ^ 2 = (d : ℂ)) : star z = z := by
  have hs : (Real.sqrt d : ℂ) ^ 2 = (d : ℂ) := by
    exact_mod_cast Real.sq_sqrt hd.le
  rcases eq_or_eq_neg_of_sq_eq_sq _ _ (hz.trans hs.symm) with h | h <;> simp [h]

theorem negative_radicand_counterexample :
    Complex.I ^ 2 = (-1 : ℂ) ∧ star Complex.I ≠ Complex.I := by
  constructor
  · norm_num
  · intro h
    have := congrArg Complex.im h
    norm_num at this

theorem embedding_real_of_generators {B K : Type*} [Field B] [Field K] [Algebra B K]
    (S : Set K) (hgenerate : IntermediateField.adjoin B S = ⊤) (φ : K →+* ℂ)
    (hbase : ∀ b : B, star (φ (algebraMap B K b)) = φ (algebraMap B K b))
    (hgens : ∀ x ∈ S, star (φ x) = φ x) : NumberField.ComplexEmbedding.IsReal φ := by
  apply NumberField.ComplexEmbedding.isReal_iff.mpr
  ext x
  change star (φ x) = φ x
  have hx : x ∈ IntermediateField.adjoin B S := by rw [hgenerate]; trivial
  apply IntermediateField.adjoin_induction (F := B)
    (p := fun x _ => star (φ x) = φ x) hgens hbase
    (fun x y _ _ hx hy => by simp [map_add, hx, hy])
    (fun x _ hx => by simp [map_inv₀, hx])
    (fun x y _ _ hx hy => by simp [map_mul, hx, hy]) hx

/-- The algebraic total-reality assertion in the pseudo-admissibility discussion,
with actual fields, embeddings, generators, and positivity at every base place. -/
theorem totally_positive_radicals_totallyReal
    {B K ι : Type*} [Field B] [NumberField B] [NumberField.IsTotallyReal B]
    [Field K] [NumberField K] [Algebra B K]
    (g : ι → K) (d : ι → B)
    (hgenerate : IntermediateField.adjoin B (Set.range g) = ⊤)
    (hsq : ∀ i, g i ^ 2 = algebraMap B K (d i))
    (hpositive : ∀ (σ : B →+* ℝ) i, 0 < σ (d i)) : NumberField.IsTotallyReal K where
  isReal v := by
    apply NumberField.InfinitePlace.isReal_iff.mpr
    let φ := v.embedding
    have hb := NumberField.IsTotallyReal.complexEmbedding_isReal (φ.comp (algebraMap B K))
    apply embedding_real_of_generators (Set.range g) hgenerate φ
      (fun b => RingHom.congr_fun hb b)
    rintro x ⟨i,rfl⟩
    have hh : (φ (g i)) ^ 2 = (hb.embedding (d i) : ℂ) := by
      rw [← map_pow, hsq]
      exact (hb.coe_embedding_apply (d i)).symm
    exact complex_square_positive_is_real (hpositive hb.embedding i) hh

/-- Elimination works for arbitrary complex roots, not just the selected real radical. -/
theorem quartic_of_cycle_equations (s u : ℂ) (hs : s ^ 2 = 5)
    (hr : (s-1)*u^2+2*(s-3)*u+s-7 = 0) :
    u^4+2*u^3-5*u^2-16*u-11 = 0 := by
  linear_combination ((u^2+6*u+7)+s*(u+1)^2)/4 * hr - (u+1)^4/4 * hs

theorem complex_pair_numberField (s u : ℂ) (hs : s ^ 2 = 5)
    (hr : (s-1)*u^2+2*(s-3)*u+s-7 = 0) :
    NumberField (IntermediateField.adjoin ℚ ({s,u} : Set ℂ)) := by
  have hi : IsIntegral ℚ s := by
    refine ⟨Polynomial.X^2-Polynomial.C 5,
      Polynomial.monic_X_pow_sub_C (5 : ℚ) (by norm_num), ?_⟩
    simp [hs]
  have hu : IsIntegral ℚ u := by
    apply isAlgebraic_iff_isIntegral.mp
    refine ⟨Polynomial.X^4+Polynomial.C 2*Polynomial.X^3-
      Polynomial.C 5*Polynomial.X^2-Polynomial.C 16*Polynomial.X-Polynomial.C 11, ?_, ?_⟩
    · intro h
      have := congrArg (fun p : Polynomial ℚ => p.coeff 4) h
      norm_num at this
    · simpa using quartic_of_cycle_equations s u hs hr
  exact { to_finiteDimensional := IntermediateField.finiteDimensional_adjoin_pair hi hu }

theorem arbitrary_complex_pair_not_totallyReal (s u : ℂ) (hs : s ^ 2 = 5)
    (hr : (s-1)*u^2+2*(s-3)*u+s-7 = 0) :
    ¬ NumberField.IsTotallyReal (IntermediateField.adjoin ℚ ({s,u} : Set ℂ)) := by
  let L := IntermediateField.adjoin ℚ ({s,u} : Set ℂ)
  letI : NumberField L := complex_pair_numberField s u hs hr
  let sL : L := ⟨s, IntermediateField.mem_adjoin_pair_left ℚ s u⟩
  let uL : L := ⟨u, IntermediateField.mem_adjoin_pair_right ℚ s u⟩
  apply not_totallyReal_of_cycle_square sL uL
  · apply Subtype.ext
    exact hs
  · apply Subtype.ext
    exact hr

/-- The defining English property of the minimal polynomial, including positive
degree and uniqueness. Imported kernel-checked library proofs are sufficient. -/
theorem minpoly_characterization {K : Type*} [Field K] [NumberField K]
    (x : K) (p : Polynomial ℚ) :
    p = minpoly ℚ x ↔ p.Monic ∧ 0 < p.natDegree ∧ Polynomial.aeval x p = 0 ∧
      ∀ q : Polynomial ℚ, q ≠ 0 → Polynomial.aeval x q = 0 → p.degree ≤ q.degree := by
  constructor
  · rintro rfl
    have hx := IsIntegral.of_finite ℚ x
    exact ⟨minpoly.monic hx, minpoly.natDegree_pos hx, minpoly.aeval ℚ x,
      fun _ hq hr => minpoly.degree_le_of_ne_zero ℚ x hq hr⟩
  · rintro ⟨hm, _, hr, hmin⟩
    exact minpoly.unique ℚ x hm hr (fun q hq hv => hmin q hq.ne_zero hv)

theorem number_field_primitive_element {L K : Type*} [Field L] [NumberField L]
    [Field K] [NumberField K] [Algebra L K] :
    Algebra.IsSeparable L K ∧ ∃ θ : K, IntermediateField.adjoin L {θ} = ⊤ := by
  letI : FiniteDimensional L K := Module.Finite.right ℚ L K
  exact ⟨inferInstance, Field.exists_primitive_element L K⟩

theorem complex_nonconstant_has_root (p : Polynomial ℂ) (hp : 0 < p.degree) :
    ∃ z : ℂ, p.eval z = 0 := Complex.exists_root hp

theorem constant_one_has_no_root : ¬ ∃ z : ℂ, (1 : Polynomial ℂ).eval z = 0 := by simp

/-- Coefficient transport followed by evaluation factors through the actual
polynomial quotient. With an irreducible polynomial the quotient is a field. -/
theorem transported_root_embedding {L : Type*} [Field L] (p : Polynomial L)
    (hp : Irreducible p) (σ : L →+* ℂ) (z : ℂ) (hz : p.eval₂ σ z = 0) :
    ∃ τ : AdjoinRoot p →+* ℂ, Function.Injective τ ∧
      τ.comp (AdjoinRoot.of p) = σ ∧ τ (AdjoinRoot.root p) = z := by
  letI : Fact (Irreducible p) := ⟨hp⟩
  refine ⟨AdjoinRoot.lift σ z hz, (AdjoinRoot.lift σ z hz).injective, ?_, ?_⟩
  · exact AdjoinRoot.lift_comp_of hz
  · exact AdjoinRoot.lift_root hz

theorem evaluation_factors_through_quotient {L : Type*} [Field L] (p : Polynomial L)
    (σ : L →+* ℂ) (z : ℂ) (hz : p.eval₂ σ z = 0) :
    ∃ τ : AdjoinRoot p →+* ℂ, ∀ q : Polynomial L,
      τ (AdjoinRoot.mk p q) = q.eval₂ σ z :=
  ⟨AdjoinRoot.lift σ z hz, fun q => AdjoinRoot.lift_mk hz q⟩

/-- The converse algebraic direction in the real-multiquadratic discussion:
a nonzero radicand with a square root in a totally real extension is positive
at every real embedding of the base. -/
theorem radicands_totally_positive_of_totallyReal
    {B K ι : Type*} [Field B] [NumberField B] [Field K] [NumberField K]
    [Algebra B K] [NumberField.IsTotallyReal K]
    (g : ι → K) (d : ι → B) (hne : ∀ i, d i ≠ 0)
    (hsq : ∀ i, g i ^ 2 = algebraMap B K (d i)) :
    ∀ (σ : B →+* ℝ) i, 0 < σ (d i) := by
  intro σ i
  obtain ⟨τ, ht⟩ := embedding_extension (K := K) (Complex.ofRealHom.comp σ)
  have hreal := NumberField.IsTotallyReal.complexEmbedding_isReal τ
  have hc : (τ (g i)) ^ 2 = (σ (d i) : ℂ) := by
    rw [← map_pow, hsq]
    exact RingHom.congr_fun ht (d i)
  have hr : (hreal.embedding (g i)) ^ 2 = σ (d i) := by
    apply Complex.ofReal_injective
    simpa only [Complex.ofReal_pow, hreal.coe_embedding_apply] using hc
  have hnonneg : 0 ≤ σ (d i) := hr ▸ sq_nonneg _
  exact lt_of_le_of_ne hnonneg ((map_ne_zero σ).mpr (hne i)).symm

theorem radical_extension_totallyReal_iff
    {B K ι : Type*} [Field B] [NumberField B] [NumberField.IsTotallyReal B]
    [Field K] [NumberField K] [Algebra B K]
    (g : ι → K) (d : ι → B) (hne : ∀ i, d i ≠ 0)
    (hgenerate : IntermediateField.adjoin B (Set.range g) = ⊤)
    (hsq : ∀ i, g i ^ 2 = algebraMap B K (d i)) :
    NumberField.IsTotallyReal K ↔ ∀ (σ : B →+* ℝ) i, 0 < σ (d i) := by
  constructor
  · intro h
    letI := h
    exact radicands_totally_positive_of_totallyReal g d hne hsq
  · exact totally_positive_radicals_totallyReal g d hgenerate hsq

end PseudoArithmetic.FieldAudit
