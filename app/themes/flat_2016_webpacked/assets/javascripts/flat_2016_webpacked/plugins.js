import {getPositionEventString, init_element_tracking, add_event_category} from './element-tracking';
import Utilities from './utilities';
import ClipboardJS from "clipboard"

function pad(str, max) {
  str = str.toString();

  return str.length < max ? pad('0' + str, max) : str;
}


const decodeEntities = (function() {
  // this prevents any overhead from creating the object each time
  let element = document.createElement('div');

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
  const $this = $(this);
  let settings = {'date': null, 'format': 'on', 'id': null};

  if (options) {
    $.extend(settings, options);
  }

  function countdownProcessor() {

    const expirationDate = Date.parse(settings.date) / 1000;

    const currentDate = Math.floor($.now() / 1000);

    if (currentDate > expirationDate) {
      if (typeof callback !== 'undefined') {
        callback.call(this); //!!!!!!! this caused errors
      }

      if (typeof interval !== 'undefined') {
        clearInterval(interval);
      }
    }

    let seconds = expirationDate - currentDate;
    let days = Math.floor(seconds / (60 * 60 * 24)); // Calculate the number of days

    seconds -= days * 60 * 60 * 24; // Update the seconds variable with number of days removed

    let hours = Math.floor(seconds / (60 * 60));

    seconds -= hours * 60 * 60; // Update the seconds variable with number of hours removed

    let minutes = Math.floor(seconds / 60);

    seconds -= minutes * 60; // Update the seconds variable with number of minutes removed

    if (settings.format === 'on') {
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

  let interval = setInterval(countdownProcessor, 1000); // Loop the function
};

// /*** CARD COUPONS LIST RELATED ***/
// /**
//  * Coupon clickable areas
//  *
//  * @return {boolean}    [description]
//  */
$.fn.coupon_clickout = function(options) {
  const $this = $(this);
  let settings = {
    theirs: $this.data('coupon-url'),
    ours: $this.attr('href'),
    changed_behaviour: typeof $this.attr('data-changed-behaviour') !== "undefined"
  };

  if (options) {
    $.extend(settings, options);
  }

  // Coupon Clickout
  if ($this.length) {
    $this
      .on('click', function(e) {

        settings.theirs += '?p=' + getPositionEventString(e);

        const page = Utilities.getUrlParameter('page');
        if (page !== undefined) {
          settings.theirs += '&page=' + page;
        }

        if (settings.changed_behaviour) {
          // alternative clickout
          window.open(settings.theirs);
          window.location.href = settings.ours;
          window.location.reload(true);
        } else {
          // standard clickout
          window.open(settings.ours);
          window.location.href = settings.theirs;
        }

        e.preventDefault();
      });
  }
};

window.init_coupon_list = function() {
  const coupon_li = $('.card-coupons-list li.item');

  if ($(coupon_li).length) {

    $(coupon_li).on('click', '.coupon-share', function(e) {
      e.stopPropagation();

      const my_modal = $('#my-modal.modal');
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
        const ele = $(this).find('span');
        const settings = {
          coupon_id: ele.parents('li.item').data('coupon-id'),
          text_active: ele.data('active'),
          text_inactive: ele.data('inactive')
        };
        let action_url = (ele.hasClass('active')) ? 'unsave' : 'save';

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
};

function coupon_add_read_more(el) {
  const $el = $(el);
  const div_desciption = $el.parent('.coupon-description');

  if (div_desciption.find('.text-truncated').is(':visible')) {
    div_desciption.find('.text-truncated').addClass('hidden');
    div_desciption.find('.text-full').removeClass('hidden');
    $el.html('').append('<i class="fa fa-caret-square-o-up"></i> <span>' + $el.data('less-text') + '</span>');
  } else {
    div_desciption.find('.text-full').addClass('hidden');
    div_desciption.find('.text-truncated').removeClass('hidden');
    $el.html('').append('<i class="fa fa-caret-square-o-down"></i> <span>' + $el.data('more-text') + '</span>');
  }
}

/**
 * Get the ID of the bookmarked Coupon(s)
 *
 * @param  {string} cookie_name
 * @return {Array}
 */
function get_bookmarked_coupons_id(cookie_name) {
  try {
    let the_cookie = Cookies.get(cookie_name);

    if (the_cookie !== null && typeof the_cookie === 'string') {
      return the_cookie.split(',');
    }
  } catch(e) {
  }

  return [];
}

function get_bookmarked_coupons_count() {
  const bookmark_bubble = $('a.bookmark-count.pannacotta');
  const bookmark_count = bookmark_bubble.find('> span');

  $.ajax({
    method: 'post',
    url: root_dir + '/bookmarks/active_bookmarks_count',
    success: function(data) {
      bookmark_count.html(parseInt(data));
    }
  });
}

/**
 * Loads the bookmarked coupon(s)
 *
 * @param  {object} options
 * @return {undefined}
 */
$.fn.load_bookmarked_coupon = function(options) {
  const $this = $(this);
  let settings = {
    cookie_name: 'saved_coupons'
  };

  if (options) {
    $.extend(settings, options);
  }

  if ($this.length) {
    let init_coupon_ids = get_bookmarked_coupons_id(settings.cookie_name);

    if (init_coupon_ids.length >= 1) {
      const bookmark_bubble = $('a.bookmark-count.pannacotta');
      const bookmark_count = bookmark_bubble.find('> span');

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
 * @return {undefined}
 */
$.fn.bookmark_coupon = function(options) {
  const $this = $(this);
  let settings = {
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

$.fn.get_coupon_modal = function(options, callback) {
  const $this = $(this);
  let settings = {coupon_id: null};

  if (options) {
    $.extend(settings, options);
  }

  if ($this.length) {
    const my_modal = $('#my-modal.modal');

    $.ajax({
      url: root_dir + '/modals/coupon_clickout',
      type: 'get',
      data: {id: settings.coupon_id},
      success: function(data) {
        my_modal.find('.modal-content').html(data);
        init_element_tracking(my_modal);
        coupon_clickout_ready();
        my_modal.on('click', '.coupon-description .show-coupon-details', function() {
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

function coupon_clickout_ready() {

  const $button = $('.zclip');
  const client = new ClipboardJS(".zclip", {container: document.getElementById('my-modal')});
  const modal = $('#my-modal.modal');
  let coupon_code;

  if ($button.length) {
    coupon_code = decodeURIComponent((window.atob($button.data('coupon-code'))));
  }

  const the_message = $('.modal-body p.the-message').data('message');
  const cta_wrapper = $('.card.card-coupons-list.pannacotta .card-content > ul > li.active .coupon-cta');

  $button.find('> .copied-text').hide();

  // for some reason this complete function doesnt work together with pagespeed
  $button.on('click', function() {
    $(this).find('> .copy-text').hide().addClass('hidden');
    $(this).find('> .copied-text').fadeIn().removeClass('hidden');
  });

  client.on("success", function(event) {
    // send event to GA trough Tag Manager
    if (typeof dataLayer !== 'undefined') {
      dataLayer.push({
        'event': modal.data('event-category'),
        'eventAction': 'copy_btn',
        'eventLabel': modal.data('event-label')
      })
    }
  });

  client.on('complete', function() {
    $button.find('>.copy-text').hide().addClass('hidden');
    $button.find('>.copied-text').fadeIn().removeClass('hidden');
  });

  $('#my-modal .add-positive-vote').add_coupon_vote();

  $('#my-modal .add-negative-vote').add_coupon_vote({
    type: 'negative'
  });

  cta_wrapper.html('<div class="border-ashes">');

  if ($button.length) {
    cta_wrapper.find('.border-ashes').html('<div class="bg-ashes the-code">' + coupon_code + '</div>');
  } else {
    cta_wrapper.find('.border-ashes').html('<div class="bg-ashes the-code">' + $('.modal-body > .the-code').text() + '</div>');
  }

  cta_wrapper.find('.border-ashes').append('<div class="the-message">' + the_message + '</div></div>');
}


function onload_help_modal(modal_id) {

  const $my_modal = $(modal_id);

  $.ajax({
    url: root_dir + '/modals/help',
    type: 'get',
    success: function(data) {
      const the_content = $my_modal.find('.modal-content');
      the_content.html(data).find('ul').addClass('list-unstyled').find('> li').prepend('<span class="list-circle"></span>');
    }
  });

  $my_modal.modal();
}

function init_get_help_modal(options, callback) {
  const modal_selector = '[data-modal="help"]';
  const $this = $(modal_selector);
  let settings = {modal_id: '#my-modal.modal'};

  if (options) {
    $.extend(settings, options);
  }

  if ($this.length) {
    $(document).on('click', modal_selector, function(e) {
      e.preventDefault();

      const my_modal = $(settings.modal_id);
      $.ajax({
        url: root_dir + '/modals/help',
        type: 'get',
        success: function(data) {
          const the_content = my_modal.find('.modal-content');
          the_content.html(data).find('ul').addClass('list-unstyled').find('> li').prepend('<span class="list-circle"></span>');
        }
      });

      my_modal.modal();
    });
  }
}

function init_newsletter_subscribe_modal(options, callback) {
  let settings = {modal_id: '#my-modal.modal'};

  if (options) {
    $.extend(settings, options);
  }

  $(document).on('click', '.attach-newsletter-popup.pannacotta', function(e) {
    e.preventDefault();

    const $my_modal = $(settings.modal_id);
    $my_modal.find('.modal-content').html('');

    $.ajax({
      url: root_dir + '/modals/newsletter_subscribe',
      type: 'get',
      data: {type: 'no-inputfield'},
      success: function(data) {
        $my_modal.find('.modal-content').html(data);
        if ($(dataLayer).length) {
          add_event_category($my_modal.find('form'), 'popup_box-nl-no-field');
        }
      }
    });

    $my_modal.modal();
  });
}

$.fn.add_coupon_vote = function(options, callback) {
  const $this = $(this);
  let settings = {type: 'positive', css_class: 'active', disabled_after: true};

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
  $('html, body').animate({
    scrollTop: $($(this).attr('href')).offset().top - 20
  }, 500);
});


function plugins_ready() {

  $('[data-coupon-url]').each(function() {
    $(this).coupon_clickout();
  });


  if (window.location.hash.substring(1) === 'help') {
    onload_help_modal('#my-modal.modal');
  }

  init_coupon_list();
  init_get_help_modal();
  init_newsletter_subscribe_modal();

}

$(document).ready(plugins_ready);

export default plugins_ready;
