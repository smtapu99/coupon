class Widgets::ShopBubblesService < Widgets::BaseService

  private

  def load_widget_data
    @shops = []
    @shops += @site.shops.where(id: @widget.shops).order_by_set(@widget.shops) if @widget.shops.present?
  end
end
