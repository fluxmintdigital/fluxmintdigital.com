#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "nokogiri"
require "pathname"
require "yaml"

root = Pathname.new(File.expand_path("..", __dir__))
source = root.join("FluxMintDigital_Website_Canonical_Package/Docs/gravity-well-architecture.md")
post = root.join("_posts/2026-10-02-gravity-well-architecture.md")
site = root.join("_site")
route = "/gravity-well-architecture/"
errors = []

errors << "Gravity Well manuscript is missing" unless source.file?
errors << "Gravity Well publication is missing" unless post.file?

if source.file? && post.file?
  source_lines = source.readlines(encoding: "UTF-8")
  errors << "Gravity Well title heading changed" unless source_lines[0] == "# Gravity Well Architecture\n"
  errors << "Gravity Well subtitle heading changed" unless source_lines[2] == "### A field note from an ecosystem that wasn’t built as a funnel\n"
  expected_body = source_lines.drop(4).join
  post_text = post.read(encoding: "UTF-8")
  match = post_text.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  if match
    data = YAML.safe_load(match[1], permitted_classes: [Date, Time]) || {}
    body = post_text[match.end(0)..]
    errors << "Gravity Well authored body changed" unless body == expected_body
    errors << "Gravity Well title metadata changed" unless data["title"] == "Gravity Well Architecture"
    errors << "Gravity Well subtitle metadata changed" unless data["subtitle"] == "A field note from an ecosystem that wasn’t built as a funnel"
    errors << "Gravity Well author changed" unless data["author"] == "DJ Boswell"
    errors << "Gravity Well must be an Observatory Field Note" unless data["artifact_type"] == "Field Note" && data["canonical_room"] == "observatory" && data.fetch("categories", []).include?("Observatory")
    errors << "Gravity Well Topics must be exactly ecosystem and agency" unless data["tags"] == %w[ecosystem agency]
    errors << "Gravity Well canonical route changed" unless data["permalink"] == route
  else
    errors << "Gravity Well front matter missing"
  end
end

observatory_data = YAML.safe_load_file(root.join("_data/observatory.yml"))
errors << "Gravity Well is not the current observation" unless observatory_data["current_observation"] == route
errors << "Stewardship featured selection changed" unless observatory_data["featured"] == %w[
  /what-i-chose-to-do-with-the-time-i-have-left/
  /stepping-stones/
  /the-garage-im-trying-to-build/
]

gravity_page = site.join("gravity-well-architecture/index.html")
observatory_page = site.join("observatory/index.html")
explorer_page = site.join("relationships/index.html")
errors << "Gravity Well route missing from build" unless gravity_page.file?
errors << "Observatory page missing from build" unless observatory_page.file?
errors << "Relationship Explorer missing from build" unless explorer_page.file?

if gravity_page.file?
  document = Nokogiri::HTML(gravity_page.read)
  errors << "Gravity Well must have one article H1" unless document.css("article.post-page h1").length == 1 && document.at_css("article.post-page h1").text.strip == "Gravity Well Architecture"
  errors << "Gravity Well subtitle must render once" unless document.css("article.post-page .post-subtitle").length == 1 && document.at_css("article.post-page .post-subtitle").text.strip == "A field note from an ecosystem that wasn’t built as a funnel"
  errors << "Gravity Well Field Note presentation missing" unless document.at_css(".post-category")&.text&.include?("Field Note · Observatory")
  errors << "Gravity Well closing epistemic disclaimer missing" unless document.text.include?("Alternative explanations remain open.")
  errors << "Gravity Well canonical tag missing or duplicated" unless document.css('link[rel="canonical"]').count { |node| node["href"] == "https://fluxmintdigital.com#{route}" } == 1
end

if observatory_page.file?
  document = Nokogiri::HTML(observatory_page.read)
  html = observatory_page.read
  errors << "Current observation does not feature Gravity Well" unless html.include?("aria-label=\"Read the current observation: Gravity Well Architecture\"")
  errors << "Field Notes form does not show its first public piece" unless html.include?("<h3>Field Notes</h3>") && html.match?(/<h3>Field Notes<\/h3>.*?1 public piece/m)
  record_items = document.css("#observatory-record .observatory-record__item")
  record_titles = record_items.map { |item| item.at_css("h3")&.text&.strip }
  gravity_index = record_titles.index("Gravity Well Architecture")
  september_index = record_titles.index("What Deserves the Right to Change the Work?")
  errors << "Gravity Well missing from chronological Observatory Record" unless gravity_index
  errors << "September 8 observation missing from Observatory Record" unless september_index
  errors << "Gravity Well must precede September 8 in the chronological record" unless gravity_index && september_index && gravity_index < september_index
  errors << "Field Note form description or room boundary changed" unless html.include?("Direct observations recorded close to the moment of noticing")
  errors << "Observatory to Library bridge changed" unless html.include?('data-depth-transition="observatory_to_library"')
end

relationships = YAML.safe_load_file(root.join("_data/relationships.yml"))
errors << "Canonical relationship record count changed" unless relationships.length == 50
errors << "Gravity Well was given an unapproved canonical relationship" if relationships.any? { |relationship| [relationship["source"], relationship["target"]].include?("gravity-well-architecture") }
if explorer_page.file?
  errors << "Relationship Explorer must retain all canonical records" unless explorer_page.read.scan("data-relationship-record").length == 50
end

sitemap = site.join("sitemap.xml")
errors << "Gravity Well sitemap entry missing or duplicated" unless sitemap.file? && sitemap.read.scan("https://fluxmintdigital.com#{route}").length == 1

abort errors.join("\n") unless errors.empty?
puts "Gravity Well publication valid: authored body preserved, Field Note/current/archive presentation correct, canonical relationships intact, and route discoverable."
