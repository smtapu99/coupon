# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_07_18_110724) do

  create_table "affiliate_networks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "validate_subid", default: false, null: false
    t.string "validation_regex"
    t.string "slug", collation: "utf8_bin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status", default: "active", null: false
    t.index ["name"], name: "index_affiliate_networks_on_name", unique: true
    t.index ["slug"], name: "index_affiliate_networks_on_slug", unique: true
  end

  create_table "alerts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "alertable_type"
    t.bigint "alertable_id"
    t.integer "site_id"
    t.string "alert_type", null: false
    t.string "status", default: "active", null: false
    t.text "message"
    t.integer "solved_by_id"
    t.boolean "is_critical", default: false
    t.datetime "solved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alertable_type", "alertable_id"], name: "index_alerts_on_alertable_type_and_alertable_id"
    t.index ["site_id", "alertable_id", "alertable_type", "alert_type"], name: "alertable_index"
  end

  create_table "api_keys", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "access_token", null: false
    t.integer "user_id"
    t.boolean "active", default: true, null: false
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "site_id"
    t.index ["access_token"], name: "index_api_keys_on_access_token", unique: true
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "authors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "site_id", default: 0, null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "avatar"
    t.text "bio"
    t.string "google_plus_url"
    t.string "profession"
    t.string "ranking_name"
    t.text "site_review"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status", default: "blocked", null: false
    t.index ["site_id"], name: "index_authors_on_site_id"
  end

  create_table "banner_locations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "banner_id", null: false
    t.integer "bannerable_id", null: false
    t.string "bannerable_type", null: false
    t.index ["bannerable_id", "bannerable_type"], name: "bannerable_locations"
  end

  create_table "banners", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "site_id", null: false
    t.string "status", default: "active"
    t.boolean "show_in_shops", default: false, null: false
    t.string "banner_type", default: "general"
    t.text "value"
    t.text "excluded_shop_ids"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "show_on_home_page", default: false, null: false
    t.boolean "excluded_for_mobile_resolution", default: false, null: false
    t.index ["site_id", "status"], name: "index_banners_on_site_id_and_status"
  end

  create_table "campaign_imports", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "status", default: "pending"
    t.text "error_messages"
    t.string "file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaign_tracking_data", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "tracking_click_id"
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tracking_click_id"], name: "index_campaign_tracking_data_on_tracking_click_id"
  end

  create_table "campaigns", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "parent_id"
    t.integer "author_id"
    t.integer "site_id", default: 0, null: false
    t.integer "shop_id"
    t.string "name", null: false
    t.string "slug", collation: "utf8_bin"
    t.string "tag_string"
    t.string "blog_feed_url"
    t.string "box_color"
    t.integer "max_coupons"
    t.string "coupon_filter_text"
    t.string "h1_first_line"
    t.string "h1_second_line"
    t.string "nav_title"
    t.text "text"
    t.string "text_headline"
    t.text "priority_coupon_ids"
    t.string "sem_logo_url"
    t.string "sem_background_url"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status", default: "blocked", null: false
    t.string "template", default: "default"
    t.boolean "is_imported", default: false, null: false
    t.boolean "is_root_campaign", default: false, null: false
    t.boolean "blocked_by_relation"
    t.boolean "hide_newsletter_box", default: false
    t.boolean "coupons_on_top", default: false
    t.index ["shop_id"], name: "index_campaigns_on_shop_id"
    t.index ["site_id", "name", "parent_id", "shop_id"], name: "index_campaigns_on_site_id_and_name_and_parent_id_and_shop_id", unique: true
    t.index ["site_id", "slug", "shop_id"], name: "index_campaigns_on_site_id_and_slug_and_shop", unique: true
    t.index ["site_id"], name: "index_campaigns_on_site_id"
    t.index ["slug"], name: "index_campaigns_on_slug"
  end

  create_table "campaigns_coupons", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "campaign_id"
    t.bigint "coupon_id"
    t.index ["campaign_id"], name: "index_campaigns_coupons_on_campaign_id"
    t.index ["coupon_id"], name: "index_campaigns_coupons_on_coupon_id"
  end

  create_table "categories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "parent_id"
    t.boolean "main_category", default: false, null: false
    t.integer "author_id"
    t.integer "origin_id"
    t.integer "site_id", null: false
    t.integer "order_position", default: 0, null: false
    t.string "status", default: "pending", null: false
    t.string "name", null: false
    t.string "slug", collation: "utf8_bin"
    t.string "css_icon_class"
    t.integer "ranking_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "active_coupons_count", default: 0, null: false
    t.index ["author_id"], name: "index_categories_on_author_id"
    t.index ["main_category"], name: "index_categories_on_main_category"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["ranking_value"], name: "index_categories_on_ranking_value"
    t.index ["site_id", "slug"], name: "index_categories_on_site_id_and_slug_and_default_site_id", unique: true
    t.index ["site_id", "status"], name: "index_categories_on_site_id_and_status"
  end

  create_table "category_tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "category_id"
    t.bigint "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "tag_id"], name: "index_category_tags_on_category_id_and_tag_id", unique: true
    t.index ["category_id"], name: "index_category_tags_on_category_id"
    t.index ["tag_id"], name: "index_category_tags_on_tag_id"
  end

  create_table "countries", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "locale", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_countries_on_name", unique: true
  end

  create_table "coupon_categories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "coupon_id"
    t.integer "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["coupon_id", "category_id"], name: "index_coupon_categories_on_coupon_id_and_category_id_and_site_id", unique: true
  end

  create_table "coupon_codes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "site_id", null: false
    t.integer "coupon_id", null: false
    t.string "code", null: false
    t.integer "tracking_user_id"
    t.boolean "is_imported", default: false, null: false
    t.datetime "end_date"
    t.datetime "used_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["coupon_id", "is_imported", "site_id", "used_at", "end_date"], name: "coupon_codes_c_id_is_imp_s_id_used_at_end_date"
  end

  create_table "coupon_imports", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "status", default: "pending"
    t.text "error_messages", limit: 16777215
    t.string "file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coupon_tags", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "coupon_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["tag_id", "coupon_id"], name: "index_coupon_tags_on_site_id_and_tag_id_and_coupon_id", unique: true
  end

  create_table "coupons", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "site_id", null: false
    t.string "status", default: "active", null: false
    t.decimal "priority_score", precision: 10, scale: 5, default: "0.0", null: false
    t.integer "shop_list_priority", default: 5, null: false
    t.integer "affiliate_network_id"
    t.integer "shop_id"
    t.integer "campaign_id"
    t.boolean "is_top", default: false, null: false
    t.boolean "is_exclusive", default: false, null: false
    t.boolean "is_editors_pick", default: false, null: false
    t.boolean "is_free", default: false, null: false
    t.boolean "is_mobile", default: false, null: false
    t.boolean "is_free_delivery", default: false, null: false
    t.boolean "is_hidden", default: false, null: false
    t.integer "negative_votes"
    t.integer "positive_votes"
    t.string "title"
    t.string "coupon_type"
    t.text "url"
    t.string "code"
    t.text "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "last_validation_at"
    t.datetime "validated_at"
    t.integer "clicks", default: 0, null: false
    t.float "savings"
    t.string "savings_in"
    t.string "currency"
    t.integer "order_position"
    t.string "logo"
    t.string "widget_header_image"
    t.string "logo_text_first_line"
    t.string "logo_text_second_line"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "use_uniq_codes", default: false, null: false
    t.string "info_discount"
    t.string "info_min_purchase"
    t.string "info_limited_clients"
    t.string "info_limited_brands"
    t.string "info_conditions"
    t.boolean "use_logo_on_home_page", default: false
    t.boolean "use_logo_on_shop_page", default: false
    t.index ["id", "shop_id", "start_date", "end_date", "savings", "savings_in", "status"], name: "index_savings_in_sd_and_ed_and_status"
    t.index ["order_position"], name: "index_coupons_on_order_position"
    t.index ["shop_id", "status", "start_date", "end_date", "is_hidden", "coupon_type", "code"], name: "coup_shop_id_status_sd_ed_is_hid_cou_type_code"
    t.index ["site_id", "shop_id", "title", "code", "start_date", "end_date"], name: "index_coupons_on_site_id_n_shop_id_n_title_n_code_n_dates", unique: true
    t.index ["site_id", "status", "start_date", "end_date"], name: "index_coupons_on_site_id_and_status_and_start_date_and_end_date"
  end

  create_table "csv_exports", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "site_id"
    t.integer "user_id"
    t.string "status", default: "pending"
    t.string "export_type"
    t.string "file"
    t.text "params"
    t.text "error_messages", limit: 16777215
    t.datetime "last_executed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "external_urls", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.text "url", collation: "utf8_general_ci"
    t.integer "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendly_id_slugs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "slug", collation: "utf8_bin"
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "global_shop_mappings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "global_id"
    t.bigint "country_id"
    t.string "url_home"
    t.string "domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_global_shop_mappings_on_country_id"
    t.index ["global_id"], name: "index_global_shop_mappings_on_global_id"
  end

  create_table "globals", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "model_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "model_type"], name: "index_globals_on_name_and_model_type", unique: true
  end

  create_table "html_documents", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "meta_robots"
    t.string "meta_keywords"
    t.text "meta_description"
    t.string "meta_title"
    t.string "meta_title_fallback"
    t.text "content"
    t.text "welcome_text"
    t.string "h1"
    t.string "h2"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "htmlable_id"
    t.string "htmlable_type"
    t.text "head_scripts"
    t.string "header_image"
    t.string "mobile_header_image"
    t.string "header_font_color"
    t.string "header_cta_text"
    t.string "header_cta_anchor_link"
    t.string "header_text_v_alignment", default: "center", null: false
    t.string "header_text_h_alignment", default: "middle", null: false
    t.boolean "header_text_background", default: false, null: false
    t.string "header_size", default: "default", null: false
    t.datetime "countdown_date"
    t.boolean "header_image_dark_filter", default: false
    t.index ["htmlable_id", "htmlable_type"], name: "index_html_documents_on_htmlable_id_and_htmlable_type"
  end

  create_table "image_settings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "site_id"
    t.string "favicon"
    t.string "hero"
    t.string "logo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "see_more_categories_background"
    t.index ["site_id"], name: "index_image_settings_on_site_id"
  end

  create_table "media", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "site_id"
    t.string "file_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["site_id"], name: "index_media_on_site_id"
  end

  create_table "options", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "site_id"
    t.string "name"
    t.text "value", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "campaign_id"
    t.index ["site_id", "name", "campaign_id"], name: "index_options_on_site_id_and_name_and_campaign_id", unique: true
    t.index ["site_id", "name"], name: "index_options_on_site_id_and_name"
  end

  create_table "problems", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "model"
    t.string "column"
    t.text "value"
    t.string "value_solution"
    t.text "message"
    t.integer "solved_by_id"
    t.datetime "solved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "site_id", default: 0, null: false
  end

  create_table "redirect_rules", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "source", null: false
    t.boolean "source_is_regex", default: false, null: false
    t.boolean "source_is_case_sensitive", default: false, null: false
    t.string "destination", null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["active"], name: "index_redirect_rules_on_active"
    t.index ["source"], name: "index_redirect_rules_on_source"
    t.index ["source_is_case_sensitive"], name: "index_redirect_rules_on_source_is_case_sensitive"
    t.index ["source_is_regex"], name: "index_redirect_rules_on_source_is_regex"
  end

  create_table "relations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "relation_from_id"
    t.string "relation_from_type"
    t.integer "relation_to_id"
    t.string "relation_to_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["relation_from_id", "relation_from_type", "relation_to_id", "relation_to_type"], name: "relation_index"
  end

  create_table "request_environment_rules", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "redirect_rule_id", null: false
    t.string "environment_key_name", null: false
    t.string "environment_value", null: false
    t.boolean "environment_value_is_regex", default: false, null: false
    t.boolean "environment_value_is_case_sensitive", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["redirect_rule_id"], name: "index_request_environment_rules_on_redirect_rule_id"
  end

  create_table "shop_categories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "shop_id"
    t.integer "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["shop_id", "category_id"], name: "index_shop_categories_on_shop_id_and_category_id"
  end

  create_table "shop_imports", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "status", default: "pending"
    t.text "error_messages", limit: 16777215
    t.string "file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shop_keywords", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "site_id", null: false
    t.integer "shop_id", null: false
    t.string "kw1"
    t.string "kw2"
    t.string "kw3"
    t.string "kw4"
    t.string "kw5"
    t.index ["id", "site_id", "shop_id"], name: "index_shop_keywords_on_id_and_site_id_and_shop_id"
  end

  create_table "shops", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "global_id"
    t.integer "tier_group", default: 4
    t.integer "site_id", null: false
    t.integer "person_in_charge_id"
    t.integer "prefered_affiliate_network_id"
    t.string "status", default: "pending", null: false
    t.decimal "priority_score", precision: 10, scale: 5, default: "0.0", null: false
    t.boolean "is_hidden", default: false
    t.boolean "is_top", default: false, null: false
    t.boolean "is_default_clickout", default: true, null: false
    t.boolean "is_featured", default: false, null: false
    t.integer "shop_slider_position", default: 0
    t.string "title"
    t.string "anchor_text"
    t.string "url"
    t.text "fallback_url"
    t.string "slug", collation: "utf8_bin"
    t.string "link_title"
    t.text "coupon_targeting_script"
    t.string "logo"
    t.string "logo_alt_text"
    t.string "logo_title_text"
    t.string "merchant_id"
    t.string "header_image"
    t.integer "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "votes", default: 0, null: false
    t.integer "voters", default: 0, null: false
    t.decimal "clickout_value", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "priority", default: 4, null: false
    t.integer "active_coupons_count", default: 0, null: false
    t.boolean "is_imported", default: false, null: false
    t.text "info_address"
    t.text "info_phone"
    t.text "info_free_shipping"
    t.text "info_payment_methods"
    t.text "info_delivery_methods"
    t.string "first_coupon_image"
    t.integer "total_stars", default: 0, null: false
    t.integer "total_votes", default: 0, null: false
    t.boolean "is_direct_clickout", default: false, null: false
    t.index ["is_featured"], name: "index_shops_on_is_featured"
    t.index ["is_hidden"], name: "index_shops_on_is_hidden"
    t.index ["is_top"], name: "index_shops_on_is_top"
    t.index ["site_id", "slug", "status"], name: "index_shops_on_site_id_and_slug_and_status"
    t.index ["site_id", "slug"], name: "index_shops_on_site_id_and_slug"
    t.index ["site_id", "status", "active_coupons_count", "tier_group", "priority_score"], name: "shops_s_id_stat_act_cou_tier_prio_score"
    t.index ["slug"], name: "index_shops_on_slug"
  end

  create_table "site_coupon_clicks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "site_id", null: false
    t.integer "coupon_id", null: false
    t.integer "clicks", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["site_id", "coupon_id"], name: "index_site_coupon_clicks_on_site_id_and_coupon_id", unique: true
  end

  create_table "site_custom_translations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "site_id"
    t.integer "translation_id"
    t.text "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["site_id", "translation_id"], name: "index_site_custom_translations_on_site_id_and_translation_id", unique: true
    t.index ["site_id"], name: "index_site_custom_translations_on_site_id"
    t.index ["translation_id"], name: "index_site_custom_translations_on_translation_id"
  end

  create_table "site_users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "site_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["site_id", "user_id"], name: "index_site_users_on_site_id_and_user_id"
  end

  create_table "sites", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "status", default: "active"
    t.integer "country_id", null: false
    t.string "name"
    t.string "hostname"
    t.boolean "is_multisite", default: false, null: false
    t.boolean "is_wls", default: false, null: false
    t.boolean "use_https", default: false, null: false
    t.string "subdir_name"
    t.string "time_zone", null: false
    t.string "favicon"
    t.decimal "commission_share_percentage", precision: 5, scale: 2, default: "0.0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "asset_hostname"
    t.index ["country_id"], name: "index_sites_on_country_id"
    t.index ["hostname", "status", "is_multisite", "subdir_name"], name: "sites_main_index"
    t.index ["hostname"], name: "index_sites_on_hostname"
  end

  create_table "snippets", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "site_id"
    t.string "color_one", default: "#ddd", null: false
    t.string "color_two", default: "#999", null: false
    t.string "color_three", default: "#d74435", null: false
    t.string "color_four", default: "#a33428", null: false
    t.string "color_five", default: "#fff", null: false
    t.string "color_six", default: "#333", null: false
    t.boolean "manual_mode", default: false, null: false
    t.string "open", default: "new_window", null: false
    t.integer "quantity", default: 3, null: false
    t.boolean "show_exclusive", default: true, null: false
    t.boolean "show_free_delivery", default: true, null: false
    t.boolean "show_new", default: true, null: false
    t.boolean "show_top", default: true, null: false
    t.string "exclusive_ids"
    t.string "free_delivery_ids"
    t.string "new_ids"
    t.string "top_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status", default: "blocked", null: false
    t.index ["site_id", "status"], name: "index_snippets_on_site_id_and_status"
    t.index ["site_id"], name: "index_snippets_on_site_id"
  end

  create_table "static_pages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "site_id"
    t.string "title"
    t.string "slug", collation: "utf8_bin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "header_color"
    t.string "header_icon"
    t.string "css_class"
    t.boolean "display_sidebar", default: true, null: false
    t.string "status", default: "blocked", null: false
    t.index ["site_id", "status"], name: "index_static_pages_on_site_id_and_status"
    t.index ["site_id"], name: "index_static_pages_on_site_id"
  end

  create_table "tag_imports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "site_id", null: false
    t.string "status", default: "pending"
    t.text "error_messages"
    t.string "file"
    t.index ["site_id"], name: "index_tag_imports_on_site_id"
    t.index ["status"], name: "index_tag_imports_on_status"
  end

  create_table "tags", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "site_id"
    t.integer "category_id"
    t.string "word"
    t.integer "country_id"
    t.boolean "is_blacklisted", default: false, null: false
    t.integer "api_hits", default: 0, null: false
    t.index ["site_id", "word"], name: "index_tags_on_site_id_and_word"
    t.index ["word", "country_id", "is_blacklisted"], name: "index_tags_on_word_and_country_id_and_is_blacklisted"
    t.index ["word", "country_id"], name: "index_tags_on_word_and_country_id", unique: true
  end

  create_table "tracking_clicks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "tracking_user_id"
    t.integer "site_id"
    t.string "uniqid"
    t.integer "coupon_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "referrer"
    t.text "landing_page"
    t.string "click_type"
    t.string "page_type"
    t.string "utm_source"
    t.string "utm_campaign"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "channel"
    t.index ["coupon_id"], name: "index_tracking_clicks_on_coupon_id"
    t.index ["site_id"], name: "index_tracking_clicks_on_site_id"
    t.index ["tracking_user_id"], name: "index_tracking_clicks_on_tracking_user_id"
    t.index ["uniqid"], name: "index_tracking_clicks_on_uniqid"
  end

  create_table "tracking_users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "site_id"
    t.text "data"
    t.string "country"
    t.string "city"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "uniqid"
    t.integer "publisher_id"
    t.text "referrer"
    t.string "gclid"
    t.string "postal_code"
    t.index ["uniqid"], name: "index_tracking_users_on_uniqid"
  end

  create_table "translations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "locale"
    t.string "key"
    t.text "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["key"], name: "index_translations_on_key"
    t.index ["locale", "key"], name: "index_translations_on_locale_and_key", unique: true
    t.index ["locale"], name: "index_translations_on_locale"
  end

  create_table "user_countries", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "country_id"], name: "index_user_countries_on_user_id_and_country_id"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "role", default: "guest", null: false
    t.boolean "can_shops", default: true, null: false
    t.boolean "can_coupons", default: true, null: false
    t.boolean "can_metas", default: true, null: false
    t.boolean "can_widgets", default: false, null: false
    t.boolean "can_qa", default: false, null: false
    t.string "first_name"
    t.string "last_name"
    t.string "status", default: "blocked", null: false
    t.string "otp_secret_key"
    t.integer "otp_module", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["status"], name: "index_users_on_status"
  end

  create_table "votes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "stars", default: 0, null: false
    t.string "keypunch"
    t.index ["id", "shop_id"], name: "index_votes_on_id_and_shop_id"
    t.index ["id", "shop_id"], name: "index_votes_on_id_and_shop_id_and_ip_and_user_agent"
    t.index ["keypunch"], name: "index_votes_on_keypunch"
  end

  create_table "widgets", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "widget_type", null: false
    t.string "name", null: false
    t.text "value"
    t.integer "site_id", null: false
    t.integer "campaign_id"
    t.datetime "created_at"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "updated_at"
    t.index ["name"], name: "index_widgets_on_name"
    t.index ["site_id", "campaign_id"], name: "index_widgets_on_site_id_and_campaign_id"
    t.index ["site_id"], name: "index_widgets_on_site_id"
    t.index ["start_date", "end_date"], name: "index_widgets_on_start_date_and_end_date"
    t.index ["widget_type"], name: "index_widgets_on_widget_type"
  end

end
