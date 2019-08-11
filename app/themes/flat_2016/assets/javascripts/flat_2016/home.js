// featured shops

$(document).ready(function() {
  $('.flexslider--home').flexslider({
    animation: "slide",
    animationLoop: true,
    customDirectionNav: ".custom-navigation a",
    selector: ".slides > li",
    touch: true,
    slideshow: false,
    pauseOnAction: true
  }).show();
  $(window).trigger('resize');
});
