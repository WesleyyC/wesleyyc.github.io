# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "pathname"
require "rexml/document"
require "cgi"

class StaticPublicContractTest < Minitest::Test
  PROJECT_DIR = Pathname.new(__dir__).parent.expand_path
  PUBLIC_DIR = PROJECT_DIR.join("public")
  PERSON_ID = "https://drq.ai/#wesley"
  GA_ID = "G-Y2HPVMHTRR"

  PORTFOLIO_ROUTES = {
    "index.html" => ["Wesley Wei Qian", "https://drq.ai/", "Home"],
    "work/index.html" => ["Work — Wesley Qian", "https://drq.ai/work/", "Work"],
    "papers/index.html" => ["Papers — Wesley Qian", "https://drq.ai/papers/", "Papers"]
  }.freeze

  CANONICAL_SITEMAP_URLS = %w[
    https://drq.ai/
    https://drq.ai/work/
    https://drq.ai/papers/
    https://drq.ai/resume
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

  def test_public_tree_is_a_directly_deployable_site
    required = %w[
      index.html
      work/index.html
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

    shipped_bytes = PUBLIC_DIR.glob("**/*").select(&:file?).sum(&:size)
    assert_operator shipped_bytes, :<, 500_000,
                    "Static public artifact is #{shipped_bytes} bytes; expected less than 500 KB"
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
      assert_equal ["Home", "Work", "Papers"], labels, route
      current = nav.scan(/<a\b[^>]*aria-current=["']page["'][^>]*>(.*?)<\/a>/m)
                   .flatten
                   .map { |label| text_content(label) }
      assert_equal [current_label], current, route
    end
  end

  def test_portfolio_structured_data_uses_one_stable_person_identity
    home_data = structured_data(public_read("index.html"))
    work_data = structured_data(public_read("work/index.html"))
    papers_data = structured_data(public_read("papers/index.html"))

    assert_equal 1, home_data.length
    assert_equal "ProfilePage", home_data.first.fetch("@type")
    person = home_data.first.fetch("mainEntity")
    assert_equal "Person", person.fetch("@type")
    assert_equal PERSON_ID, person.fetch("@id")
    assert_equal "Wesley Wei Qian", person.fetch("name")

    assert_equal "WebPage", work_data.first.fetch("@type")
    assert_equal PERSON_ID, work_data.first.fetch("about").fetch("@id")

    assert_equal "CollectionPage", papers_data.first.fetch("@type")
    assert_equal PERSON_ID, papers_data.first.fetch("about").fetch("@id")
    papers = papers_data.first.fetch("mainEntity")
    assert_equal "ItemList", papers.fetch("@type")
    assert_equal 15, papers.fetch("itemListElement").length
  end

  def test_resume_is_standalone_white_metadata_rich_and_untracked
    html = public_read("resume/index.html")
    page_head = head(html)

    assert_includes page_head, "<title>Resume — Wesley Wei Qian</title>"
    assert_match(%r{<link\b[^>]*rel=["']canonical["'][^>]*href=["']https://drq\.ai/resume["']}, page_head)
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

    assert_includes html, "I build machines that can smell"
    assert_includes html, "across AI, product engineering, science, and data operation."
    assert_includes html, "Previously, I worked on olfaction, genomics, and high-content cell imaging at Google, protein structure at DeepMind, and machine learning on sensor data at Uber."

    links = html[/<p\b[^>]*class=["']home-intro__links["'][^>]*>(.*?)<\/p>/m, 1]
    assert_equal ["LinkedIn", "Scholar", "Resume", "Email"], links.scan(/<a\b[^>]*>(.*?)<\/a>/m).flatten.map { |label| text_content(label) }
    resume_link = links[/<a\b[^>]*>Resume<\/a>/]
    assert_match(%r{href=["']https://drq\.ai/resume["']}, resume_link)
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
    assert_equal "Site inspired by Charlie Deets.", text_content(credit).sub(/\s+\./, ".")
    assert_match(%r{href=["']https://charliedeets\.com/["']}, credit)
    css = public_read("css/site.css")
    assert_match(/\.home-page\s*\{[^}]*display:\s*grid[^}]*grid-template-rows:\s*1fr auto/m, css)
    assert_match(/\.site-credit\s*\{[^}]*position:\s*static[^}]*justify-self:\s*end/m, css)
  end

  def test_retired_photo_feature_and_duplicate_resume_link_stay_removed
    %w[photo img/photo js/photo-selection.js test/photo_selection_test.js].each do |path|
      refute PROJECT_DIR.join(path).exist?, "Retired Photo artifact returned: #{path}"
      refute PUBLIC_DIR.join(path).exist?, "Retired Photo artifact shipped: #{path}"
    end

    %w[index.html work/index.html papers/index.html resume/index.html].each do |route|
      refute_match(%r{(?:href|src)=["'][^"']*/photo(?:/|-selection)}, public_read(route), route)
    end
    refute_includes public_read("css/site.css"), ".photo-main"
    refute_includes public_read("js/site.js"), "data-photo-feed"
    refute_match(%r{href=["']/resume["']}, public_read("work/index.html"))
  end

  def test_work_and_paper_records_preserve_approved_content
    work = public_read("work/index.html")
    assert_equal 4, work.scan('data-work-entry="true"').length
    assert_equal 2, work.scan('data-education-entry="true"').length
    %w[Osmo Google DeepMind Uber].each { |name| assert_includes work, name }
    assert_includes work, "University of Illinois Urbana-Champaign"
    assert_includes work, "Brandeis University"

    dates_by_company = work.scan(%r{<article class="work-entry" data-work-entry="true">(.*?)</article>}m).flatten.to_h do |article|
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
      "Integrating deep neural networks and symbolic inference for organic reactivity prediction",
      "Comprehensive interactome profiling of the human Hsp70 network highlights functional differentiation of J domains",
      "Evaluating attribution for graph neural networks",
      "Batch equalization with a generative adversarial network",
      "Evolutionary context-integrated deep sequence modeling for protein engineering"
    ]
    papers = public_read("papers/index.html")
    actual_titles = papers.scan(/<a\b[^>]*data-paper-link="true"[^>]*>(.*?)<\/a>/m).flatten.map { |title| text_content(title) }
    assert_equal expected_titles, actual_titles
    papers.scan(/<a\b[^>]*data-paper-link="true"[^>]*>/).each do |tag|
      assert_includes tag, 'target="_blank"'
      assert_match(/rel=["'][^"']*noopener[^"']*noreferrer[^"']*["']/, tag)
    end
  end

  def test_favicon_and_shared_interface_contracts_are_preserved
    %w[index.html work/index.html papers/index.html resume/index.html].each do |route|
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

    assert_equal 15, html.scan(/<div class="pub no-break(?: page-break-before)?">/).length
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

    assert_equal 2, html.scan("--resume-osmo: #ff763b;").length
    %w[#4285f4 #ea4335 #e2a000 #34a853].each { |color| assert_includes html, color }
    assert_match(%r{href="https://deepmind\.google/"[^>]*class="deepmind-blue"[^>]*>DeepMind</a>}, html)
    assert_match(%r{<div class="pub no-break page-break-before">\s*<div><span class="pub-title">Evaluating attribution for graph neural networks</span>}m, html)

    assert_equal "11.5", html[/\.entry-title\s*\{[^}]*font-size:\s*([\d.]+)pt/m, 1]
    assert_equal "700", html[/\.entry-title\s*\{[^}]*font-weight:\s*(\d+)/m, 1]
    assert_equal "600", html[/\.role-step__title\s*\{[^}]*font-weight:\s*(\d+)/m, 1]
  end

  def test_search_and_agent_discovery_publish_only_canonical_routes
    robots = public_read("robots.txt")
    assert_includes robots, "User-agent: *\nAllow: /"
    assert_includes robots, "User-agent: OAI-SearchBot\nAllow: /"
    assert_includes robots, "User-agent: Claude-SearchBot\nAllow: /"
    assert_includes robots, "User-agent: GPTBot\nDisallow: /"
    assert_includes robots, "User-agent: ClaudeBot\nDisallow: /"
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

    PUBLIC_DIR.glob("**/*").select(&:file?).each do |path|
      refute_includes path.read, "/rsc/resume.pdf", path.relative_path_from(PUBLIC_DIR).to_s unless path.extname == ".ico"
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
