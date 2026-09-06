#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "uri"

ROOT = Pathname.new(File.expand_path("..", __dir__))
SITE = ROOT.join("_site")

required_routes = %w[
  /
  /studio/
  /library/
  /workshop/
  /architecture-wall/
  /observatory/
  /meeting-table/
  /explorer-outfitters/
  /meet-dj/
  /search/
  /relationships/
  /unavailable/
  /technical-fallback/
  /library/architecture-series/
  /library/architecture-series/the-architecture-of-being-human-volume-i/
  /library/walk-on-the-wild-side/
  /library/dj-field-guide/
  /workshop/mint-pro/
  /architecture-wall/frameworks/architectural-thinking/
  /architecture-wall/frameworks/objective-first-architecture/
  /the-value-of-wonder/
  /the-view-changes-when-you-climb/
  /everything-is-connected-but-not-everything-is-related/
  /the-difference-between-information-and-understanding/
  /studio-blog/
]

def target_for(url)
  path = URI.decode_www_form_component(url.split(/[?#]/, 2).first)
  relative = path.delete_prefix("/")
  candidate = SITE.join(relative)
  return candidate if candidate.file?
  return candidate.join("index.html") if candidate.directory?
  return SITE.join(relative, "index.html") if File.extname(relative).empty?

  candidate
end

errors = []
required_routes.each do |route|
  errors << "Missing required route: #{route}" unless target_for(route).file?
end

html_files = SITE.glob("**/*.html")
html_files.each do |file|
  html = file.read
  html.scan(/(?:href|src)=["']([^"']+)["']/).flatten.each do |reference|
    next unless reference.start_with?("/") && !reference.start_with?("//")
    errors << "#{file.relative_path_from(SITE)}: missing #{reference}" unless target_for(reference).file?
  end
end

sensitive = SITE.join("FluxMintDigital_Website_Canonical_Package/Assets/source/FMD_SOURCE_MEETDJ_APPROVED_LIKENESS_REFERENCE_v001.jpg")
errors << "Controlled likeness source was emitted into the public build" if sensitive.exist?

studio_html = SITE.join("studio/index.html").read
home_html = SITE.join("index.html").read
%w[FOREST CABINEXTERIOR EXPLORERENTRY].each do |scene|
  errors << "Canonical #{scene} desktop entry source missing" unless home_html.include?("FMD_SCENE_#{scene}_BASE_DESKTOP_DEFAULT_v001.png")
  errors << "Canonical #{scene} mobile entry source missing" unless home_html.match?(/FMD_SCENE_#{scene}_BASE_MOBILE_DEFAULT_v002\.png/)
end
errors << "Entry sequence order changed" unless home_html.index('id="forest"') < home_html.index('id="cabin"') && home_html.index('id="cabin"') < home_html.index('id="explorer-entry"')
errors << "Legacy entry truth leaked" if home_html.match?(/(?:in progress|Identity Architecture, Vol\. V|central hub for every book|Falsifiable, testable)/i)
errors << "Entry must expose direct semantic Room navigation" unless home_html.include?("class=\"room-navigation\"")
explorer_sources = SITE.glob("FluxMintDigital_Website_Canonical_Package/Explorer_DJ_*") + SITE.glob("FluxMintDigital_Website_Canonical_Package/Explorer DJ Regeneration Pack v1.1")
errors << "Explorer source/evidence package was emitted into public build" unless explorer_sources.empty?
errors << "Main Studio desktop source missing" unless studio_html.include?("FMD_SCENE_MAINSTUDIO_BASE_DESKTOP_DEFAULT_v001.png")
errors << "Main Studio canonical mobile v003 source missing" unless studio_html.include?("FMD_SCENE_MAINSTUDIO_BASE_MOBILE_DEFAULT_v003.png")
errors << "Main Studio must expose exactly six semantic thresholds" unless studio_html.scan(/class="scene-threshold scene-threshold--/).length == 6
errors << "Main Studio threshold accessible names missing" unless studio_html.scan(/aria-label="Enter the /).length == 6
errors << "Main Studio Desk\/Now and Map disclosures missing" unless studio_html.scan(/<details class="scene-panel/).length == 2
errors << "Main Studio focus order must present Desk\/Map before Room thresholds" unless studio_html.index("<details class=\"scene-panel") < studio_html.index("<nav class=\"scene-thresholds")

library_html = SITE.join("library/index.html").read
errors << "Library desktop source missing" unless library_html.include?("FMD_SCENE_LIBRARY_BASE_DESKTOP_DEFAULT_v001.png")
errors << "Library mobile source missing" unless library_html.include?("FMD_SCENE_LIBRARY_BASE_MOBILE_DEFAULT_v002.png")
errors << "Library canonical Volume I cover missing" unless library_html.include?("FMD_SOURCE_LIBRARY_ARCHITECTUREOFBEINGHUMAN_VOL01_COVER_v001.png")
errors << "Library must expose three semantic series hotspots" unless library_html.scan(/class="library-hotspot library-hotspot--(?:architecture-series|walk-on-the-wild-side-series|dj-field-guide-series)"/).length == 3
errors << "Library Main Studio return threshold missing" unless library_html.include?("aria-label=\"Return to the Main Studio\"")
errors << "Library publication accessible name missing" unless library_html.include?("aria-label=\"Read The Architecture of Being Human, Volume 1\"")
errors << "Library series access must remain available outside the scene" unless library_html.scan(/class="series-summary surface-card"/).length == 3
errors << "Library keyboard order must present the primary publication before series and return hotspots" unless library_html.index("class=\"library-publication\"") < library_html.index("<nav class=\"library-scene__hotspots\"")

volume_html = SITE.join("library/architecture-series/the-architecture-of-being-human-volume-i/index.html").read
errors << "Volume I must render Published lifecycle" unless volume_html.include?('status-indicator__label">Published</span>')
errors << "Volume I series lineage missing" unless volume_html.include?("Part of The Architecture Series")

workshop_html = SITE.join("workshop/index.html").read
errors << "Workshop desktop source missing" unless workshop_html.include?("FMD_SCENE_WORKSHOP_BASE_DESKTOP_DEFAULT_v001.png")
errors << "Workshop mobile source missing" unless workshop_html.include?("FMD_SCENE_WORKSHOP_BASE_MOBILE_DEFAULT_v002.png")
errors << "Workshop must expose exactly one canonical Current Build" unless workshop_html.scan(/class="workshop-current-build"/).length == 1
errors << "Workshop Current Build must be Mint Pro" unless workshop_html.include?("Inspect current Workshop build: Mint Pro")
errors << "Workshop scene must expose applications, tool access, and return controls" unless workshop_html.scan(/class="workshop-hotspot workshop-hotspot--/).length == 3
errors << "Workshop Main Studio return threshold missing" unless workshop_html.include?("aria-label=\"Return to the Main Studio\"")
errors << "Workshop Current Build must remain available outside the scene" unless workshop_html.scan(/href="\/workshop\/mint-pro\/"/).length >= 3
errors << "Workshop must not expose OmniShell" if workshop_html.match?(/OmniShell/i)
errors << "Workshop must not expose BidMaster" if workshop_html.match?(/Bid\s*Master/i)

mint_pro_html = SITE.join("workshop/mint-pro/index.html").read
errors << "Mint Pro must render On the workbench lifecycle" unless mint_pro_html.include?('status-indicator__label">On the workbench</span>')
errors << "Mint Pro must not invent availability" if mint_pro_html.include?("<dt>Availability</dt>")
errors << "Mint Pro must not invent a version or release" if mint_pro_html.match?(/<dt>(?:Version|Release)<\/dt>/)

wall_html = SITE.join("architecture-wall/index.html").read
errors << "Architecture Wall canonical desktop v002 source missing" unless wall_html.include?("FMD_SCENE_ARCHITECTUREWALL_BASE_DESKTOP_DEFAULT_v002.png")
errors << "Architecture Wall canonical mobile v003 source missing" unless wall_html.include?("FMD_SCENE_ARCHITECTUREWALL_BASE_MOBILE_DEFAULT_v003.png")
errors << "Architecture Wall superseded desktop v001 must not be used" if wall_html.include?("FMD_SCENE_ARCHITECTUREWALL_BASE_DESKTOP_DEFAULT_v001.png")
errors << "Architecture Wall superseded mobile v002 must not be used" if wall_html.include?("FMD_SCENE_ARCHITECTUREWALL_BASE_MOBILE_DEFAULT_v002.png")
errors << "Architecture Wall aperture control missing" unless wall_html.include?("class=\"wall-aperture-control\"")
errors << "Architecture Wall scene must expose frameworks, programs, evidence, and return" unless wall_html.scan(/class="wall-hotspot wall-hotspot--/).length == 4
errors << "Architecture Wall must expose exactly two approved public Frameworks" unless wall_html.scan(/class="artifact-summary surface-card artifact-summary--text-only"/).length == 2
errors << "Architecture Wall must not invent a deeper application route" if wall_html.match?(/href="[^"]*architecture-wall-(?:app|application)|href="[^"]*research-ide/i)
errors << "Architecture Wall must identify the absence of unsupported public research" unless wall_html.include?("No formal claims, evidence, experiments, contradictions, confidence assessments, or validity limits are ready for public display")
errors << "Architecture Wall must state the canonicality boundary" unless wall_html.include?("Being part of the Studio’s current body of work does not make an idea scientifically true")
errors << "Architecture Wall must state that visual prominence is not warrant" unless wall_html.include?("A large, bright, or central object is not automatically more important or better supported")
errors << "Architecture Wall must preserve AEG independence" unless wall_html.include?("Alignment, Equivalence, and Generation are evaluated independently")
errors << "Architecture Wall must reject a combined AEG score" unless wall_html.include?("no combined AEG score exists")
errors << "Architecture Wall must reject AI warrant self-promotion" unless wall_html.include?("cannot grant warrant to its own proposal")
errors << "Architecture Wall must expose all three AEG assertion kinds" unless wall_html.scan(/Nothing publicly asserted yet/).length == 3
errors << "Architecture Wall environmental raster must be identified as non-record content" unless wall_html.include?("papers and diagrams in the room are atmosphere, not research findings")

observatory_html = SITE.join("observatory/index.html").read
errors << "Observatory canonical desktop v002 source missing" unless observatory_html.include?("FMD_SCENE_OBSERVATORY_BASE_DESKTOP_DEFAULT_v002.png")
errors << "Observatory canonical mobile v003 source missing" unless observatory_html.include?("FMD_SCENE_OBSERVATORY_BASE_MOBILE_DEFAULT_v003.png")
errors << "Observatory superseded desktop v001 must not be used" if observatory_html.include?("FMD_SCENE_OBSERVATORY_BASE_DESKTOP_DEFAULT_v001.png")
errors << "Observatory superseded mobile v002 must not be used" if observatory_html.include?("FMD_SCENE_OBSERVATORY_BASE_MOBILE_DEFAULT_v002.png")
errors << "Observatory current observation must use The Value of Wonder" unless observatory_html.include?("Read the current observation: The Value of Wonder")
errors << "Observatory must expose all four canonical forms" unless observatory_html.scan(/class="surface-card">\s*<h3>(?:Essays|Discoveries|Field Notes|Workshop Notes)<\/h3>/).length == 4
errors << "Observatory scene must expose four forms, archive, and return" unless observatory_html.scan(/class="observatory-hotspot observatory-hotspot--/).length == 6
errors << "Observatory must expose four selected real pieces" unless observatory_html.scan(/class="observatory-card surface-card"/).length == 4
errors << "Observatory publication boundary missing" unless observatory_html.include?("When a question needs formal evidence and examination, it belongs on the Architecture Wall")
errors << "Architecture Wall warrant leaked into Observatory as a positive state" if observatory_html.match?(/(?:confidence|AEG warrant)\s*[:=]\s*(?:supported|verified|high|canonical)/i)

priority_metadata = {
  "the-value-of-wonder/index.html" => ["The Value of Wonder", "June 7, 2026"],
  "the-view-changes-when-you-climb/index.html" => ["The View Changes When You Climb", "July 5, 2026"],
  "everything-is-connected-but-not-everything-is-related/index.html" => ["Everything Is Connected… But Not Everything Is Related", "June 14, 2026"],
  "the-difference-between-information-and-understanding/index.html" => ["The Difference Between Information and Understanding", "March 29, 2026"]
}
priority_metadata.each do |relative, (title, date)|
  article = SITE.join(relative).read
  errors << "#{relative}: title metadata changed" unless article.include?(title)
  errors << "#{relative}: source date metadata changed" unless article.include?(date)
  errors << "#{relative}: Observatory epistemic boundary missing" unless article.include?("an invitation to think, not a claim of scientific proof")
end

meeting_html = SITE.join("meeting-table/index.html").read
errors << "Meeting Table desktop source missing" unless meeting_html.include?("FMD_SCENE_MEETINGTABLE_BASE_DESKTOP_DEFAULT_v001.png")
errors << "Meeting Table mobile source missing" unless meeting_html.include?("FMD_SCENE_MEETINGTABLE_BASE_MOBILE_DEFAULT_v002.png")
errors << "Meeting Table scene must expose problem, clarification, blueprint, decision, and return" unless meeting_html.scan(/class="meeting-hotspot meeting-hotspot--/).length == 5
errors << "Meeting Table return threshold missing" unless meeting_html.include?("aria-label=\"Return to the Main Studio\"")
errors << "Meeting Table flow missing" unless meeting_html.include?("Describe → clarify → scope → decide")
errors << "Meeting Table intake must remain local-only" unless meeting_html.include?("data-backend-configured=\"false\"") && !meeting_html.match?(/<form[^>]+action=/)
errors << "Meeting Table intake required fields missing" unless meeting_html.scan(/<(?:textarea|input)[^>]+required/).length >= 5
errors << "Meeting Table must expose all three decision branches" unless meeting_html.scan(/name="decision"/).length == 3
errors << "Meeting Table privacy boundary missing" unless meeting_html.include?("This draft stays on your device. Nothing you type here is sent anywhere")
errors << "Meeting Table implementation must remain optional" unless meeting_html.include?("Building is always a separate decision")
errors << "Meeting Table architecture/examination boundary missing" unless meeting_html.include?("belong on the Architecture Wall—not in a collaboration brief")
errors << "Meeting Table attribution boundary missing" unless meeting_html.include?("Powered by FluxMintDigital")
errors << "Meeting Table contains funnel pricing or marketing consent" if meeting_html.match?(/(?:\$\d|retainer|discount|limited time|marketing consent)/i)
errors << "Meeting Table fabricates social proof" if meeting_html.match?(/(?:testimonial|case stud)/i)

outfitters_html = SITE.join("explorer-outfitters/index.html").read
errors << "Outfitters desktop source missing" unless outfitters_html.include?("FMD_SCENE_EXPLOREROUTFITTERS_BASE_DESKTOP_DEFAULT_v001.png")
errors << "Outfitters mobile source missing" unless outfitters_html.include?("FMD_SCENE_EXPLOREROUTFITTERS_BASE_MOBILE_DEFAULT_v002.png")
errors << "Outfitters scene must expose publications, tools, availability, and return" unless outfitters_html.scan(/class="outfitters-hotspot outfitters-hotspot--/).length == 4
errors << "Outfitters return threshold missing" unless outfitters_html.include?("aria-label=\"Return to the Main Studio\"")
errors << "Outfitters must derive exactly two discovery listings" unless outfitters_html.scan(/class="outfitters-listing surface-card"/).length == 2
errors << "Volume I identity duplicated or detached from Library" unless outfitters_html.include?("href=\"/library/architecture-series/the-architecture-of-being-human-volume-i/\"") && outfitters_html.include?("<dd>Library</dd>")
errors << "Mint Pro identity duplicated or detached from Workshop" unless outfitters_html.include?("href=\"/workshop/mint-pro/\"") && outfitters_html.include?("<dd>Workshop</dd>")
errors << "Outfitters honest empty state missing" unless outfitters_html.include?("Nothing is available to purchase here right now")
errors << "Outfitters environmental inventory boundary missing" unless outfitters_html.include?("only the items listed below are actually available through the Studio")
errors << "Outfitters unexpectedly emitted an external acquisition action" if outfitters_html.include?("rel=\"external noopener\"")
errors << "Outfitters contains fabricated commerce" if outfitters_html.match?(/(?:amazon|google play|etsy|fake discount|limited time|only \d+ left|\$\d)/i)

dj_html = SITE.join("meet-dj/index.html").read
errors << "Meet DJ desktop source missing" unless dj_html.include?("FMD_SCENE_MEETDJ_BASE_DESKTOP_DEFAULT_v001.png")
errors << "Meet DJ mobile source missing" unless dj_html.include?("FMD_SCENE_MEETDJ_BASE_MOBILE_DEFAULT_v002.png")
errors << "Meet DJ production character missing" unless dj_html.include?("FMD_CHAR_MEETDJ_REALISTIC_RESPONSIVE_IDLE_v001.png")
errors << "Meet DJ character must be decorative to semantic identity content" unless dj_html.match?(/class="dj-scene__character"[^>]+alt=""[^>]+aria-hidden="true"/)
errors << "Meet DJ must retain author, builder, and collaborator roles" unless dj_html.include?("Author · Builder · Collaborator")
errors << "Meet DJ role cards changed" unless dj_html.scan(/class="surface-card"><h3>(?:Author|Builder|Collaborator)<\/h3>/).length == 3
errors << "Meet DJ/Explorer identity boundary missing" unless dj_html.include?("The real DJ is the author, builder, and collaborator responsible for the work itself")
errors << "ForgeSpark relationship changed" unless dj_html.include?("ForgeSpark Studios is a sibling studio with its own identity and work")
errors << "Meet DJ Main Studio return missing" unless dj_html.scan(/href="\/studio\/"/).length >= 2
errors << "Controlled likeness source leaked into Meet DJ HTML" if dj_html.include?("FMD_SOURCE_MEETDJ_APPROVED_LIKENESS_REFERENCE_v001")
errors << "Meet DJ contains unsupported resume or social proof claims" if dj_html.match?(/(?:award-winning|years of experience|our clients|testimonial|certified|degree in)/i)

search_html = SITE.join("search/index.html").read
errors << "Search semantic index missing Rooms" unless search_html.scan(/\"type\":\"Room\"/).length == 6
errors << "Search semantic index missing public Artifacts" unless search_html.scan(/\"room\":\"(?:library|workshop|architecture-wall)\"/).length >= 7
errors << "Search results state missing" unless search_html.include?("id=\"search-status\" role=\"status\"") && search_html.include?("id=\"search-results\" aria-live=\"polite\"")

relationships_html = SITE.join("relationships/index.html").read
errors << "Relationship Explorer must render every canonical relationship" unless relationships_html.scan(/class="surface-card"/).length == 9
errors << "Relationship Explorer direction boundary missing" unless relationships_html.include?("An arrow shows the direction of the connection—not cause and effect")
errors << "Relationship Explorer must link every real-person target to Meet DJ" unless relationships_html.scan(/href="\/meet-dj\/"/).length >= 7

unavailable_html = SITE.join("unavailable/index.html").read
errors << "Unavailable state conflates identity and channel" unless unavailable_html.include?("The work still has a home in the Studio even when there is nowhere to purchase or download it yet")
fallback_html = SITE.join("technical-fallback/index.html").read
errors << "Technical fallback lacks semantic Room navigation" unless fallback_html.include?("class=\"room-navigation\" aria-label=\"Rooms\"")
not_found_html = SITE.join("404.html").read
errors << "404 semantic recovery missing" unless not_found_html.include?("aria-label=\"Not-found options\"")
robots = SITE.join("robots.txt")
errors << "Robots configuration missing" unless robots.file?
errors << "Robots sitemap declaration missing" unless robots.file? && robots.read.include?("Sitemap: https://fluxmintdigital.com/sitemap.xml")
errors << "Sitemap missing" unless SITE.join("sitemap.xml").file?

archive_html = SITE.join("studio-blog/index.html").read
errors << "Observatory archive must identify chronology as a history view" unless archive_html.include?("Browse Observatory pieces from newest to oldest")
errors << "Observatory archive must contain all public posts" unless archive_html.scan(/class="post-card"/).length == 20
archive_dates = archive_html.scan(/<time datetime="([^"]+)"/).flatten
errors << "Observatory archive is not reverse chronological" unless archive_dates == archive_dates.sort.reverse

css = SITE.join("assets/css/canonical.css").read
errors << "Reduced-motion contract missing" unless css.include?("prefers-reduced-motion:reduce")
errors << "Minimum target token missing" unless css.include?("--fmd-target:44px")

specimens = SITE.glob("FluxMintDigital_Website_Canonical_Package/Assets/final/FMD_UI_*")
errors << "Flattened UI specimens were emitted into the public build" unless specimens.empty?

superseded_outputs = %w[
  FluxMintDigital_Website_Canonical_Package/Assets/final/FMD_SCENE_MAINSTUDIO_BASE_MOBILE_DEFAULT_v002.png
  FluxMintDigital_Website_Canonical_Package/Assets/final/FMD_SCENE_ARCHITECTUREWALL_BASE_DESKTOP_DEFAULT_v001.png
  FluxMintDigital_Website_Canonical_Package/Assets/final/FMD_SCENE_ARCHITECTUREWALL_BASE_MOBILE_DEFAULT_v002.png
  FluxMintDigital_Website_Canonical_Package/Assets/final/FMD_SCENE_OBSERVATORY_BASE_DESKTOP_DEFAULT_v001.png
  FluxMintDigital_Website_Canonical_Package/Assets/final/FMD_SCENE_OBSERVATORY_BASE_MOBILE_DEFAULT_v002.png
  FluxMintDigital_Website_Canonical_Package/Assets/final/FMD_SCENE_FOREST_BASE_MOBILE_DEFAULT_v001.png
  FluxMintDigital_Website_Canonical_Package/Assets/final/FMD_SCENE_CABINEXTERIOR_BASE_MOBILE_DEFAULT_v001.png
  FluxMintDigital_Website_Canonical_Package/Assets/final/FMD_SCENE_EXPLORERENTRY_BASE_MOBILE_DEFAULT_v001.png
  FMD_UI_ARTIFACT_BOOK_DETAIL_MOBILE_DEFAULT_v001.png
]
emitted_superseded = superseded_outputs.select { |relative| SITE.join(relative).exist? }
errors << "Superseded/reference assets were emitted into the public build: #{emitted_superseded.join(', ')}" unless emitted_superseded.empty?

if errors.empty?
  puts "Build valid: #{required_routes.length} required routes and #{html_files.length} HTML files checked; Main Studio semantics present; controlled/reference assets excluded."
  exit 0
end


warn errors.uniq.join("\n")
exit 1
