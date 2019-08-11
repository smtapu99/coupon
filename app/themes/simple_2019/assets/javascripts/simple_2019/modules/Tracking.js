/* global dataLayer */

import {App} from "../core/facade";

export default (function() {
  let clickEvent;
  let element;
  let ChangedBehaviour;
  let sameTab;
  let newTab;

  let clickoutSelector = "data-coupon-url";

  function init() {
    setTrackingUser();
    initBanners();
    trackNewslettersForm();

    document.addEventListener("click", function(ev) {

      let parent = ev.target.closest(`[${clickoutSelector}]`);

      if (parent) {
        ev.preventDefault();
        ev.stopPropagation();

        element = parent;
        clickEvent = ev;
        clickout();
      }
    });
  }

  function initBanners() {
    let actions = document.querySelectorAll("*[data-banner-event-action]");
    actions.forEach(function(el) {
      el.addEventListener("click", ev => {
        ev.preventDefault();

        let href = el.getAttribute("href");

        if (gaLoaded()) {
          dataLayer.push({
            'event': 'clickout',
            'eventCategory': 'Clickout - Banner',
            'eventAction': el.getAttribute('data-banner-event-action'),
            'eventLabel': el.getAttribute('data-banner-event-label'),
            'eventValue': '25',
            eventCallback: function() {
              window.location.href = href;
            }
          });
        } else {
          window.location.href = href;
        }
      });
    });
  }

  function getGoogleReferrerVars(referrer) {
    let searchvalue, hash;
    //check if there are query string params
    let hashes = referrer.slice(referrer.indexOf('?') + 1).split('&');

    for (let i = 0; i < hashes.length; i++) {
      hash = hashes[i].split('=');

      if (hash[0] !== "undefined" && hash[1] !== "undefined" && (hash[0] === "q")) {
        let kwDecoded = decodeURIComponent(hash[1]);

        searchvalue = (kwDecoded.indexOf('+') !== -1) ? kwDecoded.split('+') : kwDecoded.split(' ');
      }
    }

    return searchvalue;
  }

  function isRedirectPage() {
    return document.querySelector("body.coupons.clickout") != null;
  }

  function setTrackingUser() {
    if (isRedirectPage()) {
      return;
    }

    let urlWithoutQueryString = window.location.href.split('?')[0];
    let allVars = {};

    // get tracking parameters from the query string
    //check if there are parameters on the url not from search url
    if (window.location.href.indexOf('?') !== -1 && urlWithoutQueryString.indexOf('search') === -1) {
      allVars = App.Utils.getUrlVars();
    }

    // check if we have referer AND if referer is not a cupon page!
    let referrer = document.referrer;

    if (referrer === '' || referrer === "undefined") {
      referrer = 'unknown';
    }

    allVars['referrer'] = referrer;

    if (referrer.indexOf('google') !== -1) {
      let searchValues;
      searchValues = getGoogleReferrerVars(referrer);

      if (typeof searchValues !== 'undefined') {
        for (let i = 0; i < searchValues.length; i++) {
          allVars['searchValue-' + i] = searchValues[i];
        }
      }
    }

    axios
      .post(root_dir + '/tracking/set', {query_string_params: allVars})
      .then(function(response) {
        let data = response.data;
        window.pc_tracking_user_id = data.tracking_user_id;
        triggerTrackingUserSet();
      });
  }

  function triggerTrackingUserSet(subId) {
    let event = new CustomEvent('tracking_user_set');
    document.dispatchEvent(event);
  }

  function clickout() {
    defineClickoutBehaviour();
    trackJetscale();
    trackDataLayerAndRedirect();
  }

  function gaLoaded() {
    return typeof ga !== 'undefined';
  }

  function defineClickoutBehaviour() {
    let couponUrl = elementData('coupon-url');
    let href = element.getAttribute('href');
    ChangedBehaviour = elementData('changed-behaviour') ? true : false;

    if (ChangedBehaviour) {
      // alternative clickout
      newTab = couponUrl;
      sameTab = href;
    } else {
      // standard clickout
      newTab = href;
      sameTab = couponUrl;
    }
  }

  function trackDataLayerAndRedirect() {
    window.open(newTab);

    if (gaLoaded()) {
      dataLayer.push({
        'event': 'clickout',
        'eventCategory': 'Clickout - ' + elementData('shop-name'),
        'eventAction': eventActionString(),
        'eventLabel': elementData('coupon-title'),
        'eventValue': '25',
        eventCallback: function() {
          window.location.href = sameTab;
          if (ChangedBehaviour) {
            window.location.reload(true);
          }
        }
      });
    } else {
      window.location.href = sameTab;
      if (ChangedBehaviour) {
        window.location.reload(true);
      }
    }
  }

  function trackJetscale() {
    if (typeof JETSCALE !== 'undefined') {
      try {
        JETSCALE.event({
          url: window.location.href,
          revenue: '0.25',
          type: 'clickout',
          currencyCode: 'EUR'
        });
      } catch(err) {
      }
    }
  }

  function elementData(value) {
    return element.getAttribute(`data-${value}`);
  }

  function eventActionString() {
    let elementTrackingString; //Todo: implement Element Tracking ---- getPositionEventString(clickEvent);
    let page = App.Utils.getUrlVar('page') || 1;

    if (typeof elementTrackingString === 'undefined') {
      return 'Shop - ' + elementData('shop-name') + '/null/null/null/' + page;
    } else {
      return decodeURIComponent(elementTrackingString) + '/' + elementData('coupon-id') + '/' + page;
    }
  }

  function trackNewslettersForm() {
    App.on("newsletter-modal:show", function() {
      let newsletterModal = document.querySelector(".newsletter-modal");

      if (gaLoaded()) {
        dataLayer.push({
          'event': newsletterModal.dataset.event,
          'eventAction': newsletterModal.dataset.eventAction,
          'eventLabel': newsletterModal.dataset.eventLabel
        });
      }
    });
  }

  function run() {
    App.log('Tracking Module');
    init();
  }

  return {
    run: run
  };
})();
