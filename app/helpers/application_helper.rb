module ApplicationHelper
  def user_logged_in_status
    user_signed_in? ? "logged-in" : "logged-out"
  end

  def current_page
    "#{controller_name}-#{controller.action_name}"
  end

  def view_class
    "#{controller_name} #{controller_name}-#{controller.action_name}"
  end

  def core_pages?
    controller_name == "articles" ||
      controller_name == "podcast_episodes" ||
      controller_name == "events" ||
      controller_name == "tags" ||
      controller_name == "registrations" ||
      controller_name == "users" ||
      controller_name == "pages" ||
      controller_name == "chat_channels" ||
      controller_name == "dashboards" ||
      controller_name == "moderations" ||
      controller_name == "videos" ||
      controller_name == "badges" ||
      controller_name == "stories" ||
      controller_name == "comments" ||
      controller_name == "notifications" ||
      controller_name == "reading_list_items"
  end

  def render_js?
    !((controller_name == "articles" && (controller.action_name == "index" || controller.action_name == "show")) || controller_name == "pulses")
  end

  def title(page_title)
    derived_title = if page_title.include?("DEV")
                      page_title
                    else
                      page_title + " - DEV Community 👩‍💻👨‍💻"
    end
    content_for(:title) { derived_title }
    derived_title
  end

  def icon(name, pixels = "20")
    image_tag icon_url(name), alt: name, class: "icon-img", height: pixels, width: pixels
  end

  def icon_url(name)
    prefix = "https://res.cloudinary.com/practicaldev/image/upload/"
    case name
    when "twitter"
      prefix + "v1456342401/twitter-logo-silhouette_1_letrqc.png"
    when "github"
      prefix + "v1456342401/github-logo_m841aq.png"
    when "link"
      prefix + "v1456342401/link-symbol_apfbll.png"
    when "volume"
      prefix + "v1461589297/technology_1_aefet2.png"
    when "volume-mute"
      prefix + "v1461589297/technology_jiugwb.png"
    else
      prefix + "v1456342953/star-in-black-of-five-points-shape_sor40l.png"
    end
  end

  def cloudinary(url, width = nil, _quality = 80, _format = "jpg")
    if Rails.env.development? && (url.blank? || !url.include?("http"))
      return url
    end
    if url&.size&.positive?
      if width
        "https://res.cloudinary.com/practicaldev/image/fetch/c_scale,fl_progressive,q_auto,w_#{width}/f_auto/#{url}"
      else
        "https://res.cloudinary.com/practicaldev/image/fetch/c_scale,fl_progressive,q_auto/f_auto/#{url}"
      end
    else
      "https://res.cloudinary.com/practicaldev/image/fetch/c_scale,fl_progressive,q_1/f_auto/https://pbs.twimg.com/profile_images/481625927911092224/iAVNQXjn_normal.jpeg"
    end
  end

  def cloud_cover_url(url)
    return nil unless url.present?
    return asset_path("triple-unicorn") if Rails.env.test?
    return url if Rails.env.development?
    width = 1000
    height = 420
    quality = "auto"

    cl_image_path(url,
      type: "fetch",
      width: width,
      height: height,
      crop: "imagga_scale",
      quality: quality,
      flags: "progressive",
      fetch_format: "auto",
      sign_url: true)
  end

  def cloud_social_image(article)
    Rails.cache.
      fetch("article-social-img-#{article}-#{article.updated_at}-#{article.comments_count}",
      expires_in: 1.hour) do
      src = GeneratedImage.new(article).social_image
      return src if src.include? "res.cloudinary"
      cl_image_path(src,
      type: "fetch",
      width:  "1000",
      height: "500",
      crop: "imagga_scale",
      quality: "auto",
      flags: "progressive",
      fetch_format: "auto",
      sign_url: true)
    end
  end

  def tag_colors(tag)
    Rails.cache.fetch("view-helper-#{tag}/tag_colors", expires_in: 5.hours) do
      if found_tag = Tag.find_by_name(tag)
        { background: found_tag.bg_color_hex, color: found_tag.text_color_hex }
      else
        { background: "#d6d9e0", color: "#606570" }
      end
    end
  end

  def beautified_url(url)
    url.sub(/^((http[s]?|ftp):\/)?\//, "").sub(/\?.*/, "").chomp("/")
  rescue StandardError
    url
  end

  def org_bg_or_white(org)
    org&.bg_color_hex ? org.bg_color_hex : "#ffffff"
  end

  def sanitize_rendered_markdown(processed_html)
    ActionController::Base.helpers.sanitize processed_html.html_safe,
      scrubber: RenderedMarkdownScrubber.new
  end

  def sanitized_sidebar(text)
    ActionController::Base.helpers.sanitize simple_format(text),
      tags: %w(p b i em strike strong u br)
  end

  def track_split_version(url, version)
    "trackOutboundLink('#{url}','#{version}'); return false;"
  end

  def follow_button(followable, style = "full")
    "<button class='cta follow-action-button' data-info='{\"id\":#{followable.id},\"className\":\"#{followable.class.name}\",\"style\":\"#{style}\"}' data-follow-action-button>&nbsp;</button>".html_safe
  end

  def user_colors_style(user)
    "border: 2px solid #{user.decorate.darker_color}; box-shadow: 5px 6px 0px #{user.decorate.darker_color}"
  end

  def user_colors(user)
    user.decorate.enriched_colors
  end

  def timeframe_check(given_timeframe)
    params[:timeframe] == given_timeframe
  end

  def list_path
    if params[:tag].present?
      "/t/#{params[:tag]}"
    else
      ""
    end
  end
end
