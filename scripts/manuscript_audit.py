#!/usr/bin/env python3
"""Validate the manually reviewed manuscript statement register and render it.

This checks coverage bookkeeping, not mathematical semantics. Lean and the
independent arithmetic programs check the evidence named in the register.
There is deliberately no command that automatically approves changed text.
"""

from __future__ import annotations

import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "audit/manuscript_statements.json"
MANUSCRIPT = ROOT / "manuscript/non_pseudo_arithmetic_4_manifolds.tex"
REPORT = ROOT / "notes/manuscript_semantic_audit.md"
STATUSES = {
    "kernel": "Mathematical content checked in Lean",
    "partial": "Some mathematical content checked; stated boundary remains",
    "conditional": "Implication checked using external predicates/hypotheses",
    "computation": "Exact computation; not a Lean proof",
    "data": "External data with arithmetic/encoding controls",
    "external": "Mathematical statement remains external",
}
TRANSLATIONS = {
    "checked_statement": "Matched mathematical statement, checked in Lean",
    "external_contract": "Reviewed specialization of an external input",
    "external_interpretation": "Reviewed external interpretation of the vocabulary",
    "alternative_proof": "Same checked result; written proof route differs",
    "computational_check": "Explicit computational assertion with checked data",
    "background": "Background generality not separately used by the Lean argument",
}


def source_blocks(source: str) -> list[dict]:
    start = source.index(r"\begin{abstract}")
    stop = source.index(r"\begin{thebibliography}")
    return [dict(index=i, line=source.count("\n", 0, start+m.start())+1,
                 sha256=hashlib.sha256(m.group().encode()).hexdigest(), text=m.group())
            for i, m in enumerate(re.finditer(r"\S[\s\S]*?(?=\n\s*\n|\Z)", source[start:stop]))]


def declarations(catalog: dict) -> list[str]:
    return sorted({name for claim in catalog["claims"]
                   for names in (claim["lean"], claim["positive"]["lean"], claim["negative"]["lean"])
                   for name in names})


def validate(catalog: dict, source: str) -> dict:
    def require(condition: bool, message: str):
        if not condition:
            raise ValueError(message)

    require(catalog["schema_version"] == 1, "Unknown statement-register schema")
    claims = catalog["claims"]
    ids = [claim["id"] for claim in claims]
    require(len(set(ids)) == len(ids), "Duplicate statement IDs")
    for claim in claims:
        ident = claim["id"]
        require(claim["status"] in STATUSES, f"Unknown status for {ident}")
        require(bool(claim["statement"].strip()), f"Missing statement for {ident}")
        require(bool(claim["boundary"].strip()), f"Missing scope/boundary for {ident}")
        review = claim.get("translation")
        require(isinstance(review, dict), f"Missing translation review for {ident}")
        require(review["assessment"] in TRANSLATIONS, f"Unknown translation assessment for {ident}")
        require(bool(review["reason"].strip()), f"Missing translation justification for {ident}")
        require(isinstance(review["external_inputs"], list), f"Missing external-input list for {ident}")
        require(all(x in {"E1", "E2", "E3", "E4", "E5", "E6", "E7", "background", "computation"}
                    for x in review["external_inputs"]), f"Unknown external input for {ident}")
        if review["assessment"] == "external_contract":
            require(bool(claim["lean"]) and bool(review["external_inputs"]),
                    f"An external contract needs a Lean reference and a named input: {ident}")
        require(claim["lean"] or claim["status"] in {"computation", "external", "data"},
                f"Missing Lean mapping for {ident}")
        for polarity in ("positive", "negative"):
            example = claim[polarity]
            require(bool(example["example"].strip()), f"Missing {polarity} example for {ident}")
            require(example["verification"] in {"lean", "computation", "written"},
                    f"Missing evidence classification for {ident} {polarity}")
            require(example["verification"] != "lean" or bool(example["lean"]),
                    f"No declaration for {ident} {polarity}")
            for artifact in example.get("artifacts", []):
                require((ROOT / artifact).is_file(), f"Missing evidence file {artifact}")

    actual = source_blocks(source)
    recorded = catalog["source_blocks"]
    require(len(actual) == len(recorded),
            f"Source block count changed ({len(recorded)} reviewed, {len(actual)} present): review required")
    covered = set()
    mathematical = 0
    for current, review in zip(actual, recorded):
        require(current["index"] == review["index"], "Source blocks reordered or duplicated")
        require(current["sha256"] == review["sha256"],
                f"Unreviewed manuscript edit at block {current['index']}, line {current['line']}")
        require(current["line"] == review["line"],
                f"Source locations changed at block {current['index']}: refresh after review")
        require(bool(review["claims"]) != bool(review.get("nonmathematical_reason")),
                f"Block {current['index']} needs statements or an explicit nonmathematical classification")
        unknown = set(review["claims"]) - set(ids)
        require(not unknown, f"Unknown claims in source block: {unknown}")
        covered.update(review["claims"])
        mathematical += bool(review["claims"])
    require(covered == set(ids), f"Claims not mapped to the manuscript: {sorted(set(ids)-covered)}")
    return dict(statements=len(claims), source_blocks=len(actual),
                mathematical_source_blocks=mathematical,
                classifications=dict(sorted(Counter(c["status"] for c in claims).items())),
                translation_assessments=dict(sorted(Counter(c["translation"]["assessment"]
                                                           for c in claims).items())),
                positive_examples=len(claims), negative_examples=len(claims),
                example_evidence=dict(sorted(Counter(c[p]["verification"] for c in claims
                                                     for p in ("positive", "negative")).items())),
                lean_declarations=len(declarations(catalog)))


def lean_link(name: str) -> str:
    parts = name.split(".")
    paths = list((ROOT / "formal/PseudoArithmetic").glob("*.lean"))
    modules = {p.stem for p in paths}
    module = parts[1] if len(parts) > 2 and parts[1] in modules else (
        "ConditionalDescent" if any(key in name for key in
            ("DescentBridge", "SplitSupport", "splitSupport", "clifford", "candidates"))
        else "NonTotalReality")
    # Some audit namespaces span a main module and a controls module.
    # Link the declaration itself, rather than guessing from the namespace.
    declaration = re.compile(r"^(?:theorem|lemma|def|noncomputable def|structure|abbrev|inductive) "
                             + re.escape(parts[-1]) + r"\b", re.MULTILINE)
    candidates = [p for p in paths if declaration.search(p.read_text())]
    if len(candidates) == 1:
        module = candidates[0].stem
    return f"[`{name}`](../formal/PseudoArithmetic/{module}.lean)"


def render(catalog: dict, stats: dict) -> str:
    lines = ["# Manuscript-wide semantic audit", "", "Reviewed 9 October 2026.", "",
        f"The register contains **{stats['statements']} distinct statement entries**, with a positive example and a negative control for each. "
        f"All **{stats['source_blocks']} source blocks** from the abstract through the final mathematical appendix are classified; "
        f"{stats['mathematical_source_blocks']} blocks contain mathematical assertions. Repeated statements point to the same entries.", "",
        "**Acceptance criterion: faithful translation and correct use of the imported inputs.** External geometric theorems may remain "
        "explicit assumptions. Their proof provenance is separate from translation correctness; using mathlib or a different checked proof "
        "is not a defect. The [external-input translation review](external_translation_audit.md) explains all seven input contracts and "
        "the disposition of the original 21 partial entries. Boolean interface models test logic, not geometric existence.", "",
        "A valid theorem has no negative example satisfying all its premises. Negative controls below instead violate a premise, falsify a "
        "stronger or mistranslated assertion, change the data, or probe an excluded boundary. A surviving mutation is reported when it proves "
        "a different valid theorem. Example evidence is labeled separately from statement status: a Lean link can check a supporting fact "
        "without constructing the entire geometric example. Written controls are explicitly not executed proofs.", "",
        "## Translation assessments", "", "| Assessment | Entries |", "| --- | ---: |"]
    for assessment, count in stats["translation_assessments"].items():
        lines.append(f"| {TRANSLATIONS[assessment]} | {count} |")
    lines.extend(["", "## Proof provenance", "",
        "These counts describe where the mathematics is proved; external or partial provenance is not itself a translation failure.", "",
        "| Status | Entries |", "| --- | ---: |"])
    for status, count in stats["classifications"].items():
        lines.append(f"| {STATUSES[status]} | {count} |")
    lines.extend(["", "The inventory is [machine readable](../audit/manuscript_statements.json). "
        "The [coverage checker](../scripts/manuscript_audit.py) verifies exact source-block fingerprints, nonempty positive/negative controls, "
        "evidence files, and complete cross-references. It does not infer the English meaning or automatically approve changed text. "
        "Every named Lean declaration is checked by the release validator's transitive-axiom audit.", "",
        "The default Lean build includes the algebraic, geometric, subdiagram, and face audit modules and the specialized external contracts. "
        "The [subdiagram and face worked audit](subdiagram_face_semantic_audit.md) proves the classification of all 127 nonempty principal "
        "subsets of the actual third Gram matrix and the full face vector (10,21,18,7,1), with all 70 incidence-bit flips, ten vertex deletions, "
        "and an infinite family of incorrect vectors that pass Euler's check. Besides the [28,310-case rational barrage](../results/two_cycle_semantic_audit.json), "
        "the [independent exact matrix audit](../results/manuscript_computation_audit.json) checks all three ranks/inertias, all 127 principal "
        "subdiagrams for the third matrix, and rejects 24 cycle perturbations, 32 power-basis coordinate perturbations, 10 vertex deletions, "
        "and 3 rank perturbations. A 7×7 counterexample shows why vanishing principal six-minors alone cannot prove rank five. "
        "[PARI controls](../scripts/manuscript_field_controls.gp) distinguish field and polynomial discriminants and verify a pair of "
        "nonisomorphic fields sharing degree, signature, and discriminant.", "",
        "## Findings and changes", "",
        "The actual Gram matrices and generated cyclic fields are now constructed in Lean. Their two cycles, algebraicity, number-field "
        "instances, and non-total reality are proved for every case. The third cyclic field is proved equal to its entry field. New proofs "
        "also cover the two embeddings of ℚ(√5), extension of embeddings, discriminant criterion, totally positive radical extensions, "
        "Lorentz reflections, orientation indices, and the topological noncompactness argument.", "",
        "The text now explicitly requires Coxeter-matrix symmetry and lattice discreteness, allows ideal zero angles, and accurately "
        "describes the enlarged formal boundary. The supplementary candidate interface is no longer described as proving finiteness. "
        "The source census, geometric realization, general adjoint construction, Vinberg identifications, Selberg theorem, and hyperbolic "
        "quotient construction remain external or partial as identified below. Exact signature and discriminant calculations remain CAS "
        "evidence. These are intentional proof boundaries, not translation failures merely because the imported proofs are absent. "
        "The strengthened contracts tie every census case to its actual matrix, identify fields by equality, preserve the n=4 domain, "
        "and keep all cover properties on the same witnesses. Translation assessments below state what is reviewed and what is only background.", "",
        "## Statement register", ""])
    for claim in catalog["claims"]:
        ident = claim["id"]
        blocks = [block for block in catalog["source_blocks"] if ident in block["claims"]]
        locations = ", ".join(str(block["line"]) for block in blocks)
        lines.extend([f"### {ident} — {claim['title']}", "",
            f"**English.** {claim['statement']}", "",
            f"**Status.** {STATUSES[claim['status']]}. Source lines: {locations}.", ""])
        review = claim["translation"]
        inputs = ", ".join(review["external_inputs"]) or "none"
        lines.extend([f"**Translation.** {TRANSLATIONS[review['assessment']]}. {review['reason']} "
                      f"External inputs: {inputs}.", ""])
        if claim["lean"]:
            lines.extend(["**Lean mapping.** " + "; ".join(lean_link(name) for name in claim["lean"]) + ".", ""])
        else:
            lines.extend(["**Lean mapping.** No declaration of the full mathematical statement.", ""])
        for polarity, label in (("positive", "Positive example"), ("negative", "Negative control")):
            example = claim[polarity]
            evidence = {"lean": "Lean evidence", "computation": "executed exact computation", "written": "written mathematical/control example"}[example["verification"]]
            links = "; ".join(lean_link(name) for name in example["lean"])
            links += ("; " if links and example.get("artifacts") else "") + "; ".join(
                f"[{Path(path).name}](../{path})" for path in example.get("artifacts", []))
            lines.extend([f"**{label} ({evidence}).** {example['example']}" + (f" Evidence: {links}." if links else ""), ""])
        lines.extend([f"**Scope.** {claim['boundary']}", ""])
    lines.extend(["## Source coverage ledger", "",
        "The ledger covers displayed equations and table rows with their enclosing source block. Nonmathematical classifications are explicit; "
        "there is no default that silently treats unmatched prose as nonmathematical.", "",
        "| Block | Source line | Statements or classification |", "| ---: | ---: | --- |"])
    for block in catalog["source_blocks"]:
        content = ", ".join(block["claims"]) or block["nonmathematical_reason"]
        lines.append(f"| {block['index']} | {block['line']} | {content} |")
    lines.extend(["", "## Reproduce", "", "```sh", "python3 scripts/manuscript_audit.py --check",
        "python3 scripts/manuscript_computation_audit.py", "gp -q scripts/manuscript_field_controls.gp",
        "python3 scripts/semantic_audit_examples.py", "cd formal && lake build", "```", "",
        "From the repository root, `python3 scripts/release_check.py` runs the coverage check, compares fresh exact reports, "
        "runs the GP controls, builds Lean, checks all registered declarations' axioms, and rebuilds the manuscript.", ""])
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Also require the readable report to be current")
    parser.add_argument("--render", action="store_true", help="Regenerate the report after a successful coverage check")
    parser.add_argument("--lean-audit", type=Path, help="Write #print axioms for every registered declaration")
    args = parser.parse_args()
    catalog = json.loads(CATALOG.read_text())
    stats = validate(catalog, MANUSCRIPT.read_text())
    report = render(catalog, stats)
    if args.render:
        REPORT.write_text(report)
    if args.check and (not REPORT.exists() or REPORT.read_text() != report):
        raise ValueError("Readable audit report is stale; review the register and run --render")
    if args.lean_audit:
        args.lean_audit.write_text("import PseudoArithmetic\n" + "".join(
            f"#print axioms {name}\n" for name in declarations(catalog)))
    print(json.dumps(stats, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
