var hideWithTimeout;

function run() {
  var notification = document.querySelector(".flyout");
  if (notification) {
    fitTexts();
    show(notification);
  }
}


function show(notification) {
  var cookieId = notification.dataset.flyoutId;

  if (!isShown(cookieId)) {
    setCookie(cookieId);

    setTimeout(() => {
      notification.style.visibility = "";
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
  if (Cookies.get("flyouts")) {
    var shownNotificationIDs = JSON.parse(Cookies.get("flyouts"));

    if (shownNotificationIDs.indexOf(cookieId) === -1) {
      shownNotificationIDs.push(cookieId);
      Cookies.set("flyouts", shownNotificationIDs);
    }
  } else {
    Cookies.set("flyouts", [cookieId]);
  }
}

function isShown(cookieId) {
  var isShown = false;
  if (Cookies.get("flyouts")) {
    var shownNotificationIDs = JSON.parse(Cookies.get("flyouts"));

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
  textFit(document.getElementsByClassName("flyout__type"), {
    alignHoriz: true,
    widthOnly: true,
    maxFontSize: 23
  });
  textFit(document.getElementsByClassName("flyout__amount"), {
    alignHoriz: true,
    widthOnly: true,
    maxFontSize: 24
  });
}

document.addEventListener("DOMContentLoaded", function() {
  run();
});
