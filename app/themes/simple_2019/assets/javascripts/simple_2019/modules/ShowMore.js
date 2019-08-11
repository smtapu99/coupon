import {App} from "../core/facade";

export default (function() {
  function init() {
    let buttons = document.querySelectorAll(".coupon__see-details");

    buttons.forEach((button) => {

      if(!button.hasAttribute("data-has-event")) {
        let modifier = "coupon__text--hidden";

        button.dataset.hasEvent = "true";

        let couponContainer = button.closest(".coupon, .modal-clickout");
        let couponTextTruncated = couponContainer.querySelector(".coupon__text--truncated");
        let couponTextFull = couponContainer.querySelector(".coupon__text--full");

        let moreText = button.dataset.moreText;
        let lessText = button.dataset.lessText;

        button.addEventListener('click', (ev) => {
          ev.preventDefault();
          ev.stopPropagation();

          if (couponTextFull) {
            if (couponTextFull.classList.contains("coupon__text--hidden")) {
              couponTextFull.classList.remove(modifier);
              couponTextTruncated.classList.add(modifier);
              button.classList.add("coupon__see-details--opened");
              button.innerText = lessText;
            } else {
              couponTextFull.classList.add(modifier);
              couponTextTruncated.classList.remove(modifier);
              button.classList.remove("coupon__see-details--opened");
              button.innerText = moreText;
            }
          }

        });
      }
    });
  }
  function run(){
    App.on("showmore", init)
  }
  return {
    run: run
  }
})();