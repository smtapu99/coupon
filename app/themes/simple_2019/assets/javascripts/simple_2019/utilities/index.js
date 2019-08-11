import camelize from "./camelize";
import textfit from "textfit";
import countdown from "./countdown";
import getUrlVar from "./getUrlVar";
import getUrlVars from "./getUrlVars";
import pad from "./pad";
import isMobile from "./isMobile";
import outerHeight from "./outerHeight";
import isInViewPort from "./isInViewPort";

export default (function() {
  return {
    camelize: camelize,
    pad: pad,
    getUrlVar: getUrlVar,
    getUrlVars: getUrlVars,
    countdown: countdown,
    textfit: textfit,
    isMobile: isMobile,
    outerHeight: outerHeight,
    isInViewPort: isInViewPort
  };
})();

