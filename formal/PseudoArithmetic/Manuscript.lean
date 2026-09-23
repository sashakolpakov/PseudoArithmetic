import PseudoArithmetic.NonTotalReality
import Mathlib.Tactic.Ring

/-!
# Manuscript-facing proof graph

This file mirrors the logical structure of the manuscript
*Non-Pseudo-Arithmetic Hyperbolic 4-Manifolds*.  The elementary algebra and
the field-theoretic obstruction are proved in Lean.  Results whose proofs
live in the cited literature (the Ma--Zheng classification, Vinberg's trace-
field theorem, Selberg's lemma, and the Emery--Mila total-reality
obstruction) occur only as local hypotheses of the theorem that uses them.

There are deliberately no project axioms.  The abstract predicates below
are typed translations of geometric statements, not substitute proofs of
those statements.
-/

namespace PseudoArithmetic
namespace Manuscript

/-- The three census rows used in the manuscript. -/
inductive CoxeterCase where
  | p11_6
  | p11_7
  | p11_8
  deriving DecidableEq, Fintype, Repr

/-- The value of the varying Coxeter label on the edge `(1,6)`. -/
def CoxeterCase.edge16 : CoxeterCase → ℕ
  | .p11_6 => 2
  | .p11_7 => 3
  | .p11_8 => 4

theorem CoxeterCase.edge16_values :
    CoxeterCase.p11_6.edge16 = 2 ∧
      CoxeterCase.p11_7.edge16 = 3 ∧
      CoxeterCase.p11_8.edge16 = 4 := by
  decide

/-- The two-cycle value `c₁₂ = (3+s)/2` recovers `s`. -/
theorem recover_s_from_twoCycle
    {F : Type*} [Field F] [CharZero F]
    {c₁₂ s : F} (hcycle : c₁₂ = (3 + s) / 2) :
    s = 2 * c₁₂ - 3 := by
  rw [hcycle]
  ring

/-- The three-cycle value `c₀₃₅ = -2u` recovers `u`. -/
theorem recover_u_from_threeCycle
    {F : Type*} [Field F] [CharZero F]
    {c₀₃₅ u : F} (hcycle : c₀₃₅ = -2 * u) :
    u = -c₀₃₅ / 2 := by
  rw [hcycle]
  ring

/-- The last elementary elimination in the radical calculation.

Here `t = sqrt (2 + 2s)`.  The manuscript first proves
`t = (s-1)u+s-3`; squaring this identity and using `t²=2+2s` gives the
displayed quadratic relation.  (The identity involving `t` is the earlier
step where `s²=5` is used.) -/
theorem cycle_relation_of_radical_identities
    {F : Type*} [Field F] [CharZero F]
    {s t u : F}
    (hsne : s ≠ 1)
    (ht : t = (s - 1) * u + s - 3)
    (htsq : t ^ 2 = 2 + 2 * s) :
    (s - 1) * u ^ 2 + 2 * (s - 3) * u + s - 7 = 0 := by
  have hproduct :
      (s - 1) * ((s - 1) * u ^ 2 + 2 * (s - 3) * u + s - 7) = 0 := by
    calc
      (s - 1) * ((s - 1) * u ^ 2 + 2 * (s - 3) * u + s - 7) =
          ((s - 1) * u + s - 3) ^ 2 - (2 + 2 * s) := by ring
      _ = t ^ 2 - (2 + 2 * s) := by rw [ht]
      _ = 0 := sub_eq_zero.mpr htsq
  rcases mul_eq_zero.mp hproduct with hzero | hrelation
  · exact (hsne (sub_eq_zero.mp hzero)).elim
  · exact hrelation

/-- A compact, machine-checkable version of the radical computation over
the real numbers.  Its hypotheses are precisely the four elementary facts
established from the positive square-root formulas in the manuscript. -/
theorem real_radical_calculation
    {s t u : ℝ}
    (hsq : s ^ 2 = 5)
    (hs_gt_one : 1 < s)
    (htsq : t ^ 2 = 2 + 2 * s)
    (hu_sq : u ^ 2 = (7 + s) / 2 + t)
    (hu_pos : 0 < u)
    (ht_pos : 0 < t)
    (hs_lt_three : s < 3) :
    (s - 1) * u ^ 2 + 2 * (s - 3) * u + s - 7 = 0 := by
  have hleft_pos : 0 < (s - 1) * u := mul_pos (sub_pos.mpr hs_gt_one) hu_pos
  have hright_pos : 0 < 3 - s + t := add_pos (sub_pos.mpr hs_lt_three) ht_pos
  have hsquares : ((s - 1) * u) ^ 2 = (3 - s + t) ^ 2 := by
    nlinarith
  have hlinear : (s - 1) * u = 3 - s + t := by
    nlinarith
  apply cycle_relation_of_radical_identities (ne_of_gt hs_gt_one)
    (s := s) (t := t) (u := u) _ htsq
  linarith

/-- The positive square root `s = sqrt 5` used by all three census rows. -/
noncomputable def radicalS : ℝ := Real.sqrt 5

/-- The inner radical `t = sqrt (2 + 2 sqrt 5)`. -/
noncomputable def radicalT : ℝ := Real.sqrt (2 + 2 * radicalS)

/-- The common dotted Gram entry
`a = (1/2) sqrt (7 + sqrt 5 + 2 sqrt (2 + 2 sqrt 5))`. -/
noncomputable def radicalA : ℝ :=
  (1 / 2 : ℝ) * Real.sqrt (7 + radicalS + 2 * radicalT)

/-- The element `u = sqrt 2 * a` recovered by the three-cycle. -/
noncomputable def radicalU : ℝ := Real.sqrt 2 * radicalA

/-- The manuscript's nested-radical identity, with no algebraic hypothesis
left to the caller. -/
theorem explicit_radical_cycle_relation :
    (radicalS - 1) * radicalU ^ 2 +
        2 * (radicalS - 3) * radicalU + radicalS - 7 = 0 := by
  have hs_nonneg : 0 ≤ radicalS := Real.sqrt_nonneg 5
  have hs_sq : radicalS ^ 2 = 5 := by
    exact Real.sq_sqrt (by norm_num)
  have hs_gt_one : 1 < radicalS := by
    nlinarith
  have hs_lt_three : radicalS < 3 := by
    nlinarith
  have ht_inside_pos : 0 < 2 + 2 * radicalS := by
    nlinarith
  have ht_pos : 0 < radicalT := by
    exact Real.sqrt_pos.2 ht_inside_pos
  have ht_sq : radicalT ^ 2 = 2 + 2 * radicalS := by
    exact Real.sq_sqrt (le_of_lt ht_inside_pos)
  have ha_inside_pos : 0 < 7 + radicalS + 2 * radicalT := by
    nlinarith
  have hu_pos : 0 < radicalU := by
    apply mul_pos (Real.sqrt_pos.2 (by norm_num))
    exact mul_pos (by norm_num) (Real.sqrt_pos.2 ha_inside_pos)
  have hu_sq : radicalU ^ 2 = (7 + radicalS) / 2 + radicalT := by
    simp only [radicalU, radicalA, mul_pow]
    rw [Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 2)]
    rw [Real.sq_sqrt (le_of_lt ha_inside_pos)]
    ring
  exact real_radical_calculation hs_sq hs_gt_one ht_sq hu_sq hu_pos ht_pos
    hs_lt_three

/-- The exact algebraic data extracted from the two cyclic products.

The cycle equalities and the minimal-polynomial statement are the formal
translations of the exact Coxeter/trace-field certificate.  The relation can
either be proved from `cycle_relation_of_radical_identities` or supplied by a
source-data checker. -/
structure TwoCycleCertificate (K : Type*) [Field K] [NumberField K] where
  s : K
  u : K
  c₁₂ : K
  c₀₃₅ : K
  cycle12_value : c₁₂ = (3 + s) / 2
  cycle035_value : c₀₃₅ = -2 * u
  sqrt5_minpoly : minpoly ℚ s = Polynomial.X ^ 2 - Polynomial.C 5
  cycle_relation : (s - 1) * u ^ 2 + 2 * (s - 3) * u + s - 7 = 0

namespace TwoCycleCertificate

variable {K : Type*} [Field K] [NumberField K]

theorem recovers_s (C : TwoCycleCertificate K) :
    C.s = 2 * C.c₁₂ - 3 :=
  recover_s_from_twoCycle C.cycle12_value

theorem recovers_u (C : TwoCycleCertificate K) :
    C.u = -C.c₀₃₅ / 2 :=
  recover_u_from_threeCycle C.cycle035_value

/-- The kernel-checked algebraic conclusion used by the main theorem. -/
theorem not_totallyReal (C : TwoCycleCertificate K) :
    ¬ NumberField.IsTotallyReal K :=
  not_totallyReal_of_cycle_minpoly C.s C.u C.sqrt5_minpoly C.cycle_relation

end TwoCycleCertificate

/-- External inputs for one Coxeter case.

`finiteVolumeReflectionLattice Γ` translates the relevant Ma--Zheng census
statement.  `hasAdjointTraceField Γ` says that the number field `K` is the
adjoint trace field of `Γ`; its justification in the paper is Vinberg's
cyclic-product theorem together with the displayed cycle computation.
`pseudoArithmetic_totallyReal` translates the Emery--Mila obstruction.
All three are local data supplied to the theorem, never global axioms. -/
structure CoxeterExternalInputs
    (Lattice K : Type*) [Field K] [NumberField K] where
  caseName : CoxeterCase
  Γ : Lattice
  finiteVolumeReflectionLattice : Lattice → Prop
  hasAdjointTraceField : Lattice → Prop
  isPseudoArithmetic : Lattice → Prop
  finite_volume : finiteVolumeReflectionLattice Γ
  trace_field : hasAdjointTraceField Γ
  pseudoArithmetic_totallyReal :
    ∀ Λ, hasAdjointTraceField Λ → isPseudoArithmetic Λ →
      NumberField.IsTotallyReal K

/-- Manuscript Theorem 1, with all external statements exposed as fields of
`E` and all new algebra contained in `C`. -/
theorem coxeter_case_main_theorem
    {Lattice K : Type*} [Field K] [NumberField K]
    (E : CoxeterExternalInputs Lattice K)
    (C : TwoCycleCertificate K) :
    E.finiteVolumeReflectionLattice E.Γ ∧
      E.hasAdjointTraceField E.Γ ∧
      ¬ NumberField.IsTotallyReal K ∧
      ¬ E.isPseudoArithmetic E.Γ := by
  have hnotreal := C.not_totallyReal
  refine ⟨E.finite_volume, E.trace_field, hnotreal, ?_⟩
  intro hpseudo
  exact hnotreal (E.pseudoArithmetic_totallyReal E.Γ E.trace_field hpseudo)

/-- External inputs used only in passing from a reflection orbifold to a
manifold.  This is a typed translation of the orientation subgroup,
Selberg-lemma, finite-cover geometry, finite-index trace-field invariance,
and quotient-group interpretation invoked in the manuscript's corollary. -/
structure ManifoldExternalInputs
    (Lattice Manifold K : Type*) [Field K] [NumberField K] where
  Γ : Lattice
  finiteVolumeReflectionLattice : Lattice → Prop
  finiteIndex : Lattice → Lattice → Prop
  torsionFreeOrientationPreserving : Lattice → Prop
  quotient : Lattice → Manifold → Prop
  orientableNoncompactFiniteVolume : Manifold → Prop
  hasAdjointTraceField : Lattice → Prop
  isPseudoArithmeticLattice : Lattice → Prop
  isPseudoArithmeticManifold : Manifold → Prop
  finite_volume : finiteVolumeReflectionLattice Γ
  trace_field : hasAdjointTraceField Γ
  finiteIndex_cover_exists :
    finiteVolumeReflectionLattice Γ →
      ∃ Λ M, finiteIndex Λ Γ ∧
        torsionFreeOrientationPreserving Λ ∧ quotient Λ M
  quotient_geometry :
    ∀ Λ M, finiteIndex Λ Γ → torsionFreeOrientationPreserving Λ →
      quotient Λ M → orientableNoncompactFiniteVolume M
  traceField_finiteIndex_invariant :
    ∀ Λ, finiteIndex Λ Γ → hasAdjointTraceField Γ →
      hasAdjointTraceField Λ
  pseudoArithmetic_totallyReal :
    ∀ Λ, hasAdjointTraceField Λ → isPseudoArithmeticLattice Λ →
      NumberField.IsTotallyReal K
  quotient_pseudoArithmetic :
    ∀ Λ M, quotient Λ M →
      (isPseudoArithmeticManifold M ↔ isPseudoArithmeticLattice Λ)

/-- Manuscript Corollary 2: once the external finite-cover facts are supplied,
the same non-total-reality certificate obstructs pseudo-arithmeticity of the
resulting orientable finite-volume manifold. -/
theorem finiteIndex_manifold_corollary
    {Lattice Manifold K : Type*} [Field K] [NumberField K]
    (E : ManifoldExternalInputs Lattice Manifold K)
    (C : TwoCycleCertificate K) :
    ∃ M, E.orientableNoncompactFiniteVolume M ∧
      ¬ E.isPseudoArithmeticManifold M := by
  obtain ⟨Λ, M, hindex, htorsion, hquotient⟩ :=
    E.finiteIndex_cover_exists E.finite_volume
  refine ⟨M, E.quotient_geometry Λ M hindex htorsion hquotient, ?_⟩
  intro hpseudoM
  have hpseudoΛ := (E.quotient_pseudoArithmetic Λ M hquotient).mp hpseudoM
  have htraceΛ := E.traceField_finiteIndex_invariant Λ hindex E.trace_field
  exact C.not_totallyReal
    (E.pseudoArithmetic_totallyReal Λ htraceΛ hpseudoΛ)

end Manuscript
end PseudoArithmetic
