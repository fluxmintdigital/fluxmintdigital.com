# FluxMintDigital Current Implementation Census

## Scope and evidence boundary

Repository census performed 2026-09-04, read-only with respect to the implementation. Only these six requested evidence documents were added; site source, assets, routes, configuration, dependencies, and build outputs were not changed. No deployed/live comparison was requested or performed. Paths and line references point to current sources.

## Architecture

The site is a Jekyll static site configured for `https://fluxmintdigital.com`, with an empty base URL, Kramdown, Rouge, dated post permalinks, and the `jekyll-feed`, `jekyll-sitemap`, `jekyll-seo-tag`, and `jekyll-paginate` plugins (`_config.yml:1-19`). Content resolves through four layouts:

- `default`: document shell, shared sticky header, eight-link global navigation, four-column footer, CSS/font/SEO/feed inclusion (`_layouts/default.html`).
- `home`: four photo scenes, narrative sections, studio map, compass, and room JavaScript (`_layouts/home.html`).
- `room`: title header, photographic stage, generated percentage-positioned hotspot layer, live panel, supplemental content, and previous/next navigation (`_layouts/room.html`).
- `post`: Observatory article header, calculated reading time, unconditional affiliate disclosure, article content, and tags (`_layouts/post.html`).

The route census is in `FluxMintDigital_Route_and_Surface_Census.csv`; the asset and interaction records are in their corresponding CSVs.

## Exact room/scene asset names

- Forest — `assets/images/rooms/forest_path.jpg`
- Cabin Exterior — `assets/images/rooms/cabin_exterior.jpg`
- Explorer Entry — `assets/images/rooms/explorer_entry.jpg`
- Main Studio — `assets/images/rooms/main_studio.jpg`
- Library — `assets/images/rooms/library.jpg`
- Workshop (Apps and Tools) — `assets/images/rooms/workshop.jpg`
- Architecture Wall/Science — `assets/images/rooms/main_studio.jpg` (shared, not a separately named Architecture Wall image)
- Observatory/Blog — `assets/images/rooms/observatory.jpg`
- Meeting Table/Services — `assets/images/rooms/services.jpg`
- Explorer Outfitters/Store — `assets/images/rooms/store.jpg`
- Meet DJ/About — `assets/images/rooms/architecture_wall_dj.jpg`

No repository reference uses `assets/images/rooms/cabin_exterior.jpg` as a room-stage `<img>`; it is homepage-only. `explorer_entry.jpg` and `forest_path.jpg` are likewise homepage-only.

## DJ / Explorer representations

There are no independently composited DJ sprites, portraits, transparent cutouts, SVG characters, or alternate states. DJ/Explorer is baked into raster artwork:

- `architecture_wall_dj.jpg`: DJ standing at the Architecture Wall; used as About/Meet DJ room image (`about.md:8-16`).
- `field-guide-wild-side-banner.jpg`: promotional banner described as DJ between two illustrated series cards; `<img>` in Library (`books.md:85`).
- `architecture-series-banner.jpg`: promotional banner described as DJ in a lab coat beside five covers; `<img>` in Library (`books.md:89`).
- `explorer_entry.jpg`: filename denotes the entry scene; its front-end scene has no image alt because it is a CSS background (`_layouts/home.html:35-47`). Whether the pixels depict DJ cannot be asserted from source markup alone.

About prose defines the recurring explorer as wearing a backwards hat, blue hoodie, clipboard, and flashlight (`about.md:63-65`). These characteristics are content claims, not separate assets or toggleable outfit states.

## Navigation implementations

- Global header: logo to `/`; Books, Apps, Tools, Science, Services, Blog, Store, About (`default.html:18-35`). Sticky at 64px; full navigation vanishes at 768px with no substitute (`main.css:45-97,661-669`).
- Footer: Explore the Studio, Explore the Ecosystem, and Connect groups. Multiple semantic labels converge on the same division routes. Newsletter is `#`; Contact is email (`default.html:41-79`).
- Homepage controls: scroll cue (noninteractive), `#studio-map`, About CTAs, Architecture Wall link, eight category cards, Services CTA, fixed scroll-reactive compass (`home.html:4-131`).
- Scene/room links: hotspots first open panel content; links inside the panel then navigate. Navigation hotspots do not directly navigate on activation (`room.html:14-19`; `rooms.js:29-66`).
- Previous/next: every room route supplies explicit `prev_href`/`next_href`, rendered at bottom (`room.html:39-42`). The resulting sequence is not a single strict ring: About points back to Blog and forward Science; Store returns Home; Blog points back Services despite Store intervening elsewhere.
- Articles: related links are hardcoded in each Markdown body. There are no automatic previous/next article links, breadcrumbs, location labels on posts, tag archive links, or pagination controls in the Studio Blog template.
- Location labels: room eyebrow and photo caption act as visible location labels; there is no breadcrumb data structure (`room.html:5-9,21-24`).

## Typography

No font files are stored in the repository. Google Fonts CSS references:

- Inter 400, 500, 600, 700, 800: `--font-sans`; global body/UI/header/buttons/labels.
- Fraunces optical size 9..144 at 300, 500, 600, 700: `--font-serif`; scene headings, room/page headings, post titles/body, room card headings.
- Courier Prime 400/700 is requested but no authored CSS uses it.
- Fallbacks: Inter → `system-ui, sans-serif`; Fraunces → `Georgia, serif`; code → browser `monospace` (`default.html:10-12`; `main.css:19-20,429-435`).

Root size is 16px. Evidence-defined size range is 0.60rem room status through clamped 3.25rem hero H1. Principal tokens/rules: logo 1.15rem/800; nav 0.9rem/500; room eyebrow 0.72rem uppercase with 0.12em tracking; scene H1 `clamp(1.7rem,4.4vw,2.6rem)`/500; scene H2 `clamp(1.3rem,3vw,1.9rem)`/500; room H1 `clamp(1.8rem,4vw,2.5rem)`/500; article title `clamp(1.6rem,4vw,2.4rem)`/700; article body 1.05rem at 1.8 line height (`main.css`, `rooms.css`). Sign lettering inside photographs is baked into the JPEGs and is not represented by a font declaration.

## Color, geometry, effects, and motion tokens

Root variables (`main.css:4-22`): `--brand #c9a24b`, `--brand-dark #a9843a`, `--brand-light rgba(201,162,75,.12)`, `--text #f1e7d2`, `--text-muted #cbbfa6`, `--text-light #8a7440`, `--bg #17130f`, `--bg-alt #1f1a15`, `--border #3e2c1c`, radii 8px/14px, max width 1100px, and three multi-layer shadow tokens. There is no spacing scale; spacing is authored ad hoc in rem values and inline styles.

Additional literal colors include logo/accent orange `#e8935a`, footer `#0f0c09`, white, black stage backgrounds, disclosure cream/yellow/brown, green live/navigation states, purple development status, and numerous translucent scrim/glow values. Gradients comprise gold-orange clipped logo/accent text, dark brown hero/CTA backgrounds, three photographic scrims, Cabin radial glow, and the final home scene `#120e0b` to `#16241c`. There are no separate texture files; perceived texture/lighting is baked into JPEGs plus CSS scrims/glow.

Animations are Ken Burns, scroll-cue pulse, Cabin flicker/smoke, reveal-on-intersection, and scroll-driven compass rotation. Details and reduced-motion absence are recorded in `FluxMintDigital_Current_Responsive_Census.md`.

## Content sources and fact representation

- Route/page narrative, room headings, hotspot coordinates, panel content, CTAs, and room navigation: Markdown/HTML plus YAML front matter in root page files.
- Product/app/book/tool/science/service facts: `_data/*.yml`, rendered only in supplemental grids where referenced. Status uses strings such as `coming_soon` and `in_development`; room panel badges separately hardcode phrases such as “Live,” “Coming soon,” “Future,” and “planned.” There is no validation or single lifecycle enum.
- Homepage “today’s focus” and current lane facts: hardcoded in `_layouts/home.html:60-69`, not data-driven.
- Observatory: Markdown files in `_posts`; archive uses `site.posts` (`studio-blog/index.html:14-27`).
- Current blog count “20 essays”: hardcoded twice in `blog.md:43,73`; archive count is not data-derived in prose.
- Commerce availability/marketplaces: narrative and `#` placeholder anchors in `store.md`; `_data` link fields for apps/books are empty and not rendered on room cards.
- No database, API, CMS, client storage, generated JSON content file, or server-side runtime appears in repository evidence. `window.roomContent` is build-generated from page front matter and embedded into each room page (`room.html:45`).

## Observatory inventory

Twenty sources span 2026-03-01 through 2026-07-12, weekly, numbered I–XX. Each preserves full text in its `_posts/*.md` source and declares `layout: post`, explicit title, description, category `[Observatory]`, identical tags `[architecture, curiosity, observatory]`, Roman-numeral `essay_number`, and explicit root-level permalink. Slugs, dates, titles, and related-link counts are enumerated in `FluxMintDigital_Route_and_Surface_Census.csv`; every exact description and relationship target remains directly verifiable in the front matter/body.

The filename date supplies `page.date`; no explicit date field appears in front matter. Post layout shows category, title, date, calculated reading time (word count / 200 + 1), description intro, full body, and tag chips (`post.html:4-35`). It unconditionally shows the same affiliate disclosure on every essay regardless of whether links exist (`post.html:20-22`). No post defines image, author override, updated date, draft/status, excerpt, topic beyond category/tags, Open Graph image, Twitter image, or per-post structured-data override.

## SEO and system infrastructure

- Manual title and description plus `jekyll-seo-tag` output coexist (`default.html:6-7,13`), potentially duplicating title/description metadata.
- `head-custom.html` manually adds author, Open Graph site/type/title/description/url, canonical URL, and Organization JSON-LD on every page (`head-custom.html:4-22`). `jekyll-seo-tag` can emit overlapping canonical/Open Graph/JSON-LD fields.
- No `og:image`, Twitter card/image, favicon, web manifest, theme-color, or repository social image exists.
- `jekyll-feed` provides feed metadata and generated `/feed.xml`; `jekyll-sitemap` generates `/sitemap.xml` (`_config.yml:15-18`; `default.html:14`).
- No `robots.txt` exists. No explicit redirect plugin, HTML meta refresh, JavaScript redirect, Netlify/Vercel redirect file, or server configuration exists. `CNAME` contains the custom host.
- Google Search Console verification is only a commented placeholder (`head-custom.html:1-3`).
- Pagination configuration declares 10 items and `/studio-blog/page/:num/`, but the archive iterates `site.posts`, not `paginator.posts`, and renders no pagination. Generated pagination routes therefore are not evidenced (`_config.yml:29-31`; `studio-blog/index.html:14-27`).

## Implementation seams for canonical Artifact / Surface / Room architecture

These are evidence-backed replacement seams, not redesign recommendations:

1. Room schema seam: eight root Markdown files repeat `room_image`, alt/caption, percentage hotspots, content data, and prev/next fields; one shared layout and one shared JS renderer already consume that schema.
2. Artifact seam: books/apps/tools/science/services have `_data` records, while parallel hotspot tabs and prose duplicate names, descriptions, and lifecycle wording. A canonical Artifact source could feed the existing renderers without altering their public markup.
3. Surface seam: Apps/Tools share identical Workshop image and hotspot geometry; only route identity, supplement data loop, and prev/next differ. Main Studio/Science also share one image across home CSS-background and room `<img>` mechanisms.
4. Navigation seam: header, footer, homepage map, hotspot links, and room sequence encode the same destinations independently in layout HTML/front matter.
5. Article seam: common category/tags/disclosure and hand-authored relationship links repeat across all twenty posts; layout already centralizes visual rendering.
6. State seam: human-facing badges and machine-like `_data` statuses are separate. Placeholder URLs and empty `link` fields are also separate representations of availability.
7. Asset seam: source references know path and alt, but intrinsic metadata/loading policy is distributed between layout and inline HTML rather than an asset record.

No public behavior change is implied by identifying these seams.
