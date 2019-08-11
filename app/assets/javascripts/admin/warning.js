document.addEventListener("DOMContentLoaded", function() {
  var currentSiteID = document.body.dataset.currentSiteId;
  localStorage.setItem("site_id", currentSiteID);

  window.addEventListener('storage', function(e) {
    if (e.key === "site_id" && e.oldValue !== e.newValue) {
      location.reload();
    }
  });
});
