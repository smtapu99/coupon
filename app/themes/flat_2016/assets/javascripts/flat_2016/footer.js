var footer_ready = function() {

  if (isMobile.mobile() || isMobile.tablet()) {
    var widget_selector = '.pannacotta#footer .widget';
    var widgets = $(widget_selector);

    widgets.find('.widget-content').hide();

    $('body').on('click', widget_selector + ' > .widget-header', function(e) {
      var $this = $(this);

      e.preventDefault();

      $this.toggleClass('collapsed');
      $this.next('.widget-content').slideToggle();
    });
  }

  $('.footer__to-top').click(function () {
    $("html, body").animate({
      scrollTop: 0
    }, 200);
    return false;
  });

};

jQuery(document).ready(function(){
  footer_ready();
});
