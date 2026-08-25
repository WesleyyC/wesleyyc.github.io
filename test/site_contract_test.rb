# frozen_string_literal: true

require "minitest/autorun"
require "pathname"
require "rexml/document"
require "cgi"

class SiteContractTest < Minitest::Test
  SITE_DIR = Pathname.new(ENV.fetch("SITE_DIR")).expand_path
  PROJECT_DIR = Pathname.new(__dir__).parent.expand_path

  REQUIRED_ROUTES = %w[
    index.html
    work/index.html
    papers/index.html
    publications/index.html
    resume.html
  ].freeze

  GLOBAL_NAV_LABELS = ["Home", "Work", "Papers"].freeze

  def read(relative_path)
    path = SITE_DIR.join(relative_path)
    return "" unless path.file?

    path.read
  end

  def text_content(fragment)
    fragment.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip
  end

  def primary_nav_labels(html)
    nav = html[/<nav\b[^>]*aria-label=["']Primary["'][^>]*>(.*?)<\/nav>/m, 1]
    return [] unless nav

    nav.scan(/<a\b[^>]*>(.*?)<\/a>/m).flatten.map { |label| text_content(label) }
  end

  def image_tags(html)
    html.scan(/<img\b[^>]*>/m)
  end

  def test_all_required_routes_are_built
    missing = REQUIRED_ROUTES.reject { |route| SITE_DIR.join(route).file? }
    assert_empty missing, "Missing built routes: #{missing.join(', ')}"
  end

  def test_all_styled_routes_version_the_shared_stylesheet
    %w[index.html work/index.html papers/index.html resume.html].each do |route|
      assert_match(%r{<link\b[^>]*href=["']/css/site\.css\?v=\d+["'][^>]*rel=["']stylesheet["']}, read(route), route)
    end
  end

  def test_global_navigation_is_exactly_the_approved_three_items
    %w[index.html work/index.html papers/index.html resume.html].each do |route|
      assert_equal GLOBAL_NAV_LABELS, primary_nav_labels(read(route)), route
    end
  end

  def test_global_navigation_links_papers_to_the_canonical_route
    %w[index.html work/index.html papers/index.html resume.html].each do |route|
      assert_match(%r{<a\b[^>]*href=["']/papers/["'][^>]*>Papers</a>}, read(route), route)
    end
  end

  def test_global_navigation_marks_only_the_current_route
    {
      "index.html" => "Home",
      "work/index.html" => "Work",
      "papers/index.html" => "Papers"
    }.each do |route, expected|
      current = read(route).scan(/<a\b[^>]*aria-current=["']page["'][^>]*>(.*?)<\/a>/m)
                           .flatten
                           .map { |label| text_content(label) }
      assert_equal [expected], current, route
    end
  end

  def test_no_route_has_a_top_navigation_bar
    %w[index.html work/index.html papers/index.html].each do |route|
      refute_includes read(route), 'aria-label="Photo sections"', route
    end
  end

  def test_shared_pages_emit_the_pinned_direction_contract
    %w[index.html work/index.html papers/index.html].each do |route|
      html = read(route)
      assert_includes html, "THESIS:", route
      assert_includes html, "OWN-WORLD:", route
      assert_includes html, "FIRST VIEWPORT:", route
      assert_includes html, "FORM:", route
      assert_includes html, "f7a69c56", route
    end
  end

  def test_home_uses_the_approved_copy_and_local_portrait
    html = read("index.html")
    assert_match(/<h1>Wesley Wei Qian<\/h1>/, html)
    assert_includes html, "I build machines that can smell"
    assert_includes html, "across AI, product engineering, science, and data operation."
    assert_includes html, "Previously, I worked on olfaction, genomics, and high-content cell imaging at Google, protein structure at DeepMind, and machine learning on sensor data at Uber."
    assert_match(%r{<img\b[^>]*src=["']/img/profile/wesley-home\.(?:jpe?g|webp)["'][^>]*>}, html)
    links = html[/<p\b[^>]*class=["']home-intro__links["'][^>]*>(.*?)<\/p>/m, 1]
    assert_equal ["LinkedIn", "Scholar", "Resume", "Email"], links.scan(/<a\b[^>]*>(.*?)<\/a>/m).flatten.map { |label| text_content(label) }
    assert_match(%r{<a\b[^>]*href=["']https://drq\.ai/resume["'][^>]*>Resume<\/a>}, links)
  end

  def test_home_serves_a_responsive_high_priority_portrait
    html = read("index.html")
    picture = html[/<picture\b[^>]*class=["'][^"']*home-intro__portrait-frame[^"']*["'][^>]*>(.*?)<\/picture>/m, 1]

    refute_nil picture
    assert_match(%r{<source\b[^>]*type=["']image/webp["'][^>]*srcset=["'][^"']*wesley-home-360\.webp 360w[^"']*wesley-home-720\.webp 720w[^"']*["']}, picture)
    assert_match(%r{<img\b[^>]*src=["']/img/profile/wesley-home\.jpg["'][^>]*fetchpriority=["']high["'][^>]*decoding=["']async["']}, picture)

    %w[360 720].each do |width|
      path = SITE_DIR.join("img/profile/wesley-home-#{width}.webp")
      assert path.file?, "Missing responsive portrait: #{path}"
      assert_operator path.size, :<, 100_000, "Responsive portrait should remain a compact web asset: #{path}"
    end
  end

  def test_photo_feature_is_removed_from_the_built_site_and_source_tree
    refute SITE_DIR.join("photo/index.html").exist?
    refute PROJECT_DIR.join("photo").exist?
    refute PROJECT_DIR.join("img/photo").exist?
    refute PROJECT_DIR.join("js/photo-selection.js").exist?
    refute PROJECT_DIR.join("test/photo_selection_test.js").exist?

    %w[index.html work/index.html papers/index.html resume.html].each do |route|
      refute_match(%r{(?:href|src)=["'][^"']*/photo(?:/|-selection)}, read(route), route)
    end

    refute_includes read("css/site.css"), ".photo-main"
    refute_includes read("css/site.css"), ".image-feed"
    refute_includes read("js/site.js"), "data-photo-feed"
  end

  def test_analytics_waits_for_idle_time_instead_of_competing_with_the_first_render
    html = read("index.html")
    head = html[/<head>(.*?)<\/head>/m, 1]

    refute_match(%r{<script\b[^>]*src=["']https://www\.googletagmanager\.com/gtag/js}, head)
    assert_includes html, "requestIdleCallback"
    assert_includes html, "loadAnalytics"
  end

  def test_home_credits_the_site_inspiration_in_page_flow_without_repeating_it_elsewhere
    home = read("index.html")
    credit = home[/<p\b[^>]*class=["'][^"']*site-credit[^"']*["'][^>]*>(.*?)<\/p>/m, 1]

    refute_nil credit
    assert_equal "Site inspired by Charlie Deets.", text_content(credit).sub(/\s+\./, ".")
    assert_match(%r{<a\b[^>]*href=["']https://charliedeets\.com/["'][^>]*>Charlie Deets<\/a>}, credit)

    css = read("css/site.css")
    home_page_css = css[/\.home-page\s*\{(.*?)\}/m, 1]
    credit_css = css[/\.site-credit\s*\{(.*?)\}/m, 1]
    refute_nil home_page_css
    assert_includes home_page_css, "display: grid"
    assert_includes home_page_css, "grid-template-rows: 1fr auto"
    assert_includes credit_css, "position: static"
    assert_includes credit_css, "justify-self: end"
    refute_includes credit_css, "position: fixed"
    refute_match(/@media \(max-width: 720px\).*?\.site-credit\s*\{[^}]*\bbottom:/m, css)
    refute_includes css, ".floating-menu.is-open + .site-credit"

    %w[work/index.html papers/index.html resume.html].each do |route|
      refute_includes read(route), "site-credit", route
    end
  end

  def test_work_contains_all_roles_and_education_without_a_duplicate_resume_link
    html = read("work/index.html")
    %w[Osmo Google DeepMind Uber].each { |name| assert_includes html, name }
    assert_includes html, "University of Illinois Urbana-Champaign"
    assert_includes html, "Brandeis University"
    refute_match(%r{href=["']/resume["']}, html)
    assert_equal 4, html.scan('data-work-entry="true"').length
    assert_equal 2, html.scan('data-education-entry="true"').length
    assert_match(/<h2\b[^>]*class=["'][^"']*visually-hidden[^"']*["'][^>]*>Professional experience<\/h2>/, html)
  end

  def test_work_dates_include_commitment_and_season_context
    html = read("work/index.html")
    dates_by_company = html.scan(%r{<article class="work-entry" data-work-entry="true">(.*?)</article>}m).flatten.to_h do |article|
      company = text_content(article[/<h3>(.*?)<\/h3>/m, 1])
      date = CGI.unescapeHTML(text_content(article[/<div class="entry-date">(.*?)<\/div>/m, 1]))
      [company, date]
    end

    assert_equal "2018–2022 · Part-time", dates_by_company.fetch("Google")
    assert_equal "2021 · Fall & Winter Intern", dates_by_company.fetch("DeepMind")
    assert_equal "2016 & 2017 · Summer Intern", dates_by_company.fetch("Uber")
  end


  def test_pages_link_the_local_rounded_square_favicon
    %w[index.html work/index.html papers/index.html resume.html].each do |route|
      assert_match(%r{<link\b[^>]*rel=["']icon["'][^>]*type=["']image/svg\+xml["'][^>]*href=["']/img/logo/favicon\.svg["']}, read(route), route)
    end

    favicon = PROJECT_DIR.join("img/logo/favicon.svg")
    assert favicon.file?, "Expected the local SVG favicon to exist"

    document = REXML::Document.new(favicon.read)
    rectangles = REXML::XPath.match(document, "//*[local-name()='rect']")

    assert_equal 1, rectangles.length, "Favicon canvas must be transparent around the black rounded square"
    assert_equal "#111111", rectangles.first.attributes["fill"]
    assert_operator rectangles.first.attributes["rx"].to_f, :>, 0
  end

  def test_papers_has_the_complete_sentence_case_record
    html = read("papers/index.html")
    assert_equal 15, html.scan('data-publication="true"').length
    assert_includes html, "Papers"
    assert_includes html, "Foundation models for discovery and exploration in chemical space"
    assert_includes html, "https://arxiv.org/abs/2510.18900"

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
      "Integrating deep neural networks and symbolic inference for organic reactivity prediction",
      "Comprehensive interactome profiling of the human Hsp70 network highlights functional differentiation of J domains",
      "Evaluating attribution for graph neural networks",
      "Batch equalization with a generative adversarial network",
      "Evolutionary context-integrated deep sequence modeling for protein engineering"
    ]
    actual_titles = html.scan(/<a\b[^>]*data-paper-link="true"[^>]*>(.*?)<\/a>/m).flatten.map { |title| text_content(title) }
    assert_equal expected_titles, actual_titles

    html.scan(/<a\b[^>]*data-paper-link="true"[^>]*>/).each do |tag|
      assert_includes tag, 'target="_blank"'
      assert_match(/rel=["'][^"']*noopener[^"']*noreferrer[^"']*["']/, tag)
    end
  end

  def test_legacy_publications_route_redirects_to_papers
    html = read("publications/index.html")

    assert_match(/http-equiv=["']refresh["']/i, html)
    assert_match(%r{https://drq\.ai/papers/|/papers/}, html)
  end

  def test_content_images_are_local_and_described
    %w[index.html].each do |route|
      image_tags(read(route)).each do |tag|
        assert_match(%r{src=["']/img/}, tag, route)
        assert_match(/alt=["'][^"']+["']/, tag, route)
        assert_match(/width=["']\d+["']/, tag, route)
        assert_match(/height=["']\d+["']/, tag, route)
      end
    end
  end

  def test_menu_script_exposes_keyboard_and_focus_behavior
    script = read("js/site.js")
    assert_includes script, "aria-expanded"
    assert_includes script, 'label.textContent = open ? "Close" : "Menu"'
    assert_includes script, 'trigger.setAttribute("aria-label", open ? "Close menu" : "Open menu")'
    assert_includes script, "Escape"
    assert_includes script, ".inert"
    assert_includes script, "outside"
    assert_match(/const outside = \([^)]*\) => \{[^}]*closeMenu\(\);[^}]*\};/m, script)
    assert_includes script, 'document.addEventListener("click", outside)'
    assert_includes script, 'trigger?.addEventListener("click"'
    assert_includes script, 'links?.addEventListener("click"'
    assert_includes script, 'randomizeMenuTiming'
    assert_includes script, 'measureMenu'
    assert_includes script, 'window.addEventListener("resize"'
    refute_includes script, "data-photo-feed"
    refute_includes script, "PhotoSelection"
  end

  def test_menu_contains_grouping_dividers_and_a_close_capable_trigger
    html = read("index.html")
    nav = html[/<nav\b[^>]*aria-label=["']Primary["'][^>]*>(.*?)<\/nav>/m, 1]
    assert_equal 3, nav.scan(/<a\b/).length
    assert_equal 1, nav.scan(/<button\b/).length
    assert_equal 2, nav.scan(/floating-menu__divider/).length
    assert_includes nav, "data-menu-label"
    assert_match(/<button\b[^>]*data-menu-trigger[^>]*>.*?<span\b[^>]*data-menu-label[^>]*>Menu<\/span>.*?<\/button>/m, nav)
  end

  def test_resume_uses_the_shared_editorial_shell_and_complete_content
    html = read("resume.html")
    assert_includes html, "<title>Resume</title>"
    assert_includes html, 'class="resume-document"'
    assert_includes html, "Wesley Wei Qian"
    assert_includes html, "Foundation models for discovery and exploration in chemical space"
    assert_equal 15, html.scan(/<div class="pub no-break(?: page-break-before)?">/).length
    assert_equal 4, html.scan('data-company-entry="true"').length
    assert_equal 10, html.scan('data-role-step="true"').length
    assert_match(%r{href=["']https://www\.linkedin\.com/in/wesleyq["']}, html)
    header_css = html[/\.header\s*\{(.*?)\}/m, 1]
    refute_includes header_css, "border-bottom"
    assert_includes html, "--resume-osmo:"
    assert_includes html, "--resume-deepmind:"
    assert_includes html, "--resume-uiuc:"
    assert_includes html, "--resume-brandeis:"
    refute_includes html, "Source Sans 3"
    refute_includes html, "#2AA198"
    assert_includes html, "@media print"
  end

  def test_resume_company_timelines_show_dates_only_for_individual_roles
    html = read("resume.html")
    company_headers = html.scan(%r{<div class="company-entry[^>]*data-company-entry="true"[^>]*>\s*<div class="entry-header">(.*?)</div>\s*<div class="role-timeline">}m).flatten

    assert_equal 4, company_headers.length
    company_headers.each { |header| refute_includes header, 'class="entry-date"' }
    assert_equal 10, html.scan('class="role-step__date"').length
    assert_includes html, '<div class="role-step__date">Sep 2021 - Dec 2021</div>'
    assert_includes html, '<div class="role-step__date">May 2017 - Aug 2017</div>'
    assert_includes html, '<div class="role-step__date">May 2016 - Aug 2016</div>'
    assert_includes html, '<div class="role-step__title">Intern</div>'
    refute_includes html, '<div class="role-step__title">Intern, AlphaFold</div>'
  end

  def test_resume_uses_linkedin_sourced_experience_copy
    html = read("resume.html")

    assert_includes html, "built a factory with many robots and turned scent prompting into a fragrance business"
    assert_includes html, "2024 was a wild year for new capabilities"
    assert_includes html, "finding &ldquo;drugs&rdquo; for the human nose sounded cool"
    assert_includes html, "god-tier software engineers"
    assert_includes html, "translate structural representations into functional predictions"
    assert_includes html, "fused sensor data, gyroscope, GPS, and Wi-Fi"
    assert_includes html, "I should have learned more about product management"
  end

  def test_resume_experience_copy_stays_compact_for_page_one
    html = read("resume.html")
    summaries = html.scan(%r{<div class="role-step__summary">(.*?)</div>}m)
                    .flatten
                    .map { |summary| text_content(summary) }

    assert_equal 10, summaries.length
    assert_operator summaries.sum(&:length), :<=, 1_800
    summaries.each { |summary| assert_operator summary.length, :<=, 220 }
  end

  def test_resume_applies_deepmind_blue_to_the_company_link
    html = read("resume.html")

    assert_includes html, ".entry-title a.deepmind-blue { color: var(--resume-deepmind); }"
    assert_match(%r{<a\b[^>]*href="https://deepmind\.google/"[^>]*class="deepmind-blue"[^>]*>DeepMind</a>}, html)
  end

  def test_resume_uses_osmos_current_heading_orange
    html = read("resume.html")

    assert_equal 2, html.scan("--resume-osmo: #ff763b;").length
  end

  def test_resume_uses_the_original_google_brand_palette
    html = read("resume.html")

    assert_includes html, "--resume-google-blue: #4285f4;"
    assert_includes html, "--resume-google-red: #ea4335;"
    assert_includes html, "--resume-google-yellow: #e2a000;"
    assert_includes html, "--resume-google-green: #34a853;"
  end

  def test_resume_starts_page_three_with_the_graph_attribution_publication
    html = read("resume.html")

    assert_match(%r{<div class="pub no-break page-break-before">\s*<div><span class="pub-title">Evaluating attribution for graph neural networks</span>}m, html)
    refute_match(%r{<div class="pub no-break page-break-before">\s*<div><span class="pub-title">ECNet is an evolutionary context-integrated deep learning framework for protein engineering</span>}m, html)
  end

  def test_canonical_runner_builds_a_fresh_temporary_site
    runner = PROJECT_DIR.join("script/test-site").read
    assert_includes runner, "mktemp -d"
    assert_includes runner, "jekyll build"
    assert_includes runner, 'SITE_DIR="$SITE_TEST_DIR"'
  end

  def test_styles_include_reference_breakpoints_themes_and_reduced_motion
    css = read("css/site.css")
    assert_includes css, ".floating-menu"
    assert_includes css, "backdrop-filter: blur(20px)"
    assert_includes css, "max-width: 880px"
    assert_includes css, "max-width: 720px"
    assert_includes css, "prefers-color-scheme: dark"
    assert_includes css, "prefers-reduced-motion: reduce"
    assert_includes css, ":focus-visible"
    assert_includes css, "::selection"
    assert_match(/\.floating-menu\s*\{[^}]*--menu-collapsed-width:\s*82px/m, css)
    assert_match(/\.floating-menu__links a,\s*\.floating-menu__trigger\s*\{[^}]*width:\s*100%[^}]*text-align:\s*left/m, css)
    assert_match(/\.home-intro__copy\s*\{[^}]*font-size:\s*18px[^}]*line-height:\s*29px/m, css)
    assert_includes css, "--background: #fafafa"
    open_menu_css = css[/\.floating-menu\.is-open\s*\{(.*?)\}/m, 1]
    assert_includes open_menu_css, "--menu-width-duration-active: var(--menu-width-duration-expand)"
    assert_includes open_menu_css, "height: var(--menu-open-height)"
    assert_includes open_menu_css, "bottom: 24px"
    assert_includes css, "--menu-width-duration-expand: 590ms"
    assert_includes css, "--menu-height-duration-expand: 428ms"
    assert_includes css, "--menu-width-duration-retract: 655ms"
    assert_includes css, "--menu-height-duration-retract: 475ms"
    assert_includes css, "--menu-width-spring-expand: linear("
    assert_includes css, "--menu-height-spring-expand: linear("
    assert_includes css, ".floating-menu__divider"
    assert_match(/\.floating-menu\.is-open \.floating-menu__inner\s*\{[^}]*bottom:\s*8px/m, css)
    assert_match(/\.floating-menu\.is-open \.floating-menu__links\s*>\s*\*\s*\{[^}]*opacity:\s*1/m, css)
    trigger_focus_css = css[/\.floating-menu__trigger:focus-visible\s*\{(.*?)\}/m, 1]
    assert_includes trigger_focus_css, "outline: none"
    assert_includes trigger_focus_css, "color: var(--menu-link-active)"
    refute_includes trigger_focus_css, "text-decoration: underline"
    link_focus_css = css[/\.floating-menu__links a:focus-visible\s*\{(.*?)\}/m, 1]
    assert_includes link_focus_css, "text-decoration: underline"
    assert_includes css, "--muted: #6e6e6e"
    assert_includes css, "--menu-link: #555555"
    assert_includes css, "--menu-link: #aaaaaa"
    refute_includes css, "left: 50%"
  end
end
