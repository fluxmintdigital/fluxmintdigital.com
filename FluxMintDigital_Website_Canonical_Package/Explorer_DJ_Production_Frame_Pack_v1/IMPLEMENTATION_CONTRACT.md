# Explorer DJ Animation Implementation Contract

This contract describes a future progressive enhancement. The reusable integration is retained behind `_config.yml` → `features.explorer_entry_idle.enabled`, which is canonically `false`. Production must remain non-animated until replacement delivery assets pass validation and the flag is deliberately enabled. Current frame evidence and derivative tooling remain excluded from the public build.

## Lifecycle

1. Render meaningful navigation and orientation first. Explorer is an optional, `aria-hidden` visual layer unless separately approved as semantic content.
2. Create one controller per visible Explorer instance. The controller owns its preload, playback, cancellation token, timers, observers, and event listeners.
3. Start only after the required frames decode successfully and the Explorer container intersects the viewport.
4. Pause immediately when the document becomes hidden or the container leaves the viewport. Resume from a stable hold/idle frame, not the middle of a gesture.
5. Cancel the active sequence before starting another. Functional navigation never waits for cancellation or for an animation to complete.
6. On `pagehide`, component removal, or navigation, clear timers/animation frames, disconnect observers, remove listeners, invalidate pending loads, and release frame references not shared by the cache.

## Loading and failure

- Load only the frames required by the selected context. Do not preload the entire high-resolution pack on every page.
- Decode before revealing an animated layer. Keep the static fallback visible until the sequence is ready.
- If any required frame fails, cancel that sequence and retain the approved static fallback. Never skip a missing middle frame silently.
- Do not simulate a loading animation or block page interaction.
- Production delivery should derive appropriately sized WebP/AVIF or PNG resources after visual approval; the 1024×1024 masters remain sources, not an instruction to ship all masters on initial load.

## Motion and interruption

- Use monotonic time with `requestAnimationFrame`; do not treat `setInterval` as authoritative timing.
- Honor the canonical order and timing ranges in `sequence-manifest.json`.
- Idle may be interrupted at any frame and should settle immediately to a stable frame before the next gesture.
- Wave and point are one-shot gestures. They may be cancelled, but must never delay a linked action.
- Blink is too brief to interrupt after it starts; cancellation resolves to its close-up neutral frame.
- Head turn may be interrupted by reversing toward its stable starting frame.
- Expressions and useful poses are discrete states, not tween frames. Never play the files in directory order as an animation.

## Visibility, reduced motion, and input equivalence

- Under `prefers-reduced-motion: reduce`, render one approved static frame. Do not autoplay, blink, pan, crossfade, or loop.
- Explorer cannot contain required information. Touch and keyboard users receive the same label, orientation, and destination through semantic HTML whether the character plays or not.
- Do not translate hover literally to touch. A gesture can accompany an explicit tap/focus action, but the action and its meaning must be available before animation.
- Explorer is not focusable when decorative. If a future Explorer control is approved, use a real button with an accessible name and visible focus; do not make the image itself a pseudo-control.
- Never announce decorative frame changes through a live region.

## Identity and placement boundaries

- Explorer is the stylized guide/curiosity expression, never the author, researcher, evidentiary authority, collaborator of record, or realistic DJ identity.
- Initial candidate context remains Explorer Entry. Main Studio Map is a possible second context only after the pilot is approved.
- Do not place the animated Explorer on Architecture Wall, Meeting Table, Meet DJ, Artifact/Series/article pages, Library, Outfitters, Search, Relationship Explorer, archive, or recovery/error surfaces.
- Do not extract frames from scene masters or use the controlled realistic-DJ likeness reference.

## Runtime approach

CSS plus a small vanilla-JavaScript controller is sufficient. No animation framework is justified. The supplied source-pack JavaScript is timing evidence only and must not be reused directly.
