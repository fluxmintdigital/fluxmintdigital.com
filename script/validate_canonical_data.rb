#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "date"

ROOT = File.expand_path("..", __dir__)

def load_yaml(relative_path)
  YAML.safe_load_file(File.join(ROOT, relative_path), aliases: true) || []
end

def front_matter(relative_path)
  text = File.read(File.join(ROOT, relative_path), encoding: "UTF-8")
  match = text.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  raise "Missing front matter: #{relative_path}" unless match

  YAML.safe_load(match[1], permitted_classes: [Date, Time], aliases: true) || {}
end

errors = []
rooms = load_yaml("_data/rooms.yml")
values = load_yaml("_data/semantic_values.yml")
relationships = load_yaml("_data/relationships.yml")
placements = load_yaml("_data/surface_placements.yml")
research_contract = load_yaml("_data/research_contract.yml")
observatory = load_yaml("_data/observatory.yml")
meeting_table = load_yaml("_data/meeting_table.yml")
availability = load_yaml("_data/availability.yml")
artifact_paths = Dir.glob(File.join(ROOT, "_artifacts", "*.md")).sort
artifacts = artifact_paths.map { |path| [path.delete_prefix("#{ROOT}/"), front_matter(path.delete_prefix("#{ROOT}/"))] }

room_ids = rooms.map { |room| room.fetch("id") }
artifact_ids = artifacts.map { |_path, artifact| artifact["artifact_id"] }
artifact_routes = artifacts.map { |_path, artifact| artifact["permalink"] }
known_targets = artifact_ids + ["dj-boswell", "fluxmintdigital-studio"]

errors << "Room IDs are not unique" unless room_ids.uniq.length == room_ids.length
errors << "Artifact IDs are missing or not unique" if artifact_ids.any?(&:nil?) || artifact_ids.uniq.length != artifact_ids.length
errors << "Artifact permalinks are missing or not unique" if artifact_routes.any?(&:nil?) || artifact_routes.uniq.length != artifact_routes.length

artifacts.each do |path, artifact|
  %w[artifact_id title description artifact_type canonical_room lifecycle visibility governance permalink].each do |field|
    errors << "#{path}: missing #{field}" if artifact[field].nil? || artifact[field].to_s.strip.empty?
  end
  errors << "#{path}: unknown Room #{artifact['canonical_room']}" unless room_ids.include?(artifact["canonical_room"])
  %w[lifecycle visibility governance].each do |field|
    errors << "#{path}: unknown #{field} #{artifact[field]}" unless values.fetch(field).include?(artifact[field])
  end
  if artifact["series_id"]
    series = artifacts.map(&:last).find { |candidate| candidate["artifact_id"] == artifact["series_id"] }
    errors << "#{path}: unknown series #{artifact['series_id']}" unless series
    errors << "#{path}: parent #{artifact['series_id']} is not a Series" if series && series["artifact_type"] != "Series"
    errors << "#{path}: series member requires a positive sequence" unless artifact["sequence"].is_a?(Integer) && artifact["sequence"].positive?
  end
end

relationships.each_with_index do |relationship, index|
  label = "_data/relationships.yml record #{index + 1}"
  errors << "#{label}: unknown source" unless known_targets.include?(relationship["source"])
  errors << "#{label}: unknown target" unless known_targets.include?(relationship["target"])
  errors << "#{label}: unknown type #{relationship['type']}" unless values.fetch("relationship_types").include?(relationship["type"])
end

placements.each_with_index do |placement, index|
  errors << "_data/surface_placements.yml record #{index + 1}: unknown Artifact" unless artifact_ids.include?(placement["artifact"])
end

outfitters_placements = placements.select { |placement| placement["surface"] == "explorer-outfitters-discovery" }
errors << "Outfitters discovery placements must be unique" unless outfitters_placements.map { |placement| placement["artifact"] }.uniq.length == outfitters_placements.length
outfitters_placements.each do |placement|
  artifact = artifacts.map(&:last).find { |candidate| candidate["artifact_id"] == placement["artifact"] }
  errors << "Outfitters cannot own Artifact identity" if artifact && artifact["canonical_room"] == "explorer-outfitters"
  errors << "Outfitters discovery may expose only public Artifacts" unless artifact && artifact["visibility"] == "public"
end

availability.fetch("records", []).each_with_index do |record, index|
  label = "_data/availability.yml record #{index + 1}"
  errors << "#{label}: unknown Artifact" unless artifact_ids.include?(record["artifact"])
  errors << "#{label}: invalid availability" unless values.fetch("availability").include?(record["status"])
  errors << "#{label}: channels must be an array" unless record["channels"].is_a?(Array)
  errors << "#{label}: non-available Artifact cannot expose channels" if record["status"] != "available" && record.fetch("channels", []).any?
  channel_ids = record.fetch("channels", []).map { |channel| channel["id"] }
  errors << "#{label}: channel IDs must be unique within an Artifact" unless channel_ids.uniq.length == channel_ids.length
  record.fetch("channels", []).each do |channel|
    errors << "#{label}: channel requires id, name, action, and HTTPS URL" unless channel["id"].to_s.strip != "" && channel["name"].to_s.strip != "" && channel["action"].to_s.strip != "" && channel["url"].to_s.start_with?("https://")
    if channel["affiliate"] == true
      errors << "#{label}: affiliate channel requires a known disclosure" unless availability.fetch("disclosures", {}).key?(channel["disclosure"])
    end
  end
end

volume_availability = availability.fetch("records", []).find { |record| record["artifact"] == "architecture-of-being-human-volume-i" }
amazon_channel = volume_availability&.fetch("channels", [])&.find { |channel| channel["id"] == "amazon" }
approved_amazon_url = "https://www.amazon.com/dp/B0HHSQT83Z/ref=cm_sw_r_as_gl_api_gl_i_HFKAKNGJ9HFXSDVK871C?linkCode=ml1&tag=fluxmintdigit-20&linkId=f4e6faba26d8121b4b4525d9c0358199&gaOptInStatus=true"
errors << "Approved Volume I Amazon channel is missing or changed" unless amazon_channel && amazon_channel["url"] == approved_amazon_url && amazon_channel["affiliate"] == true
errors << "Amazon Associates disclosure is missing or changed" unless availability.fetch("disclosures", {})["amazon_associates"] == "As an Amazon Associate, FluxMintDigital earns from qualifying purchases."

current_builds = placements.select { |placement| placement["surface"] == "workshop-current-build" }
errors << "Workshop must have exactly one canonical Current Build placement" unless current_builds.length == 1
current_builds.each do |placement|
  artifact = artifacts.map(&:last).find { |candidate| candidate["artifact_id"] == placement["artifact"] }
  errors << "Workshop Current Build must be public" unless artifact && artifact["visibility"] == "public"
  errors << "Workshop Current Build must be on the workbench" unless artifact && artifact["lifecycle"] == "on_the_workbench"
end

assertion_kinds = research_contract.fetch("assertion_kinds", []).map { |kind| kind["id"] }
errors << "AEG assertion kinds must be exactly alignment, equivalence, and generation" unless assertion_kinds == %w[alignment equivalence generation]
research_rules = research_contract.fetch("rules", {})
errors << "AEG assertion kinds must remain independent" unless research_rules["independent"] == true
errors << "AEG assertion kinds must remain non-entailing" unless research_rules["mutually_entailing"] == false
errors << "A combined AEG score is forbidden" unless research_rules["combined_score"] == false
errors << "AI self-promotion of warrant is forbidden" unless research_rules["ai_self_promotes_warrant"] == false
errors << "Visual prominence must not confer truth" unless research_rules["visual_prominence_confers_truth"] == false
errors << "Relationship direction must not imply causation" unless research_rules["direction_implies_causation"] == false

public_research_records = research_contract.fetch("public_records", {})
%w[claims evidence contradictions validity_envelopes].each do |record_type|
  errors << "Public research #{record_type} must be an array" unless public_research_records[record_type].is_a?(Array)
end

wall_artifacts = artifacts.map(&:last).select { |artifact| artifact["canonical_room"] == "architecture-wall" }
wall_artifacts.each do |artifact|
  errors << "#{artifact['artifact_id']}: claim-level confidence must not be stored as Artifact state" if artifact.key?("confidence")
  errors << "#{artifact['artifact_id']}: AEG warrant must not be stored as Artifact state" if artifact.key?("aeg_warrant")
end

post_paths = Dir.glob(File.join(ROOT, "_posts", "*.md")).sort
post_records = post_paths.map do |path|
  relative = path.delete_prefix("#{ROOT}/")
  data = front_matter(relative)
  date_match = File.basename(path).match(/\A(\d{4}-\d{2}-\d{2})-/)
  data.merge("source_date" => date_match && date_match[1])
end
post_urls = post_records.map { |post| post["permalink"] }
observatory_urls = [observatory["current_observation"], *observatory.fetch("featured", [])]
observatory_urls.each { |url| errors << "Observatory references unknown post #{url}" unless post_urls.include?(url) }
errors << "Observatory featured selection must not contain duplicates" unless observatory.fetch("featured", []).uniq.length == observatory.fetch("featured", []).length
expected_forms = ["Essay", "Discovery", "Field Note", "Workshop Note"]
actual_forms = observatory.fetch("forms", []).map { |form| form["artifact_type"] }
errors << "Observatory forms must remain Essay, Discovery, Field Note, and Workshop Note" unless actual_forms == expected_forms
post_records.each do |post|
  errors << "Observatory post missing title" if post["title"].to_s.strip.empty?
  errors << "Observatory post #{post['permalink']} missing source-derived date" unless post["source_date"]
  errors << "Observatory post #{post['permalink']} missing description" if post["description"].to_s.strip.empty?
end

errors << "Meeting Table primary verb must remain Collaborate" unless meeting_table["primary_verb"] == "Collaborate"
errors << "Meeting Table flow must remain describe, clarify, scope, decide" unless meeting_table.fetch("stages", []).map { |stage| stage["id"] } == %w[describe clarify scope decide]
errors << "Meeting Table decision branches changed" unless meeting_table.fetch("decisions", []).map { |decision| decision["id"] } == %w[architecture-only architecture-and-implementation no-engagement]
errors << "Meeting Table must not imply a configured backend" unless meeting_table["backend_configured"] == false
errors << "Meeting Table must not make client artifacts public" unless meeting_table["public_client_artifacts"] == false
errors << "Meeting Table must not assume attribution" unless meeting_table["attribution_assumed"] == false
errors << "Meeting Table must not make implementation automatic" unless meeting_table["implementation_automatic"] == false

studio = load_yaml("_data/studio.yml")
owner = studio.fetch("owner", {})
errors << "Canonical Person ID must remain dj-boswell" unless owner["id"] == "dj-boswell"
errors << "Canonical Person name must remain D.J. Boswell" unless owner["name"] == "D.J. Boswell"
errors << "DJ role contract changed" unless %w[author builder collaborator].all? { |role| owner.fetch("roles", []).include?(role) }
identity = studio.fetch("identity", {})
errors << "Explorer must remain a separate character identity" unless identity["explorer_character"] == "explorer-dj" && identity["human_representation"] == "realistic-dj"
errors << "ForgeSpark must remain a sibling studio" unless studio.fetch("external_boundaries", {})["forgespark_relationship"] == "sibling-studio"

if errors.empty?
  puts "Canonical data valid: #{rooms.length} Rooms, #{artifacts.length} Artifacts, #{relationships.length} relationships, #{placements.length} placements."
  exit 0
end

warn errors.join("\n")
exit 1
