#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"

options = {}
OptionParser.new do |parser|
  parser.banner = "Usage: ruby script/validate_production_alignment.rb --deployed-sha SHA --workflow-result success"
  parser.on("--deployed-sha SHA", "GitHub Pages deployed commit SHA") { |value| options[:deployed_sha] = value }
  parser.on("--workflow-result RESULT", "Deployment workflow conclusion") { |value| options[:workflow_result] = value }
end.parse!

errors = []
errors << "--deployed-sha is required" unless options[:deployed_sha]
errors << "--workflow-result is required" unless options[:workflow_result]

def git_revision(command)
  output = `#{command}`
  abort "Unable to resolve #{command}: #{output.strip}" unless $?.success?

  output.strip
end

unless errors.empty?
  warn errors.join("\n")
  exit 1
end

local_head = git_revision("git rev-parse HEAD")
origin_main = git_revision("git rev-parse origin/main")
deployed_sha = options[:deployed_sha].strip
workflow_result = options[:workflow_result].strip.downcase

errors << "local HEAD does not match origin/main" unless local_head == origin_main
errors << "local HEAD does not match deployed production SHA" unless local_head == deployed_sha
errors << "origin/main does not match deployed production SHA" unless origin_main == deployed_sha
errors << "deployment workflow did not succeed: #{options[:workflow_result]}" unless workflow_result == "success"
tracked_changes = `git status --short --untracked-files=no`.strip
errors << "tracked working-tree changes are not included in the deployed commit:\n#{tracked_changes}" unless tracked_changes.empty?

if errors.empty?
  puts "Production alignment valid: local HEAD, origin/main, and deployed SHA are #{local_head}; workflow succeeded."
else
  warn errors.join("\n")
  exit 1
end
