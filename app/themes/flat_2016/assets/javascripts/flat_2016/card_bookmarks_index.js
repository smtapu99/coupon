var card_bookmarks_index_ready = function() {

  var load_saved_coupons = function(){
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
    var $this = $(this);
    var settings = {};

    if (options) { $.extend(settings, options); }

    if ($this.length){
      $this.html(load_saved_coupons());

      $(document).on('click', '.bookmarks .card.card-coupons-list.pannacotta .btn-coupon-bookmark', function() {
        $(this).parents('li.item').fadeOut().remove();
      });
    }
  };

  var card_bookmarks_index = $('.card.card-bookmarks-index.pannacotta');
  var card_bookmarks_index_content = card_bookmarks_index.find('> .card-content');

  card_bookmarks_index.load_bookmarked_coupons();
};

jQuery(document).ready(card_bookmarks_index_ready);
