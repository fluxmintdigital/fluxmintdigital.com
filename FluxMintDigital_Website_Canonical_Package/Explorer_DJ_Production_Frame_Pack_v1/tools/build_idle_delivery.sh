#!/usr/bin/env bash
set -euo pipefail

package_dir="$(cd "$(dirname "$0")/.." && pwd)"
repo_dir="$(cd "$package_dir/../.." && pwd)"
source_dir="$package_dir/frames/animations/idle"
target_dir="$repo_dir/assets/images/explorer-entry/idle"

mkdir -p "$target_dir"
for frame in "$source_dir"/idle_*.png; do
  number="$(basename "$frame" .png | cut -d_ -f2)"
  for width in 320 512 768; do
    target="$target_dir/FMD_CHAR_EXPLORERENTRY_DJ_IDLE_F${number}_${width}W_v001.webp"
    convert "$frame" -resize "${width}x${width}" -quality 88 \
      -define webp:alpha-quality=100 -define webp:method=6 -strip "$target"
  done
done

# Portable no-JavaScript / no-WebP fallback for the first approved idle frame.
convert "$source_dir/idle_01.png" -resize 512x512 -strip \
  "$target_dir/FMD_CHAR_EXPLORERENTRY_DJ_IDLE_F01_512W_v001.png"
