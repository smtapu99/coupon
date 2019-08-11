var header_ready = function() {

  if (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
    $('input').removeAttr('autofocus');
  }

  /*** Navigation ***/

  var has_sub_menu_selector = '#main-menu > ul > li.has-sub-menu';
  var has_sub_menu = $(has_sub_menu_selector);
  var sub_menu = $('.sub-menu');

  $(document).on('mouseenter mouseover', has_sub_menu_selector, function() {
    has_sub_menu.addClass('open');
    sub_menu.fadeIn(300).removeClass('hidden');
  });

  sub_menu.on('mouseleave', function() {
    has_sub_menu.removeClass('open');
    sub_menu.addClass('hidden');
  });

  $(document).on('mouseenter mouseover','#main-menu > ul > li:not(.has-sub-menu)', function() {
    if (has_sub_menu.hasClass('open')) {
      has_sub_menu.removeClass('open');
      sub_menu.addClass('hidden');
    }
  });

  /*** Navigation Specials ***/
  var has_sub_menu__specials_selector = '#main-menu > ul > li.has-sub-menu__specials';
  var has_sub_menu__specials = $(has_sub_menu__specials_selector);
  var sub_menu__specials = $('.sub-menu__specials');

  $(document).on('mouseenter mouseover', has_sub_menu__specials_selector, function() {
    has_sub_menu__specials.addClass('open');
    sub_menu__specials.fadeIn(300).removeClass('hidden');
  });

  $(document).on('mouseleave', has_sub_menu__specials_selector, function() {
    has_sub_menu__specials.removeClass('open');
    sub_menu__specials.addClass('hidden');
  });

  $(document).on('mouseenter mouseover', '#main-menu > ul > li:not(.has-sub-menu__specials)', function() {
    if (has_sub_menu__specials.hasClass('open')) {
      has_sub_menu__specials.removeClass('open');
      sub_menu__specials.addClass('hidden');
    }
  });


  /*** Navigation Specials ***/
  var has_sub_menu__categories_selector = '#main-menu > ul > li.has-sub-menu__categories';
  var has_sub_menu__categories = $(has_sub_menu__categories_selector);
  var sub_menu__categories = $('.sub-menu__categories');

  $(document).on('mouseenter mouseover', has_sub_menu__categories_selector, function() {
    has_sub_menu__categories.addClass('open');
    sub_menu__categories.fadeIn(300).removeClass('hidden');
  });

  $(document).on('mouseleave', has_sub_menu__categories_selector, function() {
    has_sub_menu__categories.removeClass('open');
    sub_menu__categories.addClass('hidden');
  });

  $(document).on('mouseenter mouseover', '#main-menu > ul > li:not(.has-sub-menu__categories)', function() {
    if (has_sub_menu__categories.hasClass('open')) {
      has_sub_menu__categories.removeClass('open');
      sub_menu__categories.addClass('hidden');
    }
  });


  /*** Search ***/
  var search_input_selector = '#input_search_header';
  var search_input = $(search_input_selector);
  var search_header_results = $('#search-header-results');
  var search_wrapper = search_input.parents('.search-header');

  $(document).on('click', search_input_selector, function() {
    search_wrapper.addClass('active');
  });
  $(document).on('keyup', search_input_selector, function(e) {
    var $this = $(this);

    if (e.keyCode === 38 || e.keyCode === 40 || e.keyCode === 13 || e.keyCode === 27) {
      return;
    }

    clearTimeout($this.data('timer'));

    if ($this.val().length === 0) {
      search_wrapper.removeClass('active');
      search_header_results.addClass('hidden');
    } else {
      $this.data('timer', setTimeout(function() {
        $.ajax({
          url: $this.data('autocomplete-url'),
          data: {query: $this.val()},
          success: function(data) {
            if (data.length > 0) {
              search_wrapper.addClass('active');
              search_header_results.html(data).fadeIn().removeClass('hidden');
            } else {
              search_header_results.html('').fadeOut().addClass('hidden');
            }
          }
        });
      }, 300));
    }
  });
  $(document).on('focusout', search_input_selector, function() {
    setTimeout(function(){
      search_header_results.fadeOut();
      setTimeout(function(){
        search_header_results.addClass('hidden');
      }, 400);
    }, 300);
  });

  $(document).on('keyup', '.search-header', function(e) {
    var li = search_header_results.find('> ul > li.active');

    switch(e.keyCode) {
      case 38: // up
        if (!li.is(':first-child')) {
          li.removeClass('active').prev().addClass('active');
        }
        break;
      case 40: // down
        if (!li.length) {
          search_header_results.find('> ul > li:first-child').addClass('active');
        } else if (!li.is(':last-child')) {
          li.removeClass('active').next().addClass('active');
        }
        break;
      case 13: // enter
        if (li.length) {
          var anchor = li.find('> a');
          var page = getUrlParameter('page');
          var url = anchor.attr('href') + '?p=' + getPositionEventString(e);

          if (page !== undefined) {
            url = url + '&page=' + page;
          }

          window.location.href = url;
        } else {
          search_wrapper.find('form').submit();
        }
        break;
      case 27: // escape
        search_wrapper.removeClass('active');
        search_header_results.addClass('hidden');
        break;
    }
  });
};

jQuery(document).ready(header_ready);
