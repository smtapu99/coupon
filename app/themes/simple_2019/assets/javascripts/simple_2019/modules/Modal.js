import {App} from "./../core/facade";

export default (function() {

  let modal = document.getElementById("my-modal");
  let modalHidden = "modal--hidden";
  let backdrop = document.querySelector(".backdrop");
  let backdropHidden = "backdrop--hidden";
  let body = document.body;
  let modalOpen = "modal-open";
  let closeButton = document.querySelector(".modal__close-btn");

  function show() {
    App.log("Show Modal");

    backdrop.classList.remove(backdropHidden);
    modal.classList.remove(modalHidden);
    body.classList.add(modalOpen);
    App.trigger("lazy_images:update");

  }

  function hide() {
    App.log("Hide Modal");
    backdrop.classList.add(backdropHidden);
    modal.classList.add(modalHidden);
    body.classList.remove(modalOpen);
  }


  function run() {
    backdrop.addEventListener("click", hide);
    closeButton.addEventListener("click", hide);
    App.on("modal:show", show);
    App.on("modal:close", hide);
  }

  return {
    run: run
  };
})();
