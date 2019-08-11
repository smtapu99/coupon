/*eslint-env jquery*/

$(document).ready(function() {
  var cookie = null;
  try {
    cookie = Cookies.get('cookie_eu_consented');
  } catch(e) {
    cookie = null;
  }

  var $cookieBar = $('.cookies-eu');
  var $stickyBar = $(".sticky-bar");
  var $footer = $('#footer');
  var $scrollToTop = $('.scroll-to-top');

  if (cookie !== 'true') {
    $cookieBar.slideToggle(200, function() {
      var pb = ($(".cookies-eu").outerHeight() + ($stickyBar.is(":visible") && $stickyBar.outerHeight()));
      $('.scroll-to-top').css('bottom', pb + 10);
      if ($footer.next().prop("tagName") !== "DIV" && $footer.next().prop("tagName") !== "FOOTER") { // no extra footer
        $('#footer').css('padding-bottom', pb);
      } else { // has extra footer
        $('#footer').next().css('padding-bottom', pb);
      }
    });

    $(document).on('click', '.cookies-eu .btn', function(e) {
      e.preventDefault();

      Cookies.set('cookie_eu_consented', 'true', {path: '/', expires: 365});
      $cookieBar.fadeOut("slow", function() {
        $(this).remove();
        $stickyBar.css('bottom', '0px');
        var pb = (($cookieBar.is(":visible") && $(".cookies-eu").outerHeight()) + ($stickyBar.is(":visible") && $stickyBar.outerHeight()));
        $('.scroll-to-top').css('bottom', 15);
        if ($footer.next().prop("tagName") !== "DIV" && $footer.next().prop("tagName") !== "FOOTER") { // no extra footer
          $('#footer').css('padding-bottom', pb);
        } else { // has extra footer
          $('#footer').next().css('padding-bottom', pb);
        }
      });
    });
  } else {
    $cookieBar.hide();
  }
});
