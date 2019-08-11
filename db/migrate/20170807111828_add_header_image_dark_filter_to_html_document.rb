class AddHeaderImageDarkFilterToHtmlDocument < ActiveRecord::Migration[5.0]
  def change
    add_column :html_documents, :header_image_dark_filter, :boolean, default: false
  end
end
