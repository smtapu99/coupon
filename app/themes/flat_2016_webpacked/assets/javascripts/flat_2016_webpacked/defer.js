let pc_tracking_user_id, ga_uid, geo_ip_country;

let block_votes_if_voted = function() {
  $('.star-rating.voted>ul').css('pointer-events', 'none')
    .find('.btn')
    .css('opacity', '0.6');
}

let block_and_recalculate_votes = function(star) {
  $('.star-rating .list-inline.list-unstyled').hide();
  $review_count = $('.review-count');

  let total_reviews = parseInt($review_count.data('reviewcount')) + 1;
  let total_stars = parseInt($('.star-rating').data('total-stars')) + star;
  let total_rating = (total_stars / total_reviews).toFixed(2);

  $review_count.attr('data-reviewcount', total_reviews);
  $('.rating-value').attr('data-ratingvalue', total_rating);

}

var isRedirectPage = function() {
  return $('body.coupons.clickout').length > 0
}

let setTrackingUser = function() {
  if (isRedirectPage()) { return; }

  const urlWithoutQueryString = window.location.href.split('?')[0];
  let allVars = {};

  // get tracking parameters from the query string
  //check if there are parameters on the url not from search url
  if (window.location.href.indexOf('?') !== -1 && urlWithoutQueryString.indexOf('search') === -1) {
    allVars = $.getUrlVars();
  }

  // check if we have referer AND if referer is not a cupon page!
  let referrer = document.referrer;

  if (referrer === '' || referrer === "undefined") {
    referrer = 'unknown';
  }

  allVars['referrer'] = referrer;

  if (referrer.indexOf('google') !== -1) {
    let searchValues;
    searchValues = getGoogleReferrerVars(referrer);

    if (typeof searchValues !== 'undefined') {
      for (let i = 0; i < searchValues.length; i++) {
        allVars['searchValue-' + i] = searchValues[i];
      }
    }
  }

  $.post(root_dir + '/tracking/set', {query_string_params: allVars}, function(data) {

    window.pc_tracking_user_id = data.tracking_user_id;
    $(document).trigger('tracking_user_set');
  });
};

$.fn.star_rating = function(options, callback) {

  const $this = $(this);
  const $star_rating = $('.star-rating');
  const $loaders = $('.shop-rating .loader');

  let settings = {
    css_class: 'active',
    data_shop_id: $this.data('shop-id'),
    data_star: $this.data('star'),
    data_votes: $this.data('votes')
  };

  if (options) {
    $.extend(settings, options);
  }

  if ($this.length) {

    $star_rating.find('> ul > li:lt(' + $star_rating.data('votes') + ')').addClass(settings.css_class);
    if ($('.star-rating.voted').length) {
      block_votes_if_voted();
    }

    $this.find('> ul > li').hover(function() {
      $(this).prevAll().addBack().addClass(settings.css_class);
      $(this).nextAll().removeClass(settings.css_class);
    }, function() {
      $this.find('> ul > li').removeClass(settings.css_class);
      $this.find('> ul > li:lt(' + settings.data_votes + ')').addClass(settings.css_class);
    }).find('> .btn').on('click', function(e) {
      $star_rating.hide();
      $loaders.show();
      e.preventDefault();
      $this.closest('li').removeClass(settings.css_class);
      block_and_recalculate_votes($(this).data('star'));
      $.ajax({
        url: root_dir + '/shops/vote',
        data: {id: settings.data_shop_id, stars: $(this).data('star')},
        dataType: 'script',
        success: function() {
          $this.find('li').unbind();
          $this.find('.btn').attr('disabled', true);
          $('.star-rating').show();
          $('.shop-rating .loader').hide().first().remove();
          block_votes_if_voted();
        }
      });
    });
  }
};

/* Triggers*/
// we have /static/footer and /static/header that we load in iframes on cashback.cupon.es.. those should not have any tracking or cookies
if (!$('body').hasClass('no-tracking')) {
  document.addEventListener('DOMContentLoaded', setTrackingUser);
} else {
  // also the modal should be removed in that pages
  $('.modal').remove()
}

const $star_rating = $('.star-rating');
let isLoaded = false;


function getRating() {
  if ($star_rating.data('shop-id') > 0) {
    $.ajax({
      method: 'get',
      dataType: 'script',
      url: root_dir + '/shops/render_votes',
      data: {id: $star_rating.data('shop-id')},
      success: function() {
        $('.star-rating').show().star_rating();
        $('.shop-rating .loader').hide().first().remove();
        isLoaded = true;
      }
    });
  } else {
    $star_rating.star_rating();
  }
}

if (document.hidden) {
  document.addEventListener("visibilitychange", function() {
    if (!isLoaded) {
      getRating();
    }
  });
} else {
  getRating();
}

$(document).on('tracking_user_set', function(){
  block_votes_if_voted();
});
