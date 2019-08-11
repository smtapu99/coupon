import {App} from "../../core/facade";

App.on("categories_show:init", function() {
  App.log("Categories Show page init");
  App.category();
  App.coupons();
});

