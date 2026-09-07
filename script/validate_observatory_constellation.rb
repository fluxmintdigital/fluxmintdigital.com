#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("..", __dir__))

records = [
  {
    slug: "what-i-chose-to-do-with-the-time-i-have-left",
    title: "What I Chose to Do With the Time I Have Left",
    source: "What I Chose to Do With the Time I Have Left.md",
    sha: "d016a8b9f0c9dcde6095b06320426ee113450c96cacfd26d548966b769ad010f",
    order: 1
  },
  {
    slug: "stepping-stones",
    title: "Stepping Stones",
    source: "Stepping Stones.md",
    sha: "da871c678737d48594a2ff91c40d7d44fc6889968ea53c938bdf32d0b533f9ab",
    order: 2
  },
  {
    slug: "the-garage-im-trying-to-build",
    title: "The Garage I’m Trying to Build",
    source: "The Garage I’m Trying to Build.md",
    sha: "64eda31a23d8091fbfa45b1dc7d73eb0f1c5ba6c484e7811f7b591857af1b2c9",
    order: 3
  }
]

errors = []
source_root = ROOT.join("FluxMintDigital_Website_Canonical_Package/Assets/source")

records.each do |record|
  source = source_root.join(record[:source])
  post = ROOT.join("_posts/2026-09-07-#{record[:slug]}.md")
  errors << "Missing source #{record[:source]}" unless source.file?
  errors << "Missing post #{record[:slug]}" unless post.file?
  next unless source.file? && post.file?

  errors << "Source hash changed: #{record[:source]}" unless Digest::SHA256.file(source).hexdigest == record[:sha]
  source_lines = source.read(encoding: "UTF-8").lines
  expected_body = source_lines.drop(2).join
  post_text = post.read(encoding: "UTF-8")
  front_matter_match = post_text.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  unless front_matter_match
    errors << "Missing front matter: #{record[:slug]}"
    next
  end
  data = YAML.safe_load(front_matter_match[1]) || {}
  actual_body = post_text[front_matter_match.end(0)..]
  errors << "Authored body changed: #{record[:slug]}" unless actual_body == expected_body
  errors << "Title changed: #{record[:slug]}" unless data["title"] == record[:title]
  errors << "Constellation order changed: #{record[:slug]}" unless data["constellation_order"] == record[:order]
end

observatory = YAML.safe_load_file(ROOT.join("_data/observatory.yml"))
expected_urls = records.map { |record| "/#{record[:slug]}/" }
errors << "Current observation changed" unless observatory["current_observation"] == expected_urls.first
errors << "Constellation reading order changed" unless observatory["featured"] == expected_urls

relationships = YAML.safe_load_file(ROOT.join("_data/relationships.yml"))
errors << "Unauthorized OmniShell relationship" if relationships.any? { |relationship| relationship.values_at("source", "target").include?("omnishell") }
errors << "Fabricated Kickstarter relationship" if relationships.any? { |relationship| relationship.values_at("source", "target").any? { |value| value.to_s.downcase.include?("kickstarter") } }

site = ROOT.join("_site")
records.each do |record|
  errors << "Missing generated route #{record[:slug]}" unless site.join(record[:slug], "index.html").file?
  errors << "Controlled source leaked: #{record[:source]}" if site.join("FluxMintDigital_Website_Canonical_Package/Assets/source", record[:source]).exist?
end

if errors.empty?
  puts "Observatory constellation valid: 3 authored essays, canonical order preserved, controlled sources excluded."
  exit 0
end

warn errors.join("\n")
exit 1
