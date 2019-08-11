function featured_coupons_ready() {

  let card = $('.featured-coupons.pannacotta');

  if ($(card).length) {
    card.find('span[data-time]').each(function() {
      $(this).countdown({
        date: $(this).data('time'),
        format: 'on'
      });
    });
  }
}

$(document).ready(featured_coupons_ready);
