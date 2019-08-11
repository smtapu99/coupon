import {App} from "./../core/facade";

export default (function() {

  function showMoreCoupons() {
    let showMore = document.getElementById('show-more-coupons');
    let arrExtraItems = document.querySelectorAll('.coupons-grid__extra-item');
    if (showMore && arrExtraItems) {
      showMore.addEventListener('click', function() {
        arrExtraItems.forEach(function(item) {
          item.classList.remove('hidden');
        });
        showMore.classList.add('hidden');
      });
      App.log("couponsGrid init");
    }
  }

  return {
    run: showMoreCoupons
  };

})();