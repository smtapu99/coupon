import {App} from "../../core/facade";

App.on("campaigns_show:init", function() {
  App.log("Campaign page init");
  App.widgets();
  App.CampaignCouponsFilter();
});

