var handle_shop = function() {

  $.fn.welcome_text = function() {
    var $this = $(this);

    $this.find('.show-details').on('click', function(e) {
      e.preventDefault();
      if ($(this).siblings('.text-truncated').is(':visible')) {
        $(this).siblings('.text-truncated').addClass('hidden');
        $(this).siblings('.text-full').removeClass('hidden');
        $(this).text($(this).data('less-text'));
      } else {
        $(this).siblings('.text-full').addClass('hidden');
        $(this).siblings('.text-truncated').removeClass('hidden');
        $(this).text($(this).data('more-text'));
      }
    });
  };

  function block_votes() {
    $('.star-rating .list-inline.list-unstyled').hide();
    $('.star-rating').prepend("<div class='loader'></div>");
  }

  $.fn.card_shop_filter = function(options, callback) {
    var $this = $(this);
    var settings = {minItems: 11};
    var request = null;

    if (options) {
      $.extend(settings, options);
    }
    ;

    if ($this.length) {
      var checkbox = $this.find('> li > .checkbox input[type="checkbox"]');

      checkbox.on('change', function() {
        var shopIds = [];
        var queryText = $.getUrlVar('query');

        history.replaceState(null, null, window.location.href.replace(/page=[0-9]&?/, ''));


        checkbox.filter(':checked').each(function() {
          if ($(this).parents('li').attr('data-shop-id')) {
            shopIds.push($(this).parents('li').data('shop-id'));
          }
        });

        $('.card-coupons-list > .card-content > ul').not(':first').remove();
        $('.card-coupons-list > .card-content > ul > li').remove();
        $('.pagination-wrapper').html('');

        if (!$('div.loader').length) {
          $('.card-coupons-list > .card-content > ul').before('<div class="loader" />').fadeIn();
        }

        request = $.ajax({
          method: 'get',
          url: window.location.origin + window.location.pathname,
          data: {query: queryText, shop_id: shopIds},
          beforeSend: function(xhr) {
            if (request !== null) {
              request.abort();
            }
          },
          complete: function(jqXHR, status) {
            request = null;
          },
          success: function(data) {
            $('div.loader').remove();
            $('.card-coupons-list > .card-content > ul').replaceWith($('.card-coupons-list > .card-content > ul', data));
            $('.pagination-wrapper').html($('.card-coupons-list > .card-content > ul', data).data('pagination'));
            $('ul.pagination > li > a').each(function() {
              if ($(this).attr('href') != '#') {
                $(this).attr('href', $(this).attr('href'));
              }
            });
            plugins_ready();
          }
        });
      });
    }
  };
  block_votes();
  $('#sidebar ul.filters-list').card_shop_filter();
  $('.shop-description, .pannacotta.card-shop-header .category-description, .card-shops-index.pannacotta .category-description').welcome_text();

  var filtersLength = $('.card-coupon-filter > ul:visible li').length;

  $('.summary-widget .shop-official a').on('click', function(event) {
    var has_filter = false;
    var active_coupon_filter = $('.card-coupon-filter > ul:visible .active[data-filter-type]');
    if (active_coupon_filter.length > 0 && active_coupon_filter.data('filter-type') !== 'all' && filtersLength > 1) {
      has_filter = true;
    }
    var filter_ids = getActiveFilters().map(function() { return $(this).val(); });
    if ($(filter_ids).length > 0) {
      has_filter = true;
    }

    if (has_filter) {
      event.preventDefault();
      event.stopPropagation();
      resetFilters();
      $(this).trigger('click');
    }
  });

  function resetFilters() {
    $('.card-coupon-filter > ul:visible li[data-filter-type=all]').trigger('click');
    getActiveFilters().each(function() {
      $(this).trigger('click');
    });
  }

  function getActiveFilters() {
    return $('.pannacotta .card-coupon-filter').find('.dropdown-menu input[type="checkbox"]:checked');
  }
};

jQuery(document).ready(handle_shop);
