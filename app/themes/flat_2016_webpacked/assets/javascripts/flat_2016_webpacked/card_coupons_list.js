import Utilities from './utilities';
import isMobile from './isMobile';

$.fn.coupon_expires_in = function() {
  const $this = $(this);
  let expiration_date = Date.parse($this.data('time'));
  let currentDate = $.now();
  let end_tomorrow = new Date(new Date().getTime() + 24 * 60 * 60 * 1000).setHours(23, 59, 59, 999);
  let end_2_days = new Date(end_tomorrow + 24 * 60 * 60 * 1000).setHours(23, 59, 59, 999);
  let end_3_days = new Date(end_2_days + 24 * 60 * 60 * 1000).setHours(23, 59, 59, 999);
  let hourdiff = (expiration_date - currentDate) / 60 / 60 / 1000;

  if (hourdiff < 24) {
    $this.countdown({
      date: $this.data('time'),
      format: 'on'
    });
    $(this).removeClass('hidden');
  } else if (expiration_date <= end_tomorrow) {
    $(this).html('<i class="color-ready fa fa-clock-o"></i> ' + $this.data('expires-tomorrow'));
    $(this).removeClass('hidden');
  } else if (expiration_date <= end_2_days) {
    $(this).html('<i class="color-ready fa fa-clock-o"></i> ' + $this.data('expires-in-x-days').replace('{x}', 2));
    $(this).removeClass('hidden');
  } else if (expiration_date <= end_3_days) {
    $(this).html('<i class="color-ready fa fa-clock-o"></i> ' + $this.data('expires-in-x-days').replace('{x}', 3));
    $(this).removeClass('hidden');
  }
};

let append_newsletter_signup = function() {
  let selector = '.card-coupons.pannacotta .form-inline, .campaigns.show .widget-newsletter form';
  let form = $(selector);

  $(document).on('submit', selector, function(e) {
    e.preventDefault();

    $.ajax({
      method: 'post',
      dataType: 'script',
      data: $(form).serialize(),
      url: $(form).attr('action')
    });
  });
};

let init_shop_coupon_filters = function(options, callback) {
  let this_id = '.pannacotta .card-coupon-filter';
  let $this = $(this_id);
  let list = $('.pannacotta.card-coupons');
  let settings = {};

  if (options) { $.extend(settings, options); }

  function hide_all_unmatched_filters() {
    let ary = [];
    let filter_ids = [];

    list.find('li.item[data-visible=true]').each(function() {
      jQuery.merge(ary, $(this).data('filter-ids').split(' '));
    });

    ary = jQuery.unique(
      ary.filter(function (el) {
        return el != null && el != '';
      })
    );

    $this.find('.dropdown-menu input[type="checkbox"]:checked').each(function() {
      filter_ids.push($(this).val());
    });

    if($(ary).length > 0) {
      $this.find('label').hide();
      $this.find('.' + ary.join(',.')).show();
    } else if ($(filter_ids).length == 0) {
      $this.find('label').show();
    }

    filter_ids.forEach(function(id) {
      $('.' + id).show();
    });
  }

  function checked_filter_ids() {
    return $this.find('.dropdown-menu input[type="checkbox"]:checked').map(function() { return $(this).val(); });
  }

  function disable_dropdown_close() {
    $(document).on('click', this_id + ' .dropdown-menu', function(e) {
      e.stopPropagation();
    });
  }

  function show_coupons_and_reset_pagination(page_size, initial_size) {
    initial_size = initial_size || 12;
    page_size = page_size || 8;

    list.find('li.item[data-visible=false]').hide();
    list.find('li.item[data-visible=true]').show();
    list.find('li.item[data-visible=true]:gt(' + (initial_size-1) + ')').hide();

    hide_all_unmatched_filters();
    init_grid_show_more();
  }

  if ($this.length) {
    let coupon_matcher = '.pannacotta.card-coupons .item';

    disable_dropdown_close();

    $(document).on('click', this_id + ' input[type="checkbox"]', function() {
      let filter_ids = checked_filter_ids();
      let coupon_length = 0;
      let offer_length = 0;
      let coupon_type = $('.card-coupon-filter > ul:visible .active[data-filter-type]').data('filter-type');

      $this.find('.dropdown-toggle.active').parents('.btn-group').not($(this).parents('.btn-group')).find('input:checkbox').removeAttr('checked');
      $this.find('.dropdown-toggle').removeClass('active');
      $(this).parents('.btn-group').find('.dropdown-toggle').addClass('active');

      // if at least one filter id is present
      if ($(filter_ids).length) {
        // hide all coupons
        $('.card-coupons.pannacotta .card-content > ul > li').hide();
        $('.card-coupons.pannacotta .card-content > ul > li').attr('data-visible', false);

        $(coupon_matcher).filter(function() {
          let matched = true;
          for (let i = 0, l = filter_ids.length;  i < l; i++) {
            if ($.inArray(filter_ids[i], $(this).data('filter-ids').split(' ')) == -1) {
              matched = false
            }
          }
          if (!matched) {
            return false;
          }

          // count all matching coupons/offers
          if ($(this).data('coupon-type') == 'coupon') {
            coupon_length += 1;
          } else {
            offer_length += 1;
          }

          // but return only the onse user should see
          if (coupon_type != 'all') {
            matched = $(this).data('coupon-type') == coupon_type;
            return matched;
          }

          return matched;
        }).attr('data-visible', true);

        $('.pannacotta .card-coupon-filter li[data-filter-type="coupon"] span').html(coupon_length);
        $('.pannacotta .card-coupon-filter li[data-filter-type="offer"] span').html(offer_length);

      } else {
        $(this).parents('.btn-group').find('.dropdown-toggle').removeClass('active');
        $(coupon_matcher).attr('data-visible', true);

        ['coupon', 'offer'].forEach(function(type) {
          let length = $('.pannacotta.card-coupons .item[data-coupon-type=' + type + ']').length;
          $('.pannacotta .card-coupon-filter li[data-filter-type="' + type +'"] span').html(length);
        })
      }

      show_coupons_and_reset_pagination();
    });

    // Coupon Type Filter
    $(document).on('click', this_id + ' li[data-filter-type]', function(e) {
      e.preventDefault();

      let coupon_type = $(this).data('filter-type');
      $(this).parent().find('li.active').removeClass('active');
      $(this).addClass('active');

      $('.card-coupons.pannacotta .card-content > ul > li').attr('data-visible', false);

      let filter_ids = checked_filter_ids();

      if ($(filter_ids).length) {
        $(filter_ids).each(function(index, item) {

          $(coupon_matcher).filter(function() {
            let matched = true;
            for ( let i = 0 ;  i < filter_ids.length; i++ ) {
              if($.inArray(filter_ids[i], $(this).data('filter-ids').split(' ')) == -1) {
                matched = false
              }
            }
            if (!matched) {
              return false;
            }

            // and return only the once the user should see
            if (coupon_type != 'all') {
              matched = $(this).data('coupon-type') == coupon_type;
              return matched;
            }

            return matched;
          }).attr('data-visible', true);

        });
      } else {
        if (coupon_type=='all') {
          $('.card-coupons.pannacotta .card-content > ul > li').attr('data-visible', true);
        } else {
          $('.card-coupons.pannacotta .card-content > ul > li[data-coupon-type=' + coupon_type + ']').attr('data-visible', true);
        }
      }

      show_coupons_and_reset_pagination();
    });
  }
};

let init_grid_show_more = function(options, callback) {
  const this_id = '.card-coupons-grid';
  let $this = $(this_id);
  let settings = {initial_size: 12, page_size: 8};

  if (options) {
    $.extend(settings, options);
  }

  $this.find('.show-more').unbind('click');

  $this.find('li.item[data-visible=true]:gt(' + (settings.initial_size - 1) + ')').hide();

  let size_li = $this.find("li.item[data-visible=true]").length;
  let x = settings.initial_size;

  $this.find('.show-more').hide();

  if (size_li > settings.initial_size) {
    $this.find('.show-more').show();
  }

  // $this.find('li.item:lt('+settings.page_size+')').show();
  $(document).on('click', this_id + ' .show-more', function() {
    x = (x + settings.page_size <= size_li) ? x + settings.page_size : size_li;
    $this.find('li.item[data-visible=true]:lt(' + x + ')').show();

    if (x === size_li) {
      $(this).hide();
    }
  });
};

let show_mobile_coupons = function() {
  $('.card-coupons.pannacotta .card-content > ul > li[data-is-mobile=true]').removeClass('hidden');
};

window.card_coupons_list_ready = function() {

  init_shop_coupon_filters();
  init_grid_show_more();

  if (isMobile.mobile() || isMobile.tablet()) {
    show_mobile_coupons();
    $('.card-coupon-filter .filter-mobile').removeClass('hidden');
  } else {
    $('.card-coupon-filter .filter-desktop').removeClass('hidden');
  }

  append_newsletter_signup();

  $(document).load_bookmarked_coupon();

  let $card_coupons_list_content = $('.card-coupons.pannacotta .card-content');
  $card_coupons_list_content.find('.btn-coupon-bookmark').each(function() {
    $(this).bookmark_coupon();
  });

  $('.card-coupons li.item .coupon-expires').each(function() {
    $(this).coupon_expires_in();
  });
};

jQuery(document).ready(card_coupons_list_ready);
