# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "pathname"
require "rexml/document"
require "cgi"
require "digest"

class StaticPublicContractTest < Minitest::Test
  PROJECT_DIR = Pathname.new(__dir__).parent.expand_path
  PUBLIC_DIR = PROJECT_DIR.join("public")
  PERSON_ID = "https://drq.ai/#wesley"
  GA_ID = "G-Y2HPVMHTRR"

  PORTFOLIO_ROUTES = {
    "index.html" => ["Wesley Qian", "https://drq.ai/", "Home"],
    "experience/index.html" => ["Experience — Wesley Wei Qian", "https://drq.ai/experience/", "Experience"],
    "papers/index.html" => ["Papers — Wesley Wei Qian", "https://drq.ai/papers/", "Papers"]
  }.freeze

  CANONICAL_SITEMAP_URLS = %w[
    https://drq.ai/
    https://drq.ai/experience/
    https://drq.ai/papers/
    https://drq.ai/resume/
  ].freeze

  def read(relative_path)
    path = PROJECT_DIR.join(relative_path)
    return "" unless path.file?

    path.read
  end

  def public_read(relative_path)
    path = PUBLIC_DIR.join(relative_path)
    return "" unless path.file?

    path.read
  end

  def head(html)
    html[/<head>(.*?)<\/head>/m, 1].to_s
  end

  def structured_data(html)
    payloads = html.scan(%r{<script\b[^>]*type=["']application/ld\+json["'][^>]*>(.*?)</script>}m).flatten
    payloads.map { |payload| JSON.parse(payload) }
  end

  def text_content(fragment)
    fragment.to_s.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip
  end

  def relative_luminance(hex_color)
    channels = hex_color.delete_prefix("#").scan(/../).map { |channel| channel.to_i(16) / 255.0 }
    linear = channels.map do |channel|
      channel <= 0.04045 ? channel / 12.92 : ((channel + 0.055) / 1.055)**2.4
    end

    (0.2126 * linear[0]) + (0.7152 * linear[1]) + (0.0722 * linear[2])
  end

  def contrast_ratio(foreground, background = "#ffffff")
    luminances = [relative_luminance(foreground), relative_luminance(background)].sort.reverse
    (luminances[0] + 0.05) / (luminances[1] + 0.05)
  end

  def test_public_tree_is_a_directly_deployable_site
    required = %w[
      index.html
      experience/index.html
      papers/index.html
      resume/index.html
      404.html
      css/site.css
      js/site.js
      favicon.ico
      img/logo/favicon.svg
      img/profile/wesley-home-360.webp
      img/profile/wesley-home-720.webp
      img/profile/wesley-home.jpg
      CNAME
      robots.txt
      sitemap.xml
      llms.txt
    ]

    missing = required.reject { |path| PUBLIC_DIR.join(path).file? }
    assert_empty missing, "Missing public artifacts: #{missing.join(', ')}"
    refute PUBLIC_DIR.join("work").exist?, "Retired /work/ route must not ship"

    files = PUBLIC_DIR.glob("**/*").select(&:file?)
    optional_video = PUBLIC_DIR.join("media/osmo-studio-launch.mp4")
    core_bytes = files.reject { |path| path == optional_video }.sum(&:size)
    assert_operator core_bytes, :<, 500_000,
                    "Core site is #{core_bytes} bytes; expected less than 500 KB"
    assert_operator files.sum(&:size), :<, 3_000_000,
                    "Site plus the on-demand film must stay below 3 MB"
  end

  def test_studio_film_is_available_on_demand_with_a_direct_link_fallback
    html = public_read("index.html")
    assert PUBLIC_DIR.join("media/osmo-studio-launch.mp4").file?, "The Studio link must resolve to a shipped film"
    link = html[/<a\b[^>]*data-studio-video[^>]*>/]
    refute_nil link, "Home must expose the optional Studio film"
    video_version = Digest::SHA256.file(PUBLIC_DIR.join("media/osmo-studio-launch.mp4")).hexdigest[0, 12]
    assert_includes link, %(href="/media/osmo-studio-launch.mp4?v=#{video_version}")
    video = html[/<video\b[^>]*>/]
    refute_nil video
    refute_match(/\bsrc=|\bautoplay\b/, video, "The film must not load or play before activation")
    assert_match(/\bpreload="none"/, video)
    assert_match(/\bcontrols\b/, video)
    assert_match(/\bplaysinline\b/, video)
    refute_match(%r{<link\b[^>]*href="[^"]+\.mp4(?:\?[^"]*)?"}, head(html))
  end

  def test_portfolio_pages_ship_complete_metadata_navigation_and_analytics
    PORTFOLIO_ROUTES.each do |route, (title, canonical, current_label)|
      html = public_read(route)
      page_head = head(html)

      assert_includes page_head, "<title>#{title}</title>", route
      assert_match(%r{<meta\b[^>]*name=["']description["'][^>]*content=["'][^"']+["']}, page_head, route)
      assert_match(%r{<link\b[^>]*rel=["']canonical["'][^>]*href=["']#{Regexp.escape(canonical)}["']}, page_head, route)
      assert_match(%r{<meta\b[^>]*property=["']og:url["'][^>]*content=["']#{Regexp.escape(canonical)}["']}, page_head, route)
      assert_match(%r{<meta\b[^>]*name=["']twitter:card["'][^>]*content=["']summary_large_image["']}, page_head, route)
      assert_match(%r{<script\b[^>]*async[^>]*src=["']https://www\.googletagmanager\.com/gtag/js\?id=#{GA_ID}["']}, page_head, route)
      assert_equal 2, html.scan(GA_ID).length, "#{route} must initialize and load GA4 exactly once"
      refute_includes html, "requestIdleCallback", route

      nav = html[/<nav\b[^>]*aria-label=["']Primary["'][^>]*>(.*?)<\/nav>/m, 1]
      refute_nil nav, route
      labels = nav.scan(/<a\b[^>]*>(.*?)<\/a>/m).flatten.map { |label| text_content(label) }
      assert_equal ["Home", "Experience", "Papers"], labels, route
      current = nav.scan(/<a\b[^>]*aria-current=["']page["'][^>]*>(.*?)<\/a>/m)
                   .flatten
                   .map { |label| text_content(label) }
      assert_equal [current_label], current, route
    end
  end

  def test_portfolio_structured_data_uses_one_stable_person_identity
    home_data = structured_data(public_read("index.html"))
    experience_data = structured_data(public_read("experience/index.html"))
    papers_data = structured_data(public_read("papers/index.html"))

    assert_equal 1, home_data.length
    assert_equal "ProfilePage", home_data.first.fetch("@type")
    person = home_data.first.fetch("mainEntity")
    assert_equal "Person", person.fetch("@type")
    assert_equal PERSON_ID, person.fetch("@id")
    assert_equal "Wesley Wei Qian", person.fetch("name")
    assert_includes person.fetch("alternateName"), "Wesley Qian"

    assert_equal 1, experience_data.length
    assert_equal "WebPage", experience_data.first.fetch("@type")
    assert_equal PERSON_ID, experience_data.first.fetch("about").fetch("@id")

    assert_equal "CollectionPage", papers_data.first.fetch("@type")
    assert_equal PERSON_ID, papers_data.first.fetch("about").fetch("@id")
    papers = papers_data.first.fetch("mainEntity")
    assert_equal "ItemList", papers.fetch("@type")
    assert_equal 15, papers.fetch("itemListElement").length
  end

  def test_navigation_is_available_before_javascript_initializes
    PORTFOLIO_ROUTES.each_key do |route|
      html = public_read(route)
      links = html[/<div\b[^>]*data-menu-links[^>]*>/]
      refute_nil links, route
      refute_match(/\binert\b|aria-hidden=["']true["']/, links, route)
      assert_match(/<button\b[^>]*\bhidden\b[^>]*data-menu-trigger/, html, route)
    end
  end

  def test_paper_urls_and_titles_match_the_resume_and_structured_data
    papers = public_read("papers/index.html")
    visible = papers.scan(/<a\b[^>]*data-paper-link="true"[^>]*href="([^"]+)"[^>]*>(.*?)<\/a>/m)
                    .map { |url, title| [CGI.unescapeHTML(text_content(title)), CGI.unescapeHTML(url)] }.sort
    records = structured_data(papers).first.fetch("mainEntity").fetch("itemListElement")
    assert_equal visible, records.map { |entry| entry.fetch("item").values_at("name", "url") }.sort
    records.each do |entry|
      assert_equal PERSON_ID, entry.fetch("item").fetch("author").fetch("@id")
      fragment = entry.fetch("item").fetch("@id").delete_prefix("https://drq.ai/papers/#")
      assert_equal 1, papers.scan(/\bid="#{Regexp.escape(fragment)}"/).length
      assert_equal 1, public_read("resume/index.html").scan(/\bid="#{Regexp.escape(fragment)}"/).length
    end
    resume = public_read("resume/index.html")
    resume_records = resume.scan(/<article class="pub no-break(?: page-break-before)?" id="[^"]+">(.*?)<\/article>/m).flatten.map do |entry|
      title = CGI.unescapeHTML(text_content(entry[/<h3 class="pub-title">(.*?)<\/h3>/m, 1]))
      venue = entry[/<span class="pub-venue">(.*?)<\/span>/m, 1].to_s
      url = CGI.unescapeHTML(venue[/href="([^"]+)"/, 1].to_s)
      [title, url]
    end
    assert_equal visible, resume_records.sort
  end

  def test_resume_section_links_have_destinations
    html = public_read("resume/index.html")
    nav = html[/<nav aria-label="Resume sections">(.*?)<\/nav>/m, 1]
    refute_nil nav
    targets = nav.scan(/href="#([^"]+)"/).flatten
    assert_equal %w[experience-heading education-heading publications-heading services-heading], targets
    targets.each { |id| assert_equal 1, html.scan(/\bid="#{Regexp.escape(id)}"/).length }
  end

  def test_resume_is_standalone_white_metadata_rich_and_untracked
    html = public_read("resume/index.html")
    page_head = head(html)

    assert_includes page_head, "<title>Resume — Wesley Wei Qian</title>"
    assert_match(%r{<link\b[^>]*rel=["']canonical["'][^>]*href=["']https://drq\.ai/resume/["']}, page_head)
    assert_match(%r{<meta\b[^>]*property=["']og:title["'][^>]*content=["']Resume — Wesley Wei Qian["']}, page_head)
    assert_match(%r{<meta\b[^>]*name=["']twitter:card["'][^>]*content=["']summary_large_image["']}, page_head)
    assert_equal "ProfilePage", structured_data(html).first.fetch("@type")
    assert_equal PERSON_ID, structured_data(html).first.fetch("mainEntity").fetch("@id")

    refute_includes html, GA_ID
    refute_includes html, "floating-menu"
    refute_includes html, "site-credit"
    refute_match(%r{/css/site\.css}, html)
    refute_match(%r{/js/site\.js}, html)
    assert_match(%r{<meta\b[^>]*name=["']color-scheme["'][^>]*content=["']light["']}, page_head)
    assert_includes html, "background: #fff"
  end

  def test_resume_print_layout_keeps_consistent_letter_page_margins
    html = public_read("resume/index.html")

    assert_match(/@page\s*\{\s*size:\s*letter;\s*margin:\s*0;\s*\}/m, html)
    assert_match(/@media print\s*\{.*?\.resume-document\s*\{.*?padding:\s*0\.35in 0\.5in;/m, html)
    assert_match(/\.page-break-before\s*\{\s*padding-top:\s*0\.35in;\s*\}/, html)
  end

  def test_resume_detail_rows_share_responsive_indent_and_compact_spacing
    html = public_read("resume/index.html")

    refute_match(/\.pub\s*\{[^}]*padding-left:/m, html)
    refute_match(/\.pub::before\s*\{/, html)

    assert_match(/--resume-detail-indent:\s*0\.15in;/, html)
    assert_match(/\.role-timeline\s*\{[^}]*padding-left:\s*var\(--resume-detail-indent\);[^}]*\}/m, html)
    assert_match(/\.edu-details\s*\{[^}]*padding-left:\s*var\(--resume-detail-indent\);[^}]*\}/m, html)
    assert_match(/\.edu-details\s*\{[^}]*margin-top:\s*1pt;[^}]*\}/m, html)
    assert_match(/\.pub \.pub-meta\s*\{[^}]*padding-left:\s*var\(--resume-detail-indent\);[^}]*\}/m, html)
    assert_match(/\.pub \.pub-meta\s*\{[^}]*margin-top:\s*1pt;[^}]*\}/m, html)
    assert_match(/\.pub \.pub-authors\s*\{[^}]*padding-left:\s*var\(--resume-detail-indent\);[^}]*\}/m, html)
    assert_match(/\.pub \.pub-authors\s*\{[^}]*margin-top:\s*1pt;[^}]*\}/m, html)
    assert_equal 2, html.scan('<div class="edu-details">').length
    assert_equal 15, html.scan('<div class="pub-meta">').length

    company_spacing = html[/\.company-entry\s*\{[^}]*margin-bottom:\s*([\d.]+)in;/m, 1].to_f
    education_spacing = html[/\.edu-entry\s*\{[^}]*margin-bottom:\s*([\d.]+)in;/m, 1].to_f
    publication_spacing = html[/\.pub\s*\{[^}]*margin-bottom:\s*([\d.]+)in;/m, 1].to_f
    assert_in_delta 0.06, education_spacing, 0.001
    assert_in_delta education_spacing, publication_spacing, 0.001
    assert_operator company_spacing, :>, education_spacing

    mobile_styles = html[/@media screen and \(max-width: 760px\)\s*\{(.*?)\/\* --- Print --- \*\//m, 1]
    refute_nil mobile_styles
    assert_match(/:root\s*\{[^}]*--resume-detail-indent:\s*8px;[^}]*\}/m, mobile_styles)
    refute_match(/\.role-timeline,\s*\.edu-details,\s*\.pub \.pub-authors\s*\{\s*padding-left:\s*0;/m,
                 mobile_styles)

    assert_match(/\.service-list\s*\{[^}]*list-style:\s*none;[^}]*padding-left:\s*0;[^}]*\}/m, html)
    assert_match(/\.service-entry\s*\{[^}]*margin-bottom:\s*2pt;[^}]*\}/m, html)
    assert_match(/\.service-detail\s*\{[^}]*padding-left:\s*var\(--resume-detail-indent\);[^}]*\}/m, html)
    assert_equal 2, html.scan('<li class="service-entry">').length
  end

  def test_resume_mobile_metadata_remains_legible_without_changing_print_scale
    html = public_read("resume/index.html")
    mobile_styles = html[/@media screen and \(max-width: 760px\)\s*\{(.*?)\/\* --- Print --- \*\//m, 1]

    refute_nil mobile_styles
    assert_match(/:root\s*\{[^}]*--resume-mobile-meta-size:\s*14px;/m, mobile_styles)
    assert_match(/\.contact,\s*\.entry-date,\s*\.role-step__date,\s*\.pub-note\s*\{[^}]*font-size:\s*var\(--resume-mobile-meta-size\);/m,
                 mobile_styles)
    assert_match(/\.pub \.pub-authors\s*\{[^}]*font-size:\s*var\(--resume-mobile-meta-size\);[^}]*line-height:\s*1\.4;/m,
                 mobile_styles)

    print_styles = html[/@media print\s*\{(.*?)<\/style>/m, 1]
    refute_nil print_styles
    refute_match(/\.pub \.pub-authors\s*\{[^}]*font-size:\s*13px;/m, print_styles)
  end

  def test_resume_brand_text_colors_meet_wcag_contrast_on_white
    html = public_read("resume/index.html")
    tokens = %w[
      --resume-osmo
      --resume-google-blue
      --resume-google-red
      --resume-google-yellow
      --resume-google-green
      --resume-deepmind
      --resume-uiuc
      --resume-brandeis
    ]

    tokens.each do |token|
      colors = html.scan(/#{Regexp.escape(token)}:\s*(#[0-9a-f]{6});/i).flatten
      assert_equal 2, colors.length, "#{token} must match in screen and print tokens"
      colors.each do |color|
        assert_operator contrast_ratio(color), :>=, 4.5,
                        "#{token} #{color} must meet 4.5:1 against white"
      end
    end
  end

  def test_resume_entries_expose_semantic_headings_and_services_share_detail_hierarchy
    html = public_read("resume/index.html")

    %w[experience education publications services].each do |section|
      assert_match(/<section aria-labelledby="#{section}-heading">\s*<h2[^>]*id="#{section}-heading"/m, html)
    end

    assert_equal 4, html.scan(/<article class="company-entry no-break" data-company-entry="true">/).length
    assert_equal 2, html.scan(/<article class="edu-entry no-break">/).length
    assert_equal 15, html.scan(/<article class="pub no-break(?: page-break-before)?" id="[^"]+">/).length
    assert_equal 6, html.scan('<h3 class="entry-title">').length
    assert_equal 15, html.scan('<h3 class="pub-title">').length
    assert_equal 2, html.scan('<h3 class="service-title">').length
    assert_equal 2, html.scan('<div class="service-detail">').length
  end

  def test_new_york_smells_uses_the_standard_papers_metadata_format
    entry = public_read("papers/index.html")[%r{<article\b[^>]*id="new-york-smells"[^>]*>(.*?)</article>}m, 1]
    refute_nil entry
    assert_match(%r{<a\b[^>]*data-paper-link="true"[^>]*href="https://arxiv.org/abs/2511\.20544"}, entry)
    assert_equal "arXiv", entry[%r{<div class="publication-meta">(.*?)</div>}m, 1]
    refute_includes entry, "smell.cs.columbia.edu"
  end

  def test_published_assets_do_not_link_to_a_local_server
    assert_equal "drq.ai", public_read("CNAME").strip
    local_urls = []
    local_host = %r{(?:https?:)?//(?:(?:[\w-]+\.)*localhost\.?|127(?:\.\d{1,3}){3}|\[::1\]|0\.0\.0\.0)(?=[:/?#\s"'<>]|$)}i

    PUBLIC_DIR.glob("**/*.{html,css,js,txt,xml,svg,json}").each do |file|
      file.read.scan(local_host).each do |url|
        local_urls << "#{file.relative_path_from(PUBLIC_DIR)}: #{url}"
      end
    end

    assert_empty local_urls, "Local URLs would ship to drq.ai: #{local_urls.join(', ')}"
  end

  def test_every_internal_html_reference_resolves_inside_public
    broken = []

    PUBLIC_DIR.glob("**/*.html").each do |page|
      page.read.scan(/(?:href|src)=["']([^"'#?]+)(?:[?#][^"']*)?["']/).flatten.each do |reference|
        next if reference.match?(%r{\A(?:https?:|mailto:|data:|//)})

        target = if reference.start_with?("/")
                   PUBLIC_DIR.join(reference.delete_prefix("/"))
                 else
                   page.dirname.join(reference).cleanpath
                 end
        broken << "#{page.relative_path_from(PUBLIC_DIR)} -> #{reference}" unless target.file? || target.join("index.html").file?
      end
    end

    assert_empty broken, "Broken internal references: #{broken.join(', ')}"
  end

  def test_home_content_portrait_credit_and_resume_link_are_preserved
    html = public_read("index.html")

    assert_includes html, "across AI, product engineering, science, and data operation."
    assert_includes text_content(html), "Previously, I worked on olfaction, genomics, and high-content cell imaging at Google, protein structure at DeepMind, and machine learning on sensor data at Uber."

    links = html[/<p\b[^>]*class=["']home-intro__links["'][^>]*>(.*?)<\/p>/m, 1]
    assert_equal ["LinkedIn", "Scholar", "Resume", "Email"], links.scan(/<a\b[^>]*>(.*?)<\/a>/m).flatten.map { |label| text_content(label) }
    resume_link = links[/<a\b[^>]*>Resume<\/a>/]
    assert_match(%r{href=["']/resume/["']}, resume_link)
    assert_match(/target=["']_blank["']/, resume_link)
    assert_match(/rel=["'][^"']*noopener[^"']*noreferrer[^"']*["']/, resume_link)

    picture = html[/<picture\b[^>]*class=["'][^"']*home-intro__portrait-frame[^"']*["'][^>]*>(.*?)<\/picture>/m, 1]
    refute_nil picture
    assert_match(%r{wesley-home-360\.webp 360w[^"']*wesley-home-720\.webp 720w}, picture)
    assert_match(%r{<img\b[^>]*src=["']/img/profile/wesley-home\.jpg["'][^>]*fetchpriority=["']high["'][^>]*decoding=["']async["'][^>]*alt=["'][^"']+["']}, picture)
    %w[360 720].each do |width|
      path = PUBLIC_DIR.join("img/profile/wesley-home-#{width}.webp")
      assert_operator path.size, :<, 100_000
    end

    credit = html[/<p\b[^>]*class=["'][^"']*site-credit[^"']*["'][^>]*>(.*?)<\/p>/m, 1]
    assert_equal "Inspired by Charlie Deets.", text_content(credit).sub(/\s+\./, ".")
    assert_match(%r{href=["']https://charliedeets\.com/["']}, credit)
    css = public_read("css/site.css")
    assert_match(/\.home-page\s*\{[^}]*display:\s*grid[^}]*grid-template-rows:\s*1fr auto/m, css)
    assert_match(/\.site-credit\s*\{[^}]*position:\s*static[^}]*justify-self:\s*end/m, css)
  end

  def test_mobile_home_credit_follows_content_and_clears_the_centered_menu
    html = public_read("index.html")
    credit = html[/<p\b[^>]*class=["'][^"']*site-credit[^"']*["'][^>]*>(.*?)<\/p>/m, 1]
    css = public_read("css/site.css")

    assert_equal "Inspired by Charlie Deets.", text_content(credit).sub(/\s+\./, ".")
    assert_match(/@media \(max-width: 720px\).*?\.home-page\s*\{[^}]*grid-template-rows:\s*auto auto[^}]*align-content:\s*start/m, css)
    assert_match(/@media \(max-width: 720px\).*?\.home-main\s*\{[^}]*padding-bottom:\s*32px/m, css)
    assert_match(/@media \(max-width: 720px\).*?\.site-credit\s*\{[^}]*justify-self:\s*stretch[^}]*margin:\s*0 24px max\(96px, calc\(72px \+ env\(safe-area-inset-bottom\)\)\)[^}]*padding:\s*0/m, css)
  end

  def test_every_shared_asset_route_uses_the_current_deployment_cache_key
    (PORTFOLIO_ROUTES.keys + ["404.html"]).each do |route|
      assert_match(%r{href=["']/css/site\.css\?v=20260904-6["']}, head(public_read(route)), route)
      if PORTFOLIO_ROUTES.key?(route)
        assert_match(%r{src=["']/js/site\.js\?v=20260904-2["']}, public_read(route), route)
      end
    end
  end

  def test_retired_photo_feature_stays_removed
    %w[photo img/photo js/photo-selection.js test/photo_selection_test.js].each do |path|
      refute PROJECT_DIR.join(path).exist?, "Retired Photo artifact returned: #{path}"
      refute PUBLIC_DIR.join(path).exist?, "Retired Photo artifact shipped: #{path}"
    end

    %w[index.html experience/index.html papers/index.html resume/index.html].each do |route|
      refute_match(%r{(?:href|src)=["'][^"']*/photo(?:/|-selection)}, public_read(route), route)
    end
    refute_includes public_read("css/site.css"), ".photo-main"
    refute_includes public_read("js/site.js"), "data-photo-feed"
  end

  def test_experience_and_paper_records_preserve_approved_content
    experience = public_read("experience/index.html")
    assert_equal 4, experience.scan('data-work-entry="true"').length
    assert_equal 2, experience.scan('data-education-entry="true"').length
    %w[Osmo Google DeepMind Uber].each { |name| assert_includes experience, name }
    assert_includes experience, "University of Illinois Urbana-Champaign"
    assert_includes experience, "Brandeis University"

    dates_by_company = experience.scan(%r{<article class="work-entry" data-work-entry="true" id="[^"]+">(.*?)</article>}m).flatten.to_h do |article|
      company = text_content(article[/<h3>(.*?)<\/h3>/m, 1])
      date = CGI.unescapeHTML(text_content(article[/<div class="entry-date">(.*?)<\/div>/m, 1]))
      [company, date]
    end
    assert_equal "2018–2022 · Part-time", dates_by_company.fetch("Google")
    assert_equal "2021 · Fall & Winter Intern", dates_by_company.fetch("DeepMind")
    assert_equal "2016 & 2017 · Summer Intern", dates_by_company.fetch("Uber")

    expected_titles = [
      "Foundation models for discovery and exploration in chemical space",
      "A deep learning and digital archaeology approach for mosquito repellent discovery",
      "New York Smells: a large multimodal dataset for olfaction",
      "Pervasive mislocalization of pathogenic coding variants underlying human disorders",
      "A principal odor map unifies diverse tasks in human olfactory perception",
      "3D equivariant diffusion for target-aware molecule generation and affinity prediction",
      "Metabolic activity organizes olfactory representations",
      "A central chaperone-like role for 14-3-3 proteins in human cells",
      "Energy-inspired molecular conformation optimization",
      "ECNet is an evolutionary context-integrated deep learning framework for protein engineering",
      "Comprehensive interactome profiling of the human Hsp70 network highlights functional differentiation of J domains",
      "Evaluating attribution for graph neural networks",
      "Batch equalization with a generative adversarial network",
      "Evolutionary context-integrated deep sequence modeling for protein engineering",
      "Integrating deep neural networks and symbolic inference for organic reactivity prediction"
    ]
    papers = public_read("papers/index.html")
    actual_titles = papers.scan(/<a\b[^>]*data-paper-link="true"[^>]*>(.*?)<\/a>/m).flatten.map { |title| text_content(title) }
    assert_equal expected_titles, actual_titles
    papers.scan(/<a\b[^>]*data-paper-link="true"[^>]*>/).each do |tag|
      assert_includes tag, 'target="_blank"'
      assert_match(/rel=["'][^"']*noopener[^"']*noreferrer[^"']*["']/, tag)
    end
  end

  def test_resume_uses_canonical_publication_authors_and_contribution_markers
    resume = public_read("resume/index.html")

    principal_odor_map = resume[/<article class="pub no-break" id="[^"]+">\s*<h3 class="pub-title">A principal odor map.*?<\/article>/m]
    assert_includes principal_odor_map, "Emily J. Mayhew*"
    assert_includes principal_odor_map, "Kelsie A. Little"
    refute_includes principal_odor_map, "Emily E Mayhew"

    ecnet = resume[/<article class="pub no-break" id="[^"]+">\s*<h3 class="pub-title">ECNet is an evolutionary context-integrated deep learning framework for protein engineering.*?<\/article>/m]
    assert_includes ecnet, "Yunan Luo*, Guangde Jiang*"
  end

  def test_chemrxiv_preprint_and_acs_presentation_are_classified_consistently
    papers = public_read("papers/index.html")
    resume = public_read("resume/index.html")
    title = "Integrating deep neural networks and symbolic inference for organic reactivity prediction"

    papers_2020 = papers[/<section class="publication-year" aria-labelledby="year-2020">.*?<\/section>/m]
    papers_2021 = papers[/<section class="publication-year" aria-labelledby="year-2021">.*?<\/section>/m]
    assert_includes papers_2020, title
    refute_includes papers_2021, title
    assert_includes CGI.unescapeHTML(text_content(papers_2020)),
                    "ChemRxiv · presented at ACS National Meeting (2021)"

    resume_entry = resume[/<article class="pub no-break" id="[^"]+">\s*<h3 class="pub-title">#{Regexp.escape(title)}.*?<\/article>/m]
    assert_includes CGI.unescapeHTML(text_content(resume_entry)),
                    "ChemRxiv (2020) · presented at ACS National Meeting (2021)"
  end

  def test_favicon_and_shared_interface_contracts_are_preserved
    %w[index.html experience/index.html papers/index.html resume/index.html].each do |route|
      html = public_read(route)
      assert_match(%r{<link\b[^>]*rel=["']icon["'][^>]*type=["']image/svg\+xml["'][^>]*href=["']/img/logo/favicon\.svg["']}, html, route)
      assert_match(%r{<link\b[^>]*rel=["'](?:alternate )?icon["'][^>]*type=["']image/x-icon["'][^>]*href=["']/favicon\.ico["']}, html, route)
    end

    favicon = REXML::Document.new(public_read("img/logo/favicon.svg"))
    rectangles = REXML::XPath.match(favicon, "//*[local-name()='rect']")
    assert_equal 1, rectangles.length
    assert_equal "#111111", rectangles.first.attributes["fill"]
    assert_operator rectangles.first.attributes["rx"].to_f, :>, 0
    assert_equal [0, 0, 1, 0], PUBLIC_DIR.join("favicon.ico").binread(4).bytes

    css = public_read("css/site.css")
    %w[.floating-menu backdrop-filter max-width:\ 880px max-width:\ 720px prefers-color-scheme:\ dark prefers-reduced-motion:\ reduce :focus-visible ::selection].each do |token|
      assert_includes css, token.tr("\\", "")
    end
    assert_match(/@media \(max-width: 720px\).*?\.floating-menu\s*\{[^}]*left:\s*50%/m, css)
    assert_match(/@media \(max-width: 720px\).*?\.floating-menu\.scroll-hidden\s*\{[^}]*opacity:\s*0[^}]*pointer-events:\s*none/m, css)
  end

  def test_resume_preserves_approved_content_hierarchy_and_brand_details
    html = public_read("resume/index.html")

    assert_equal 15, html.scan(/<article class="pub no-break(?: page-break-before)?" id="[^"]+">/).length
    assert_equal 4, html.scan('data-company-entry="true"').length
    assert_equal 10, html.scan('data-role-step="true"').length
    assert_equal 10, html.scan('class="role-step__date"').length
    assert_includes html, '<div class="role-step__date">Sep 2021 - Dec 2021</div>'
    assert_includes html, '<div class="role-step__date">May 2017 - Aug 2017</div>'
    assert_includes html, '<div class="role-step__date">May 2016 - Aug 2016</div>'
    assert_includes html, '<div class="role-step__title">Intern</div>'
    refute_includes html, "Intern, AlphaFold"

    [
      "built a factory with many robots and turned scent prompting into a fragrance business",
      "2024 was a wild year for new capabilities",
      "finding &ldquo;drugs&rdquo; for the human nose sounded cool",
      "god-tier software engineers",
      "translate structural representations into functional predictions",
      "fused sensor data, gyroscope, GPS, and Wi-Fi",
      "I should have learned more about product management"
    ].each { |copy| assert_includes html, copy }

    summaries = html.scan(%r{<div class="role-step__summary">(.*?)</div>}m).flatten.map { |summary| text_content(summary) }
    assert_operator summaries.sum(&:length), :<=, 1_800
    summaries.each { |summary| assert_operator summary.length, :<=, 220 }

    assert_equal 2, html.scan(/--resume-osmo:\s*#[0-9a-f]{6};/i).length
    assert_match(%r{href="https://deepmind\.google/"[^>]*class="deepmind-blue"[^>]*>DeepMind</a>}, html)
    assert_match(%r{<article class="pub no-break page-break-before" id="graph-neural-network-attribution">\s*<h3 class="pub-title">Evaluating attribution for graph neural networks</h3>}m, html)

    assert_equal "11.5", html[/\.entry-title\s*\{[^}]*font-size:\s*([\d.]+)pt/m, 1]
    assert_equal "700", html[/\.entry-title\s*\{[^}]*font-weight:\s*(\d+)/m, 1]
    assert_equal "inherit", html[/\.entry-title\s*\{[^}]*line-height:\s*([^;]+);/m, 1]
    assert_equal "600", html[/\.role-step__title\s*\{[^}]*font-weight:\s*(\d+)/m, 1]

    section_size = html[/h2\s*\{[^}]*font-size:\s*([\d.]+)pt/m, 1].to_f
    entry_size = html[/\.entry-title\s*\{[^}]*font-size:\s*([\d.]+)pt/m, 1].to_f
    section_weight = html[/h2\s*\{[^}]*font-weight:\s*(\d+)/m, 1].to_i
    entry_weight = html[/\.entry-title\s*\{[^}]*font-weight:\s*(\d+)/m, 1].to_i

    assert_operator section_size, :>, entry_size
    assert_operator section_weight, :>=, entry_weight
    assert_equal "1.2", html[/h2\s*\{[^}]*line-height:\s*([\d.]+)/m, 1]
  end

  def test_search_and_agent_discovery_allow_all_crawlers_and_publish_only_canonical_routes
    robots = public_read("robots.txt")
    assert_equal ["*"], robots.scan(/^User-agent:\s*(\S+)/).flatten
    assert_includes robots, "Allow: /"
    refute_includes robots, "Disallow:"
    assert_includes robots, "Sitemap: https://drq.ai/sitemap.xml"

    sitemap = REXML::Document.new(public_read("sitemap.xml"))
    urls = REXML::XPath.match(sitemap, "//*[local-name()='loc']").map(&:text)
    assert_equal CANONICAL_SITEMAP_URLS, urls

    llms = public_read("llms.txt")
    CANONICAL_SITEMAP_URLS.each { |url| assert_includes llms, url }
    assert_includes llms, "Visible HTML pages are authoritative"
    assert_includes llms, "olfaction"
    assert_includes llms, "machine learning"
  end

  def test_retired_pdf_is_unavailable_and_uncited
    refute PUBLIC_DIR.join("rsc/resume.pdf").exist?

    PUBLIC_DIR.glob("**/*.{html,css,js,txt,xml}").each do |path|
      refute_includes path.read, "/rsc/resume.pdf", path.relative_path_from(PUBLIC_DIR).to_s
    end
  end

  def test_retired_publications_route_stays_removed
    refute PUBLIC_DIR.join("publications").exist?

    PUBLIC_DIR.glob("**/*.{html,css,js,txt,xml}").each do |path|
      refute_match(%r{(?:href|src)=["']/publications(?:/|["'])}, path.read,
                   path.relative_path_from(PUBLIC_DIR).to_s)
    end
  end

  def test_github_pages_workflow_deploys_public_without_a_generator
    workflow = read(".github/workflows/deploy-pages.yml")
    assert_includes workflow, "actions/configure-pages@v5"
    assert_includes workflow, "actions/upload-pages-artifact@v4"
    assert_includes workflow, "path: public"
    assert_includes workflow, "actions/deploy-pages@v4"
    refute_includes workflow, "jekyll"
    refute_includes workflow, "bundle"
    refute_includes workflow, "npm"
  end

  def test_jekyll_runtime_is_removed_after_static_parity
    %w[_config.yml Gemfile Gemfile.lock _includes _layouts assets/css/style.scss].each do |path|
      refute PROJECT_DIR.join(path).exist?, "Jekyll-only source remains: #{path}"
    end

    %w[index.html work.html publications.html resume.html].each do |path|
      refute PROJECT_DIR.join(path).exist?, "Legacy root page remains: #{path}"
    end
  end

  def test_public_directory_is_the_only_deployable_source
    %w[
      CNAME
      favicon.ico
      css/site.css
      js/site.js
      img/logo/favicon.svg
      img/profile/wesley-home-360.webp
      img/profile/wesley-home-720.webp
      img/profile/wesley-home.jpg
    ].each do |path|
      refute PROJECT_DIR.join(path).exist?, "Deployable asset is duplicated outside public/: #{path}"
    end
  end
end
