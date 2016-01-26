
function scrollWithEase(x, y, duration) {
  const step = Math.PI / (duration / 15);
  const width = window.scrollX;
  const height = window.scrollY;
  const cosXParameter = width / 2;
  const cosYParameter = height / 2;
  var count = 0;
  var xMargin;
  var yMargin;

  var scrollInterval = setInterval(() => {
    if (window.scrollX != x && window.scrollY != y) {
      count = count + 1;
      xMargin = cosXParameter - cosXParameter * Math.cos(count * step);
      yMargin = cosYParameter - cosYParameter * Math.cos(count * step);
      window.scrollTo((x + width - xMargin), (y + height - yMargin));
    } 
    else {
      clearInterval(scrollInterval); 
    }
  }, 15 );
}

export {scrollWithEase};
