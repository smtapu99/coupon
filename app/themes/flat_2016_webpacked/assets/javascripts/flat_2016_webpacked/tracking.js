// set google analytics variables globally
let gaClientId, setTrackingUser;

$.extend({
  getUrlVars: function() {
    let vars = {}, hash;
    const hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for (let i = 0; i < hashes.length; i++) {
      hash = hashes[i].split('=');
      vars[hash[0]] = hash[1];
    }
    return vars;
  },
  getUrlVar: function(name) {
    return $.getUrlVars()[name];
  }
});

window._push = function(type, options, ele) {

  if (!checkTypeAllowed(type)) {
    return;
  }

  const data = {
    v: 1,
    tid: ga_uid,
    cid: getGaClientId(),
    t: type,
    cd1: pc_tracking_user_id
  };

  if (options) {
    $.extend(data, options);

    if (type === 'pageview') {
      $.extend(data, {
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
    complete: function() {
    }
  });

  if (ele && $(ele).attr('href')) {
    window.location.href = $(ele).attr('href');
  }
};

function getGaClientId() {
  if (typeof gaClientId !== 'undefined' && gaClientId !== null) {
    return gaClientId;
  }

  let val;

  try {
    val = Cookies.get('_ga');
  } catch(e) {
    val = null;
  }

  if (typeof val !== 'undefined' && val !== null) {
    let values = val.split('.', 4);
    gaClientId = values[2] + '.' + values[3];
  } else {
    gaClientId = getCustomCId();
  }

  return gaClientId;
}

function checkTypeAllowed(type) {
  const allowed_types = ['pageview', 'event', 'transaction'];
  return (allowed_types.indexOf(type) === -1);
}

function getCustomCId() {
  const default_cid = "1492704099.1416573659";
  const tuid = pc_tracking_user_id + '';
  return default_cid.substr(0, default_cid.length - tuid.length) + tuid;
}

window.getGoogleReferrerVars = function(referrer) {
  let searchvalue, hash;
  //check if there are query string params
  const hashes = referrer.slice(referrer.indexOf('?') + 1).split('&');

  for (let i = 0; i < hashes.length; i++) {
    hash = hashes[i].split('=');

    if (hash[0] !== "undefined" && hash[1] !== "undefined" && (hash[0] === "q")) {
      let kwDecoded = decodeURIComponent(hash[1]);

      searchvalue = (kwDecoded.indexOf('+') !== -1) ? kwDecoded.split('+') : kwDecoded.split(' ');
    }
  }

  return searchvalue;
};
