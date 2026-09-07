# Choice Audit — Deterministic Codex Implementation Contract v1.0

## Objective
Build a production-grade browser-native **Choice Audit** inside the existing FluxMintDigital Workshop.

It must:
- work without authentication
- work without email capture
- store reflection content locally only
- remain usable when persistent storage is unavailable
- provide the canonical printable Choice Audit PDF
- support printing the visitor's current audit
- support desktop, intermediate, and mobile compositions
- support keyboard-only and screen-reader use
- preserve the locked FluxMintDigital visual system
- never interpret, score, diagnose, rank, or define the visitor

The result must feel like a native **Workshop instrument**, not a generic form app.

## Canonical Public Route
Preferred:
`/workshop/choice-audit/`

Sibling artifact:
`/workshop/personal-architecture-map/`

## Conceptual Component Boundaries
Adapt naming to repository conventions while preserving separation:

- `ChoiceAuditArtifact`
  - `ArtifactHeader`
  - `PrivacyReceipt`
  - `ChoiceField`
  - `ForceField`
    - `ForceRegion`
    - `ParticipationClassifier`
    - `InfluenceMarker`
  - `RelationshipLayer`
  - `TemporalLens`
  - `CounterfactualField`
  - `EvidenceLens`
  - `PreservationField`
  - `AuditReflection`
  - `LocalPersistenceStatus`
  - `AuditActions`
  - `ArchitectureReveal`
  - `ArtifactRelationshipExits`

Supporting infrastructure:
- local persistence adapter
- audit schema/versioning
- print renderer / print styles
- analytics allowlist
- accessibility helpers where needed

## Canonical Data Schema
```text
ChoiceAudit
  schemaVersion
  id
  createdAt
  updatedAt
  title?
  choice

  forces
    desire
    expectation
    security
    opportunity
    identity
    obligation
    fearAvoidance
    possibility

  relationships[]

  temporal
    then
    after
    now

  counterfactual
    reflection
    response?

  evidence
    supports
    challenges
    alternatives
    uncertainty

  preservation
```

Each force:
```text
ForceEntry
  reflection
  classifications[]
  influence?
```

Allowed classifications:
`W | E | N | P | ?`

Allowed influence:
`1 | 2 | 3 | null`

The UI must render influence qualitatively:
- `• Present`
- `•• Significant`
- `••• Dominant`

Never as score, percentage, bar, or normalized weight.

Classifications are overlapping multi-select values, not radio buttons.

## Canonical Force Regions
1. Desire
2. Expectation
3. Security
4. Opportunity
5. Identity
6. Obligation
7. Fear & Avoidance
8. Possibility

## Local Persistence
Preferred:
**IndexedDB**

Required abstraction:
```text
AuditRepository
  create()
  get()
  save()
  duplicate()
  list()
  delete()
```

Fallback:
**in-memory current-session state**

Do not silently fall back to server storage, cookies, query strings, remote services, or undocumented localStorage persistence.

## Privacy Invariant
Treat every audit-schema field as:
**LOCAL_REFLECTION_DATA**

It must never be passed to:
- analytics
- telemetry
- remote logging
- crash-report metadata
- URLs
- query parameters
- remotely serialized navigation state
- server actions
- API routes

## Analytics Allowlist
Permitted coarse events:
- `choice_audit_viewed`
- `choice_audit_opened`
- `choice_audit_printable_downloaded`
- `choice_audit_current_printed`
- `personal_architecture_map_followed`
- `workshop_return_followed`

Never emit reflection content or individual force content. For v1, do not track which force was opened.

## Internal Conceptual States
**Empty → Active → Connected → Reflected → Revisited**

Never display progress percentages, remaining-section counts, progress bars, or completion rings.

## Desktop Composition
Keep the whole map perceptible with **THE CHOICE** central and all eight force regions visible. Focus expands a region without navigating away from the whole.

No force is visually more important by default.

## Intermediate Composition
Reduce breadth while preserving whole-map awareness. Do not merely scale down desktop geometry.

## Mobile Composition
Use:
- central Choice
- compact all-forces index
- inline force expansion
- route back to whole-map view

Do not shrink the desktop radial field to microscopic size.

Use neutral “contains material” indicators, never completion checkmarks.

## Empty State
**Begin with one choice.**

> It can be large or ordinary, recent or old. You do not need to know yet why you made it.

No forced tutorial.

## Partial-State Validity
Partial use is valid.

Preferred copy:
> Use only the forces that seem relevant.

Blank does not mean incomplete.

## Force Region Structure
Each force includes:
- prompt
- reflection
- optional overlapping classifications: W / E / N / P / ?
- optional qualitative participation mark: • / •• / •••

Required line:
> **Influence, not score.**

## Relationships
v1 may support lightweight reader-authored:
`↔ Interaction`

Do not infer causality or generate connections.

## Then / After / Now
**THEN** — What was true or most salient then?  
**AFTER** — What became visible only afterward?  
**NOW** — What do I see more clearly now?

Chronology must not imply progress or superiority.

## Counterfactual
> **If one of these forces had not been present, how might this have been different?**

This is a thought experiment, not proof of causation.

## Evidence Lens
Heading:
**BEFORE YOU DECIDE WHAT IT MEANS**

Prompts:
- What supports this?
- What might challenge it?
- What else could explain it?
- What remains uncertain?

Hindsight check:
> **Am I reconstructing the decision differently because I know what happened afterward?**

## Reflection Ending
Heading:
**WHAT DO YOU NOTICE?**

Never:
**YOUR RESULTS**

The interface may reflect what the visitor entered, but may not interpret the person.

Preservation:
**What here appears worth preserving?**

Canonical principle:
> **A choice can belong to you without having originated only from you.**

## Larger Architecture Reveal
Only after reflection reveal:
1. Formation
2. Inheritance
3. Recognition
4. Choice
5. Alignment
6. Friction
7. Negative Geometry
8. Influence / Control
9. Becoming
10. Personal Architecture

Actions:
- **Explore the Personal Architecture Map**
- **Return to Workshop**

No price inside the working field.

## Canonical PDF Relationship
Browser-native and PDF versions are two Surfaces of one Artifact.

Required wording:
**Download the Printable Choice Audit**

## Print Contract
`@media print` removes navigation, buttons, persistence indicators, acquisition links, environment, and interaction-only affordances.

Preserve:
- artifact identity
- governing question
- Choice
- eight forces
- entered reflections
- classifications
- influence labels
- relationships
- Then / After / Now
- counterfactual
- Evidence Lens
- preservation
- date
- FluxMintDigital footer

Test color, grayscale, and print-to-PDF.

## Local Save Status
Use:
**Saving locally…**
then
**Saved on this device**

Failure:
> **This audit could not be saved on this device. Your current work is still available in this session.**

No cloud icon, sync language, or green success state.

## Returning Visitor
> **Your previous map is still here on this device.**

Actions:
- Continue
- Start another audit

## Accessibility
Every force needs semantic heading, keyboard focus, associated text field, text labels for states, and non-color meaning.

Logical screen-reader order:
Artifact identity → Privacy receipt → Choice → Desire → Expectation → Security → Opportunity → Identity → Obligation → Fear & Avoidance → Possibility → Relationships → Then → After → Now → Counterfactual → Evidence Lens → Preservation → Reflection → Larger Architecture → Relationship exits.

## Keyboard Acceptance
Keyboard-only use must support all editing, classifications, influence, relationships, reflection fields, print/download, new/delete flows, map navigation, and Workshop return.

## Hover Independence
No required information or control may depend on hover.

## Focus Visible
Every interactive control needs deliberate `:focus-visible` treatment.

## Reduced Motion
Honor `prefers-reduced-motion: reduce`.

When active:
- remove paper movement
- remove light-shift motion
- make scale revelation immediate
- make focus transitions immediate or near-immediate
- preserve all information

## Progressive Enhancement
If JavaScript fails, visitor must still be able to understand the artifact, see the eight forces, access the printable PDF, return to Workshop, and reach the Personal Architecture Map.

## Visual Implementation Boundary
Use:
- cream working surface
- charcoal structure
- restrained bronze-gold orientation
- fine construction geometry
- partial/open boundaries
- deliberate negative space
- reader-content dominance

Reject generic SaaS cards, glassmorphism, neon, dashboard UI, and AI-app styling.

## Known Existing Site Issues to Inspect
- disappearing mobile global navigation
- 768 / 780 breakpoint mismatch
- hover-only hotspot labels
- missing focus-visible hotspot treatment
- missing reduced-motion handling

Do not propagate these into Choice Audit.

## Staged Gates
- CA-000 — Repository Reconnaissance
- CA-001 — Semantic Artifact Shell
- CA-002 — Local Audit Model
- CA-003 — Working Field
- CA-004 — Reflection Architecture
- CA-005 — Responsive Compositions
- CA-006 — Print / Export
- CA-007 — Visual Fidelity
- CA-008 — Accessibility / Privacy Hardening
- CA-009 — Human Acceptance Gate

## Hard PASS Criteria
Production promotion is blocked unless all applicable items pass:
- canonical route works directly
- no authentication
- no email requirement
- no remote reflection persistence
- no reflection content in analytics/network requests
- all eight forces present
- overlapping classifications work
- influence remains qualitative
- partial maps work
- IndexedDB works
- storage-disabled fallback works
- returning local audit works
- keyboard-only use works
- screen-reader semantics are coherent
- focus-visible exists
- mobile is deliberately composed
- no required hover interaction
- reduced-motion works
- canonical PDF downloads
- current audit prints correctly
- grayscale print works
- no clipping at supported sizes
- no scoring/progress/completion UI
- no generated psychological interpretation
- no acquisition CTA inside the working field
- larger map relationship appears after reflection
- Workshop return remains available
- human visual/play-feel review passes

## Required First Action
**Do not start CA-001 before CA-000 has been reviewed and approved.**
