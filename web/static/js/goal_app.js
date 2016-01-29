import React from 'react';
import {Flux} from 'flumpt';
import KeyStringDetector from 'key-string';
import GoalAppComponent from './components/goal_app';
import {smoothScroll, currentPosition} from './utils.js';

class GoalApp extends Flux {
  subscribe() {
    this.on("goal:scroll", (x, y) => {
      smoothScroll(x, y, 500);
    });
    this.on("goal:keydown", (ev) => {
      const current = document.querySelector('section.current');
      const width = current.offsetWidth;
      const height = current.offsetHeight;
      let [x, y] = currentPosition();
      const detector = new KeyStringDetector();
      switch (detector.detect(ev)) {
        case 'J':
          y += height;
          smoothScroll(x, y, 100);
          break;
        case 'K':
          y -= height;
          smoothScroll(x, y, 100);
          break;
        case 'H':
          x -= width;
          smoothScroll(x, y, 200);
          break;
        case 'L':
          x += width;
          smoothScroll(x, y, 200);
          break;
      }
    })
  }
  render(state) {
    return <GoalAppComponent {...state}/>;
  }
}

export default GoalApp;
