var featured_coupons_ready = function() {

  var card = $('.featured-coupons.pannacotta');

  if ($(card).length){
    card.find('span[data-time]').each(function() {
      $(this).countdown({
        date: $(this).data('time'),
        format: 'on'
      });
    });
  }
};

$(document).ready(featured_coupons_ready)
