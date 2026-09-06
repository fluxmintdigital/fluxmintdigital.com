#!/usr/bin/env ruby
require "csv"
require "digest"

package = File.expand_path("..", __dir__)
repo = File.expand_path("../..", package)
source_dir = File.join(package, "frames/animations/idle")
delivery_dir = File.join(repo, "assets/images/explorer-entry/idle")
manifest_path = File.join(package, "idle-delivery-manifest.csv")

rows = []
Dir.glob(File.join(delivery_dir, "FMD_CHAR_EXPLORERENTRY_DJ_IDLE_*")).sort.each do |path|
  name = File.basename(path)
  match = name.match(/_F(\d{2})_(\d+)W_v001\.(webp|png)\z/)
  next unless match
  frame = "idle_#{match[1]}"
  source = File.join(source_dir, "#{frame}.png")
  width = match[2].to_i
  rows << {
    "source_frame" => "frames/animations/idle/#{frame}.png",
    "source_sha256" => Digest::SHA256.file(source).hexdigest,
    "derivative_filename" => name,
    "dimensions" => "#{width}x#{width}",
    "format" => match[3].upcase,
    "byte_size" => File.size(path),
    "sha256" => Digest::SHA256.file(path).hexdigest,
    "intended_use" => case width
                      when 320 then "mobile/1x or compact character"
                      when 512 then "mobile high-density and tablet"
                      else "desktop/high-density"
                      end
  }
end

CSV.open(manifest_path, "w", write_headers: true, headers: rows.first.keys) do |csv|
  rows.each { |row| csv << row }
end
