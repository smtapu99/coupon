class FlattenedMigrations < ActiveRecord::Migration[5.0]
  def change
    create_table "affiliate_networks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string   "name",                           null: false
      t.boolean  "validate_subid", default: false, null: false
      t.string   "slug",                                        collation: "utf8_bin"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["name"], name: "index_affiliate_networks_on_name", unique: true, using: :btree
      t.index ["slug"], name: "index_affiliate_networks_on_slug", unique: true, using: :btree
    end

    create_table "api_keys", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string   "access_token",                null: false
      t.integer  "user_id",                     null: false
      t.boolean  "active",       default: true, null: false
      t.datetime "expires_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["access_token"], name: "index_api_keys_on_access_token", unique: true, using: :btree
      t.index ["user_id"], name: "index_api_keys_on_user_id", using: :btree
    end

    create_table "authors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "site_id",                       default: 0,         null: false
      t.string   "first_name",                                        null: false
      t.string   "last_name",                                         null: false
      t.string   "avatar"
      t.text     "bio",             limit: 65535
      t.string   "google_plus_url"
      t.string   "profession"
      t.string   "ranking_name"
      t.text     "site_review",     limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "status",                        default: "blocked", null: false
      t.index ["site_id"], name: "index_authors_on_site_id", using: :btree
    end

    create_table "campaign_imports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "user_id",                                          null: false
      t.integer  "site_id",                                          null: false
      t.string   "status",                       default: "pending"
      t.text     "error_messages", limit: 65535
      t.string   "file"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "campaigns", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "parent_id"
      t.integer  "author_id"
      t.integer  "site_id",                           default: 0,         null: false
      t.integer  "shop_id"
      t.string   "name",                                                  null: false
      t.string   "slug",                                                               collation: "utf8_bin"
      t.string   "tag_string"
      t.string   "blog_feed_url"
      t.string   "box_color"
      t.integer  "max_coupons"
      t.string   "coupon_filter_text"
      t.string   "h1_first_line"
      t.string   "h1_second_line"
      t.string   "nav_title"
      t.integer  "show_nav_link"
      t.text     "text",                limit: 65535
      t.string   "text_headline"
      t.string   "priority_coupon_ids"
      t.datetime "start_date"
      t.datetime "end_date"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "status",                            default: "blocked", null: false
      t.string   "template",                          default: "default"
      t.boolean  "is_imported",                       default: false,     null: false
      t.boolean  "blocked_by_relation"
      t.index ["shop_id"], name: "index_campaigns_on_shop_id", using: :btree
      t.index ["show_nav_link"], name: "index_campaigns_on_show_nav_link", using: :btree
      t.index ["site_id", "name", "parent_id", "shop_id"], name: "index_campaigns_on_site_id_and_name_and_parent_id_and_shop_id", unique: true, using: :btree
      t.index ["site_id", "slug", "shop_id"], name: "index_campaigns_on_site_id_and_slug_and_shop", unique: true, using: :btree
      t.index ["site_id"], name: "index_campaigns_on_site_id", using: :btree
      t.index ["slug"], name: "index_campaigns_on_slug", using: :btree
    end

    create_table "categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "parent_id"
      t.boolean  "main_category",        default: false,     null: false
      t.integer  "author_id"
      t.integer  "origin_id"
      t.integer  "site_id",                                  null: false
      t.string   "status",               default: "pending", null: false
      t.string   "name",                                     null: false
      t.string   "slug",                                                  collation: "utf8_bin"
      t.string   "css_icon_class"
      t.integer  "ranking_value"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "active_coupons_count", default: 0,         null: false
      t.index ["author_id"], name: "index_categories_on_author_id", using: :btree
      t.index ["main_category"], name: "index_categories_on_main_category", using: :btree
      t.index ["parent_id"], name: "index_categories_on_parent_id", using: :btree
      t.index ["ranking_value"], name: "index_categories_on_ranking_value", using: :btree
      t.index ["site_id", "slug"], name: "index_categories_on_site_id_and_slug_and_default_site_id", unique: true, using: :btree
      t.index ["site_id", "status"], name: "index_categories_on_site_id_and_status", using: :btree
    end

    create_table "countries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string   "name",       null: false
      t.string   "locale",     null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["name"], name: "index_countries_on_name", unique: true, using: :btree
    end

    create_table "coupon_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "coupon_id"
      t.integer  "category_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["coupon_id", "category_id"], name: "index_coupon_categories_on_coupon_id_and_category_id_and_site_id", unique: true, using: :btree
    end

    create_table "coupon_codes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
      t.integer  "site_id",                          null: false
      t.integer  "coupon_id",                        null: false
      t.string   "code",                             null: false
      t.integer  "tracking_user_id"
      t.boolean  "is_imported",      default: false, null: false
      t.datetime "end_date"
      t.datetime "used_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["coupon_id", "is_imported", "site_id", "used_at", "end_date"], name: "coupon_codes_c_id_is_imp_s_id_used_at_end_date", using: :btree
    end

    create_table "coupon_imports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
      t.integer  "user_id",                                             null: false
      t.integer  "site_id",                                             null: false
      t.string   "status",                          default: "pending"
      t.text     "error_messages", limit: 16777215
      t.string   "file"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "coupon_tags", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "tag_id"
      t.integer  "coupon_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["tag_id", "coupon_id"], name: "index_coupon_tags_on_site_id_and_tag_id_and_coupon_id", unique: true, using: :btree
    end

    create_table "coupons", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "site_id",                                                                                  null: false
      t.string   "status",                                                               default: "pending", null: false
      t.decimal  "priority_score",                              precision: 10, scale: 5, default: "0.0",     null: false
      t.integer  "shop_list_priority",                                                   default: 5,         null: false
      t.integer  "affiliate_network_id"
      t.integer  "shop_id"
      t.integer  "campaign_id"
      t.string   "tracking_platform_campaign_id"
      t.string   "tracking_platform_banner_id"
      t.boolean  "is_top",                                                               default: false,     null: false
      t.boolean  "is_exclusive",                                                         default: false,     null: false
      t.boolean  "is_free",                                                              default: false,     null: false
      t.boolean  "is_mobile",                                                            default: false,     null: false
      t.boolean  "is_international",                                                     default: false,     null: false
      t.boolean  "is_free_delivery",                                                     default: false,     null: false
      t.boolean  "is_imported",                                                          default: false,     null: false
      t.boolean  "is_hidden",                                                            default: false,     null: false
      t.integer  "negative_votes"
      t.integer  "positive_votes"
      t.string   "title"
      t.string   "coupon_type"
      t.text     "url",                           limit: 65535
      t.text     "old_url",                       limit: 65535
      t.string   "code"
      t.text     "description",                   limit: 65535
      t.datetime "start_date"
      t.datetime "end_date"
      t.integer  "clicks",                                                               default: 0,         null: false
      t.float    "savings",                       limit: 24
      t.string   "savings_in"
      t.integer  "coupon_of_the_week"
      t.string   "mini_title"
      t.integer  "ranking_value"
      t.integer  "order_position"
      t.string   "commission_type"
      t.float    "commission_value",              limit: 24
      t.string   "logo"
      t.string   "logo_color"
      t.string   "logo_text_first_line"
      t.string   "logo_text_second_line"
      t.integer  "shop_slider_position"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "use_uniq_codes",                                                       default: false,     null: false
      t.string   "info_discount"
      t.string   "info_min_purchase"
      t.string   "info_limited_clients"
      t.string   "info_limited_brands"
      t.string   "info_conditions"
      t.index ["id", "shop_id", "start_date", "end_date", "savings", "savings_in", "status"], name: "index_savings_in_sd_and_ed_and_status", using: :btree
      t.index ["order_position"], name: "index_coupons_on_order_position", using: :btree
      t.index ["shop_id", "status", "start_date", "end_date", "is_hidden", "coupon_type", "code"], name: "coup_shop_id_status_sd_ed_is_hid_cou_type_code", using: :btree
      t.index ["site_id", "shop_id", "title", "code", "start_date", "end_date"], name: "index_coupons_on_site_id_n_shop_id_n_title_n_code_n_dates", unique: true, using: :btree
      t.index ["site_id", "status", "start_date", "end_date"], name: "index_coupons_on_site_id_and_status_and_start_date_and_end_date", using: :btree
    end

    create_table "csv_exports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
      t.integer  "site_id"
      t.integer  "user_id"
      t.string   "status",                          default: "pending"
      t.string   "export_type"
      t.string   "file"
      t.text     "params",         limit: 65535
      t.text     "error_messages", limit: 16777215
      t.datetime "last_executed"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "external_urls", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
      t.text     "url",        limit: 65535, collation: "utf8_general_ci"
      t.integer  "site_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "friendly_id_slugs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string   "slug",                                   collation: "utf8_bin"
      t.integer  "sluggable_id",              null: false
      t.string   "sluggable_type", limit: 50
      t.string   "scope"
      t.datetime "created_at"
      t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
      t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
      t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
      t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree
    end

    create_table "html_documents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string   "meta_robots"
      t.string   "meta_keywords"
      t.text     "meta_description",    limit: 65535
      t.string   "meta_title"
      t.string   "meta_title_fallback"
      t.text     "content",             limit: 65535
      t.text     "welcome_text",        limit: 65535
      t.string   "h1"
      t.string   "h2"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "htmlable_id"
      t.string   "htmlable_type"
      t.text     "head_scripts",        limit: 65535
      t.string   "header_image"
      t.string   "mobile_header_image"
      t.string   "header_font_color"
      t.datetime "countdown_date"
      t.index ["htmlable_id", "htmlable_type"], name: "index_html_documents_on_htmlable_id_and_htmlable_type", using: :btree
    end

    create_table "media", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "site_id"
      t.string   "file_name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["site_id"], name: "index_media_on_site_id", using: :btree
    end

    create_table "newsletter_subscriber_shops", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
      t.integer "newsletter_subscriber_id"
      t.integer "shop_id"
    end

    create_table "newsletter_subscribers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "site_id"
      t.string   "email"
      t.boolean  "active",                                       default: true
      t.boolean  "is_mailchimp_confirmed",                       default: false, null: false
      t.boolean  "is_mailchimp_unsubscribed",                    default: false
      t.string   "token",                                                        null: false
      t.boolean  "sent_to_mailchimp",                            default: false, null: false
      t.boolean  "with_error",                                   default: false, null: false
      t.text     "error",                     limit: 4294967295
      t.integer  "reminder_level"
      t.datetime "last_reminder_sent_at"
      t.datetime "optin_at"
      t.datetime "unsubscribed_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["email", "active"], name: "index_newsletter_subscribers_on_email_and_active", using: :btree
      t.index ["email"], name: "index_newsletter_subscribers_on_email", using: :btree
    end

    create_table "options", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "site_id"
      t.string   "name"
      t.text     "value",       limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "campaign_id"
      t.index ["site_id", "name", "campaign_id"], name: "index_options_on_site_id_and_name_and_campaign_id", unique: true, using: :btree
      t.index ["site_id", "name"], name: "index_options_on_site_id_and_name", using: :btree
    end

    create_table "redirect_rules", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string   "source",                                   null: false
      t.boolean  "source_is_regex",          default: false, null: false
      t.boolean  "source_is_case_sensitive", default: false, null: false
      t.string   "destination",                              null: false
      t.boolean  "active",                   default: false, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["active"], name: "index_redirect_rules_on_active", using: :btree
      t.index ["source"], name: "index_redirect_rules_on_source", using: :btree
      t.index ["source_is_case_sensitive"], name: "index_redirect_rules_on_source_is_case_sensitive", using: :btree
      t.index ["source_is_regex"], name: "index_redirect_rules_on_source_is_regex", using: :btree
    end

    create_table "relations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
      t.integer  "relation_from_id"
      t.string   "relation_from_type"
      t.integer  "relation_to_id"
      t.string   "relation_to_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["relation_from_id", "relation_from_type", "relation_to_id", "relation_to_type"], name: "relation_index", using: :btree
    end

    create_table "request_environment_rules", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "redirect_rule_id",                                    null: false
      t.string   "environment_key_name",                                null: false
      t.string   "environment_value",                                   null: false
      t.boolean  "environment_value_is_regex",          default: false, null: false
      t.boolean  "environment_value_is_case_sensitive", default: true,  null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["redirect_rule_id"], name: "index_request_environment_rules_on_redirect_rule_id", using: :btree
    end

    create_table "sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string   "session_id",                  null: false
      t.text     "data",       limit: 16777215
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
      t.index ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
    end

    create_table "shop_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
      t.integer  "shop_id"
      t.integer  "category_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["shop_id", "category_id"], name: "index_shop_categories_on_shop_id_and_category_id", using: :btree
    end

    create_table "shop_imports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
      t.integer  "user_id",                                             null: false
      t.integer  "site_id",                                             null: false
      t.string   "status",                          default: "pending"
      t.text     "error_messages", limit: 16777215
      t.string   "file"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "shop_votes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string   "ip"
      t.string   "user_agent"
      t.integer  "shop_id"
      t.integer  "vote_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "shops", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "tier_group",                                                           default: 4
      t.integer  "site_id",                                                                                  null: false
      t.integer  "person_in_charge_id"
      t.integer  "prefered_affiliate_network_id"
      t.string   "status",                                                               default: "pending", null: false
      t.decimal  "priority_score",                              precision: 10, scale: 5, default: "0.0",     null: false
      t.boolean  "is_hidden",                                                            default: false
      t.boolean  "is_top",                                                               default: false,     null: false
      t.boolean  "is_default_clickout",                                                  default: true,      null: false
      t.boolean  "is_featured",                                                          default: false,     null: false
      t.integer  "shop_slider_position",                                                 default: 0
      t.string   "title"
      t.string   "anchor_text"
      t.string   "url"
      t.text     "fallback_url",                  limit: 65535
      t.string   "slug",                                                                                                  collation: "utf8_bin"
      t.string   "link_title"
      t.text     "coupon_targeting_script",       limit: 65535
      t.string   "logo"
      t.string   "logo_cropped"
      t.string   "logo_alt_text"
      t.string   "logo_title_text"
      t.string   "merchant_id"
      t.string   "header_image"
      t.integer  "author_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "votes",                                                                default: 0,         null: false
      t.integer  "voters",                                                               default: 0,         null: false
      t.decimal  "clickout_value",                              precision: 10, scale: 2, default: "0.0",     null: false
      t.integer  "priority",                                                             default: 4,         null: false
      t.integer  "active_coupons_count",                                                 default: 0,         null: false
      t.boolean  "is_imported",                                                          default: false,     null: false
      t.text     "info_address",                  limit: 65535
      t.text     "info_phone",                    limit: 65535
      t.text     "info_free_shipping",            limit: 65535
      t.text     "info_payment_methods",          limit: 65535
      t.text     "info_delivery_methods",         limit: 65535
      t.string   "first_coupon_image"
      t.index ["is_featured"], name: "index_shops_on_is_featured", using: :btree
      t.index ["is_hidden"], name: "index_shops_on_is_hidden", using: :btree
      t.index ["is_top"], name: "index_shops_on_is_top", using: :btree
      t.index ["site_id", "slug", "status"], name: "index_shops_on_site_id_and_slug_and_status", using: :btree
      t.index ["site_id", "slug"], name: "index_shops_on_site_id_and_slug", using: :btree
      t.index ["site_id", "status", "active_coupons_count", "tier_group", "priority_score"], name: "shops_s_id_stat_act_cou_tier_prio_score", using: :btree
      t.index ["slug"], name: "index_shops_on_slug", using: :btree
    end

    create_table "site_coupon_clicks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "site_id",                null: false
      t.integer  "coupon_id",              null: false
      t.integer  "clicks",     default: 0
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["site_id", "coupon_id"], name: "index_site_coupon_clicks_on_site_id_and_coupon_id", unique: true, using: :btree
    end

    create_table "site_custom_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "site_id"
      t.integer  "category_id"
      t.integer  "author_id"
      t.string   "name"
      t.text     "description",    limit: 65535
      t.string   "header_image"
      t.string   "slug",                                                      collation: "utf8_bin"
      t.string   "css_icon_class"
      t.integer  "ranking_value"
      t.boolean  "is_top",                       default: false, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["site_id", "category_id"], name: "index_site_custom_categories_on_site_id_and_category_id", using: :btree
    end

    create_table "site_custom_coupons", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "site_id"
      t.integer  "coupon_id"
      t.string   "title"
      t.text     "description",          limit: 65535
      t.integer  "coupon_of_the_week"
      t.string   "mini_title"
      t.integer  "ranking_value"
      t.integer  "order_position"
      t.string   "logo"
      t.integer  "shop_slider_position"
      t.boolean  "is_top",                             default: false, null: false
      t.boolean  "is_exclusive",                       default: false, null: false
      t.boolean  "is_free",                            default: false, null: false
      t.boolean  "is_mobile",                          default: false, null: false
      t.boolean  "is_international",                   default: false, null: false
      t.boolean  "is_free_delivery",                   default: false, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["site_id", "coupon_id"], name: "index_site_custom_coupons_on_site_id_and_coupon_id", unique: true, using: :btree
    end

    create_table "site_custom_shops", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "site_id",                                       null: false
      t.integer  "shop_id",                                       null: false
      t.string   "logo"
      t.string   "logo_cropped"
      t.string   "header_image"
      t.string   "logo_alt_text"
      t.string   "logo_title_text"
      t.string   "title"
      t.string   "link_title"
      t.text     "description",     limit: 65535
      t.boolean  "is_top",                        default: false, null: false
      t.boolean  "is_featured",                   default: false, null: false
      t.integer  "author_id"
      t.string   "status"
      t.string   "slug",                                                       collation: "utf8_bin"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["shop_id"], name: "index_site_custom_shops_on_shop_id", using: :btree
      t.index ["site_id"], name: "index_site_custom_shops_on_site_id", using: :btree
      t.index ["slug", "site_id"], name: "index_site_custom_shops_on_slug_and_site_id", unique: true, using: :btree
    end

    create_table "site_custom_translations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "site_id"
      t.integer  "translation_id"
      t.text     "value",          limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["site_id", "translation_id"], name: "index_site_custom_translations_on_site_id_and_translation_id", unique: true, using: :btree
      t.index ["site_id"], name: "index_site_custom_translations_on_site_id", using: :btree
      t.index ["translation_id"], name: "index_site_custom_translations_on_translation_id", using: :btree
    end

    create_table "site_status_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "site_id"
      t.integer  "category_id"
      t.string   "status"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["site_id", "category_id", "status"], name: "ssc_site_id_category_id_status", using: :btree
    end

    create_table "site_status_coupons", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "site_id"
      t.integer  "coupon_id"
      t.string   "status"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["site_id", "coupon_id", "status"], name: "index_site_status_coupons_on_site_id_and_coupon_id_and_status", using: :btree
    end

    create_table "site_status_shops", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "site_id"
      t.integer  "shop_id"
      t.string   "status"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["site_id", "shop_id", "status"], name: "index_site_status_shops_on_site_id_and_shop_id_and_status", using: :btree
    end

    create_table "site_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "site_id"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["site_id", "user_id"], name: "index_site_users_on_site_id_and_user_id", using: :btree
    end

    create_table "sites", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "country_id",                                                          null: false
      t.string   "name"
      t.string   "hostname"
      t.boolean  "is_multisite",                                        default: false, null: false
      t.boolean  "use_https",                                           default: false, null: false
      t.string   "subdir_name"
      t.string   "time_zone",                                                           null: false
      t.decimal  "commission_share_percentage", precision: 5, scale: 2, default: "0.0", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "asset_hostname"
      t.index ["country_id"], name: "index_sites_on_country_id", using: :btree
      t.index ["hostname", "is_multisite", "subdir_name"], name: "index_sites_on_hostname_and_is_multisite_and_subdir_name", using: :btree
      t.index ["hostname"], name: "index_sites_on_hostname", using: :btree
    end

    create_table "sliders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "campaign_id"
      t.integer  "site_id"
      t.string   "title",                           null: false
      t.integer  "position",    default: 1,         null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "status",      default: "blocked", null: false
      t.index ["campaign_id"], name: "index_sliders_on_campaign_id", using: :btree
      t.index ["site_id", "campaign_id", "status"], name: "index_sliders_on_site_id_and_campaign_id_and_status", using: :btree
      t.index ["site_id"], name: "index_sliders_on_site_id", using: :btree
    end

    create_table "slides", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "slide_position",                   default: 0,         null: false
      t.integer  "slider_id"
      t.integer  "record_id"
      t.string   "alt"
      t.string   "background_color"
      t.string   "coupon_first_line"
      t.string   "coupon_second_line"
      t.text     "external_url",       limit: 65535
      t.string   "on_click"
      t.string   "pre_title"
      t.string   "record_type"
      t.string   "src"
      t.string   "target",                           default: "_self"
      t.string   "thumbnail"
      t.string   "title"
      t.datetime "start_date"
      t.datetime "end_date"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "status",                           default: "blocked", null: false
      t.string   "button_text"
      t.index ["slider_id"], name: "index_slides_on_slider_id", using: :btree
    end

    create_table "snippets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "site_id"
      t.string   "color_one",          default: "#ddd",       null: false
      t.string   "color_two",          default: "#999",       null: false
      t.string   "color_three",        default: "#d74435",    null: false
      t.string   "color_four",         default: "#a33428",    null: false
      t.string   "color_five",         default: "#fff",       null: false
      t.string   "color_six",          default: "#333",       null: false
      t.boolean  "manual_mode",        default: false,        null: false
      t.string   "open",               default: "new_window", null: false
      t.integer  "quantity",           default: 3,            null: false
      t.boolean  "show_exclusive",     default: true,         null: false
      t.boolean  "show_free_delivery", default: true,         null: false
      t.boolean  "show_new",           default: true,         null: false
      t.boolean  "show_top",           default: true,         null: false
      t.string   "exclusive_ids"
      t.string   "free_delivery_ids"
      t.string   "new_ids"
      t.string   "top_ids"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "status",             default: "blocked",    null: false
      t.index ["site_id", "status"], name: "index_snippets_on_site_id_and_status", using: :btree
      t.index ["site_id"], name: "index_snippets_on_site_id", using: :btree
    end

    create_table "static_pages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "site_id"
      t.string   "title"
      t.string   "slug",                                             collation: "utf8_bin"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "header_color"
      t.string   "header_icon"
      t.string   "css_class"
      t.boolean  "display_sidebar", default: true,      null: false
      t.string   "status",          default: "blocked", null: false
      t.index ["site_id", "status"], name: "index_static_pages_on_site_id_and_status", using: :btree
      t.index ["site_id"], name: "index_static_pages_on_site_id", using: :btree
    end

    create_table "tags", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string  "word"
      t.integer "country_id"
      t.index ["word", "country_id"], name: "index_tags_on_word_and_country_id", unique: true, using: :btree
    end

    create_table "tracking_clicks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "tracking_user_id"
      t.integer  "site_id"
      t.string   "uniqid"
      t.integer  "coupon_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "referrer"
      t.text     "landing_page",     limit: 65535
      t.string   "click_type"
      t.string   "page_type"
      t.string   "utm_source"
      t.string   "utm_campaign"
      t.string   "utm_medium"
      t.string   "utm_term"
      t.string   "channel"
      t.index ["coupon_id"], name: "index_tracking_clicks_on_coupon_id", using: :btree
      t.index ["site_id"], name: "index_tracking_clicks_on_site_id", using: :btree
      t.index ["tracking_user_id"], name: "index_tracking_clicks_on_tracking_user_id", using: :btree
      t.index ["uniqid"], name: "index_tracking_clicks_on_uniqid", using: :btree
    end

    create_table "tracking_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "site_id"
      t.text     "data",         limit: 65535
      t.string   "email"
      t.string   "ip"
      t.string   "country"
      t.string   "city"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "uniqid"
      t.integer  "publisher_id"
      t.text     "referrer",     limit: 65535
      t.string   "gclid"
      t.string   "postal_code"
      t.index ["uniqid"], name: "index_tracking_users_on_uniqid", using: :btree
    end

    create_table "transactions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
      t.integer  "site_id"
      t.string   "site_name"
      t.string   "subid"
      t.integer  "tracking_click_id"
      t.integer  "tracking_user_id"
      t.string   "affiliate_network_slug"
      t.string   "affiliate_network_transaction_id"
      t.string   "program_name"
      t.string   "shop_title"
      t.decimal  "commission",                       precision: 8, scale: 2
      t.string   "currency"
      t.datetime "tracking_time"
      t.string   "tracking_time_unix"
      t.datetime "auto_approve_date"
      t.datetime "auto_deny_date"
      t.datetime "pending_status_date_changed"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "channel"
      t.integer  "coupon_id"
      t.index ["subid"], name: "subid", unique: true, using: :btree
      t.index ["tracking_click_id"], name: "index_transactions_on_tracking_click_id", using: :btree
    end

    create_table "translations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string   "locale"
      t.string   "key"
      t.text     "value",      limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["key"], name: "index_translations_on_key", using: :btree
      t.index ["locale", "key"], name: "index_translations_on_locale_and_key", unique: true, using: :btree
      t.index ["locale"], name: "index_translations_on_locale", using: :btree
    end

    create_table "user_countries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "user_id"
      t.integer  "country_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["user_id", "country_id"], name: "index_user_countries_on_user_id_and_country_id", using: :btree
    end

    create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string   "email",                  default: "",        null: false
      t.string   "encrypted_password",     default: "",        null: false
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",          default: 0,         null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.integer  "failed_attempts",        default: 0
      t.string   "unlock_token"
      t.datetime "locked_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "role",                   default: "guest",   null: false
      t.string   "first_name"
      t.string   "last_name"
      t.string   "status",                 default: "blocked", null: false
      t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
      t.index ["role"], name: "index_users_on_role", using: :btree
      t.index ["status"], name: "index_users_on_status", using: :btree
    end

    create_table "votes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer  "votes",      default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "widgets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string   "widget_type",               null: false
      t.string   "name",                      null: false
      t.text     "value",       limit: 65535
      t.integer  "site_id",                   null: false
      t.integer  "campaign_id"
      t.datetime "created_at"
      t.datetime "start_date"
      t.datetime "end_date"
      t.datetime "updated_at"
      t.index ["name"], name: "index_widgets_on_name", using: :btree
      t.index ["site_id", "campaign_id"], name: "index_widgets_on_site_id_and_campaign_id", using: :btree
      t.index ["site_id"], name: "index_widgets_on_site_id", using: :btree
      t.index ["start_date", "end_date"], name: "index_widgets_on_start_date_and_end_date", using: :btree
      t.index ["widget_type"], name: "index_widgets_on_widget_type", using: :btree
    end
  end
end
