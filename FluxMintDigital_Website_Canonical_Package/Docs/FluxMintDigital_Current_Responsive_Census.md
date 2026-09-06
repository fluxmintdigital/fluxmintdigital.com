# FluxMintDigital Current Responsive Census

Evidence basis: repository source at 2026-09-04. This is a source census, not a browser/live audit. No build output was generated.

## Breakpoints and global behavior

Only two explicit breakpoints exist:

- `max-width: 768px` in `assets/css/main.css:661-669`: hides `.site-nav` without providing a hamburger/replacement; collapses footer, posts, and feature grids to one column; keeps the homepage category grid at two columns; stacks CTA content; reduces hero padding.
- `max-width: 780px` in `assets/css/rooms.css:168-170`: changes `.stage-wrap` from `1.6fr 1fr` to one column. The image/hotspots therefore precede the panel.

There are no min-width queries, orientation queries, height queries, container queries, DPR queries, print styles, or `prefers-reduced-motion` handling. The 768/780 split creates a narrow 12-pixel interval in which the header is already hidden but room stage and panel remain side by side.

## Scene and Surface geometry

| Scene/Surface | Source and asset | Desktop/current geometry | Responsive/current geometry |
|---|---|---|---|
| Forest | `_layouts/home.html:11-20`; `forest_path.jpg` | First scene is inline `height:100vh`; flex-centered copy; cover/center background; bottom scrim; scroll cue. | Same geometry at all widths; minimum scene height remains 540px. Text uses clamped headings but body is fixed 1.02rem. |
| Cabin Exterior | `_layouts/home.html:22-33`; `cabin_exterior.jpg` | 92vh, min 540px; cover/center image; top scrim; centered copy positioned at top 10%; 260x220 glow; three smoke particles near 63%/20%. | No mobile relocation/scaling for copy, glow, or smoke. Viewport crop changes because `background-size:cover`. |
| Explorer Entry | `_layouts/home.html:35-48`; `explorer_entry.jpg` | 92vh, min 540px; full scrim; centered max-620px copy; two wrapping CTAs. | CTA wrapper can wrap; otherwise same. Background crop changes. |
| Main Studio | `_layouts/home.html:50-58`; `main_studio.jpg` | 92vh, min 540px; bottom scrim; centered max-620px copy. | Same rules and cover crop. |
| Homepage content/map | `_layouts/home.html:60-131` | Containers max 1100px with 24px side padding; prose sections max 720px; category cards use auto-fit minmax in base CSS, but inline map is `.cat-grid`. | At <=768px category map is forced to two equal columns, not one; closing scene stays 60vh/min 400px. |
| Library | `books.md`; `library.jpg` | Header centered; stage+panel grid `1.6fr 1fr`, 24px gap; image retains natural 1400:933 ratio; panel min-height 360px. | At <=780px panel moves beneath stage. Hotspot coordinates remain percentages of the scaled image. Two banners are width 100%, height auto. |
| Workshop (Apps) | `apps.md`; `workshop.jpg` | Same shared room geometry; four percentage-positioned hotspots. | Same one-column collapse; no touch-specific labels. |
| Workshop (Tools) | `tools.md`; `workshop.jpg` | Identical scene and hotspot map to Apps; content panel differs only by route context/prev-next. | Same one-column collapse. |
| Architecture Wall/Science | `science.md`; `main_studio.jpg` | Shared room geometry; three percentage hotspots over Main Studio image. | Same one-column collapse. |
| Observatory/Blog | `blog.md`; `observatory.jpg` | Shared room geometry, but source image ratio is 1400:1120 (1.25) versus most room images 1.50, making the stage taller at a given width. | Same one-column collapse; scaled percentage hotspots. |
| Meeting Table/Services | `services.md`; `services.jpg` | Shared room geometry plus native FAQ below supplement. | Same one-column collapse; FAQ remains full content width. |
| Explorer Outfitters/Store | `store.md`; `store.jpg` | Shared room geometry; three hotspots. | Same one-column collapse. |
| Meet DJ/About | `about.md`; `architecture_wall_dj.jpg` | Shared room geometry; three hotspots. | Same one-column collapse. |
| Studio Blog archive | `studio-blog/index.html`; no image | Auto-fill card grid with minimum 300px. | Forced one column at <=768px. |
| Article | `_layouts/post.html`; no image | Content and disclosure max 760px inside 1100px container; serif body, clamped title. | Same width constraints; container padding prevents edge collision. No table overflow wrapper. |
| Header | `_layouts/default.html:18-35` | Sticky 64px bar; logo left, eight links right. | Eight-link nav disappears at <=768px; logo remains; no mobile navigation control exists. |
| Footer | `_layouts/default.html:41-79` | Four columns (`1.6fr 1fr 1fr 1fr`). | One column <=768px. |

## Visual states

- Room hotspot base: faint gold border/fill. Hover and selected `.active` share a brighter gold inset glow (`rooms.css:69-81`). Navigation hotspots use dashed borders and green hover/active treatment (`rooms.css:89-90`). Labels are hidden at opacity 0 and shown only on `:hover`; `.active`, focus, and touch do not reveal them (`rooms.css:82-88`). JavaScript adds `tabindex=0` and `role=button`, but CSS supplies no hotspot `:focus`/`:focus-visible` treatment (`rooms.js:60-66`).
- Panel starts in a waiting/empty state. Activating a hotspot replaces its `innerHTML`; selected hotspot persists until another is activated. Tabs appear only for tab-bearing data and first tab is reset active on every hotspot activation (`rooms.js:16-57`).
- Links/buttons/cards have hover states, but generally no authored focus-visible or pressed/touch state. FAQ summaries are the exception, with explicit focus-visible outline (`rooms.css:153`).
- Homepage `.reveal` content begins hidden and translated; IntersectionObserver makes it visible at 20% intersection. It never unobserves, and there is no no-JavaScript fallback (`rooms.css:57-58`; `rooms.js:70-77`).
- No route-aware active global navigation style, no breadcrumb component, no selected footer state, and no mobile-only/desktop-only image asset.

## Image loading and layout stability

- Room-stage images are `<img loading="eager">` (`_layouts/room.html:13`). They have neither HTML `width`/`height` attributes nor CSS `aspect-ratio`; dimensions become known from the file, so the stage has no explicit pre-decode reservation.
- Book banners are ordinary `<img>` elements without `loading`, `width`, `height`, `srcset`, or `<picture>` (`books.md:85,89`); browser default loading is eager.
- Homepage scenes are CSS backgrounds on absolutely positioned `.kenburns` elements. All four are discoverable from the initial HTML/CSS style attributes, but cannot use native `loading=lazy`, `srcset`, or intrinsic sizing. The fixed scene dimensions protect overall scene geometry, not image fetch timing.
- All raster assets are JPEG. There are no WebP/AVIF/PNG/GIF assets, thumbnails, responsive variants, low-quality placeholders, preload/prefetch tags, image CDN transforms, CSS masks, or fallback images.
- CSS background images use `cover center`; room `<img>` images use full width and natural aspect. This means homepage crops are viewport-dependent while room stages display the complete image.

## Motion

- Ken Burns: scale 1 to 1.07, 26 seconds, ease-in-out, infinite alternate; per-scene inline durations override Cabin to 28s, Entry to 26s, Main Studio to 30s (`rooms.css:26-32`; `home.html:23,36,51`).
- Scroll cue: 1.8s infinite scale/opacity pulse. Cabin glow: 3.6s infinite flicker. Three smoke particles: 6s infinite rise with 0/2/4s delays (`rooms.css:43-50`; `home.html:25-27`).
- Reveal: 0.9s opacity/translate transition. Compass: scroll-linked rotation with 0.2s transition (`rooms.css:54-58`; `rooms.js:79-87`).
- There is no reduced-motion override; smooth scrolling and all animations remain enabled for users requesting reduced motion.
