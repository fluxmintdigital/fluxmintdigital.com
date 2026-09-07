# CA-000 — Repository Reconnaissance Only

You are entering an existing FluxMintDigital codebase with a locked architecture for a new Workshop artifact called the Choice Audit.

Do **not** implement the Choice Audit yet.

Your first task is reconnaissance only.

Read the handoff documents in the package I provide, then inspect the repository and report back with evidence for:

- current route structure and Workshop ownership patterns
- existing artifact-page conventions
- breakpoint definitions and the known 768/780 mismatch
- mobile global-navigation behavior
- hover-only hotspot behavior
- focus-visible implementation
- reduced-motion handling
- typography and material/design-token usage
- current Workshop environmental assets
- analytics/telemetry architecture
- local persistence/storage conventions
- print styles and PDF/download patterns
- accessibility utilities and semantic conventions
- existing component boundaries that the Choice Audit should inherit rather than duplicate
- any architectural conflicts between the repository as implemented and the locked Choice Audit contracts

Do not rewrite canonical copy.

Do not create new routes, components, styles, schemas, storage code, analytics events, or assets.

Do not “fix” unrelated repository issues during reconnaissance.

Do not infer missing architecture when repository evidence is available.

Return:

1. **Repository Evidence Report**
2. **Choice Audit Integration Map**
3. **Known Conflicts / Required Decisions**
4. **Proposed CA-001 implementation plan**
5. **PASS / HOLD recommendation for beginning CA-001**

Treat the handoff package as the governing architecture. Where the repository conflicts with the handoff, document the conflict rather than silently choosing one side.

I will separately place the canonical cover image and final Personal Architecture Map PDF into the designated source-assets folder. Do not substitute screenshots or regenerate those assets.

Stop after CA-000 and wait for human review.
