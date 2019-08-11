import {App} from "../core/facade";

export default (function() {
  let couponsSelector = '.active-coupons .coupons-list .coupon';
  let couponTypeFilters = document.querySelector('.coupon-type-filter');
  let coupons = document.querySelectorAll(couponsSelector);

  function init() {
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
          showByType(type);
        });
      } else {
        couponTypeFilters.querySelector(`li[data-filter-type=${type}]`).style.display = 'none';
      }
    });

    let showAllButton = couponTypeFilters.querySelector('li[data-filter-type=all]');
    showAllButton.addEventListener('click', function() {
      showByType("all");
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
        el.style.display = "block";
      } else {
        el.style.display = "none";
        if (el.getAttribute('data-coupon-type') === type) {
          el.style.display = "block";
        }
      }
    });
  }

  function run() {
    if (!couponTypeFilters) return;

    App.log('CouponFilters Module');
    init();
  }

  return {
    run: run,
  };
})();
