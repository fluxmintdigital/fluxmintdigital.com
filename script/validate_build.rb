#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "uri"
require "yaml"

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
  /library/walk-on-the-wild-side/everything-looks-different-from-the-other-side-volume-i/
  /library/dj-field-guide/
  /library/dj-field-guide/the-dj-field-guide-to-matter-volume-i/
  /workshop/mint-pro/
  /workshop/bidmaster/
  /workshop/choice-audit/
  /workshop/personal-architecture-map/
  /architecture-wall/frameworks/architectural-thinking/
  /architecture-wall/frameworks/objective-first-architecture/
  /the-value-of-wonder/
  /the-view-changes-when-you-climb/
  /everything-is-connected-but-not-everything-is-related/
  /the-difference-between-information-and-understanding/
  /what-i-chose-to-do-with-the-time-i-have-left/
  /stepping-stones/
  /the-garage-im-trying-to-build/
  /when-the-studio-started-talking-back/
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
wild_side_source = SITE.join("FluxMintDigital_Website_Canonical_Package/Assets/source/FMD_SOURCE_LIBRARY_WALKONTHEWILDSIDE_VOL01_COVER_v001.png")
errors << "Controlled Walk on the Wild Side cover master was emitted into the public build" if wild_side_source.exist?
field_guide_source = SITE.join("FluxMintDigital_Website_Canonical_Package/Assets/source/FMD_SOURCE_LIBRARY_DJFIELDGUIDE_MATTER_VOL01_COVER_v001.png")
errors << "Controlled DJ Field Guide cover master was emitted into the public build" if field_guide_source.exist?
choice_cover_source = SITE.join("FluxMintDigital_Website_Canonical_Package/Assets/source/FMD_PERSONAL_ARCHITECTURE_MAP_COVER_v1.png")
errors << "Controlled Personal Architecture Map cover master was emitted into the public build" if choice_cover_source.exist?
choice_pdf_source = SITE.join("FluxMintDigital_Website_Canonical_Package/Assets/source/FluxMintDigital_The_Personal_Architecture_Map_v1.pdf")
errors << "Controlled Personal Architecture Map PDF was emitted into the public build" if choice_pdf_source.exist?
choice_handoff = SITE.join("FluxMintDigital_Website_Canonical_Package/Assets/source/FluxMintDigital_Choice_Audit_Codex_Handoff_Package_v1.0")
errors << "Controlled Choice Audit handoff package was emitted into the public build" if choice_handoff.exist?
errors << "Choice Audit browser test fixture was emitted into the public build" if SITE.join("script/fixtures/choice-audit-model.html").exist?
errors << "Internal Experience and Interaction Audit was emitted into the public build" if SITE.join("FluxMintDigital_Experience_and_Interaction_Audit/index.html").exist?

seo_properties = {
  "title" => /<title(?:\s|>)/,
  "description" => /<meta name="description"/,
  "canonical" => /<link rel="canonical"/,
  "Open Graph title" => /<meta property="og:title"/,
  "Open Graph description" => /<meta property="og:description"/,
  "Open Graph URL" => /<meta property="og:url"/,
  "Twitter title" => /<meta (?:name|property)="twitter:title"/
}
html_files.each do |file|
  html = file.read
  seo_properties.each do |label, pattern|
    count = html.scan(pattern).length
    errors << "#{file.relative_path_from(SITE)}: expected one #{label}, found #{count}" unless count == 1
  end
end

studio_html = SITE.join("studio/index.html").read
home_html = SITE.join("index.html").read
%w[FOREST CABINEXTERIOR EXPLORERENTRY].each do |scene|
  errors << "Canonical #{scene} desktop entry source missing" unless home_html.include?("FMD_SCENE_#{scene}_BASE_DESKTOP_DEFAULT_v001.png")
  errors << "Canonical #{scene} mobile entry source missing" unless home_html.match?(/FMD_SCENE_#{scene}_BASE_MOBILE_DEFAULT_v002\.png/)
end
errors << "Entry sequence order changed" unless home_html.index('id="forest"') < home_html.index('id="cabin"') && home_html.index('id="cabin"') < home_html.index('id="explorer-entry"')
errors << "Legacy entry truth leaked" if home_html.match?(/(?:in progress|Identity Architecture, Vol\. V|central hub for every book|Falsifiable, testable)/i)
errors << "Entry must expose direct semantic Room navigation" unless home_html.include?("class=\"room-navigation\"")
errors << "Disabled Explorer feature emitted character markup" if home_html.include?("data-explorer-idle")
errors << "Disabled Explorer feature emitted controller code" if home_html.include?("explorerInitialized")
errors << "Disabled Explorer feature requested delivery frames" if home_html.include?("FMD_CHAR_EXPLORERENTRY_DJ_IDLE")
errors << "Disabled Explorer delivery directory was emitted" if SITE.join("assets/images/explorer-entry").exist?
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
errors << "Library scene must retain one non-overlapping featured publication" unless library_html.scan(/class="library-publication"/).length == 1
errors << "Architecture Series lifecycle count changed" unless library_html.include?("1 published volume")
errors << "Awaiting-publication series counts changed" unless library_html.scan(/1 volume awaiting publication/).length == 2
errors << "Library contains stale series-count copy" if library_html.include?("No volumes announced yet")

volume_html = SITE.join("library/architecture-series/the-architecture-of-being-human-volume-i/index.html").read
errors << "Volume I must render Published lifecycle" unless volume_html.include?('status-indicator__label">Published</span>')
errors << "Volume I series lineage missing" unless volume_html.include?("Part of The Architecture Series")

wild_side_html = SITE.join("library/walk-on-the-wild-side/everything-looks-different-from-the-other-side-volume-i/index.html").read
errors << "Walk on the Wild Side Volume I must render Awaiting publication lifecycle" unless wild_side_html.include?('status-indicator__label">Awaiting publication</span>')
errors << "Walk on the Wild Side Volume I availability must remain unavailable" unless wild_side_html.include?("<dt>Availability</dt><dd>Not available yet</dd>")
errors << "Walk on the Wild Side Volume I publication wording changed" unless wild_side_html.include?("Volume I is written and awaiting publication.")
errors << "Walk on the Wild Side Volume I contains an unsupported timing promise" if wild_side_html.match?(/released soon|coming soon/i)
errors << "Walk on the Wild Side Volume I series lineage missing" unless wild_side_html.include?("Part of Walk on the Wild Side With DJ")
errors << "Walk on the Wild Side Volume I cover derivative missing" unless wild_side_html.include?("FMD_ARTIFACT_LIBRARY_WALKONTHEWILDSIDE_VOL01_COVER_768W_v001.webp")
errors << "Walk on the Wild Side Volume I must not expose acquisition controls" if wild_side_html.include?("acquisition-actions")
errors << "Walk on the Wild Side Volume I must not invent release or commerce facts" if wild_side_html.match?(/(?:amazon\.com|ISBN|\$\d|datePublished|dateModified|Publication date|Format)/i)

wild_side_series_html = SITE.join("library/walk-on-the-wild-side/index.html").read
errors << "Walk on the Wild Side series must expose exactly one real volume" unless wild_side_series_html.scan(/class="artifact-summary surface-card/).length == 1
errors << "Walk on the Wild Side series must link Volume I" unless wild_side_series_html.include?("/library/walk-on-the-wild-side/everything-looks-different-from-the-other-side-volume-i/")
errors << "Walk on the Wild Side series must retain future-volume language" unless wild_side_series_html.include?("More volumes will appear here as the series grows")
errors << "Library must expose Walk on the Wild Side Volume I" unless library_html.include?("/library/walk-on-the-wild-side/everything-looks-different-from-the-other-side-volume-i/")

field_guide_html = SITE.join("library/dj-field-guide/the-dj-field-guide-to-matter-volume-i/index.html").read
errors << "DJ Field Guide Volume I must render Awaiting publication lifecycle" unless field_guide_html.include?('status-indicator__label">Awaiting publication</span>')
errors << "DJ Field Guide Volume I availability must remain unavailable" unless field_guide_html.include?("<dt>Availability</dt><dd>Not available yet</dd>")
errors << "DJ Field Guide Volume I publication wording changed" unless field_guide_html.include?("Volume I is written and awaiting publication.")
errors << "DJ Field Guide Volume I contains an unsupported timing promise" if field_guide_html.match?(/released soon|coming soon/i)
errors << "DJ Field Guide Volume I series lineage missing" unless field_guide_html.include?("Part of The DJ Field Guide Series")
errors << "DJ Field Guide Volume I cover derivative missing" unless field_guide_html.include?("FMD_ARTIFACT_LIBRARY_DJFIELDGUIDE_MATTER_VOL01_COVER_768W_v001.webp")
errors << "DJ Field Guide Volume I must not expose acquisition controls" if field_guide_html.include?("acquisition-actions")
errors << "DJ Field Guide Volume I must not invent release or commerce facts" if field_guide_html.match?(/(?:amazon\.com|ISBN|\$\d|datePublished|dateModified|Publication date|Format)/i)

field_guide_series_html = SITE.join("library/dj-field-guide/index.html").read
errors << "DJ Field Guide series must expose exactly one real volume" unless field_guide_series_html.scan(/class="artifact-summary surface-card/).length == 1
errors << "DJ Field Guide series must link Volume I" unless field_guide_series_html.include?("/library/dj-field-guide/the-dj-field-guide-to-matter-volume-i/")
errors << "DJ Field Guide series must retain future-volume language" unless field_guide_series_html.include?("More volumes will appear here as the series grows")
errors << "Library must expose DJ Field Guide Volume I" unless library_html.include?("/library/dj-field-guide/the-dj-field-guide-to-matter-volume-i/")

workshop_html = SITE.join("workshop/index.html").read
errors << "Workshop desktop source missing" unless workshop_html.include?("FMD_SCENE_WORKSHOP_BASE_DESKTOP_DEFAULT_v001.png")
errors << "Workshop mobile source missing" unless workshop_html.include?("FMD_SCENE_WORKSHOP_BASE_MOBILE_DEFAULT_v002.png")
errors << "Workshop must expose exactly one canonical Current Build" unless workshop_html.scan(/class="workshop-current-build"/).length == 1
errors << "Workshop Current Build must be Mint Pro" unless workshop_html.include?("Inspect current Workshop build: Mint Pro")
errors << "Workshop scene must expose applications, tool access, and return controls" unless workshop_html.scan(/class="workshop-hotspot workshop-hotspot--/).length == 3
errors << "Workshop Main Studio return threshold missing" unless workshop_html.include?("aria-label=\"Return to the Main Studio\"")
errors << "Workshop Current Build must remain available outside the scene" unless workshop_html.scan(/href="\/workshop\/mint-pro\/"/).length >= 2
errors << "Workshop must not expose OmniShell" if workshop_html.match?(/OmniShell/i)
errors << "Workshop must expose BidMaster exactly once in its conventional application list" unless workshop_html.scan(/href="\/workshop\/bidmaster\/"/).length == 1
errors << "Workshop must expose both approved Instruments" unless workshop_html.include?('href="/workshop/choice-audit/"') && workshop_html.include?('href="/workshop/personal-architecture-map/"')

choice_html = SITE.join("workshop/choice-audit/index.html").read
errors << "Choice Audit must remain a released Workshop Instrument" unless choice_html.include?("Instrument · Workshop") && choice_html.include?('status-indicator__label">Released</span>')
errors << "Choice Audit browser usability is still conflated with acquisition availability" if choice_html.include?("<dt>Availability</dt><dd>Not available yet</dd>")
errors << "Choice Audit browser-use receipt missing" unless choice_html.include?("<dt>Use</dt><dd>Free browser instrument</dd>")
errors << "Choice Audit shell lost its governing question" unless choice_html.include?("What participated in this choice?")
errors << "Choice Audit shell must preserve the no-gate contract" unless choice_html.include?("no email address, account, purchase, or personal information")
errors << "Choice Audit shell must not expose an acquisition action" if choice_html.include?('class="acquisition-actions"')
errors << "Choice Audit dedicated controller missing or duplicated" unless choice_html.scan('src="/assets/js/choice-audit-controller.js"').length == 1
expected_force_order = %w[desire expectation security opportunity identity obligation fearAvoidance possibility]
actual_force_order = choice_html.scan(/data-force="([^"]+)"/).flatten
errors << "Choice Audit force regions missing or out of canonical order" unless actual_force_order == expected_force_order
errors << "Choice Audit must expose one reflection field per force" unless choice_html.scan(/data-force-reflection/).length == 8
errors << "Choice Audit overlapping classification controls changed" unless choice_html.scan(/data-force-classification/).length == 40
errors << "Choice Audit qualitative influence controls changed" unless choice_html.scan(/data-force-influence/).length == 24 && choice_html.scan(/Influence, not score\./).length == 8
errors << "Choice Audit privacy receipt missing" unless choice_html.include?("Your map is yours") && choice_html.include?("Your reflections stay on this device")
errors << "Choice Audit returning-audit contract missing" unless choice_html.include?("Your previous map is still here on this device") && choice_html.include?(">Continue</button>") && choice_html.include?("Start another audit")
errors << "Choice Audit relationship builder missing" unless choice_html.include?("Add ↔ Interaction") && choice_html.include?("does not infer relationships") && choice_html.include?("does not prove causation")
errors << "Choice Audit working field must begin disabled for progressive enhancement" unless choice_html.match?(/<fieldset class="choice-audit__field"[^>]+disabled/)
errors << "Choice Audit no-JavaScript explanation or exits missing" unless choice_html.include?("The interactive working field needs JavaScript") && choice_html.include?('href="/workshop/personal-architecture-map/"') && choice_html.include?('href="/workshop/"')
choice_field_html = choice_html[/<section class="choice-audit".*?<\/section>\s*<script type="module"/m].to_s
errors << "Acquisition action leaked into Choice Audit working field" if choice_field_html.include?("acquisition-actions") || choice_field_html.match?(/Gumroad|Ko-fi|\$12/)
errors << "Progress or results UI leaked into Choice Audit" if choice_field_html.match?(/progress-bar|completion-ring|Your Results|\bpercent(?:age)?\b/i)
expected_temporal = { "then" => "What was true or most salient then?", "after" => "What became visible only afterward?", "now" => "What do I see more clearly now?" }
expected_temporal.each do |key, prompt|
  errors << "Choice Audit #{key} field or prompt missing" unless choice_field_html.include?("data-temporal=\"#{key}\"") && choice_field_html.include?(prompt)
end
errors << "Choice Audit counterfactual field missing" unless choice_field_html.include?("What might have changed the choice?") && choice_field_html.include?("data-counterfactual-reflection")
errors << "Choice Audit counterfactual vocabulary changed" unless %w[Yes No Maybe Unknown].all? { |value| choice_field_html.include?("data-counterfactual-response=\"\"&gt; #{value}") || choice_field_html.match?(/value="#{value}" data-counterfactual-response/) }
%w[supports challenges alternatives uncertainty].each do |field|
  errors << "Choice Audit Evidence Lens field missing: #{field}" unless choice_field_html.include?("data-evidence=\"#{field}\"")
end
errors << "Choice Audit Evidence Lens heading changed" unless choice_field_html.match?(/Before you decide what it means/i)
errors << "Choice Audit hindsight check missing" unless choice_field_html.include?("Am I reconstructing the decision differently because I know what happened afterward?")
errors << "Choice Audit preservation or final reflection field missing" unless choice_field_html.include?("data-preservation") && choice_field_html.include?("data-final-reflection") && choice_field_html.match?(/What do you notice\?/i)
expected_maps = ["Formation", "Inheritance", "Recognition", "Choice Audit", "Alignment", "Friction", "Negative Geometry", "Influence / Control", "Becoming", "Personal Architecture"]
map_positions = expected_maps.map { |label| choice_field_html.index("> #{label}</li>") || choice_field_html.index(">#{label}</") }
errors << "Choice Audit larger-architecture sequence missing or reordered" unless map_positions.all? && map_positions == map_positions.sort
errors << "Choice Audit reveal must begin hidden" unless choice_field_html.match?(/data-architecture-reveal[^>]+hidden/)
errors << "Choice Audit Alignment question missing" unless choice_field_html.include?("Where does my life reinforce what matters to me?")
errors << "Choice Audit reveal exits changed" unless choice_field_html.include?("Explore the Personal Architecture Map") && choice_field_html.include?("Return to Workshop")

choice_model = SITE.join("assets/js/choice-audit-model.js")
errors << "Choice Audit local model was not emitted" unless choice_model.file?
if choice_model.file?
  choice_model_source = choice_model.read
  %w[localStorage sessionStorage document.cookie XMLHttpRequest sendBeacon].each do |forbidden_api|
    errors << "Choice Audit local model uses forbidden persistence/network API: #{forbidden_api}" if choice_model_source.include?(forbidden_api)
  end
  errors << "Choice Audit local model must not initiate remote requests" if choice_model_source.match?(/\bfetch\s*\(/)
  errors << "Choice Audit local model schema version missing" unless choice_model_source.include?("const SCHEMA_VERSION = 1")
  errors << "Choice Audit local reflection classification missing" unless choice_model_source.include?('const DATA_CLASSIFICATION = "LOCAL_REFLECTION_DATA"')
  errors << "Choice Audit storage-failure wording changed" unless choice_model_source.include?("This audit could not be saved on this device. Your current work is still available in this session.")
end
choice_controller = SITE.join("assets/js/choice-audit-controller.js")
errors << "Choice Audit controller was not emitted" unless choice_controller.file?
if choice_controller.file?
  controller_source = choice_controller.read
  %w[localStorage sessionStorage document.cookie XMLHttpRequest sendBeacon].each do |forbidden_api|
    errors << "Choice Audit controller uses forbidden persistence/network API: #{forbidden_api}" if controller_source.include?(forbidden_api)
  end
  errors << "Choice Audit controller must not initiate remote requests" if controller_source.match?(/\bfetch\s*\(/)
end

map_html = SITE.join("workshop/personal-architecture-map/index.html").read
errors << "Personal Architecture Map must remain a released Workshop Instrument" unless map_html.include?("Instrument · Workshop") && map_html.include?('status-indicator__label">Released</span>')
errors << "Personal Architecture Map cover derivatives missing" unless %w[480W 768W 1024W].all? { |width| map_html.include?("FMD_ARTIFACT_WORKSHOP_PERSONALARCHITECTUREMAP_COVER_#{width}_v001.webp") }
errors << "Personal Architecture Map canonical price treatment changed" unless map_html.include?("$12") && map_html.include?("You may pay more if you’d like.")
expected_gumroad = "https://fluxmint.gumroad.com/l/personal-architecture-map"
expected_kofi = "https://ko-fi.com/s/d9287edf31"
errors << "Personal Architecture Map Gumroad rail missing or duplicated" unless map_html.scan(expected_gumroad).length == 1
errors << "Personal Architecture Map Ko-fi rail missing or duplicated" unless map_html.scan(expected_kofi).length == 1
errors << "Personal Architecture Map must expose both rails equally" unless map_html.include?("Get it on Gumroad") && map_html.include?("Get it on Ko-fi")
errors << "Personal Architecture Map relationship paths missing" unless map_html.include?('href="/workshop/choice-audit/"') && map_html.include?('href="/library/architecture-series/the-architecture-of-being-human-volume-i/"')

mint_pro_html = SITE.join("workshop/mint-pro/index.html").read
errors << "Mint Pro must render On the workbench lifecycle" unless mint_pro_html.include?('status-indicator__label">On the workbench</span>')
errors << "Mint Pro availability truth changed" unless mint_pro_html.include?("<dt>Availability</dt><dd>Not available yet</dd>")
errors << "Mint Pro must not expose acquisition controls" if mint_pro_html.include?("acquisition-actions")
errors << "Mint Pro must not invent a version or release" if mint_pro_html.match?(/<dt>(?:Version|Release)<\/dt>/)
errors << "Mint Pro must not expose an invented publication date" if mint_pro_html.include?("datePublished")
%w[What\ it\ is Why\ it\ exists What\ makes\ it\ different Where\ it\ is\ now].each do |heading|
  errors << "Mint Pro depth section missing: #{heading}" unless mint_pro_html.include?(">#{heading}<")
end
errors << "Mint Pro publishing architecture lost" unless mint_pro_html.include?("structured manuscripts") && mint_pro_html.include?("controlled templates") && mint_pro_html.include?("deterministic layout") && mint_pro_html.include?("EPUB/PDF output")
errors << "Mint Pro verified EPUB detail missing" unless mint_pro_html.include?("six-importer manuscript pipeline") && mint_pro_html.include?("EPUB 3.3 output has passed epubcheck 5.1.0 with zero errors or warnings")
errors << "Mint Pro unfinished device and layout boundaries missing" unless mint_pro_html.include?("PDF appearance and behavior still need continued device confirmation") && mint_pro_html.include?("tablet-specific two-pane editing layout")

bidmaster_html = SITE.join("workshop/bidmaster/index.html").read
errors << "BidMaster lifecycle or availability changed" unless bidmaster_html.include?('status-indicator__label">On the workbench</span>') && bidmaster_html.include?("<dt>Availability</dt><dd>Not available yet</dd>")
errors << "BidMaster public purpose missing" unless bidmaster_html.include?("local-first estimating workspace") && bidmaster_html.include?("independent contractors and small crews") && bidmaster_html.include?("Calculations are deterministic")
errors << "BidMaster must not expose acquisition controls" if bidmaster_html.include?("acquisition-actions")
errors << "BidMaster must not invent release or commerce claims" if bidmaster_html.match?(/(?:play\.google\.com|Play Store|\$\d|datePublished|Release date|Buy|Get BidMaster|\bAI\b|image[- ]analysis)/i)

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

architectural_thinking_html = SITE.join("architecture-wall/frameworks/architectural-thinking/index.html").read
objective_first_html = SITE.join("architecture-wall/frameworks/objective-first-architecture/index.html").read
errors << "Architectural Thinking depth explanation missing" unless architectural_thinking_html.include?("What architecture produced this?") && architectural_thinking_html.include?("does not count as evidence for itself")
errors << "Objective-First Architecture depth explanation missing" unless objective_first_html.include?("what you are genuinely trying to accomplish") && objective_first_html.include?("elegant answer to the wrong objective")
errors << "Framework distinction missing" unless objective_first_html.include?("Architectural Thinking looks broadly") && objective_first_html.include?("the objective")

observatory_html = SITE.join("observatory/index.html").read
errors << "Observatory canonical desktop v002 source missing" unless observatory_html.include?("FMD_SCENE_OBSERVATORY_BASE_DESKTOP_DEFAULT_v002.png")
errors << "Observatory canonical mobile v003 source missing" unless observatory_html.include?("FMD_SCENE_OBSERVATORY_BASE_MOBILE_DEFAULT_v003.png")
errors << "Observatory superseded desktop v001 must not be used" if observatory_html.include?("FMD_SCENE_OBSERVATORY_BASE_DESKTOP_DEFAULT_v001.png")
errors << "Observatory superseded mobile v002 must not be used" if observatory_html.include?("FMD_SCENE_OBSERVATORY_BASE_MOBILE_DEFAULT_v002.png")
errors << "Observatory current observation must use OBS-003" unless observatory_html.include?("Read the current observation: What Deserves the Right to Change the Work?")
errors << "Observatory must give primary emphasis only to populated forms" unless observatory_html.scan(/class="surface-card">\s*<h3>Essays<\/h3>/).length == 1 && observatory_html.scan(/class="surface-card">\s*<h3>(?:Discoveries|Field Notes|Workshop Notes)<\/h3>/).empty?
errors << "Observatory must preserve empty form types quietly" unless %w[Discoveries Field\ Notes Workshop\ Notes].all? { |label| observatory_html.include?("<strong>#{label}</strong>") }
errors << "Observatory scene must expose populated forms, archive, and return" unless observatory_html.scan(/class="observatory-hotspot observatory-hotspot--/).length == 3
errors << "Observatory must expose the three-essay constellation" unless observatory_html.scan(/class="observatory-card surface-card"/).length == 3
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
errors << "Outfitters must derive exactly three discovery listings" unless outfitters_html.scan(/class="outfitters-listing surface-card"/).length == 3
errors << "Volume I identity duplicated or detached from Library" unless outfitters_html.include?("href=\"/library/architecture-series/the-architecture-of-being-human-volume-i/\"") && outfitters_html.include?("<dd>Library</dd>")
errors << "Mint Pro identity duplicated or detached from Workshop" unless outfitters_html.include?("href=\"/workshop/mint-pro/\"") && outfitters_html.include?("<dd>Workshop</dd>")
errors << "Personal Architecture Map is missing from Outfitters" unless outfitters_html.include?("href=\"/workshop/personal-architecture-map/\"") && outfitters_html.include?("<dd>Workshop</dd>")
approved_amazon_url = "https://www.amazon.com/dp/B0HHSQT83Z/ref=cm_sw_r_as_gl_api_gl_i_HFKAKNGJ9HFXSDVK871C?linkCode=ml1&amp;tag=fluxmintdigit-20&amp;linkId=f4e6faba26d8121b4b4525d9c0358199&amp;gaOptInStatus=true"
amazon_disclosure = "As an Amazon Associate, FluxMintDigital earns from qualifying purchases."
errors << "Outfitters approved Amazon acquisition action missing or duplicated" unless outfitters_html.scan(approved_amazon_url).length == 1
errors << "Outfitters Amazon action must use external-link security and affiliate semantics" unless outfitters_html.match?(/href="#{Regexp.escape(approved_amazon_url)}" target="_blank" rel="external noopener sponsored"/)
errors << "Outfitters Amazon Associates disclosure missing or duplicated" unless outfitters_html.scan(amazon_disclosure).length == 1
errors << "Outfitters availability grouping is missing" unless outfitters_html.include?("Available to take") && outfitters_html.include?("Not available yet")
errors << "Outfitters environmental inventory boundary missing" unless outfitters_html.include?("only the items listed below are actually available through the Studio")
errors << "Outfitters contains fabricated commerce" if outfitters_html.match?(/(?:google play|etsy|fake discount|limited time|only \d+ left)/i)

volume_html = SITE.join("library/architecture-series/the-architecture-of-being-human-volume-i/index.html").read
errors << "Volume I approved Amazon acquisition action missing or duplicated" unless volume_html.scan(approved_amazon_url).length == 1
errors << "Volume I Amazon Associates disclosure missing or duplicated" unless volume_html.scan(amazon_disclosure).length == 1
errors << "Volume I availability must derive as available" unless volume_html.include?("<dt>Availability</dt><dd>Available</dd>")

dj_html = SITE.join("meet-dj/index.html").read
errors << "Meet DJ approved desktop likeness composition missing" unless dj_html.include?("FMD_SCENE_MEETDJ_LIKENESS_DESKTOP_DEFAULT_v003.webp")
errors << "Meet DJ approved mobile likeness composition missing" unless dj_html.include?("FMD_SCENE_MEETDJ_LIKENESS_MOBILE_DEFAULT_v003.webp")
errors << "Meet DJ must use deliberate mobile source selection" unless dj_html.match?(/<source media="\(max-width: 767px\)"[^>]+FMD_SCENE_MEETDJ_LIKENESS_MOBILE_DEFAULT_v003\.webp[^>]+width="941" height="1672"/)
errors << "Superseded Meet DJ character remains publicly referenced" if dj_html.include?("FMD_CHAR_MEETDJ_REALISTIC_RESPONSIVE_IDLE_v001.png")
errors << "Meet DJ must retain author, builder, and collaborator roles" unless dj_html.include?("Author · Builder · Collaborator")
errors << "Meet DJ role cards changed" unless dj_html.scan(/class="surface-card"><h3>(?:Author|Builder|Collaborator)<\/h3>/).length == 3
errors << "Meet DJ/Explorer identity boundary missing" unless dj_html.include?("The real DJ is the author, builder, and collaborator responsible for the work itself")
errors << "ForgeSpark relationship changed" unless dj_html.include?("ForgeSpark Studios is a sibling studio with its own identity and work")
errors << "Meet DJ Main Studio return missing" unless dj_html.scan(/href="\/studio\/"/).length >= 2
errors << "Controlled likeness source leaked into Meet DJ HTML" if dj_html.include?("FMD_SOURCE_MEETDJ_APPROVED_LIKENESS_REFERENCE")
errors << "Controlled Meet DJ likeness PNG leaked into public build" if SITE.glob("**/FMD_SOURCE_MEETDJ_APPROVED_LIKENESS_REFERENCE_v00*.png").any?
errors << "Meet DJ contains unsupported resume or social proof claims" if dj_html.match?(/(?:award-winning|years of experience|our clients|testimonial|certified|degree in)/i)

search_html = SITE.join("search/index.html").read
errors << "Search semantic index missing Rooms" unless search_html.scan(/\"type\":\"Room\"/).length == 6
errors << "Search semantic index missing public Artifacts" unless search_html.scan(/\"room\":\"(?:library|workshop|architecture-wall)\"/).length >= 7
errors << "Search results state missing" unless search_html.include?("id=\"search-status\" role=\"status\"") && search_html.include?("id=\"search-results\" aria-live=\"polite\"")
errors << "Search excerpt for Wild Side Volume I remains a status stub" unless search_html.include?("A playful exploration of how changing your point of view can change what you notice and understand.")
errors << "Search excerpt for DJ Field Guide Volume I remains a status stub" unless search_html.include?("An approachable, illustrated exploration of matter—the stuff we can see and the stuff we cannot.")

relationships_html = SITE.join("relationships/index.html").read
expected_relationships = YAML.safe_load_file(ROOT.join("_data/relationships.yml"), aliases: true).length
errors << "Relationship Explorer must render every canonical relationship" unless relationships_html.scan(/class="surface-card"/).length == expected_relationships
errors << "Relationship Explorer direction boundary missing" unless relationships_html.include?("An arrow shows the direction of the connection—not cause and effect")
errors << "Relationship Explorer must link every real-person target to Meet DJ" unless relationships_html.scan(/href="\/meet-dj\/"/).length >= 7
errors << "Relationship Explorer is missing the Architectural Thinking essay explanation" unless relationships_html.include?('href="/what-is-architectural-thinking/"') && relationships_html.include?('href="/architecture-wall/frameworks/architectural-thinking/"')
errors << "Relationship Explorer is missing the Objective-First essay explanation" unless relationships_html.include?('href="/why-i-created-objective-first-architecture/"') && relationships_html.include?('href="/architecture-wall/frameworks/objective-first-architecture/"')

architectural_thinking_essay_html = SITE.join("what-is-architectural-thinking/index.html").read
objective_first_essay_html = SITE.join("why-i-created-objective-first-architecture/index.html").read
errors << "Architectural Thinking essay must expose its approved framework relationship" unless architectural_thinking_essay_html.include?('Explains: Architectural Thinking™') && architectural_thinking_essay_html.include?('href="/architecture-wall/frameworks/architectural-thinking/"')
errors << "Objective-First essay must expose its approved framework relationship" unless objective_first_essay_html.include?('Explains: Objective-First Architecture™') && objective_first_essay_html.include?('href="/architecture-wall/frameworks/objective-first-architecture/"')

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
if SITE.join("sitemap.xml").file?
  sitemap = SITE.join("sitemap.xml").read
  errors << "Observatory archive must appear exactly once in sitemap" unless sitemap.scan("https://fluxmintdigital.com/studio-blog/").length == 1
  errors << "Internal audit leaked into sitemap" if sitemap.include?("FluxMintDigital_Experience_and_Interaction_Audit")
  %w[store services about blog apps tools books science].each do |legacy_route|
    errors << "Legacy route /#{legacy_route}/ leaked into sitemap" if sitemap.include?("https://fluxmintdigital.com/#{legacy_route}/")
  end
end

legacy_redirects = {
  "store" => "/explorer-outfitters/",
  "services" => "/meeting-table/",
  "about" => "/meet-dj/",
  "blog" => "/observatory/",
  "apps" => "/workshop/",
  "tools" => "/workshop/",
  "books" => "/library/",
  "science" => "/architecture-wall/"
}
legacy_redirects.each do |route, target|
  redirect_html = SITE.join(route, "index.html").read
  errors << "Legacy route /#{route}/ lost its redirect" unless redirect_html.include?("url=#{target}") && redirect_html.include?("window.location.replace(\"#{target}\")")
  errors << "Legacy route /#{route}/ missing noindex, follow" unless redirect_html.include?('<meta name="robots" content="noindex, follow">')
  errors << "Legacy route /#{route}/ canonical target changed" unless redirect_html.include?(%(<link rel="canonical" href="https://fluxmintdigital.com#{target}">))
end

expected_site_description = "FluxMintDigital is a Studio where curiosity explores hidden architecture through books, instruments, research, and things being built toward clearer understanding."
errors << "Homepage Studio metadata changed" unless home_html.include?(%(content="#{expected_site_description}"))

awaiting_seo_html = SITE.join("library/walk-on-the-wild-side/everything-looks-different-from-the-other-side-volume-i/index.html").read
errors << "Awaiting-publication SEO type changed" unless awaiting_seo_html.include?('<meta property="og:type" content="book">') && awaiting_seo_html.include?('"@type": "Book"')
errors << "Awaiting-publication social image missing" unless awaiting_seo_html.include?('meta property="og:image"') && awaiting_seo_html.include?('meta name="twitter:image"')
errors << "Awaiting-publication SEO invented a date" if awaiting_seo_html.match?(/datePublished|dateModified/)

unreleased_seo_html = SITE.join("workshop/mint-pro/index.html").read
errors << "Unreleased-application SEO type changed" unless unreleased_seo_html.include?('"@type": "SoftwareApplication"') && unreleased_seo_html.include?('<meta property="og:type" content="website">')
errors << "Unreleased-application SEO invented a date" if unreleased_seo_html.match?(/datePublished|dateModified/)

archive_html = SITE.join("studio-blog/index.html").read
errors << "Observatory archive must identify chronology as a history view" unless archive_html.include?("Browse Observatory pieces from newest to oldest")
expected_public_post_count = ROOT.glob("_posts/*.md").length
errors << "Observatory archive must contain all public posts" unless archive_html.scan(/class="post-card"/).length == expected_public_post_count
archive_dates = archive_html.scan(/<time datetime="([^"]+)"/).flatten
errors << "Observatory archive is not reverse chronological" unless archive_dates == archive_dates.sort.reverse

errors << "Explorer Entry orientation must remain a quiet Observatory link" unless home_html.include?('<p class="entry-stage__aside">Not sure where to begin? <a href="/observatory/">Visit the Observatory.</a></p>')
errors << "Explorer Entry orientation must not become a button or hotspot" if home_html.match?(/class="[^"]*(?:button|hotspot)[^"]*"[^>]*href="\/observatory\/"/)
errors << "Observatory Library continuation missing" unless observatory_html.include?('href="/library/">Read more in the Library</a>')
errors << "Observatory Workshop continuation missing" unless observatory_html.include?('href="/workshop/">Explore what is being built</a>')

errors << "Choice Audit retains stale workbench lifecycle wording" if choice_html.include?("browser-native instrument is on the Workshop workbench")
errors << "Choice Audit released-use wording missing" unless choice_html.include?("You can use the browser-native instrument here in the Workshop")

meeting_handoff = meeting_html[/<div class="meeting-human-handoff">.*?<\/div>/m].to_s
errors << "Meeting Table human handoff missing" unless meeting_handoff.include?("Ready to bring it to the table?") && meeting_handoff.include?("This worksheet has not been sent and stays on this device")
errors << "Meeting Table handoff must use only the canonical public contact destination" unless meeting_handoff.include?('href="mailto:dj@fluxmintdigital.com"')
errors << "Meeting Table handoff must not serialize worksheet data" if meeting_handoff.match?(/mailto:[^"']*[?&](?:subject|body)=|(?:problem|outcome|constraints)=/i)
errors << "Meeting Table review control must be inert until its local controller is active" unless meeting_html.match?(/type="submit"[^>]*data-meeting-review(?:="")?[^>]*disabled(?:="")?/)
meeting_controller = SITE.join("assets/js/meeting-table-intake.js").read
errors << "Meeting Table local controller does not activate the review control" unless meeting_controller.include?("reviewButton.disabled = false")

canonical_contact = "dj@fluxmintdigital.com"
studio_data = YAML.safe_load_file(ROOT.join("_data/studio.yml"), aliases: true)
errors << "Canonical public contact email changed or is missing" unless studio_data.dig("owner", "email") == canonical_contact
html_files = Dir[SITE.join("**/*.html")]
errors << "Superseded public Gmail address remains in generated HTML" if html_files.any? { |path| File.read(path).include?("fluxmintdigital@gmail.com") }
html_files.each do |path|
  File.read(path).scan(/href=["']mailto:([^"']+)["']/i).flatten.each do |destination|
    errors << "Unexpected or parameterized mailto destination in #{path.sub(SITE.to_s + "/", "")}" unless destination == canonical_contact
  end
end
errors << "Meet DJ direct email path missing" unless dj_html.include?(%Q(href="mailto:#{canonical_contact}">Email DJ</a>))
errors << "Meet DJ collaboration path missing" unless dj_html.include?(%Q(href="/meeting-table/">Bring a problem to the Meeting Table</a>))
errors << "Global footer direct-email label missing" unless File.read(SITE.join("index.html")).include?(%Q(href="mailto:#{canonical_contact}">Email DJ</a>))

css = SITE.join("assets/css/canonical.css").read
errors << "Reduced-motion contract missing" unless css.include?("prefers-reduced-motion:reduce")
errors << "Minimum target token missing" unless css.include?("--fmd-target:44px")

choice_audit_html = SITE.join("workshop/choice-audit/index.html").read
free_choice_audit_pdf = SITE.join("assets/downloads/FluxMintDigital_Choice_Audit_Free_v1.pdf")
errors << "Canonical free Choice Audit PDF missing" unless free_choice_audit_pdf.file?
errors << "Choice Audit printable download missing" unless choice_audit_html.include?('href="/assets/downloads/FluxMintDigital_Choice_Audit_Free_v1.pdf"') && choice_audit_html.include?("Download the printable Choice Audit")
errors << "Current-audit print action missing" unless choice_audit_html.include?("Print My Current Audit") && choice_audit_html.include?("data-audit-print")
errors << "Paid Personal Architecture Map PDF leaked into public build" if SITE.join("FluxMintDigital_Website_Canonical_Package/Assets/source/FluxMintDigital_The_Personal_Architecture_Map_v1.pdf").exist? || SITE.glob("**/FluxMintDigital_The_Personal_Architecture_Map_v1.pdf").any?
errors << "Personal Architecture Map source cover leaked into public build" if SITE.glob("**/FMD_PERSONAL_ARCHITECTURE_MAP_COVER_v1.png").any?

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
