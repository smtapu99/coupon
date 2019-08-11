import {App} from "../core/facade";
import Cookies from "js-cookie";

export default (function() {

  let cookie = null;
  let cookieBar = document.querySelector('.cookies-eu');
  let closeBtn = cookieBar.querySelector(".cookies-eu__close");
  let stickyBar = document.querySelector(".sticky-bar");
  let footer = document.getElementById("footer");

  function init() {

    try {
      cookie = Cookies.get('cookie_eu_consented');
    } catch(e) {
      cookie = null;
    }

    show();

    App.on("sticky_banner", () => {
      setFooterPadding();
    });

    if (cookieBar.style.display !== 'none') {
      closeBtn.addEventListener('click', function(ev) {
        ev.preventDefault();

        Cookies.set('cookie_eu_consented', 'true', {path: '/', expires: 365});
        close();
      });
    }
  }

  function show() {
    if (cookie !== 'true') {
      cookieBar.style.display = '';
    }

    setTimeout(function() {
      setFooterPadding();
    }, 500);
  }

  function close() {
    cookieBar.style.display = 'none';
    setFooterPadding();
    App.trigger("cookies_eu:close");
  }

  function setFooterPadding() {
    if (footer) {
      let paddingBottom = (isVisible(stickyBar) && App.Utils.outerHeight(stickyBar)) + (isVisible(cookieBar) && App.Utils.outerHeight(cookieBar));
      footer.style.paddingBottom = paddingBottom + "px";
    }
  }

  function isVisible(el) {
    if (!el) {
      return false;
    }

    let rect = el.getBoundingClientRect();

    return (
      rect.top >= 0 &&
      rect.left >= 0 &&
      rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
      rect.right <= (window.innerWidth || document.documentElement.clientWidth) &&
      el.display !== 'none'
    );
  }

  function run() {
    App.log("CookiesEU module");
    if (cookieBar) {
      init();
    }
  }

  return {
    run: run
  };
})();
