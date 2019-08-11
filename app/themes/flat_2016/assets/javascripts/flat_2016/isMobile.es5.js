/**
 * Small helper for detecting device type
 * @type {{mobile, smallMobile, tablet, tabletLandscape, tabletPortrait, desktop}}
 * @return {Boolean}
 *
 * @example
 * if (ismobile.mobile()) {
 *  doSomethingOnMobileOnly();
 * }
 */

window.isMobile =

  (function() {

    var mobile = "(max-width: 768px)";
    var smallMobile = "(max-width: 320px)";

    var tablet = "(min-width: 768px) and (max-width: 1024px)";
    var tabletLandscape = "(min-width: 768px) and (max-width: 1024px) and (orientation: landscape)";
    var tabletPortrait = "(min-width: 768px) and (max-width: 1024px) and (orientation: portrait)";

    var desktop = "(min-width: 1025px)";

    return {
      mobile: function() {
        return window.matchMedia(mobile).matches;
      },
      smallMobile: function() {
        return window.matchMedia(smallMobile).matches;
      },
      tablet: function() {
        return window.matchMedia(tablet).matches;
      },
      tabletLandscape: function() {
        return window.matchMedia(tabletLandscape).matches;
      },
      tabletPortrait: function() {
        return window.matchMedia(tabletPortrait).matches;
      },
      desktop: function() {
        return window.matchMedia(desktop).matches;
      }
    };

  })();

