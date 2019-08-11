function load_coupon_modal() {
  if (window.location.hash.length && window.location.hash.substring(1) !== 'help' && window.location.hash.substring(1)[0] !== 'h') {
    let card_coupons_list_content = $('.card.card-coupons-list.pannacotta .card-content');
    let active_coupon = card_coupons_list_content.find('> ul > li[data-coupon-id="' + parseInt(window.location.hash.replace('#', '')) + '"]');

    $('body').get_coupon_modal({coupon_id: parseInt(window.location.hash.replace('#', ''))});

    if ($(active_coupon).length) {
      active_coupon.addClass('active');

      $('html, body').animate({
        scrollTop: active_coupon.offset().top - 30
      }, 300);
    }
  }
}

$(document).on('tracking_user_set', load_coupon_modal);
