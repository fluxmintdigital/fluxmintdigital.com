#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

root = Pathname.new(File.expand_path("..", __dir__))
site = root.join("_site")
errors = []

artifact_files = root.join("_artifacts").glob("*.md")
artifacts = artifact_files.to_h do |path|
  match = path.read.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  data = YAML.safe_load(match[1], aliases: true)
  [data["artifact_id"], data]
end
thinking = artifacts["architectural-thinking"]
method = artifacts["objective-first-architecture"]

errors << "Architectural Thinking is not classified as a Way of Thinking" unless thinking && thinking["title"] == "Architectural Thinking" && thinking["artifact_type"] == "Way of Thinking" && thinking["division"] == "ways-of-thinking" && thinking["intellectual_kind"] == "reasoning-lens"
errors << "Objective-First Architecture is not classified as a Method" unless method && method["title"] == "Objective-First Architecture™" && method["artifact_type"] == "Method" && method["division"] == "methods" && method["intellectual_kind"] == "operational-method"
errors << "Architectural Thinking route changed" unless thinking && thinking["permalink"] == "/architecture-wall/frameworks/architectural-thinking/"
errors << "Objective-First Architecture route changed" unless method && method["permalink"] == "/architecture-wall/frameworks/objective-first-architecture/"

placements = YAML.safe_load_file(root.join("_data/surface_placements.yml"), aliases: true)
thinking_placement = placements.find { |placement| placement["artifact"] == "architectural-thinking" }
method_placement = placements.find { |placement| placement["artifact"] == "objective-first-architecture" }
errors << "Architectural Thinking placement changed" unless thinking_placement && thinking_placement["surface"] == "architecture-wall-ways-of-thinking"
errors << "Objective-First Architecture placement changed" unless method_placement && method_placement["surface"] == "architecture-wall-methods"
errors << "Architectural Stewardship was prematurely placed" if placements.any? { |placement| placement.values.any? { |value| value.to_s.match?(/architectural.?stewardship/i) } }

relationships = YAML.safe_load_file(root.join("_data/relationships.yml"), aliases: true)
derivation = relationships.select { |relationship| relationship.values_at("source", "type", "target") == ["objective-first-architecture", "derived_from", "architectural-thinking"] }
errors << "Objective-First relationship to Architectural Thinking changed" unless derivation.length == 1
errors << "Architectural Stewardship was prematurely related" if relationships.any? { |relationship| relationship.values.any? { |value| value.to_s.match?(/architectural.?stewardship/i) } }

wall = site.join("architecture-wall/index.html").read
thinking_html = site.join("architecture-wall/frameworks/architectural-thinking/index.html").read
method_html = site.join("architecture-wall/frameworks/objective-first-architecture/index.html").read
errors << "Architecture Wall taxonomy missing" unless wall.index("Ways of Thinking") && wall.index("Methods in Use") && wall.index("Ways of Thinking") < wall.index("Methods in Use")
errors << "Empty Research Programs section was exposed" if wall.include?("id=\"architecture-wall-programs\"")
errors << "Architectural Thinking humility boundary missing" unless thinking_html.include?("does not claim that DJ invented structural thinking") && thinking_html.include?("does not count as evidence for itself")
errors << "Objective-First operational boundary missing" unless method_html.include?("prevent implementation from outrunning understanding") && method_html.include?("A more detailed repeatable grammar remains under definition")
errors << "Objective-First no longer identifies Architectural Thinking as its broader lens" unless method_html.include?("focused practice within Architectural Thinking")

public_html = site.glob("**/*.html").map(&:read).join("\n")
errors << "Architectural Thinking trademark remains public" if public_html.include?("Architectural Thinking™")
errors << "Architectural Thinking name disappeared" unless public_html.include?("Architectural Thinking")
errors << "Objective-First trademark disappeared" unless public_html.include?("Objective-First Architecture™")
errors << "Architectural Stewardship was published" if public_html.match?(/Architectural Stewardship™?/)
errors << "Footer purpose statement changed" unless site.join("index.html").read.include?("Helping people see complex systems more clearly and build with greater intention.")

abort errors.join("\n") unless errors.empty?
puts "AW-001 valid: Architectural Thinking is a non-proprietary lens, Objective-First Architecture™ is a method in use, Research Programs remain unexposed while empty, and the canonical derivation remains intact."
