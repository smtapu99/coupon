var pad = function(str, max) {
  str = str.toString();

  return str.length < max ? pad('0' + str, max) : str;
};

var getUrlParameter = function(sParam) {
  var sPageURL = window.location.search.substring(1);
  var sURLVariables = sPageURL.split('&');

  for (var i = 0; i < sURLVariables.length; i++) {
    var sParameterName = sURLVariables[i].split('=');

    if (sParameterName[0] == sParam) {
      return sParameterName[1];
    }
  }
};

var decodeEntities = (function() {
  // this prevents any overhead from creating the object each time
  var element = document.createElement('div');

  function decodeHTMLEntities(str) {
    if (str && typeof str === 'string') {
      // strip script/html tags
      str = str.replace(/<script[^>]*>([\S\s]*?)<\/script>/gmi, '');
      str = str.replace(/<\/?\w(?:[^"'>]|"[^"]*"|'[^']*')*>/gmi, '');
      element.innerHTML = str;
      str = element.textContent;
      element.textContent = '';
    }

    return str;
  }

  return decodeHTMLEntities;
})();

$.fn.countdown = function(options, callback) {
  var $this = $(this); // Custom 'this' selector
  var settings = {'date': null, 'format': 'on', 'id': null};

  if (options) {
    $.extend(settings, options);
  }

  function countdownProcessor() {

    var expirationDate = Date.parse(settings.date);
    expirationDate = expirationDate / 1000;
    var currentDate = Math.floor($.now() / 1000);

    if (currentDate > expirationDate) {
      if (typeof callback != 'undefined') {
        callback.call(this); //!!!!!!! this caused errors
      }

      if (typeof interval != 'undefined') {
        clearInterval(interval);
      }
    }

    var seconds = expirationDate - currentDate;
    var days = Math.floor(seconds / (60 * 60 * 24)); // Calculate the number of days

    seconds -= days * 60 * 60 * 24; // Update the seconds variable with number of days removed

    var hours = Math.floor(seconds / (60 * 60));

    seconds -= hours * 60 * 60; // Update the seconds variable with number of hours removed

    var minutes = Math.floor(seconds / 60);

    seconds -= minutes * 60; // Update the seconds variable with number of minutes removed

    if (settings.format == 'on') {
      hours = pad(hours, 2);
      minutes = pad(minutes, 2);
      seconds = pad(seconds, 2);
    }

    if (!isNaN(hours) && !isNaN(minutes) && !isNaN(seconds)) {
      $('.end_date_countdown').fadeIn();

      // Update the countdown's html values
      $this.find('.days').text(days);
      $this.find('.hours').text(hours);
      $this.find('.minutes').text(minutes, 2);
      $this.find('.seconds').text(seconds, 2);
    }
  }

  var interval = setInterval(countdownProcessor, 1000); // Loop the function
};


var init_coupon_list = function() {
  var coupon_li = $('.card-coupons-list li.item');

  if ($(coupon_li).length) {

    $(coupon_li).on('click', '.coupon-share', function(e) {
      e.stopPropagation();

      var my_modal = $('#my-modal.modal');
      $.ajax({
        method: 'get',
        url: $(this).data('href'),
        complete: function(data) {
          my_modal.find('.modal-content').html(data.responseText);
          my_modal.modal();

          dataLayer.push({
            'event': 'share-button/' + $(this).parents('li').data('coupon-id'),
            'eventAction': 'click',
            'eventLabel': 'null',
            'eventValue': '0'
          });
        }
      });
    })
      .on('click', '.coupon-like', function(e) {
        e.stopPropagation();
        $(this).unbind('click');
        var ele = $(this).find('span');
        var settings = {
          coupon_id: ele.parents('li.item').data('coupon-id'),
          text_active: ele.data('active'),
          text_inactive: ele.data('inactive')
        };
        var action_url = (ele.hasClass('active')) ? 'unsave' : 'save';
        var bookmark_bubble = $('a.bookmark-count.pannacotta');
        var bookmark_count = bookmark_bubble.find('> span');

        $.ajax({
          method: 'post',
          url: root_dir + '/bookmarks/' + action_url,
          data: {id: settings.coupon_id},
          success: function(data) {
            ele.toggleClass('active');
          },
          complete: function() {
            if (ele.hasClass('active')) {
              ele.html('<i class="fa fa-heart"></i>');
              ele.prop('title', settings.text_inactive);
            } else {
              ele.html('<i class="fa fa-heart-o"></i>');
              ele.prop('title', settings.text_active);
            }
            get_bookmarked_coupons_count();

            _push('event', {
              ec: 'Bookmark',
              ea: action_url,
              el: settings.coupon_id
            });
          }
        });
      })
      .on('click', '.coupon-description .show-coupon-details', function(e) {
        e.stopPropagation();
        coupon_add_read_more(this)
      });
  }
}

var coupon_add_read_more = function(ele) {
  var div_desciption = $(ele).parent('.coupon-description');
  if (div_desciption.find('.text-truncated').is(':visible')) {
    div_desciption.find('.text-truncated').addClass('hidden');
    div_desciption.find('.text-full').removeClass('hidden');
    $(ele).html('').append('<i class="fa fa-caret-square-o-up"></i> <span>' + $(ele).data('less-text') + '</span>');
  } else {
    div_desciption.find('.text-full').addClass('hidden');
    div_desciption.find('.text-truncated').removeClass('hidden');
    $(ele).html('').append('<i class="fa fa-caret-square-o-down"></i> <span>' + $(ele).data('more-text') + '</span>');
  }
}

/**
 * Get the ID of the bookmarked Coupon(s)
 *
 * @param  {string} cookie_name
 * @return {description}
 */
var get_bookmarked_coupons_id = function(cookie_name) {
  try {
    var the_cookie = Cookies.get(cookie_name);

    if (the_cookie !== null && typeof the_cookie === 'string') {
      return the_cookie.split(',');
    }
  } catch (e) {
  }

  return [];
};

var get_bookmarked_coupons_count = function() {
  var bookmark_bubble = $('a.bookmark-count.pannacotta');
  var bookmark_count = bookmark_bubble.find('> span');

  $.ajax({
    method: 'post',
    url: root_dir + '/bookmarks/active_bookmarks_count',
    success: function(data) {
      bookmark_count.html(parseInt(data));
    }
  });
};

/**
 * Loads the bookmarked coupon(s)
 *
 * @param  {object} options
 * @return {nil}
 */
$.fn.load_bookmarked_coupon = function(options) {
  var $this = $(this);
  var settings = {
    cookie_name: 'saved_coupons'
  };

  if (options) {
    $.extend(settings, options);
  }

  if ($this.length) {
    var init_coupon_ids = get_bookmarked_coupons_id(settings.cookie_name);

    if (init_coupon_ids.length >= 1) {
      var bookmark_bubble = $('a.bookmark-count.pannacotta');
      var bookmark_count = bookmark_bubble.find('> span');

      bookmark_bubble.removeClass('hidden').addClass('active');
      bookmark_count.text(parseInt(init_coupon_ids.length));

      $(init_coupon_ids).each(function(index, id) {
        $('.card.card-coupons-list.pannacotta li[data-coupon-id="' + id + '"]').each(function() {
          $(this).find('.btn-coupon-bookmark').addClass('active');
        });
      });
    }
  }
};

/**
 * Bookmarks coupon(s)
 *
 * @param  {object} options
 * @return {nil}
 */
$.fn.bookmark_coupon = function(options) {
  var $this = $(this);
  var settings = {
    coupon_id: $this.parents('li.item').data('coupon-id'),
    text_active: $this.data('active'),
    text_inactive: $this.data('inactive')
  };

  if (options) {
    $.extend(settings, options);
  }

  if ($this.length) {

    if ($this.hasClass('active')) {
      $this.html('<i class="fa fa-heart"></i>');
      $this.prop('title', settings.text_inactive);
      // $this.html('<span>' + settings.text_inactive + '</span><i class="roberto roberto-remove"></i>');
    } else {
      $this.html('<i class="fa fa-heart-o"></i>');
      $this.prop('title', settings.text_active);
      // $this.html('<span>' + settings.text_active + '</span><i class="roberto roberto-bookmark"></i>');
    }

    $this.removeClass('hidden');

  }
};

/*** END CARD COUPONS LIST RELATED ***/

// var init_coupon_share = function(){
//   $(document).on('click', '.card-coupons-list .coupon-share', function(){
//     var my_modal = $('#my-modal.modal');
//     $.ajax({
//       method: 'get',
//       url: $(this).data('href'),
//       complete: function(data) {
//         my_modal.find('.modal-content').html(data.responseText);
//         my_modal.modal();

//         dataLayer.push({
//           'event': 'share-button/' + $(this).parents('li').data('coupon-id'),
//           'eventAction': 'click',
//           'eventLabel': 'null',
//           'eventValue': '0'
//         });
//       }
//     });
//   });
// };

$.fn.get_coupon_modal = function(options, callback) {
  var $this = $(this);
  var settings = {coupon_id: null};

  if (options) {
    $.extend(settings, options);
  }

  if ($this.length) {
    var my_modal = $('#my-modal.modal');

    $.ajax({
      url: root_dir + '/modals/coupon_clickout',
      type: 'get',
      data: {id: settings.coupon_id},
      success: function(data) {
        my_modal.find('.modal-content').html(data);
        init_element_tracking(my_modal);
        my_modal.on('click', '.coupon-description .show-coupon-details', function(e) {
          coupon_add_read_more(this)
        });
      }
    });

    // this event is set in case the help link is clicked on the clickout modal
    // so if the help widget is closed the clickout modal comes back
    // but if this is closed it should not show up again
    my_modal.unbind('hidden.bs.modal.clickout');

    my_modal.modal();
  }
};

var onload_help_modal = function(modal_id) {

  var my_modal = $(modal_id);

  $.ajax({
    url: root_dir + '/modals/help',
    type: 'get',
    data: {shop_scope: shopScope},
    success: function(data) {
      var the_content = my_modal.find('.modal-content');
      the_content.html(data).find('ul').addClass('list-unstyled').find('> li').prepend('<span class="list-circle"></span>');
    }
  });

  my_modal.modal();
};

var init_get_help_modal = function(options, callback) {
  var modal_selector = '[data-modal="help"]';
  var $this = $(modal_selector);
  var settings = {modal_id: '#my-modal.modal'};

  if (options) {
    $.extend(settings, options);
  }

  if ($this.length) {
    $(document).on('click', modal_selector, function(e) {
      e.preventDefault();

      var my_modal = $(settings.modal_id);
      $.ajax({
        url: root_dir + '/modals/help',
        type: 'get',
        data: {shop_scope: shopScope},
        success: function(data) {
          var the_content = my_modal.find('.modal-content');
          the_content.html(data).find('ul').addClass('list-unstyled').find('> li').prepend('<span class="list-circle"></span>');
        }
      });

      my_modal.modal();
    });
  }
};

var init_newsletter_subscribe_modal = function(options, callback) {
  var settings = {modal_id: '#my-modal.modal'};

  if (options) {
    $.extend(settings, options);
  }

  $(document).on('click', '.attach-newsletter-popup.pannacotta', function(e) {
    e.preventDefault();

    var my_modal = $(settings.modal_id);
    my_modal.find('.modal-content').html('');

    $.ajax({
      url: root_dir + '/modals/newsletter_subscribe',
      type: 'get',
      data: {type: 'no-inputfield'},
      success: function(data) {
        my_modal.find('.modal-content').html(data);
        if ($(dataLayer).length) {
          add_event_category(my_modal.find('form'), 'popup_box-nl-no-field');
        }
        $('.show-newsletter-details').off().on('click', function(e) {
          newsletter_add_read_more(this);
        })
      }
    });

    my_modal.modal();
  });
};

$.fn.add_coupon_vote = function(options, callback) {
  var $this = $(this);
  var settings = {type: 'positive', css_class: 'active', disabled_after: true};

  if (options) {
    $.extend(settings, options);
  }

  if ($this.length) {
    $this.on('click', function(e) {
      e.preventDefault();

      $.ajax({
        url: root_dir + '/coupons/vote',
        data: {id: $this.data('id'), type: settings.type},
        type: 'get',
        // dataType: 'script',
        success: function() {
          $this.addClass(settings.css_class);
        }
      });

      if (settings.disabled_after === true) {
        $('#my-modal.modal .list-voting .btn').attr('disabled', true);
      }
    });
  }
};

// smooth scrolling on anchor link click
$(document).on('click', 'a[href^="#"]:not([href="#"])', function(event) {
  event.preventDefault();
  if($($(this).attr('href')).length){
    $('html, body').animate({
      scrollTop: $($(this).attr('href')).offset().top - 20
    }, 500);
  }
});


var plugins_ready = function() {
  if (window.location.hash.substring(1) == 'help') {
    onload_help_modal('#my-modal.modal');
  }

  init_coupon_list();
  init_get_help_modal();
  init_newsletter_subscribe_modal();

};

jQuery(document).ready(plugins_ready);

$(document).ready(function() {
  $('.show-newsletter-details').off().on('click', function(e) {
    newsletter_add_read_more(this);
  })
})

var newsletter_add_read_more = function(ele) {
  let newsletter_container= $(ele).parent();
  if (newsletter_container.find('.text-truncated').is(':visible')) {
    newsletter_container.find('.text-truncated').addClass('hidden');
    newsletter_container.find('.text-full').removeClass('hidden');
    $(ele).html($(ele).data('less-text'));
  } else {
    newsletter_container.find('.text-full').addClass('hidden');
    newsletter_container.find('.text-truncated').removeClass('hidden');
    $(ele).html($(ele).data('more-text'));
  }
}
