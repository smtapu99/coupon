class AddHeaderSizeToHtmlDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :html_documents, :header_size, :string, after: :header_text_background, null: false, default: 'default'
  end
end
