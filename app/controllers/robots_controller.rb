class RobotsController < FrontendController
  respond_to :txt

  def index
    robots = default_robots_txt

    if Setting::get('admin_rules.robots_txt').present?
      Setting::get('admin_rules.robots_txt').split("\n").each do |line|
        next if line.blank?
        robots += line + "\n"
      end
    end

    robots += "Sitemap: #{root_url.split('/').push('sitemap.xml').join('/')}\n"

    render plain: robots
  end
end
