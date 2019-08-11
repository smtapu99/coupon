class AddHeaderCtaAnchorLinkToCampaigns < ActiveRecord::Migration[5.0]
  def change
    add_column :html_documents, :header_cta_anchor_link, :string, after: :header_font_color
    add_column :html_documents, :header_cta_text, :string, after: :header_font_color
  end
end
