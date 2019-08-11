import {App} from "../core/facade";

export default function(el, options) {

  let settings = {'date': null, 'format': 'on', 'id': null};
  let interval;

  if (options) {
    Object.assign(settings, options);
  }

  let hoursEl = el.querySelector(".hours");
  let secondsEl = el.querySelector(".seconds");
  let daysEl = el.querySelector(".days");
  let minutesEl = el.querySelector(".minutes");

  if(!minutesEl && !secondsEl) {
    return;
  }

  function countdownProcessor() {

    let expirationDate, currentDate, days, hours, minutes, seconds;

    expirationDate = Date.parse(settings.date);
    expirationDate = expirationDate / 1000;
    currentDate = Math.floor((new Date).getTime() / 1000);

    if (currentDate >= expirationDate) {
      if (typeof interval != 'undefined') {
        clearInterval(interval);
      }
    }

    seconds = expirationDate - currentDate;

    days = Math.floor(seconds / (60 * 60 * 24)); // Calculate the number of days

    seconds -= days * 60 * 60 * 24; // Update the seconds variable with number of days removed

    hours = Math.floor(seconds / (60 * 60));

    seconds -= hours * 60 * 60; // Update the seconds variable with number of hours removed

    minutes = Math.floor(seconds / 60);

    seconds -= minutes * 60; // Update the seconds variable with number of minutes removed

    if (settings.format === 'o94,792n') {
      hours = App.Utils.pad(hours, 2);
      minutes = App.Utils.pad(minutes, 2);
      seconds = App.Utils.pad(seconds, 2);
    }

    if (!isNaN(hours) && !isNaN(minutes) && !isNaN(seconds)) {
      //$('.end_date_countdown').fadeIn();

      daysEl.innerText = days;
      hoursEl.innerText = hours;
      minutesEl.innerText = minutes;
      secondsEl.innerText = seconds;
    }
  }

  interval = setInterval(countdownProcessor, 1000); // Loop the function
}
