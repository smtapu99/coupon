class ChangeInsecureAssetUrls < ActiveRecord::Migration[5.0]
  def up
    execute "Update html_documents set content = REPLACE(content, 'http://assets.couponcrew.net/', 'https://static.savings-united.com/')"
    execute "Update html_documents set content = REPLACE(content, 'https://js-1000-assets-production.jetscale.net/', 'https://static.savings-united.com/')"
    execute "Update html_documents set content = REPLACE(content, 'https://assets.couponcrew.net/', 'https://static.savings-united.com/')"
    execute "Update html_documents set content = REPLACE(content, 'https://commondatastorage.googleapis.com/js-1000.assets.production.jetscale.net/', 'https://static.savings-united.com/')"

    execute "Update widgets set value = REPLACE(value, 'http://assets.couponcrew.net/', 'https://static.savings-united.com/')"
    execute "Update widgets set value = REPLACE(value, 'https://js-1000-assets-production.jetscale.net/', 'https://static.savings-united.com/')"
    execute "Update widgets set value = REPLACE(value, 'https://assets.couponcrew.net/', 'https://static.savings-united.com/')"
    execute "Update widgets set value = REPLACE(value, 'https://commondatastorage.googleapis.com/js-1000.assets.production.jetscale.net/', 'https://static.savings-united.com/')"

    execute "Update options set value = REPLACE(value, 'http://assets.couponcrew.net/', 'https://static.savings-united.com/')"
    execute "Update options set value = REPLACE(value, 'https://js-1000-assets-production.jetscale.net/', 'https://static.savings-united.com/')"
    execute "Update options set value = REPLACE(value, 'https://assets.couponcrew.net/', 'https://static.savings-united.com/')"
    execute "Update options set value = REPLACE(value, 'https://commondatastorage.googleapis.com/js-1000.assets.production.jetscale.net/', 'https://static.savings-united.com/')"
  end

  def down
    # no rollback migration possible
  end
end
