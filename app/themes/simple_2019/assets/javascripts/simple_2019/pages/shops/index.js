import {App} from "../../core/facade";

App.on("shops_show:init", function() {
  App.log("Shop page init");
  App.coupons();
  App.vote();
  App.CouponFilters();
});

App.on("shops_index:init", function() {
  App.log("Shops index page init");
  App.ShopsIndex();
});
