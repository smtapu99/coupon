class ChangeLinksInSeoTextToHttps < ActiveRecord::Migration[5.2]
  def up
    Site.active.where(use_https: true).each do |site|
      from = "http://#{site.hostname}"
      to = "https://#{site.hostname}"

      execute("UPDATE html_documents SET content = REPLACE(content, '#{from}', '#{to}'), welcome_text = REPLACE(welcome_text, '#{from}', '#{to}'), head_scripts = REPLACE(head_scripts, '#{from}', '#{to}')")
      execute("UPDATE widgets SET value = REPLACE(value, '#{from}', '#{to}')")
      execute("UPDATE coupons SET description = REPLACE(description, '#{from}', '#{to}')")
      execute("UPDATE external_urls SET url = REPLACE(url, '#{from}', '#{to}')")
      execute("UPDATE options SET value = REPLACE(value, '#{from}', '#{to}')")
      execute("UPDATE translations SET value = REPLACE(value, '#{from}', '#{to}')")
      execute("UPDATE site_custom_translations SET value = REPLACE(value, '#{from}', '#{to}')")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
