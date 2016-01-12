import React from 'react';
import {Flux} from 'flumpt';
import GoalAppComponent from './components/goal_app';

class GoalApp extends Flux {
  subscribe() {
  }
  render(state) {
    return <GoalAppComponent {...state}/>;
  }
}

export default GoalApp;
