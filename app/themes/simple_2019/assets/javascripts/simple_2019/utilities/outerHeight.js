function getElementOuterHeight(el) {
  let elementStyle = window.getComputedStyle(el);

  return el.offsetHeight + parseInt(elementStyle.marginTop) + parseInt(elementStyle.marginTop);
}

export default getElementOuterHeight;
