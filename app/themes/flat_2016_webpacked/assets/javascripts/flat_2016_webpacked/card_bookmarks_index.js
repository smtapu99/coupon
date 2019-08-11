const card_bookmarks_index_ready = function() {

  const load_saved_coupons = function(){
    $.ajax({
      method: 'post',
      dataType: 'script',
      url: root_dir + '/bookmarks/saved_coupons',
      success: function() {
        card_coupons_list_ready();
        $('[data-coupon-url]').coupon_clickout();
        init_coupon_list();
      }
    });
  };

  $.fn.load_bookmarked_coupons = function(options, callback){
    const $this = $(this);
    let settings = {};

    if (options) { $.extend(settings, options); }

    if ($this.length){
      $this.html(load_saved_coupons());

      $(document).on('click', '.bookmarks .card.card-coupons-list.pannacotta .btn-coupon-bookmark', function() {
        $(this).parents('li.item').fadeOut().remove();
      });
    }
  };

  let card_bookmarks_index = $('.card.card-bookmarks-index.pannacotta');

  card_bookmarks_index.load_bookmarked_coupons();
};

$(document).ready(card_bookmarks_index_ready);
