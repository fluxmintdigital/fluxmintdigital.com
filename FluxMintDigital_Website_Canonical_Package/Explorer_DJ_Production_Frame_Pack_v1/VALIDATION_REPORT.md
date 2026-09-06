# Explorer DJ Production Frame Validation

**Validated:** 2026-09-06
**Source baseline:** `bbb1c240264cae0b51d99cb1b80b01628c3b2b2b` plus the supplied untracked frame pack
**Public integration:** none

## Regeneration Pack v1.1 review

The 12 expected replacement filenames are present. All have genuine PNG signatures, RGBA channels, and variable transparency. Four are 1024×1024; eight are 1254×1254 and therefore require normalization before they could satisfy the package contract.

Normalized comparison copies were created without altering the supplied replacements. Visual sequence review failed: the regenerated images use a sharper, materially different rendering treatment and inconsistent framing relative to adjacent retained frames. Wave changes from upper-body to full-body framing at frame 5; blink changes face/shoulder scale at frame 4; head turn changes visual treatment and does not connect continuously at frames 3→4 or 6→7. The expression and useful-pose replacements are likewise not interchangeable with the retained family.

No v1.1 replacement was promoted into `frames/`. Their hashes and paths are preserved as rejected evidence in `frame-manifest.csv`; normalized comparisons are quarantined under `quarantine/replacement_candidates_v1_1/`.

Five additional composite source sheets were inspected after the replacement review. They map exactly to the same 12 replacement subjects: four wave frames, one blink frame, three head-turn frames, two expressions, and two useful poses. Each source is a genuine RGBA PNG with variable transparency. They confirm the replacement extractions are faithful, but do not add the adjacent frames needed to make the old and new rendering families continuous. Dimensions, mappings, and SHA-256 hashes are recorded in `replacement-source-manifest.csv`; all five remain evidence-only.

## Result

- Declared records: 52
- Production-ready cleaned frames: 40
- Requires regeneration: 12
- Missing manifest records: 0
- Unexpected production files: 0
- PNG signature failures among production frames: 0
- Dimension failures among production frames: 0
- RGBA/alpha failures among production frames: 0
- Opaque canvas-edge failures among production frames: 0
- Public HTML/CSS/JavaScript references to either Explorer frame pack: 0

Every production-ready output is a genuine 8-bit 1024×1024 sRGBA PNG with transparent canvas edges. Visual contact-sheet review confirms removal of baked filename labels, neighboring-cell fragments, and accidental borders from the accepted set. Character pixels were cropped from the supplied individual source frames without redraw, synthesis, interpolation, or scaling, then registered bottom-center on a fresh transparent canvas.

The original `Explorer_DJ_HighRes_Frame_Pack_v1` remains unchanged. The eleven decodable but unacceptable diagnostic results are stored outside `frames/` under `quarantine/cleaned_previews/`; the twelfth rejected source, `blink_04.png`, is 0 bytes and has no diagnostic image.

## Sequence readiness

| Sequence/group | Ready frames | Declared frames | Result |
|---|---:|---:|---|
| Idle | 12 | 12 | Complete |
| Wave | 4 | 8 | Incomplete; frames 05–08 require regeneration |
| Point | 6 | 6 | Complete |
| Blink | 5 | 6 | Incomplete; frame 04 requires regeneration |
| Head turn | 5 | 8 | Incomplete; frames 04–06 require regeneration |
| Expressions | 5 | 7 | Incomplete master set; frames 03 and 07 require regeneration |
| Useful poses | 3 | 5 | Incomplete master set; frames 03 and 05 require regeneration |

The full package is **not ready for broader Explorer integration** because the declared animation grammar is incomplete. A complete sequence may still be approved independently for a limited context.

## Approved infrastructure; production disabled

The complete 12-frame idle sequence previously validated the reusable Explorer Entry architecture. The integration now remains behind the disabled canonical feature flag in `_config.yml`; no character markup, controller, or delivery frames appear in the production build. Source masters and tooling remain unchanged and excluded. When explicitly enabled against controlled fixtures, the controller loads the selected resolution only near the character region, plays one 1.68-second cycle at 140ms per frame, pauses 9–18 seconds between optional cycles, suspends offscreen/hidden work, cancels timers and animation frames on lifecycle changes, and restores the static frame after a delivery failure.

Reduced motion and no-JavaScript presentations remain static. The character is decorative, unfocusable, `aria-hidden`, and has empty alternative text. Browser validation passed at 1440×1000, 1024×768, 768×1024, and 390×844 with zero horizontal overflow. Blocked-frame simulation returned safely to the static fallback; repeated offscreen/onscreen transitions left no accumulated timers or animation frames; restricted-network testing retained a stable reserved character box.

The infrastructure is ready to receive a newly validated delivery set. Production remains intentionally OFF. This does not change the incomplete status of wave, blink, head-turn, expression, or useful-pose families and does not authorize Explorer elsewhere.
