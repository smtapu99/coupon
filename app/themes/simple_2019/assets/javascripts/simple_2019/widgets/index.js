import {App} from "./../core/facade";
import shopBubbles from "./shopBubbles";
import quickLinks from "./quickLinks";
import couponsGrid from "./couponsGrid";

export default (function() {

  function run() {
    App.log("Widgets init");
    shopBubbles.run();
    quickLinks.run();
    couponsGrid.run();
  }

  return {
    run: run
  };
})();
