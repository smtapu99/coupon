import {App} from "../core/facade";

export default (function() {

  function categoryShopFilter() {

    let filter = document.querySelector('.shop-filter__list');
    let loader = document.querySelector('.loader--coupons');

    if (filter) {
      filter.addEventListener('click', function(ev) {

        if (ev.target.getAttribute('data-shop-id')) {
          let checkbox = ev.target;

          let shopIds = [];
          history.replaceState(null, null, window.location.href.replace(/page=[0-9]&?/, ''));

          let checkedBoxes = document.querySelectorAll('.shop-filter__list input[type=checkbox]:checked');
          for (let i = 0; i < checkedBoxes.length; i++) {
            shopIds.push(checkedBoxes[i].getAttribute('data-shop-id'));
          }

          let cardCouponsList = document.querySelector('.coupons-list');
          let coupons = cardCouponsList.querySelectorAll('.coupon');
          for (let i = 0; i < coupons.length; i++) {
            cardCouponsList.removeChild(coupons[i]);
          }
          document.querySelector('.pagination-wrapper').innerHTML = '';

          loader.classList.remove("hidden");

          let params = {shop_id: shopIds};
          //TODO: can we use some API instead of parsing an entire page?
          axios.get(window.location.origin + window.location.pathname, {
            params: params
          })
            .then(function(response) {
              let parser = new DOMParser();
              let doc = parser.parseFromString(response.data, "text/html");
              let cardContent = document.querySelector('.coupons-list');
              let newCardContent = doc.querySelector('.coupons-list');
              cardContent.innerHTML = newCardContent.innerHTML;
              loader.classList.add("hidden");
              App.coupons();
            })
            .catch(function(error) {
              App.log(error);
            });
        }
      });
    }
  }

  function run() {
    App.log("Categories filter run");
    categoryShopFilter();
  }

  return {
    run: run
  };
})();
