-- MySQL dump 10.13  Distrib 5.5.46, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: pannacotta
-- ------------------------------------------------------
-- Server version	5.5.46-0ubuntu0.14.04.2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `activities`
--

DROP TABLE IF EXISTS `activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `trackable_id` int(11) DEFAULT NULL,
  `trackable_type` varchar(255) DEFAULT NULL,
  `owner_id` int(11) DEFAULT NULL,
  `owner_type` varchar(255) DEFAULT NULL,
  `key` varchar(255) DEFAULT NULL,
  `parameters` text,
  `recipient_id` int(11) DEFAULT NULL,
  `recipient_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `site_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_activities_on_trackable_id_and_trackable_type` (`trackable_id`,`trackable_type`),
  KEY `index_activities_on_owner_id_and_owner_type` (`owner_id`,`owner_type`),
  KEY `index_activities_on_recipient_id_and_recipient_type` (`recipient_id`,`recipient_type`)
) ENGINE=InnoDB AUTO_INCREMENT=256428 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `affiliate_networks`
--

DROP TABLE IF EXISTS `affiliate_networks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `affiliate_networks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `validate_subid` tinyint(1) NOT NULL DEFAULT '0',
  `slug` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_affiliate_networks_on_name` (`name`),
  UNIQUE KEY `index_affiliate_networks_on_slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=99 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api_keys`
--

DROP TABLE IF EXISTS `api_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_keys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `access_token` varchar(255) NOT NULL,
  `user_id` int(11) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `expires_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_api_keys_on_access_token` (`access_token`),
  KEY `index_api_keys_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `authors`
--

DROP TABLE IF EXISTS `authors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `authors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `bio` text,
  `google_plus_url` varchar(255) DEFAULT NULL,
  `profession` varchar(255) DEFAULT NULL,
  `ranking_name` varchar(255) DEFAULT NULL,
  `site_review` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'blocked',
  PRIMARY KEY (`id`),
  KEY `index_authors_on_site_id` (`site_id`)
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `campaigns`
--

DROP TABLE IF EXISTS `campaigns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campaigns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author_id` int(11) DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `shop_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `tag_string` varchar(255) DEFAULT NULL,
  `blog_feed_url` varchar(255) DEFAULT NULL,
  `box_color` varchar(255) DEFAULT NULL,
  `max_coupons` int(11) DEFAULT NULL,
  `coupon_box_color` varchar(255) DEFAULT NULL,
  `coupon_box_headline` varchar(255) DEFAULT NULL,
  `coupon_box_icon` varchar(255) DEFAULT NULL,
  `coupon_filter_color` varchar(255) DEFAULT NULL,
  `coupon_filter_icon` varchar(255) DEFAULT NULL,
  `coupon_filter_text` varchar(255) DEFAULT NULL,
  `h1_first_line` varchar(255) DEFAULT NULL,
  `h1_second_line` varchar(255) DEFAULT NULL,
  `nav_color` varchar(255) DEFAULT NULL,
  `nav_icon` varchar(255) DEFAULT NULL,
  `nav_title` varchar(255) DEFAULT NULL,
  `nav_link_color` varchar(255) DEFAULT NULL,
  `show_nav_link` int(11) DEFAULT NULL,
  `text` text,
  `text_headline` varchar(255) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'blocked',
  `is_imported` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_campaigns_on_site_id_and_name` (`site_id`,`name`),
  UNIQUE KEY `index_campaigns_on_site_id_and_slug_and_shop` (`site_id`,`slug`,`shop_id`) USING BTREE,
  KEY `index_campaigns_on_site_id` (`site_id`),
  KEY `index_campaigns_on_slug` (`slug`),
  KEY `index_campaigns_on_show_nav_link` (`show_nav_link`),
  KEY `index_campaigns_on_shop_id` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1961 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `main_category` tinyint(1) NOT NULL DEFAULT '0',
  `author_id` int(11) DEFAULT NULL,
  `origin_id` int(11) DEFAULT NULL,
  `site_id` int(11) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `css_icon_class` varchar(255) DEFAULT NULL,
  `description` text,
  `header_image` varchar(255) DEFAULT NULL,
  `is_top` int(11) DEFAULT NULL,
  `ranking_value` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `active_coupons_count` int(11) NOT NULL DEFAULT '0',
  `related_slider_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_categories_on_site_id_and_slug_and_default_site_id` (`site_id`,`slug`),
  KEY `index_categories_on_author_id` (`author_id`),
  KEY `index_categories_on_site_id_and_status` (`site_id`,`status`),
  KEY `index_categories_on_is_top` (`is_top`),
  KEY `index_categories_on_ranking_value` (`ranking_value`),
  KEY `index_categories_on_main_category` (`main_category`),
  KEY `index_categories_on_parent_id` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=389 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `countries`
--

DROP TABLE IF EXISTS `countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `countries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `locale` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_countries_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `coupon_categories`
--

DROP TABLE IF EXISTS `coupon_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `coupon_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `coupon_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_coupon_categories_on_coupon_id_and_category_id_and_site_id` (`coupon_id`,`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=217531 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `coupon_codes`
--

DROP TABLE IF EXISTS `coupon_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `coupon_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `coupon_id` int(11) NOT NULL,
  `code` varchar(255) NOT NULL,
  `tracking_user_id` int(11) DEFAULT NULL,
  `is_imported` tinyint(1) NOT NULL DEFAULT '0',
  `end_date` datetime DEFAULT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=113162 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `coupon_imports`
--

DROP TABLE IF EXISTS `coupon_imports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `coupon_imports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `status` varchar(255) DEFAULT 'pending',
  `error_messages` mediumtext,
  `file` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3497 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `coupon_tags`
--

DROP TABLE IF EXISTS `coupon_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `coupon_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) DEFAULT NULL,
  `coupon_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_coupon_tags_on_site_id_and_tag_id_and_coupon_id` (`tag_id`,`coupon_id`)
) ENGINE=InnoDB AUTO_INCREMENT=165161 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `coupons`
--

DROP TABLE IF EXISTS `coupons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `coupons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `priority_score` decimal(10,5) NOT NULL DEFAULT '0.00000',
  `shop_list_priority` int(11) NOT NULL DEFAULT '5',
  `affiliate_network_id` int(11) DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `tracking_platform_campaign_id` varchar(255) DEFAULT NULL,
  `tracking_platform_banner_id` varchar(255) DEFAULT NULL,
  `is_top` tinyint(1) NOT NULL DEFAULT '0',
  `is_exclusive` tinyint(1) NOT NULL DEFAULT '0',
  `is_free` tinyint(1) NOT NULL DEFAULT '0',
  `is_mobile` tinyint(1) NOT NULL DEFAULT '0',
  `is_international` tinyint(1) NOT NULL DEFAULT '0',
  `is_free_delivery` tinyint(1) NOT NULL DEFAULT '0',
  `is_imported` tinyint(1) NOT NULL DEFAULT '0',
  `is_general` tinyint(1) NOT NULL DEFAULT '0',
  `is_hidden` tinyint(1) NOT NULL DEFAULT '0',
  `negative_votes` int(11) DEFAULT NULL,
  `positive_votes` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `coupon_type` varchar(255) DEFAULT NULL,
  `url` text,
  `old_url` text,
  `code` varchar(255) DEFAULT NULL,
  `description` text,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `clicks` int(11) NOT NULL DEFAULT '0',
  `savings` float DEFAULT NULL,
  `savings_in` varchar(255) DEFAULT NULL,
  `total_costs` float DEFAULT NULL,
  `coupon_of_the_week` int(11) DEFAULT NULL,
  `mini_title` varchar(255) DEFAULT NULL,
  `ranking_value` int(11) DEFAULT NULL,
  `order_position` int(11) DEFAULT NULL,
  `commission_type` varchar(255) DEFAULT NULL,
  `commission_value` float DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `logo_color` varchar(255) DEFAULT NULL,
  `logo_text_first_line` varchar(255) DEFAULT NULL,
  `logo_text_second_line` varchar(255) DEFAULT NULL,
  `old_price` float DEFAULT NULL,
  `shop_slider_position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `snippet_logo` varchar(255) DEFAULT NULL,
  `use_uniq_codes` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_coupons_on_site_id_n_shop_id_n_title_n_code_n_dates` (`site_id`,`shop_id`,`title`,`code`,`start_date`,`end_date`),
  KEY `index_coupons_on_site_id_and_status_and_start_date_and_end_date` (`site_id`,`status`,`start_date`,`end_date`),
  KEY `index_coupons_on_order_position` (`order_position`),
  KEY `index_coupons_on_is_general` (`is_general`),
  KEY `index_savings_in_sd_and_ed_and_status` (`id`,`shop_id`,`start_date`,`end_date`,`savings`,`savings_in`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=207939 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `coupons_copy`
--

DROP TABLE IF EXISTS `coupons_copy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `coupons_copy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `affiliate_network_id` int(11) DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `tracking_platform_campaign_id` varchar(255) DEFAULT NULL,
  `tracking_platform_banner_id` varchar(255) DEFAULT NULL,
  `is_top` tinyint(1) NOT NULL DEFAULT '0',
  `is_exclusive` tinyint(1) NOT NULL DEFAULT '0',
  `is_free` tinyint(1) NOT NULL DEFAULT '0',
  `is_mobile` tinyint(1) NOT NULL DEFAULT '0',
  `is_international` tinyint(1) NOT NULL DEFAULT '0',
  `is_free_delivery` tinyint(1) NOT NULL DEFAULT '0',
  `is_imported` tinyint(1) NOT NULL DEFAULT '0',
  `negative_votes` int(11) DEFAULT NULL,
  `positive_votes` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `coupon_type` varchar(255) DEFAULT NULL,
  `url` text,
  `code` varchar(255) DEFAULT NULL,
  `description` text,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `clicks` int(11) DEFAULT NULL,
  `savings` float DEFAULT NULL,
  `savings_in` varchar(255) DEFAULT NULL,
  `total_costs` float DEFAULT NULL,
  `coupon_of_the_week` int(11) DEFAULT NULL,
  `mini_title` varchar(255) DEFAULT NULL,
  `ranking_value` int(11) DEFAULT NULL,
  `order_position` int(11) DEFAULT NULL,
  `commission_type` varchar(255) DEFAULT NULL,
  `commission_value` float DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `old_price` float DEFAULT NULL,
  `shop_slider_position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `snippet_logo` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_coupons_on_site_id_n_shop_id_n_title_n_code_n_dates` (`site_id`,`shop_id`,`title`,`code`,`start_date`,`end_date`),
  KEY `index_coupons_on_site_id_and_status_and_start_date_and_end_date` (`site_id`,`status`,`start_date`,`end_date`),
  KEY `index_coupons_on_order_position` (`order_position`)
) ENGINE=InnoDB AUTO_INCREMENT=62672 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `csv_exports`
--

DROP TABLE IF EXISTS `csv_exports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `csv_exports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT 'pending',
  `export_type` varchar(255) DEFAULT NULL,
  `file` varchar(255) DEFAULT NULL,
  `params` text,
  `error_messages` mediumtext,
  `last_executed` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=694 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `external_urls`
--

DROP TABLE IF EXISTS `external_urls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `external_urls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` text CHARACTER SET utf8,
  `site_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10683 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `friendly_id_slugs`
--

DROP TABLE IF EXISTS `friendly_id_slugs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `friendly_id_slugs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `slug` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `sluggable_id` int(11) NOT NULL,
  `sluggable_type` varchar(50) DEFAULT NULL,
  `scope` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope` (`slug`,`sluggable_type`,`scope`),
  KEY `index_friendly_id_slugs_on_sluggable_id` (`sluggable_id`),
  KEY `index_friendly_id_slugs_on_slug_and_sluggable_type` (`slug`,`sluggable_type`),
  KEY `index_friendly_id_slugs_on_sluggable_type` (`sluggable_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `html_documents`
--

DROP TABLE IF EXISTS `html_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `html_documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `meta_robots` varchar(255) DEFAULT NULL,
  `meta_keywords` varchar(255) DEFAULT NULL,
  `meta_description` varchar(255) DEFAULT NULL,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_title_fallback` varchar(255) DEFAULT NULL,
  `content` text,
  `welcome_text` text,
  `h1` varchar(255) DEFAULT NULL,
  `h2` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `htmlable_id` int(11) DEFAULT NULL,
  `htmlable_type` varchar(255) DEFAULT NULL,
  `head_scripts` text,
  PRIMARY KEY (`id`),
  KEY `index_html_documents_on_htmlable_id_and_htmlable_type` (`htmlable_id`,`htmlable_type`)
) ENGINE=InnoDB AUTO_INCREMENT=12491 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `media`
--

DROP TABLE IF EXISTS `media`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `media` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_media_on_site_id` (`site_id`)
) ENGINE=InnoDB AUTO_INCREMENT=24304 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `newsletter_subscriber_shops`
--

DROP TABLE IF EXISTS `newsletter_subscriber_shops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `newsletter_subscriber_shops` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `newsletter_subscriber_id` int(11) DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=199127 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `newsletter_subscribers`
--

DROP TABLE IF EXISTS `newsletter_subscribers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `newsletter_subscribers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `is_mailchimp_confirmed` tinyint(1) NOT NULL DEFAULT '0',
  `is_mailchimp_unsubscribed` tinyint(1) DEFAULT '0',
  `token` varchar(255) NOT NULL,
  `sent_to_mailchimp` tinyint(1) NOT NULL DEFAULT '0',
  `with_error` tinyint(1) NOT NULL DEFAULT '0',
  `error` longtext,
  `reminder_level` int(11) DEFAULT NULL,
  `last_reminder_sent_at` datetime DEFAULT NULL,
  `optin_at` datetime DEFAULT NULL,
  `unsubscribed_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_newsletter_subscribers_on_email` (`email`),
  KEY `index_newsletter_subscribers_on_email_and_active` (`email`,`active`)
) ENGINE=InnoDB AUTO_INCREMENT=250143 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `options`
--

DROP TABLE IF EXISTS `options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `options` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `value` mediumtext,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_options_on_site_id_and_name_and_campaign_id` (`site_id`,`name`,`campaign_id`),
  KEY `index_options_on_site_id_and_name` (`site_id`,`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8005 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `options_backup_05_11_2015`
--

DROP TABLE IF EXISTS `options_backup_05_11_2015`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `options_backup_05_11_2015` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `value` mediumtext,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_options_on_site_id_and_name_and_campaign_id` (`site_id`,`name`,`campaign_id`),
  KEY `index_options_on_site_id_and_name` (`site_id`,`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7234 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `redirect_rules`
--

DROP TABLE IF EXISTS `redirect_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `redirect_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source` varchar(255) NOT NULL,
  `source_is_regex` tinyint(1) NOT NULL DEFAULT '0',
  `source_is_case_sensitive` tinyint(1) NOT NULL DEFAULT '0',
  `destination` varchar(255) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_redirect_rules_on_source` (`source`),
  KEY `index_redirect_rules_on_active` (`active`),
  KEY `index_redirect_rules_on_source_is_regex` (`source_is_regex`),
  KEY `index_redirect_rules_on_source_is_case_sensitive` (`source_is_case_sensitive`)
) ENGINE=InnoDB AUTO_INCREMENT=1414 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `relations`
--

DROP TABLE IF EXISTS `relations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `relation_from_id` int(11) DEFAULT NULL,
  `relation_from_type` varchar(255) DEFAULT NULL,
  `relation_to_id` int(11) DEFAULT NULL,
  `relation_to_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2212 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_environment_rules`
--

DROP TABLE IF EXISTS `request_environment_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_environment_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `redirect_rule_id` int(11) NOT NULL,
  `environment_key_name` varchar(255) NOT NULL,
  `environment_value` varchar(255) NOT NULL,
  `environment_value_is_regex` tinyint(1) NOT NULL DEFAULT '0',
  `environment_value_is_case_sensitive` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_request_environment_rules_on_redirect_rule_id` (`redirect_rule_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1414 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_bin NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) NOT NULL,
  `data` mediumtext,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=33760830 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shop_categories`
--

DROP TABLE IF EXISTS `shop_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shop_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shop_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_shop_categories_on_shop_id_and_category_id` (`shop_id`,`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3310 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shop_imports`
--

DROP TABLE IF EXISTS `shop_imports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shop_imports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `status` varchar(255) DEFAULT 'pending',
  `error_messages` mediumtext,
  `file` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shops`
--

DROP TABLE IF EXISTS `shops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shops` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `person_in_charge_id` int(11) DEFAULT NULL,
  `prefered_affiliate_network_id` int(11) DEFAULT NULL,
  `traffic` varchar(255) DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `priority_score` decimal(10,5) NOT NULL DEFAULT '0.00000',
  `is_hidden` tinyint(1) DEFAULT '0',
  `is_top` tinyint(1) NOT NULL DEFAULT '0',
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `shop_slider_position` int(11) DEFAULT '0',
  `title` varchar(255) DEFAULT NULL,
  `anchor_text` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `fallback_url` text,
  `slug` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `link_title` varchar(255) DEFAULT NULL,
  `description` text,
  `logo` varchar(255) DEFAULT NULL,
  `logo_cropped` varchar(255) DEFAULT NULL,
  `logo_alt_text` varchar(255) DEFAULT NULL,
  `logo_title_text` varchar(255) DEFAULT NULL,
  `merchant_id` varchar(255) DEFAULT NULL,
  `header_image` varchar(255) DEFAULT NULL,
  `author_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `votes` int(11) NOT NULL DEFAULT '0',
  `voters` int(11) NOT NULL DEFAULT '0',
  `clickout_value` decimal(10,2) NOT NULL DEFAULT '0.00',
  `priority` int(11) NOT NULL DEFAULT '4',
  `active_coupons_count` int(11) NOT NULL DEFAULT '0',
  `display_logo_on_coupons` tinyint(1) DEFAULT '0',
  `display_description_on_shop_page` tinyint(1) DEFAULT '0',
  `is_imported` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_shops_on_slug` (`slug`),
  KEY `index_shops_on_site_id_and_slug_and_status` (`site_id`,`slug`,`status`),
  KEY `index_shops_on_site_id_and_slug` (`site_id`,`slug`),
  KEY `index_shops_on_is_top` (`is_top`),
  KEY `index_shops_on_is_featured` (`is_featured`),
  KEY `index_shops_on_is_hidden` (`is_hidden`)
) ENGINE=InnoDB AUTO_INCREMENT=10096 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_coupon_clicks`
--

DROP TABLE IF EXISTS `site_coupon_clicks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_coupon_clicks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `coupon_id` int(11) NOT NULL,
  `clicks` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_site_coupon_clicks_on_site_id_and_coupon_id` (`site_id`,`coupon_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16789 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_custom_categories`
--

DROP TABLE IF EXISTS `site_custom_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_custom_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `author_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `header_image` varchar(255) DEFAULT NULL,
  `slug` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `css_icon_class` varchar(255) DEFAULT NULL,
  `ranking_value` int(11) DEFAULT NULL,
  `is_top` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_site_custom_categories_on_site_id_and_category_id` (`site_id`,`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_custom_coupons`
--

DROP TABLE IF EXISTS `site_custom_coupons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_custom_coupons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `coupon_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` text,
  `coupon_of_the_week` int(11) DEFAULT NULL,
  `mini_title` varchar(255) DEFAULT NULL,
  `ranking_value` int(11) DEFAULT NULL,
  `order_position` int(11) DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `shop_slider_position` int(11) DEFAULT NULL,
  `is_top` tinyint(1) NOT NULL DEFAULT '0',
  `is_exclusive` tinyint(1) NOT NULL DEFAULT '0',
  `is_free` tinyint(1) NOT NULL DEFAULT '0',
  `is_mobile` tinyint(1) NOT NULL DEFAULT '0',
  `is_international` tinyint(1) NOT NULL DEFAULT '0',
  `is_free_delivery` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_site_custom_coupons_on_site_id_and_coupon_id` (`site_id`,`coupon_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_custom_shops`
--

DROP TABLE IF EXISTS `site_custom_shops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_custom_shops` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `shop_id` int(11) NOT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `logo_cropped` varchar(255) DEFAULT NULL,
  `header_image` varchar(255) DEFAULT NULL,
  `logo_alt_text` varchar(255) DEFAULT NULL,
  `logo_title_text` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `link_title` varchar(255) DEFAULT NULL,
  `description` text,
  `is_top` tinyint(1) NOT NULL DEFAULT '0',
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  `author_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `slug` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_site_custom_shops_on_slug_and_site_id` (`slug`,`site_id`),
  KEY `index_site_custom_shops_on_site_id` (`site_id`),
  KEY `index_site_custom_shops_on_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_custom_translations`
--

DROP TABLE IF EXISTS `site_custom_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_custom_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `translation_id` int(11) DEFAULT NULL,
  `value` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_site_custom_translations_on_site_id_and_translation_id` (`site_id`,`translation_id`),
  KEY `index_site_custom_translations_on_site_id` (`site_id`),
  KEY `index_site_custom_translations_on_translation_id` (`translation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5736 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_status_categories`
--

DROP TABLE IF EXISTS `site_status_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_status_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ssc_site_id_category_id_status` (`site_id`,`category_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_status_coupons`
--

DROP TABLE IF EXISTS `site_status_coupons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_status_coupons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `coupon_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_site_status_coupons_on_site_id_and_coupon_id_and_status` (`site_id`,`coupon_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_status_shops`
--

DROP TABLE IF EXISTS `site_status_shops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_status_shops` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_site_status_shops_on_site_id_and_shop_id_and_status` (`site_id`,`shop_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_users`
--

DROP TABLE IF EXISTS `site_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_site_users_on_site_id_and_user_id` (`site_id`,`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sites`
--

DROP TABLE IF EXISTS `sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `country_id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `hostname` varchar(255) DEFAULT NULL,
  `is_multisite` tinyint(1) NOT NULL DEFAULT '0',
  `subdir_name` varchar(255) DEFAULT NULL,
  `time_zone` varchar(255) NOT NULL,
  `commission_share_percentage` decimal(5,2) NOT NULL DEFAULT '0.00',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `asset_hostname` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sites_on_country_id` (`country_id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sliders`
--

DROP TABLE IF EXISTS `sliders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sliders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `campaign_id` int(11) DEFAULT NULL,
  `site_id` int(11) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `position` int(11) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'blocked',
  PRIMARY KEY (`id`),
  KEY `index_sliders_on_site_id` (`site_id`),
  KEY `index_sliders_on_campaign_id` (`campaign_id`),
  KEY `index_sliders_on_site_id_and_campaign_id_and_status` (`site_id`,`campaign_id`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=625 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `slides`
--

DROP TABLE IF EXISTS `slides`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `slides` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `slide_position` int(11) NOT NULL DEFAULT '0',
  `slider_id` int(11) DEFAULT NULL,
  `record_id` int(11) DEFAULT NULL,
  `alt` varchar(255) DEFAULT NULL,
  `background_color` varchar(255) DEFAULT NULL,
  `coupon_first_line` varchar(255) DEFAULT NULL,
  `coupon_second_line` varchar(255) DEFAULT NULL,
  `external_url` text,
  `on_click` varchar(255) DEFAULT NULL,
  `pre_title` varchar(255) DEFAULT NULL,
  `record_type` varchar(255) DEFAULT NULL,
  `src` varchar(255) DEFAULT NULL,
  `target` varchar(255) DEFAULT '_self',
  `thumbnail` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'blocked',
  `button_text` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_slides_on_slider_id` (`slider_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1959 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `snippets`
--

DROP TABLE IF EXISTS `snippets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `snippets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `color_one` varchar(255) NOT NULL DEFAULT '#ddd',
  `color_two` varchar(255) NOT NULL DEFAULT '#999',
  `color_three` varchar(255) NOT NULL DEFAULT '#d74435',
  `color_four` varchar(255) NOT NULL DEFAULT '#a33428',
  `color_five` varchar(255) NOT NULL DEFAULT '#fff',
  `color_six` varchar(255) NOT NULL DEFAULT '#333',
  `manual_mode` tinyint(1) NOT NULL DEFAULT '0',
  `open` varchar(255) NOT NULL DEFAULT 'new_window',
  `quantity` int(11) NOT NULL DEFAULT '3',
  `show_exclusive` tinyint(1) NOT NULL DEFAULT '1',
  `show_free_delivery` tinyint(1) NOT NULL DEFAULT '1',
  `show_new` tinyint(1) NOT NULL DEFAULT '1',
  `show_top` tinyint(1) NOT NULL DEFAULT '1',
  `exclusive_ids` varchar(255) DEFAULT NULL,
  `free_delivery_ids` varchar(255) DEFAULT NULL,
  `new_ids` varchar(255) DEFAULT NULL,
  `top_ids` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'blocked',
  PRIMARY KEY (`id`),
  KEY `index_snippets_on_site_id` (`site_id`),
  KEY `index_snippets_on_site_id_and_status` (`site_id`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `static_pages`
--

DROP TABLE IF EXISTS `static_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `static_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `slug` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `header_color` varchar(255) DEFAULT NULL,
  `header_icon` varchar(255) DEFAULT NULL,
  `css_class` varchar(255) DEFAULT NULL,
  `display_sidebar` tinyint(1) NOT NULL DEFAULT '1',
  `status` varchar(255) NOT NULL DEFAULT 'blocked',
  PRIMARY KEY (`id`),
  KEY `index_static_pages_on_site_id` (`site_id`),
  KEY `index_static_pages_on_site_id_and_status` (`site_id`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=144 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `word` varchar(255) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_tags_on_word_and_country_id` (`word`,`country_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2780 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tracking_clicks`
--

DROP TABLE IF EXISTS `tracking_clicks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tracking_clicks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tracking_user_id` int(11) DEFAULT NULL,
  `site_id` int(11) DEFAULT NULL,
  `uniqid` varchar(255) DEFAULT NULL,
  `coupon_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `referrer` varchar(255) DEFAULT NULL,
  `landing_page` text,
  `click_type` varchar(255) DEFAULT NULL,
  `page_type` varchar(255) DEFAULT NULL,
  `utm_source` varchar(255) DEFAULT NULL,
  `utm_campaign` varchar(255) DEFAULT NULL,
  `utm_medium` varchar(255) DEFAULT NULL,
  `utm_term` varchar(255) DEFAULT NULL,
  `channel` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tracking_clicks_on_tracking_user_id` (`tracking_user_id`),
  KEY `index_tracking_clicks_on_site_id` (`site_id`),
  KEY `index_tracking_clicks_on_coupon_id` (`coupon_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12355088 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tracking_users`
--

DROP TABLE IF EXISTS `tracking_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tracking_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `data` text,
  `email` varchar(255) DEFAULT NULL,
  `ip` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `uniqid` varchar(255) DEFAULT NULL,
  `publisher_id` int(11) DEFAULT NULL,
  `referrer` text,
  `gclid` varchar(255) DEFAULT NULL,
  `postal_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tracking_users_on_uniqid` (`uniqid`)
) ENGINE=InnoDB AUTO_INCREMENT=5376637 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `site_name` varchar(255) DEFAULT NULL,
  `subid` varchar(255) DEFAULT NULL,
  `tracking_click_id` int(11) DEFAULT NULL,
  `tracking_user_id` int(11) DEFAULT NULL,
  `affiliate_network_slug` varchar(255) DEFAULT NULL,
  `affiliate_network_transaction_id` varchar(255) DEFAULT NULL,
  `program_name` varchar(255) DEFAULT NULL,
  `shop_title` varchar(255) DEFAULT NULL,
  `commission` decimal(8,2) DEFAULT NULL,
  `currency` varchar(255) DEFAULT NULL,
  `tracking_time` datetime DEFAULT NULL,
  `tracking_time_unix` varchar(255) DEFAULT NULL,
  `auto_approve_date` datetime DEFAULT NULL,
  `auto_deny_date` datetime DEFAULT NULL,
  `pending_status_date_changed` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `channel` varchar(255) DEFAULT NULL,
  `coupon_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `subid` (`subid`),
  KEY `index_transactions_on_subid` (`subid`),
  KEY `index_transactions_on_tracking_click_id` (`tracking_click_id`)
) ENGINE=InnoDB AUTO_INCREMENT=97068 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `translations`
--

DROP TABLE IF EXISTS `translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `locale` varchar(255) DEFAULT NULL,
  `key` varchar(255) DEFAULT NULL,
  `value` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_translations_on_locale_and_key` (`locale`,`key`),
  KEY `index_translations_on_locale` (`locale`),
  KEY `index_translations_on_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=164512 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_countries`
--

DROP TABLE IF EXISTS `user_countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_countries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_countries_on_user_id_and_country_id` (`user_id`,`country_id`)
) ENGINE=InnoDB AUTO_INCREMENT=399 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL DEFAULT '',
  `encrypted_password` varchar(255) NOT NULL DEFAULT '',
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) NOT NULL DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) DEFAULT NULL,
  `last_sign_in_ip` varchar(255) DEFAULT NULL,
  `failed_attempts` int(11) DEFAULT '0',
  `unlock_token` varchar(255) DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `role` varchar(255) NOT NULL DEFAULT 'guest',
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'blocked',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  KEY `index_users_on_role` (`role`),
  KEY `index_users_on_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `widgets`
--

DROP TABLE IF EXISTS `widgets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `widgets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `widget_type` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `value` text NOT NULL,
  `site_id` int(11) NOT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_widgets_on_name` (`name`),
  KEY `index_widgets_on_site_id` (`site_id`),
  KEY `index_widgets_on_site_id_and_campaign_id` (`site_id`,`campaign_id`),
  KEY `index_widgets_on_widget_type` (`widget_type`),
  KEY `index_widgets_on_start_date_and_end_date` (`start_date`,`end_date`)
) ENGINE=InnoDB AUTO_INCREMENT=5816 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-03-09 12:36:53
INSERT INTO schema_migrations (version) VALUES ('20131113102307');

INSERT INTO schema_migrations (version) VALUES ('20131113102433');

INSERT INTO schema_migrations (version) VALUES ('20131113102541');

INSERT INTO schema_migrations (version) VALUES ('20131113102610');

INSERT INTO schema_migrations (version) VALUES ('20131113102631');

INSERT INTO schema_migrations (version) VALUES ('20131113102700');

INSERT INTO schema_migrations (version) VALUES ('20131113102718');

INSERT INTO schema_migrations (version) VALUES ('20131113114344');

INSERT INTO schema_migrations (version) VALUES ('20131113114811');

INSERT INTO schema_migrations (version) VALUES ('20131113114930');

INSERT INTO schema_migrations (version) VALUES ('20131113114958');

INSERT INTO schema_migrations (version) VALUES ('20131113115052');

INSERT INTO schema_migrations (version) VALUES ('20131113115147');

INSERT INTO schema_migrations (version) VALUES ('20131113115258');

INSERT INTO schema_migrations (version) VALUES ('20131113115559');

INSERT INTO schema_migrations (version) VALUES ('20131113120841');

INSERT INTO schema_migrations (version) VALUES ('20131113121103');

INSERT INTO schema_migrations (version) VALUES ('20131113125956');

INSERT INTO schema_migrations (version) VALUES ('20131113130604');

INSERT INTO schema_migrations (version) VALUES ('20131113130730');

INSERT INTO schema_migrations (version) VALUES ('20131120091639');

INSERT INTO schema_migrations (version) VALUES ('20131120110429');

INSERT INTO schema_migrations (version) VALUES ('20131120131814');

INSERT INTO schema_migrations (version) VALUES ('20131121090849');

INSERT INTO schema_migrations (version) VALUES ('20131121103330');

INSERT INTO schema_migrations (version) VALUES ('20131121111800');

INSERT INTO schema_migrations (version) VALUES ('20131122113715');

INSERT INTO schema_migrations (version) VALUES ('20131122134053');

INSERT INTO schema_migrations (version) VALUES ('20131122134131');

INSERT INTO schema_migrations (version) VALUES ('20131122134721');

INSERT INTO schema_migrations (version) VALUES ('20131125100031');

INSERT INTO schema_migrations (version) VALUES ('20131125123629');

INSERT INTO schema_migrations (version) VALUES ('20131125125120');

INSERT INTO schema_migrations (version) VALUES ('20131125145203');

INSERT INTO schema_migrations (version) VALUES ('20131125145656');

INSERT INTO schema_migrations (version) VALUES ('20131126114517');

INSERT INTO schema_migrations (version) VALUES ('20131127093907');

INSERT INTO schema_migrations (version) VALUES ('20131127094932');

INSERT INTO schema_migrations (version) VALUES ('20131127103407');

INSERT INTO schema_migrations (version) VALUES ('20131127145933');

INSERT INTO schema_migrations (version) VALUES ('20131127151542');

INSERT INTO schema_migrations (version) VALUES ('20131128131331');

INSERT INTO schema_migrations (version) VALUES ('20131129143529');

INSERT INTO schema_migrations (version) VALUES ('20131202102840');

INSERT INTO schema_migrations (version) VALUES ('20131202104916');

INSERT INTO schema_migrations (version) VALUES ('20131202105617');

INSERT INTO schema_migrations (version) VALUES ('20131202105946');

INSERT INTO schema_migrations (version) VALUES ('20131205102959');

INSERT INTO schema_migrations (version) VALUES ('20131205122540');

INSERT INTO schema_migrations (version) VALUES ('20131209085450');

INSERT INTO schema_migrations (version) VALUES ('20131209085457');

INSERT INTO schema_migrations (version) VALUES ('20131209085509');

INSERT INTO schema_migrations (version) VALUES ('20131209151806');

INSERT INTO schema_migrations (version) VALUES ('20131220105858');

INSERT INTO schema_migrations (version) VALUES ('20140106132415');

INSERT INTO schema_migrations (version) VALUES ('20140106143343');

INSERT INTO schema_migrations (version) VALUES ('20140113104703');

INSERT INTO schema_migrations (version) VALUES ('20140113111720');

INSERT INTO schema_migrations (version) VALUES ('20140113133522');

INSERT INTO schema_migrations (version) VALUES ('20140114100615');

INSERT INTO schema_migrations (version) VALUES ('20140115094325');

INSERT INTO schema_migrations (version) VALUES ('20140115094915');

INSERT INTO schema_migrations (version) VALUES ('20140115102355');

INSERT INTO schema_migrations (version) VALUES ('20140115153206');

INSERT INTO schema_migrations (version) VALUES ('20140116104402');

INSERT INTO schema_migrations (version) VALUES ('20140116154103');

INSERT INTO schema_migrations (version) VALUES ('20140117102543');

INSERT INTO schema_migrations (version) VALUES ('20140120101040');

INSERT INTO schema_migrations (version) VALUES ('20140120162648');

INSERT INTO schema_migrations (version) VALUES ('20140120163602');

INSERT INTO schema_migrations (version) VALUES ('20140121124954');

INSERT INTO schema_migrations (version) VALUES ('20140121152434');

INSERT INTO schema_migrations (version) VALUES ('20140123151731');

INSERT INTO schema_migrations (version) VALUES ('20140124104323');

INSERT INTO schema_migrations (version) VALUES ('20140124132400');

INSERT INTO schema_migrations (version) VALUES ('20140127102531');

INSERT INTO schema_migrations (version) VALUES ('20140128154540');

INSERT INTO schema_migrations (version) VALUES ('20140129100320');

INSERT INTO schema_migrations (version) VALUES ('20140203095427');

INSERT INTO schema_migrations (version) VALUES ('20140203102236');

INSERT INTO schema_migrations (version) VALUES ('20140203154821');

INSERT INTO schema_migrations (version) VALUES ('20140204152559');

INSERT INTO schema_migrations (version) VALUES ('20140205110527');

INSERT INTO schema_migrations (version) VALUES ('20140207131521');

INSERT INTO schema_migrations (version) VALUES ('20140207140953');

INSERT INTO schema_migrations (version) VALUES ('20140210162518');

INSERT INTO schema_migrations (version) VALUES ('20140213133833');

INSERT INTO schema_migrations (version) VALUES ('20140225150816');

INSERT INTO schema_migrations (version) VALUES ('20140228094452');

INSERT INTO schema_migrations (version) VALUES ('20140228141431');

INSERT INTO schema_migrations (version) VALUES ('20140303134143');

INSERT INTO schema_migrations (version) VALUES ('20140304130211');

INSERT INTO schema_migrations (version) VALUES ('20140304160434');

INSERT INTO schema_migrations (version) VALUES ('20140305111149');

INSERT INTO schema_migrations (version) VALUES ('20140305142219');

INSERT INTO schema_migrations (version) VALUES ('20140306092704');

INSERT INTO schema_migrations (version) VALUES ('20140307140630');

INSERT INTO schema_migrations (version) VALUES ('20140314111035');

INSERT INTO schema_migrations (version) VALUES ('20140314114538');

INSERT INTO schema_migrations (version) VALUES ('20140314131958');

INSERT INTO schema_migrations (version) VALUES ('20140314150628');

INSERT INTO schema_migrations (version) VALUES ('20140317091545');

INSERT INTO schema_migrations (version) VALUES ('20140317093721');

INSERT INTO schema_migrations (version) VALUES ('20140318165154');

INSERT INTO schema_migrations (version) VALUES ('20140318165308');

INSERT INTO schema_migrations (version) VALUES ('20140319132604');

INSERT INTO schema_migrations (version) VALUES ('20140320143735');

INSERT INTO schema_migrations (version) VALUES ('20140320143736');

INSERT INTO schema_migrations (version) VALUES ('20140320172440');

INSERT INTO schema_migrations (version) VALUES ('20140321150326');

INSERT INTO schema_migrations (version) VALUES ('20140321150344');

INSERT INTO schema_migrations (version) VALUES ('20140321150357');

INSERT INTO schema_migrations (version) VALUES ('20140321150422');

INSERT INTO schema_migrations (version) VALUES ('20140321150439');

INSERT INTO schema_migrations (version) VALUES ('20140325091358');

INSERT INTO schema_migrations (version) VALUES ('20140331081800');

INSERT INTO schema_migrations (version) VALUES ('20140401124538');

INSERT INTO schema_migrations (version) VALUES ('20140402102146');

INSERT INTO schema_migrations (version) VALUES ('20140402125508');

INSERT INTO schema_migrations (version) VALUES ('20140402144444');

INSERT INTO schema_migrations (version) VALUES ('20140403105402');

INSERT INTO schema_migrations (version) VALUES ('20140403105654');

INSERT INTO schema_migrations (version) VALUES ('20140403114254');

INSERT INTO schema_migrations (version) VALUES ('20140403120948');

INSERT INTO schema_migrations (version) VALUES ('20140410103518');

INSERT INTO schema_migrations (version) VALUES ('20140410125448');

INSERT INTO schema_migrations (version) VALUES ('20140410132849');

INSERT INTO schema_migrations (version) VALUES ('20140410145259');

INSERT INTO schema_migrations (version) VALUES ('20140411142256');

INSERT INTO schema_migrations (version) VALUES ('20140423153838');

INSERT INTO schema_migrations (version) VALUES ('20140509085025');

INSERT INTO schema_migrations (version) VALUES ('20140522102024');

INSERT INTO schema_migrations (version) VALUES ('20140523162552');

INSERT INTO schema_migrations (version) VALUES ('20140530134749');

INSERT INTO schema_migrations (version) VALUES ('20140530151819');

INSERT INTO schema_migrations (version) VALUES ('20140602095718');

INSERT INTO schema_migrations (version) VALUES ('20140603110004');

INSERT INTO schema_migrations (version) VALUES ('20140604083349');

INSERT INTO schema_migrations (version) VALUES ('20140604093929');

INSERT INTO schema_migrations (version) VALUES ('20140604095256');

INSERT INTO schema_migrations (version) VALUES ('20140604122350');

INSERT INTO schema_migrations (version) VALUES ('20140604124758');

INSERT INTO schema_migrations (version) VALUES ('20140605110233');

INSERT INTO schema_migrations (version) VALUES ('20140605122317');

INSERT INTO schema_migrations (version) VALUES ('20140617101519');

INSERT INTO schema_migrations (version) VALUES ('20140623092855');

INSERT INTO schema_migrations (version) VALUES ('20140626153226');

INSERT INTO schema_migrations (version) VALUES ('20140627085856');

INSERT INTO schema_migrations (version) VALUES ('20140630081056');

INSERT INTO schema_migrations (version) VALUES ('20140703143004');

INSERT INTO schema_migrations (version) VALUES ('20140707152310');

INSERT INTO schema_migrations (version) VALUES ('20140716115532');

INSERT INTO schema_migrations (version) VALUES ('20140723104013');

INSERT INTO schema_migrations (version) VALUES ('20140905105611');

INSERT INTO schema_migrations (version) VALUES ('20140911101238');

INSERT INTO schema_migrations (version) VALUES ('20140911103541');

INSERT INTO schema_migrations (version) VALUES ('20140911105512');

INSERT INTO schema_migrations (version) VALUES ('20140911111415');

INSERT INTO schema_migrations (version) VALUES ('20140911112325');

INSERT INTO schema_migrations (version) VALUES ('20140923101422');

INSERT INTO schema_migrations (version) VALUES ('20140924125028');

INSERT INTO schema_migrations (version) VALUES ('20140924143638');

INSERT INTO schema_migrations (version) VALUES ('20140926075426');

INSERT INTO schema_migrations (version) VALUES ('20141013101645');

INSERT INTO schema_migrations (version) VALUES ('20141014121651');

INSERT INTO schema_migrations (version) VALUES ('20141027140152');

INSERT INTO schema_migrations (version) VALUES ('20141028142645');

INSERT INTO schema_migrations (version) VALUES ('20141029143713');

INSERT INTO schema_migrations (version) VALUES ('20141105090749');

INSERT INTO schema_migrations (version) VALUES ('20141110113234');

INSERT INTO schema_migrations (version) VALUES ('20141110153719');

INSERT INTO schema_migrations (version) VALUES ('20141202091807');

INSERT INTO schema_migrations (version) VALUES ('20141218161748');

INSERT INTO schema_migrations (version) VALUES ('20150115102408');

INSERT INTO schema_migrations (version) VALUES ('20150122145210');

INSERT INTO schema_migrations (version) VALUES ('20150127092302');

INSERT INTO schema_migrations (version) VALUES ('20150203143207');

INSERT INTO schema_migrations (version) VALUES ('20150216103921');

INSERT INTO schema_migrations (version) VALUES ('20150223122904');

INSERT INTO schema_migrations (version) VALUES ('20150227080359');

INSERT INTO schema_migrations (version) VALUES ('20150317144145');

INSERT INTO schema_migrations (version) VALUES ('20150420100455');

INSERT INTO schema_migrations (version) VALUES ('20150422100934');

INSERT INTO schema_migrations (version) VALUES ('20150427104057');

INSERT INTO schema_migrations (version) VALUES ('20150428093851');

INSERT INTO schema_migrations (version) VALUES ('20150528075816');

INSERT INTO schema_migrations (version) VALUES ('20150617142554');

INSERT INTO schema_migrations (version) VALUES ('20150625100330');

INSERT INTO schema_migrations (version) VALUES ('20150715124039');

INSERT INTO schema_migrations (version) VALUES ('20150724145842');

INSERT INTO schema_migrations (version) VALUES ('20150728113405');

INSERT INTO schema_migrations (version) VALUES ('20150810073602');

INSERT INTO schema_migrations (version) VALUES ('20150810131110');

INSERT INTO schema_migrations (version) VALUES ('20150826082248');

INSERT INTO schema_migrations (version) VALUES ('20151027095627');

INSERT INTO schema_migrations (version) VALUES ('20151029175956');

INSERT INTO schema_migrations (version) VALUES ('20151029180225');

INSERT INTO schema_migrations (version) VALUES ('20151112093719');

INSERT INTO schema_migrations (version) VALUES ('20151112101919');

INSERT INTO schema_migrations (version) VALUES ('20151125090705');

INSERT INTO schema_migrations (version) VALUES ('20151201120736');

INSERT INTO schema_migrations (version) VALUES ('20151204114710');

INSERT INTO schema_migrations (version) VALUES ('20151208102910');

INSERT INTO schema_migrations (version) VALUES ('20151209121947');

INSERT INTO schema_migrations (version) VALUES ('20151210103716');

INSERT INTO schema_migrations (version) VALUES ('20151210123518');

INSERT INTO schema_migrations (version) VALUES ('20151211100552');

INSERT INTO schema_migrations (version) VALUES ('20151216142413');

INSERT INTO schema_migrations (version) VALUES ('20151218141432');

INSERT INTO schema_migrations (version) VALUES ('20160106102831');

INSERT INTO schema_migrations (version) VALUES ('20160107095848');

INSERT INTO schema_migrations (version) VALUES ('20160127162328');

INSERT INTO schema_migrations (version) VALUES ('20160304100128');
