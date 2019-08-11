import {App} from "./../core/facade";

export default (function() {
  let couponsSelector = '.coupons-grid__item';
  let couponTypeFilters = document.querySelector('.coupon-type-filter');
  let coupons = document.querySelectorAll(couponsSelector);
  let grid = document.querySelector(".coupons-grid .row");
  let currentFilter = "all";

  function run() {
    App.log("Campaign Page Filter");
    setCouponsDataVisible();
    initCouponTypeFilters();
    couponTypeFilters.style.visibility = 'visible';
  }

  function setCouponsDataVisible() {
    document.querySelectorAll(couponsSelector).forEach((ele) => ele.setAttribute('data-visible', true));
  }

  function initCouponTypeFilters() {

    ['coupon', 'offer'].forEach(function(type) {
      let count = couponsByType(type, true).length;

      if (count > 0) {
        let filterButton = couponTypeFilters.querySelector(`li[data-filter-type=${type}]`);
        filterButton.querySelector("span").innerHTML = count;
        filterButton.addEventListener("click", () => {
          if (currentFilter !== type) {
            currentFilter = type;
            showByType(type);
          }
        });
      } else {
        couponTypeFilters.querySelector(`li[data-filter-type=${type}]`).style.display = 'none';
      }
    });

    let showAllButton = couponTypeFilters.querySelector('li[data-filter-type=all]');
    showAllButton.addEventListener('click', function() {
      if (currentFilter !== "all") {
        currentFilter = "all";
        showByType("all");
      }
    });
  }

  function couponsByType(type, visible) {
    let selector = '';

    if (type !== 'all') {
      selector = `[data-coupon-type='${type}']`;
    }

    if (typeof visible != 'undefined') {
      selector = selector + `[data-visible=${visible}]`;
    }

    if (selector) {
      return document.querySelectorAll(couponsSelector + selector);
    }

    return document.querySelectorAll(couponsSelector);
  }

  function showByType(type) {

    let filterButton = couponTypeFilters.querySelectorAll(`li[data-filter-type]`);
    filterButton.forEach(function(el) {
      if (el.getAttribute('data-filter-type') === type) {
        el.classList.add("active");
      } else {
        el.classList.remove("active");
      }
    });

    coupons.forEach(function(el) {

      if (type === "all") {
        el.parentNode.style.display = 'block';
      } else {
        if (el.getAttribute('data-coupon-type') === type ) {
          el.parentNode.style.display = 'block';
        } else  {
          el.parentNode.style.display = 'none';
        }
      }
    });

    App.trigger("lazy_images:update");

  }

  /*function matchAndCount(type, value) {
    coupons.forEach(function(el) {

      let rawIds = el.getAttribute('data-filter-ids');
      let shop = rawIds.match(/shop-(\d+)x/)[1];
      let category = rawIds.match(/cat-(\d+)x/)[1];

      console.log("Value! = " + value);

      switch (type) {
        case "shop":
          if (shop === value) {
            console.log(rawIds);
            console.log(shop);
          }
          break;
        default:
          console.log("default");
      }
    });
  }
*/
  return {
    run: run
  };
})();
