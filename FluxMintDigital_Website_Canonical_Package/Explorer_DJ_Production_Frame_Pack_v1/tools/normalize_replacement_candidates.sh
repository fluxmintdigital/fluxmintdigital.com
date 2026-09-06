#!/usr/bin/env bash
set -euo pipefail

package_dir="$(cd "$(dirname "$0")/.." && pwd)"
repo_dir="$(cd "$package_dir/../.." && pwd)"
replacement_dir="$repo_dir/FluxMintDigital_Website_Canonical_Package/Explorer DJ Regeneration Pack v1.1/Explorer_DJ_Regeneration_Pack_v1_1"
candidate_dir="$package_dir/quarantine/replacement_candidates_v1_1"

normalize() {
  local filename="$1"
  local relative="$2"
  local target_height="$3"
  local source="$replacement_dir/$filename"
  local target="$candidate_dir/$relative"
  local component width height x y expanded_x expanded_y expanded_width expanded_height

  component="$(convert "$source" -alpha extract -threshold 5% \
    -define connected-components:verbose=true -connected-components 8 null: 2>&1 \
    | awk '/gray\(255\)/{print $2; exit}')"
  [[ "$component" =~ ^([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)$ ]]
  width="${BASH_REMATCH[1]}"; height="${BASH_REMATCH[2]}"; x="${BASH_REMATCH[3]}"; y="${BASH_REMATCH[4]}"
  expanded_x=$(( x > 8 ? x - 8 : 0 )); expanded_y=$(( y > 8 ? y - 8 : 0 ))
  expanded_width=$(( width + 16 )); expanded_height=$(( height + 16 ))
  source_width="$(identify -format '%w' "$source")"; source_height="$(identify -format '%h' "$source")"
  (( expanded_x + expanded_width <= source_width )) || expanded_width=$(( source_width - expanded_x ))
  (( expanded_y + expanded_height <= source_height )) || expanded_height=$(( source_height - expanded_y ))
  mkdir -p "$(dirname "$target")"
  convert "$source" -crop "${expanded_width}x${expanded_height}+${expanded_x}+${expanded_y}" +repage \
    -resize "x${target_height}" -gravity south -background none -extent 1024x976 \
    -gravity north -background none -extent 1024x1024 -define png:color-type=6 -strip "$target"
}

normalize blink_04.png animations/blink/blink_04.png 820
for n in 05 06 07 08; do normalize "wave_${n}.png" "animations/wave/wave_${n}.png" 839; done
for n in 04 05 06; do normalize "head_turn_${n}.png" "animations/head_turn/head_turn_${n}.png" 812; done
normalize expression_03.png poses/expressions/expression_03.png 784
normalize expression_07.png poses/expressions/expression_07.png 784
normalize pose_03.png poses/useful/pose_03.png 656
normalize pose_05.png poses/useful/pose_05.png 587
