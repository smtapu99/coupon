import {App} from "./../core/facade";

export default (function() {

  if (window.sticky_banner) {
    var {startDate = new Date(startDate), endDate, id, countdownDate} = window.sticky_banner;

    startDate = new Date(startDate);
    endDate = new Date(endDate);

    if (countdownDate) {
      countdownDate = new Date(countdownDate);
    }

    var currentDate = new Date();
    var stickyBar = document.querySelector('.sticky-bar');
    var stickyClose = stickyBar.querySelector('.sticky-bar__close');
    var cookieName = `sticky-bar-${id}`;
    var cookieLifetimeDays = 1;
  }

  function hide() {
    let date = new Date();
    stickyBar.style.transform = "translateY(225px)";
    document.cookie = cookieName + "=true; expires=" + date.setDate(date.getDate() + cookieLifetimeDays) + "; path=/";
  }

  function moveAboveCookieNotice() {
    let notice = document.querySelector(".cookies-eu");

    if (notice && notice.style.display !== "none") {
      stickyBar.style.transform = `translateY(-${notice.offsetHeight}px)`;
    }
  }

  function showIfNoCookie() {
    if (stickyBar) {
      if (document.cookie.indexOf(cookieName) < 0) {
        stickyBar.style.transform = "translateY(0)";
      }

      stickyBar.addEventListener("transitionend", function() {
        App.trigger("sticky_banner");
      });
    }
  }

  function run() {
    App.log("Banners init");
    App.on("cookies_eu:close", function() {
      showIfNoCookie();
    });

    if (document.cookie.indexOf(cookieName) < 0 && currentDate < endDate && currentDate > startDate) {
      if (typeof countdownDate !== 'undefined' && currentDate < countdownDate) {
        App.Utils.countdown(stickyBar, {date: countdownDate});
      }

      stickyClose.addEventListener("click", function(e) {
        e.preventDefault();
        e.stopPropagation();
        hide();
      });

      setTimeout(
        function() {
          showIfNoCookie();
          moveAboveCookieNotice();
        }, 1000
      );
    }
  }

  return {
    run: run
  };

})();
