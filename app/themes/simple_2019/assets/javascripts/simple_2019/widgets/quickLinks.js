export default (function() {

  function run() {

    let quickLinks = document.querySelectorAll(".top-links__btn");

    if (quickLinks.length) {
      quickLinks.forEach(function(el) {
        el.addEventListener('click', function(ev) {
          ev.preventDefault();
          let anchor = el.getAttribute('href').slice(1);
          ScrollToWidget(anchor);
        });
      });
    }

  }

  function ScrollToWidget(widget_id) {
    let widget = document.querySelector(`[id^=${widget_id}]`);

    if (widget) {
      let widgetOffsetTop = widget.getBoundingClientRect().top + window.scrollY;
      window.scrollTo({
        top: widgetOffsetTop,
        behavior: "smooth"
      });
    }
  }

  return {
    run: run
  };

})();
