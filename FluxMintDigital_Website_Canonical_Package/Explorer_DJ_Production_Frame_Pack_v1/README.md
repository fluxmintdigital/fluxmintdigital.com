# Explorer DJ Production Frame Pack v1

This is the deterministic cleanup output derived from `../Explorer_DJ_HighRes_Frame_Pack_v1/`. The source/evidence pack is preserved unchanged and remains the authority for original pixels and motion intent.

## Status

**Full animation grammar not ready. Limited idle slice ready.** Forty of 52 declared frames pass production validation. The complete 12-frame idle sequence is integrated at Explorer Entry only; twelve other records remain quarantined and require regeneration before broader Explorer use. See `REGENERATION_REQUIRED.md`.

The supplied Regeneration Pack v1.1 was validated but not promoted: its files are clean standalone illustrations, yet they do not maintain framing, rendering, or transition continuity with their neighboring retained frames. See `VALIDATION_REPORT.md`.

## Contents

- `frames/`: production-ready cleaned frames only
- `quarantine/cleaned_previews/`: non-production diagnostic crops of contaminated frames
- `frame-manifest.csv`: all 52 declared records, source and production hashes, status, and reason
- `frame-manifest.sha256`: checksum for the frame manifest
- `replacement-source-manifest.csv`: provenance and hashes for the five supplied v1.1 composite source sheets
- `idle-delivery-manifest.csv`: responsive Explorer Entry delivery derivatives, sizes, uses, and SHA-256 hashes
- `review/`: required desktop and 390px local review screenshots
- `sequence-manifest.json`: canonical order and playback contract
- `IMPLEMENTATION_CONTRACT.md`: future progressive-enhancement requirements
- `REGENERATION_REQUIRED.md`: exact blocked frames
- `tools/clean_frames.sh`: deterministic crop/registration procedure
- `tools/build_frame_manifest.rb`: reproducible manifest generation

All production frames use a genuine 1024×1024 RGBA PNG canvas, transparent background, bottom-center registration at y=976, stripped metadata, and preserved source pixel scale. No frame was redrawn, generated, interpolated, or substituted.
