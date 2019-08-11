$(document).ready(function () {

  var shopBubbles = $(".shop-bubbles__list");

  if (shopBubbles.length) {
    shopBubbles.each(function () {

      var shortRow, longRow, wrapperWidth;

      var wrapper = $(this);

      var items = $(this).find('.shop-bubbles__item');

      var length = items.length;


      var rows = (length <= 20) ? 3 : 4;

      function isOverQuota() {
        return length > 7
      }

      function getTotalBubbles() {
        return wrapper.find(".shop-bubbles__item").length;
      }

      function handleUnfittingCount() {
        if (length % 3 === 0) {
          if (length === 21) {
            rows = 3;
          }
          items.last().remove();
          length = getTotalBubbles();
        }
      }

      function firstRowLonger() {
        if (rows === 4 && length !== 26 && length && length !== 21) {
          var limit = 22;

          if (items.length > limit) {
            items.slice(limit).remove();
            length = getTotalBubbles();
          }
        }

        longRow = Math.round(length / rows);

        shortRow = longRow - 2;

        items.eq(longRow).css('margin-left', '75px');
        items.eq(longRow + shortRow).css('margin-right', '75px');

      }

      function secondRowLonger() {
        shortRow = Math.floor(length / rows);

        longRow = shortRow + 1;

        items.first().css('margin-left', '75px');
        items.eq(shortRow - 1).css('margin-right', '75px');
      }

      function setWrapperWidth() {
        wrapperWidth = items.eq(1).outerWidth(true) * longRow;

        if (wrapperWidth < 1200) {
          wrapper.width(wrapperWidth);
        } else {
          setTimeout(setWrapperWidth, 1000);
        }
      }

      if (isOverQuota()) {

        handleUnfittingCount();

        var rest = Math.floor(((length / rows) % 1) * 10) / 10;

        if (rest === 0.6 || rows === 4) {
          firstRowLonger()

        } else if (rest === 0.3) {
          secondRowLonger()
        }

        setWrapperWidth();

      }

    });

  }


});

