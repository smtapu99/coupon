class Widgets::BlogPostsService < Widgets::BaseService

  private

  def load_widget_data
    require 'rss'
    return unless @widget.rss_feed_url
    @blog_posts = RSS::Parser.parse(open(@widget.rss_feed_url).read, false).items[0...@widget.post_count.to_i]
  end
end