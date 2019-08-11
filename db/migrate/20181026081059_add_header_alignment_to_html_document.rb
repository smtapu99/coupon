class AddHeaderAlignmentToHtmlDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :html_documents, :header_text_v_alignment, :string, after: :header_cta_anchor_link, null: false, default: 'center'
    add_column :html_documents, :header_text_h_alignment, :string, after: :header_text_v_alignment, null: false, default: 'middle'
    add_column :html_documents, :header_text_background, :boolean, after: :header_text_h_alignment, null: false, default: false
  end
end
