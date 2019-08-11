import {App} from "../core/facade";

export default (
  function() {
    function init() {

      App.log("ScrollToTop Init");

      let scrollToTop, footerScrollToTopButton;

      if (document.querySelector(".footer--2019")) {
        footerScrollToTopButton = document.querySelector('.footer__to-top');
      }

      scrollToTop = document.querySelector(".scroll-to-top");

      window.addEventListener("scroll", function() {
        if (window.pageYOffset > window.innerHeight && !scrollToTop.classList.contains("scroll-to-top--active") && !hideIfFooterButtonIsVisible(footerScrollToTopButton)) {
          scrollToTop.classList.add("scroll-to-top--active");
        } else if (window.pageYOffset < window.innerHeight || hideIfFooterButtonIsVisible(footerScrollToTopButton)) {
          scrollToTop.classList.remove("scroll-to-top--active");
        }
      });

      [footerScrollToTopButton, scrollToTop].forEach(el => {
        if (el) {
          el.addEventListener("click", function(ev) {
            ev.preventDefault();

            window.scrollTo({
              top: 0,
              behavior: "smooth"
            });
          });
        }
      });
    }

    function hideIfFooterButtonIsVisible(footerButton) {
      if (footerButton) {
        return App.Utils.isInViewPort(footerButton, true);
      } else {
        return false;
      }
    }

    return {run: init};
  }

)();
