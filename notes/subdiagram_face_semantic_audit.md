# Worked semantic audit: principal subdiagrams and the face vector

Reviewed 9 October 2026. This completes the two local computations previously
left outside Lean in entries V06 and V12 of the
[manuscript register](manuscript_semantic_audit.md). The geometric
interpretation remains an explicit imported input, as requested. The
classification and the five face counts no longer depend on trusting Python
or CoxIter output.

## English statements and exact Lean meanings

The first statement is:

> Among the 127 nonempty principal subsets of the actual displayed Gram
> matrix for P₁₁,₈, exactly 54 are positive definite, 12 are positive
> semidefinite but not positive definite, and 61 have a negative direction.
> Exactly ten principal subsets are maximal positive semidefinite.

The definitions use the actual `GramAudit.gram .p11_8`. For a facet set `S`,
`principal S` restricts both rows and columns to that same set. The matrix
entries are real radicals, not floating-point approximations. The central
signature in
[`SubdiagramClassify.lean`](../formal/PseudoArithmetic/SubdiagramClassify.lean)
is:

```lean
theorem classification_correct (S : Facets) (hne : S.Nonempty) :
    ((principal S).PosDef ↔ S ∈ positiveSubsets) ∧
    ((principal S).PosSemidef ∧ ¬ (principal S).PosDef ↔ S ∈ singularSubsets) ∧
    (¬ (principal S).PosSemidef ↔ S ∈ negativeSubsets)
```

`Facets` is `Finset (Fin 7)`, with labels **0 through 6**. Mathlib's
`PosDef` and `PosSemidef` quantify over all real vectors; they are not names
for a Boolean lookup table. `classification_counts` proves the three
cardinalities. `negative_direction` supplies a vector with negative
quadratic value for every member of the third class.

| English clause | Lean expression | Translation check |
| --- | --- | --- |
| Every principal subset of this matrix | `(S : Facets)` and `principal S` | Both indices use `Subtype.val` into the same actual P₁₁,₈ matrix. |
| Nonempty | `hne : S.Nonempty` | The empty matrix is vacuously positive definite, but is excluded from the 127-case list. |
| Exactly the claimed classification | Three biconditionals | Both directions are proved; acceptance and rejection are checked. |
| Positive definite | `(principal S).PosDef` | Strict positivity on every nonzero real vector, including symmetry. |
| Singular positive semidefinite | `PosSemidef ∧ ¬ PosDef` | These finite symmetric matrices have zero directions; the phrase does not mean that every connected component is affine. |
| Maximal among positive-semidefinite subsets | `∀ T, S ⊆ T → (principal T).PosSemidef → T = S` | `maximal_nonnegative_iff` proves that precisely the ten listed incidences satisfy it. Maximality is not assumed. |

The second statement is:

> The nonempty face incidence poset, including the whole polytope, has
> face vector (10,21,18,7,1), with dimension measured by strict face chains.

[`FaceAudit.lean`](../formal/PseudoArithmetic/FaceAudit.lean) defines a face
by the **complete** set of facets containing its vertices. It first selects
incident vertices, closes the facet set, requires a nonempty vertex set,
and counts closed sets by chain dimension. Thus the proof does not merely
check five supplied numbers against Euler's formula.

```lean
theorem face_vector :
    faceCount vertices 0 = 10 ∧ faceCount vertices 1 = 21 ∧
      faceCount vertices 2 = 18 ∧ faceCount vertices 3 = 7 ∧
      faceCount vertices 4 = 1
```

`vertices_are_maximal_nonnegative` in
[`DiagramFaceAudit.lean`](../formal/PseudoArithmetic/DiagramFaceAudit.lean)
connects this exact incidence list to the real-matrix classification.
`dimension_is_stable` proves that the chain recursion has stabilized: every
cutoff of at least four gives the same dimension. A bounded search is
therefore not being mistaken for an unbounded chain height.

The correspondence with geometric faces is stated separately:
`face_count_transfer` assumes a bijection from the geometric nonempty faces
to these closed incidences, preserving dimension. It proves equality of
the resulting counts; `geometric_face_vector` transfers all five numerical
conclusions. The premise supplies no numerical counts. The published
realization and the face-incidence theorem supply its geometric meaning.
Neither an abstract face set nor a test equivalence is advertised as a
constructed hyperbolic polytope.

## How the matrix proof avoids trusting computed answers

[`SubdiagramAudit.lean`](../formal/PseudoArithmetic/SubdiagramAudit.lean)
contains eleven identities of the form

\[
G_S=U^{\mathsf T}\mathrm{diag}(d)U,
\]

where Lean verifies the identity, the invertibility of the triangular
matrix U, and the signs of every diagonal pivot. Nine positive-definite
blocks cover all positive cases; two further positive-semidefinite blocks
cover the ideal vertices. Their ranks are also proved to be three, giving
nullities one and two respectively.

Five minimal negative blocks have explicit vectors with negative quadratic
value. Three additional minimal singular blocks have explicit nonzero
vectors with zero value. Principal-submatrix inheritance and exhaustive
finite coverage then classify every subset. `by decide` checks the finite
coverage inside Lean's kernel; it does not decide positivity of real
matrices or import a numerical program's answer.

## Positive examples and counterexamples to altered statements

A valid implication has no counterexample satisfying all its hypotheses.
The negative controls below prove failure of a specified altered assertion.
They are mathematical Lean theorems, not expected tactic failures.

| Statement or requirement | Satisfying example | Negative control when it is changed |
| --- | --- | --- |
| Positive-definite classification | S={0,1,2,3}; pivots are 1, 1, (5−√5)/8, 3/4. | S={2,6} is positive semidefinite with nonzero zero vector (1,1), so replacing positive semidefinite by positive definite fails. |
| Positive-semidefinite classification | S={2,6}; matrix [[1,−1],[−1,1]]. | S={0,5}; the vector (1,1) has value 2−2a<0 since a>1. |
| Nonempty enumeration | All 127 nonempty subsets are classified. | S=∅ is positive definite but not in `positiveSubsets`; dropping `hne` falsifies the displayed biconditional. |
| Maximal vertex incidence | S={0,1,2,3} is a maximal positive-semidefinite set. | S={0} is positive definite but is not a vertex incidence; omitting maximality fails. |
| Complete vertex list | All ten maximal incidences give ten vertices and two endpoints per elliptic edge. | Deleting any one of the ten vertices gives nine vertices and breaks at least one edge's endpoint count. |
| Exact vertex–facet incidences | The ten computed sets, with seven possible facets each. | Flipping any one of the 70 membership bits gives a set outside the maximal-incidence list. |
| Irredundant vertex encoding | The ten incidences are pairwise incomparable. | The two listed sets {0} and {0,1} produce only one minimal nonempty face. A list length alone cannot give the vertex count. |
| Closed facet sets | The nonsimple ideal vertex is encoded by {2,3,4,5,6}. | {2,3,4,6} has exactly the same incident vertex and closes to the five-facet set; counting both would count that vertex twice. |
| Nonempty faces, including the polytope | The empty facet set represents the whole polytope. | The set of all seven facets has no incident vertices and is excluded. Confusing empty facet set with empty geometric face changes the convention. |
| Dimension-preserving correspondence | Chain dimension gives ten vertices. | Labeling every face as dimension zero gives 57 alleged vertices, so a bijection without dimension preservation is insufficient. |
| Exact face counts | Lean derives (10,21,18,7,1) from the incidence poset. | (10,22,19,7,1) has the same Euler alternating sum 1, but its edge and two-face counts are false. |

The last example is strengthened to an infinite family:

```lean
theorem euler_false_positive_family (t : ℕ) (ht : 0 < t) :
    (10 : ℤ) - (21 + t) + (18 + t) - 7 + 1 = 1 ∧
      faceCount vertices 1 ≠ 21 + t ∧ faceCount vertices 2 ≠ 18 + t
```

This demonstrates a semantic failure that a successful Euler proof would
miss. The intended statement asserts each count, so each count is proved.

The exhaustive controls include all 127 nonempty subsets, all 21 elliptic
edge diagrams, all ten vertex deletions, all 70 incidence-bit flips, every
proper subset of each of the five minimal negative examples, and the
infinite Euler false-positive family. They are in
[`SubdiagramControls.lean`](../formal/PseudoArithmetic/SubdiagramControls.lean)
and [`FaceControls.lean`](../formal/PseudoArithmetic/FaceControls.lean).

## Language and proof boundary

The manuscript distinguishes the kernel-checked local classification and
face counts from the independent CoxIter report. It keeps Vinberg's
geometric criterion, the source realization, and the cusp/link
interpretations explicit. The local classification proves positive
definiteness, positive semidefiniteness, negative directions, maximality,
and the vertex ranks. It does not claim to compute every inertia triple
for all three seven-by-seven matrices; those additional certificates remain
separate exact computations.

The original [two-cycle worked audit](two_cycle_semantic_audit.md) remains
the example for a theorem with removable algebraic hypotheses. In
particular it proves counterexamples after deleting either equation or
allowing a root outside the field, and detects a sign mistranslation that
still admits a valid Lean proof.

## Reproduce

From `formal/`, run `lake build`. From the repository root, run
`python3 scripts/manuscript_audit.py --check` and
`python3 scripts/release_check.py`. The default build includes the new
modules, and the release check audits the axioms of every declaration
registered as statement or example evidence.
