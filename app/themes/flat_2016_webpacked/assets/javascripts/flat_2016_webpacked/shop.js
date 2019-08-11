import plugins_ready from './plugins';

function handle_shop(){

  $.fn.welcome_text = function() {
    const $this = $(this);

    $this.find('.show-details').on('click', function(e){
      e.preventDefault();
      if ($(this).siblings('.text-truncated').is(':visible')){
        $(this).siblings('.text-truncated').addClass('hidden');
        $(this).siblings('.text-full').removeClass('hidden');
        $(this).text($(this).data('less-text'));
      } else {
        $(this).siblings('.text-full').addClass('hidden');
        $(this).siblings('.text-truncated').removeClass('hidden');
        $(this).text($(this).data('more-text'));
      }
    })
  };

  function block_votes() {
    $('.star-rating .list-inline.list-unstyled').hide();
    $('.star-rating').prepend("<div class='loader'></div>");
  }

  $.fn.card_shop_filter = function(options, callback) {
    const $this    = $(this);
    let settings = {minItems: 11};
    let request  = null;

    if (options) { $.extend(settings, options); }

    if ($this.length) {
      let checkbox = $this.find('> li > .checkbox input[type="checkbox"]');

      checkbox.on('change', function() {
        let shopIds     = [];
        const queryText   = $.getUrlVar('query');
        let $list = $('.card-coupons-list > .card-content > ul');

        history.replaceState(null, null, window.location.href.replace(/page=[0-9]&?/, ''));


        checkbox.filter(':checked').each(function() {
          if ($(this).parents('li').attr('data-shop-id')) {
            shopIds.push($(this).parents('li').data('shop-id'));
          }
        });

        $list.not(':first').remove();
        $list.find('li').remove();
        $('.pagination-wrapper').html('');

        if (!$('div.loader').length) {
          $list.before('<div class="loader" />').fadeIn();
        }

        request = $.ajax({
          method: 'get',
          url: window.location.origin + window.location.pathname,
          data: {query: queryText, shop_id: shopIds},
          beforeSend: function(xhr){
            if (request !== null){
              request.abort();
            }
          },
          complete: function(jqXHR, status){
            request = null;
          },
          success: function(data) {
            $('div.loader').remove();
            $('.card-coupons-list > .card-content > ul').replaceWith($('.card-coupons-list > .card-content > ul', data));
            $('.pagination-wrapper').html($('.card-coupons-list > .card-content > ul', data).data('pagination'));
            $('ul.pagination > li > a').each(function() {
              if ($(this).attr('href') !== '#') {
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
}

$(document).ready(handle_shop);
