$(document).on('click', ".top-x-coupons #show-all", function() {
  $coupon = $(".list-coupons-as-items:nth-child(2)");
  $coupon.slideDown();
  $coupon.css({'display': 'block', 'visibility': 'visible'});
  $(".top-x-coupons #show-all").hide();
});
