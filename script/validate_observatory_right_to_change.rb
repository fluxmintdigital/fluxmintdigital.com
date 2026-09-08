#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "digest"
require "pathname"
require "yaml"

root = Pathname.new(File.expand_path("..", __dir__))
source = root.join("FluxMintDigital_Website_Canonical_Package/Assets/source/What Deserves the Right to Change the Work?.md")
post = root.join("_posts/2026-09-08-what-deserves-the-right-to-change-the-work.md")
site = root.join("_site")
errors = []

expected_sha = "461dd7894e5d98cbe5d696b9c7874f762a72eacf1d7a921508ab5beb571086cc"
expected_title = "What Deserves the Right to Change the Work?"
expected_description = "I was talking with my mother about one of my books when a fairly ordinary question turned into something larger."
expected_route = "/what-deserves-the-right-to-change-the-work/"
expected_tags = %w[architecture evidence making uncertainty decisions]
expected_targets = %w[
  architecture-of-being-human-volume-i
  when-the-studio-started-talking-back
  stepping-stones
  why-we-create
  the-architecture-of-everyday-decisions
  living-an-examined-life
  choice-audit
]

errors << "Controlled OBS-003 source is missing or changed" unless source.file? && Digest::SHA256.file(source).hexdigest == expected_sha
errors << "OBS-003 publication source is missing" unless post.file?

if source.file? && post.file?
  expected_body = source.readlines(encoding: "UTF-8").drop(2).join
  post_text = post.read(encoding: "UTF-8")
  match = post_text.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  if match
    data = YAML.safe_load(match[1], permitted_classes: [Date, Time]) || {}
    actual_body = post_text[match.end(0)..]
    errors << "Authored OBS-003 body changed" unless actual_body == expected_body
    errors << "OBS-003 title changed" unless data["title"] == expected_title
    errors << "OBS-003 description changed" unless data["description"] == expected_description
    errors << "OBS-003 route changed" unless data["permalink"] == expected_route
    errors << "OBS-003 form changed" unless data.fetch("categories", []).include?("Observatory")
    errors << "OBS-003 topics changed" unless data["tags"] == expected_tags
  else
    errors << "OBS-003 front matter missing"
  end
end

relationships = YAML.safe_load_file(root.join("_data/relationships.yml"))
actual = relationships.select { |relationship| relationship["source"] == "what-deserves-the-right-to-change-the-work" }
companion_targets = actual.select { |relationship| relationship["type"] == "companion_to" }.map { |relationship| relationship["target"] }
errors << "OBS-003 companion relationships changed" unless companion_targets == expected_targets
authorship = actual.select { |relationship| relationship["type"] == "authored_by" && relationship["target"] == "dj-boswell" }
errors << "OBS-003 authorship relationship missing" unless authorship.length == 1
errors << "OBS-003 has duplicate relationship records" unless relationships.map { |relationship| relationship.values_at("source", "type", "target") }.uniq.length == relationships.length

observatory = YAML.safe_load_file(root.join("_data/observatory.yml"))
errors << "OBS-003 is not the current observation" unless observatory["current_observation"] == expected_route
errors << "OBS-001 selection changed" unless observatory["featured"] == %w[/what-i-chose-to-do-with-the-time-i-have-left/ /stepping-stones/ /the-garage-im-trying-to-build/]

route = site.join("what-deserves-the-right-to-change-the-work/index.html")
errors << "OBS-003 route missing from build" unless route.file?
if route.file?
  html = route.read
  errors << "OBS-003 relationship rendering missing" unless expected_targets.all? { |target| html.include?("/#{target}/") || target == "architecture-of-being-human-volume-i" && html.include?("/library/architecture-series/the-architecture-of-being-human-volume-i/") || target == "choice-audit" && html.include?("/workshop/choice-audit/") }
end

archive = site.join("studio-blog/index.html")
if archive.file?
  archive_html = archive.read
  new_position = archive_html.index(expected_title)
  prior_position = archive_html.index("When the Studio Started Talking Back")
  errors << "OBS-003 is not first in the archive" unless new_position && prior_position && new_position < prior_position
else
  errors << "Observatory archive missing"
end
errors << "Controlled OBS-003 source leaked into public build" if site.join("FluxMintDigital_Website_Canonical_Package/Assets/source/What Deserves the Right to Change the Work?.md").exist?
sitemap = site.join("sitemap.xml")
errors << "OBS-003 sitemap entry missing or duplicated" unless sitemap.file? && sitemap.read.scan("https://fluxmintdigital.com#{expected_route}").length == 1

abort errors.join("\n") unless errors.empty?
puts "OBS-003 valid: authored body preserved, current observation designated, seven contextual companions plus authorship, and controlled source excluded."
