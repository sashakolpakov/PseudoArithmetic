# Manuscript-wide semantic audit

Reviewed 9 October 2026.

The register contains **135 distinct statement entries**, with a positive example and a negative control for each. All **145 source blocks** from the abstract through the final mathematical appendix are classified; 87 blocks contain mathematical assertions. Repeated statements point to the same entries.

**Acceptance criterion: faithful translation and correct use of the imported inputs.** External geometric theorems may remain explicit assumptions. Their proof provenance is separate from translation correctness; using mathlib or a different checked proof is not a defect. The [external-input translation review](external_translation_audit.md) explains all seven input contracts and the disposition of the original 21 partial entries. Boolean interface models test logic, not geometric existence.

A valid theorem has no negative example satisfying all its premises. Negative controls below instead violate a premise, falsify a stronger or mistranslated assertion, change the data, or probe an excluded boundary. A surviving mutation is reported when it proves a different valid theorem. Example evidence is labeled separately from statement status: a Lean link can check a supporting fact without constructing the entire geometric example. Written controls are explicitly not executed proofs.

## Translation assessments

| Assessment | Entries |
| --- | ---: |
| Background generality not separately used by the Lean argument | 8 |
| Matched mathematical statement, checked in Lean | 83 |
| Explicit computational assertion with checked data | 13 |
| Reviewed specialization of an external input | 14 |
| Reviewed external interpretation of the vocabulary | 17 |

## Proof provenance

These counts describe where the mathematics is proved; external or partial provenance is not itself a translation failure.

| Status | Entries |
| --- | ---: |
| Exact computation; not a Lean proof | 9 |
| Implication checked using external predicates/hypotheses | 10 |
| External data with arithmetic/encoding controls | 4 |
| Mathematical statement remains external | 19 |
| Mathematical content checked in Lean | 83 |
| Some mathematical content checked; stated boundary remains | 10 |

The inventory is [machine readable](../audit/manuscript_statements.json). The [coverage checker](../scripts/manuscript_audit.py) verifies exact source-block fingerprints, nonempty positive/negative controls, evidence files, and complete cross-references. It does not infer the English meaning or automatically approve changed text. Every named Lean declaration is checked by the release validator's transitive-axiom audit.

The default Lean build includes the algebraic, geometric, subdiagram, and face audit modules and the specialized external contracts. The [subdiagram and face worked audit](subdiagram_face_semantic_audit.md) proves the classification of all 127 nonempty principal subsets of the actual third Gram matrix and the full face vector (10,21,18,7,1), with all 70 incidence-bit flips, ten vertex deletions, and an infinite family of incorrect vectors that pass Euler's check. Besides the [28,310-case rational barrage](../results/two_cycle_semantic_audit.json), the [independent exact matrix audit](../results/manuscript_computation_audit.json) checks all three ranks/inertias, all 127 principal subdiagrams for the third matrix, and rejects 24 cycle perturbations, 32 power-basis coordinate perturbations, 10 vertex deletions, and 3 rank perturbations. A 7×7 counterexample shows why vanishing principal six-minors alone cannot prove rank five. [PARI controls](../scripts/manuscript_field_controls.gp) distinguish field and polynomial discriminants and verify a pair of nonisomorphic fields sharing degree, signature, and discriminant.

## Findings and changes

The actual Gram matrices and generated cyclic fields are now constructed in Lean. Their two cycles, algebraicity, number-field instances, and non-total reality are proved for every case. The third cyclic field is proved equal to its entry field. New proofs also cover the two embeddings of ℚ(√5), extension of embeddings, discriminant criterion, totally positive radical extensions, Lorentz reflections, orientation indices, and the topological noncompactness argument.

The text now explicitly requires Coxeter-matrix symmetry and lattice discreteness, allows ideal zero angles, and accurately describes the enlarged formal boundary. The supplementary candidate interface is no longer described as proving finiteness. The source census, geometric realization, general adjoint construction, Vinberg identifications, Selberg theorem, and hyperbolic quotient construction remain external or partial as identified below. Exact signature and discriminant calculations remain CAS evidence. These are intentional proof boundaries, not translation failures merely because the imported proofs are absent. The strengthened contracts tie every census case to its actual matrix, identify fields by equality, preserve the n=4 domain, and keep all cover properties on the same witnesses. Translation assessments below state what is reviewed and what is only background.

## Statement register

### G01 — Lorentz form

**English.** The ambient form is the sum of n spatial products minus the time product.

**Status.** Mathematical content checked in Lean. Source lines: 142, 378.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GeometryAudit.lorentz`](../formal/PseudoArithmetic/GeometryAudit.lean); [`PseudoArithmetic.GeometryAudit.lorentz_symmetric`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Positive example (Lean evidence).** In dimension 1+1, (1,0) has norm 1 and (0,1) has norm -1. Evidence: [`PseudoArithmetic.GeometryAudit.space_time_null_examples`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Negative control (Lean evidence).** Changing the final minus to a plus makes (0,1) positive and destroys the hyperboloid equation. Evidence: [`PseudoArithmetic.GeometryAudit.upper_sheet_positive`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Scope.** The form is represented on (Fin n → ℝ) × ℝ; no metric-space identification is asserted.

### G02 — Upper hyperboloid sheet

**English.** Hyperbolic points satisfy norm -1 and strictly positive time coordinate.

**Status.** Mathematical content checked in Lean. Source lines: 142, 378.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GeometryAudit.upperSheet`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Positive example (Lean evidence).** The point (0,1) belongs to the upper sheet in every dimension. Evidence: [`PseudoArithmetic.GeometryAudit.upper_sheet_positive`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Negative control (Lean evidence).** The point (0,-1) has the correct norm but fails the sheet condition. Evidence: [`PseudoArithmetic.GeometryAudit.lower_sheet_negative`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Scope.** This defines the set, not its hyperbolic metric.

### G03 — Projective orthogonal group

**English.** The sheet-preserving orthogonal group represents O(n,1)/{±I} and acts isometrically.

**Status.** Mathematical statement remains external. Source lines: 142.

**Translation.** Background generality not separately used by the Lean argument. The quotient/action statement is background geometry; the dimension-four vocabulary assumes its usual hyperbolic interpretation without constructing the projective quotient. External inputs: background.

**Lean mapping.** No declaration of the full mathematical statement.

**Positive example (written mathematical/control example).** I preserves the upper sheet; each projective class has one sheet-preserving representative.

**Negative control (Lean evidence).** -I preserves the Lorentz form but sends (0,1) to the lower sheet; form preservation alone is insufficient. Evidence: [`PseudoArithmetic.GeometryAudit.lower_sheet_negative`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Scope.** No orthogonal-group quotient, action, or hyperbolic metric is constructed here. The point control alone is kernel checked.

### G04 — Discreteness

**English.** A subgroup is discrete when its identity is isolated.

**Status.** Mathematical statement remains external. Source lines: 142.

**Translation.** Background generality not separately used by the Lean argument. Discreteness is part of the interpreted lattice predicate. The general topological definition is reviewed background, not a separate Lean topology on these groups. External inputs: background.

**Lean mapping.** No declaration of the full mathematical statement.

**Positive example (written mathematical/control example).** The finite subgroup generated by a single reflection is discrete.

**Negative control (written mathematical/control example).** Rational translations z ↦ z+q in the upper half-plane have nonidentity elements converging to identity.

**Scope.** Written examples; no topology on the project reflection group is formalized.

### G05 — Lattice definition

**English.** A lattice is a discrete subgroup with finite-volume quotient.

**Status.** Mathematical statement remains external. Source lines: 93, 142.

**Translation.** Reviewed external interpretation of the vocabulary. The predicate finiteVolumeLattice means both discreteness and finite covolume in fixed dimension four. It does not mean finite volume alone. External inputs: E1.

**Lean mapping.** [`PseudoArithmetic.Manuscript.CoxeterExternalInputs`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.ExternalContracts.Hyperbolic4Vocabulary`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (written mathematical/control example).** PSL₂(ℤ) acting on the upper half-plane illustrates both conditions.

**Negative control (written mathematical/control example).** The trivial group is discrete but its hyperbolic-space quotient has infinite volume. A finite-volume clause alone does not define discreteness.

**Scope.** These familiar two-dimensional examples test the general definition; the manuscript's four-dimensional examples use E1.

### G06 — Orbifold versus manifold

**English.** A discrete quotient is an orbifold, and torsion-freeness gives a manifold.

**Status.** Mathematical statement remains external. Source lines: 142.

**Translation.** Reviewed external interpretation of the vocabulary. The needed torsion-free quotient specialization is exposed by cover_exists and quotient_geometry, using the same subgroup and quotient; the general orbifold assertion is background. External inputs: E5, E7.

**Lean mapping.** [`PseudoArithmetic.Manuscript.ManifoldExternalInputs`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.ExternalContracts.CoverInputs.quotient_geometry`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (written mathematical/control example).** A torsion-free finite-index subgroup supplied by E5 has a manifold quotient by E7.

**Negative control (written mathematical/control example).** A reflection fixes its mirror, so the full reflection group cannot be used as the torsion-free manifold group.

**Scope.** The interface has no orbifold objects; its positive logical model is not a geometric example.

### G07 — Coxeter angles

**English.** Nonzero dihedral angles are π/m with integer m≥2; zero ideal angles are allowed.

**Status.** Some mathematical content checked; stated boundary remains. Source lines: 161, 401.

**Translation.** Reviewed external interpretation of the vocabulary. The off-diagonal Coxeter labels exclude 1 and encode infinity by 0. Angles themselves belong to the geometric interpretation of reflectionGroupOf. External inputs: E1.

**Lean mapping.** [`PseudoArithmetic.GeometryAudit.twoMirrorLabels`](../formal/PseudoArithmetic/GeometryAudit.lean); [`PseudoArithmetic.GeometryAudit.parallelMirrorLabels`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Positive example (Lean evidence).** Labels 3 and infinity are admitted; mathlib encodes infinity by 0. Evidence: [`PseudoArithmetic.GeometryAudit.coxeter_label_examples`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Negative control (Lean evidence).** An off-diagonal label 1 is forbidden. Replacing label 3 by 2 changes its cosine. Evidence: [`PseudoArithmetic.GeometryAudit.off_diagonal_one_forbidden`](../formal/PseudoArithmetic/GeometryAudit.lean); [`PseudoArithmetic.GramAudit.angle_label_mutation`](../formal/PseudoArithmetic/GramAudit.lean).

**Scope.** Coxeter labels and trigonometry are checked; geometric angles are not defined.

### G08 — Symmetry of Coxeter matrices

**English.** A Coxeter matrix is symmetric, has diagonal 1, and no off-diagonal 1.

**Status.** Mathematical content checked in Lean. Source lines: 401.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GeometryAudit.twoMirrorLabels`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Positive example (Lean evidence).** The symmetric two-mirror matrix with off-diagonal 3 is a CoxeterMatrix. Evidence: [`PseudoArithmetic.GeometryAudit.coxeter_label_examples`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Negative control (Lean evidence).** The array with labels 3 and 4 in opposite positions cannot be a CoxeterMatrix. Evidence: [`PseudoArithmetic.GeometryAudit.coxeter_symmetry_required`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Scope.** The prose now explicitly requires symmetry; the previous wording omitted it.

### G09 — Coxeter presentation

**English.** The generators are involutions and (rᵢrⱼ)^m=1 for finite m; infinity imposes no such relation.

**Status.** Mathematical statement remains external. Source lines: 401.

**Translation.** Background generality not separately used by the Lean argument. The Coxeter presentation is reviewed background; the contract interprets reflectionGroupOf as the actual facet-reflection group, not an arbitrary matrix group. External inputs: background.

**Lean mapping.** No declaration of the full mathematical statement.

**Positive example (written mathematical/control example).** Two mirrors at angle π/3 generate a dihedral group of order 6.

**Negative control (written mathematical/control example).** Two parallel mirrors generate an infinite dihedral group; treating the infinity code 0 as order 1 would identify distinct reflections.

**Scope.** The label type is formalized, but its group presentation and the geometric realization are not connected in this project.

### G10 — Reflection fundamental domain

**English.** Facet reflections of a hyperbolic Coxeter polytope form a discrete group with that polytope as fundamental domain.

**Status.** Mathematical statement remains external. Source lines: 161, 409, 865.

**Translation.** Reviewed external interpretation of the vocabulary. reflectionGroupOf includes the Coxeter fundamental polytope interpretation. Its specialization to each actual matrix is census_realization; it is not a theorem about every symmetric matrix. External inputs: E1.

**Lean mapping.** [`PseudoArithmetic.Manuscript.CoxeterExternalInputs.finite_volume`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.ExternalContracts.CensusInputs.census_realization`](../formal/PseudoArithmetic/ExternalContracts.lean); [`PseudoArithmetic.ExternalContracts.CensusInputs.finite_volume`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (written mathematical/control example).** The hyperbolic triangle with angles π/2, π/3, π/7 is the standard finite-area example.

**Negative control (written mathematical/control example).** Two intersecting mirrors whose angle is an irrational multiple of π generate a rotation subgroup accumulating at identity.

**Scope.** Poincaré–Coxeter is external; the examples are written geometric controls, not Lean objects.

### G11 — Covolume from a fundamental domain

**English.** Finite volume of a fundamental domain is equivalent to finite covolume.

**Status.** Mathematical statement remains external. Source lines: 161, 409, 591, 865.

**Translation.** Reviewed external interpretation of the vocabulary. The finite-volume census polytope is a fundamental domain in the intended interpretation, giving finiteVolumeLattice. Quotient measure is not independently defined. External inputs: E1.

**Lean mapping.** No declaration of the full mathematical statement.

**Positive example (written mathematical/control example).** The (2,3,7) triangle has finite area and its reflection group has finite covolume.

**Negative control (written mathematical/control example).** An arbitrary bounded subset of hyperbolic space has finite volume but need not be a fundamental domain for the trivial group.

**Scope.** The fundamental-domain hypothesis is essential; quotient measure is not formalized.

### G12 — Causal vector classes

**English.** A nonzero vector is spacelike, null, or timelike according to the sign of its Lorentz norm.

**Status.** Mathematical content checked in Lean. Source lines: 378.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GeometryAudit.Spacelike`](../formal/PseudoArithmetic/GeometryAudit.lean); [`PseudoArithmetic.GeometryAudit.Null`](../formal/PseudoArithmetic/GeometryAudit.lean); [`PseudoArithmetic.GeometryAudit.Timelike`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Positive example (Lean evidence).** In 1+1 dimensions, (1,0), (1,1), and (0,1) realize the three classes. Evidence: [`PseudoArithmetic.GeometryAudit.space_time_null_examples`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Negative control (Lean evidence).** The zero vector has norm zero but is excluded from the null class. Evidence: [`PseudoArithmetic.GeometryAudit.zero_is_not_null`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Scope.** The explicit nonzero clause matches the English convention.

### G13 — Reflecting hyperplane

**English.** The orthogonal locus of a unit spacelike normal on the hyperboloid is a totally geodesic hyperplane.

**Status.** Some mathematical content checked; stated boundary remains. Source lines: 378.

**Translation.** Reviewed external interpretation of the vocabulary. The orthogonal locus is explicit. The assertion that a unit-spacelike locus is totally geodesic remains the standard geometric interpretation. External inputs: E1.

**Lean mapping.** [`PseudoArithmetic.GeometryAudit.upperSheet`](../formal/PseudoArithmetic/GeometryAudit.lean); [`PseudoArithmetic.GeometryAudit.lorentz`](../formal/PseudoArithmetic/GeometryAudit.lean); [`PseudoArithmetic.GeometryAudit.orthogonalHyperplane`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Positive example (Lean evidence).** For e=(1,0) in 1+1 dimensions, the orthogonal upper-sheet locus is the point (0,1). Evidence: [`PseudoArithmetic.GeometryAudit.upper_sheet_positive`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Negative control (written mathematical/control example).** For the timelike normal e=(0,1), orthogonality forces time zero, so this locus is empty.

**Scope.** Only the algebraic locus and examples are represented; total geodesicity and the general hyperplane theorem are external.

### G14 — Reflection formula

**English.** For a unit spacelike e, reflection is x−2⟨x,e⟩e.

**Status.** Mathematical content checked in Lean. Source lines: 378, 1155.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GeometryAudit.reflect`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Positive example (Lean evidence).** With e=(1,0), reflection sends (3,5) to (-3,5). Evidence: [`PseudoArithmetic.GeometryAudit.reflection_positive_example`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Negative control (Lean evidence).** Changing the minus to a plus sends the first coordinate 3 to 9, not -3. Evidence: [`PseudoArithmetic.GeometryAudit.reflection_sign_mutation`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Scope.** The formula is checked on the vector space; the hyperbolic action remains external.

### G15 — Reflection fixes the mirror

**English.** The reflection fixes every vector orthogonal to e.

**Status.** Mathematical content checked in Lean. Source lines: 378, 1155.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GeometryAudit.reflection_fixes_orthogonal`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Positive example (Lean evidence).** For e=(1,0), all vectors (0,t) are fixed by substitution. Evidence: [`PseudoArithmetic.GeometryAudit.reflection_fixes_orthogonal`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Negative control (Lean evidence).** The vector e is not orthogonal to itself when its norm is 1, and is negated rather than fixed. Evidence: [`PseudoArithmetic.GeometryAudit.reflection_negates_normal`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Scope.** A theorem-schema instantiation is a positive example; no claimed negative example satisfies the hypothesis.

### G16 — Reflection negates its normal

**English.** A unit spacelike normal is mapped to its negative.

**Status.** Mathematical content checked in Lean. Source lines: 378, 1155.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GeometryAudit.reflection_negates_normal`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Positive example (Lean evidence).** The unit normal (1,0) maps to (-1,0). Evidence: [`PseudoArithmetic.GeometryAudit.reflection_negates_normal`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Negative control (Lean evidence).** Using e=(2,0) in the unnormalized formula gives rₑ(e)=(-14,0), not -e. Evidence: [`PseudoArithmetic.GeometryAudit.nonunit_normal_not_negated`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Scope.** Both the normalized theorem and the nonunit numerical counterexample are kernel checked.

### G17 — Reflection is an isometry and involution

**English.** For norm(e)=1, reflection preserves the Lorentz form and its square is identity.

**Status.** Mathematical content checked in Lean. Source lines: 378, 1155.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GeometryAudit.reflection_preserves_form`](../formal/PseudoArithmetic/GeometryAudit.lean); [`PseudoArithmetic.GeometryAudit.reflection_involutive`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Positive example (Lean evidence).** The unit spatial reflection changes the sign of one coordinate twice. Evidence: [`PseudoArithmetic.GeometryAudit.reflection_positive_example`](../formal/PseudoArithmetic/GeometryAudit.lean); [`PseudoArithmetic.GeometryAudit.reflection_involutive`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Negative control (Lean evidence).** With e=(2,0), reflecting (1,0) changes its squared norm from 1 to 49. Evidence: [`PseudoArithmetic.GeometryAudit.nonunit_reflection_fails`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Scope.** Unit normalization cannot be dropped from this formula.

### G18 — Outward half-space convention

**English.** Outward normals give the half-space inequalities ⟨x,eᵢ⟩≤0.

**Status.** Mathematical content checked in Lean. Source lines: 394.

**Translation.** Matched mathematical statement, checked in Lean. Membership is exactly upper-sheet membership and the nonpositive Lorentz inner-product condition. The normal-sign control checks that reversing the normal changes the half-space. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GeometryAudit.lorentz`](../formal/PseudoArithmetic/GeometryAudit.lean); [`PseudoArithmetic.GeometryAudit.outwardHalfSpace`](../formal/PseudoArithmetic/GeometryAudit.lean); [`PseudoArithmetic.GeometryAudit.outward_halfspace_iff`](../formal/PseudoArithmetic/GeometryAudit.lean); [`PseudoArithmetic.GeometryAudit.outward_halfspace_controls`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Positive example (Lean evidence).** The upper-sheet point (-1,√2) belongs to the half-space with normal (1,0). Evidence: [`PseudoArithmetic.GeometryAudit.outward_halfspace_controls`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Negative control (Lean evidence).** The same point does not belong to the half-space with opposite normal (-1,0). Evidence: [`PseudoArithmetic.GeometryAudit.outward_halfspace_controls`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Scope.** This is the explicit algebraic half-space definition with the chosen outward convention. Geometric polytope intersections remain external.

### G19 — Unit Gram diagonal

**English.** A unit-normal Gram matrix has diagonal entries 1.

**Status.** Mathematical content checked in Lean. Source lines: 161, 642.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.gram`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.gram_diagonal`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** Every diagonal entry in each of the three displayed matrices is 1. Evidence: [`PseudoArithmetic.GramAudit.gram_diagonal`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** The doubled matrix has diagonal 2; confusing G with 2G fails this convention. Evidence: [`PseudoArithmetic.GramAudit.doubledGram`](../formal/PseudoArithmetic/GramAudit.lean).

**Scope.** The concrete entries are checked; their realization by geometric normals is external.

### G20 — Intersecting-facet Gram entries

**English.** For outward unit normals, the Gram entry at angle π/m is −cos(π/m).

**Status.** Some mathematical content checked; stated boundary remains. Source lines: 161, 394, 642.

**Translation.** Reviewed external interpretation of the vocabulary. The normalization is unit outward normals, with a minus sign and angle π/m. The exact special cosines and row decoding are checked; the angle/inner-product theorem is imported. External inputs: E1.

**Lean mapping.** [`PseudoArithmetic.GramAudit.special_angles`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.edgeCos_matches_angle`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** Labels 3, 4, 5 give -1/2, -√2/2, -(1+√5)/4. Evidence: [`PseudoArithmetic.GramAudit.special_angles`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** Replacing π/3 by π/2 changes the entry from -1/2 to 0. Evidence: [`PseudoArithmetic.GramAudit.angle_label_mutation`](../formal/PseudoArithmetic/GramAudit.lean).

**Scope.** The exact cosines are kernel checked; the angle-to-inner-product geometric theorem is external.

### G21 — Parallel-facet Gram entries

**English.** Asymptotic facets have unit Gram entry -1.

**Status.** Some mathematical content checked; stated boundary remains. Source lines: 161, 394, 642.

**Translation.** Reviewed external interpretation of the vocabulary. The parallel entry is -1 in the unit-normal convention. Decoding the source symbol 0 to this entry is checked separately from its asymptotic geometry. External inputs: E1.

**Lean mapping.** [`PseudoArithmetic.GramAudit.gram`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.CensusAudit.parallel_code_is_not_zero_entry`](../formal/PseudoArithmetic/CensusAudit.lean).

**Positive example (Lean evidence).** The displayed (2,6) and (6,2) entries equal -1 by definition. Evidence: [`PseudoArithmetic.GramAudit.gram`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** Interpreting the census symbol 0 as a zero Gram entry is rejected; it decodes to -1. Evidence: [`PseudoArithmetic.CensusAudit.parallel_code_is_not_zero_entry`](../formal/PseudoArithmetic/CensusAudit.lean).

**Scope.** The matrix records the intended entry; asymptotic hyperplanes are not constructed.

### G22 — Disjoint-facet Gram entries

**English.** Ultraparallel facets at distance ρ have entry -cosh ρ<-1.

**Status.** Some mathematical content checked; stated boundary remains. Source lines: 161, 394, 642.

**Translation.** Reviewed external interpretation of the vocabulary. The distance formula refers to positive distance between disjoint hyperplanes and outward unit normals. Bounds a,b>1 are checked; the distance interpretation is imported. External inputs: E1.

**Lean mapping.** [`PseudoArithmetic.GramAudit.radicalA_gt_one`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.radicalB_gt_one`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The displayed entries -a and -bⱼ are less than -1 for all cases. Evidence: [`PseudoArithmetic.GramAudit.radicalA_gt_one`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.radicalB_gt_one`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (written mathematical/control example).** The value -1 is the asymptotic boundary and does not represent positive separation.

**Scope.** Bounds are proved; distance and the hyperbolic cosine interpretation are external.

### G23 — Orientation subgroup bound

**English.** The kernel of an orientation character has index at most 2.

**Status.** Mathematical content checked in Lean. Source lines: 417, 900, 1155.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.CoverAudit.orientation_kernel_index_le_two`](../formal/PseudoArithmetic/CoverAudit.lean).

**Positive example (Lean evidence).** The identity character on ℤˣ has kernel of index 2. Evidence: [`PseudoArithmetic.CoverAudit.orientation_positive_example`](../formal/PseudoArithmetic/CoverAudit.lean).

**Negative control (Lean evidence).** The trivial character has index 1, disproving an unconditional claim of index exactly 2. Evidence: [`PseudoArithmetic.CoverAudit.orientation_surjectivity_needed`](../formal/PseudoArithmetic/CoverAudit.lean).

**Scope.** ℤˣ represents {±1}; the geometric orientation character itself is an external construction.

### G24 — Orientation index exactly two

**English.** If an element reverses orientation, the orientation kernel has index 2.

**Status.** Mathematical content checked in Lean. Source lines: 417, 900, 1155, 1239.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.CoverAudit.orientation_kernel_index_eq_two`](../formal/PseudoArithmetic/CoverAudit.lean).

**Positive example (Lean evidence).** The element -1 makes the identity character on ℤˣ surjective. Evidence: [`PseudoArithmetic.CoverAudit.orientation_positive_example`](../formal/PseudoArithmetic/CoverAudit.lean).

**Negative control (Lean evidence).** A character with image {1} has index 1. Evidence: [`PseudoArithmetic.CoverAudit.orientation_surjectivity_needed`](../formal/PseudoArithmetic/CoverAudit.lean).

**Scope.** Identifying each facet reflection as orientation reversing is a geometric input.

### G25 — Finite-index cover and volume

**English.** An index-d subgroup gives a degree-d cover and scales volume by the positive integer d.

**Status.** Some mathematical content checked; stated boundary remains. Source lines: 61, 417, 908, 1130, 1252.

**Translation.** Reviewed external interpretation of the vocabulary. E7 uses finite-index preservation of finite volume. The stronger exact degree-times-volume formula is reviewed geometric background with checked scalar controls, not a hidden extra numerical premise. External inputs: E7.

**Lean mapping.** [`PseudoArithmetic.CoverAudit.positive_degree_volume_scale`](../formal/PseudoArithmetic/CoverAudit.lean); [`PseudoArithmetic.Manuscript.ManifoldExternalInputs.quotient_geometry`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.ExternalContracts.CoverInputs.quotient_geometry`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (Lean evidence).** For d=2, the coefficient 19/864 becomes 19/432. Evidence: [`PseudoArithmetic.CoverAudit.volume_scale_controls`](../formal/PseudoArithmetic/CoverAudit.lean).

**Negative control (Lean evidence).** Leaving the coefficient unchanged is wrong; allowing degree 0 would destroy the positive-volume equivalence. Evidence: [`PseudoArithmetic.CoverAudit.volume_scale_controls`](../formal/PseudoArithmetic/CoverAudit.lean).

**Scope.** Only the scalar implication is kernel checked. Cover degree, volume measure, and their relation remain E7.

### G26 — Selberg's lemma

**English.** A finitely generated characteristic-zero linear group has a torsion-free subgroup of finite index.

**Status.** Mathematical statement remains external. Source lines: 61, 424, 426, 432, 900, 1130, 1239, 1314.

**Translation.** Reviewed specialization of an external input. The imported specialization asks for one finite-index, torsion-free orientation-preserving subgroup together with its quotient; it packages Selberg after the orientation/finite-generation step, not the full general Selberg theorem. External inputs: E5, E7.

**Lean mapping.** [`PseudoArithmetic.Manuscript.ManifoldExternalInputs.finiteIndex_cover_exists`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.ExternalContracts.CoverInputs.cover_exists`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (Lean evidence).** For the finite linear group {±1}, the identity subgroup is torsion-free and has index 2. Evidence: [`PseudoArithmetic.CoverAudit.selberg_finite_group_control`](../formal/PseudoArithmetic/CoverAudit.lean).

**Negative control (Lean evidence).** The ambient group still contains -1 of order 2: the theorem does not say the original group is torsion-free. Evidence: [`PseudoArithmetic.CoverAudit.selberg_finite_group_control`](../formal/PseudoArithmetic/CoverAudit.lean).

**Scope.** This verifies a finite-group example, not the general Selberg theorem or its characteristic-zero hypothesis.

### G27 — Finite generation and linearity

**English.** Finitely many facet reflections generate a finitely generated linear group in characteristic zero.

**Status.** Mathematical statement remains external. Source lines: 432, 900.

**Translation.** Reviewed external interpretation of the vocabulary. Finite generation and linearity justify the E5 specialization; the seven geometric reflections are not constructed as a faithful matrix-group representation in this project. External inputs: E1, E5.

**Lean mapping.** No declaration of the full mathematical statement.

**Positive example (written mathematical/control example).** Seven actual reflections give seven matrix generators over ℝ.

**Negative control (written mathematical/control example).** Infinitely many listed generators would not by itself prove finite generation; an abstract group without a faithful linear representation does not meet Selberg's premises.

**Scope.** Neither the generated matrix group nor the finite-generation argument is instantiated in Lean.

### G28 — Free action and orientability

**English.** A torsion-free discrete hyperbolic group acts freely; an orientation-preserving such group has orientable quotient.

**Status.** Mathematical statement remains external. Source lines: 61, 432, 908, 1130, 1252.

**Translation.** Reviewed specialization of an external input. Finite volume, noncompactness, finite index, torsion/orientation, and quotient correspondence concern the same subgroup and quotient. The conclusion supplies both the cover lattice and the manifold geometry. External inputs: E7.

**Lean mapping.** [`PseudoArithmetic.Manuscript.ManifoldExternalInputs.quotient_geometry`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.ExternalContracts.CoverInputs.quotient_geometry`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (written mathematical/control example).** A hyperbolic translation generates a torsion-free discrete group with an orientable cylinder quotient.

**Negative control (written mathematical/control example).** A half-turn has torsion and fixes a point. An infinite irrational rotation subgroup is torsion-free but not discrete and fixes a point.

**Scope.** These written controls isolate torsion and discreteness; the action and quotient are not formalized.

### G29 — Noncompactness passes to a cover

**English.** A space admitting a continuous surjection onto a noncompact space is noncompact.

**Status.** Mathematical content checked in Lean. Source lines: 61, 432, 908, 1130, 1155, 1252.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.CoverAudit.noncompact_of_continuous_surjective`](../formal/PseudoArithmetic/CoverAudit.lean).

**Positive example (Lean evidence).** Projection ℝ×Fin 2 → ℝ gives the required noncompact two-sheeted example. Evidence: [`PseudoArithmetic.CoverAudit.noncompact_cover_positive`](../formal/PseudoArithmetic/CoverAudit.lean).

**Negative control (Lean evidence).** The constant map from the compact one-point space to ℝ is continuous but not surjective. Evidence: [`PseudoArithmetic.CoverAudit.surjectivity_needed_for_noncompactness`](../formal/PseudoArithmetic/CoverAudit.lean).

**Scope.** The proved topological statement is stronger than the finite-cover case; E7 supplies the quotient map.

### G30 — Finite volume is not noncompactness

**English.** The manifold corollary needs noncompactness of the base separately from finite volume.

**Status.** Implication checked using external predicates/hypotheses. Source lines: 908, 1130, 1206.

**Translation.** Reviewed specialization of an external input. Finite volume and noncompactness are distinct premises, and quotient_geometry consumes both. A Boolean control explicitly separates them. External inputs: E1, E7.

**Lean mapping.** [`PseudoArithmetic.Manuscript.ManifoldExternalInputs.noncompact`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.ExternalContracts.CensusInputs.noncompact`](../formal/PseudoArithmetic/ExternalContracts.lean); [`PseudoArithmetic.ExternalContracts.CoverInputs.quotient_geometry`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (Lean evidence).** The census rows have positive cusp counts, supporting the separate noncompact input. Evidence: [`PseudoArithmetic.CensusAudit.all_cases_have_cusps`](../formal/PseudoArithmetic/CensusAudit.lean).

**Negative control (Lean evidence).** The predicates finiteVolume=True and noncompact=False are consistent; compact hyperbolic quotients also illustrate the mathematical distinction. Evidence: [`PseudoArithmetic.InterfaceAudit.finite_volume_does_not_logically_imply_noncompactness`](../formal/PseudoArithmetic/InterfaceAudit.lean).

**Scope.** The Lean negative example tests logical independence; the geometric compact example is written only.

### G31 — Finite-index finite generation

**English.** A finite-index subgroup of a finitely generated group is finitely generated.

**Status.** Mathematical content checked in Lean. Source lines: 900.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.CoverAudit.finite_index_subgroup_finitely_generated`](../formal/PseudoArithmetic/CoverAudit.lean).

**Positive example (Lean evidence).** The orientation kernel is finite index, so Schreier’s lemma supplies finite generation for the Selberg step. Evidence: [`PseudoArithmetic.CoverAudit.finite_index_subgroup_finitely_generated`](../formal/PseudoArithmetic/CoverAudit.lean).

**Negative control (written mathematical/control example).** Finite index alone is insufficient: an infinite direct sum of order-two groups has index 1 in itself but is not finitely generated.

**Scope.** The general group theorem is imported from mathlib and checked here. The negative example has the elementary written proof that finitely many generators have support in only finitely many coordinates.

### F01 — Number fields

**English.** A number field is a finite extension of ℚ.

**Status.** Mathematical content checked in Lean. Source lines: 182, 839, 871.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.SemanticAudit.witnessField`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.GramAudit.entryField_numberField`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.cycleField_numberField`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The fields generated by the actual entries and cycles have NumberField instances. Evidence: [`PseudoArithmetic.GramAudit.entryField_numberField`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.cycleField_numberField`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (written mathematical/control example).** An arbitrary subfield of ℝ is not automatically a number field: ℝ itself is not finite-dimensional over ℚ.

**Scope.** The positive examples are concrete. The negative example is a written distinction, not a project theorem on the dimension of ℝ.

### F02 — Field embeddings

**English.** A unital field homomorphism into ℂ is injective and fixes the rationals.

**Status.** Mathematical content checked in Lean. Source lines: 182, 308, 327.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.FieldAudit.embedding_injective`](../formal/PseudoArithmetic/FieldAudit.lean); [`PseudoArithmetic.FieldAudit.embedding_fixes_rationals`](../formal/PseudoArithmetic/FieldAudit.lean).

**Positive example (Lean evidence).** The real inclusion and both embeddings of ℚ(√5) satisfy these conditions. Evidence: [`PseudoArithmetic.FieldAudit.sqrt_five_exactly_two_embeddings`](../formal/PseudoArithmetic/FieldAudit.lean).

**Negative control (Lean evidence).** The zero function is not a unital field embedding. Evidence: [`PseudoArithmetic.FieldAudit.zero_function_not_embedding`](../formal/PseudoArithmetic/FieldAudit.lean).

**Scope.** Lean's RingHom and field instances imply the English injectivity and rational-fixing clauses.

### F03 — Total reality quantifier

**English.** A number field is totally real exactly when every complex embedding is real.

**Status.** Mathematical content checked in Lean. Source lines: 182, 493, 847.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.SemanticAudit.baseField_totallyReal`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.SemanticAudit.real_embedding_does_not_mean_totallyReal`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Positive example (Lean evidence).** ℚ(√5) is totally real, including its negative embedding. Evidence: [`PseudoArithmetic.SemanticAudit.baseField_totallyReal`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.FieldAudit.sqrt_five_exactly_two_embeddings`](../formal/PseudoArithmetic/FieldAudit.lean).

**Negative control (Lean evidence).** The constructed witness field lies in ℝ but has a nonreal embedding. Evidence: [`PseudoArithmetic.SemanticAudit.real_embedding_does_not_mean_totallyReal`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.SemanticAudit.witness_has_nonreal_embedding`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** A distinguished real embedding must not replace the universal quantifier.

### F04 — Non-total reality versus total complexity

**English.** One nonreal embedding refutes total reality; it need not exclude all real embeddings.

**Status.** Mathematical content checked in Lean. Source lines: 182, 847, 1343.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.SemanticAudit.witness_has_nonreal_embedding`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.SemanticAudit.witness_not_totallyComplex`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Positive example (Lean evidence).** The witness field has both a real inclusion and a nonreal embedding. Evidence: [`PseudoArithmetic.SemanticAudit.witness_has_nonreal_embedding`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.SemanticAudit.witness_not_totallyComplex`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Negative control (Lean evidence).** Translating 'not totally real' as 'totally complex' fails on this same field. Evidence: [`PseudoArithmetic.SemanticAudit.witness_not_totallyComplex`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** Negating a universal statement gives existence of a nonreal embedding, not absence of real embeddings.

### F05 — Minimal polynomial normalization

**English.** The minimal polynomial of an algebraic element is the unique monic annihilator of least positive degree.

**Status.** Mathematical content checked in Lean. Source lines: 286, 292.

**Translation.** Matched mathematical statement, checked in Lean. The equivalence states monicity, positive degree, annihilation, and minimal degree among nonzero annihilators over a number field. Mathlib supplies the checked uniqueness argument. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.minpoly_eq_of_square_five`](../formal/PseudoArithmetic/NonTotalReality.lean); [`PseudoArithmetic.FieldAudit.vanishes_iff_minpoly_dvd`](../formal/PseudoArithmetic/FieldAudit.lean); [`PseudoArithmetic.FieldAudit.minpoly_characterization`](../formal/PseudoArithmetic/FieldAudit.lean).

**Positive example (Lean evidence).** For √5 it is X²-5. Evidence: [`PseudoArithmetic.minpoly_eq_of_square_five`](../formal/PseudoArithmetic/NonTotalReality.lean).

**Negative control (Lean evidence).** The square (X²-5)² also annihilates √5 but is not minimal. Evidence: [`PseudoArithmetic.FieldAudit.annihilating_polynomial_need_not_be_minimal`](../formal/PseudoArithmetic/FieldAudit.lean).

**Scope.** The wrapper is stated for number fields, the domain of the manuscript argument. The proof may use mathlib; no new uniqueness axiom is assumed.

### F06 — Kernel of polynomial evaluation

**English.** An annihilating polynomial is divisible by the minimal polynomial.

**Status.** Mathematical content checked in Lean. Source lines: 292, 327.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.FieldAudit.vanishes_iff_minpoly_dvd`](../formal/PseudoArithmetic/FieldAudit.lean).

**Positive example (Lean evidence).** Both X²-5 and its square vanish at √5. Evidence: [`PseudoArithmetic.FieldAudit.annihilating_polynomial_need_not_be_minimal`](../formal/PseudoArithmetic/FieldAudit.lean).

**Negative control (Lean evidence).** X²-4 evaluates to 1 at √5, so it is not in the evaluation kernel. Evidence: [`PseudoArithmetic.SemanticAudit.radicalS_square`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** The negative value follows immediately from the square identity; the theorem is divisibility, not equality of annihilators.

### F07 — Irrationality of √5

**English.** No rational number equals √5.

**Status.** Mathematical content checked in Lean. Source lines: 298, 308.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.FieldAudit.sqrt_five_irrational`](../formal/PseudoArithmetic/FieldAudit.lean); [`PseudoArithmetic.sqrt5_polynomial_irreducible`](../formal/PseudoArithmetic/NonTotalReality.lean).

**Positive example (Lean evidence).** The prime nonsquare argument excludes every rational candidate. Evidence: [`PseudoArithmetic.FieldAudit.sqrt_five_irrational`](../formal/PseudoArithmetic/FieldAudit.lean).

**Negative control (Lean evidence).** √4=2 is rational, so replacing '5' by an arbitrary positive integer is false. Evidence: [`PseudoArithmetic.FieldAudit.sqrt_four_rational`](../formal/PseudoArithmetic/FieldAudit.lean).

**Scope.** The proof uses the verified rational nonsquare theorem rather than assuming irrationality.

### F08 — Square identity and minimal polynomial

**English.** In a characteristic-zero field, s²=5 is equivalent to minpolyℚ(s)=X²-5.

**Status.** Mathematical content checked in Lean. Source lines: 298, 308, 847, 1062, 1314.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.SemanticAudit.square_iff_minpoly`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Positive example (Lean evidence).** The distinguished √5 element of the witness field satisfies both. Evidence: [`PseudoArithmetic.SemanticAudit.witness_square`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.SemanticAudit.square_iff_minpoly`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Negative control (Lean evidence).** Taking s=7 and u=0 over ℚ satisfies the relation but not s²=5; its minimal polynomial cannot be X²-5. Evidence: [`PseudoArithmetic.SemanticAudit.square_hypothesis_necessary`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** The equivalence removes the formerly external irreducibility premise.

### F09 — Exactly two embeddings of ℚ(√5)

**English.** Its complex embeddings send √5 to ±√5, both choices occur, and the generator image determines the embedding.

**Status.** Mathematical content checked in Lean. Source lines: 298, 308, 813, 1155, 1232.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.FieldAudit.sqrt_five_exactly_two_embeddings`](../formal/PseudoArithmetic/FieldAudit.lean); [`PseudoArithmetic.FieldAudit.base_embedding_ext`](../formal/PseudoArithmetic/FieldAudit.lean).

**Positive example (Lean evidence).** The real inclusion and the negative conjugate are distinct embeddings. Evidence: [`PseudoArithmetic.FieldAudit.sqrt_five_exactly_two_embeddings`](../formal/PseudoArithmetic/FieldAudit.lean).

**Negative control (Lean evidence).** A putative third embedding with a different generator image is excluded by the same exhaustive theorem. Evidence: [`PseudoArithmetic.FieldAudit.sqrt_five_exactly_two_embeddings`](../formal/PseudoArithmetic/FieldAudit.lean).

**Scope.** The statement is exactly two, not merely at least two or merely real roots of a polynomial.

### F10 — Extension of number-field embeddings

**English.** Every complex embedding of a number subfield extends to the ambient number field.

**Status.** Mathematical content checked in Lean. Source lines: 182, 320, 327, 368, 839, 1155, 1232.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.FieldAudit.embedding_extension`](../formal/PseudoArithmetic/FieldAudit.lean).

**Positive example (Lean evidence).** The identity embedding of ℚ extends to each of the two embeddings of ℚ(√5). Evidence: [`PseudoArithmetic.FieldAudit.embedding_extension_not_unique`](../formal/PseudoArithmetic/FieldAudit.lean).

**Negative control (Lean evidence).** Replacing existence by uniqueness fails: those two extensions agree on ℚ. Evidence: [`PseudoArithmetic.FieldAudit.embedding_extension_not_unique`](../formal/PseudoArithmetic/FieldAudit.lean).

**Scope.** Mathlib proves the extension theorem; the local proof uses ComplexEmbedding.lift.

### F11 — Transported polynomial argument

**English.** Transporting an irreducible minimal polynomial and choosing a complex root gives an extending field embedding.

**Status.** Mathematical content checked in Lean. Source lines: 182, 327, 1232.

**Translation.** Matched mathematical statement, checked in Lean. The quotient-root construction is an injective unital field homomorphism that restricts to the given base embedding and sends the distinguished root to the chosen complex root. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.FieldAudit.embedding_extension`](../formal/PseudoArithmetic/FieldAudit.lean); [`PseudoArithmetic.FieldAudit.transported_root_embedding`](../formal/PseudoArithmetic/FieldAudit.lean).

**Positive example (Lean evidence).** For ℚ⊂ℚ(√5), the transported polynomial X²-5 has roots ±√5. Evidence: [`PseudoArithmetic.FieldAudit.sqrt_five_exactly_two_embeddings`](../formal/PseudoArithmetic/FieldAudit.lean).

**Negative control (written mathematical/control example).** Transporting to ℝ instead of the algebraically closed field ℂ fails for X²+1.

**Scope.** The root embedding is constructed for AdjoinRoot of an irreducible polynomial. The general extension theorem and primitive-element theorem are also checked; the written proof need not be replayed by the same tactics.

### F12 — Quadratic discriminant criterion

**English.** For a≠0, ax²+bx+c has a real root iff b²-4ac≥0.

**Status.** Mathematical content checked in Lean. Source lines: 345, 352, 813, 1155.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.FieldAudit.quadratic_root_iff`](../formal/PseudoArithmetic/FieldAudit.lean).

**Positive example (Lean evidence).** x²-1 has roots; x²+2x+1 has the double root -1. Evidence: [`PseudoArithmetic.FieldAudit.quadratic_positive_and_negative`](../formal/PseudoArithmetic/FieldAudit.lean); [`PseudoArithmetic.FieldAudit.discriminant_zero_has_root`](../formal/PseudoArithmetic/FieldAudit.lean).

**Negative control (Lean evidence).** x²+1 has no real root; for a=b=0,c=1 the discriminant is 0 but no root exists. Evidence: [`PseudoArithmetic.FieldAudit.quadratic_positive_and_negative`](../formal/PseudoArithmetic/FieldAudit.lean); [`PseudoArithmetic.FieldAudit.quadratic_leading_coefficient_necessary`](../formal/PseudoArithmetic/FieldAudit.lean).

**Scope.** The nonzero leading coefficient and non-strict discriminant inequality are both essential.

### F13 — Nonreal subfield persistence

**English.** If a number subfield is not totally real, neither is any number-field extension.

**Status.** Mathematical content checked in Lean. Source lines: 362, 368, 888.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.FieldAudit.nonreal_subfield_persists`](../formal/PseudoArithmetic/FieldAudit.lean).

**Positive example (Lean evidence).** The witness field is a non-totally-real extension of itself, and the theorem applies to every further number-field extension. Evidence: [`PseudoArithmetic.SemanticAudit.concrete_positive_example`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.FieldAudit.nonreal_subfield_persists`](../formal/PseudoArithmetic/FieldAudit.lean).

**Negative control (Lean evidence).** The converse is false: ℚ is totally real inside the non-totally-real witness field. Evidence: [`PseudoArithmetic.FieldAudit.persistence_converse_false`](../formal/PseudoArithmetic/FieldAudit.lean).

**Scope.** The Algebra instance encodes the inclusion; field homomorphisms are injective.

### F14 — Positive real square roots

**English.** For x≥0, the chosen real square root is nonnegative and has square x.

**Status.** Mathematical content checked in Lean. Source lines: 352, 619, 733.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.SemanticAudit.radicalS_square`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.RadicalAudit.radicalT_positive`](../formal/PseudoArithmetic/RadicalAudit.lean).

**Positive example (Lean evidence).** The positive radicals √5 and √(2+2√5) satisfy their square equations. Evidence: [`PseudoArithmetic.SemanticAudit.radicalS_square`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.RadicalAudit.radicalT_positive`](../formal/PseudoArithmetic/RadicalAudit.lean).

**Negative control (Lean evidence).** Lean defines Real.sqrt(-1)=0, whose square is not -1; omitting nonnegativity is false. Evidence: [`PseudoArithmetic.FieldAudit.negative_real_sqrt_control`](../formal/PseudoArithmetic/FieldAudit.lean).

**Scope.** The total real sqrt function does not silently choose a complex root.

### F15 — Algebraicity of the displayed radicals

**English.** The finitely many displayed rational expressions and nested square roots are algebraic over ℚ.

**Status.** Mathematical content checked in Lean. Source lines: 619, 871.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.integral_sqrt`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.radicalA_integral`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.radicalB_integral`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** All entries in each displayed Gram matrix are integral over the field ℚ. Evidence: [`PseudoArithmetic.GramAudit.gram_entries_integral`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (written mathematical/control example).** Being real alone does not imply algebraicity; replacing an entry by a transcendental real would invalidate this argument.

**Scope.** Here 'integral over ℚ' means algebraic, not algebraic integer. The negative transcendence example is explanatory, not newly proved.

### F16 — Primitive-element step

**English.** A finite extension of number fields is separable and generated by one element.

**Status.** Mathematical content checked in Lean. Source lines: 327.

**Translation.** Matched mathematical statement, checked in Lean. For an extension of number fields the declaration supplies both separability and a single element whose adjoin is the whole extension. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.FieldAudit.embedding_extension`](../formal/PseudoArithmetic/FieldAudit.lean); [`PseudoArithmetic.FieldAudit.number_field_primitive_element`](../formal/PseudoArithmetic/FieldAudit.lean).

**Positive example (Lean evidence).** For ℚ(√5)/ℚ the generator is √5. Evidence: [`PseudoArithmetic.FieldAudit.sqrt_five_exactly_two_embeddings`](../formal/PseudoArithmetic/FieldAudit.lean).

**Negative control (written mathematical/control example).** Characteristic p extensions can be inseparable: over Fₚ(t), Xᵖ-t has only one distinct root in an algebraic closure.

**Scope.** Both number fields and their algebra structure are explicit. The characteristic-p inseparability control is a written boundary example outside this domain.

### F17 — Complex root and quotient construction

**English.** A nonconstant transported polynomial has a complex root, and evaluation at that root factors through its defining ideal.

**Status.** Mathematical content checked in Lean. Source lines: 327.

**Translation.** Matched mathematical statement, checked in Lean. Positive polynomial degree supplies a complex root; vanishing under the transported evaluation gives a homomorphism out of the polynomial quotient. Nonconstancy and evaluation vanishing are explicit, separate premises. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.FieldAudit.embedding_extension`](../formal/PseudoArithmetic/FieldAudit.lean); [`PseudoArithmetic.FieldAudit.vanishes_iff_minpoly_dvd`](../formal/PseudoArithmetic/FieldAudit.lean); [`PseudoArithmetic.FieldAudit.complex_nonconstant_has_root`](../formal/PseudoArithmetic/FieldAudit.lean); [`PseudoArithmetic.FieldAudit.evaluation_factors_through_quotient`](../formal/PseudoArithmetic/FieldAudit.lean); [`PseudoArithmetic.FieldAudit.constant_one_has_no_root`](../formal/PseudoArithmetic/FieldAudit.lean).

**Positive example (Lean evidence).** X²+1 has the complex root i; evaluation at i kills the polynomial. Evidence: [`PseudoArithmetic.FieldAudit.negative_radicand_counterexample`](../formal/PseudoArithmetic/FieldAudit.lean).

**Negative control (Lean evidence).** The nonzero constant polynomial 1 has no complex root: omitting nonconstancy would give a false statement. Evidence: [`PseudoArithmetic.FieldAudit.constant_one_has_no_root`](../formal/PseudoArithmetic/FieldAudit.lean).

**Scope.** Root existence and the quotient map are separate checked declarations. Irreducibility is needed to obtain a field embedding, not merely to factor evaluation through the quotient.

### T01 — Adjoint representation

**English.** Ad(g) is conjugation X ↦ gXg⁻¹ on the Lie algebra, not the defining matrix g itself.

**Status.** Some mathematical content checked; stated boundary remains. Source lines: 193, 448.

**Translation.** Reviewed external interpretation of the vocabulary. The field-valued vocabulary denotes the real adjoint representation. The sl₂ control rules out conflating adjoint and defining traces; construction of the general Lie algebra remains external. External inputs: E2.

**Lean mapping.** [`PseudoArithmetic.TraceAudit.sl2_diagonal_conjugation`](../formal/PseudoArithmetic/TraceAudit.lean).

**Positive example (Lean evidence).** For g=diag(2,1/2) on sl₂, conjugation has eigenvalues 1,4,1/4 and trace 21/4. Evidence: [`PseudoArithmetic.TraceAudit.sl2_diagonal_conjugation`](../formal/PseudoArithmetic/TraceAudit.lean); [`PseudoArithmetic.TraceAudit.adjoint_trace_is_not_defining_trace`](../formal/PseudoArithmetic/TraceAudit.lean).

**Negative control (Lean evidence).** The defining matrix trace is 5/2, different from 21/4. Evidence: [`PseudoArithmetic.TraceAudit.adjoint_trace_is_not_defining_trace`](../formal/PseudoArithmetic/TraceAudit.lean).

**Scope.** The concrete sl₂ conjugation calculation is formal; no general Lie-algebra or lattice Ad construction is instantiated.

### T02 — Basis independence of trace

**English.** Conjugating a matrix by an invertible basis change preserves its trace.

**Status.** Mathematical content checked in Lean. Source lines: 193, 448.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.TraceAudit.trace_basis_independent`](../formal/PseudoArithmetic/TraceAudit.lean).

**Positive example (Lean evidence).** Every P,A,Q with QP=1 has trace(PAQ)=trace(A). Evidence: [`PseudoArithmetic.TraceAudit.trace_basis_independent`](../formal/PseudoArithmetic/TraceAudit.lean).

**Negative control (Lean evidence).** An arbitrary unmatched left/right multiplication can change trace; the 1×1 traces 12 and 3 differ. Evidence: [`PseudoArithmetic.TraceAudit.wrong_basis_change_control`](../formal/PseudoArithmetic/TraceAudit.lean).

**Scope.** The inverse condition on the basis change is explicit.

### T03 — Adjoint trace field definition

**English.** The field is the rational field generated by all adjoint traces, rather than all matrix entries.

**Status.** Some mathematical content checked; stated boundary remains. Source lines: 193, 448.

**Translation.** Reviewed external interpretation of the vocabulary. adjointTraceField is a field-valued function interpreted as adjoining all adjoint traces. E2 and E6 are literal equalities involving this same function, not free predicates about unrelated fields. External inputs: E2, E6.

**Lean mapping.** [`PseudoArithmetic.TraceAudit.representationTraceField`](../formal/PseudoArithmetic/TraceAudit.lean); [`PseudoArithmetic.ExternalContracts.Hyperbolic4Vocabulary.adjointTraceField`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (Lean evidence).** The construction adjoins the range of traces of the supplied matrices. Evidence: [`PseudoArithmetic.TraceAudit.representationTraceField`](../formal/PseudoArithmetic/TraceAudit.lean).

**Negative control (Lean evidence).** Using defining-representation traces changes the generating data in the sl₂ example. Evidence: [`PseudoArithmetic.TraceAudit.adjoint_trace_is_not_defining_trace`](../formal/PseudoArithmetic/TraceAudit.lean).

**Scope.** The supplied matrices are not verified to be the actual Ad representation of the reflection group.

### T04 — Trace-field subgroup inclusion

**English.** Restricting the set of group elements can only decrease the generated trace field.

**Status.** Mathematical content checked in Lean. Source lines: 462.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.TraceAudit.traceField_restrict_le`](../formal/PseudoArithmetic/TraceAudit.lean).

**Positive example (Lean evidence).** Restriction along any map of index types gives the required field inclusion. Evidence: [`PseudoArithmetic.TraceAudit.traceField_restrict_le`](../formal/PseudoArithmetic/TraceAudit.lean).

**Negative control (Lean evidence).** Equality cannot be inferred just from a subset of generators: {0} generates ℚ while {0,√5} generates a larger field. Evidence: [`PseudoArithmetic.FieldAudit.sqrt_five_irrational`](../formal/PseudoArithmetic/FieldAudit.lean).

**Scope.** This proves the easy inclusion and does not replace the finite-index invariance theorem.

### T05 — Finite-index invariance

**English.** For the lattices under consideration, a finite-index subgroup has the same adjoint trace field.

**Status.** Mathematical statement remains external. Source lines: 193, 462, 919, 1130, 1246.

**Translation.** Reviewed specialization of an external input. The base is a finite-volume lattice, finiteIndex Λ Γ is directed from cover to base, and the conclusion is equality of their actual field values. External inputs: E6.

**Lean mapping.** [`PseudoArithmetic.Manuscript.ManifoldExternalInputs.traceField_finiteIndex_invariant`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.ExternalContracts.CoverInputs.traceField_invariant`](../formal/PseudoArithmetic/ExternalContracts.lean); [`PseudoArithmetic.ExternalContracts.finite_index_argument_order_control`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (Lean evidence).** The contract model preserves exactly the same matrix-derived field for its cover/base pair. Evidence: [`PseudoArithmetic.ExternalContracts.cover_contract_positive`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Negative control (written mathematical/control example).** For arbitrary defining traces, the cyclic group generated by the scalar √2 has field ℚ(√2), while its index-2 subgroup generated by 2 has field ℚ.

**Scope.** The written negative example excludes a false generalization. The Lean positive model checks only the interface; E6 remains external.

### T06 — Zariski density

**English.** Borel density supplies Zariski density for lattices in the connected noncompact simple group.

**Status.** Mathematical statement remains external. Source lines: 206, 448.

**Translation.** Background generality not separately used by the Lean argument. Borel density supplies the Zariski-density premise behind the cited field results. The general density statement is reviewed background, not an additional unchecked Lean inference. External inputs: background.

**Lean mapping.** No declaration of the full mathematical statement.

**Positive example (written mathematical/control example).** A finite-covolume hyperbolic lattice meets the cited theorem's hypotheses.

**Negative control (written mathematical/control example).** The trivial subgroup is not Zariski dense in a nontrivial simple group; it also fails finite covolume.

**Scope.** No Zariski topology or Borel density instance is formalized for the examples.

### T07 — Ambient algebraic group

**English.** Vinberg supplies a form over the adjoint trace field, unique up to field-isomorphism of groups.

**Status.** Mathematical statement remains external. Source lines: 206, 448.

**Translation.** Background generality not separately used by the Lean argument. The ambient algebraic group is interpreted through the cited Vinberg theorem. Its construction and uniqueness are background behind E3, not claimed as constructed Lean objects. External inputs: background, E3.

**Lean mapping.** No declaration of the full mathematical statement.

**Positive example (written mathematical/control example).** A group already defined over ℚ with Zariski-dense arithmetic subgroup illustrates descent to ℚ.

**Negative control (written mathematical/control example).** An abstract predicate 'has trace field K' does not construct an algebraic group or its scalar-extension isomorphism.

**Scope.** This is a stated external construction, and no positive or negative algebraic-group object is checked in Lean.

### T08 — Admissibility

**English.** The base is totally real, exactly one real factor is the required noncompact orthogonal group, and the others are compact.

**Status.** Mathematical statement remains external. Source lines: 206, 475.

**Translation.** Background generality not separately used by the Lean argument. The admissibility definition requires a totally real base and exactly one appropriate noncompact real factor. Its algebraic-group objects are background to E3. External inputs: background, E3.

**Lean mapping.** No declaration of the full mathematical statement.

**Positive example (written mathematical/control example).** Over ℚ, the form diag(1,1,1,1,-1) has one Lorentzian real place.

**Negative control (written mathematical/control example).** The positive-definite form diag(1,1,1,1,1) gives a compact real group and fails the required noncompact factor.

**Scope.** These explicit signature examples test the definition in writing; admissible algebraic groups are not defined in Lean.

### T09 — Pseudo-admissibility

**English.** For n>3 the ambient group must be scalar extension of an admissible group through a finite totally real multiquadratic extension.

**Status.** Mathematical statement remains external. Source lines: 93, 206, 481, 493.

**Translation.** Reviewed external interpretation of the vocabulary. The imported implication is specialized to dimension four and the totally real meaning of the multiquadratic extension. It does not assert that a merely real embedding makes a lattice pseudo-arithmetic. External inputs: E3.

**Lean mapping.** [`PseudoArithmetic.Manuscript.CoxeterExternalInputs.pseudoArithmetic_totallyReal`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.ExternalContracts.CensusInputs.pseudoArithmetic_totallyReal`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (written mathematical/control example).** The trivial extension K=k is allowed and includes quasi-arithmetic examples.

**Negative control (written mathematical/control example).** Demanding a strictly nontrivial extension would wrongly exclude this t=0 case.

**Scope.** The exact geometric definition is external; the Lean predicate retains only the implication needed by the proof.

### T10 — Total positivity of multiquadratic radicands

**English.** Over a totally real number field, an extension generated by square roots of nonzero base elements is totally real if and only if every defining radicand is totally positive.

**Status.** Mathematical content checked in Lean. Source lines: 206, 493, 507, 1155.

**Translation.** Matched mathematical statement, checked in Lean. The equivalence quantifies over every real embedding of the base and every nonzero defining radicand. A single real embedding is insufficient. The generating-adjoin hypothesis belongs to the sufficient direction. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.FieldAudit.totally_positive_radicals_totallyReal`](../formal/PseudoArithmetic/FieldAudit.lean); [`PseudoArithmetic.FieldAudit.radicands_totally_positive_of_totallyReal`](../formal/PseudoArithmetic/FieldAudit.lean); [`PseudoArithmetic.FieldAudit.radical_extension_totallyReal_iff`](../formal/PseudoArithmetic/FieldAudit.lean).

**Positive example (Lean evidence).** ℚ(√5)/ℚ uses the positive radicand 5. Evidence: [`PseudoArithmetic.SemanticAudit.baseField_totallyReal`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Negative control (executed exact computation).** Over ℚ(√5), adjoining √(√5) gives a real embedding but not a totally real field; X⁴-5 has signature (2,1). Evidence: [manuscript_field_controls.gp](../scripts/manuscript_field_controls.gp).

**Scope.** The total-reality/total-positivity equivalence is proved for number fields generated by square roots of nonzero base elements. The algebraic-group definition connecting it to pseudo-arithmeticity remains E3.

### T11 — Positive square gives real image

**English.** A complex number whose square is a positive real number is itself real.

**Status.** Mathematical content checked in Lean. Source lines: 507.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.FieldAudit.complex_square_positive_is_real`](../formal/PseudoArithmetic/FieldAudit.lean).

**Positive example (Lean evidence).** Every embedded radical in the positive-radicand theorem has real image. Evidence: [`PseudoArithmetic.FieldAudit.totally_positive_radicals_totallyReal`](../formal/PseudoArithmetic/FieldAudit.lean).

**Negative control (Lean evidence).** i²=-1 but i is not real; the radicand cannot be allowed to be negative. Evidence: [`PseudoArithmetic.FieldAudit.negative_radicand_counterexample`](../formal/PseudoArithmetic/FieldAudit.lean).

**Scope.** Reality is expressed by complex conjugation fixing the element.

### T12 — Real generators give a real field image

**English.** An embedding real on the base and all field generators is real on the generated field.

**Status.** Mathematical content checked in Lean. Source lines: 507.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.FieldAudit.embedding_real_of_generators`](../formal/PseudoArithmetic/FieldAudit.lean).

**Positive example (Lean evidence).** Both embeddings of ℚ(√5) are real on its generator. Evidence: [`PseudoArithmetic.SemanticAudit.baseField_embedding_real`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Negative control (Lean evidence).** Omitting the generator condition permits ℚ(i): its base is real, but i is not. Evidence: [`PseudoArithmetic.FieldAudit.negative_radicand_counterexample`](../formal/PseudoArithmetic/FieldAudit.lean).

**Scope.** The proof uses adjoin induction and the explicit hypothesis that the generators generate the whole field.

### T13 — Positive-radical extension is totally real

**English.** A number field generated over a totally real base by square roots of totally positive elements is totally real.

**Status.** Mathematical content checked in Lean. Source lines: 206, 493, 507, 1155.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.FieldAudit.totally_positive_radicals_totallyReal`](../formal/PseudoArithmetic/FieldAudit.lean).

**Positive example (Lean evidence).** The theorem applies to the single radicand 5 and includes an empty generator family for K=k. Evidence: [`PseudoArithmetic.SemanticAudit.baseField_totallyReal`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.FieldAudit.totally_positive_radicals_totallyReal`](../formal/PseudoArithmetic/FieldAudit.lean).

**Negative control (Lean evidence).** The constructed witness field has a real inclusion and a nonreal embedding, so a single real place cannot substitute for total positivity. Evidence: [`PseudoArithmetic.SemanticAudit.real_embedding_does_not_mean_totallyReal`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** The algebraic content of the manuscript's total-reality proof is now checked; its connection to pseudo-arithmetic geometry remains external.

### T14 — Pseudo-arithmetic total-reality obstruction

**English.** For n>3, pseudo-arithmeticity implies a totally real adjoint trace field.

**Status.** Implication checked using external predicates/hypotheses. Source lines: 61, 93, 206, 258, 501, 507, 893, 932, 1105, 1225, 1273, 1314.

**Translation.** Reviewed specialization of an external input. For every finite-volume lattice in the fixed dimension four, pseudo-arithmeticity implies total reality of its own adjoint trace field; the implication is not reversed. External inputs: E3.

**Lean mapping.** [`PseudoArithmetic.Manuscript.CoxeterExternalInputs.pseudoArithmetic_totallyReal`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.ExternalContracts.CensusInputs.pseudoArithmetic_totallyReal`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (Lean evidence).** The rational logical interface satisfies the implication and is pseudo-arithmetic in its supplied predicate. Evidence: [`PseudoArithmetic.InterfaceAudit.rationalLatticeInterface`](../formal/PseudoArithmetic/InterfaceAudit.lean).

**Negative control (Lean evidence).** The reversed implication totallyReal→pseudoArithmetic admits a non-totally-real field with pseudoArithmetic=True, so it cannot imply the obstruction. Evidence: [`PseudoArithmetic.ExternalContracts.reversed_total_reality_implication_is_insufficient`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Scope.** Both interface examples are logical models, not geometric lattices. E3 supplies the mathematical interpretation.

### T15 — Contrapositive obstruction

**English.** A non-totally-real adjoint trace field excludes pseudo-arithmeticity.

**Status.** Implication checked using external predicates/hypotheses. Source lines: 61, 517, 893, 919, 1225, 1314.

**Translation.** Reviewed specialization of an external input. The checked contrapositive applies E3 to the same group and the literal field identified by E2; the matrix theorem supplies the negative total-reality result. External inputs: E1, E2, E3.

**Lean mapping.** [`PseudoArithmetic.Manuscript.coxeter_case_main_theorem`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.ExternalContracts.census_main_theorem`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (Lean evidence).** Each of the three labeled logical interfaces plus the genuine certificate satisfies the conclusion. Evidence: [`PseudoArithmetic.InterfaceAudit.main_interface_positive`](../formal/PseudoArithmetic/InterfaceAudit.lean).

**Negative control (Lean evidence).** Non-total reality by itself says nothing about an unrelated predicate; the implication to total reality is necessary. Evidence: [`PseudoArithmetic.InterfaceAudit.total_reality_bridge_necessary`](../formal/PseudoArithmetic/InterfaceAudit.lean).

**Scope.** The contrapositive is checked; the field-to-lattice identification remains E2/E3.

### T16 — Vinberg identification

**English.** For a finite-volume Coxeter reflection lattice, the cyclic-product field equals its adjoint trace field.

**Status.** Mathematical statement remains external. Source lines: 61, 193, 258, 540, 548, 871, 932, 1094, 1105, 1217, 1273, 1314.

**Translation.** Reviewed specialization of an external input. The same group and its unit-normal matrix must satisfy reflectionGroupOf and finiteVolumeLattice; the conclusion is equality with the generated field of closed products in 2G. External inputs: E1, E2.

**Lean mapping.** [`PseudoArithmetic.Manuscript.CoxeterExternalInputs.trace_field`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.GramAudit.cycleField`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.ExternalContracts.CensusInputs.vinberg`](../formal/PseudoArithmetic/ExternalContracts.lean); [`PseudoArithmetic.ExternalContracts.traceField_eq_cycleField`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (Lean evidence).** All three concrete cyclic-product fields are number fields and fail total reality. Evidence: [`PseudoArithmetic.GramAudit.all_three_cycleFields_not_totallyReal`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** A cyclic field cannot be replaced by an unrelated totally real field; strict cycle/entry-field inclusion is also exhibited by the -√5 matrix. Evidence: [`PseudoArithmetic.ExternalContracts.unrelated_field_rejected`](../formal/PseudoArithmetic/ExternalContracts.lean); [`PseudoArithmetic.GramAudit.strictEntryExample_cycleField`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.strictEntryExample_entry_not_in_cycleField`](../formal/PseudoArithmetic/GramAudit.lean).

**Scope.** The matrix-derived field and strict-inclusion control are Lean objects. Vinberg supplies equality with the geometrically interpreted adjoint trace field; this imported equality is exposed with its hypotheses.

### T17 — Arithmetic and gluing motivation

**English.** Arithmetic and quasi-arithmetic lattices and the cited gluing constructions lie in the pseudo-arithmetic framework.

**Status.** Mathematical statement remains external. Source lines: 93.

**Translation.** Background generality not separately used by the Lean argument. The arithmetic/gluing statements motivate the imported definition; the main obstruction does not invoke them as extra premises. External inputs: background.

**Lean mapping.** No declaration of the full mathematical statement.

**Positive example (written mathematical/control example).** The trivial scalar extension includes quasi-arithmetic groups, including arithmetic examples.

**Negative control (written mathematical/control example).** The three main examples refute the stronger statement that all hyperbolic lattices in dimension four belong to that framework.

**Scope.** This introductory mathematical background is external to the formalization; it is not silently classified as nonmathematical history.

### C01 — Census classification

**English.** Ma–Zheng's census classifies 331 finite-volume hyperbolic Coxeter 4-polytopes with seven facets.

**Status.** Mathematical statement remains external. Source lines: 122, 258, 613, 865, 932, 978, 1206, 1314.

**Translation.** Background generality not separately used by the Lean argument. E1 imports the three selected cases. The full count 331 is reviewed external classification data and is not used as a premise of the Lean implication. External inputs: E1, background.

**Lean mapping.** [`PseudoArithmetic.ExternalContracts.CensusInputs.census_realization`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (written mathematical/control example).** The three selected rows occur in the pinned source with the stated labels.

**Negative control (written mathematical/control example).** A Gram array of size seven alone does not establish realization, finite volume, or completeness of a classification.

**Scope.** The source transcription was checked separately; the classification and its total count are not Lean theorems here.

### C02 — Pair ordering

**English.** The 21 entries list all unordered facet pairs in lexicographic order.

**Status.** Mathematical content checked in Lean. Source lines: 574.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.CensusAudit.pairOrder`](../formal/PseudoArithmetic/CensusAudit.lean); [`PseudoArithmetic.CensusAudit.pair_order_complete`](../formal/PseudoArithmetic/CensusAudit.lean).

**Positive example (Lean evidence).** The list is duplicate-free and contains (i,j) exactly when i<j. Evidence: [`PseudoArithmetic.CensusAudit.pair_order_complete`](../formal/PseudoArithmetic/CensusAudit.lean).

**Negative control (Lean evidence).** Index 2 is (0,3), not index 3; the reversed pair (1,0) is absent. Evidence: [`PseudoArithmetic.CensusAudit.pair_order_controls`](../formal/PseudoArithmetic/CensusAudit.lean).

**Scope.** This checks the entire encoding index set, not just its length.

### C03 — Census symbols

**English.** Integers encode angles, 0 encodes parallel facets, and a,b encode disjoint-facet distances.

**Status.** Mathematical content checked in Lean. Source lines: 574, 642.

**Translation.** Matched mathematical statement, checked in Lean. All 21 symbols are decoded and equated with the actual matrix entries for each of the three cases, including the code 0 giving -1. Geometric angles and distances are interpreted by E1. External inputs: E1.

**Lean mapping.** [`PseudoArithmetic.CensusAudit.encodedRow`](../formal/PseudoArithmetic/CensusAudit.lean); [`PseudoArithmetic.CensusAudit.decodeGramEntry`](../formal/PseudoArithmetic/CensusAudit.lean); [`PseudoArithmetic.CensusAudit.decoded_row_eq_gram`](../formal/PseudoArithmetic/CensusAudit.lean); [`PseudoArithmetic.CensusAudit.parallel_code_is_not_zero_entry`](../formal/PseudoArithmetic/CensusAudit.lean).

**Positive example (Lean evidence).** Every decoded row agrees entry by entry with the actual gram j for all three cases. Evidence: [`PseudoArithmetic.CensusAudit.decoded_row_eq_gram`](../formal/PseudoArithmetic/CensusAudit.lean).

**Negative control (Lean evidence).** The census symbol 0 decodes to -1, not to the Gram entry 0. Evidence: [`PseudoArithmetic.CensusAudit.parallel_code_is_not_zero_entry`](../formal/PseudoArithmetic/CensusAudit.lean).

**Scope.** The row-to-matrix equality is checked in Lean. The accuracy of the published rows and the geometric meaning of their symbols remain the reviewed source data E1.

### C04 — Three distinct census vectors

**English.** The rows share all entries except q₆=2,q₇=3,q₈=4 at pair (1,6).

**Status.** External data with arithmetic/encoding controls. Source lines: 122, 591, 594, 619, 1206.

**Translation.** Explicit computational assertion with checked data. The explicit data and arithmetic are checked by the named artifacts; an executed computation is not presented as a Lean theorem. External inputs: computation.

**Lean mapping.** [`PseudoArithmetic.CensusAudit.encodedRow`](../formal/PseudoArithmetic/CensusAudit.lean); [`PseudoArithmetic.Manuscript.CoxeterCase.edge16_values`](../formal/PseudoArithmetic/Manuscript.lean).

**Positive example (Lean evidence).** All three encoded rows and the three edge labels are explicit. Evidence: [`PseudoArithmetic.CensusAudit.row_controls`](../formal/PseudoArithmetic/CensusAudit.lean); [`PseudoArithmetic.Manuscript.CoxeterCase.edge16_values`](../formal/PseudoArithmetic/Manuscript.lean).

**Negative control (Lean evidence).** Equating the first two or last two rows contradicts the kernel-checked row distinctions. Evidence: [`PseudoArithmetic.CensusAudit.row_controls`](../formal/PseudoArithmetic/CensusAudit.lean).

**Scope.** The encoded numbers are checked; their identification with the published polytopes is external.

### C05 — Cusp counts

**English.** The published cusp counts for rows 6,7,8 are 1,1,2.

**Status.** External data with arithmetic/encoding controls. Source lines: 594, 908, 1206.

**Translation.** Explicit computational assertion with checked data. The explicit data and arithmetic are checked by the named artifacts; an executed computation is not presented as a Lean theorem. External inputs: computation.

**Lean mapping.** [`PseudoArithmetic.CensusAudit.cuspCount`](../formal/PseudoArithmetic/CensusAudit.lean).

**Positive example (Lean evidence).** Each recorded count is positive, and the third equals 2. Evidence: [`PseudoArithmetic.CensusAudit.all_cases_have_cusps`](../formal/PseudoArithmetic/CensusAudit.lean); [`PseudoArithmetic.CensusAudit.census_value_controls`](../formal/PseudoArithmetic/CensusAudit.lean).

**Negative control (Lean evidence).** The third count is not 1. Evidence: [`PseudoArithmetic.CensusAudit.census_value_controls`](../formal/PseudoArithmetic/CensusAudit.lean).

**Scope.** For row 8 the principal-subdiagram computation independently finds two ideal vertices; rows 6 and 7 still use census geometry.

### C06 — Volume coefficients

**English.** The volumes are 13π²/864, π²/54, and 19π²/864 respectively.

**Status.** External data with arithmetic/encoding controls. Source lines: 591, 594, 978, 1206.

**Translation.** Explicit computational assertion with checked data. The explicit data and arithmetic are checked by the named artifacts; an executed computation is not presented as a Lean theorem. External inputs: computation.

**Lean mapping.** [`PseudoArithmetic.CensusAudit.volumeCoefficient`](../formal/PseudoArithmetic/CensusAudit.lean).

**Positive example (Lean evidence).** The three rational coefficients are positive and match the encoded values. Evidence: [`PseudoArithmetic.CensusAudit.positive_volume_coefficients`](../formal/PseudoArithmetic/CensusAudit.lean); [`PseudoArithmetic.CensusAudit.census_value_controls`](../formal/PseudoArithmetic/CensusAudit.lean).

**Negative control (Lean evidence).** The coefficient 19/864 is not 1/54; swapping the final two volumes is detected. Evidence: [`PseudoArithmetic.CensusAudit.census_value_controls`](../formal/PseudoArithmetic/CensusAudit.lean).

**Scope.** These are records of external volume data. Lean checks their arithmetic, not the hyperbolic volume integral.

### C07 — Basic radicals and bounds

**English.** s=√5 and r=√2 are positive, with 1<s<3 and 1<r<2.

**Status.** Mathematical content checked in Lean. Source lines: 619, 733, 939.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.Manuscript.radicalS`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.GramAudit.radicalR`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.radical_bounds`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The chosen real radicals satisfy all four strict bounds. Evidence: [`PseudoArithmetic.GramAudit.radical_bounds`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** The negative square roots obey the same square equations but violate the chosen positive-branch bounds; equality of squares alone permits 1 and -1. Evidence: [`PseudoArithmetic.RadicalAudit.positive_branch_is_necessary`](../formal/PseudoArithmetic/RadicalAudit.lean).

**Scope.** Real.sqrt fixes the intended branch; square equations alone do not.

### C08 — The common radical a

**English.** a=(1/2)√(7+s+2√(2+2s)) is defined on positive radicands and exceeds 1.

**Status.** Mathematical content checked in Lean. Source lines: 619, 1206.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.Manuscript.radicalA`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.GramAudit.radicands_positive`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.radicalA_gt_one`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The actual nested real square roots satisfy a>1. Evidence: [`PseudoArithmetic.GramAudit.radicalA_gt_one`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** The branch -a fails the required inequality. Evidence: [`PseudoArithmetic.GramAudit.radical_negative_branch_rejected`](../formal/PseudoArithmetic/GramAudit.lean).

**Scope.** The proof includes radicand positivity, rather than applying Real.sq_sqrt without its premise.

### C09 — The three b radicals

**English.** The three displayed formulas for b₆,b₇,b₈ use positive real branches and each exceeds 1.

**Status.** Mathematical content checked in Lean. Source lines: 619, 1206.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.radicalB`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.radicands_positive`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.radicalB_gt_one`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The theorem proves bⱼ>1 uniformly for all three constructors. Evidence: [`PseudoArithmetic.GramAudit.radicalB_gt_one`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (written mathematical/control example).** Negating a chosen b preserves a bare square identity but makes the disjoint-facet coefficient have the wrong sign.

**Scope.** The formulas are literal Lean definitions. The independent computation also verifies branch signs for all three, beyond their polynomial equations.

### C10 — Full Gram matrices

**English.** Each displayed 7×7 matrix is symmetric with the listed entries and unit diagonal.

**Status.** Mathematical content checked in Lean. Source lines: 258, 642, 1094, 1105, 1206.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.gram`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.gram_symmetric`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.gram_diagonal`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** Both symmetry and every diagonal entry are checked for all three cases. Evidence: [`PseudoArithmetic.GramAudit.gram_symmetric`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.gram_diagonal`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (executed exact computation).** Changing only one of a symmetric pair destroys symmetry; adding 1/1000 to g₆₆ changes rank in all three cases. Evidence: [manuscript_computation_audit.py](../scripts/manuscript_computation_audit.py); [manuscript_computation_audit.json](../results/manuscript_computation_audit.json).

**Scope.** Symmetry and literal entries are kernel checked; the three rank mutations are exact Python controls, and geometric realization is E1.

### C11 — Common doubled entry A₁₂

**English.** A₁₂=A₂₁=−(1+s)/2.

**Status.** Mathematical content checked in Lean. Source lines: 122, 231, 258, 680, 1273, 1314.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.four_entries`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The actual doubled matrices reduce to this value for all cases. Evidence: [`PseudoArithmetic.GramAudit.four_entries`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (executed exact computation).** Using the undoubled entry −(1+s)/4 changes the two-cycle by a factor of four. Evidence: [manuscript_computation_audit.py](../scripts/manuscript_computation_audit.py); [manuscript_computation_audit.json](../results/manuscript_computation_audit.json).

**Scope.** The independent barrage perturbs this symmetric entry in both directions and rejects the recovered certificate.

### C12 — Common doubled entry A₀₃

**English.** A₀₃=A₃₀=−1.

**Status.** Mathematical content checked in Lean. Source lines: 122, 231, 258, 680, 1273, 1314.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.four_entries`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The unit entry -1/2 doubles to -1. Evidence: [`PseudoArithmetic.GramAudit.four_entries`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** Using +1 reverses the sign of the three-cycle, selecting the wrong u branch. Evidence: [`PseudoArithmetic.SemanticAudit.middle_sign_mutation_rejected`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** Both coefficient and sign are checked in the concrete matrix; the targeted cycle mutations include this edge.

### C13 — Common doubled entry A₃₅

**English.** A₃₅=A₅₃=−r.

**Status.** Mathematical content checked in Lean. Source lines: 122, 231, 258, 680, 1273, 1314.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.four_entries`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The unit entry -√2/2 doubles to -√2. Evidence: [`PseudoArithmetic.GramAudit.four_entries`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (executed exact computation).** Omitting the doubling replaces -√2 by -√2/2 and halves the three-cycle. Evidence: [manuscript_computation_audit.py](../scripts/manuscript_computation_audit.py); [manuscript_computation_audit.json](../results/manuscript_computation_audit.json).

**Scope.** The targeted cycle mutations include this edge; the exact formula is kernel checked.

### C14 — Common doubled entry A₀₅

**English.** A₀₅=A₅₀=−2a.

**Status.** Mathematical content checked in Lean. Source lines: 122, 231, 258, 680, 1273, 1314.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.four_entries`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The actual branch a>1 yields the stated negative doubled entry. Evidence: [`PseudoArithmetic.GramAudit.four_entries`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.radicalA_gt_one`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** Replacing a by -a changes the cycle's recovered u to the other sign, which fails the manuscript's relation at the intended radicals. Evidence: [`PseudoArithmetic.SemanticAudit.middle_sign_mutation_rejected`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** The sign is tied to the chosen real embedding, not inferred from a square equation.

### C15 — Algebraic entries generate number fields

**English.** The entry field and its cyclic subfield are number fields for each displayed matrix.

**Status.** Mathematical content checked in Lean. Source lines: 871, 1094.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.entryField_numberField`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.cycleField_numberField`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** Lean constructs both fields as actual intermediate fields of ℝ. Evidence: [`PseudoArithmetic.GramAudit.entryField_numberField`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.cycleField_numberField`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (written mathematical/control example).** An arbitrary predicate named 'has trace field' does not itself supply any elements, finite-dimensionality, or cycle membership. Evidence: [`PseudoArithmetic.InterfaceAudit.total_reality_bridge_necessary`](../formal/PseudoArithmetic/InterfaceAudit.lean).

**Scope.** The negative control is a logical distinction, not a counterexample to the number-field theorem. The concrete construction closes the old missing algebraic link.

### C16 — Special-angle derivation

**English.** For z=exp(iπ/5), the equation z⁵=-1 and z≠-1 give x²-x-1=0 for x=z+z⁻¹, with positivity selecting x=(1+√5)/2.

**Status.** Mathematical content checked in Lean. Source lines: 642.

**Translation.** Matched mathematical statement, checked in Lean. The actual exponential z=exp(iπ/5), its fifth power, the excluded -1 value, the quotient-polynomial relation, and z+z⁻¹=(1+√5)/2 are checked. The cosine evaluation may reuse mathlib. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.special_angles`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.RadicalAudit.fifth_root_quotient`](../formal/PseudoArithmetic/RadicalAudit.lean); [`PseudoArithmetic.RadicalAudit.fifth_root_golden_relation`](../formal/PseudoArithmetic/RadicalAudit.lean); [`PseudoArithmetic.RadicalAudit.fifth_root_excluded_boundary`](../formal/PseudoArithmetic/RadicalAudit.lean); [`PseudoArithmetic.RadicalAudit.golden_root_positive`](../formal/PseudoArithmetic/RadicalAudit.lean); [`PseudoArithmetic.RadicalAudit.fifthRoot_power`](../formal/PseudoArithmetic/RadicalAudit.lean); [`PseudoArithmetic.RadicalAudit.fifthRoot_sum`](../formal/PseudoArithmetic/RadicalAudit.lean); [`PseudoArithmetic.RadicalAudit.fifthRoot_ne_neg_one`](../formal/PseudoArithmetic/RadicalAudit.lean); [`PseudoArithmetic.RadicalAudit.fifthRoot_golden_relation`](../formal/PseudoArithmetic/RadicalAudit.lean).

**Positive example (Lean evidence).** For z=exp(iπ/5), z⁵=-1, z≠-1, and z+z⁻¹=(1+√5)/2 satisfies the golden-ratio equation. Evidence: [`PseudoArithmetic.RadicalAudit.fifthRoot_power`](../formal/PseudoArithmetic/RadicalAudit.lean); [`PseudoArithmetic.RadicalAudit.fifthRoot_ne_neg_one`](../formal/PseudoArithmetic/RadicalAudit.lean); [`PseudoArithmetic.RadicalAudit.fifthRoot_sum`](../formal/PseudoArithmetic/RadicalAudit.lean); [`PseudoArithmetic.RadicalAudit.fifthRoot_golden_relation`](../formal/PseudoArithmetic/RadicalAudit.lean).

**Negative control (Lean evidence).** z=-1 also satisfies z⁵=-1 but not z⁴-z³+z²-z+1=0; cancelling z+1 without excluding this root is invalid. Evidence: [`PseudoArithmetic.RadicalAudit.fifth_root_excluded_boundary`](../formal/PseudoArithmetic/RadicalAudit.lean).

**Scope.** All stated identities are checked; reuse of mathlib for the special cosine is an acceptable proof choice. The exclusion z≠-1 is necessary for cancelling z+1.

### R01 — Closed cyclic products

**English.** A cyclic product follows a finite closed walk; repeated indices are permitted.

**Status.** Mathematical content checked in Lean. Source lines: 161, 528.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.cyclicProduct`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** A length-three repeated-index cycle in a one-entry matrix with value 2 equals 8. Evidence: [`PseudoArithmetic.GramAudit.repeated_indices_are_allowed`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** Restricting to distinct indices would omit this allowed product. Evidence: [`PseudoArithmetic.GramAudit.repeated_indices_are_allowed`](../formal/PseudoArithmetic/GramAudit.lean).

**Scope.** The list definition includes a closing edge and permits a one-edge diagonal cycle.

### R02 — Reversal of a cyclic product

**English.** Reversing a closed walk in a symmetric matrix preserves its product.

**Status.** Mathematical content checked in Lean. Source lines: 528.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.cyclicProduct_reverse`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The general theorem covers every finite list, including the displayed three-cycle. Evidence: [`PseudoArithmetic.GramAudit.three_cycle_reverse`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** Without symmetry a three-cycle may have forward product 2·3·5=30 and reverse product 7·11·13=1001. Evidence: [`PseudoArithmetic.GramAudit.symmetry_needed_for_reversal`](../formal/PseudoArithmetic/GramAudit.lean).

**Scope.** The negative nonsymmetric matrix and the symmetric general theorem are both kernel checked.

### R03 — Doubled normalization

**English.** Scaling every entry by a nonzero rational q multiplies a length-l cycle by q^l and preserves the generated field.

**Status.** Mathematical content checked in Lean. Source lines: 161, 548, 680.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.cyclicProduct_scale`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.generatedCycleField_scale`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** Taking q=2 gives the manuscript's equivalence of G and 2G cycle fields. Evidence: [`PseudoArithmetic.GramAudit.generatedCycleField_scale`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** It does not preserve individual cycle values: a two-cycle 1 becomes 4. Evidence: [`PseudoArithmetic.GramAudit.doubling_changes_cycle_values`](../formal/PseudoArithmetic/GramAudit.lean).

**Scope.** Nonzero rational scaling is explicit; q=0 would generally collapse the field.

### R04 — Reflection-coordinate rescaling

**English.** Changing basis vectors by nonzero factors changes reflection coefficients by scaleⱼ/scaleᵢ, so closed products telescope.

**Status.** Mathematical content checked in Lean. Source lines: 556.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.cyclicProduct_rescale`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** Every closed walk has exactly the same product after such a coefficient rescaling. Evidence: [`PseudoArithmetic.GramAudit.cyclicProduct_rescale`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** An open coefficient changes from 1 to 3/2; an open product need not be invariant. Evidence: [`PseudoArithmetic.GramAudit.open_product_not_rescaling_invariant`](../formal/PseudoArithmetic/GramAudit.lean).

**Scope.** This applies to reflection coefficients, not to raw inner products after unnormalized normal rescaling.

### R05 — Cycle field versus entry field

**English.** All cycles lie in the entry field, but in general these fields need not be equal.

**Status.** Mathematical content checked in Lean. Source lines: 161, 528, 556, 871, 995.

**Translation.** Matched mathematical statement, checked in Lean. The cyclic field is a subfield of the entry field; the strict example is a symmetric unit-diagonal matrix with off-diagonal -√5 and cyclic field exactly ℚ. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.cycleField_le_entryField`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.strictEntryExample_cycleField`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.strictEntryExample_entry_not_in_cycleField`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.generatedCycleField_rescale`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The inclusion is proved for each actual matrix; equality is separately proved for the third. Evidence: [`PseudoArithmetic.GramAudit.cycleField_le_entryField`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.third_cycleField_eq_entryField`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** For the symmetric unit-diagonal 2×2 matrix with off-diagonal -√5, every closed product is rational, but its off-diagonal entry is not in the cycle field. Evidence: [`PseudoArithmetic.GramAudit.strictEntryExample_cycleField`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.strictEntryExample_entry_not_in_cycleField`](../formal/PseudoArithmetic/GramAudit.lean).

**Scope.** The negative control is a Lean instance of the full generatedCycleField, for every finite closed walk, not only a few short cycles.

### R06 — The two-cycle value

**English.** c₁₂=A₁₂A₂₁=(3+s)/2.

**Status.** Mathematical content checked in Lean. Source lines: 61, 122, 231, 258, 680, 1094, 1273, 1314.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.cycle12_value`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The identity holds in each of the three concrete matrices. Evidence: [`PseudoArithmetic.GramAudit.cycle12_value`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (executed exact computation).** Omitting one factor of 2 in A changes the result; the exact mutation barrage perturbs edge (1,2) in both directions. Evidence: [manuscript_computation_audit.py](../scripts/manuscript_computation_audit.py); [manuscript_computation_audit.json](../results/manuscript_computation_audit.json).

**Scope.** The positive formula is kernel checked and the numerical perturbations are checked independently.

### R07 — Recovering s inside the field

**English.** s=2c₁₂−3 belongs to the cycle field.

**Status.** Mathematical content checked in Lean. Source lines: 61, 231, 680, 871, 1062, 1314.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.Manuscript.recover_s_from_twoCycle`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.GramAudit.radicalS_mem_cycleField`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The actual √5 is recovered in each generated cycle field. Evidence: [`PseudoArithmetic.GramAudit.radicalS_mem_cycleField`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** Using 2c₁₂+3 is wrong; the rational recovery control detects the wrong constant. Evidence: [`PseudoArithmetic.GramAudit.cycle_recovery_controls`](../formal/PseudoArithmetic/GramAudit.lean).

**Scope.** Membership follows from field closure and a genuine cycle, not from arbitrary membership in ℝ.

### R08 — The three-cycle value

**English.** c₀₃₅=A₀₃A₃₅A₅₀=−2u, where u=ra.

**Status.** Mathematical content checked in Lean. Source lines: 61, 122, 231, 258, 680, 1094, 1273, 1314.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.cycle035_value`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The product of the actual three negative entries is -2√2a in all cases. Evidence: [`PseudoArithmetic.GramAudit.cycle035_value`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (executed exact computation).** Changing the sign of one entry changes the product's sign; omitting doubling changes its magnitude. Evidence: [manuscript_computation_audit.py](../scripts/manuscript_computation_audit.py); [manuscript_computation_audit.json](../results/manuscript_computation_audit.json).

**Scope.** The exact mutation barrage checks the three edges separately with positive and negative perturbations.

### R09 — Recovering u inside the field

**English.** u=−c₀₃₅/2 belongs to the same cycle field as s.

**Status.** Mathematical content checked in Lean. Source lines: 61, 231, 680, 871, 1062, 1314.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.Manuscript.recover_u_from_threeCycle`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.GramAudit.radicalU_mem_cycleField`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The positive radical u is a field element in each concrete construction. Evidence: [`PseudoArithmetic.GramAudit.radicalU_mem_cycleField`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** Using an unrelated real root outside ℚ(√5) does not make that totally real field non-totally-real. Evidence: [`PseudoArithmetic.SemanticAudit.field_membership_necessary`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** The English and Lean statements require both elements in one field.

### R10 — The squared u identity

**English.** u²=(7+s)/2+t, with t=√(2+2s)>0.

**Status.** Mathematical content checked in Lean. Source lines: 733.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.RadicalAudit.radicalU_square`](../formal/PseudoArithmetic/RadicalAudit.lean); [`PseudoArithmetic.RadicalAudit.radicalT_positive`](../formal/PseudoArithmetic/RadicalAudit.lean).

**Positive example (Lean evidence).** The identity is proved from the actual positive nested radicals. Evidence: [`PseudoArithmetic.RadicalAudit.radicalU_square`](../formal/PseudoArithmetic/RadicalAudit.lean).

**Negative control (Lean evidence).** Changing u to -u preserves this equation; it therefore cannot select the intended branch by itself. Evidence: [`PseudoArithmetic.RadicalAudit.positive_branch_is_necessary`](../formal/PseudoArithmetic/RadicalAudit.lean).

**Scope.** A negative example here refutes branch uniqueness, not the squared identity.

### R11 — The linear radical identity

**English.** (s−1)u=3−s+t for the chosen positive radicals.

**Status.** Mathematical content checked in Lean. Source lines: 733, 791.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.RadicalAudit.radical_linear_identity`](../formal/PseudoArithmetic/RadicalAudit.lean).

**Positive example (Lean evidence).** Both sides are positive and have equal squares for s=√5. Evidence: [`PseudoArithmetic.RadicalAudit.radical_linear_identity`](../formal/PseudoArithmetic/RadicalAudit.lean); [`PseudoArithmetic.RadicalAudit.radicalU_positive`](../formal/PseudoArithmetic/RadicalAudit.lean).

**Negative control (Lean evidence).** Equal squares alone permit 1 and -1, so positivity cannot be dropped from the inference to equality. Evidence: [`PseudoArithmetic.RadicalAudit.positive_branch_is_necessary`](../formal/PseudoArithmetic/RadicalAudit.lean).

**Scope.** This connects the English positive-branch step to the formal proof.

### R12 — Elimination and cancellation

**English.** Substituting t=(s−1)u+s−3 and cancelling s−1 produces F(s,u)=0.

**Status.** Mathematical content checked in Lean. Source lines: 775, 791, 1062.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.RadicalAudit.radicalT_linear`](../formal/PseudoArithmetic/RadicalAudit.lean); [`PseudoArithmetic.RadicalAudit.elimination_factorization`](../formal/PseudoArithmetic/RadicalAudit.lean); [`PseudoArithmetic.Manuscript.cycle_relation_of_radical_identities`](../formal/PseudoArithmetic/Manuscript.lean).

**Positive example (Lean evidence).** The actual s>1 makes the cancelled factor nonzero. Evidence: [`PseudoArithmetic.GramAudit.radical_bounds`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.Manuscript.explicit_radical_cycle_relation`](../formal/PseudoArithmetic/Manuscript.lean).

**Negative control (Lean evidence).** At s=1,t=-2,u=0 the substituted square identity holds but F=-6, so cancellation without s≠1 is invalid. Evidence: [`PseudoArithmetic.RadicalAudit.cancellation_hypothesis_necessary`](../formal/PseudoArithmetic/RadicalAudit.lean).

**Scope.** The ring factorization itself is universal; its cancellation has a nonzero premise.

### R13 — The radical relation

**English.** F(s,u)=(s−1)u²+2(s−3)u+s−7 vanishes for the stated radicals.

**Status.** Mathematical content checked in Lean. Source lines: 61, 79, 231, 258, 723, 775, 791, 888, 1062, 1273, 1314.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.Manuscript.explicit_radical_cycle_relation`](../formal/PseudoArithmetic/Manuscript.lean).

**Positive example (Lean evidence).** The actual witness field satisfies the relation and s²=5. Evidence: [`PseudoArithmetic.SemanticAudit.witness_relation`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.SemanticAudit.witness_square`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Negative control (Lean evidence).** The relation with the middle sign reversed fails at these same radicals. Evidence: [`PseudoArithmetic.SemanticAudit.middle_sign_mutation_rejected`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** A theorem for the sign-mutated polynomial can still be proved after u↦-u; that does not validate the transcription.

### R14 — Discriminant formula

**English.** The discriminant of F(s,·) is 8(1+s).

**Status.** Mathematical content checked in Lean. Source lines: 61, 231, 258, 813.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.SemanticAudit.discriminant_identity`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Positive example (Lean evidence).** At s=√5 it is positive; at the conjugate s=-√5 it is negative. Evidence: [`PseudoArithmetic.SemanticAudit.discriminant_identity`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.conjugateQuadratic_no_real_root`](../formal/PseudoArithmetic/NonTotalReality.lean).

**Negative control (Lean evidence).** At s=-1 it is zero and u=-2 is a real double root; a non-strict negative test would be wrong. Evidence: [`PseudoArithmetic.SemanticAudit.double_root_boundary`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** The identity holds for every real s, independently of s²=5.

### R15 — Nonzero conjugate leading coefficient

**English.** For s²=5 with s<0, the leading coefficient s−1 is nonzero.

**Status.** Mathematical content checked in Lean. Source lines: 231, 813.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.conjugateQuadratic_no_real_root`](../formal/PseudoArithmetic/NonTotalReality.lean).

**Positive example (Lean evidence).** The embedding s↦-√5 gives s−1<0. Evidence: [`PseudoArithmetic.FieldAudit.base_embedding_negative_exists`](../formal/PseudoArithmetic/FieldAudit.lean).

**Negative control (Lean evidence).** At s=1 the equation becomes linear and still has the root -3/2. Evidence: [`PseudoArithmetic.SemanticAudit.linear_boundary`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** The formal no-root theorem proves the needed inequality internally.

### R16 — Negative conjugate has no real root

**English.** If s²=5 and s<0, there is no real u with F(s,u)=0.

**Status.** Mathematical content checked in Lean. Source lines: 61, 231, 813, 1062, 1273.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.conjugateQuadratic_no_real_root`](../formal/PseudoArithmetic/NonTotalReality.lean).

**Positive example (Lean evidence).** The conjugate s=-√5 is excluded for every real u. Evidence: [`PseudoArithmetic.conjugateQuadratic_no_real_root`](../formal/PseudoArithmetic/NonTotalReality.lean).

**Negative control (Lean evidence).** Negative sign alone is insufficient: s=-1,u=-2 is a root but s²≠5. Evidence: [`PseudoArithmetic.SemanticAudit.negative_sign_alone_insufficient`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** The universal no-root conclusion is stronger than checking a list of trial roots.

### R17 — Real-root boundary and barrage

**English.** For arbitrary real s, F(s,·) has a real root exactly when s≥-1.

**Status.** Mathematical content checked in Lean. Source lines: 813, 1155.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.SemanticAudit.real_root_iff`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Positive example (Lean evidence).** s=-1 has root -2, and s=1 has root -3/2; rational roots form an infinite parametrized family. Evidence: [`PseudoArithmetic.SemanticAudit.double_root_boundary`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.SemanticAudit.linear_boundary`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.SemanticAudit.rational_root_family`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Negative control (Lean evidence).** Every s=-2-n has no root; every nonzero rational perturbation of the parametrized s breaks the chosen root. Evidence: [`PseudoArithmetic.SemanticAudit.negative_parameter_family`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.SemanticAudit.rational_perturbation_family`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** The generic strengthening audits the manuscript's special case; a separate rational script checks 28,310 instances.

### R18 — The small witness field

**English.** L=ℚ(s,u) for the actual radicals is a number field that is not totally real.

**Status.** Mathematical content checked in Lean. Source lines: 847, 888.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.SemanticAudit.witnessField`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.SemanticAudit.concrete_positive_example`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Positive example (Lean evidence).** Both generator equations and the non-total-reality conclusion hold for the constructed L. Evidence: [`PseudoArithmetic.SemanticAudit.concrete_positive_example`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Negative control (Lean evidence).** Dropping the square equation admits K=ℚ,s=7,u=0, where the relation holds and K is totally real. Evidence: [`PseudoArithmetic.SemanticAudit.square_hypothesis_necessary`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** This is a constructed positive mathematical object, not an abstract inconsistent premise set.

### R19 — Necessity of the relation

**English.** The square equation alone does not imply non-total reality; the u relation is also needed.

**Status.** Mathematical content checked in Lean. Source lines: 847.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.not_totallyReal_of_cycle_square`](../formal/PseudoArithmetic/NonTotalReality.lean).

**Positive example (Lean evidence).** The actual L satisfies both equations and fails total reality. Evidence: [`PseudoArithmetic.SemanticAudit.concrete_positive_example`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Negative control (Lean evidence).** K=ℚ(√5) with u=0 satisfies s²=5 and remains totally real, while the relation fails. Evidence: [`PseudoArithmetic.SemanticAudit.relation_hypothesis_necessary`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** This tests a deletion of a genuine premise.

### R20 — Bad embedding of the ambient field

**English.** The minimal polynomial realizes s↦-√5 in an embedding of K, forcing a nonreal image for u.

**Status.** Mathematical content checked in Lean. Source lines: 61, 79, 231, 258, 839, 847, 888, 1062, 1175, 1232, 1314, 1343.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.not_totallyReal_of_cycle_minpoly`](../formal/PseudoArithmetic/NonTotalReality.lean); [`PseudoArithmetic.cycleEmbedding_not_real`](../formal/PseudoArithmetic/NonTotalReality.lean).

**Positive example (Lean evidence).** The witness field has a complex embedding which is not real. Evidence: [`PseudoArithmetic.SemanticAudit.witness_has_nonreal_embedding`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Negative control (Lean evidence).** Assuming every embedding sends s to +√5 omits the negative embedding of the base. Evidence: [`PseudoArithmetic.FieldAudit.sqrt_five_exactly_two_embeddings`](../formal/PseudoArithmetic/FieldAudit.lean).

**Scope.** The bad embedding is derived, not assumed as part of the certificate.

### R21 — Nonreal roots and their field membership

**English.** If s,u∈K satisfy the equations, the conjugate polynomial has a nonreal root in the image of K.

**Status.** Mathematical content checked in Lean. Source lines: 231, 839, 847, 1314.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.cycleEmbedding_not_real`](../formal/PseudoArithmetic/NonTotalReality.lean).

**Positive example (Lean evidence).** The image of the actual u under the negative-s embedding supplies that root. Evidence: [`PseudoArithmetic.SemanticAudit.witness_has_nonreal_embedding`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Negative control (Lean evidence).** Choosing a root in ℂ without showing that it is the image of an element of K would not prove anything about embeddings of K. Evidence: [`PseudoArithmetic.SemanticAudit.field_membership_necessary`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** The counterexample to the weakened field-membership statement is kernel checked.

### R22 — Concrete cycle-field conclusions for all cases

**English.** The cyclic-product field of each displayed matrix is a number field and is not totally real.

**Status.** Mathematical content checked in Lean. Source lines: 61, 106, 231, 871, 888, 1094, 1105, 1217, 1314.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.all_three_cycleFields_not_totallyReal`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** One theorem quantifies over p11_6,p11_7,p11_8, each with its actual matrix-defined field. Evidence: [`PseudoArithmetic.GramAudit.all_three_cycleFields_not_totallyReal`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** The totally real field ℚ(√5) cannot substitute for any of these cycle fields while retaining both recovered elements and equations. Evidence: [`PseudoArithmetic.SemanticAudit.baseField_totallyReal`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.SemanticAudit.field_membership_necessary`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** This is the unconditional algebraic theorem. It does not identify the field with a geometric adjoint trace field.

### R23 — Certificate constructor

**English.** Two actual cycle values under a real embedding determine the internal certificate equations.

**Status.** Mathematical content checked in Lean. Source lines: 847, 1062.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.Manuscript.TwoCycleCertificate.of_real_cycles`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.Manuscript.not_totallyReal_of_real_cycles`](../formal/PseudoArithmetic/Manuscript.lean).

**Positive example (Lean evidence).** The constructed witness field and all three concrete cycle fields instantiate the constructor. Evidence: [`PseudoArithmetic.SemanticAudit.concrete_cycle_constructor`](../formal/PseudoArithmetic/SemanticAudit.lean); [`PseudoArithmetic.GramAudit.all_three_cycleFields_not_totallyReal`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** No TwoCycleCertificate can exist over ℚ, which is totally real. Evidence: [`PseudoArithmetic.InterfaceAudit.main_certificate_necessary`](../formal/PseudoArithmetic/InterfaceAudit.lean).

**Scope.** Injectivity transports the equations back into the field; a bare numerical coincidence in an unrelated field would not suffice.

### R24 — Arbitrary complex solution field

**English.** For any complex s,u satisfying s²=5 and F(s,u)=0, ℚ(s,u) is a number field and is not totally real.

**Status.** Mathematical content checked in Lean. Source lines: 807, 839.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.FieldAudit.complex_pair_numberField`](../formal/PseudoArithmetic/FieldAudit.lean); [`PseudoArithmetic.FieldAudit.arbitrary_complex_pair_not_totallyReal`](../formal/PseudoArithmetic/FieldAudit.lean).

**Positive example (Lean evidence).** The actual real radicals, included in ℂ, are one instance; the theorem also covers either complex root. Evidence: [`PseudoArithmetic.FieldAudit.arbitrary_complex_pair_not_totallyReal`](../formal/PseudoArithmetic/FieldAudit.lean).

**Negative control (Lean evidence).** Without the relation, ℚ(√5) is totally real even though its generator satisfies s²=5. Evidence: [`PseudoArithmetic.SemanticAudit.relation_hypothesis_necessary`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** Eliminating s gives a monic quartic for u. This closes the generality gap between the manuscript’s arbitrary-complex-root lemma and the original concrete real witness.

### R25 — Raw Gram entries versus reflection coefficients

**English.** Raw Gram entries scale by the product of normal scalars; normalized reflection coefficients scale by their ratio.

**Status.** Mathematical content checked in Lean. Source lines: 556.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GeometryAudit.reflectionCoefficient_rescale`](../formal/PseudoArithmetic/GeometryAudit.lean); [`PseudoArithmetic.GeometryAudit.raw_gram_rescaling_control`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Positive example (Lean evidence).** The formula aᵢⱼ=2⟨eᵢ,eⱼ⟩/⟨eᵢ,eᵢ⟩ changes by λⱼ/λᵢ under nonzero normal scaling. Evidence: [`PseudoArithmetic.GeometryAudit.reflectionCoefficient_rescale`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Negative control (Lean evidence).** For a unit spatial normal scaled by 2 and 3, the raw inner product is 6, not 3/2. Evidence: [`PseudoArithmetic.GeometryAudit.raw_gram_rescaling_control`](../formal/PseudoArithmetic/GeometryAudit.lean).

**Scope.** The algebraic formulas are proved; their relation to a polytope’s chosen normal vectors remains geometric input.

### M01 — Main theorem

**English.** The three census reflection groups are finite-volume lattices with non-totally-real trace fields and are not pseudo-arithmetic.

**Status.** Implication checked using external predicates/hypotheses. Source lines: 61, 79, 93, 104, 106, 258, 865, 893, 932, 1105, 1155, 1314.

**Translation.** Reviewed specialization of an external input. The theorem quantifies over all three cases and ties each group to its actual matrix and generated cycle field. No caller-selected field or two-cycle certificate is needed. External inputs: E1, E2, E3.

**Lean mapping.** [`PseudoArithmetic.Manuscript.coxeter_case_main_theorem`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.ExternalContracts.census_main_theorem`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (Lean evidence).** For all three cases the contract model uses the actual gram j and cycleField j, and the checked theorem concludes non-pseudo-arithmeticity of the modeled group. This is a logical test model, not constructed geometry. Evidence: [`PseudoArithmetic.ExternalContracts.contract_positive`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Negative control (Lean evidence).** The row-7 matrix cannot be paired with the row-6 case, and the totally real field ℚ(√5) cannot replace any of the three cyclic fields. Evidence: [`PseudoArithmetic.ExternalContracts.wrong_case_matrix_rejected`](../formal/PseudoArithmetic/ExternalContracts.lean); [`PseudoArithmetic.ExternalContracts.unrelated_field_rejected`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Scope.** E1 supplies geometric realization/finite volume, E2 the equality of fields, and E3 the pseudo-arithmetic implication. The specialized theorem connects the actual matrix algebra to these contracts; the geometry is imported.

### M02 — Manifold existence corollary

**English.** There exists an orientable, noncompact, finite-volume hyperbolic 4-manifold that is not pseudo-arithmetic.

**Status.** Implication checked using external predicates/hypotheses. Source lines: 61, 79, 116, 258, 900, 908, 1130, 1155, 1252, 1314.

**Translation.** Reviewed specialization of an external input. A shared existential pair Λ,M carries finite index, quotient correspondence, geometry, the actual trace field, and both non-pseudo-arithmeticity conclusions. E7 makes Λ a lattice before E3 is used. External inputs: E1, E2, E3, E5, E6, E7.

**Lean mapping.** [`PseudoArithmetic.Manuscript.finiteIndex_manifold_corollary`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.ExternalContracts.census_manifold_corollary`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (Lean evidence).** Each case in the logical model supplies one shared subgroup/quotient pair carrying all conclusions, including the equality with its actual cyclic field. Evidence: [`PseudoArithmetic.ExternalContracts.cover_contract_positive`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Negative control (Lean evidence).** Separate existential witnesses for two cover properties need not give one object satisfying both; the two Bool witnesses true and false give a checked countermodel. Evidence: [`PseudoArithmetic.ExternalContracts.separate_witnesses_do_not_give_common_cover`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Scope.** E5–E7 supply the subgroup, finite-index field equality, and geometric quotient. All cover properties use the same witnesses. The positive model checks the contract logic, not geometric existence.

### M03 — Finite-index trace transfer in the corollary

**English.** The cover has the same non-totally-real trace field as the base.

**Status.** Implication checked using external predicates/hypotheses. Source lines: 919, 1130, 1246, 1314.

**Translation.** Reviewed specialization of an external input. Field equality transfers the already proved obstruction to the cover field and identifies it with the same case cycleField j. External inputs: E2, E6.

**Lean mapping.** [`PseudoArithmetic.Manuscript.ManifoldExternalInputs.traceField_finiteIndex_invariant`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.ExternalContracts.CoverInputs.traceField_invariant`](../formal/PseudoArithmetic/ExternalContracts.lean); [`PseudoArithmetic.ExternalContracts.census_manifold_corollary`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (Lean evidence).** The positive interface transports the same witness field through the finite-index premise. Evidence: [`PseudoArithmetic.InterfaceAudit.manifold_interface_positive`](../formal/PseudoArithmetic/InterfaceAudit.lean).

**Negative control (Lean evidence).** Setting base trace=True, finite index=True, cover trace=False shows that the transfer cannot be omitted. Evidence: [`PseudoArithmetic.InterfaceAudit.trace_transfer_necessary`](../formal/PseudoArithmetic/InterfaceAudit.lean).

**Scope.** This countermodel tests the missing implication and is not a counterexample to Vinberg invariance.

### M04 — Quotient/group pseudo-arithmeticity

**English.** Pseudo-arithmeticity of the manifold corresponds to that of its quotient group.

**Status.** Implication checked using external predicates/hypotheses. Source lines: 919, 1130, 1252, 1314.

**Translation.** Reviewed specialization of an external input. The equivalence is guarded by finite-volume lattice and quotient hypotheses for the same Λ,M, so manifold pseudo-arithmeticity transfers to the group used in E3. External inputs: E7.

**Lean mapping.** [`PseudoArithmetic.Manuscript.ManifoldExternalInputs.quotient_pseudoArithmetic`](../formal/PseudoArithmetic/Manuscript.lean); [`PseudoArithmetic.ExternalContracts.CoverInputs.quotient_pseudoArithmetic`](../formal/PseudoArithmetic/ExternalContracts.lean).

**Positive example (Lean evidence).** The positive interface supplies this equivalence and hence transfers the obstruction. Evidence: [`PseudoArithmetic.InterfaceAudit.manifold_interface_positive`](../formal/PseudoArithmetic/InterfaceAudit.lean).

**Negative control (Lean evidence).** Independent predicates False for the group and True for the manifold prevent that inference. Evidence: [`PseudoArithmetic.InterfaceAudit.quotient_group_bridge_necessary`](../formal/PseudoArithmetic/InterfaceAudit.lean).

**Scope.** The Lean model tests the logical correspondence; the geometric meaning is an external definition/construction.

### V01 — Gram rank

**English.** Each full 7×7 Gram matrix has rank 5.

**Status.** Exact computation; not a Lean proof. Source lines: 258, 939, 1206.

**Translation.** Explicit computational assertion with checked data. The explicit data and arithmetic are checked by the named artifacts; an executed computation is not presented as a Lean theorem. External inputs: computation.

**Lean mapping.** No declaration of the full mathematical statement.

**Positive example (executed exact computation).** Exact quotient-field elimination computes rank 5 separately for rows 6,7,8. Evidence: [manuscript_computation_audit.py](../scripts/manuscript_computation_audit.py); [manuscript_computation_audit.json](../results/manuscript_computation_audit.json).

**Negative control (executed exact computation).** Adding 1/1000 to entry g₆₆ changes the rank in each case; all three mutations are rejected. Evidence: [manuscript_computation_audit.py](../scripts/manuscript_computation_audit.py); [manuscript_computation_audit.json](../results/manuscript_computation_audit.json).

**Scope.** Checked by manuscript_computation_audit.py with rational arithmetic, not a Lean matrix-rank theorem.

### V02 — Gram inertia

**English.** Each matrix has four positive, one negative, and two zero eigenvalue directions.

**Status.** Exact computation; not a Lean proof. Source lines: 258, 939, 1206.

**Translation.** Explicit computational assertion with checked data. The explicit data and arithmetic are checked by the named artifacts; an executed computation is not presented as a Lean theorem. External inputs: computation.

**Lean mapping.** No declaration of the full mathematical statement.

**Positive example (executed exact computation).** Exact symmetric elimination returns (4,1,2) for each displayed matrix. Evidence: [manuscript_computation_audit.py](../scripts/manuscript_computation_audit.py); [manuscript_computation_audit.json](../results/manuscript_computation_audit.json).

**Negative control (executed exact computation).** The zero-diagonal matrix [[0,1],[1,0]] has inertia (1,1,0), not (0,0,2); a zero diagonal does not imply a null direction. Evidence: [manuscript_computation_audit.py](../scripts/manuscript_computation_audit.py); [manuscript_computation_audit.json](../results/manuscript_computation_audit.json).

**Scope.** The script handles 2×2 pivots and signs via rational interval isolation, without numerical eigenvalues.

### V03 — Leading principal minors

**English.** The common five leading minors are 1,1,(5-s)/8,3(5-s)/32,-(1+s)/32.

**Status.** Mathematical content checked in Lean. Source lines: 939, 1155.

**Translation.** Matched mathematical statement, checked in Lean. Each expression is the determinant of the corresponding leading principal submatrix of the actual gram j, for every case j. The five values and their signs are checked in Lean. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.RadicalAudit.leading_minor_signs`](../formal/PseudoArithmetic/RadicalAudit.lean); [`PseudoArithmetic.RadicalAudit.leadingGram`](../formal/PseudoArithmetic/RadicalAudit.lean); [`PseudoArithmetic.RadicalAudit.leading_minor_values`](../formal/PseudoArithmetic/RadicalAudit.lean).

**Positive example (Lean evidence).** The five determinant values hold for each actual matrix, and the first four are positive while the fifth is negative. Evidence: [`PseudoArithmetic.RadicalAudit.leading_minor_values`](../formal/PseudoArithmetic/RadicalAudit.lean); [`PseudoArithmetic.RadicalAudit.leading_minor_signs`](../formal/PseudoArithmetic/RadicalAudit.lean).

**Negative control (Lean evidence).** At the incorrect boundary s=5 the third and fourth expressions vanish, so the claimed signs fail. Evidence: [`PseudoArithmetic.RadicalAudit.leading_minor_sign_boundary`](../formal/PseudoArithmetic/RadicalAudit.lean).

**Scope.** The determinant identities and signs are Lean theorems. Full seven-by-seven rank and inertia still have separate exact computational evidence.

### V04 — Jacobi signature step

**English.** The nonzero leading minors with signs +,+,+,+,- give inertia (4,1) on the five-dimensional block.

**Status.** Exact computation; not a Lean proof. Source lines: 939.

**Translation.** Explicit computational assertion with checked data. The explicit data and arithmetic are checked by the named artifacts; an executed computation is not presented as a Lean theorem. External inputs: computation.

**Lean mapping.** No declaration of the full mathematical statement.

**Positive example (executed exact computation).** The successive signed pivots in exact elimination have four positive signs and one negative sign. Evidence: [manuscript_computation_audit.py](../scripts/manuscript_computation_audit.py); [manuscript_computation_audit.json](../results/manuscript_computation_audit.json).

**Negative control (executed exact computation).** If a leading minor is zero, naive division by the previous minor is invalid; the script's [[0,1],[1,0]] control requires a 2×2 pivot. Evidence: [manuscript_computation_audit.py](../scripts/manuscript_computation_audit.py); [manuscript_computation_audit.json](../results/manuscript_computation_audit.json).

**Scope.** The generic Jacobi theorem is external to project Lean; exact congruence elimination checks this instance.

### V05 — Rank witnesses and zero six-minors

**English.** The nonzero five-minor plus full elimination proves rank 5; all seven principal six-minors also vanish.

**Status.** Exact computation; not a Lean proof. Source lines: 939.

**Translation.** Explicit computational assertion with checked data. The explicit data and arithmetic are checked by the named artifacts; an executed computation is not presented as a Lean theorem. External inputs: computation.

**Lean mapping.** No declaration of the full mathematical statement.

**Positive example (executed exact computation).** The script checks the five-minor, full rank, and every principal six-minor independently. Evidence: [manuscript_computation_audit.py](../scripts/manuscript_computation_audit.py); [manuscript_computation_audit.json](../results/manuscript_computation_audit.json).

**Negative control (executed exact computation).** The symmetric 7×7 matrix -I+J/6 has rank 7, every principal six-minor zero, and a nonzero principal five-minor. These minor conditions alone therefore do not prove rank 5. Evidence: [manuscript_computation_audit.py](../scripts/manuscript_computation_audit.py); [manuscript_computation_audit.json](../results/manuscript_computation_audit.json).

**Scope.** The script verifies this same-size counterexample exactly. Full elimination is essential to the manuscript rank certificate.

### V06 — Principal-subdiagram enumeration

**English.** All 127 nonempty principal subsets of the actual P11,8 Gram matrix are classified: 54 positive definite, 12 positive semidefinite but not positive definite, and 61 with a negative direction; exactly ten subsets are maximal positive semidefinite.

**Status.** Mathematical content checked in Lean. Source lines: 961, 1155.

**Translation.** Matched mathematical statement, checked in Lean. The biconditionals quantify over actual principal matrices and all real vectors through mathlib PosDef/PosSemidef. The 127 nonempty subsets and both directions of the classification are proved; no CAS answers are assumed. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.SubdiagramClassify.classification_correct`](../formal/PseudoArithmetic/SubdiagramClassify.lean); [`PseudoArithmetic.SubdiagramClassify.classification_counts`](../formal/PseudoArithmetic/SubdiagramClassify.lean); [`PseudoArithmetic.SubdiagramClassify.negative_direction`](../formal/PseudoArithmetic/SubdiagramClassify.lean); [`PseudoArithmetic.SubdiagramClassify.maximal_nonnegative_iff`](../formal/PseudoArithmetic/SubdiagramControls.lean).

**Positive example (Lean evidence).** The actual subset {0,1,2,3} is positive definite; {2,6} is positive semidefinite but not positive definite. Exact congruence certificates and exhaustive finite coverage prove the classes for every subset. Evidence: [`PseudoArithmetic.SubdiagramClassify.explicit_classification_controls`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.SubdiagramClassify.principal_positive_iff`](../formal/PseudoArithmetic/SubdiagramClassify.lean); [`PseudoArithmetic.SubdiagramClassify.principal_nonnegative_iff`](../formal/PseudoArithmetic/SubdiagramClassify.lean); [subdiagram_face_semantic_audit.md](../notes/subdiagram_face_semantic_audit.md).

**Negative control (Lean evidence).** The subset {0,5} has a negative direction. Dropping nonemptiness admits the vacuously positive-definite empty matrix, absent from the 127-case list. A positive singleton is not maximal. Every proper subset of each minimal negative example is nonnegative, and every one of the 70 incidence-bit flips corrupts the maximal list. Evidence: [`PseudoArithmetic.SubdiagramClassify.empty_subset_negative`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.SubdiagramClassify.nonmaximal_positive_negative`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.SubdiagramClassify.negative_minima_are_minimal`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.SubdiagramClassify.incidence_flip_barrage`](../formal/PseudoArithmetic/SubdiagramControls.lean); [subdiagram_face_semantic_audit.md](../notes/subdiagram_face_semantic_audit.md).

**Scope.** All three real-matrix classes, their counts, and maximality are proved in Lean for the literal P11,8 matrix. This is not a claim to formalize every inertia triple for all three matrices. Geometric vertex interpretation uses the published realization.

### V07 — Ordinary vertices

**English.** Eight maximal vertex subdiagrams of P11,8 are positive definite of rank 4.

**Status.** Mathematical content checked in Lean. Source lines: 961, 1155.

**Translation.** Matched mathematical statement, checked in Lean. The eight sets are selected from the proved complete maximal positive-semidefinite list, and rank four is deduced from positivity and cardinality. External inputs: E1.

**Lean mapping.** [`PseudoArithmetic.SubdiagramClassify.ordinary_vertex_controls`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.SubdiagramClassify.ordinary_vertices_positive_rank_four`](../formal/PseudoArithmetic/SubdiagramControls.lean).

**Positive example (Lean evidence).** Exactly eight maximal nonnegative subsets are positive definite; each has cardinality and matrix rank four. Evidence: [`PseudoArithmetic.SubdiagramClassify.ordinary_vertex_controls`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.SubdiagramClassify.ordinary_vertices_positive_rank_four`](../formal/PseudoArithmetic/SubdiagramControls.lean); [subdiagram_face_semantic_audit.md](../notes/subdiagram_face_semantic_audit.md).

**Negative control (Lean evidence).** Positive definiteness alone does not imply maximality: {0} is positive definite but not a vertex incidence. Deleting any listed vertex breaks an edge endpoint count. Evidence: [`PseudoArithmetic.SubdiagramClassify.nonmaximal_positive_negative`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.SubdiagramClassify.vertex_deletion_endpoint_barrage`](../formal/PseudoArithmetic/SubdiagramControls.lean); [subdiagram_face_semantic_audit.md](../notes/subdiagram_face_semantic_audit.md).

**Scope.** The exact maximal-subdiagram count, positivity, and ranks are proved. Calling these ordinary geometric vertices uses the published realization.

### V08 — First ideal link

**English.** The subset {1,3,4,6} is a rank-3 positive-semidefinite link of type C̃₃.

**Status.** Some mathematical content checked; stated boundary remains. Source lines: 961, 1155.

**Translation.** Reviewed external interpretation of the vocabulary. The actual indexed Gram block, all its coefficients, and its rank are checked; the affine-type and ideal-link interpretation is the cited geometric input. No numerical premise remains. External inputs: E1.

**Lean mapping.** [`PseudoArithmetic.SubdiagramAudit.nonnegative1346`](../formal/PseudoArithmetic/SubdiagramAudit.lean); [`PseudoArithmetic.SubdiagramClassify.ideal1346_rank`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.SubdiagramClassify.ideal_nullity_controls`](../formal/PseudoArithmetic/SubdiagramControls.lean).

**Positive example (Lean evidence).** The actual four-by-four block is positive semidefinite of rank three and nullity one. Its 4,3,4 path has the stated affine type under the standard Coxeter interpretation. Evidence: [`PseudoArithmetic.SubdiagramAudit.nonnegative1346`](../formal/PseudoArithmetic/SubdiagramAudit.lean); [`PseudoArithmetic.SubdiagramClassify.ideal1346_rank`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.SubdiagramClassify.ideal_nullity_controls`](../formal/PseudoArithmetic/SubdiagramControls.lean); [subdiagram_face_semantic_audit.md](../notes/subdiagram_face_semantic_audit.md).

**Negative control (Lean evidence).** This block is not positive definite: the nonzero vector (sqrt(2),1,sqrt(2),1) has quadratic value zero. Evidence: [`PseudoArithmetic.SubdiagramClassify.singular1346_not_positive`](../formal/PseudoArithmetic/SubdiagramClassify.lean); [subdiagram_face_semantic_audit.md](../notes/subdiagram_face_semantic_audit.md).

**Scope.** Positive semidefiniteness, rank, and nullity are proved in Lean. Naming the affine Coxeter type and interpreting it as an ideal link remain external geometry.

### V09 — Second ideal link and nonsimplicity

**English.** The subset {2,3,4,5,6} has type Ã₁ disjoint union C̃₂, rank 3 and nullity 2; its link is a triangular prism.

**Status.** Some mathematical content checked; stated boundary remains. Source lines: 961, 1155.

**Translation.** Reviewed external interpretation of the vocabulary. The five-facet actual matrix and its rank-three, nullity-two assertion are literal Lean statements. Only the interpretation as the stated product of affine types and geometric link remains imported. External inputs: E1.

**Lean mapping.** [`PseudoArithmetic.SubdiagramAudit.nonnegative23456`](../formal/PseudoArithmetic/SubdiagramAudit.lean); [`PseudoArithmetic.SubdiagramClassify.ideal23456_rank`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.SubdiagramClassify.ideal_nullity_controls`](../formal/PseudoArithmetic/SubdiagramControls.lean).

**Positive example (Lean evidence).** The actual five-by-five block is positive semidefinite of rank three and nullity two; the complete incidence is closed and occurs in the face poset. Evidence: [`PseudoArithmetic.SubdiagramAudit.nonnegative23456`](../formal/PseudoArithmetic/SubdiagramAudit.lean); [`PseudoArithmetic.SubdiagramClassify.ideal23456_rank`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.FaceAudit.nonsimple_closure_controls`](../formal/PseudoArithmetic/FaceControls.lean); [subdiagram_face_semantic_audit.md](../notes/subdiagram_face_semantic_audit.md).

**Negative control (Lean evidence).** The nullity is two, not one. The four-facet subset {2,3,4,6} closes to the same five-facet vertex, so counting both as distinct faces would be wrong. Evidence: [`PseudoArithmetic.SubdiagramClassify.ideal_nullity_controls`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.FaceAudit.nonsimple_closure_controls`](../formal/PseudoArithmetic/FaceControls.lean); [subdiagram_face_semantic_audit.md](../notes/subdiagram_face_semantic_audit.md).

**Scope.** The matrix ranks, nullities, and incidence closure are proved in Lean. The affine component names and Euclidean triangular-prism link retain their external geometric interpretation.

### V10 — Two endpoints per elliptic edge

**English.** Each of the 21 elliptic rank-3 edge diagrams has exactly two ordinary or ideal endpoints.

**Status.** Mathematical content checked in Lean. Source lines: 961, 1155.

**Translation.** Matched mathematical statement, checked in Lean. PositiveTest is proved equivalent to actual positive definiteness; cardinality three gives rank three. The endpoint count is proved for every such subset of the seven facets. External inputs: E1.

**Lean mapping.** [`PseudoArithmetic.SubdiagramClassify.elliptic_edge_endpoints`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.SubdiagramClassify.elliptic_edges_card`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.SubdiagramClassify.edge_endpoint_barrage`](../formal/PseudoArithmetic/SubdiagramControls.lean).

**Positive example (Lean evidence).** Every positive-definite three-facet set has exactly two members of the complete ten-vertex list containing it; the face count proves 21 edges. Evidence: [`PseudoArithmetic.SubdiagramClassify.elliptic_edges_card`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.SubdiagramClassify.elliptic_edge_endpoints`](../formal/PseudoArithmetic/SubdiagramControls.lean); [subdiagram_face_semantic_audit.md](../notes/subdiagram_face_semantic_audit.md).

**Negative control (Lean evidence).** Each of the ten single-vertex deletions breaks the endpoint count for at least one positive-definite three-facet set. Evidence: [`PseudoArithmetic.SubdiagramClassify.vertex_deletion_endpoint_barrage`](../formal/PseudoArithmetic/SubdiagramControls.lean); [subdiagram_face_semantic_audit.md](../notes/subdiagram_face_semantic_audit.md).

**Scope.** The complete matrix classification and all incidence counts are Lean theorems. The identification with geometric edges/endpoints and the finite-volume criterion remain external.

### V11 — Vinberg finite-volume criterion

**English.** The stated complete vertex-link and edge checks imply finite volume and two cusps for P11,8.

**Status.** Mathematical statement remains external. Source lines: 79, 258, 613, 961, 1206.

**Translation.** Reviewed external interpretation of the vocabulary. The supplement applies the criterion to the realized P₁₁,₈ with a complete vertex/edge enumeration; rank and inertia alone are not substituted for its hypotheses. This independent geometric criterion is not needed as a second assumption after E1. External inputs: E1.

**Lean mapping.** No declaration of the full mathematical statement.

**Positive example (Lean evidence).** The complete maximal-subdiagram classification, the eight rank-four ordinary vertices, the two rank-three ideal blocks, and every elliptic edge endpoint check are proved for this matrix. Evidence: [`PseudoArithmetic.SubdiagramClassify.maximal_nonnegative_iff`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.SubdiagramClassify.ordinary_vertices_positive_rank_four`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.SubdiagramClassify.ideal1346_rank`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.SubdiagramClassify.ideal23456_rank`](../formal/PseudoArithmetic/SubdiagramControls.lean); [`PseudoArithmetic.SubdiagramClassify.edge_endpoint_barrage`](../formal/PseudoArithmetic/SubdiagramControls.lean); [subdiagram_face_semantic_audit.md](../notes/subdiagram_face_semantic_audit.md).

**Negative control (Lean evidence).** Deleting any one of the ten vertex incidences breaks the endpoint count for some elliptic edge, demonstrating why local link checks need completeness. Evidence: [`PseudoArithmetic.SubdiagramClassify.vertex_deletion_endpoint_barrage`](../formal/PseudoArithmetic/SubdiagramControls.lean); [subdiagram_face_semantic_audit.md](../notes/subdiagram_face_semantic_audit.md).

**Scope.** The algebraic and combinatorial hypotheses are checked in Lean; the geometric sufficiency theorem and realization remain external.

### V12 — Complete face vector

**English.** The complete nonempty face incidence poset for P11,8, including the polytope, has face vector (10,21,18,7,1), also reported independently by CoxIter.

**Status.** Mathematical content checked in Lean. Source lines: 978, 1155.

**Translation.** Matched mathematical statement, checked in Lean. The conclusion states each of the five counts, not just Euler consistency. The quantified face transfer requires a complete bijection and dimension preservation; the constructed poset supplies a satisfying instance. External inputs: E1.

**Lean mapping.** [`PseudoArithmetic.FaceAudit.face_vector`](../formal/PseudoArithmetic/FaceAudit.lean); [`PseudoArithmetic.FaceAudit.vertices_are_maximal_nonnegative`](../formal/PseudoArithmetic/DiagramFaceAudit.lean); [`PseudoArithmetic.FaceAudit.dimension_is_stable`](../formal/PseudoArithmetic/FaceControls.lean); [`PseudoArithmetic.FaceAudit.face_count_transfer`](../formal/PseudoArithmetic/DiagramFaceAudit.lean); [`PseudoArithmetic.FaceAudit.geometric_face_vector`](../formal/PseudoArithmetic/DiagramFaceAudit.lean).

**Positive example (Lean evidence).** The full vector is derived by closing the complete Gram-derived vertex incidences and counting strict-chain dimensions; the face correspondence transfers every count. Evidence: [`PseudoArithmetic.FaceAudit.face_vector`](../formal/PseudoArithmetic/FaceAudit.lean); [`PseudoArithmetic.FaceAudit.face_correspondence_positive`](../formal/PseudoArithmetic/DiagramFaceAudit.lean); [`PseudoArithmetic.FaceAudit.nonsimple_closure_controls`](../formal/PseudoArithmetic/FaceControls.lean); [`PseudoArithmetic.FaceAudit.empty_face_controls`](../formal/PseudoArithmetic/FaceControls.lean); [subdiagram_face_semantic_audit.md](../notes/subdiagram_face_semantic_audit.md).

**Negative control (Lean evidence).** Deleting any vertex gives nine vertices; redundant incidences can list two sets but only one vertex; omitting dimension preservation can label all 57 faces as vertices. For every t>0, the wrong vector (10,21+t,18+t,7,1) still has Euler sum one. Evidence: [`PseudoArithmetic.FaceAudit.every_vertex_deletion_changes_count`](../formal/PseudoArithmetic/FaceControls.lean); [`PseudoArithmetic.FaceAudit.redundant_vertex_negative`](../formal/PseudoArithmetic/FaceControls.lean); [`PseudoArithmetic.FaceAudit.wrong_dimension_negative`](../formal/PseudoArithmetic/DiagramFaceAudit.lean); [`PseudoArithmetic.FaceAudit.euler_false_positive_family`](../formal/PseudoArithmetic/FaceControls.lean); [subdiagram_face_semantic_audit.md](../notes/subdiagram_face_semantic_audit.md).

**Scope.** Lean proves all five counts from the complete Gram-derived incidence poset and proves stabilization of chain height. The bijection with geometric faces and preservation of dimension are explicit external interpretation inputs; neither includes numerical counts. The historical CoxIter execution is separate provenance.

### V13 — Independent CoxIter volume

**English.** CoxIter reports volume 19π²/864 for P11,8, agreeing with the census.

**Status.** External data with arithmetic/encoding controls. Source lines: 978.

**Translation.** Explicit computational assertion with checked data. The explicit data and arithmetic are checked by the named artifacts; an executed computation is not presented as a Lean theorem. External inputs: computation.

**Lean mapping.** [`PseudoArithmetic.CensusAudit.census_value_controls`](../formal/PseudoArithmetic/CensusAudit.lean).

**Positive example (Lean evidence).** The recorded rational coefficient agrees with the row-8 value. Evidence: [`PseudoArithmetic.CensusAudit.census_value_controls`](../formal/PseudoArithmetic/CensusAudit.lean).

**Negative control (Lean evidence).** Substituting the row-7 coefficient 1/54 is rejected. Evidence: [`PseudoArithmetic.CensusAudit.census_value_controls`](../formal/PseudoArithmetic/CensusAudit.lean).

**Scope.** The release checks pinned outputs; it does not rerun CoxIter or kernel-verify its volume algorithm.

### V14 — Extra cycle recovering r

**English.** For row 8, c₁₂₆=-r(1+s), so r lies in the cyclic field.

**Status.** Mathematical content checked in Lean. Source lines: 995.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.cycle126_value`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.third_case_generators_mem`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The actual cycle identity and field membership are proved. Evidence: [`PseudoArithmetic.GramAudit.cycle126_value`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.third_case_generators_mem`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** Dividing by 1+s requires it nonzero; s=-1 would invalidate the recovery formula. Evidence: [`PseudoArithmetic.SemanticAudit.double_root_boundary`](../formal/PseudoArithmetic/SemanticAudit.lean).

**Scope.** The actual s>1 supplies nonvanishing; the boundary example tests the denominator, not the actual radical.

### V15 — Extra cycle recovering b₈

**English.** For row 8, c₀₃₄₁₆=-4b₈, so b₈ lies in the cyclic field.

**Status.** Mathematical content checked in Lean. Source lines: 995.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.cycle03416_value`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.third_case_generators_mem`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The five-edge product has the stated value in the actual doubled matrix. Evidence: [`PseudoArithmetic.GramAudit.cycle03416_value`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (Lean evidence).** Computing it in G instead of 2G scales it by 2⁻⁵, so the coefficient -4 would be wrong. Evidence: [`PseudoArithmetic.GramAudit.cyclicProduct_scale`](../formal/PseudoArithmetic/GramAudit.lean).

**Scope.** This control isolates normalization from the existence of the geometric polytope.

### V16 — Full field generated by four radicals

**English.** The row-8 cyclic field equals ℚ(s,r,a,b₈), and also equals its entry field.

**Status.** Mathematical content checked in Lean. Source lines: 995, 1094.

**Translation.** Matched mathematical statement, checked in Lean. The equality literally uses the rational adjoin of {s,r,a,b₈}, as well as equality with the entry field; both inclusions are proved. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.GramAudit.third_cycleField_eq_entryField`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.third_case_generators_mem`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.fourGeneratorField`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.third_cycleField_eq_fourGeneratorField`](../formal/PseudoArithmetic/GramAudit.lean).

**Positive example (Lean evidence).** The row-8 cyclic field equals the literal field ℚ(s,r,a,b₈) and its entry field. Evidence: [`PseudoArithmetic.GramAudit.third_cycleField_eq_fourGeneratorField`](../formal/PseudoArithmetic/GramAudit.lean); [`PseudoArithmetic.GramAudit.third_cycleField_eq_entryField`](../formal/PseudoArithmetic/GramAudit.lean).

**Negative control (written mathematical/control example).** Equality of cycle and entry fields is not automatic for other matrices; the two-vertex off-diagonal √5 example has strict inclusion.

**Scope.** The concrete four-generator adjoin, cycle field, and entry field are all defined and proved equal. Identification with a geometric adjoint trace field is E2.

### V17 — Primitive element and coordinates

**English.** w=2(r+a+b₈) generates the full field, with the displayed degree-8 polynomial and reconstructed generator coordinates.

**Status.** Exact computation; not a Lean proof. Source lines: 79, 258, 995, 1155, 1343.

**Translation.** Explicit computational assertion with checked data. The explicit data and arithmetic are checked by the named artifacts; an executed computation is not presented as a Lean theorem. External inputs: computation.

**Lean mapping.** No declaration of the full mathematical statement.

**Positive example (executed exact computation).** The exact script proves w=2(r+a+b₈), all radical relations and branch signs in the quotient, and the stored coordinates express every generator in ℚ(w). Evidence: [manuscript_computation_audit.py](../scripts/manuscript_computation_audit.py); [manuscript_computation_audit.json](../results/manuscript_computation_audit.json).

**Negative control (executed exact computation).** Perturbing each of the 32 rational coordinates by 1/1000 independently violates its generator relation. Evidence: [manuscript_computation_audit.py](../scripts/manuscript_computation_audit.py); [manuscript_computation_audit.json](../results/manuscript_computation_audit.json).

**Scope.** The unique real root in (22,23) selects the intended embedding; irreducibility is checked by GP, not Lean.

### V18 — Primitive polynomial irreducibility

**English.** The displayed degree-8 polynomial is irreducible over ℚ.

**Status.** Exact computation; not a Lean proof. Source lines: 995, 1343.

**Translation.** Explicit computational assertion with checked data. The explicit data and arithmetic are checked by the named artifacts; an executed computation is not presented as a Lean theorem. External inputs: computation.

**Lean mapping.** No declaration of the full mathematical statement.

**Positive example (executed exact computation).** PARI/GP polisirreducible returns true for the exact coefficients. Evidence: [manuscript_field_controls.gp](../scripts/manuscript_field_controls.gp).

**Negative control (executed exact computation).** Multiplying it by X-1 gives a reducible degree-9 polynomial and is rejected. Evidence: [manuscript_field_controls.gp](../scripts/manuscript_field_controls.gp).

**Scope.** Irreducibility is an independent CAS check; no Lean proof of this degree-8 assertion is claimed.

### V19 — Field signature

**English.** The full field has signature (4,2), degree 8, and two conjugate pairs of nonreal embeddings.

**Status.** Exact computation; not a Lean proof. Source lines: 995, 1343.

**Translation.** Explicit computational assertion with checked data. The explicit data and arithmetic are checked by the named artifacts; an executed computation is not presented as a Lean theorem. External inputs: computation.

**Lean mapping.** [`PseudoArithmetic.CensusAudit.field_signature_controls`](../formal/PseudoArithmetic/CensusAudit.lean).

**Positive example (Lean evidence).** Sturm arithmetic finds four real roots; GP gives signature (4,2), and Lean checks 4+2·2=8. Evidence: [`PseudoArithmetic.CensusAudit.field_signature_controls`](../formal/PseudoArithmetic/CensusAudit.lean); [manuscript_computation_audit.py](../scripts/manuscript_computation_audit.py); [manuscript_computation_audit.json](../results/manuscript_computation_audit.json); [manuscript_field_controls.gp](../scripts/manuscript_field_controls.gp).

**Negative control (Lean evidence).** Counting complex pairs as individual embeddings gives 4+2=6≠8; ℚ(i) with signature (0,1) distinguishes non-total reality from no real places. Evidence: [`PseudoArithmetic.CensusAudit.field_signature_controls`](../formal/PseudoArithmetic/CensusAudit.lean); [manuscript_field_controls.gp](../scripts/manuscript_field_controls.gp).

**Scope.** The numerical signature is computational. The core theorem proves non-total reality without using this degree-8 computation.

### V20 — Field discriminant

**English.** The full field discriminant is 40960000=2¹⁶5⁴.

**Status.** Exact computation; not a Lean proof. Source lines: 995, 1343.

**Translation.** Explicit computational assertion with checked data. The explicit data and arithmetic are checked by the named artifacts; an executed computation is not presented as a Lean theorem. External inputs: computation.

**Lean mapping.** [`PseudoArithmetic.CensusAudit.field_signature_controls`](../formal/PseudoArithmetic/CensusAudit.lean).

**Positive example (Lean evidence).** GP computes nfdisc=40960000; Lean verifies the integer factorization. Evidence: [`PseudoArithmetic.CensusAudit.field_signature_controls`](../formal/PseudoArithmetic/CensusAudit.lean); [manuscript_field_controls.gp](../scripts/manuscript_field_controls.gp).

**Negative control (executed exact computation).** For X²-5, the polynomial discriminant is 20 but the field discriminant is 5; these notions cannot be interchanged. Evidence: [manuscript_field_controls.gp](../scripts/manuscript_field_controls.gp).

**Scope.** The negative control is checked by GP; the full discriminant is not a Lean theorem.

### V21 — Two primitive-element routes

**English.** Both routes describe the same reconstructed field; degree, signature and discriminant alone do not establish isomorphism.

**Status.** Exact computation; not a Lean proof. Source lines: 995.

**Translation.** Explicit computational assertion with checked data. The explicit data and arithmetic are checked by the named artifacts; an executed computation is not presented as a Lean theorem. External inputs: computation.

**Lean mapping.** No declaration of the full mathematical statement.

**Positive example (executed exact computation).** GP finds an isomorphism between the two degree-8 presentations, and the original certifiers reconstruct the same radicals. Evidence: [manuscript_field_controls.gp](../scripts/manuscript_field_controls.gp).

**Negative control (executed exact computation).** X³-6X²-9X-1 and X³-21X-28 define nonisomorphic fields with degree 3, signature (3,0), and discriminant 3969. Evidence: [manuscript_field_controls.gp](../scripts/manuscript_field_controls.gp).

**Scope.** GP checks this explicit negative pair. Its isomorphism test gives abstract field isomorphism; identification as the same subfield of ℝ also uses the radical reconstruction.

### D01 — Supplementary descent criterion

**English.** The supplied normalization, Clifford, ABHN and Hasse–Minkowski implications yield the stated similarity-descent equivalences.

**Status.** Implication checked using external predicates/hypotheses. Source lines: 1175.

**Translation.** Reviewed specialization of an external input. The listed implication is conditional on the explicitly supplied descent/classification hypotheses. It is supplementary to the main argument; the candidate quantifiers and admissibility guards are checked by the named controls. External inputs: background.

**Lean mapping.** [`PseudoArithmetic.DescentBridge.simDesc_iff`](../formal/PseudoArithmetic/ConditionalDescent.lean); [`PseudoArithmetic.normalized_clifford_descent_iff`](../formal/PseudoArithmetic/ConditionalDescent.lean); [`PseudoArithmetic.normalized_clifford_splitSupport_iff`](../formal/PseudoArithmetic/ConditionalDescent.lean).

**Positive example (Lean evidence).** The Boolean descent model has one candidate that descends. Evidence: [`PseudoArithmetic.InterfaceAudit.descent_positive_and_negative`](../formal/PseudoArithmetic/InterfaceAudit.lean).

**Negative control (Lean evidence).** Its other candidate fails descent even though the general candidate type is inhabited. Evidence: [`PseudoArithmetic.InterfaceAudit.descent_positive_and_negative`](../formal/PseudoArithmetic/InterfaceAudit.lean).

**Scope.** This audits the supplementary interface mentioned in the manuscript, not the classical quadratic-form theorems.

### D02 — Split support and ramification orbits

**English.** Split support requires ramification stability on orbits and trivial decomposition at every ramified prime.

**Status.** Mathematical content checked in Lean. Source lines: 1175.

**Translation.** Matched mathematical statement, checked in Lean. The listed Lean definitions and theorems express the mathematical content; the scope below specifies the objects and any specialization. External inputs: none.

**Lean mapping.** [`PseudoArithmetic.SplitSupport`](../formal/PseudoArithmetic/ConditionalDescent.lean).

**Positive example (Lean evidence).** With the two-point flip action, full ramification support and trivial decomposition satisfy the definition. Evidence: [`PseudoArithmetic.InterfaceAudit.split_support_positive`](../formal/PseudoArithmetic/InterfaceAudit.lean).

**Negative control (Lean evidence).** Support on only one point breaks orbit stability; nontrivial decomposition at a ramified point separately breaks split support. Evidence: [`PseudoArithmetic.InterfaceAudit.incomplete_orbit_negative`](../formal/PseudoArithmetic/InterfaceAudit.lean); [`PseudoArithmetic.InterfaceAudit.nonsplit_prime_negative`](../formal/PseudoArithmetic/InterfaceAudit.lean).

**Scope.** These are finite combinatorial models; interpreting points as primes and predicates as Brauer invariants remains external.

### D03 — Candidate quantifiers

**English.** Pseudo-arithmeticity needs existence of an eligible admissible candidate passing the descent test, not success of every candidate.

**Status.** Implication checked using external predicates/hypotheses. Source lines: 1175.

**Translation.** Reviewed specialization of an external input. The listed implication is conditional on the explicitly supplied descent/classification hypotheses. It is supplementary to the main argument; the candidate quantifiers and admissibility guards are checked by the named controls. External inputs: background.

**Lean mapping.** [`PseudoArithmetic.DescentBridge.pseudoArithmetic_iff`](../formal/PseudoArithmetic/ConditionalDescent.lean).

**Positive example (Lean evidence).** The Boolean model succeeds because the true candidate passes. Evidence: [`PseudoArithmetic.InterfaceAudit.descent_interface_equivalence`](../formal/PseudoArithmetic/InterfaceAudit.lean).

**Negative control (Lean evidence).** The false candidate fails, so replacing existence by a universal requirement rejects a positive model. Evidence: [`PseudoArithmetic.InterfaceAudit.candidate_quantifier_is_existential`](../formal/PseudoArithmetic/InterfaceAudit.lean).

**Scope.** The candidate type can be infinite; the code does not prove a finite enumeration.

### D04 — All-candidates obstruction

**English.** Failure of split support for every eligible candidate rules out pseudo-arithmeticity.

**Status.** Implication checked using external predicates/hypotheses. Source lines: 1175.

**Translation.** Reviewed specialization of an external input. The listed implication is conditional on the explicitly supplied descent/classification hypotheses. It is supplementary to the main argument; the candidate quantifiers and admissibility guards are checked by the named controls. External inputs: background.

**Lean mapping.** [`PseudoArithmetic.all_candidates_fail_splitSupport_not_pseudoArithmetic`](../formal/PseudoArithmetic/ConditionalDescent.lean); [`PseudoArithmetic.all_candidates_obstructed_not_pseudoArithmetic`](../formal/PseudoArithmetic/ConditionalDescent.lean).

**Positive example (written mathematical/control example).** The generic theorem composes only the necessary directions of the supplied implications.

**Negative control (Lean evidence).** One failed candidate is insufficient when another passes, as in the Boolean model. Evidence: [`PseudoArithmetic.InterfaceAudit.candidate_quantifier_is_existential`](../formal/PseudoArithmetic/InterfaceAudit.lean).

**Scope.** This positive example is the general checked implication; a concrete arithmetic exhaustion is outside the interface and is not used by the manuscript's main proof.

## Source coverage ledger

The ledger covers displayed equations and table rows with their enclosing source block. Nonmathematical classifications are explicit; there is no default that silently treats unmatched prose as nonmathematical.

| Block | Source line | Statements or classification |
| ---: | ---: | --- |
| 0 | 61 | M01, M02, R06, R07, R08, R09, R13, R14, R16, R20, R22, T14, T15, T16, G25, G26, G28, G29 |
| 1 | 79 | R13, R20, M01, M02, V11, V17 |
| 2 | 86 | Heading, navigation, or document structure; no mathematical assertion. |
| 3 | 88 | Heading, navigation, or document structure; no mathematical assertion. |
| 4 | 91 | Heading, navigation, or document structure; no mathematical assertion. |
| 5 | 93 | G05, T17, T09, T14, M01 |
| 6 | 104 | M01 |
| 7 | 106 | M01, R22 |
| 8 | 116 | M02 |
| 9 | 122 | C01, C04, C11, C12, C13, C14, R06, R08 |
| 10 | 129 | Dated literature and novelty report; historical claim covered by NOVELTY_AUDIT.md, not an English-to-Lean theorem. |
| 11 | 137 | Heading, navigation, or document structure; no mathematical assertion. |
| 12 | 140 | Expository transition or trust-boundary explanation; mathematical content is registered in the adjacent blocks. |
| 13 | 142 | G01, G02, G03, G04, G05, G06 |
| 14 | 161 | G07, G10, G11, G19, G20, G21, G22, R01, R03, R05 |
| 15 | 182 | F01, F02, F03, F04, F10, F11 |
| 16 | 193 | T01, T02, T03, T05, T16 |
| 17 | 206 | T06, T07, T08, T09, T10, T13, T14 |
| 18 | 218 | Verification/provenance/build metadata, checked by the release workflow; no new mathematical assertion. |
| 19 | 228 | Heading, navigation, or document structure; no mathematical assertion. |
| 20 | 231 | C11, C12, C13, C14, R06, R07, R08, R09, R13, R14, R15, R16, R20, R21, R22 |
| 21 | 253 | Heading, navigation, or document structure; no mathematical assertion. |
| 22 | 256 | Expository transition or trust-boundary explanation; mathematical content is registered in the adjacent blocks. |
| 23 | 258 | C01, C10, C11, C12, C13, C14, R06, R08, R13, R14, R20, M01, M02, T14, T16, V01, V02, V11, V17 |
| 24 | 276 | Expository transition or trust-boundary explanation; mathematical content is registered in the adjacent blocks. |
| 25 | 279 | Heading, navigation, or document structure; no mathematical assertion. |
| 26 | 282 | Heading, navigation, or document structure; no mathematical assertion. |
| 27 | 284 | Expository transition or trust-boundary explanation; mathematical content is registered in the adjacent blocks. |
| 28 | 286 | F05 |
| 29 | 292 | F05, F06 |
| 30 | 298 | F07, F08, F09 |
| 31 | 308 | F02, F07, F08, F09 |
| 32 | 320 | F10 |
| 33 | 327 | F02, F06, F10, F11, F16, F17 |
| 34 | 345 | F12 |
| 35 | 352 | F12, F14 |
| 36 | 362 | F13 |
| 37 | 368 | F10, F13 |
| 38 | 376 | Heading, navigation, or document structure; no mathematical assertion. |
| 39 | 378 | G01, G02, G12, G13, G14, G15, G16, G17 |
| 40 | 394 | G18, G20, G21, G22 |
| 41 | 401 | G07, G08, G09 |
| 42 | 409 | G10, G11 |
| 43 | 414 | Heading, navigation, or document structure; no mathematical assertion. |
| 44 | 417 | G23, G24, G25 |
| 45 | 424 | G26 |
| 46 | 426 | G26 |
| 47 | 432 | G26, G27, G28, G29 |
| 48 | 443 | Heading, navigation, or document structure; no mathematical assertion. |
| 49 | 446 | Heading, navigation, or document structure; no mathematical assertion. |
| 50 | 448 | T01, T02, T03, T06, T07 |
| 51 | 462 | T04, T05 |
| 52 | 473 | Heading, navigation, or document structure; no mathematical assertion. |
| 53 | 475 | T08 |
| 54 | 481 | T09 |
| 55 | 493 | T09, T10, T13, F03 |
| 56 | 501 | T14 |
| 57 | 507 | T10, T11, T12, T13, T14 |
| 58 | 517 | T15 |
| 59 | 525 | Heading, navigation, or document structure; no mathematical assertion. |
| 60 | 528 | R01, R02, R05 |
| 61 | 540 | T16 |
| 62 | 548 | T16, R03 |
| 63 | 556 | R04, R05, R25 |
| 64 | 569 | Heading, navigation, or document structure; no mathematical assertion. |
| 65 | 572 | Heading, navigation, or document structure; no mathematical assertion. |
| 66 | 574 | C02, C03 |
| 67 | 591 | C04, C06, G11 |
| 68 | 594 | C04, C05, C06 |
| 69 | 613 | C01, V11 |
| 70 | 617 | Heading, navigation, or document structure; no mathematical assertion. |
| 71 | 619 | C04, C07, C08, C09, F14, F15 |
| 72 | 642 | C03, C10, C16, G19, G20, G21, G22 |
| 73 | 677 | Heading, navigation, or document structure; no mathematical assertion. |
| 74 | 680 | C11, C12, C13, C14, R03, R06, R07, R08, R09 |
| 75 | 716 | Heading, navigation, or document structure; no mathematical assertion. |
| 76 | 719 | Heading, navigation, or document structure; no mathematical assertion. |
| 77 | 721 | Expository transition or trust-boundary explanation; mathematical content is registered in the adjacent blocks. |
| 78 | 723 | R13 |
| 79 | 733 | C07, R10, R11, F14 |
| 80 | 775 | R12, R13 |
| 81 | 791 | R11, R12, R13 |
| 82 | 805 | Heading, navigation, or document structure; no mathematical assertion. |
| 83 | 807 | R24 |
| 84 | 813 | R14, R15, R16, R17, F09, F12 |
| 85 | 839 | F01, F10, R20, R21, R24 |
| 86 | 847 | F03, F04, F08, R18, R19, R20, R21, R23 |
| 87 | 862 | Heading, navigation, or document structure; no mathematical assertion. |
| 88 | 865 | C01, G10, G11, M01 |
| 89 | 871 | F01, F15, C15, R05, R07, R09, R22, T16 |
| 90 | 888 | F13, R13, R18, R20, R22 |
| 91 | 893 | T14, T15, M01 |
| 92 | 900 | G23, G24, G26, G27, G31, M02 |
| 93 | 908 | G25, G28, G29, G30, C05, M02 |
| 94 | 919 | T05, T15, M03, M04 |
| 95 | 929 | Heading, navigation, or document structure; no mathematical assertion. |
| 96 | 932 | C01, T14, T16, M01 |
| 97 | 937 | Heading, navigation, or document structure; no mathematical assertion. |
| 98 | 939 | V01, V02, V03, V04, V05, C07 |
| 99 | 959 | Heading, navigation, or document structure; no mathematical assertion. |
| 100 | 961 | V06, V07, V08, V09, V10, V11 |
| 101 | 978 | V12, V13, C01, C06 |
| 102 | 993 | Heading, navigation, or document structure; no mathematical assertion. |
| 103 | 995 | V14, V15, V16, V17, V18, V19, V20, V21, R05 |
| 104 | 1023 | Heading, navigation, or document structure; no mathematical assertion. |
| 105 | 1025 | Verification/provenance/build metadata, checked by the release workflow; no new mathematical assertion. |
| 106 | 1045 | Verification/provenance/build metadata, checked by the release workflow; no new mathematical assertion. |
| 107 | 1051 | Heading, navigation, or document structure; no mathematical assertion. |
| 108 | 1054 | Verification/provenance/build metadata, checked by the release workflow; no new mathematical assertion. |
| 109 | 1057 | Heading, navigation, or document structure; no mathematical assertion. |
| 110 | 1059 | Expository transition or trust-boundary explanation; mathematical content is registered in the adjacent blocks. |
| 111 | 1062 | R07, R09, R12, R13, F08, R16, R20, R23 |
| 112 | 1094 | C10, C15, R06, R08, R22, V16, T16 |
| 113 | 1103 | Heading, navigation, or document structure; no mathematical assertion. |
| 114 | 1105 | M01, T14, T16, C10, R22 |
| 115 | 1130 | G25, G26, G28, G29, G30, T05, M02, M03, M04 |
| 116 | 1142 | Heading, navigation, or document structure; no mathematical assertion. |
| 117 | 1144 | Verification/provenance/build metadata, checked by the release workflow; no new mathematical assertion. |
| 118 | 1155 | F09, F10, F12, T10, T13, G14, G15, G16, G17, G23, G24, G29, V03, V06, V17, R17, M01, M02, V07, V08, V09, V10, V12 |
| 119 | 1173 | Heading, navigation, or document structure; no mathematical assertion. |
| 120 | 1175 | D01, D02, D03, D04, R20 |
| 121 | 1184 | Heading, navigation, or document structure; no mathematical assertion. |
| 122 | 1186 | Verification/provenance/build metadata, checked by the release workflow; no new mathematical assertion. |
| 123 | 1199 | Heading, navigation, or document structure; no mathematical assertion. |
| 124 | 1202 | Expository transition or trust-boundary explanation; mathematical content is registered in the adjacent blocks. |
| 125 | 1206 | C01, C04, C05, C06, C08, C09, C10, V01, V02, V11, G30 |
| 126 | 1217 | T16, R22 |
| 127 | 1225 | T14, T15 |
| 128 | 1232 | F09, F10, F11, R20 |
| 129 | 1239 | G26, G24 |
| 130 | 1246 | T05, M03 |
| 131 | 1252 | G25, G28, G29, M02, M04 |
| 132 | 1263 | Verification/provenance/build metadata, checked by the release workflow; no new mathematical assertion. |
| 133 | 1267 | Heading, navigation, or document structure; no mathematical assertion. |
| 134 | 1270 | Expository transition or trust-boundary explanation; mathematical content is registered in the adjacent blocks. |
| 135 | 1273 | C11, C12, C13, C14, R06, R08, R13, R16, T14, T16 |
| 136 | 1279 | Verification/provenance/build metadata, checked by the release workflow; no new mathematical assertion. |
| 137 | 1285 | Verification/provenance/build metadata, checked by the release workflow; no new mathematical assertion. |
| 138 | 1291 | Verification/provenance/build metadata, checked by the release workflow; no new mathematical assertion. |
| 139 | 1298 | Verification/provenance/build metadata, checked by the release workflow; no new mathematical assertion. |
| 140 | 1309 | Heading, navigation, or document structure; no mathematical assertion. |
| 141 | 1311 | Heading, navigation, or document structure; no mathematical assertion. |
| 142 | 1314 | C01, C11, C12, C13, C14, R06, R07, R08, R09, F08, R13, R20, R21, R22, T14, T15, T16, M01, M02, G26, M03, M04 |
| 143 | 1340 | Heading, navigation, or document structure; no mathematical assertion. |
| 144 | 1343 | V17, V18, V19, V20, R20, F04 |

## Reproduce

```sh
python3 scripts/manuscript_audit.py --check
python3 scripts/manuscript_computation_audit.py
gp -q scripts/manuscript_field_controls.gp
python3 scripts/semantic_audit_examples.py
cd formal && lake build
```

From the repository root, `python3 scripts/release_check.py` runs the coverage check, compares fresh exact reports, runs the GP controls, builds Lean, checks all registered declarations' axioms, and rebuilds the manuscript.
