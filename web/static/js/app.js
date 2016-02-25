// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import ReactDOM from 'react-dom';
import page from 'page';
import TreeModel from 'tree-model';
import _ from 'lodash';
import GoalApp from './goal_app';
import 'whatwg-fetch';

const app = new GoalApp({
  renderer: el => {
    ReactDOM.render(el, document.getElementById('app'));
  },
  initialState: {},
  middlewares: [
    // logger
    (state) => {
      console.log(state);
      return state;
    }
  ]
});

page('/goals/:id', function(ctx, next) {
  const tree = new TreeModel();
  const root = tree.parse(
    {
      id: 1,
      title: "root",
      body: "some contents",
      status_id: 0,
      parent_id: null,
      position: 0,
      owned_by: 1,
      children: [
        {
          id: 2,
          title: "c1",
          body: "some contents",
          status_id: 0,
          parent_id: 1,
          position: 0,
          owned_by: 1,
          children: [
            {
              id: 3,
              title: "c1-1",
              body: "some contents",
              status_id: 0,
              parent_id: 2,
              position: 0,
              owned_by: 1,
              children: []
            },
            {
              id: 4,
              title: "c1-2",
              body: "some contents",
              status_id: 0,
              parent_id: 2,
              position: 1,
              owned_by: 1,
              children: []
            },
            {
              id: 5,
              title: "c1-3",
              body: "some contents",
              status_id: 0,
              parent_id: 2,
              position: 2,
              owned_by: 1,
              children: []
            },
          ]
        },
        {
          id: 6,
          title: "c2",
          body: "some contents",
          status_id: 0,
          parent_id: 1,
          position: 1,
          owned_by: 1,
          children: [
            {
              id: 7,
              title: "c2-1",
              body: "some contents",
              status_id: 0,
              parent_id: 6,
              position: 0,
              owned_by: 1,
              children: []
            },
            {
              id: 8,
              title: "c2-2",
              body: "some contents",
              status_id: 0,
              parent_id: 6,
              position: 1,
              owned_by: 1,
              children: []
            },
            {
              id: 9,
              title: "c2-3",
              body: "some contents",
              status_id: 0,
              parent_id: 6,
              position: 2,
              owned_by: 1,
              children: []
            },
          ]
        },
        {
          id: 10,
          title: "c3",
          body: "some contents",
          status_id: 0,
          parent_id: 1,
          position: 2,
          owned_by: 1,
          children: [
            {
              id: 11,
              title: "c3-1",
              body: "some contents",
              status_id: 0,
              parent_id: 10,
              position: 0,
              owned_by: 1,
              children: []
            },
            {
              id: 12,
              title: "c3-2",
              body: "some contents",
              status_id: 0,
              parent_id: 10,
              position: 1,
              owned_by: 1,
              children: []
            },
            {
              id: 13,
              title: "c3-3",
              body: "some contents",
              status_id: 0,
              parent_id: 10,
              position: 2,
              owned_by: 1,
              children: []
            },
          ]
        },
      ]
    }
  );
  const state = {
    // FIXME: temporary tangible data
    self_and_ancestor_ids: [
      8, 6, 1
    ],
    tree: tree,
    root: root
  }
  app.update(initState => (state));
});
page('/goals', function(ctx, next) {
  fetch('/api/goals', {credentials: 'same-origin'})
  .then((res) => {
    return res.json();
  }).then((json) => {
    const goals = json.data;
    let trees = [];
    let roots = [];
    goals.forEach((g) => {
      if (g.parent_id) {
        let n = trees[trees.length -1].parse(g);
        let r = roots[roots.length - 1];
        let p = r.first((p) => {
          return p.model.id === n.model.parent_id;
        });
        p.addChild(n);
      }
      else {
        let t = new TreeModel({modelComparatorFn: (a, b) => {
          if (a.position < b.position) {
            return -1;
          }
          if (a.position > b.position) {
            return 1;
          }
          return 0;
        }});
        trees.push(t);
        let r = t.parse(g);
        roots.push(r);
      }
      const state = {
        self_and_ancestor_ids: [roots[0].model.id],
        tree: trees[0],
        root: roots[0],
      };
      app.update(initState => (state));
    });
  });
});

page.start();
