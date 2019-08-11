import {App} from "../core/facade";

export default (function() {

  function fitTexts() {
    App.Utils.textfit(document.getElementsByClassName("coupon__type"), {
      alignHoriz: true,
      widthOnly: true,
      maxFontSize: 23
    });
    App.Utils.textfit(document.getElementsByClassName("coupon__amount"), {
      alignHoriz: true,
      widthOnly: true,
      maxFontSize: 36
    });
    App.Utils.textfit(document.querySelectorAll(".coupon__action .clickout.btn"),
      {alignHoriz: true, widthOnly: true, maxFontSize: 14, detectMultiLine: false});
  }

  function run() {
    App.log("Coupons module");
    App.trigger("lazy_images:update");
    fitTexts();
    App.trigger("showmore");
  }

  return {
    run: run
  };
})();
