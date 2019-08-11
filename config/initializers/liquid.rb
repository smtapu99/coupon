template_path = Rails.root.join('app/views/admin/')
Liquid::Template.file_system = Liquid::LocalFileSystem.new(template_path)