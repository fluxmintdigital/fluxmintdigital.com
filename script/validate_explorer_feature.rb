#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("..", __dir__))
site = Pathname.new(ARGV[0] || ROOT.join("_site"))
mode = ARGV[1] || "off"
errors = []

config = YAML.safe_load_file(ROOT.join("_config.yml"), aliases: true)
feature = config.dig("features", "explorer_entry_idle")
errors << "Explorer feature flag must exist and default false" unless feature.is_a?(Hash) && feature["enabled"] == false
errors << "Explorer delivery base changed" unless feature && feature["asset_base"] == "/assets/images/explorer-entry/idle/"
errors << "Explorer frame count changed" unless feature && feature["frame_count"] == 12

entry_source = ROOT.join("_includes/entry-journey.html").read
component_source = ROOT.join("_includes/explorer-entry-character.html").read
controller_source = ROOT.join("_includes/explorer-entry-idle-controller.js").read
errors << "Character hook is not gated by the canonical flag" unless entry_source.scan(/site\.features\.explorer_entry_idle\.enabled/).length == 2
errors << "Component does not derive its delivery contract from the flag" unless component_source.include?("site.features.explorer_entry_idle") && component_source.include?("explorer_feature.asset_base") && component_source.include?("explorer_feature.frame_count")

required_controller_contract = [
  "IntersectionObserver", "visibilitychange", "pagehide", "prefers-reduced-motion",
  "clearTimeout", "cancelAnimationFrame", "disconnect()", "image.addEventListener('error'",
  "document.visibilityState", "region.dataset.animationState = 'static'"
]
required_controller_contract.each do |token|
  errors << "Controller contract missing #{token}" unless controller_source.include?(token)
end

evidence_idle = ROOT.join("FluxMintDigital_Website_Canonical_Package/Explorer_DJ_Production_Frame_Pack_v1/frames/animations/idle")
errors << "Controlled idle evidence must retain 12 frames" unless evidence_idle.glob("idle_*.png").length == 12
errors << "Delivery derivative tooling missing" unless ROOT.join("FluxMintDigital_Website_Canonical_Package/Explorer_DJ_Production_Frame_Pack_v1/tools/build_idle_delivery.sh").file?

home = site.join("index.html")
errors << "Built home page missing" unless home.file?
if home.file?
  html = home.read
  if mode == "off"
    errors << "OFF: character markup emitted" if html.include?("data-explorer-idle")
    errors << "OFF: controller emitted" if html.include?("explorerInitialized")
    errors << "OFF: frame URL emitted" if html.include?("FMD_CHAR_EXPLORERENTRY_DJ_IDLE")
    errors << "OFF: delivery directory emitted" if site.join("assets/images/explorer-entry").exist?
  elsif mode == "on"
    errors << "ON: one character hook required" unless html.scan(/<div class="entry-explorer-character"[^>]+data-explorer-idle/).length == 1
    errors << "ON: decorative contract missing" unless html.match?(/<div class="entry-explorer-character"[^>]+aria-hidden="true"/) && html.match?(/FMD_CHAR_EXPLORERENTRY_DJ_IDLE_F01_512W_v001\.png[^>]+alt=""/)
    errors << "ON: inline controller missing" unless html.include?("region.dataset.explorerInitialized = 'true'")
    delivery = site.glob("assets/images/explorer-entry/idle/*")
    errors << "ON fixture: expected 36 WebP frames and one PNG fallback" unless delivery.count { |path| path.extname == ".webp" } == 36 && delivery.count { |path| path.extname == ".png" } == 1
  else
    errors << "Unknown validation mode #{mode}"
  end
end

if errors.any?
  warn errors.join("\n")
  exit 1
end

puts "Explorer feature #{mode.upcase} contract valid at #{site}"
