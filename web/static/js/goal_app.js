import React from 'react';
import {Flux} from 'flumpt';
import _ from 'lodash';
import GoalAppComponent from './components/goal_app';

class GoalApp extends Flux {
  subscribe() {
    this.on("self_and_ancestor_ids:update", (node) => {
      const self_and_ancestor_ids = node.getPath().map((n) => (n.model.id)).reverse();
      const state = _.set(this.state, "self_and_ancestor_ids", self_and_ancestor_ids);
      this.update((s) => {
        return state;
      });
    });

    this.on("clipboard:copy", (node) => {
      const clipboard = _.clone(this.state.clipboard);
      clipboard.push(node);
      const state = _.set(this.state, "clipboard", clipboard);
      this.update((s) => {
        return state;
      });
    });

    this.on("clipboard:paste", (dest, newPosition) => {
      const clipboard = _.clone(this.state.clipboard);
      const target = clipboard.pop();
      const parent = dest.parent;
      const position = dest.model.position + (newPosition === "before" ? 0 : 1);

      const tmpGoal = this.state.tree.parse({
        id: -1,
        title: target.model.title,
        body: target.model.body,
        parent_id: dest.model.parent_id,
        position: dest.model.position + 1,
        status_id: target.model.status_id,
      });

      parent.children.forEach((c) => {
        if (c.model.position >= position) {
          c.model.position += 1;
        }
      });
      const newNode = parent.addChild(tmpGoal);
      const self_and_ancestor_ids = newNode.getPath().map((n) => (n.model.id)).reverse();

      fetch('/api/goals/' + target.model.id + '/copy/?dest_parent_id=' + dest.model.parent_id + '&dest_position=' + position, {
        credentials: 'include',
        method: 'post',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
      }).then((res) => {
        return res.json();
      }).then((json) => {
        const node = parent.children[position];
        node.model.id = json.data[0].id;
      });

      const state = _.merge(this.state, {self_and_ancestor_ids: self_and_ancestor_ids, clipboard: clipboard});
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
