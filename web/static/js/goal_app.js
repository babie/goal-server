import React from 'react';
import {Flux} from 'flumpt';
import _ from 'lodash';
import GoalAppComponent from './components/goal_app';
import {smoothScroll, currentPosition} from './utils.js';

class GoalApp extends Flux {
  subscribe() {
    this.on("self_and_ancestor_ids:update", (node) => {
      const self_and_ancestor_ids = node.getPath().map((n) => (n.model.id)).reverse();
      const state = _.set(this.state, "self_and_ancestor_ids", self_and_ancestor_ids);
      this.update((s) => {
        return state;
      });
    });
  }
  render(state) {
    return <GoalAppComponent {...state}/>;
  }
}

export default GoalApp;
