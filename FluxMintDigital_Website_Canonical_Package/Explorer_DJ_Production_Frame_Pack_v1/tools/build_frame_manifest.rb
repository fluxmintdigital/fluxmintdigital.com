#!/usr/bin/env ruby
require "csv"
require "digest"
require "json"

package = File.expand_path("..", __dir__)
source = File.expand_path("../../Explorer_DJ_HighRes_Frame_Pack_v1", __dir__)
replacement = File.expand_path("../../Explorer DJ Regeneration Pack v1.1/Explorer_DJ_Regeneration_Pack_v1_1", __dir__)
declared = JSON.parse(File.read(File.join(source, "manifest.json"))).fetch("sequences")

quarantine_reasons = {
  "animations/blink/blink_04.png" => "Empty 0-byte source; no approved pixel payload to repair",
  "animations/wave/wave_05.png" => "Raised hand clipped at source extraction boundary",
  "animations/wave/wave_06.png" => "Raised hand clipped at source extraction boundary",
  "animations/wave/wave_07.png" => "Raised hand clipped at source extraction boundary",
  "animations/wave/wave_08.png" => "Raised hand clipped at source extraction boundary",
  "animations/head_turn/head_turn_04.png" => "Face/head clipped at source extraction boundary",
  "animations/head_turn/head_turn_05.png" => "Face/head clipped at source extraction boundary",
  "animations/head_turn/head_turn_06.png" => "Face/head clipped at source extraction boundary",
  "poses/expressions/expression_03.png" => "Head clipped at source extraction boundary",
  "poses/expressions/expression_07.png" => "Head clipped at source extraction boundary",
  "poses/useful/pose_03.png" => "Opaque source-sheet residue intersects subject crop",
  "poses/useful/pose_05.png" => "Opaque checker/background residue intersects legs"
}.freeze

rows = []
declared.each do |group, paths|
  paths.each_with_index do |relative, index|
    source_path = File.join(source, relative)
    production_path = File.join(package, "frames", relative)
    status = quarantine_reasons.key?(relative) ? "REQUIRES_REGENERATION" : "PRODUCTION_READY"
    rows << {
      "frame_id" => File.basename(relative, ".png"),
      "group" => group,
      "order" => index + 1,
      "declared_path" => relative,
      "source_sha256" => File.size?(source_path) ? Digest::SHA256.file(source_path).hexdigest : nil,
      "replacement_evidence_path" => quarantine_reasons.key?(relative) ? "../Explorer DJ Regeneration Pack v1.1/Explorer_DJ_Regeneration_Pack_v1_1/#{File.basename(relative)}" : nil,
      "replacement_evidence_sha256" => quarantine_reasons.key?(relative) && File.file?(File.join(replacement, File.basename(relative))) ? Digest::SHA256.file(File.join(replacement, File.basename(relative))).hexdigest : nil,
      "production_path" => File.file?(production_path) ? "frames/#{relative}" : nil,
      "production_sha256" => File.file?(production_path) ? Digest::SHA256.file(production_path).hexdigest : nil,
      "status" => status,
      "notes" => quarantine_reasons[relative] || "Deterministically isolated and bottom-center registered; source pixels preserved"
    }
  end
end

headers = rows.first.keys
CSV.open(File.join(package, "frame-manifest.csv"), "w", write_headers: true, headers: headers) do |csv|
  rows.each { |row| csv << row }
end

File.write(File.join(package, "frame-manifest.sha256"), Digest::SHA256.file(File.join(package, "frame-manifest.csv")).hexdigest + "  frame-manifest.csv\n")
