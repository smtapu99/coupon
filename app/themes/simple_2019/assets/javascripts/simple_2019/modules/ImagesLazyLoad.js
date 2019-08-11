import {App} from "../core/facade";
import Layzr from 'layzr.js';

export default (function() {

  let instance;

  function init() {
    App.log("Images Lazy Load Module init");
    instance = Layzr({
      threshold: 100
    });

    update();

    App.on("lazy_images:update", update);
  }

  function update() {
    instance.update().check().handlers(true);
  }

  return {
    run: init,
    update: update
  };

})();
