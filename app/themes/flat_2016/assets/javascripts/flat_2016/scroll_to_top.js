function scrollToTop() {

  var isNewFooter = false;
  var footerScrollToTopButton = null;

  if (document.querySelector(".footer--2019")) {
    isNewFooter = true;
    footerScrollToTopButton = document.querySelector('.footer__to-top');
  }

  function hideIfFooterButtonIsVisible() {
    var rect;
    if (isNewFooter) {
      rect = footerScrollToTopButton.getBoundingClientRect();

      return (
        rect.top >= 0 &&
        rect.bottom <= ((window.innerHeight + rect.height) || (document.documentElement.clientHeight + rect.height))
      );
    } else {
      return false;
    }
  }

  var scrollToTop = document.querySelector(".scroll-to-top");

  if (scrollToTop) {
    scrollToTop.addEventListener("click", function() {
      window.scrollTo({
        top: 0,
        behavior: "smooth"
      });
    });

    window.addEventListener("scroll", function() {
      if (window.pageYOffset > window.innerHeight && !scrollToTop.classList.contains("scroll-to-top--active") && !hideIfFooterButtonIsVisible()) {
        scrollToTop.classList.add("scroll-to-top--active");
      } else if (window.pageYOffset < window.innerHeight || hideIfFooterButtonIsVisible()) {
        scrollToTop.classList.remove("scroll-to-top--active");
      }
    });
  }
}

document.addEventListener("DOMContentLoaded", scrollToTop);
