module ApplicationHelper
  def safe_website_link(website_url, options = {})
    return nil unless website_url.present?

    begin
      uri = URI.parse(website_url)
      return nil unless %w[http https].include?(uri.scheme)

      display_text = options[:display_text] || uri.host
      link_options = { target: "_blank", rel: "noopener" }.merge(options.except(:display_text))
      link_to(display_text, website_url, link_options)
    rescue URI::InvalidURIError
      nil
    end
  end
end
