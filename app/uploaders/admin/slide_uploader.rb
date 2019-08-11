class Admin::SlideUploader < Admin::BaseUploader
  process :resize_to_limit => [1170, 0]
  process :kraken_optimize

  version :large do
    resize_to_limit(1108, 1108)
  end

  version :medium do
    resize_to_limit(748, 218)
  end

  version :thumb do
    resize_to_fill(150, 150)
  end

  version :standard do
    process :resize_by_name
  end

  def resize_by_name
    if mounted_as == 'src'.to_sym
      resize_to_fill(1170, 350)
      resize_to_fill(370, 265)
    else
      resize_to_fill(150, 150)
    end
  end
end
