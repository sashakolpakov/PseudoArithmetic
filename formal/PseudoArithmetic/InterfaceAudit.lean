import PseudoArithmetic.SemanticAudit
import PseudoArithmetic.ConditionalDescent

/-!
Positive and negative logical models for the external interfaces.
These models test quantifiers and missing premises. Their Boolean predicates
are not models of hyperbolic geometry or examples of geometric lattices.
-/

namespace PseudoArithmetic.InterfaceAudit

open Manuscript SemanticAudit

noncomputable def actualCertificate : TwoCycleCertificate witnessField :=
  TwoCycleCertificate.of_real_cycles witnessField.subtype
    ((3+witnessS)/2) (-2*witnessU) rfl rfl

def positiveLatticeInterface (j : CoxeterCase) : CoxeterExternalInputs Unit witnessField where
  caseName := j
  Γ := ()
  finiteVolumeReflectionLattice := fun _ => True
  hasAdjointTraceField := fun _ => True
  isPseudoArithmetic := fun _ => False
  finite_volume := trivial
  trace_field := trivial
  pseudoArithmetic_totallyReal := by intros; contradiction

theorem main_interface_positive (j : CoxeterCase) :
    (positiveLatticeInterface j).finiteVolumeReflectionLattice () ∧
      (positiveLatticeInterface j).hasAdjointTraceField () ∧
      ¬ NumberField.IsTotallyReal witnessField ∧
      ¬ (positiveLatticeInterface j).isPseudoArithmetic () :=
  coxeter_case_main_theorem (positiveLatticeInterface j) actualCertificate

def rationalLatticeInterface : CoxeterExternalInputs Unit ℚ where
  caseName := .p11_6
  Γ := ()
  finiteVolumeReflectionLattice := fun _ => True
  hasAdjointTraceField := fun _ => True
  isPseudoArithmetic := fun _ => True
  finite_volume := trivial
  trace_field := trivial
  pseudoArithmetic_totallyReal := by intros; infer_instance

/-- All external implications may hold while the missing certificate fails. -/
theorem main_certificate_necessary :
    rationalLatticeInterface.isPseudoArithmetic () ∧
      ¬ Nonempty (TwoCycleCertificate ℚ) := by
  refine ⟨trivial, ?_⟩
  rintro ⟨C⟩
  exact C.not_totallyReal inferInstance

/-- A nonreal field alone does not constrain an unrelated pseudo-arithmeticity
predicate. This is a logical countermodel, not a geometric counterexample. -/
theorem total_reality_bridge_necessary :
    ¬ NumberField.IsTotallyReal witnessField ∧
      (True : Prop) ∧ ¬ (True → NumberField.IsTotallyReal witnessField) := by
  exact ⟨concrete_positive_example.2.2, trivial,
    fun h => concrete_positive_example.2.2 (h trivial)⟩

def positiveManifoldInterface : ManifoldExternalInputs Unit Unit witnessField where
  Γ := ()
  finiteVolumeReflectionLattice := fun _ => True
  noncompactQuotient := fun _ => True
  finiteIndex := fun _ _ => True
  torsionFreeOrientationPreserving := fun _ => True
  quotient := fun _ _ => True
  orientableNoncompactFiniteVolumeHyperbolic4 := fun _ => True
  hasAdjointTraceField := fun _ => True
  isPseudoArithmeticLattice := fun _ => False
  isPseudoArithmeticManifold := fun _ => False
  finite_volume := trivial
  noncompact := trivial
  trace_field := trivial
  finiteIndex_cover_exists := by intro _; exact ⟨(),(),trivial,trivial,trivial⟩
  quotient_geometry := by intros; trivial
  traceField_finiteIndex_invariant := by intros; trivial
  pseudoArithmetic_totallyReal := by intros; contradiction
  quotient_pseudoArithmetic := by intros; rfl

theorem manifold_interface_positive :
    ∃ M, positiveManifoldInterface.orientableNoncompactFiniteVolumeHyperbolic4 M ∧
      ¬ positiveManifoldInterface.isPseudoArithmeticManifold M :=
  finiteIndex_manifold_corollary positiveManifoldInterface actualCertificate

theorem existence_cannot_be_dropped : ¬ ∃ _ : Empty, True := by
  rintro ⟨M, _⟩
  exact M.elim

theorem finite_volume_does_not_logically_imply_noncompactness :
    ∃ finiteVolume noncompact : Prop, finiteVolume ∧ ¬ noncompact :=
  ⟨True, False, trivial, id⟩

theorem quotient_group_bridge_necessary :
    ¬ (False : Prop) ∧ (True : Prop) ∧ ¬ (True ↔ False) := by simp

theorem trace_transfer_necessary :
    ∃ traceAtBase traceAtCover finiteIndex : Prop,
      traceAtBase ∧ finiteIndex ∧ ¬ traceAtCover :=
  ⟨True, False, True, trivial, trivial, id⟩

def flipAction (g p : Bool) : Bool := if g then !p else p

theorem split_support_positive :
    SplitSupport flipAction (fun _ => True) (fun _ => True) := by
  constructor
  · intro g p; rfl
  · intros; trivial

theorem incomplete_orbit_negative :
    ¬ SplitSupport flipAction (fun p => p = false) (fun _ => True) := by
  apply not_splitSupport_of_incomplete_ramified_orbit flipAction
    (fun p => p = false) (fun _ => True) (g := true) (w := false)
  · rfl
  · decide

theorem nonsplit_prime_negative :
    ¬ SplitSupport flipAction (fun _ => True) (fun _ => False) := by
  apply not_splitSupport_of_ramified_nontrivialDecomposition flipAction
    (fun _ => True) (fun _ => False) (w := false)
  · trivial
  · exact id

def booleanDescent : DescentBridge Bool where
  eligible := fun _ => True
  fiberSig := fun _ => True
  admissibleSig := fun _ => True
  cliffordRestricted := fun i => i = true
  splitSupport := fun i => i = true
  normIsoDesc := fun i => i = true
  simDesc := fun i => i = true
  totallyReal := True
  pseudoArithmetic := True
  admissible_fiber := by intros; trivial
  normalization := by intros; rfl
  iso_necessary := by intro i h; exact ⟨trivial,h⟩
  local_necessary := by intros; assumption
  abhn_sufficient := by intros; assumption
  hm_sufficient := by intros; assumption
  pseudo_characterization := by simp

theorem descent_positive_and_negative :
    booleanDescent.simDesc true ∧ ¬ booleanDescent.simDesc false := by
  change true = true ∧ ¬ false = true
  decide

theorem candidate_quantifier_is_existential :
    (∃ i, booleanDescent.splitSupport i) ∧ ¬ (∀ i, booleanDescent.splitSupport i) := by
  exact ⟨⟨true, rfl⟩, fun h => Bool.noConfusion (h false)⟩

theorem descent_interface_equivalence :
    booleanDescent.pseudoArithmetic ↔ booleanDescent.totallyReal ∧
      ∃ i, booleanDescent.eligible i ∧ booleanDescent.admissibleSig i ∧
        booleanDescent.splitSupport i := booleanDescent.pseudoArithmetic_iff

end PseudoArithmetic.InterfaceAudit
