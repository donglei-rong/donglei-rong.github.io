# frozen_string_literal: true
# Run with bundle exec ruby scripts/validate.rb [--built]. No network required.
require "yaml"
require "uri"
require "cgi"
require "set"

ROOT = Dir.pwd
abort "Run this command from the project root (next to _config.yml)." unless File.file?(File.join(ROOT, "_config.yml"))
Dir.chdir(ROOT)
errors = []
check = ->(condition, message) { errors << message unless condition }
load_yaml = ->(name) { YAML.safe_load_file("_data/#{name}.yml", permitted_classes: [], aliases: false) }
profile = load_yaml.call("profile")
pubs = load_yaml.call("publications") || []
publication_settings = File.file?("_data/publication_settings.yml") ? (load_yaml.call("publication_settings") || {}) : {}
if publication_settings["scope"] == "english_journal_articles"
  check.call(pubs.all? { |paper| paper["type"] == "journal" && paper["language"] == "en" }, "Only English-language journal articles belong in this publication scope")
  check.call(publication_settings["show_working_papers"] == false, "Working Papers must be disabled for the journal-only scope")
end
check.call(!pubs.empty?, "No publications found")
%w[id title authors venue year type doi].each do |key|
  pubs.each { |pub| check.call(pub[key] && pub[key].to_s.strip != "", "#{pub['id']}: missing #{key}") }
end
%w[id doi].each do |key|
  values = pubs.map { |pub| pub[key].to_s.downcase }
  check.call(values.uniq.size == values.size, "Duplicate publication #{key}")
end
pubs.each do |pub|
  check.call(pub["id"].match?(/\A[a-z0-9-]+\z/), "Invalid ID: #{pub['id']}")
  check.call(pub["year"].is_a?(Integer), "#{pub['id']}: year must be an integer")
  check.call(%w[journal conference preprint].include?(pub["type"]), "#{pub['id']}: unknown publication type")
  check.call(pub["doi"].match?(/\A10\.\d{4,9}\/\S+\z/), "#{pub['id']}: invalid DOI")
  if pub["image"] && pub["image"] != ""
    check.call(!pub["image_alt"].to_s.strip.empty?, "#{pub['id']}: image_alt is required for an image")
    if pub["image_kind"]
      check.call(%w[figure article-preview journal-cover].include?(pub["image_kind"]), "#{pub['id']}: unknown image_kind")
    end
    if %w[article-preview journal-cover].include?(pub["image_kind"])
      check.call(!pub["image_source_url"].to_s.empty?, "#{pub['id']}: image source is required")
    end
  end
  check.call([true, false].include?(pub["selected"]), "#{pub['id']}: selected must be true or false")
  if pub["publication_date"]
    check.call(pub["publication_date"].is_a?(String) && pub["publication_date"].match?(/\A\d{4}(?:-\d{2}(?:-\d{2})?)?\z/), "#{pub['id']}: invalid publication_date precision")
    check.call(pub["publication_date"].to_s.start_with?(pub["year"].to_s), "#{pub['id']}: publication_date must use the journal publication year")
  end
  if pub["publication_status"]
    check.call(%w[published online_first].include?(pub["publication_status"]), "#{pub['id']}: only published journal articles are allowed")
  end
end

# Working papers are separate from published articles and require a public link.
working_papers = File.file?("_data/working_papers.yml") ? (load_yaml.call("working_papers") || []) : []
check.call(working_papers.is_a?(Array), "working_papers.yml must be a list")
working_papers = [] unless working_papers.is_a?(Array)
working_papers.each do |paper|
  %w[id title authors preprint_url].each do |key|
    check.call(!paper[key].to_s.strip.empty?, "Working paper: missing #{key}")
  end
  check.call(paper["id"].to_s.match?(/\A[a-z0-9-]+\z/), "Working paper: invalid id")
  check.call(paper["year"].is_a?(Integer), "Working paper: year must be an integer")
  check.call(%w[preprint under_review].include?(paper.fetch("status", "preprint")), "Working paper: status must be preprint or under_review")
end
manuscript_ids = working_papers.map { |paper| paper["id"] }
check.call(manuscript_ids.uniq.size == manuscript_ids.size, "Duplicate working paper id")

# Validate all explicitly named URL fields and local assets in every data file.
def visit(value, &block)
  case value
  when Hash
    value.each { |key, item| block.call(key, item); visit(item, &block) }
  when Array
    value.each { |item| visit(item, &block) }
  end
end
all_data = Dir.glob("_data/*.yml").map { |path| YAML.safe_load_file(path, aliases: false) }
all_data.each do |data|
  visit(data) do |key, value|
    next if !value.is_a?(String) || value.empty?
    if key.end_with?("_url") || %w[google_scholar researchgate orcid linkedin github url].include?(key)
      next if value.start_with?("#")
      begin
        uri = URI.parse(value)
        check.call(%w[https http].include?(uri.scheme) && !uri.host.to_s.empty?, "Invalid external URL: #{value}")
      rescue URI::InvalidURIError
        check.call(false, "Invalid URL: #{value}")
      end
    end
    if %w[image avatar public_cv].include?(key)
      asset = value.sub(%r{\A/}, "")
      check.call(asset.start_with?("assets/") && File.file?(asset), "Missing or non-public asset: #{value}")
      check.call(!asset.split("/").include?(".."), "Asset escapes public directory: #{value}")
    end
  end
end
news = load_yaml.call("news") || []
news.each { |item| check.call(item["date"].match?(/\A\d{4}\.(0[1-9]|1[0-2])\z/), "News dates must use YYYY.MM") }

if ARGV.include?("--built")
  check.call(File.file?("_site/index.html"), "_site/index.html missing; run Jekyll first")
  html = File.read("_site/index.html", encoding: "utf-8")
  config = YAML.safe_load_file("_config.yml", aliases: false)
  baseurl = ENV.fetch("CHECK_BASEURL", config["baseurl"].to_s)
  ids = html.scan(/\bid="([^"]+)"/).flatten
  check.call(ids.uniq.size == ids.size, "Duplicate HTML IDs")
  links = html.scan(/\bhref="([^"]*)"/).flatten.map { |link| CGI.unescapeHTML(link) }
  check.call(!links.include?(""), "Empty href found")
  links.select { |link| link.start_with?("#") }.each do |link|
    check.call(ids.include?(link.delete_prefix("#")), "Broken anchor: #{link}")
  end
  html.scan(/\b(?:href|src)="([^"]+)"/).flatten.each do |raw|
    link = CGI.unescapeHTML(raw)
    next if link.match?(%r{\A(?:https?:|mailto:|#|data:)})
    local = link.split(/[?#]/).first.to_s.delete_prefix(baseurl).sub(%r{\A/}, "")
    local = "index.html" if local.empty?
    local += "/index.html" if !File.extname(local).match?(/\./)
    check.call(File.exist?(File.join("_site", local)), "Broken local asset/link: #{link}")
  end
  rendered_pubs = html.scan(/class="publication" id="publication-/).size
  rendered_highlights = html.scan(/class="publication" id="highlight-/).size
  check.call(rendered_pubs == pubs.size, "Expected #{pubs.size} publications, rendered #{rendered_pubs}")
  check.call(rendered_highlights == pubs.count { |pub| pub["selected"] }, "Highlights count mismatch")
  publication_blocks = html.scan(/<article class="publication"[^>]*>.*?<\/article>/m)
  highlighted_name = CGI.escapeHTML(profile.fetch("publication_name", "D. Rong"))
  check.call(publication_blocks.join.scan(/<strong>#{Regexp.escape(highlighted_name)}<\/strong>/).size == rendered_pubs + rendered_highlights, "Author highlighting mismatch")
  check.call(publication_blocks.none? { |block| block.include?('publication__visual') || block.include?('paper-placeholder') || block.include?('<img ') }, "Highlights and All Publications must use text citations without covers")
  rendered_working_papers = html.scan(/class="working-paper" id="working-paper-/).size
  working_papers_visible = publication_settings["show_working_papers"] != false && !working_papers.empty?
  check.call(rendered_working_papers == (working_papers_visible ? working_papers.size : 0), "Working papers count mismatch")
  check.call(html.include?('id="working-papers"') == working_papers_visible, "Working papers section visibility mismatch")
  check.call(working_papers_visible || !links.include?("#working-papers"), "Disabled or empty working papers navigation must be hidden")
  years = html.scan(/class="publication" id="publication-[^"]+" data-year="(\d+)"/).flatten.map(&:to_i)
  check.call(years == years.sort.reverse, "Publications are not sorted newest first")
  check.call(html.include?('property="og:title"') && html.include?('name="description"'), "SEO tags missing")
  check.call(!html.include?("University of Cincinnati"), "Private application text in public page")
  check.call(!html.include?("Zhiyu Huang"), "Reference author's identity in public page")
  check.call(!html.match?(/\{[%{]/), "Unrendered Liquid in HTML")
  Dir.glob("_site/**/*", File::FNM_DOTMATCH).select { |path| File.file?(path) }.each do |path|
    relative = path.delete_prefix("_site/")
    allowed = %w[index.html 404.html robots.txt sitemap.xml].include?(relative) || relative.start_with?("assets/")
    check.call(allowed, "Unexpected published file (check exclusions): #{relative}")
    check.call(!relative.match?(/\.(docx|zip|yml|rb|mjs)\z/i), "Private/source file in build: #{relative}")
  end
end

if errors.empty?
  puts "PASS: #{pubs.size} publications, #{pubs.count { |pub| pub['selected'] }} highlights, #{news.size} news items; data, links and assets valid."
  puts "PASS: rendered counts, author highlighting, descending years, anchors, SEO and public-output allowlist." if ARGV.include?("--built")
else
  warn errors.map { |error| "FAIL: #{error}" }.join("\n")
  exit 1
end

