export default function(el, fullyVisible = false) {
  let rect = el.getBoundingClientRect();

  let isInViewPort = (
    rect.top >= 0 &&
    rect.left >= 0 &&
    rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
    rect.right <= (window.innerWidth || document.documentElement.clientWidth)
  );

  if (fullyVisible) {
    isInViewPort = (
      rect.top >= 0 &&
      rect.left >= 0 &&
      rect.bottom <= ((window.innerHeight + rect.height) || (document.documentElement.clientHeight + rect.height)) &&
      rect.right <= ((window.innerWidth + rect.width) || (document.documentElement.clientWidth + rect.width))
    );
  }

  return isInViewPort;
}
