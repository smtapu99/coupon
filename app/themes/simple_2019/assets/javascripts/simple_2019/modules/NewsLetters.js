import {App} from "../core/facade";
import axios from "axios";

export default (function() {

  let form;

  function init() {
    App.log("NewsLetters init");

    form = document.querySelector(".w-newsletter__form");

    if (form) {
      form.addEventListener("submit", function(ev) {
        ev.preventDefault();
        subscribe();
      });
    }

  }

  function showModal(data) {
    let Modal = document.querySelector("#my-modal .modal__content");
    Modal.innerHTML = data;
    App.trigger("modal:show");
  }

  function subscribe() {

    let button = document.querySelector(".w-newsletter__submit");
    let buttonText = button.innerText;

    button.innerHTML = "<div class='loader'></div>";

    let data = new FormData(form);
    axios.post(form.action, data)
      .then(response => {
        showModal(response.data);
        App.trigger("newsletter-modal:show");
      })
      .then(() => {
        button.innerText = buttonText;
      });
  }

  return {
    run: init
  };

})();
