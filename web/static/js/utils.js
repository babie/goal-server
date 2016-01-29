function currentPosition() {
  const x = (window.pageXOffset !== undefined) ? window.pageXOffset : (document.documentElement || document.body.parentNode || document.body).scrollLeft;
  const y = (window.pageYOffset !== undefined) ? window.pageYOffset : (document.documentElement || document.body.parentNode || document.body).scrollTop;
  return [x, y];
}

function smoothScroll(x, y, duration) {
  const step = Math.PI / (duration / 15);
  const [prevX, prevY] = currentPosition();
  const cosXParameter = Math.abs(x - prevX) / 2;
  const cosYParameter = Math.abs(y - prevY) / 2;
  var xCount = 0;
  var yCount = 0;
  var xMargin;
  var yMargin;

  var scrollYInterval = setInterval(() => {
    const [currentX, currentY] = currentPosition();
    if (currentY != y) {
      yCount = yCount + 1;
      yMargin = cosYParameter - cosYParameter * Math.cos(yCount * step);
      let nextY;
      if (prevY < y) {
        nextY = prevY + yMargin;
      }
      else {
        nextY = prevY - yMargin;
      }
      if ((y - 1) <= nextY && nextY <= (y + 1)) {
        window.scrollTo(currentX, y);
        clearInterval(scrollYInterval);
      }
      else {
        window.scrollTo(currentX, nextY);
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
      let nextX;
      if (prevX < x) {
        nextX = prevX + xMargin;
      }
      else {
        nextX = prevX - xMargin;
      }
      if ((x - 1) <= nextX && nextX <= (x + 1)) {
        window.scrollTo(x, currentY);
        clearInterval(scrollXInterval);
      }
      else {
        window.scrollTo(nextX, currentY);
      }
    } 
    else {
      clearInterval(scrollXInterval);
    }
  }, 15 );
}

export {smoothScroll, currentPosition};
