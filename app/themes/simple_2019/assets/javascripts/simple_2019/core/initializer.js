import {App} from "./facade";
import Common from "../modules/Common";

export default (function() {

  function getCurrentPage() {
    return document.body.getAttribute("data-init");
  }

  return {
    init: function() {
      Common.run();
      App.log("Application Init");
      let pageName = getCurrentPage();
      App.trigger(pageName + ":init");
    }
  };
})();
