function currentXPosition() {
  // Firefox, Chrome, Opera, Safari
  if (self.pageXOffset) return self.pageXOffset;
  // Internet Explorer 6 - standards mode
  if (document.documentElement && document.documentElement.scrollLeft)
      return document.documentElement.scrollLeft;
  // Internet Explorer 6, 7 and 8
  if (document.body.scrollLeft) return document.body.scrollLeft;
  return 0;
}

function currentYPosition() {
  // Firefox, Chrome, Opera, Safari
  if (self.pageYOffset) return self.pageYOffset;
  // Internet Explorer 6 - standards mode
  if (document.documentElement && document.documentElement.scrollTop)
      return document.documentElement.scrollTop;
  // Internet Explorer 6, 7 and 8
  if (document.body.scrollTop) return document.body.scrollTop;
  return 0;
}

function currentPosition() {
  const x = currentXPosition();
  const y = currentYPosition();
  return [x, y];
}

function scrollWithEase(x, y, duration) {
  const step = Math.PI / (duration / 15);
  const width = window.scrollX;
  const height = window.scrollY;
  const cosXParameter = width / 2;
  const cosYParameter = height / 2;
  var xCount = 0;
  var yCount = 0;
  var xMargin;
  var yMargin;

  var scrollYInterval = setInterval(() => {
    const currentY = currentYPosition();
    if (window.scrollY != y) {
      yCount = yCount + 1;
      yMargin = cosYParameter - cosYParameter * Math.cos(yCount * step);
      if (yMargin < 1.0) {
        window.scrollTo(window.scrollX, y);
        clearInterval(scrollYInterval);
      }
      else {
        window.scrollTo(window.scrollX, (y + height - yMargin));
      }
    }
    else {
      clearInterval(scrollYInterval);
    }
  }, 15 );
  var scrollXInterval = setInterval(() => {
    const currentX = currentXPosition();
    if (window.scrollX != x) {
      xCount = xCount + 1;
      xMargin = cosXParameter - cosXParameter * Math.cos(xCount * step);
      if (xMargin < 1.0) {
        window.scrollTo(x, window.scrollY);
        clearInterval(scrollXInterval);
      }
      else {
        window.scrollTo((x + width - xMargin), window.scrollY);
      }
    } 
    else {
      clearInterval(scrollXInterval);
    }
  }, 15 );
}

export {scrollWithEase, currentPosition};
