#!/usr/bin/env ruby
# frozen_string_literal: true

require "nokogiri"
require "pathname"
require "yaml"

root = Pathname.new(File.expand_path("..", __dir__))
site = root.join("_site")
errors = []

read = ->(route) { site.join(route, "index.html").read }
outfitters = read.call("explorer-outfitters")
library = read.call("library")
workshop = read.call("workshop")
studio = read.call("studio")
archive = read.call("studio-blog")
book = read.call("library/architecture-series/the-architecture-of-being-human-volume-i")
relationships = read.call("relationships")
observatory = read.call("observatory")
meet_dj = read.call("meet-dj")
home = read.call("")

available = outfitters[/data-availability-group="available".*?data-availability-group="unavailable"/m].to_s
future = outfitters[/data-availability-group="unavailable".*?<\/div>\s*<\/section>/m].to_s
errors << "Available Outfitters group does not contain the architecture book" unless available.include?("The Architecture of Being Human")
errors << "Available Outfitters group does not contain Personal Architecture Map" unless available.include?("The Personal Architecture Map")
errors << "Mint Pro leaked into the available Outfitters group" if available.include?("Mint Pro")
errors << "Mint Pro missing from the future Outfitters group" unless future.include?("Mint Pro")
errors << "Choice Audit was forced into Outfitters" if outfitters.include?("outfitters-choice-audit")

errors << "Architecture Series count is not lifecycle-derived" unless library.include?("1 published volume")
errors << "Awaiting-publication counts are not lifecycle-derived" unless library.scan("1 volume awaiting publication").length == 2
errors << "Unsupported publication timing promise remains" if [
  read.call("library/walk-on-the-wild-side/everything-looks-different-from-the-other-side-volume-i"),
  read.call("library/dj-field-guide/the-dj-field-guide-to-matter-volume-i")
].any? { |html| html.match?(/released soon|coming soon/i) }

archive_positions = [
  "What I Chose to Do With the Time I Have Left",
  "Stepping Stones",
  "The Garage I’m Trying to Build"
].map { |title| archive.index(title) }
errors << "Same-date Observatory order changed" unless archive_positions.all? && archive_positions == archive_positions.sort

desk = studio[/<div class="scene-panel__items">.*?<\/div>\s*<\/div>\s*<\/details>/m].to_s
desk_titles = ["What I Chose to Do With the Time I Have Left", "The Choice Audit", "Everything Looks Different from the Other Side", "Mint Pro"]
errors << "Desk curation changed" unless desk_titles.all? { |title| desk.include?(title) } && desk.scan("<article>").length == 4

errors << "Workshop workbench grouping changed" unless workshop.include?("Applications taking shape") && workshop.include?("Mint Pro") && workshop.include?("BidMaster")
errors << "Workshop released grouping changed" unless workshop.include?("Released instruments") && workshop.include?("The Choice Audit") && workshop.include?("The Personal Architecture Map")

errors << "Architecture book constellation heading missing" unless book.include?("Continue exploring this architecture")
errors << "Architecture book constellation paths missing" unless book.include?("/workshop/choice-audit/") && book.include?("/workshop/personal-architecture-map/")
errors << "Relationship Explorer lacks by-work mode" unless relationships.include?("data-relationship-work")
errors << "Relationship Explorer lacks derived thread mode" unless relationships.include?("data-relationship-thread")
canonical_relationship_count = YAML.safe_load_file(root.join("_data/relationships.yml")).length
errors << "Relationship Explorer diverged from the canonical graph" unless relationships.scan("data-relationship-record").length == canonical_relationship_count
errors << "Zero-count Observatory forms remain primary cards" if observatory.match?(/class="surface-card">\s*<h3>(?:Discoveries|Field Notes|Workshop Notes)<\/h3>/)
errors << "Meet DJ Observatory continuation missing" unless meet_dj.include?('href="/observatory/">Read from the Observatory</a>')

home_document = Nokogiri::HTML(home)
home_links = home_document.css("a[href]").map { |link| link["href"] }
required_crawler_routes = %w[/studio/ /library/ /workshop/ /architecture-wall/ /observatory/ /meeting-table/ /explorer-outfitters/ /meet-dj/]
errors << "Threshold page does not expose direct semantic Room links" unless (required_crawler_routes - home_links).empty?
errors << "Sitemap is missing" unless site.join("sitemap.xml").file?
errors << "Robots file is missing" unless site.join("robots.txt").file?

site.glob("**/*.html").each do |path|
  document = Nokogiri::HTML(path.read)
  errors << "Generated document has no main landmark" unless document.at_css("main")
end

abort errors.join("\n") unless errors.empty?
puts "WR-005 valid: truthful acquisition/lifecycle grouping, deterministic Observatory order, four-item Desk, contextual constellations, and one #{canonical_relationship_count}-record relationship graph."
