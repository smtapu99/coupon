if (document.body.classList.contains('coupons') && (document.body.classList.contains('clickout') || document.body.classList.contains('api_clickout'))) {
  if (window.Clickout) {
    window.setTimeout(clickout_redirect, 800);
  }
}

function clickout_redirect() {
  window.location.href = window.Clickout.redirect_url;
}
