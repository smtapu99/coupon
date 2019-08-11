class RemoveAccordionFromStaticPages < ActiveRecord::Migration[5.2]
  def up
    documents = HtmlDocument.where("content like ?", "%accordion%")
    documents.each do |doc|
      doc.content.gsub!('id="accordion"', 'class="seo-text-container"')
      doc.content.gsub!('role="tabpanel"', '')
      doc.content.gsub!('role="tab"', '')
      doc.content.gsub!('data-toggle="collapse"', '')
      doc.content.gsub!('data-parent="#accordion"', '')
      doc.content.gsub!('aria-expanded="false"', '')
      doc.content.gsub!('collapsed', '')
      doc.content.gsub!('class="collapse "', '')

      doc.content.gsub!(/aria-controls="collapse_\d{2}"/, '')
      doc.content.gsub!(/href="#collapse_\d{2}"/, '')
      doc.content.gsub!(/data-target="#collapse_\d{2}"/, '')
      doc.content.gsub!(/aria-labelledby="heading_\d{2}"/, '')
      doc.content.gsub!(/id="heading_\d{2}"/, '')
      doc.content.gsub!(/id="collapse_\d{2}"/, '')
      doc.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
