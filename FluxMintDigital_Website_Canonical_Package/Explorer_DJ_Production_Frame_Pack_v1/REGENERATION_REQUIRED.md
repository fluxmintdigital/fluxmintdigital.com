# Frames Requiring Regeneration

These frames cannot be repaired deterministically without inventing missing pixels or altering approved character edges. Their source files remain untouched in `../Explorer_DJ_HighRes_Frame_Pack_v1/`; cleaned diagnostic crops are retained under `quarantine/cleaned_previews/` where available.

| Frame | Reason |
|---|---|
| `animations/blink/blink_04.png` | Source is empty (0 bytes). The flattened master sheet does not provide an exact transparent production source. |
| `animations/wave/wave_05.png` | Raised hand is clipped at the extracted frame boundary. |
| `animations/wave/wave_06.png` | Raised hand is clipped at the extracted frame boundary. |
| `animations/wave/wave_07.png` | Raised hand is clipped at the extracted frame boundary. |
| `animations/wave/wave_08.png` | Raised hand is clipped at the extracted frame boundary. |
| `animations/head_turn/head_turn_04.png` | Face/head is clipped at the extracted frame boundary. |
| `animations/head_turn/head_turn_05.png` | Face/head is clipped at the extracted frame boundary. |
| `animations/head_turn/head_turn_06.png` | Face/head is clipped at the extracted frame boundary. |
| `poses/expressions/expression_03.png` | Head is clipped at the extracted frame boundary. |
| `poses/expressions/expression_07.png` | Head is clipped at the extracted frame boundary. |
| `poses/useful/pose_03.png` | Opaque source-sheet residue intersects the subject crop. |
| `poses/useful/pose_05.png` | Opaque checker/background residue intersects the legs. |

## v1.1 replacement review

The 12 files in `../Explorer DJ Regeneration Pack v1.1/Explorer_DJ_Regeneration_Pack_v1_1/` are genuine RGBA PNG illustrations and are clean as standalone images. They do not pass sequence-continuity validation against the retained frames:

- Eight files are 1254×1254 rather than the production contract's 1024×1024.
- Wave changes from the existing upper-body framing to a sharper full-body rendering at frame 5.
- Blink changes face scale, feature rendering, line/detail treatment, and shoulder framing at frame 4.
- Head turn changes rendering style and does not create continuous orientation across frames 3→4 and 6→7.
- Replacement expressions and useful poses use the newer detail/identity treatment and are not visually interchangeable with the neighboring retained pose family.

Normalized candidates are preserved under `quarantine/replacement_candidates_v1_1/` for direct comparison. They are not production frames. Their source SHA-256 hashes are recorded in `frame-manifest.csv`.

The blocked frames remain blocked. A future replacement must preserve the corresponding pose, character identity, sequence position, apparent scale, rendering treatment, framing, and viewing angle of its immediate neighbors; use a genuine 1024×1024 RGBA PNG with clear transparent margins and no labels, adjacent cells, checker pattern, border, or watermark. Alternatively, replace an entire sequence with a coherent, human-approved sequence in the newer visual treatment.
