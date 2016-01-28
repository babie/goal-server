function currentPosition() {
  const x = (window.pageXOffset !== undefined) ? window.pageXOffset : (document.documentElement || document.body.parentNode || document.body).scrollLeft;
  const y = (window.pageYOffset !== undefined) ? window.pageYOffset : (document.documentElement || document.body.parentNode || document.body).scrollTop;
  return [x, y];
}

function smoothScroll(x, y, duration) {
  const step = Math.PI / (duration / 15);
  const [width, height] = currentPosition();
  const cosXParameter = width / 2;
  const cosYParameter = height / 2;
  var xCount = 0;
  var yCount = 0;
  var xMargin;
  var yMargin;

  var scrollYInterval = setInterval(() => {
    const [currentX, currentY] = currentPosition();
    if (currentY != y) {
      yCount = yCount + 1;
      yMargin = cosYParameter - cosYParameter * Math.cos(yCount * step);
      if (yMargin < 1.0) {
        window.scrollTo(currentX, y);
        clearInterval(scrollYInterval);
      }
      else {
        window.scrollTo(currentX, (y + height - yMargin));
      }
    }
    else {
      clearInterval(scrollYInterval);
    }
  }, 15 );

  var scrollXInterval = setInterval(() => {
    const [currentX, currentY] = currentPosition();
    if (currentX != x) {
      xCount = xCount + 1;
      xMargin = cosXParameter - cosXParameter * Math.cos(xCount * step);
      if (xMargin < 1.0) {
        window.scrollTo(x, currentY);
        clearInterval(scrollXInterval);
      }
      else {
        window.scrollTo((x + width - xMargin), currentY);
      }
    } 
    else {
      clearInterval(scrollXInterval);
    }
  }, 15 );
}

export {smoothScroll, currentPosition};
