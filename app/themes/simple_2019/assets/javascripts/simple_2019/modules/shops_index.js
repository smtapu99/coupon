import {App} from "../core/facade";

export default (function() {

  function showMoreInformation() {

    let buttons = document.querySelectorAll(".shops-index__category-see-details");

    buttons.forEach((button) => {
      let modifier = "shops-index__category-text--hidden";

      let category_text_container = button.closest(".shops-index__category-text");
      let shop_text_truncated = category_text_container.querySelector(".shops-index__category-text--truncated");
      let shop_text_full = category_text_container.querySelector(".shops-index__category-text--full");

      let moreText = button.dataset.moreText;
      let lessText = button.dataset.lessText;

      button.addEventListener('click', (ev) => {
        ev.preventDefault();
        ev.stopPropagation();
        if (shop_text_full) {
          if (shop_text_full.classList.contains(modifier)) {
            shop_text_full.classList.remove(modifier);
            shop_text_truncated.classList.add(modifier);
            button.innerText = lessText;
          } else {
            shop_text_full.classList.add(modifier);
            shop_text_truncated.classList.remove(modifier);
            button.innerText = moreText;
          }
        }

      });
    });
  }

  function run() {
    App.log("Shop module");
    showMoreInformation();
  }

  return {
    run: run
  };
})();
