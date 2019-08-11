import {App} from "../core/facade";
import ClipboardJS from "clipboard";

export default (function() {

  let Modal = document.querySelector("#my-modal .modal__content");

  function copyButton() {
    let copyButton = document.querySelector('.modal-clickout__copy');

    if (copyButton) {
      let clipboard = new ClipboardJS(copyButton);

      clipboard.on('success', function(e) {
        App.log('Copied:', e.text);

        copyButton.querySelector('.copy-text').classList.add('hidden');
        copyButton.querySelector('.copied-text').classList.remove('hidden');
        copyButton.setAttribute('disabled', 'disabled');

        e.clearSelection();
      });
    }
  }

  function showModal() {
    if (window.location.hash.length && window.location.hash.split("-")[0] === '#id') {

      let couponId = window.location.hash.split("-")[1];
      let url = window.root_dir + '/modals/coupon_clickout?id=' + couponId;

      axios.get(url)
        .then(function(response) {
          Modal.innerHTML = response.data;
          copyButton();
          App.trigger("modal:show");
          App.trigger("showmore");
        })
        .catch(function(err) {
          App.log('Failed to fetch page: ', err);
        });
    }
  }

  function run() {
    App.log("ModalClickout:init");
    showModal();
  }

  return {
    run: run
  };

})();
