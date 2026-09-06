# Explorer DJ — High-Resolution Frame Pack v1

Contains 12 idle, 8 wave, 6 point, 6 blink, 8 head-turn, 7 expression, and 5 useful-pose masters. Every exported frame is normalized to a 1024×1024 RGBA transparent canvas and indexed in `manifest.json`.

## Production note
The image generator produced the approved animation grammar as a composite master sheet rather than independent full-resolution frame renders. This package therefore extracts those generated frames, cleans the background to transparency, normalizes registration, and resamples them onto consistent 1024×1024 working canvases. These are suitable for Codex website implementation, but enlarging them does not create source detail that was not present in the composite.

Treat this as the v1 production-prep master pack. If Explorer DJ later appears at hero/close-up scale, rebuild as individually rendered or rigged masters while preserving this exact animation grammar and character identity.

Suggested timing: idle 120–160 ms/frame with pauses; wave 90–120 ms/frame; blink 70–100 ms/frame intermittently; head turn 110–150 ms/frame; point 100–140 ms/frame. Respect `prefers-reduced-motion`.
