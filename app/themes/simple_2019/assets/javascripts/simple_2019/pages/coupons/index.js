import {App} from "../../core/facade";

App.on("coupons_index:init", function() {
  App.log("Coupons page init");
  App.coupons();

  (function filterByType() {
    let toggleBtn = document.querySelector('.filter-by-type__toggle');
    let dropdown = document.querySelector('.filter-by-type__dropdown');
    let expanded = 'filter-by-type__dropdown--expanded';
    let toggleBtnActive = 'filter-by-type__toggle--active';

    toggleBtn.addEventListener('click', function(ev) {
      ev.preventDefault();
      if (App.Utils.isMobile.tabletPortrait() || App.Utils.isMobile.mobile()) {
        dropdown.classList.toggle(expanded);
        toggleBtn.classList.toggle(toggleBtnActive);
      }
    });

  }());

});
