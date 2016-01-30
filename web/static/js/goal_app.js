import React from 'react';
import {Flux} from 'flumpt';
import _ from 'lodash';
import KeyStringDetector from 'key-string';
import GoalAppComponent from './components/goal_app';
import {smoothScroll, currentPosition} from './utils.js';

class GoalApp extends Flux {
  subscribe() {
    this.on("goal:scroll", (x, y) => {
      smoothScroll(x, y, 100);
    });
    this.on("goal:keydown", (ev) => {
      const currentDOM = document.querySelector('section.current');
      const width = currentDOM.offsetWidth;
      const height = currentDOM.offsetHeight;
      let [x, y] = currentPosition();
      let self_and_ancestor_ids = this.state.self_and_ancestor_ids;
      const root = this.state.root;
      const current = root.first((node) => {
        return node.model.id === _.first(this.state.self_and_ancestor_ids)
      });
      let sibling = null;

      const detector = new KeyStringDetector();
      switch (detector.detect(ev)) {
        case 'J':
          sibling = root.first((node) => {
            return (
              node.model.parent_id === current.model.parent_id &&
              node.model.position === current.model.position + 1
            );
          });
          if (sibling) {
            self_and_ancestor_ids = [sibling.model.id].concat(_.tail(self_and_ancestor_ids));
            const state = _.merge(this.state, {self_and_ancestor_ids: self_and_ancestor_ids});
            this.update((s) => {
              return state;
            });
          }
          break;
        case 'K':
          sibling = root.first((node) => {
            return (
              node.model.parent_id === current.model.parent_id &&
              node.model.position === current.model.position - 1
            );
          });
          if (sibling) {
            self_and_ancestor_ids = [sibling.model.id].concat(_.tail(self_and_ancestor_ids));
            const state = _.merge(this.state, {self_and_ancestor_ids: self_and_ancestor_ids});
            this.update((s) => {
              return state;
            });
          }
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
