class Admin::HtmlDocumentUploader < Admin::BaseUploader

  process :kraken_optimize

  version :teaser do
    process :resize_by_name
  end

  version :thumb do
    resize_to_fill(150, 150)
  end

  def resize_by_name
    resize_to_fill(1140, 240) if mounted_as == :header_image
    resize_to_fill(345, 200) if mounted_as == :mobile_header_image
  end
end
