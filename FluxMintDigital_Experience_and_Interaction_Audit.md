# FluxMintDigital Experience & Interaction Audit

**Audit baseline:** `bbb1c240264cae0b51d99cb1b80b01628c3b2b2b`
**Audit date:** 2026-09-06
**Scope:** Public Studio behavior on desktop, tablet, touch/mobile, keyboard, JavaScript-disabled, and reduced-motion paths.
**Disposition:** Audit only. No interaction recommendations in this document have been implemented.

## Executive finding

The current Studio is functionally sound, accessible at its core, and deliberately restrained. Its strongest interaction pattern is the pairing of spatial scene hotspots with conventional semantic navigation. The site remains usable without decorative motion and, except for client-side Search and the local Meeting Table draft state, without JavaScript.

The main experiential weakness is not a lack of animation. It is that the interaction vocabulary is nearly identical everywhere: marker, label, slight lift, immediate navigation. That makes distinct Rooms feel mechanically similar. The highest-value next step is to strengthen functional orientation and state—especially Main Studio hotspots, Desk/Now, Studio Map, and the compact Explore menu—before adding atmosphere.

An Explorer DJ frame pack was supplied after the initial repository audit at `FluxMintDigital_Website_Canonical_Package/Explorer_DJ_HighRes_Frame_Pack_v1/`. It establishes useful character poses and an intended animation vocabulary, but the pack does **not** currently pass production packaging validation: `animations/blink/blink_04.png` is an empty 0-byte file, and visual sampling exposes source-sheet residue/cropped neighboring figures and baked filename labels in multiple exported frames. The pack is valid identity and motion-grammar evidence, not yet a public implementation asset. Explorer Entry scene masters remain present, while the earlier optional Explorer Entry and Main Studio character-raster concepts are recorded as `NO LONGER REQUIRED` in the master manifest. Nothing in this audit reinstates those old requirements or authorizes implementation.

## Classification

- **Functional:** required to navigate, disclose, enter, search, draft, select, or understand state.
- **Atmospheric:** creates a physical or inhabited response but carries no required information.
- **Discovery:** rewards intentional exploration or reveals useful context that remains available conventionally.

One interaction can contain more than one layer. Its required action is classified Functional; an optional response attached to it may be Atmospheric or Discovery.

## Current interaction inventory

| Surface | Current behavior | Class | Pointer / desktop | Touch / mobile | Keyboard | Reduced motion / no JS | Assessment |
|---|---|---|---|---|---|---|---|
| Skip link | Hidden until focused; moves focus to the main content landmark | Functional | Not normally visible | Available to external-keyboard users | Clear focus reveal | Motion collapses to effectively instant | Strong and conventional. Preserve. See `_layouts/default.html:21`, `assets/css/canonical.css:38-40`. |
| Brand/home link | Aperture lockup returns to Main Studio | Functional | Standard link | Standard tap target | Standard focus ring | Fully static and independent of JS | Clear and appropriately conventional. `_layouts/default.html:23-27`. |
| Wide global navigation | Persistent semantic links; current page receives `aria-current` and an underline | Functional | Color change on hover | Links remain visible at wide touch layouts | Focus matches hover; current page remains distinct | No required animation | Strong. The subtle current-state receipt is worth preserving. `_includes/studio-navigation.html:1-11`, `assets/css/canonical.css:47-49`. |
| Compact Explore menu | Native `<details>` disclosure containing the same navigation | Functional | Summary opens the panel | One-tap disclosure, then one-tap destination | Native summary operation and visible focus | Works without JS; reduced motion has no information loss | Robust baseline, but open/closed affordance and dismissal feel abrupt. It does not close on outside click or Escape by design of plain `<details>`. `_layouts/default.html:28-32`, `assets/css/canonical.css:80`. |
| Breadcrumb/location receipt | Conventional linked hierarchy with current item | Functional | Standard links | Standard links | Visible focus | Static | Excellent orientation fallback; should not become animated. `_layouts/default.html:36-38`, `_includes/breadcrumbs.html:1-22`. |
| Forest → Cabin → Explorer Entry | Full-scene stages with clear CTA links and conventional orientation below | Functional, Atmospheric | Buttons respond with color and pressed offset | Actions stack on narrow screens | Visible focus, logical source order | Usable without JS; reduced motion removes transition duration | Strong spatial sequence, but each navigation is currently a hard page cut. `_includes/entry-journey.html:1-21`, `assets/css/canonical.css:297-298`. |
| Buttons and primary links | Background change on hover and 1px pressed movement | Functional | Clear hover/active feedback | Pressed offset supplies small tactile cue | Strong shared focus ring | Active transform becomes effectively instant | Restrained and consistent. `assets/css/canonical.css:40-42`. |
| Main Studio Desk/Now | Named native `<details>` panel; derives up to five public current Artifacts from placement data | Functional, Discovery | Click disclosure; plus/minus state | Tap disclosure; panel overlays scene | Native summary focus and operation | Works without JS; data remains semantic | Strong foundation. Content is current, but presentation feels like a static drawer rather than a living desk. `_includes/main-studio-scene.html:15-35`. |
| Main Studio Map | Named native `<details>` panel; opens conventional Room navigation | Functional | Click disclosure | Tap disclosure; single-column Room links | Native focus and links | Works without JS | Complete but duplicates a list without adding spatial orientation or current-position meaning. `_includes/main-studio-scene.html:37-44`. |
| Named Studio panels | `name="studio-panel"` requests accordion-like mutual exclusion | Functional | Opening one closes the other in supporting browsers | Same | Native disclosure | Gracefully degrades to independently open panels if unsupported | Good progressive enhancement; do not replace with a custom disclosure unless testing finds a real compatibility defect. |
| Main Studio Room thresholds | Six positioned semantic links with marker glow and labels | Functional, Discovery | Label/marker intensify on hover | Marker is tappable, but the hidden mobile label cannot provide a reliable preview because the same tap navigates | Focus reveals label and gets global outline | Conventional Room navigation and `<noscript>` fallback remain; motion collapses | Largest current modality gap. The action works, but touch users get less spatial meaning before navigation. `_includes/main-studio-scene.html:47-63`, `assets/css/canonical.css:71-82`. |
| Room-scene hotspots | Positioned links for Room-specific objects/categories plus Main Studio return | Functional, Discovery | Glow, scale, and slight label lift | Labels generally remain present in dedicated mobile compositions; secondary label text is suppressed at narrow widths | Same visible labels and focus ring | Static glow; conventional navigation below every scene | Strong accessible architecture. Repeated identical behavior across Rooms slightly flattens Room personality. Representative: `_includes/explorer-outfitters-scene.html:13-17`, `assets/css/canonical.css:271-276`. |
| Conventional Room navigation/exits | Room cards, related exits, and Main Studio return links below scenes | Functional | Border/background or standard link response | Cards/links reflow and stack | Fully operable and visibly focused | Static, JS-independent | Essential strength. It makes spatial interaction optional rather than mandatory. `_includes/room-navigation.html:1-6`, `assets/css/canonical.css:63-64`. |
| Artifact summary cards | Cover or text card; title is the primary link; status is displayed semantically | Functional | Some featured cards lift on hover/focus; generic summaries remain restrained | Direct title link | Title receives visible focus | Static content; images lazy-load | Clear and appropriately conventional. Avoid turning entire dense cards into ambiguous mega-links. `_includes/artifact-summary.html:1-14`, `assets/css/canonical.css:57-59`. |
| Artifact detail and Series links | Conventional detail, lineage, related Artifact, home Room, and Relationship Explorer links | Functional | Standard link behavior | Standard | Visible focus, semantic reading order | Static | Correct place for truth-bearing state. Keep motion away from lifecycle and lineage. `_layouts/artifact.html:25-73`. |
| Search | Explicit-submit local filtering; URL query is updated; results and empty state are announced | Functional | Form submit creates result cards immediately | Controls stack on narrow screens | Label, input, button, and live status are keyboard-accessible | Requires JS for filtering; without JS the form has no server-side results path | Clear, fast, and honest. No loading state is needed because there is no network request. The no-JS experience is the principal limitation. `search.md:13-18`, `assets/js/studio-search.js:1-50`. |
| Relationship Explorer | Ordered list of source → relationship type → target, with provenance note and conventional exits | Functional, Discovery | Link hover/focus only | Single-column records | Fully operable | Static and JS-independent | Semantically excellent but visually closer to a directory than an explorer. Direction is correctly not presented as causation. `relationships.md:7-20`, `assets/css/canonical.css:292-294`. |
| Architecture Wall disclosures | Native details expose state-axis and AEG explanatory material | Functional | Click disclosure | Tap disclosure | Native keyboard behavior | Static, JS-independent | Appropriate restraint in a technical context. State, warrant, contradiction, and lineage must remain non-theatrical and data-led. `architecture-wall.md:46-60`, `_includes/aeg-assertion-kinds.html:1-30`. |
| Meeting Table local draft | Native form validation plus a custom consolidated error, focused success state, and reset | Functional | Checked choices receive material response; submit/reset are conventional | Touch targets and stacked actions | Errors and result receive focus; invalid field is marked | Requires small JS enhancement; nothing is transmitted | Strong privacy-preserving contract. No loading state is appropriate because no backend exists. Reset is immediate but low risk because the draft remains local. `meeting-table.md:10-49`, `assets/js/meeting-table-intake.js:1-35`. |
| Outfitters availability | Listings derive from canonical placements; current empty state states that nothing is for sale | Functional | Standard links only | Standard links; stacked actions | Fully operable | Static | Correctly avoids fabricated commerce. Environmental props are not controls or inventory. `explorer-outfitters.md:10-30`. |
| Meet DJ | Independent decorative realistic-DJ layer; semantic identity and pathway links carry meaning | Functional, Atmospheric | Character does not react; links remain conventional | Character repositions without blocking controls | Identity is complete before the decorative image | Character is `aria-hidden`; reduced-motion treatment is static | Correct. The realistic DJ should not become a waving mascot or interactive authority cue. `meet-dj.md:7-42`, `_includes/meet-dj-scene.html:1-25`. |
| Footer navigation | Repeats useful paths, contact, and Studio orientation | Functional | Standard links | Stacked/reflowed layout | Standard focus | Static | Should remain completely conventional. `_layouts/default.html:41-73`. |
| Empty, unavailable, 404, fallback | Plain explanation plus recovery links | Functional | Standard links | Standard links | Standard focus | Static and resilient | Correctly calm. These states should not punish or entertain a blocked visitor. `unavailable.md:1-10`, `technical-fallback.md:1-11`, `404.html:1-20`. |
| Loading state | No public interaction currently performs an asynchronous network operation | Functional | N/A | N/A | N/A | N/A | Absence is correct. Do not add simulated loading. |

## Strengths worth preserving

1. **Spatial and semantic navigation share one ontology.** Every major scene offers semantic links and a conventional path beneath or alongside it.
2. **Native controls do most of the work.** Links, forms, buttons, and `<details>` preserve browser behavior and progressive enhancement.
3. **Truth does not depend on the scene.** Lifecycle, availability, relationships, warrant, and current placement are HTML/data, not raster interaction.
4. **Keyboard focus is unusually consistent.** A shared 3px focus treatment applies to links, buttons, summaries, and fields (`assets/css/canonical.css:40`).
5. **Touch sizing and narrow-layout fallbacks are established.** The 44px target token, single-column mobile cards, stacked controls, intrinsic-width safeguards, and anchor offsets from the approved Mobile Presentation Pass remain intact (`assets/css/canonical.css:303-358`).
6. **Reduced motion is global and defensive.** Animation and transition duration collapse, smooth scrolling is disabled, and hotspot markers retain a static affordance (`assets/css/canonical.css:82` and Room-specific reduced-motion rules).
7. **The site does not fake latency or commerce.** Search is synchronous, Meeting Table is explicitly local, and Outfitters does not invent channels.

## Problems ranked by severity

### High

No issue currently prevents completion of a required public task. The following is the highest-priority experiential/accessibility-equivalence issue, but conventional navigation keeps it below blocker severity.

1. **Main Studio mobile threshold labels do not have a dependable touch preview.** At widths below 768px labels are hidden until `:hover` or `:focus-visible`, while the hotspot itself is a direct anchor. A touch activation commonly navigates immediately. The accessible name and conventional Room list preserve function, but the spatial scene withholds destination meaning from sighted touch users before activation. Evidence: `assets/css/canonical.css:81`.

### Medium

1. **Room transitions are mechanically abrupt.** Thresholds suggest physical passage, but navigation resolves as an ordinary page cut. Spatial continuity is promised visually and not acknowledged behaviorally.
2. **Desk/Now is current in data but static in feeling.** It exposes the right records without communicating why these are “on the desk” now, when the selection changed, or which item is most active. No date should be invented; the opportunity depends on existing placement/state data.
3. **Studio Map is complete but weak as orientation.** It repeats Room links without showing “you are here,” the Room verbs as a navigational decision aid beyond small labels, or the relationship between the visible thresholds and the list.
4. **Compact Explore disclosure is abrupt and minimally expressive.** Native `<details>` is robust, but the summary provides little visible open-state cue beyond the revealed menu and has no optional outside-click/Escape enhancement.
5. **Hotspot response is highly uniform.** Nearly every Room uses the same glow/scale/lift grammar. Consistency is valuable, but total uniformity makes reading, building, examining, noticing, collaborating, and taking feel like reskinned menu choices.

### Low

1. **Relationship Explorer does not visually trace a selected connection.** Its list is semantically clear, but focus or hover does not help the eye hold source, relationship, and target together.
2. **Search has no non-JavaScript result path.** The rest of the Studio remains navigable and all records are reachable conventionally, so this is resilience debt rather than a release blocker.
3. **Meeting Table reset is immediate.** A mistaken reset loses only a local draft and performs no external action. Confirmation would probably add more friction than safety unless real-device review shows repeated mistakes.
4. **Named `<details>` exclusivity is enhancement-dependent.** Browsers without support for the `name` behavior can open both panels. Content remains usable, so no custom accordion is justified solely for parity.

## Opportunities ranked by experiential value

| Rank | Opportunity | Class | Meaning revealed | Proposed response | Complexity | Risk |
|---:|---|---|---|---|---|---|
| 1 | Main Studio touch threshold clarity | Functional | What each physical threshold leads to | On coarse pointers, keep concise destination labels persistently legible or provide an explicit scene-explore mode with a clear exit. Do not use a surprise two-tap link contract. | Low–Medium | Label collisions on 390px compositions; must preserve approved subjects. |
| 2 | Studio Map orientation state | Functional, Discovery | Where the visitor is and how Room verbs differ | Synchronize map entries and visible scene markers on hover/focus/selection; retain the existing list as the source of navigation truth. On touch, selecting a map entry may highlight its marker before following a separate conventional link. | Medium | Avoid creating two competing navigation models or trapping focus in the scene. |
| 3 | Desk/Now presence | Functional, Atmospheric | What DJ is actively reading, building, examining, or noticing | Give the opened desk a restrained lamp/material response and clearly identify the current placement using data that already exists. If no freshness metadata exists, say only what the data supports. | Low–Medium | A pulsing “live” treatment would falsely imply real-time status. |
| 4 | Threshold continuity | Atmospheric, Functional | That a visitor is moving between connected Studio spaces | Use a short progressive-enhancement exit/entry luminance or depth transition. Navigation must start immediately when unsupported and reduced motion must use an instant state change. | Medium | Delayed navigation, bfcache regressions, motion sensitivity, or “game loading screen” behavior. |
| 5 | Compact Explore state polish | Functional | Whether navigation is open and where focus should return | Add a clear CSS open-state indicator; optionally enhance outside-click and Escape dismissal while retaining native `<details>`. | Low | Custom behavior can regress native semantics if overbuilt. |
| 6 | Relationship trace | Discovery | Which two Artifacts a typed relationship connects | On hover/focus, visually hold the source, relationship label, and target as one row. A future graphical view may be optional, never the only representation. | Low | Animated lines can imply causation or importance; avoid them. |
| 7 | Room-specific material responses | Atmospheric | The Room's verb without extra exposition | Use one restrained response per Room only when attached to an existing control: page/lamplight for Read, tool-bench illumination for Build, crisp aperture focus for Examine, horizon/telescope light for Notice, table light for Collaborate, shelf/tag light for Take. | Medium | Inconsistent assets, over-animation, or raster features mistaken for controls. |
| 8 | Explorer Entry cameo pilot | Discovery, Atmospheric | The Explorer is a guide into the experience, not its author | After the supplied frame pack is repaired and implementation frames are explicitly approved, allow a user-invoked or single restrained entrance/orientation appearance at Explorer Entry. It must never block the Enter Studio action. | Medium–High | The current pack has a missing frame and visible extraction residue; repetition would turn the Studio into a game menu. |
| 9 | Forest threshold environmental response | Atmospheric, Discovery | The path is intentional and the cabin is inhabited | A small, non-looping light or depth response on focus/hover/explicit touch exploration can reward noticing. | Low–Medium | Full-scene parallax or continuous particles would compete with the composition and consume mobile resources. |

## Proposed interaction grammar

### Functional grammar

- Immediate, conventional, and reversible where possible.
- Use links for destinations, buttons for state changes, and native disclosures for expandable content.
- Visible hover, focus, active/pressed, selected/current, expanded/collapsed, validation, empty, unavailable, and error states must not rely on motion alone.
- Typical response duration: 80–160ms. Navigation must never wait for an animation to finish.
- Functional targets remain at least 44px. Focus stays high-contrast and is never replaced by glow alone.
- Live data determines labels and state; environmental pixels never do.

### Atmospheric grammar

- Low amplitude, low frequency, and subordinate to reading and navigation.
- Prefer targeted illumination, material depth, or a single environmental response over object movement.
- Typical response duration: 180–400ms. No perpetual bounce, pulse, camera drift, cursor trail, ambient sound, or particle field.
- Atmospheric behavior may disappear entirely on touch, low-power contexts, failed JavaScript, or reduced motion without loss.
- Avoid whole-scene parallax on mobile. If pointer parallax is ever approved, cap displacement tightly and never move semantic overlays out of alignment with their landmarks.

### Discovery grammar

- Scarce, intentional, and attached to curiosity—not required task completion.
- Prefer explicit visitor action or a once-per-context reveal. Do not build streaks, collectibles, badges, progress meters, or hidden required routes.
- Any revealed meaning also exists in the DOM and is reachable conventionally.
- Discovery state should reset safely and should not become a canonical fact merely because a visitor found it.

## Modality contract for proposed interactions

| Class | Desktop pointer | Touch/mobile | Keyboard | Reduced motion |
|---|---|---|---|---|
| Functional | Hover may preview; click performs the action | A first tap must have an obvious result. Do not translate hover into an invisible precondition | Focus exposes the same label/context; Enter/Space follows native semantics | State changes instantly; all information remains visible |
| Atmospheric | May respond subtly to hover or fine-pointer position | Prefer explicit tap-associated response or omit it; never run continuous scene motion | Only respond when a semantic control is focused; decorative regions are not focusable | Use a static light/color/depth state or no response |
| Discovery | Hover may hint, but click reveals | Use a labeled control or clearly optional scene-explore mode | The same reveal is operable and dismissible in logical order | Reveal without travel, zoom, parallax, or looping animation |

Mobile is a separate interaction composition. Persistent short labels, an explicit disclosure, or conventional navigation are valid mobile solutions; hover emulation is not.

## Explorer DJ integration

### Appropriate opportunities

1. **Explorer Entry — strongest and recommended pilot.** A rare optional guide/orientation appearance fits the threshold between exterior journey and Studio. It should be user-invoked or a restrained one-time entrance, and the page must remain complete without it. The supplied pack's wave grammar is conceptually appropriate here once the frames pass packaging and visual cleanup.
2. **Main Studio Map — conditional second use.** The Explorer could point out how the Rooms relate only while the Map is deliberately open. This is orientation, not authorship or authority.
3. **Forest — small discovery moment.** A distant, nonverbal trace or brief environmental response could reward curiosity if an approved asset and behavior are supplied. It should not become a mascot hunt.

### Places Explorer DJ should not appear

- **Architecture Wall:** a character near claims, evidence, confidence, contradictions, or AEG state could imply endorsement or authority.
- **Meeting Table:** collaboration belongs to real DJ and the visitor; a stylized guide would weaken the human intake contract.
- **Meet DJ:** realistic DJ is the Person identity. Explorer may be explained in copy, not layered as an equal identity.
- **Artifact, Series, and Observatory article pages:** authorship and long-form reading should remain conventional and unambiguous.
- **Library:** the approved personal animals already supply atmosphere; another character would clutter the reading identity.
- **Explorer Outfitters:** repeated character use risks mascot merchandising and conventional storefront behavior.
- **Search, Relationship Explorer, archive, unavailable, technical fallback, and 404:** these are utility/recovery contexts and should remain calm and direct.
- **Workshop workbench:** do not place Explorer where it could be mistaken for the builder or project owner. A threshold-only appearance would still need a strong reason.

### Existing asset/grammar status

- The supplied `Explorer_DJ_HighRes_Frame_Pack_v1` declares 52 transparent 1024×1024 RGBA PNG frames: 12 idle, 8 wave, 6 point, 6 blink, 8 head-turn, 7 expression, and 5 useful-pose frames. Fifty-one parse as 1024×1024 PNGs with variable alpha; `animations/blink/blink_04.png` is empty and fails PNG decoding.
- The pack README accurately discloses that frames were extracted and resampled from a generated composite master sheet. A 1024×1024 canvas therefore does not equal 1024×1024 source detail.
- Visual sampling found inconsistent subject scale/crop, neighboring-frame fragments at canvas edges, and baked source filename text beneath several figures. Those defects would be conspicuous in a public frame animation and can cause visible jitter or residue.
- `implementation/explorer-dj-animation.js` is a useful proof of timing intent, not production-ready runtime code. It honors reduced motion and preloads frames, but it has no cancellation/cleanup, visibility pause, decode strategy, error recovery, or lifecycle management; an infinite loop also leaves its returned Promise unresolved.
- The pack is therefore **motion-grammar/reference evidence, validation failed for implementation**. It is preserved unchanged. A separate deterministic cleanup package now exists at `FluxMintDigital_Website_Canonical_Package/Explorer_DJ_Production_Frame_Pack_v1/`: 40 of 52 declared frames pass production validation, while 12 are quarantined as `REQUIRES_REGENERATION`. No cleaned frame is referenced by the public site.
- `FluxMintDigital_Scene_Decomposition_Plan.md:11-12,30` describes Explorer overlays as optional.
- `FluxMintDigital_AAA_Asset_Master_Manifest.csv:114-115` marks the earlier Explorer Entry and Main Studio optional character-raster concepts `NO LONGER REQUIRED` for the initial implementation. Supplying a reference pack does not silently reverse those decisions.
- The useful grammar is now concrete: restrained idle, blink, head turn, wave, point, expressions, and static useful poses. Recommended initial use remains a single wave or calm idle at Explorer Entry; pointing belongs only to an explicitly open orientation aid such as Studio Map. Blink/head-turn loops should be rare and should stop when the document is hidden. Expressions and poses require individual semantic review before use.

## Explicit do-not-animate recommendations

- Architecture Wall claims, evidence, confidence, contradiction, validity envelopes, provenance, lineage, governance/review, lifecycle, canonical state, or independent Alignment/Equivalence/Generation warrants.
- Lifecycle, visibility, availability, price, acquisition channel, publication status, or other truth-bearing facts anywhere.
- Relationship direction in a way that implies causation, flow, importance, or confidence.
- Observatory essay prose, long-form reading position, citations, or metadata.
- Search-result order or counts as theatrical movement; results should appear promptly and predictably.
- Meeting Table validation errors, success text, or privacy explanation beyond an immediate accessible state change.
- Footer, breadcrumbs, legal/system recovery links, unavailable state, technical fallback, and 404 recovery.
- The realistic DJ character. It is identity imagery, not a talking avatar or conversion device.
- Library animals. They remain atmospheric parts of the approved composition, not independent mascots.
- Whole-scene camera pans, scroll-jacking, forced zooms, transition interstitials, simulated loading, looping hotspot pulses, sound, confetti, cursor trails, physics, achievements, or collectible discovery systems.

## Complexity and risk controls

- **Low risk:** CSS open/current/focus state polish; persistent mobile labels; row-level Relationship Explorer emphasis; static reduced-motion alternatives.
- **Medium risk:** synchronized Map/scene selection; data-derived Desk/Now emphasis; Room-specific environmental responses; progressive page-transition enhancement.
- **High risk:** touch scene modes, parallax tied to scene coordinates, cross-document transition orchestration, or any Explorer character animation. These require real-device performance, focus, history-navigation, and reduced-motion testing.
- **Asset risk:** The broader Explorer grammar remains blocked on the 12 exact records in `Explorer_DJ_Production_Frame_Pack_v1/REGENERATION_REQUIRED.md`. Regeneration Pack v1.1 supplies clean standalone illustrations, but normalized transition review shows material style/framing discontinuities with neighboring retained frames, so none were promoted. The reusable Explorer Entry controller, gated component, responsive delivery contract, static/reduced-motion fallback, viewport/visibility suspension, and failure recovery are preserved behind a canonical feature flag that defaults OFF. Current derivatives are not emitted publicly. Future activation requires validated replacement visuals plus a deliberate flag change. Wave, blink, head turn, expressions, useful poses, Main Studio, and every Room remain outside the implementation.
- **Semantic risk:** atmospheric responses must never make one Artifact, relationship, Room, claim, or availability state appear more true or important than its data says.
- **Technical policy:** existing CSS and small vanilla JavaScript are sufficient for all recommended first-pass behavior. No animation framework is justified.

## Recommended implementation sequence

1. **Functional equivalence first:** resolve Main Studio touch-label clarity; add compact Explore open-state clarity; verify focus, Escape, and history behavior without replacing native controls.
2. **Orientation:** synchronize Studio Map entries with scene thresholds and current-location language while keeping the conventional list authoritative.
3. **Temporal meaning:** refine Desk/Now using existing placement/lifecycle data and a restrained opened-state material response.
4. **Shared threshold grammar:** prototype one immediate, nonblocking, reduced-motion-safe spatial continuity response; validate navigation timing and bfcache before applying it across Rooms.
5. **Room-specific restraint:** add at most one meaningful material response per Room, starting with the existing primary access object. Review all Rooms together to prevent accumulation.
6. **Relationship discovery:** add row-level source/type/target emphasis without replacing the ordered semantic list or implying causation.
7. **Explorer pilot last:** only after the supplied pack passes frame-level packaging and visual validation, prototype Explorer Entry in isolation. Approve its frequency, dismissal, mobile behavior, reduced-motion still state, loading budget, and offscreen/hidden-document pause before considering Main Studio Map use.
8. **Regression gate:** test desktop, tablet, coarse-pointer touch, keyboard-only, screen-reader reading order, reduced motion, no-JS, low-power mobile, back/forward navigation, overflow, and all conventional fallbacks. Remove any enhancement whose failure obstructs meaning or navigation.

## Audit conclusion

The Studio does not need more motion everywhere. It needs clearer interaction state in a few high-value places, followed by a small number of Room-specific physical responses. Main Studio touch orientation, Studio Map, and Desk/Now provide the best return with the least risk. Explorer DJ should remain rare; the supplied frame pack now establishes the intended grammar but cannot enter implementation until its objective packaging and extraction defects are corrected and the resulting frames are approved. Architecture Wall truth, long-form reading, utility surfaces, failure states, and real-person identity should remain deliberately conventional.
