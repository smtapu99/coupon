import isMobile from './isMobile';

function footer_ready() {

  if (isMobile.mobile() || isMobile.tablet()) {
    const widget_selector = '.pannacotta#footer .widget';
    let widgets = $(widget_selector);

    widgets.find('.widget-content').hide();

    $('body').on('click', widget_selector + ' > .widget-header', function(e) {
      const $this = $(this);

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
}

jQuery(document).ready(footer_ready);
