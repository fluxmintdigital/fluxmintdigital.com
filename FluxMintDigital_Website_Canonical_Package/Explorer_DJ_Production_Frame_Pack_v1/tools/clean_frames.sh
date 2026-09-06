#!/usr/bin/env bash
set -euo pipefail

package_dir="$(cd "$(dirname "$0")/.." && pwd)"
repo_dir="$(cd "$package_dir/../.." && pwd)"
source_dir="$repo_dir/FluxMintDigital_Website_Canonical_Package/Explorer_DJ_HighRes_Frame_Pack_v1"
frames_dir="$package_dir/frames"

clean_frame() {
  local relative="$1"
  local roi_height="$2"
  local source="$source_dir/$relative"
  local target="$frames_dir/$relative"
  local component bbox width height x y expanded_x expanded_y expanded_width expanded_height

  mkdir -p "$(dirname "$target")"

  component="$(convert "$source" -crop "1024x${roi_height}+0+0" +repage -alpha extract -threshold 5% \
    -define connected-components:verbose=true -connected-components 8 null: 2>&1 \
    | awk '/gray\(255\)/{print $2; exit}')"
  if [[ ! "$component" =~ ^([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)$ ]]; then
    echo "Unable to isolate primary subject: $relative" >&2
    exit 1
  fi

  width="${BASH_REMATCH[1]}"
  height="${BASH_REMATCH[2]}"
  x="${BASH_REMATCH[3]}"
  y="${BASH_REMATCH[4]}"

  expanded_x=$(( x > 6 ? x - 6 : 0 ))
  expanded_y=$(( y > 6 ? y - 6 : 0 ))
  expanded_width=$(( width + 12 ))
  expanded_height=$(( height + 12 ))
  if (( expanded_x + expanded_width > 1024 )); then expanded_width=$(( 1024 - expanded_x )); fi
  if (( expanded_y + expanded_height > roi_height )); then expanded_height=$(( roi_height - expanded_y )); fi

  convert "$source" \
    -crop "${expanded_width}x${expanded_height}+${expanded_x}+${expanded_y}" +repage \
    -gravity south -background none -extent 1024x976 \
    -gravity north -background none -extent 1024x1024 \
    -define png:color-type=6 -strip "$target"
}

for frame in "$source_dir"/animations/idle/*.png; do
  clean_frame "${frame#"$source_dir/"}" 1024
done
for frame in "$source_dir"/animations/wave/*.png; do
  clean_frame "${frame#"$source_dir/"}" 936
done
for frame in "$source_dir"/animations/point/*.png; do
  clean_frame "${frame#"$source_dir/"}" 936
done
for frame in "$source_dir"/animations/blink/*.png; do
  [[ -s "$frame" ]] || continue
  clean_frame "${frame#"$source_dir/"}" 890
done
for frame in "$source_dir"/animations/head_turn/*.png; do
  clean_frame "${frame#"$source_dir/"}" 892
done
for frame in "$source_dir"/poses/expressions/*.png; do
  clean_frame "${frame#"$source_dir/"}" 884
done
for frame in "$source_dir"/poses/useful/*.png; do
  clean_frame "${frame#"$source_dir/"}" 910
done

# Frames with missing pixels or subject-intersecting residue are diagnostics only.
# Do not let a reproducible cleanup run promote them into the production set.
quarantine=(
  animations/wave/wave_05.png
  animations/wave/wave_06.png
  animations/wave/wave_07.png
  animations/wave/wave_08.png
  animations/head_turn/head_turn_04.png
  animations/head_turn/head_turn_05.png
  animations/head_turn/head_turn_06.png
  poses/expressions/expression_03.png
  poses/expressions/expression_07.png
  poses/useful/pose_03.png
  poses/useful/pose_05.png
)
for relative in "${quarantine[@]}"; do
  diagnostic="$package_dir/quarantine/cleaned_previews/$relative"
  mkdir -p "$(dirname "$diagnostic")"
  mv "$frames_dir/$relative" "$diagnostic"
done
