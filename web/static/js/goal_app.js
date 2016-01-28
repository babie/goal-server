import React from 'react';
import {Flux} from 'flumpt';
import GoalAppComponent from './components/goal_app';
import {scrollWithEase} from './utils.js';

class GoalApp extends Flux {
  subscribe() {
    self = this;
    this.on("goal:scroll", (x, y) => {
      setTimeout(() => {
        scrollWithEase(x, y, 500);
      }, 700);
    });
  }
  render(state) {
    return <GoalAppComponent {...state}/>;
  }
}

export default GoalApp;
