# FluxMintDigital Migration Risks and Contradictions

This document records evidence conflicts and loss risks only. It makes no KEEP/REFINE/REBUILD or redesign decision.

## High-confidence contradictions

1. **Architecture Wall asset naming versus use.** Science/Architecture Wall uses `main_studio.jpg` (`science.md:8`), while the only filename containing “architecture_wall” is `architecture_wall_dj.jpg`, used by About (`about.md:8`). A filename-driven migration could swap or misclassify these scenes.
2. **Blog count is hardcoded.** “20 essays” appears in hotspot data and supplement prose (`blog.md:43,73`) while the archive dynamically iterates posts. The count will stale if post inventory changes.
3. **Pagination configured but not implemented by the archive.** `_config.yml:29-31` promises 10-item pagination, but `studio-blog/index.html:14-27` reads all `site.posts` and never references `paginator`; `/studio-blog/page/:num/` is configuration intent, not an evidenced current route.
4. **Post date metadata is implicit.** Dates are encoded in filenames, while front matter has no `date`. A content migration that reads only YAML will lose dates.
5. **SEO emission overlaps.** Handwritten title/description/Open Graph/canonical/Organization JSON-LD and `jekyll-seo-tag` are both enabled (`default.html:6-14`; `head-custom.html:4-22`), creating possible duplicate/conflicting metadata.
6. **Affiliate disclosure is unconditional.** Every post receives an affiliate disclosure (`post.html:20-22`) even though the current essays’ relationship links are internal; disclosure behavior is layout-wide, not article metadata.
7. **Responsive navigation gap.** At 768px the entire eight-link navigation becomes `display:none` with no mobile menu (`main.css:661-669`; `default.html:24-33`).
8. **Breakpoint mismatch.** Header behavior changes at 768px, room stage at 780px, leaving 769–780px with desktop room geometry but no global nav.
9. **Status vocabularies diverge.** `_data` uses `coming_soon`/`in_development`; panels and prose use “Live,” “Coming soon,” “Future,” “planned,” “Print-on-demand — planned,” and “Live · 20 essays.” No canonical lifecycle source exists.
10. **Store links contradict marketplace prose.** Store promises eventual Amazon, Google Play, and Etsy destinations but all rendered commerce CTAs are `#`, while data `link` fields are empty (`store.md:35-65`; `_data/apps.yml`; `_data/books.yml`).

## Visual-experience loss risks

- Hotspot objects are pixels baked into scene photographs; only hit rectangles, labels, and panel content are separate. Replacing a background without retaining coordinate/object correspondence breaks meaning even when routes survive.
- Apps and Tools intentionally use the exact same `workshop.jpg` and hotspot geometry. Treating routes as unrelated pages would lose the “one room, two divisions” continuity (`apps.md:7-36`; `tools.md:7-36`).
- Main Studio serves both a homepage background and the Science room stage through different rendering mechanisms and crop rules. Homepage uses `cover center`; Science shows the complete `<img>`.
- Observatory is the only 1400x1120 room source; all other room JPEGs are 1400x933. Assuming a universal room aspect ratio changes its geometry/hotspot placement.
- DJ has no separable character layer. About and both book-banner representations are baked, so character extraction or outfit-state inference is unsupported by the repository.
- Scene lighting/motion is partly CSS, not only image pixels: three scrims, Cabin glow, smoke, Ken Burns, reveal, and compass behavior (`rooms.css:26-58`). Asset-only migration would omit them.
- Hotspot labels are hover-only. Touch and keyboard activation work through JavaScript, but labels do not become visible on focus/active; any census based only on screenshots may miss their names.
- Homepage copy initially has opacity zero and depends on IntersectionObserver. If JavaScript fails or observer support is absent, `.reveal` content remains hidden.

## Orphan, duplication, obsolete, and legacy evidence

- **No orphan raster files found:** all twelve repository images have at least one reference. There are no duplicate byte-identical visual files evidenced by name/reference inventory; semantic reuse exists for `workshop.jpg` and `main_studio.jpg`.
- **Unused CSS/dead-style candidates:** `main.css` contains older/general structures not found in current templates/content, including `.hero`, `.featured-cats`, `.latest-posts`, `.pagination`, `.page-body`, `.page-section`, `.feature-grid/.feature-card`, `.hero-ctas`, `.cta-banner`, `.lane-grid`, `.contact-block`, and status badge variants. `rooms.css` defines `.photo-tag` and room status classes without current markup references. These are selector-reference findings, not proof that downstream/generated consumers never use them.
- **Unused font request:** Courier Prime is downloaded by the Google Fonts URL but has no authored `font-family` use (`default.html:12`).
- **Legacy external destination:** Work-at-Home Equipment Blog is `https://fluxmintdigital.github.io/`, linked from the Observatory twice and described as live (`blog.md:35-39,73-74`).
- **Legacy naming split:** public labels use Books/Apps/Tools/Science/Services/Blog/Store/About while spatial names use Library/Workshop/Architecture Wall/Meeting Table/Observatory/Explorer Outfitters/Meet DJ. This is intentional current evidence and must not be normalized implicitly.
- **Root post permalinks differ from configured date pattern.** Each post’s explicit root permalink overrides `_config.yml:12`; removing explicit values would silently produce dated URLs.
- **`essay_number` is not rendered.** Roman numerals I–XX exist in post metadata but neither post layout nor archive displays them.
- **Data fields not rendered:** app/book `status`, `tagline`, and `link` fields are not used by current room-series loops, which render only name/description (`apps.md:85-88`; `books.md:92-95`). Tool `examples` and science `status` similarly are absent from their basic supplemental rendering where only selected fields are used.

## Route and navigation risks

- No redirect definitions or legacy aliases exist. Any old inbound route outside the explicit census falls to hosting-level behavior/404; repository evidence cannot preserve unknown redirects.
- `404.html` uses an explicit file-style URL rather than `/404/` (`404.html:5`). Hosting may serve it for misses, but that is platform behavior rather than a route redirect.
- Room previous/next topology is manually duplicated and asymmetric; it is not derived from a single ordered map. About → Science while Science’s previous is Tools; Blog’s previous is Services and Store is outside that chain.
- Hash links (`/#scene-main-studio`, `#studio-map`) depend on current homepage IDs. `#` placeholders may jump to the top of the current page rather than act inertly.
- Footer has many-to-one route aliases (“Meet DJ”→About, “Architecture Wall”→Science, etc.), and a migration preserving only header labels would lose the room-language navigation system.
- Article related links are authored as root URLs that do match explicit permalinks. They are not represented as metadata fields, so a front-matter-only importer would lose the relationship graph.

## Accessibility, loading, and metadata risks

- CSS-background scenes have no image alternative text. Their narrative copy contextualizes them, but background imagery itself is not exposed to accessibility APIs.
- Room hotspots become keyboard operable only after JavaScript adds roles/tab indices; they are `<div>` elements in source. No focus visual is authored for them.
- Generated panel HTML concatenates front-matter strings into `innerHTML` (`rooms.js:16-40`); content is trusted at build/source level and is not escaped by the client renderer.
- No width/height attributes, `aspect-ratio`, `srcset`, `<picture>`, preload, or modern image formats exist. Preserving only CSS layout without source dimensions can preserve current layout-shift exposure.
- Google Fonts creates an external runtime dependency and only preconnects `fonts.googleapis.com`, not `fonts.gstatic.com` (`default.html:10-12`).
- There is no reduced-motion behavior despite multiple infinite and scroll-driven animations.
- There is no `robots.txt`, social image, favicon, or Search Console verification value in repository evidence.

## Evidence boundary requiring later reconciliation

Repository source cannot establish hosting-provider redirects, CDN transformations, cached deployed files, browser-rendered Google font payloads, live HTTP headers, broken external destination status, or whether deployed output matches the current branch. Those belong to the separate live visual/HTTP audit and Documents 04–05. No conclusion here overrides that later evidence.
