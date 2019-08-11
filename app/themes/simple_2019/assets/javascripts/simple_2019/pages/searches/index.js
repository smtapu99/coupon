import {App} from "../../core/facade";

App.on("searches_index:init", function() {
  App.log("Search page init");
  App.coupons();
});

