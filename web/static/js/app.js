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
import "../../../deps/phoenix_html/web/static/js/phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import ReactDOM from 'react-dom';
import page from 'page';
import GoalApp from './goal_app';


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
  const state = {
    id: parseInt(ctx.params.id),
  }
  app.update(initState => (state));
});
page.start();
