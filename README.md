# FluxMintDigital — fluxmintdigital.com

Jekyll site for the FluxMintDigital Architecture Studio, built as an
interactive "walk through the cabin" experience — each division is a room,
built from real photography with clickable objects.

## What changed in this rebuild

This replaces the earlier card-grid version of the site entirely:

- **Theme**: dark charcoal/brass/cream, Fraunces + Inter, instead of the
  original blue/purple corporate theme. The swap lives almost entirely in
  `assets/css/main.css`'s `:root` variables — if you ever want to adjust a
  color sitewide, start there.
- **Homepage** (`index.md` + `_layouts/home.html`): a photographic arrival
  sequence — Forest → Cabin → Explorer Entry → Main Studio → Studio Map →
  Departure — instead of a static hero section.
- **Every division page** (`books.md`, `apps.md`, `tools.md`, `science.md`,
  `services.md`, `store.md`, `blog.md`, `about.md`) now uses `layout: room`
  — a real photo of that "room" with clickable hotspots, plus a
  supplementary text section below for accessibility, SEO, and no-JS
  fallback.
- **Apps and Tools share one room** (the Workshop), matching the Experience
  Map's design — same photo, same hotspots, two separate URLs
  (`/apps/`, `/tools/`) with different page copy.

## File structure that matters

```
_layouts/room.html       ← generic layout every division page uses
_layouts/home.html       ← homepage-specific arrival sequence
assets/css/main.css      ← sitewide theme (colors, header, footer, buttons)
assets/css/rooms.css     ← room/hotspot-specific styles (shared, cached once)
assets/js/rooms.js       ← the interactive hotspot engine (shared, cached once)
assets/images/rooms/     ← the actual room photos (real files, not embedded)
_data/*.yml              ← editable lists (books, apps, tools, services, science)
books.md, apps.md, etc.  ← front matter defines hotspots + panel content per room
```

## How each room page works

Every room page's front matter defines:

- `room_image` — path to the photo
- `hotspots` — a list of clickable zones (`key`, `label`, `x`/`y`/`w`/`h` as
  percentages of the image, optional `nav: true` for doorway-style links to
  other rooms)
- `content_data` — what shows in the side panel when each hotspot is
  clicked (title, badge, body text, or `tabs` for multi-part content, or
  `links` for buttons)

The Markdown body below the front matter is the supplementary section —
most of these loop through `_data/*.yml` so you can add a new book, app,
tool, or service by editing YAML, same as before, without touching any
page's HTML.

## Adjusting a hotspot

If a clickable zone doesn't quite line up with the object in the photo,
open the relevant `.md` file and nudge its `x`, `y`, `w`, `h` values
(percentages of the image, from the top-left corner). No CSS or JS
knowledge needed for this — it's just four numbers per hotspot.

## Adding a new room later

1. Add the photo to `assets/images/rooms/`.
2. Copy an existing room page (e.g. `services.md`) as a starting point.
3. Update its front matter: `permalink`, `room_image`, `hotspots`,
   `content_data`, `prev_href`/`next_href`.
4. Add a nav link in `_layouts/default.html` if it's a new top-level page.

## Deploying

Same workflow as before — this repo is already wired to GitHub Pages with
the custom domain via `CNAME`.

```bash
git add .
git commit -m "Rebuild site as interactive photo rooms"
git push
```

Check the **Actions** tab on GitHub to watch the build; it's usually live
within a couple of minutes.

## Known open items

- **Hotspot alignment** was tightened in this pass but is still an
  estimate, not pixel-measured — expect to nudge a few after seeing it
  live and at different screen sizes.
- **Store's Etsy/Google Play/Amazon links** are placeholders (`href="#"`)
  until those listings actually exist. Search this repo for
  `placeholder` to find every one that needs a real URL later.
- **Science and Blog reuse existing wide shots** (the Main Studio and
  Observatory photos) rather than having their own dedicated close-up —
  workable for now, but a dedicated photo for each would look sharper
  long-term.
- **Mobile**: hotspots are percentage-based so they'll scale with the
  image, but no dedicated "guided expedition" mobile treatment has been
  built yet, per the Experience Map's original mobile philosophy.

## Local preview before pushing

```bash
bundle install
bundle exec jekyll serve
```

Then open `http://localhost:4000`.
