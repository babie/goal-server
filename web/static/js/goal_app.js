import React from 'react';
import {Flux} from 'flumpt';
import _ from 'lodash';
import GoalAppComponent from './components/goal_app';
import {smoothScroll, currentPosition} from './utils.js';

class GoalApp extends Flux {
  subscribe() {

    this.on("goal:focus", (id, x, y) => {
      let self_and_ancestor_ids;
      const root = this.state.root;
      const focused = root.first((node) => {
        return node.model.id === id;_
      });
      self_and_ancestor_ids = focused.getPath().map((g) => (g.model.id)).reverse();
      if (self_and_ancestor_ids) {
        const state = _.set(this.state, "self_and_ancestor_ids", self_and_ancestor_ids);
        this.update((s) => {
          return state;
        });
        window.scrollTo(x, y);
      }
    });

    this.on("self_and_ancestor_ids:update", (self_and_ancestor_ids) => {
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
