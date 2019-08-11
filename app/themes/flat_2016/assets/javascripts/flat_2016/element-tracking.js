// eA1/eA2/eA3/eA4/eA5
// Shop page Dafiti / MB / CL /  3 / (Coupon ID added in redirect page)
// Campaign page Christmas / SB / EC/ 1 /  (Coupon ID added in redirect page)
// eA1 Type of page on our site (eg. Shop page)
// eA2 broad distinction of the place within the page (either Body, Sidebar or Header)
// eA3 Name of the specific element where the clickable link is placed / Widget Name
// eA4 Position within that widget (if applicable) / please put “null” for elements without positions (e.g. Top x Coupons widget)
// eA5 Coupon ID (added in the coupon redirect page)
// List of acronyms used in eventAction
// CL - Coupons list
// CA - Category Widget
// FU - Fallback URL
// CLW- Coupon List Widget
// CAW- Category Widget
// RCW- Related Coupons Widget
// AS - Ad Space
// SB - Sidebar
// SE - Search
// SR - Search Result
// MB - Main Body
// HD - Header
var getPositionEventString = function(e) {

  var ele = e.target; // clicked element

  var result = '';

  // get first part
  result = jQuery('body').data('tracking-data') + '/';

  // get second part
  if (jQuery(ele).parents('#sidebar').length) {
    result += 'SB/';
  } else if (jQuery(ele).parents('#header').length || jQuery(ele).parents('.shop-header-wrapper').length) {
    result += 'HD/';
  } else if (jQuery(ele).attr('name') == 'query' || jQuery(ele).parents('#search-header-results').length) {
    result += 'SE/';
  } else {
    result += 'MB/';
  }

  // get third part and fourth part
  // Coupons List on pages
  if (jQuery(ele).parents('.card-coupons-list').length) {
    result += 'CL/';
    result += jQuery(ele).closest('li.item').data('index');
  // Related Coupons Widget
  } else if (jQuery(ele).parents('.box-related-coupons').length) {
    result += 'RCW/';
    result += jQuery(ele).closest('li').data('index');
  // Top Coupons Widget
  } else if (jQuery(ele).parents('.top-x-coupons').length) {
    result += 'TCW/';
    result += jQuery(ele).closest('li').index();
  // Fallback Link
  } else if (jQuery(ele).hasClass('fallback_link')) {
    result += 'FU/';
    result += 'null/';
  // Shop Header Logo
  } else if (jQuery(ele).parents('.shop-header-logo').length) {
    result += 'SPL/';
    result += 'null/';
  // Content Text Image and Link
  } else if (jQuery(ele).parents('.card-about-this-shop').length ||
      jQuery(ele).parents('.card-about-this-category').length ||
      jQuery(ele).parents('.card-about-this-campaign').length) {

    // Image Clicks
    if (typeof jQuery(ele).attr('src') !== 'undefined' || jQuery(ele).children('img').length) {
      result += 'ICT/';
    } else {
      // Link Clicks
      result += 'CT/';
    }

    result += 'null/';
  // Coupons List Widget
  } else if (jQuery(ele).parents('.card-coupons-lists').length) {
    var lis = jQuery(ele).closest('.card-coupons-lists').find('.tab-pane li').not('.text-center');
    result += 'CLW/';
    result += lis.index(jQuery(ele).closest('li'));
  } else if (jQuery(ele).attr('name') == 'query' || jQuery(ele).parents('#search-header-results').length) {
    result += 'SR/';
    if (jQuery(ele).attr('name') == 'query') {
      // clickout with the keyboard
      result += jQuery('#search-header-results ul li.active').index();
    } else {
      // clickout with the mouse
      result += jQuery(ele).parents('li').index();
    }
  } else {
    result += 'null/';
    result += 'null';
  }

  return result;
};

var add_dataLayer_event = function(ele, type) {
  type = type || 'gtm.linkClick';

  dataLayer.push({
    event: type,
    'gtm.element': $(ele),
  });
};

var init_element_tracking = function(element) {
  // Coupon Clickout Modal
  if ($(element).has('.coupon-clickout-modal')) {
    add_event_category($(element), "popup_coupon_" + $(element).find('li[data-shop-name]').data('shop-name'));

    add_event_label($(element), $(element).find('.coupon-title').text().trim());

    add_event_action($(element).find('.the-message a'), 'shop_link');
    add_event_action($(element).find('.roberto-thumb-up').parent(), 'like_btn');
    add_event_action($(element).find('.roberto-thumb-down').parent(), 'dislike_btn');
  }
};

var get_card_title = function(element) {
  switch(true) {
      case $(element).hasClass('card-filter-by-letter'): return 'box-filter-by-letter';
      case $(element).hasClass('top-x-coupons'): return 'box-top-coupons';
      case $(element).hasClass('card-categories-index'): return 'box-categories';
      case $(element).hasClass('additional-info'): return 'box-shopinfo';
      case $(element).hasClass('card-social-media'): return 'box-social';
      case $(element).hasClass('card-shops-list'): return 'box-shops-list';
      case $(element).hasClass('card-list-coupon-type'): return 'box-filter-by-type';
      case $(element).hasClass('card-text'): return 'box-text';
      case $(element).hasClass('card-image'): return 'ad-image';
      case $(element).hasClass('card-see-more-categories'): return 'box-categories';
      case $(element).hasClass('card-newsletter'): return 'box-nl-with-field';
      default: return 'card';
  }
};

var add_event_action = function(element, string) {
  $(element).attr('data-event-action', string);
};

var add_event_label = function(element, string) {
  $(element).attr('data-event-label', string);
};

var add_event_category = function(element, string) {
  $(element).attr('data-event-category', string);
};

var set_element_tracking_data = function() {

  // logo
  add_event_action($('.site-logo a'), 'logo');

  // nav links
  $('#main-menu li a, .sub-menu a').each(function() {
    add_event_action($(this), 'tab_' + $(this).text().trim());
  });

  // featured shops
  var featured_shops = $('.featured-shops a');
  $(featured_shops).each(function(i) {
    var val = i+1 == featured_shops.length ? 'showall' : $(featured_shops).index($(this)) + '_' + $(this).data('shop-name');
    add_event_action($(this), val);
  });

  // breadcrumbs
  $('.breadcrumb a').each(function(i) {
    add_event_action($(this), (i === 0 ? 'home' : $(this).text().trim()));
  });

  // sidebar boxes category
  var sidebar_cards = $('#sidebar .card');
  sidebar_cards.each(function(i) {
    // sidebar box-nl-no-field
    if ($(this).find('[data-modal="newsletter_subscribe"]').length) {
      add_event_category($(this).closest('.card-image'), 'sidebar_0_box-nl-no-field');
    } else {
      add_event_category($(this), 'sidebar_' + sidebar_cards.index($(this)) + '_' + get_card_title($(this)));
    }
  });

  // sidebar box-top-x-coupons
  var top_x_coupons_links = $('.top-x-coupons a');
  top_x_coupons_links.each(function() {
    add_event_action($(this), top_x_coupons_links.index($(this)) + '_' + $(this).closest('li').data('shop-name'));
  });

  // sidebar box-shopinfo
  $('.additional-info a').not('.fallback_link').each(function() {
    add_event_action($(this), $(this).text().trim());
  });

  // sidebar box-shops-list
  $('.card-shops-list a').each(function() {
    add_event_action($(this), $(this).closest('li').index() +'_'+ $(this).text().trim());
  });

  // sidebar box-social
  $('.card-social-media a.btn').each(function() {
    add_event_action($(this), 'rate_' + $(this).data('star'));
  });

  // sidebar box-filter-by-letter
  $('.card-filter-by-letter a').each(function() {
    add_event_action($(this), $(this).text().trim());
  });

  // sidebar box-filter-by-type
  $('.card-list-coupon-type a').each(function() {
    add_event_action($(this), $(this).closest('li').index() + '_' + $(this).text().trim());
  });

  // sidebar box-categories
  $('.card-categories-index a').each(function() {
    add_event_action($(this), $(this).text().trim());
  });

  // sidebar box-text
  $('.card-text a').each(function() {
    add_event_action($(this), $(this).text().trim());
  });

  // sidebar box-text
  $('.card-image a').each(function() {
    add_event_action($(this), $(this).closest('.card-image').data('id') + '_' + $(this).attr('href'));
  });

  // sidebar ad-image
  $('.ad-image a').each(function() {
    if ($(this).has('img')) {
      add_event_action($(this), $(this).find('img').attr('src'));
    }
  });

  // content coupons-lists
  $('.card-coupons-lists .tab-content a').each(function(i) {
    var index = $('.card-coupons-lists .tab-content li').index($(this).closest('li'));
    add_event_action($(this), (index != -1 ? index + '_' : '') + $(this).find('span').text().trim());
  });

  // content coupons-list
  coupons_list_lis = $('.card-coupons-list li.item');
  coupons_list_lis.each(function(i) {

    add_event_category($(this), 'content_coupon_' + $(this).data('shop-name') + '_' + $(this).data('index'));
    add_event_label($(this), $(this).find(':header').text().trim());

    $(this).find('a').each(function() {
      if ($(this).find('img').length) {
        add_event_action($(this), 'img');
      } else if ($(this).hasClass('btn')) {
        add_event_action($(this), 'btn');
      } else if ($(this).hasClass('show-details')) {
        add_event_action($(this), 'coupon_details');
      } else if ($(this).parents('.list-more-details').length) {
        add_event_action($(this), 'morefromthisshop');
      } else {
        add_event_action($(this), 'link');
      }
    });
  });

  // content related_shops
  var related_shops_li = $('.related-shops li');
  $('.related-shops a').each(function() {
    add_event_action($(this), related_shops_li.index($(this).closest('li')) + '_' + $(this).closest('li').data('shop-name'));
  });

  // sidebar box-nl-with-field
  $('.card-see-more-categories a').each(function() {
    add_event_action($(this), $(this).text().trim());
  });

  // footer
  $('#footer.pannacotta a').each(function(i) {
    add_event_action($(this), $(this).text().trim());
  });

  // fallback link clickout
  $(document).on('click', '.fallback_link', function(e) {

    var page = getUrlParameter('page') || 1;

    dataLayer.push({
      'event': 'clickout',
      'eventCategory': 'Clickout - ' + $(this).data('shop'),
      'eventAction': decodeURIComponent(getPositionEventString(e)) + 'null/' + page,
      'eventLabel': 'null',
      'eventValue': '0'
    });
  });

  // content link and image clickout
  $(document).on('click', '.card-about-this-shop .card-content a, .card-about-this-shop .card-content img', function(e) {

    var page = getUrlParameter('page') || 1;

    dataLayer.push({
      'event': 'clickout',
      'eventCategory': 'Clickout - ' + jQuery('body').data('tracking-data').replace('Shop%20-%20', ''),
      'eventAction': decodeURIComponent(getPositionEventString(e)) + 'null/' + page,
      'eventLabel': 'null',
      'eventValue': '0'
    });
  });

};

jQuery(document).ready(set_element_tracking_data);
//jQuery(document).on('page:load', set_element_tracking_data);
