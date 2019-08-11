const card_text_ready = function() {

  const card_text = $('.card.card-text.pannacotta .card-content');

  card_text.find('ul li').prepend('<i class="list-circle"></i>');

  card_text.find('> img, > p > img').addClass('img-responsive');

  card_text.find('p[style*="text-align: center"] > img').css('margin', '0 auto');

  card_text.find('iframe[src*="youtube"]').removeAttr('frameborder').addClass('embed-responsive-item').replaceWith(function() {
    return '<div class="embed-responsive embed-responsive-16by9">' + this.outerHTML + '</div>';
  });
};

$(document).ready(card_text_ready);
