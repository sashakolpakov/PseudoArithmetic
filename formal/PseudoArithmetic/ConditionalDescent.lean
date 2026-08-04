import PseudoArithmetic.NonTotalReality

/-!
# Conditional descent and pseudo-arithmeticity bridges

Mathlib does not yet expose all of the Clifford-algebra, Brauer-group, ABHN,
and Hasse--Minkowski machinery used by the manuscript.  This file therefore
does not postulate those results globally.  Instead, each unavailable
classical input is an explicit hypothesis of the theorem that uses it.

The conclusions below are consequently kernel-checked implication chains:
once the named mathematical inputs are supplied, Lean verifies the descent
criterion and the obstruction arguments.
-/

namespace PseudoArithmetic

/-- An inspectable interface for the classical inputs to normalized descent.

Values of `Candidate` represent elementary-2 descent candidates.  The two
sufficiency fields deliberately separate the missing library foundations:
`abhn_sufficient` contains the ABHN/local-degree/Chebotarev lifting step, and
`hm_sufficient` contains local quadratic-form existence, reciprocity, global
existence, and Hasse--Minkowski.  Supplying a value of this structure is a
hypothesis of the theorems below; the structure creates no Lean axiom.
-/
structure DescentBridge (Candidate : Type*) where
  eligible : Candidate → Prop
  fiberSig : Candidate → Prop
  admissibleSig : Candidate → Prop
  cliffordRestricted : Candidate → Prop
  splitSupport : Candidate → Prop
  normIsoDesc : Candidate → Prop
  simDesc : Candidate → Prop
  totallyReal : Prop
  pseudoArithmetic : Prop
  admissible_fiber : ∀ i, admissibleSig i → fiberSig i
  normalization : ∀ i, simDesc i ↔ normIsoDesc i
  iso_necessary : ∀ i, normIsoDesc i → fiberSig i ∧ cliffordRestricted i
  local_necessary : ∀ i, cliffordRestricted i → splitSupport i
  abhn_sufficient :
    ∀ i, fiberSig i → splitSupport i → cliffordRestricted i
  hm_sufficient :
    ∀ i, fiberSig i → cliffordRestricted i → normIsoDesc i
  pseudo_characterization :
    pseudoArithmetic ↔ totallyReal ∧
      ∃ i, eligible i ∧ admissibleSig i ∧ simDesc i

/-- The normalized Clifford split-support equivalence assembled from a
supplied `DescentBridge`.
-/
theorem DescentBridge.simDesc_iff
    {Candidate : Type*} (D : DescentBridge Candidate) (i : Candidate) :
    D.simDesc i ↔ D.fiberSig i ∧ D.splitSupport i := by
  constructor
  · intro hsim
    have hiso := (D.normalization i).mp hsim
    obtain ⟨hfiber, hclifford⟩ := D.iso_necessary i hiso
    exact ⟨hfiber, D.local_necessary i hclifford⟩
  · rintro ⟨hfiber, hsupport⟩
    apply (D.normalization i).mpr
    exact D.hm_sufficient i hfiber
      (D.abhn_sufficient i hfiber hsupport)

/-- The lightweight split-support test agrees with the necessary direction
of the full descent criterion.

This implication deliberately avoids `abhn_sufficient` and `hm_sufficient`:
an accepted similarity descent must pass split support using only
normalization, Clifford functoriality, and the local Brauer restriction
formula represented by the corresponding necessary fields of
`DescentBridge`.
-/
theorem DescentBridge.simDesc_implies_splitSupport
    {Candidate : Type*} (D : DescentBridge Candidate) (i : Candidate) :
    D.simDesc i → D.splitSupport i := by
  intro hsim
  have hiso := (D.normalization i).mp hsim
  exact D.local_necessary i (D.iso_necessary i hiso).2

/-- Hence a lightweight split-support rejection can never contradict an
acceptance by the full similarity-descent criterion.
-/
theorem DescentBridge.not_simDesc_of_not_splitSupport
    {Candidate : Type*} (D : DescentBridge Candidate) (i : Candidate)
    (hfail : ¬ D.splitSupport i) :
    ¬ D.simDesc i := by
  intro hsim
  exact hfail (D.simDesc_implies_splitSupport i hsim)

/-- The finite pseudo-arithmeticity criterion assembled from a supplied
`DescentBridge`.
-/
theorem DescentBridge.pseudoArithmetic_iff
    {Candidate : Type*} (D : DescentBridge Candidate) :
    D.pseudoArithmetic ↔ D.totallyReal ∧
      ∃ i, D.eligible i ∧ D.admissibleSig i ∧ D.splitSupport i := by
  constructor
  · intro hpseudo
    obtain ⟨htotallyReal, i, heligible, hadmissible, hsim⟩ :=
      D.pseudo_characterization.mp hpseudo
    exact ⟨htotallyReal, i, heligible, hadmissible,
      (D.simDesc_iff i).mp hsim |>.2⟩
  · rintro ⟨htotallyReal, i, heligible, hadmissible, hsupport⟩
    apply D.pseudo_characterization.mpr
    refine ⟨htotallyReal, i, heligible, hadmissible, ?_⟩
    exact (D.simDesc_iff i).mpr
      ⟨D.admissible_fiber i hadmissible, hsupport⟩

/-- A ramification predicate is stable when translating a prime by any
element of the candidate Galois group preserves ramification.
-/
def RamificationStable
    {G Prime : Type*} (act : G → Prime → Prime) (ramified : Prime → Prop) : Prop :=
  ∀ g w, ramified w ↔ ramified (act g w)

/-- The finite split-support condition: ramification is Galois-stable, and
every ramified prime has trivial decomposition group.
-/
def SplitSupport
    {G Prime : Type*}
    (act : G → Prime → Prime)
    (ramified trivialDecomposition : Prime → Prop) : Prop :=
  RamificationStable act ramified ∧
    ∀ w, ramified w → trivialDecomposition w

/-- A ramified prime with nontrivial decomposition group violates split
support.
-/
theorem not_splitSupport_of_ramified_nontrivialDecomposition
    {G Prime : Type*}
    (act : G → Prime → Prime)
    (ramified trivialDecomposition : Prime → Prop)
    {w : Prime}
    (hramified : ramified w)
    (hnontrivial : ¬ trivialDecomposition w) :
    ¬ SplitSupport act ramified trivialDecomposition := by
  intro hsupport
  exact hnontrivial (hsupport.2 w hramified)

/-- An incomplete Galois orbit of ramified primes violates split support.
-/
theorem not_splitSupport_of_incomplete_ramified_orbit
    {G Prime : Type*}
    (act : G → Prime → Prime)
    (ramified trivialDecomposition : Prime → Prop)
    {g : G} {w : Prime}
    (hramified : ramified w)
    (htranslate : ¬ ramified (act g w)) :
    ¬ SplitSupport act ramified trivialDecomposition := by
  intro hsupport
  exact htranslate ((hsupport.1 g w).mp hramified)

/-- The direct Clifford/Tits split-support test is necessary for similarity
descent.  Here `cliffordRestricted_necessary` packages similarity invariance
of the odd-rank even Clifford algebra and functoriality under group descent;
no determinant normalization or local-global sufficiency theorem occurs.
-/
theorem similarityDescends_implies_directSplitSupport
    {Form : Type*}
    (similarityDescends cliffordRestricted splitSupport : Form → Prop)
    (cliffordRestricted_necessary :
      ∀ q, similarityDescends q → cliffordRestricted q)
    (localBrauer_necessary :
      ∀ q, cliffordRestricted q → splitSupport q)
    (q : Form) :
    similarityDescends q → splitSupport q := by
  intro hdescends
  exact localBrauer_necessary q
    (cliffordRestricted_necessary q hdescends)

/-- A direct split-support failure is therefore a sound lightweight
rejection of similarity descent.
-/
theorem not_similarityDescends_of_directSplitSupport_failure
    {Form : Type*}
    (similarityDescends cliffordRestricted splitSupport : Form → Prop)
    (cliffordRestricted_necessary :
      ∀ q, similarityDescends q → cliffordRestricted q)
    (localBrauer_necessary :
      ∀ q, cliffordRestricted q → splitSupport q)
    (q : Form) (hfail : ¬ splitSupport q) :
    ¬ similarityDescends q := by
  intro hdescends
  exact hfail (similarityDescends_implies_directSplitSupport
    similarityDescends cliffordRestricted splitSupport
    cliffordRestricted_necessary localBrauer_necessary q hdescends)

/-- Conditional normalized Clifford descent.

`normalization` is the odd-rank determinant-normalization step, while
`hasseMinkowski_clifford` packages the global classification of the
normalized form by signatures and its even Clifford class.  Both facts are
ordinary hypotheses rather than declarations in Lean's trusted environment.
-/
theorem normalized_clifford_descent_iff
    {Form : Type*}
    (similarityDescends normalizedIsometryDescends signaturesDescend
      cliffordRestricted : Form → Prop)
    (normalization :
      ∀ q, similarityDescends q ↔ normalizedIsometryDescends q)
    (hasseMinkowski_clifford :
      ∀ q, normalizedIsometryDescends q ↔
        signaturesDescend q ∧ cliffordRestricted q)
    (q : Form) :
    similarityDescends q ↔ signaturesDescend q ∧ cliffordRestricted q :=
  (normalization q).trans (hasseMinkowski_clifford q)

/-- Conditional local split-support form of normalized Clifford descent.

The last hypothesis is the ABHN/local-invariant identification of restricted
two-torsion Brauer classes with the split-support condition.
-/
theorem normalized_clifford_splitSupport_iff
    {Form : Type*}
    (similarityDescends normalizedIsometryDescends signaturesDescend
      cliffordRestricted splitSupport : Form → Prop)
    (normalization :
      ∀ q, similarityDescends q ↔ normalizedIsometryDescends q)
    (hasseMinkowski_clifford :
      ∀ q, normalizedIsometryDescends q ↔
        signaturesDescend q ∧ cliffordRestricted q)
    (abhn_local : ∀ q, cliffordRestricted q ↔ splitSupport q)
    (q : Form) :
    similarityDescends q ↔ signaturesDescend q ∧ splitSupport q := by
  rw [normalized_clifford_descent_iff similarityDescends
    normalizedIsometryDescends signaturesDescend cliffordRestricted
    normalization hasseMinkowski_clifford]
  exact and_congr_right fun _ => abhn_local q

/-- A ramified Clifford prime that does not split completely obstructs
similarity descent.

Only the necessary directions of normalization, global classification, and
the local Brauer restriction formula are required.  The ramification and
nonsplitting facts are concrete inputs suitable for exact computation.
-/
theorem nonsplit_ramified_prime_obstructs_descent
    {Form Prime : Type*}
    (similarityDescends normalizedIsometryDescends cliffordRestricted : Form → Prop)
    (ramified splitsCompletely : Form → Prime → Prop)
    (normalization_necessary :
      ∀ q, similarityDescends q → normalizedIsometryDescends q)
    (clifford_necessary :
      ∀ q, normalizedIsometryDescends q → cliffordRestricted q)
    (local_brauer_necessary :
      ∀ q p, cliffordRestricted q → ramified q p → splitsCompletely q p)
    {q : Form} {p : Prime}
    (hramified : ramified q p)
    (hnonsplit : ¬ splitsCompletely q p) :
    ¬ similarityDescends q := by
  intro hdescends
  exact hnonsplit (local_brauer_necessary q p
    (clifford_necessary q (normalization_necessary q hdescends)) hramified)

/-- If every eligible candidate that passes the real-signature screen fails
split support, then pseudo-arithmeticity is impossible.

This negative theorem intentionally assumes only necessary directions.  In
particular it does not use ABHN, Chebotarev, global form existence, or
Hasse--Minkowski.  A concrete failure of `splitSupport` can be supplied by
either of the two unconditional lemmas above.
-/
theorem all_candidates_fail_splitSupport_not_pseudoArithmetic
    {Object Candidate : Type*}
    (isPseudoArithmetic : Object → Prop)
    (eligible : Object → Candidate → Prop)
    (admissibleSig : Candidate → Prop)
    (similarityDescends normalizedIsometryDescends
      cliffordRestricted splitSupport : Candidate → Prop)
    (pseudoArithmetic_candidate :
      ∀ Γ, isPseudoArithmetic Γ →
        ∃ H, eligible Γ H ∧ admissibleSig H ∧ similarityDescends H)
    (normalization_necessary :
      ∀ H, similarityDescends H → normalizedIsometryDescends H)
    (clifford_necessary :
      ∀ H, normalizedIsometryDescends H → cliffordRestricted H)
    (local_brauer_necessary :
      ∀ H, cliffordRestricted H → splitSupport H)
    (candidate_obstruction :
      ∀ Γ H, eligible Γ H → admissibleSig H → ¬ splitSupport H)
    {Γ : Object} :
    ¬ isPseudoArithmetic Γ := by
  intro hpseudo
  obtain ⟨H, heligible, hadmissible, hdescends⟩ :=
    pseudoArithmetic_candidate Γ hpseudo
  exact candidate_obstruction Γ H heligible hadmissible
    (local_brauer_necessary H
      (clifford_necessary H (normalization_necessary H hdescends)))

/-- Conditional finite-candidate obstruction to pseudo-arithmeticity.

`pseudoArithmetic_candidate` is the geometric/field-of-definition reduction
to an eligible multiquadratic descent candidate.  The remaining hypotheses
are the necessary Clifford and local Brauer facts.  Lean checks that a
ramified nonsplit prime for every eligible candidate contradicts
pseudo-arithmeticity.
-/
theorem all_candidates_obstructed_not_pseudoArithmetic
    {Object Candidate Prime : Type*}
    (isPseudoArithmetic : Object → Prop)
    (eligible : Object → Candidate → Prop)
    (similarityDescends normalizedIsometryDescends
      cliffordRestricted : Candidate → Prop)
    (ramified splitsCompletely : Candidate → Prime → Prop)
    (pseudoArithmetic_candidate :
      ∀ Γ, isPseudoArithmetic Γ →
        ∃ H, eligible Γ H ∧ similarityDescends H)
    (normalization_necessary :
      ∀ H, similarityDescends H → normalizedIsometryDescends H)
    (clifford_necessary :
      ∀ H, normalizedIsometryDescends H → cliffordRestricted H)
    (local_brauer_necessary :
      ∀ H p, cliffordRestricted H → ramified H p → splitsCompletely H p)
    (candidate_obstruction :
      ∀ Γ H, eligible Γ H →
        ∃ p, ramified H p ∧ ¬ splitsCompletely H p)
    {Γ : Object} :
    ¬ isPseudoArithmetic Γ := by
  intro hpseudo
  obtain ⟨H, heligible, hdescends⟩ := pseudoArithmetic_candidate Γ hpseudo
  obtain ⟨p, hramified, hnonsplit⟩ := candidate_obstruction Γ H heligible
  exact hnonsplit (local_brauer_necessary H p
    (clifford_necessary H (normalization_necessary H hdescends)) hramified)

/-- The manuscript's unconditional two-cycle field calculation, connected to
pseudo-arithmeticity through one explicit external theorem hypothesis.

In a geometric application, `pseudoArithmetic_implies_totallyReal` is the
Emery--Mila field-of-definition input after identifying `K` with the adjoint
trace field.
-/
theorem not_pseudoArithmetic_of_cycle_minpoly
    {K : Type*} [Field K] [NumberField K]
    (isPseudoArithmetic : Prop)
    (pseudoArithmetic_implies_totallyReal :
      isPseudoArithmetic → NumberField.IsTotallyReal K)
    (s u : K)
    (hmin : minpoly ℚ s = Polynomial.X ^ 2 - Polynomial.C 5)
    (hrel : (s - 1) * u ^ 2 + 2 * (s - 3) * u + s - 7 = 0) :
    ¬ isPseudoArithmetic := by
  intro hpseudo
  exact not_totallyReal_of_cycle_minpoly s u hmin hrel
    (pseudoArithmetic_implies_totallyReal hpseudo)

end PseudoArithmetic
