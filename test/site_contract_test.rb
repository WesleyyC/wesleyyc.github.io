# frozen_string_literal: true

require "minitest/autorun"
require "pathname"

class SiteContractTest < Minitest::Test
  SITE_DIR = Pathname.new(ENV.fetch("SITE_DIR")).expand_path
  PROJECT_DIR = Pathname.new(__dir__).parent.expand_path

  REQUIRED_ROUTES = %w[
    index.html
    work/index.html
    publications/index.html
    photo/index.html
    resume.html
  ].freeze

  GLOBAL_NAV_LABELS = ["Home", "Work", "Publications", "Photo"].freeze

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

  def test_global_navigation_is_exactly_the_approved_four_items
    %w[index.html work/index.html publications/index.html photo/index.html resume.html].each do |route|
      assert_equal GLOBAL_NAV_LABELS, primary_nav_labels(read(route)), route
    end
  end

  def test_global_navigation_marks_only_the_current_route
    {
      "index.html" => "Home",
      "work/index.html" => "Work",
      "publications/index.html" => "Publications",
      "photo/index.html" => "Photo"
    }.each do |route, expected|
      current = read(route).scan(/<a\b[^>]*aria-current=["']page["'][^>]*>(.*?)<\/a>/m)
                           .flatten
                           .map { |label| text_content(label) }
      assert_equal [expected], current, route
    end
  end

  def test_no_route_has_a_top_navigation_bar
    %w[index.html work/index.html publications/index.html photo/index.html].each do |route|
      refute_includes read(route), 'aria-label="Photo sections"', route
    end
  end

  def test_shared_pages_emit_the_pinned_direction_contract
    %w[index.html work/index.html publications/index.html photo/index.html].each do |route|
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
    assert_includes html, "Previously, I worked on olfaction and genomics at Google"
    assert_match(%r{<img\b[^>]*src=["']/img/profile/wesley-home\.(?:jpe?g|webp)["'][^>]*>}, html)
    links = html[/<p\b[^>]*class=["']home-intro__links["'][^>]*>(.*?)<\/p>/m, 1]
    assert_equal ["LinkedIn", "Scholar", "Resume", "Email"], links.scan(/<a\b[^>]*>(.*?)<\/a>/m).flatten.map { |label| text_content(label) }
  end

  def test_work_contains_all_roles_education_and_resume_link
    html = read("work/index.html")
    %w[Osmo Google DeepMind Uber].each { |name| assert_includes html, name }
    assert_includes html, "University of Illinois Urbana-Champaign"
    assert_includes html, "Brandeis University"
    assert_match(%r{href=["']/resume["']}, html)
    assert_equal 4, html.scan('data-work-entry="true"').length
    assert_equal 2, html.scan('data-education-entry="true"').length
    assert_match(/<h2\b[^>]*class=["'][^"']*visually-hidden[^"']*["'][^>]*>Professional experience<\/h2>/, html)
  end

  def test_publications_has_the_complete_sentence_case_record
    html = read("publications/index.html")
    assert_equal 15, html.scan('data-publication="true"').length
    assert_includes html, "Publications"
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

  def test_photo_feed_has_a_local_curated_set_with_accessible_dimensions
    html = read("photo/index.html")
    feed_images = image_tags(html).select { |tag| tag.include?('data-feed-image="true"') }
    assert_operator feed_images.length, :>=, 24
    dimensions = []

    feed_images.each do |tag|
      assert_match(%r{data-src=["']/img/photo/feed/}, tag)
      refute_match(/\ssrc=["']/, tag)
      assert_match(/alt=["'][^"']+["']/, tag)
      assert_match(/width=["']\d+["']/, tag)
      assert_match(/height=["']\d+["']/, tag)
      refute_includes tag, "instagram.com"
      assert_includes tag, 'loading="lazy"'
      refute_includes tag, "fetchpriority"
      dimensions << [tag[/width=["'](\d+)["']/, 1].to_i, tag[/height=["'](\d+)["']/, 1].to_i]
    end

    assert dimensions.any? { |width, height| width > height }, "Expected landscape photographs"
    assert dimensions.any? { |width, height| height > width }, "Expected portrait photographs"
    refute dimensions.any? { |width, height| width == height }, "Baked square mats should be cropped away"
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
    assert_includes script, 'trigger.setAttribute("aria-hidden", String(open))'
    assert_includes script, "trigger.inert = open"
    assert_includes script, "Escape"
    assert_match(/\.focus\(\)/, script)
    assert_includes script, ".inert"
    assert_includes script, "outside"
    assert_match(/const outside = \([^)]*\) => \{[^}]*closeMenu\(\);[^}]*\};/m, script)
    assert_includes script, 'document.addEventListener("click", outside)'
    assert_includes script, 'trigger?.addEventListener("keydown"'
    assert_includes script, 'event.key === "Enter"'
    assert_includes script, 'event.key === " "'
    assert_includes script, 'menu?.addEventListener("focusin"'
    assert_includes script, "event.relatedTarget"
    assert_includes script, "ignoreNextFocusout"
    assert_includes script, 'window.addEventListener("resize"'
    assert_includes script, 'image.loading = index === 0 ? "eager" : "lazy"'
    assert_includes script, 'image.setAttribute("fetchpriority", "high")'
    assert_includes script, "image.src = source"
    assert_includes script, "data-photo-feed"
    assert_includes script, "PhotoSelection.selectRandom"
    refute_includes script, 'label.textContent = open ? "Close" : "Menu"'
  end

  def test_open_menu_contains_links_without_a_close_row
    html = read("index.html")
    nav = html[/<nav\b[^>]*aria-label=["']Primary["'][^>]*>(.*?)<\/nav>/m, 1]
    assert_equal 4, nav.scan(/<a\b/).length
    assert_equal 1, nav.scan(/<button\b/).length
    refute_includes nav, "floating-menu__divider"
    refute_match(/>Close</, nav)
  end

  def test_resume_uses_the_shared_editorial_shell_and_complete_content
    html = read("resume.html")
    assert_includes html, 'class="resume-document"'
    assert_includes html, "Wesley Wei Qian"
    assert_includes html, "Foundation models for discovery and exploration in chemical space"
    assert_equal 15, html.scan(/<div class="pub no-break(?: page-break-before)?">/).length
    refute_includes html, "Source Sans 3"
    refute_includes html, "#2AA198"
    assert_includes html, "@media print"
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
    assert_match(/\.floating-menu__trigger\s*\{[^}]*width:\s*82px/m, css)
    assert_match(/\.floating-menu__trigger\s*\{[^}]*display:\s*flex[^}]*align-items:\s*center[^}]*justify-content:\s*center/m, css)
    assert_match(/\.home-intro__copy\s*\{[^}]*font-size:\s*18px[^}]*line-height:\s*29px/m, css)
    assert_includes css, "--muted: #707070"
    assert_includes css, "--menu-link: #555555"
    assert_includes css, "--menu-link: #aaaaaa"
    refute_includes css, "left: 50%"
  end
end
