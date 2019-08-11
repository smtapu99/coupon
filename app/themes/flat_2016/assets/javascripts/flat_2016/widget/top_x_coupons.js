$( document ).on('click', ".top-x-coupons #show-all", function() {
  $( ".list-coupons-as-items:nth-child(2)" ).slideDown();
  $( ".list-coupons-as-items:nth-child(2)" ).css({'display': 'block', 'visibility': 'visible' });
  $( ".top-x-coupons #show-all" ).hide();
});