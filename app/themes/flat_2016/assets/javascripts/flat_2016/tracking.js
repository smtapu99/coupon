// set google analytics variables globally
var _push, gaClientId, setTrackingUser;

// /*** CARD COUPONS LIST RELATED ***/
// /**
//  * Coupon clickable areas
//  *
//  * @return {boolean}    [description]
//  */

var Tracking = {
  clickoutSelector: '[data-coupon-url]',
  init: function() {
    var $this = this;
    $(this.clickoutSelector).on('click', function(e) {
      $this.element = $(this);
      $this.clickEvent = e;
      $this.clickout();
      e.preventDefault();
    });
  },
  bannersInit: function() {
    var _self = this;

    $('[data-banner-event-action]').on('click', function(e) {
      e.preventDefault();

      var $this = $(this);
      if(_self.gaLoaded()) {
        dataLayer.push({
          'event': 'clickout',
          'eventCategory': 'Clickout - Banner',
          'eventAction': $(this).data('banner-event-action'),
          'eventLabel': $(this).data('banner-event-label'),
          'eventValue': '25',
          eventCallback: function() {
            window.location.href = $this.attr('href');
          }
        });
      } else {
        window.location.href = $this.attr('href');
      }
    });
  },
  gaLoaded: function() {
    return typeof ga !== 'undefined';
  },
  clickout: function() {
    this.defineClickoutBehaviour();
    this.trackJetscale();
    this.trackDataLayerAndRedirect();
  },
  defineClickoutBehaviour: function() {
    var couponUrl = this.element.data('coupon-url');
    var href = this.element.attr('href');
    this.changed_behaviour = typeof this.element.attr('data-changed-behaviour') !== "undefined" ? true : false;

    if (this.changed_behaviour) {
      // alternative clickout
      this.newTab = couponUrl;
      this.sameTab = href;
    } else {
      // standard clickout
      this.newTab = href;
      this.sameTab = couponUrl;
    }
  },
  trackDataLayerAndRedirect: function() {
    var $this = this;
    window.open($this.newTab);

    if(this.gaLoaded()) {
      dataLayer.push({
        'event': 'clickout',
        'eventCategory': 'Clickout - ' + $(this.element).data('shop-name'),
        'eventAction': this.eventActionString(),
        'eventLabel': this.elementData('coupon-title'),
        'eventValue': '25',
        eventCallback: function() {
          window.location.href = $this.sameTab;

          if ($this.changed_behaviour) {
            window.location.reload(true);
          }
        }
      });
    } else {
      window.location.href = $this.sameTab;

      if ($this.changed_behaviour) {
        window.location.reload(true);
      }
    }
  },
  trackJetscale: function() {
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
  },
  elementData: function(value) {
    return $(this.element).data(value);
  },
  eventActionString: function() {
    var elementTrackingString = getPositionEventString(this.clickEvent);
    var page = getUrlParameter('page') || 1;

    if (typeof elementTrackingString === 'undefined') {
      return 'Shop - ' + this.elementData('shop-name') + '/null/null/null/' + page;
    } else {
      return decodeURIComponent(elementTrackingString) + '/' +  this.elementData('coupon-id') + '/' + page;
    }
  }
}

document.addEventListener("DOMContentLoaded", function(){
  Tracking.init();
  Tracking.bannersInit();
});

$.extend({
  getUrlVars: function(){
    var vars = {}, hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
      hash = hashes[i].split('=');
      vars[hash[0]] = hash[1];
    }
    return vars;
  },
  getUrlVar: function(name){
    return $.getUrlVars()[name];
  }
})

;(function($) {

  _push = function(type, options, ele){

    if (!checkTypeAllowed(type)){
      return;
    }

    var data = {
      v: 1,
      tid: ga_uid,
      cid: getGaClientId(),
      t: type,
      cd1: pc_tracking_user_id
    }

    if (options) {
      jQuery.extend(data, options);

      if (type == 'pageview'){
        jQuery.extend(data, {
          dh: window.location.hostname,
          dp: window.location.pathname,
          dt: document.title,
        })
      }
    }

    $.ajax({
      method: 'post',
      data: data,
      // async: false, # deprecated #CA-1169
      url: 'https://www.google-analytics.com/collect',
      complete: function(){
      }
    });

    if (ele && $(ele).attr('href')){
      window.location.href = $(ele).attr('href');
    }

    return;
  }

  function getGaClientId(){
    if (typeof gaClientId !== 'undefined' && gaClientId !== null){
      return gaClientId;
    }

    var val;

    try {
      val = Cookies.get('_ga');
    } catch (e){
      val = null;
    }

    if (typeof val != 'undefined' && val !== null){
      var values = val.split('.', 4);
      gaClientId = values[2] + '.' + values[3];
    } else {
      gaClientId = getCustomCId();
    }

    return gaClientId;
  }

  function checkTypeAllowed(type){
    var allowed_types = ['pageview', 'event', 'transaction'];
    if (allowed_types.indexOf(type) === -1){
      return false;
    }
    return true;
  }

  function getCustomCId(){
    var default_cid   = "1492704099.1416573659";
    var tuid = pc_tracking_user_id + '';
    return default_cid.substr(0, default_cid.length - tuid.length) + tuid;
  }

  window.getGoogleReferrerVars = function(referrer){
    var searchvalue, hash;
    //check if there are query string params
    var hashes = referrer.slice(referrer.indexOf('?') + 1).split('&');

    for (var i = 0; i < hashes.length; i++) {
      hash = hashes[i].split('=');

      if (hash[0] != "undefined" && hash[1] != "undefined" && (hash[0] == "q")) {
        var kwDecoded = decodeURIComponent(hash[1]);

        searchvalue = (kwDecoded.indexOf('+') != -1) ? kwDecoded.split('+') : kwDecoded.split(' ');
      }
    }

    return searchvalue;
  }

})(jQuery);
