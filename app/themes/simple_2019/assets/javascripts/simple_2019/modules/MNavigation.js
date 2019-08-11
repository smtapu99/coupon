import {App} from "../core/facade";
import debounce from 'lodash/debounce';

export default (function() {
  let navigationWrapper, row, navigationItems, leftArrow, rightArrow;

  navigationWrapper = document.querySelector(".m-navigation .container");

  if (navigationWrapper) {
    row = navigationWrapper.querySelector(".row");
    navigationItems = navigationWrapper.querySelectorAll(".m-navigation__item");
    leftArrow = document.querySelector(".m-navigation__arrow--left");
    rightArrow = document.querySelector(".m-navigation__arrow--right");
  }

  function run() {
    if (navigationWrapper) {
      App.log("Main navigation init");
      setContainerWidth();
      showArrows();
      clickOnArrow();
      subMenus();
      updateOnResize();
    }
  }

  function getNavWidth() {
    let width = 0;
    let padding = 5;

    navigationItems.forEach(item => {
      width += getElementOuterWidth(item);
    });

    return width + padding + "px";
  }

  function setContainerWidth() {

    if (App.Utils.isMobile.mobile()) {
      row.style.width = getNavWidth();
    } else {
      row.style.width = "";
    }
  }

  function getElementOuterWidth(el) {
    let elementStyle = window.getComputedStyle(el);

    return el.offsetWidth + parseInt(elementStyle.marginLeft) + parseInt(elementStyle.marginRight);
  }

  function updateOnResize() {
    window.addEventListener("resize", () => {
      setContainerWidth();
      if (App.Utils.isMobile.desktop()) {
        hideArrows();
      }
    });
  }

  function showArrows() {

    if (App.Utils.isMobile.mobile() && row.parentElement.offsetWidth < row.offsetWidth) {
      rightArrow.style.display = "block";
    }
    navigationWrapper.addEventListener("scroll", debounce(() => {
      let scrollLeft = navigationWrapper.scrollLeft;
      let scrollRight = navigationWrapper.scrollWidth - (navigationWrapper.scrollLeft + navigationWrapper.clientWidth);
      let edge = 20;

      switch (true) {
        case(scrollLeft < edge):
          leftArrow.style.display = "none";
          rightArrow.style.display = "block";
          break;
        case(scrollLeft > edge && scrollRight !== 0):
          leftArrow.style.display = "block";
          rightArrow.style.display = "block";
          break;
        case(scrollRight < edge):
          leftArrow.style.display = "block";
          rightArrow.style.display = "none";
          break;
        default:
          leftArrow.style.display = "none";
          rightArrow.style.display = "none";
      }
    }, 300));
  }

  function hideArrows() {
    leftArrow.style.display = "none";
    rightArrow.style.display = "none";
  }

  function clickOnArrow() {
    let scrollWidth = 120;
    leftArrow.addEventListener("click", () => {
      navigationWrapper.scrollLeft = navigationWrapper.scrollLeft - scrollWidth;
    });

    rightArrow.addEventListener("click", () => {
      navigationWrapper.scrollLeft = navigationWrapper.scrollLeft + scrollWidth;
    });
  }

  function subMenus() {
    navigationItems.forEach(el => {
      if (el.classList.contains("has-sub-menu") || el.classList.contains("has-sub-menu__categories")) {
        let openSubmenuLink = el.querySelector(".m-navigation__link");
        openSubmenuLink.addEventListener("click", ev => {
          if (!App.Utils.isMobile.desktop()) {
            ev.preventDefault();
          }
        });
      }
    });
  }

  return {
    run: run
  };
})();
