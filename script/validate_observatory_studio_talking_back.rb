#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "digest"
require "pathname"
require "yaml"

root = Pathname.new(File.expand_path("..", __dir__))
source = root.join("FluxMintDigital_Website_Canonical_Package/Assets/source/When the Studio Starts Talking Back.md")
post = root.join("_posts/2026-09-07-when-the-studio-started-talking-back.md")
site = root.join("_site")
errors = []

expected_sha = "b58ed27e955c831af61717977d2d546eee6ad1dbb3ebb1214fdc614ddc5e127a"
errors << "Controlled OBS-002 source is missing or changed" unless source.file? && Digest::SHA256.file(source).hexdigest == expected_sha
errors << "OBS-002 publication source is missing" unless post.file?

if source.file? && post.file?
  source_body = source.readlines(encoding: "UTF-8").drop(2).join.delete_suffix("\n")
  post_text = post.read(encoding: "UTF-8")
  match = post_text.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  if match
    data = YAML.safe_load(match[1], permitted_classes: [Date, Time]) || {}
    post_body = post_text[match.end(0)..].delete_suffix("\n")
    errors << "Authored OBS-002 body changed" unless post_body == source_body
    errors << "OBS-002 title changed" unless data["title"] == "When the Studio Started Talking Back"
    errors << "OBS-002 description is not the authored opening sentence" unless data["description"] == "I recently spent a surprising amount of time rebuilding a website."
    errors << "OBS-002 route changed" unless data["permalink"] == "/when-the-studio-started-talking-back/"
    errors << "OBS-002 form changed" unless data.fetch("categories", []).include?("Observatory")
    errors << "OBS-002 topics changed" unless data["tags"] == %w[architecture making observatory]
    errors << "OBS-002 same-date archive position changed" unless data["same_date_order"] == 0
  else
    errors << "OBS-002 front matter missing"
  end
end

relationships = YAML.safe_load_file(root.join("_data/relationships.yml"))
expected_targets = %w[
  building-a-studio-instead-of-a-brand
  behind-the-studio
  nothing-meaningful-is-built-overnight
  stepping-stones
  why-we-create
]
actual = relationships.select { |relationship| relationship["source"] == "when-the-studio-started-talking-back" }
errors << "OBS-002 relationships changed" unless actual.length == 5 && actual.all? { |relationship| relationship["type"] == "companion_to" } && actual.map { |relationship| relationship["target"] }.sort == expected_targets.sort

observatory = YAML.safe_load_file(root.join("_data/observatory.yml"))
errors << "OBS-002 displaced the curated current observation" unless observatory["current_observation"] == "/what-i-chose-to-do-with-the-time-i-have-left/"
errors << "OBS-002 disrupted the curated OBS-001 selection" unless observatory["featured"] == %w[/what-i-chose-to-do-with-the-time-i-have-left/ /stepping-stones/ /the-garage-im-trying-to-build/]

route = site.join("when-the-studio-started-talking-back/index.html")
errors << "OBS-002 route missing from build" unless route.file?
if route.file?
  html = route.read
  errors << "OBS-002 relationship rendering missing" unless expected_targets.all? { |target| html.include?("/#{target}/") }
end
archive = site.join("studio-blog/index.html")
if archive.file?
  html = archive.read
  new_position = html.index("When the Studio Started Talking Back")
  obs001_positions = ["What I Chose to Do With the Time I Have Left", "Stepping Stones", "The Garage I’m Trying to Build"].map { |title| html.index(title) }
  errors << "OBS-002 archive placement or OBS-001 order changed" unless new_position && obs001_positions.all? && new_position < obs001_positions.first && obs001_positions == obs001_positions.sort
end

errors << "Controlled OBS-002 source leaked into public build" if site.join("FluxMintDigital_Website_Canonical_Package/Assets/source/When the Studio Starts Talking Back.md").exist?
sitemap = site.join("sitemap.xml")
errors << "OBS-002 sitemap entry missing or duplicated" unless sitemap.file? && sitemap.read.scan("https://fluxmintdigital.com/when-the-studio-started-talking-back/").length == 1

abort errors.join("\n") unless errors.empty?
puts "OBS-002 valid: authored body preserved, curated Observatory state retained, five canonical companion relationships, and controlled source excluded."
