# FluxMintDigital Scene Decomposition Plan

## Governing rule

Separate an element only when interaction, state, animation, reuse, accessibility, or data authority justifies it. Environmental detail, texture, ordinary props, atmospheric shelf filler, and noninteractive furniture remain baked. Truth-bearing text, current catalog facts, lifecycle/availability, relationships, and user-specific state never remain baked.

| Scene | Remains baked in base | Separate asset/component | Justification | Type | Alternate states |
|---|---|---|---|---|---|
| Forest | Path, trees, terrain, distant Studio hints, static light/weather | Live title/CTA; optional ambient treatment only if nonessential | Text/navigation must remain semantic; atmosphere may fail safely | HTML/UI; optional CSS | CTA hover/focus/active; static reduced-motion atmosphere |
| Cabin Exterior | Cabin structure, landscape, path/door geometry, static global illumination | Glow and smoke; live CTA/threshold | Effects animate; entry action must be accessible | CSS preferred; HTML/UI | Ambient idle; reduced-motion static/off |
| Explorer Entry | Architecture, doorway, furnishings, nonfactual props; no required character | Optional Explorer DJ; copy/CTAs; threshold indicator | Character reuse and identity boundary; semantic navigation | Transparent raster character; HTML/SVG UI | Optional overlay/presentation state; CTA states |
| Main Studio | Room shell, ordinary furnishings, environmental work traces, noninteractive décor | Desk/Now; Studio Map; each meaningful room threshold; optional Explorer; semantic fallback | Desk state changes; Map/thresholds navigate; character reuse; fallback resilience | Data + HTML/UI + SVG; raster object/character only where needed | Desk idle/active/current slots; Map/threshold idle/hover/focus/selected; fallback |
| Library | Room shell, shelves, atmospheric books, chair, approved Library pets, lighting | Real publication objects; series UI; room thresholds | Covers/publication facts and availability change; Artifact links require names | Canonical cover raster + HTML/data + SVG/CSS indicators | default/hover/focus; availability handled outside cover |
| Workshop | Room shell, ordinary tools, benches, materials, ambient prototypes with no factual identity | Current-build/workbench objects; one tool-wall region; thresholds; artifact state | Current work changes; collection region is interactive; avoid decomposing every tool | Data/HTML/UI + SVG overlay; conditional transparent raster objects | idle/hover/focus/active; lifecycle state via UI |
| Architecture Wall | Physical wall/room, frames/rails, nonsemantic drafting texture, neutral lighting | Aperture centerpiece; claim/model/evidence/warrant cards; relationship lines; contradiction/status/lineage markers; inspection controls; thresholds | Entire semantic research surface is data/state/accessibility dependent; static raster cannot represent warrant | HTML/data for truth; SVG for nodes/lines/indicators; CSS states | default/focus/selected/contradicted/superseded/candidate as authorized; reduced-motion trace |
| Observatory | Room shell, window/mountains, telescope may remain baked, generic journals/lighting | Telescope hit/indicator or telescope object only if earned; current observation; typed archive cards; thresholds | Current observation and Artifact type/state change; telescope separation conditional | HTML/data/SVG UI; conditional transparent raster telescope | idle/hover/focus/active; archive filter/selected if specified |
| Meeting Table | Room shell, table/furniture, neutral working materials, landscape; no baked person/pet | Intake notebook/brief; project blueprint/map; Main Studio threshold; service/fit content; CTA; optional realistic DJ overlay | Intake/user state and offering truth cannot be pixels; DJ family reusable | HTML/data/UI; conditional raster objects and transparent character | idle/active/completed/error for intake only after workflow decision; CTA states |
| Explorer Outfitters | Room shell, generic atmosphere, nonfactual display fixtures | Representative acquisition objects; Artifact details; availability/channel controls; thresholds | Product identity, availability and external URLs change independently | Canonical product raster + HTML/data + SVG/CSS states | available/unavailable/not-offered; hover/focus; external-channel failure |
| Meet DJ | Grounded pet-free workspace without authority-conferring Wall content; ordinary books/tools | Required realistic illustrated DJ; authorship/about content; optional contact action | Primary human identity, character reuse/consistency and semantic text | Transparent raster character; HTML/UI | Character idle; link states; no mascot substitution |

## Priority object contracts

### Main Studio Desk / Now

- Exactly 3–5 curated current Artifacts, selected from canonical Artifact data—not hardcoded page copy.
- The desk is a temporal surface, not canonical ownership and not a product grid.
- Individual current objects may be transparent raster only when object identity is visually important; labels, lifecycle, availability, and targets remain HTML/data.
- Current curation changes must not rewrite historical records.

Approved maximum initial Main Studio decomposition is: Desk/Now, Studio Map, Library threshold, Workshop threshold, Architecture Wall threshold, Observatory threshold, Meeting Table threshold, Explorer Outfitters threshold, and optional Explorer DJ overlay. The base contains no baked character.

### Studio Map and room thresholds

- Map is a separate orientation object and never replaces conventional global navigation, search, direct URLs, breadcrumbs/location receipts, or return paths.
- Thresholds correspond to physically meaningful access points. Visual hit regions are remapped for each final desktop/mobile composition.
- Implement state indicators as SVG/CSS/components. Do not bake destination names or active state into scene art.

### Library publication objects

- The first real object is *The Architecture of Being Human — Volume I*: Book/Publication; Library; Architecture Series; Volume I; Published; Public. Its approved cover source is pending import and must not be recreated.
- Series sequence, title, publication state, and acquisition are data-driven. Availability UI sits outside the cover raster.
- Current banners are reference evidence; future series presentations may combine canonical raster art with responsive HTML/SVG UI.
- Approved maximum initial Library decomposition is Volume I, Architecture Series access, Walk on the Wild Side access, DJ Field Guide access, and Main Studio threshold. Pets remain baked atmospheric elements.

### Workshop current-build/prototype objects

- Decompose only the small number of visible objects that represent changing “On the Workbench” Artifacts.
- Ordinary tools remain part of the environment. The tool wall exposes at most a meaningful collection region, not dozens of decorative controls.
- Apps and Tools remain within one Workshop Room; type/Division changes the data view, not the Room scene.
- Approved maximum initial decomposition is Current Build, prototype/experiment, justified workstation/tool access, and Main Studio threshold.

### Architecture Wall semantic research UI

- Base scene contains no authoritative claim wording, evidence status, relationship, lineage, or truth state.
- Aperture centerpiece is a functional SVG/component derived from—but not interchangeable with—the corporate mark.
- Claim nodes, evidence cards, warrants/AEG information, contradictions, relationship direction/type, provenance, candidate status, and lineage are generated from canonical data.
- Visual prominence, glow, position, or animation never conveys truth or warrant by itself. Textual/semantic state is mandatory.
- Approved access objects are Aperture centerpiece, framework, research program, experiment/evidence, deeper Architecture Wall application portal, and Main Studio threshold. Detailed claims, evidence cards, AEG/warrant, contradictions, relationships, lineage, confidence, candidate and canonical states remain semantic/data-driven UI rather than raster.

### Observatory current observation

- Telescope remains baked unless it has meaningful movement/reuse/state. An accessible overlay can provide the interaction without extracting the telescope.
- “Current observation” and archive types (Essay, Field Note, Discovery, Workshop Note) are data/UI.
- Article text and reading remain independent of scene behavior.
- Approved maximum initial decomposition is telescope, current Field Note/current observation, and Main Studio threshold.

### Meeting Table intake/problem object

- Base conveys a real problem brought to a collaborative table without encoding a specific client/problem.
- Intake fields, user progress, errors, privacy, fit/status, and CTA destination are HTML/application state.
- Do not produce multiple raster states until the actual intake workflow is authorized.
- Approved maximum initial decomposition is problem/intake notebook or brief, project blueprint/map, Main Studio threshold, and optional realistic DJ overlay.

### Outfitters representative acquisition objects

- Scene may suggest meaningful take-home objects, but only canonical Artifact objects are clickable/factual.
- Lifecycle, visibility, availability, channel health/URL, and price freshness remain separate fields.
- External channels never own identity; a failed channel changes channel UI before Artifact state.
- Approved maximum initial decomposition is representative book, field notebook/resource, map/print, companion-tool representation, and Main Studio threshold.

## Explicit non-decomposition list

Do not separately produce ordinary shelves, every book spine, every workshop tool, generic notebooks, chairs, lamps, plants, windows, mountain views, floor texture, wall grain, or static light pools unless later animation/reuse requirements establish a concrete need. Do not separate Library pets. Do not create animals, pet layers or pet variants in any other canonical production scene.
