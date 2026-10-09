import PseudoArithmetic.GramAudit
import PseudoArithmetic.InterfaceAudit

/-!
External statements specialized to the dimension-four argument.

The vocabulary is interpreted geometrically by the cited sources, not defined
by Boolean tests. Crucially, trace fields are actual intermediate fields of
ℝ and each case is related to its actual matrix. The contracts below expose
the precise imported conclusions, with their domain restrictions and a common
subgroup/quotient witness. They do not claim new proofs of the imported geometry.
-/

namespace PseudoArithmetic.ExternalContracts

open Manuscript GramAudit SemanticAudit

/-- All lattice/manifold predicates here refer to real hyperbolic dimension 4.
`finiteIndex Λ Γ` means that Λ is a subgroup of finite index in Γ.
`reflectionGroupOf Γ A` means A is a unit-normal Gram matrix for a Coxeter
fundamental polytope whose facet reflections generate Γ. -/
structure Hyperbolic4Vocabulary (Lattice Manifold : Type*) where
  finiteVolumeLattice : Lattice → Prop
  reflectionGroupOf : Lattice → Matrix (Fin 7) (Fin 7) ℝ → Prop
  adjointTraceField : Lattice → IntermediateField ℚ ℝ
  pseudoArithmetic : Lattice → Prop
  noncompactQuotient : Lattice → Prop
  finiteIndex : Lattice → Lattice → Prop
  torsionFreeOrientationPreserving : Lattice → Prop
  quotient : Lattice → Manifold → Prop
  orientableNoncompactFiniteVolumeHyperbolic4 : Manifold → Prop
  pseudoArithmeticManifold : Manifold → Prop

/-- E1–E3 as used in the proof. E2 is equality of fields, not a free predicate
on an independently chosen field. The n>3 condition in E3 is satisfied by
the fixed dimension 4 of the vocabulary. -/
structure CensusInputs {Lattice Manifold : Type*}
    (V : Hyperbolic4Vocabulary Lattice Manifold) where
  group : CoxeterCase → Lattice
  census_realization : ∀ j, V.reflectionGroupOf (group j) (gram j)
  finite_volume : ∀ j, V.finiteVolumeLattice (group j)
  noncompact : ∀ j, V.noncompactQuotient (group j)
  vinberg : ∀ Γ A, V.reflectionGroupOf Γ A → V.finiteVolumeLattice Γ →
    V.adjointTraceField Γ = generatedCycleField (fun i k => 2 * A i k)
  pseudoArithmetic_totallyReal : ∀ Γ, V.finiteVolumeLattice Γ →
    V.pseudoArithmetic Γ → NumberField.IsTotallyReal (V.adjointTraceField Γ)

theorem traceField_eq_cycleField {Lattice Manifold : Type*}
    {V : Hyperbolic4Vocabulary Lattice Manifold} (E : CensusInputs V) (j : CoxeterCase) :
    V.adjointTraceField (E.group j) = cycleField j :=
  E.vinberg _ _ (E.census_realization j) (E.finite_volume j)

/-- The three actual cycle fields supply the algebra; no certificate premise
or freely chosen field is left for the geometric caller to provide. -/
theorem census_main_theorem {Lattice Manifold : Type*}
    {V : Hyperbolic4Vocabulary Lattice Manifold} (E : CensusInputs V) (j : CoxeterCase) :
    V.finiteVolumeLattice (E.group j) ∧
      V.adjointTraceField (E.group j) = cycleField j ∧
      ¬ NumberField.IsTotallyReal (V.adjointTraceField (E.group j)) ∧
      ¬ V.pseudoArithmetic (E.group j) := by
  have hf := traceField_eq_cycleField E j
  have hn : ¬ NumberField.IsTotallyReal (V.adjointTraceField (E.group j)) := by
    rw [hf]
    exact all_three_cycleFields_not_totallyReal j
  exact ⟨E.finite_volume j, hf, hn,
    fun h => hn (E.pseudoArithmetic_totallyReal _ (E.finite_volume j) h)⟩

/-- E5–E7 after specialization to the census groups. `cover_exists` packages
orientation, finite generation, Selberg, and quotient existence; it is not
advertised as the general Selberg statement. All properties concern the same Λ,M. -/
structure CoverInputs {Lattice Manifold : Type*}
    {V : Hyperbolic4Vocabulary Lattice Manifold} (E : CensusInputs V) where
  cover_exists : ∀ j, ∃ Λ M, V.finiteIndex Λ (E.group j) ∧
    V.torsionFreeOrientationPreserving Λ ∧ V.quotient Λ M
  traceField_invariant : ∀ Λ Γ, V.finiteVolumeLattice Γ → V.finiteIndex Λ Γ →
    V.adjointTraceField Λ = V.adjointTraceField Γ
  quotient_geometry : ∀ Λ Γ M, V.finiteVolumeLattice Γ → V.noncompactQuotient Γ →
    V.finiteIndex Λ Γ → V.torsionFreeOrientationPreserving Λ → V.quotient Λ M →
    V.finiteVolumeLattice Λ ∧ V.orientableNoncompactFiniteVolumeHyperbolic4 M
  quotient_pseudoArithmetic : ∀ Λ M, V.finiteVolumeLattice Λ → V.quotient Λ M →
    (V.pseudoArithmeticManifold M ↔ V.pseudoArithmetic Λ)

theorem census_manifold_corollary {Lattice Manifold : Type*}
    {V : Hyperbolic4Vocabulary Lattice Manifold} (E : CensusInputs V)
    (C : CoverInputs E) (j : CoxeterCase) :
    ∃ Λ M, V.finiteIndex Λ (E.group j) ∧ V.quotient Λ M ∧
      V.orientableNoncompactFiniteVolumeHyperbolic4 M ∧
      V.adjointTraceField Λ = cycleField j ∧
      ¬ V.pseudoArithmetic Λ ∧ ¬ V.pseudoArithmeticManifold M := by
  obtain ⟨Λ, M, hindex, htf, hq⟩ := C.cover_exists j
  obtain ⟨hv, hgeom⟩ := C.quotient_geometry Λ (E.group j) M
    (E.finite_volume j) (E.noncompact j) hindex htf hq
  have hfield : V.adjointTraceField Λ = cycleField j :=
    (C.traceField_invariant Λ _ (E.finite_volume j) hindex).trans
      (traceField_eq_cycleField E j)
  have hn : ¬ V.pseudoArithmetic Λ := by
    intro hp
    have htr := E.pseudoArithmetic_totallyReal Λ hv hp
    rw [hfield] at htr
    exact all_three_cycleFields_not_totallyReal j htr
  exact ⟨Λ, M, hindex, hq, hgeom, hfield, hn,
    fun h => hn ((C.quotient_pseudoArithmetic Λ M hv hq).mp h)⟩

/-- A logical model with actual matrix-defined fields. Its predicates are
test values; it is not a model of the geometric objects themselves. -/
noncomputable def testVocabulary : Hyperbolic4Vocabulary CoxeterCase CoxeterCase where
  finiteVolumeLattice := fun _ => True
  reflectionGroupOf := fun j A => A = gram j
  adjointTraceField := cycleField
  pseudoArithmetic := fun _ => False
  noncompactQuotient := fun _ => True
  finiteIndex := Eq
  torsionFreeOrientationPreserving := fun _ => True
  quotient := Eq
  orientableNoncompactFiniteVolumeHyperbolic4 := fun _ => True
  pseudoArithmeticManifold := fun _ => False

noncomputable def testCensusInputs : CensusInputs testVocabulary where
  group := id
  census_realization := fun _ => rfl
  finite_volume := fun _ => trivial
  noncompact := fun _ => trivial
  vinberg := by intro j A h _; change A = gram j at h; subst A; rfl
  pseudoArithmetic_totallyReal := by intros; contradiction

theorem testCoverInputs : CoverInputs testCensusInputs := {
  cover_exists := fun j => ⟨j,j,rfl,trivial,rfl⟩
  traceField_invariant := by intro Λ Γ _ h; change Λ = Γ at h; subst Λ; rfl
  quotient_geometry := by intros; exact ⟨trivial,trivial⟩
  quotient_pseudoArithmetic := by intros; rfl
}

theorem contract_positive (j : CoxeterCase) :
    testVocabulary.adjointTraceField (testCensusInputs.group j) = cycleField j ∧
      ¬ testVocabulary.pseudoArithmetic (testCensusInputs.group j) := by
  have h := census_main_theorem testCensusInputs j
  exact ⟨h.2.1,h.2.2.2⟩

theorem cover_contract_positive (j : CoxeterCase) :
    ∃ Λ M, testVocabulary.finiteIndex Λ (testCensusInputs.group j) ∧
      testVocabulary.quotient Λ M ∧
      testVocabulary.orientableNoncompactFiniteVolumeHyperbolic4 M ∧
      testVocabulary.adjointTraceField Λ = cycleField j ∧
      ¬ testVocabulary.pseudoArithmetic Λ ∧ ¬ testVocabulary.pseudoArithmeticManifold M :=
  census_manifold_corollary testCensusInputs testCoverInputs j

theorem unrelated_field_rejected (j : CoxeterCase) : baseField ≠ cycleField j := by
  intro h
  have ht := baseField_totallyReal
  rw [h] at ht
  exact all_three_cycleFields_not_totallyReal j ht

theorem wrong_case_matrix_rejected :
    ¬ testVocabulary.reflectionGroupOf .p11_6 (gram .p11_7) := by
  intro h
  have he := congrArg (fun A : Matrix (Fin 7) (Fin 7) ℝ => A 1 6) h
  change -(1/2 : ℝ) = -0 at he
  norm_num at he

theorem reversed_total_reality_implication_is_insufficient :
    (NumberField.IsTotallyReal witnessField → True) ∧ True ∧
      ¬ NumberField.IsTotallyReal witnessField :=
  ⟨fun _ => trivial, trivial, concrete_positive_example.2.2⟩

theorem separate_witnesses_do_not_give_common_cover :
    (∃ i : Bool, i = true) ∧ (∃ i : Bool, i = false) ∧
      ¬ ∃ i : Bool, i = true ∧ i = false := by decide

theorem finite_index_argument_order_control :
    let relation := fun cover base : Bool => cover = false ∧ base = true
    relation false true ∧ ¬ relation true false := by decide

end PseudoArithmetic.ExternalContracts
