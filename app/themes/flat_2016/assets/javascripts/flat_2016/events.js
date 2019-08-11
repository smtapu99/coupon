var load_coupon_modal = function(){

  // window.location.hash.substring(1)[0] == h if seo_text_anchor_links are used
  if (window.location.hash.length && window.location.hash.split("-")[0] === '#id') {
    var couponId = window.location.hash.split("-")[1];
    var card_coupons_list_content = $('.card.card-coupons-list.pannacotta .card-content');
    var active_coupon = card_coupons_list_content.find('> ul > li[data-coupon-id="' + couponId + '"]');

    $('body').get_coupon_modal({coupon_id: parseInt(couponId)});

    if ($(active_coupon).length){
      active_coupon.addClass('active');

      $('html, body').animate({
        scrollTop: active_coupon.offset().top - 30
      }, 300);
    }
  }
};

var trigger_user_events = function(){
  load_coupon_modal();
};

jQuery(document).on('tracking_user_set', trigger_user_events);
