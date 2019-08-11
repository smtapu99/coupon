import {App} from "../core/facade";
import Cookie from "js-cookie";

export default (function() {

  let hideWithTimeout;

  function run() {
    let notification = document.querySelector(".flyout");
    if (notification) {
      fitTexts();
      show(notification);
    }
  }


  function show(notification) {
    let cookieId = notification.dataset.flyoutId;

    if (!isShown(cookieId)) {
      setCookie(cookieId);

      setTimeout(() => {
        notification.style.display = "";
        notification.classList.add("flyout--visible");
        hide(notification);
        mouseOver(notification, hideWithTimeout);
      }, 5000);
    }


    return cookieId;
  }

  function hide(notification) {
    hideWithTimeout = setTimeout(() => {
      notification.classList.remove("flyout--visible");
    }, 5000);
  }

  function setCookie(cookieId) {
    if (Cookie.get("flyouts")) {
      let shownNotificationIDs = JSON.parse(Cookie.get("flyouts"));

      if (shownNotificationIDs.indexOf(cookieId) === -1) {
        shownNotificationIDs.push(cookieId);
        Cookie.set("flyouts", shownNotificationIDs);
      }
    } else {
      Cookie.set("flyouts", [cookieId]);
    }
  }

  function isShown(cookieId) {
    let isShown = false;
    if (Cookie.get("flyouts")) {
      let shownNotificationIDs = JSON.parse(Cookie.get("flyouts"));

      isShown = (shownNotificationIDs.indexOf(cookieId) > -1);
    }

    return isShown;
  }

  function mouseOver(notification, timer) {
    notification.addEventListener("mouseenter", function() {
      clearTimeout(timer);
    });

    notification.addEventListener("mouseleave", function() {
      hide(notification);
    });
  }

  function fitTexts() {
    App.Utils.textfit(document.getElementsByClassName("flyout__type"), {
      alignHoriz: true,
      widthOnly: true,
      maxFontSize: 23
    });
    App.Utils.textfit(document.getElementsByClassName("flyout__amount"), {
      alignHoriz: true,
      widthOnly: true,
      maxFontSize: 24
    });
  }

  return {
    run: run
  };
})();
