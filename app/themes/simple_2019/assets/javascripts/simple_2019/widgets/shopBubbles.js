export default (function() {

  function run() {
    let shopBubbles = document.querySelectorAll(".shop-bubbles__list");

    if (shopBubbles.length) {

      shopBubbles.forEach(function(el) {

        let shortRow, longRow, wrapperWidth;

        let wrapper = el;

        let items = wrapper.querySelectorAll('.shop-bubbles__item');

        let length = items.length;


        let rows = (length <= 20) ? 3 : 4;

        function isOverQuota() {
          return length > 7;
        }

        function getTotalBubbles() {
          items = wrapper.querySelectorAll('.shop-bubbles__item');
          return wrapper.querySelectorAll(".shop-bubbles__item").length;
        }

        function handleUnfittingCount() {
          if (length % 3 === 0) {
            if (length === 21) {
              rows = 3;
            }
            items[items.length - 1].remove();
            length = getTotalBubbles();
          }
        }

        function firstRowLonger() {
          if (rows === 4 && length !== 26 && length && length !== 21) {
            let limit = 22;

            if (items.length > limit) {
              items.slice(limit).remove();
              length = getTotalBubbles();
            }
          }

          longRow = Math.round(length / rows);

          shortRow = longRow - 2;

          items[longRow].style.marginLeft = '75px';
          items[longRow + shortRow].style.marginRight = '75px';

        }

        function secondRowLonger() {
          shortRow = Math.floor(length / rows);

          longRow = shortRow + 1;

          items[0].style.marginLeft = '75px';
          items[shortRow - 1].style.marginRight = '75px';
        }

        function setWrapperWidth() {
          wrapperWidth = getElementOuterWidth(items[1]) * longRow;
          wrapper.style.width = wrapperWidth + 'px';
        }

        function getElementOuterWidth(el) {
          let elementStyle = window.getComputedStyle(el);

          return el.offsetWidth + parseInt(elementStyle.marginLeft) + parseInt(elementStyle.marginRight);
        }

        if (isOverQuota()) {

          handleUnfittingCount();

          let rest = Math.floor(((length / rows) % 1) * 10) / 10;

          if (rest === 0.6 || rows === 4) {
            firstRowLonger();

          } else if (rest === 0.3) {
            secondRowLonger();
          }
          setTimeout(setWrapperWidth, 1000);
        }

      });

    }
  }

  return {
    run: run
  };

})();

