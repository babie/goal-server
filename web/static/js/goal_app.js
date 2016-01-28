import React from 'react';
import {Flux} from 'flumpt';
import GoalAppComponent from './components/goal_app';
import {smoothScroll} from './utils.js';

class GoalApp extends Flux {
  subscribe() {
    this.on("goal:scroll", (x, y) => {
      smoothScroll(x, y, 500);
    });
  }
  render(state) {
    return <GoalAppComponent {...state}/>;
  }
}

export default GoalApp;
