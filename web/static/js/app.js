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

import React from 'react';  //eslint-disable-line
import {Flux, Component} from 'flumpt';
import ReactDOM from 'react-dom';
import page from 'page';

class CounterComponent extends Component {
  render() {
    return (
      <div>
        <p>count: {this.props.count}</p>
        <div>
          <button onClick={() => this.dispatch('increment')}>+1</button>
          <button onClick={() => this.dispatch('decrement')}>-1</button>
        </div>
      </div>
    );
  }
}


class App extends Flux {
  subscribe() {
    this.on('increment', () => {
      this.update(({count}) => {
        return {count: count + 1};
      });
    });
    this.on('decrement', () => {
      this.update(({count}) => {
        return {count: count - 1};
      });
    });
  }
  render(state) {
    return <CounterComponent {...state}/>;
  }
}

const app = new App({
  renderer: el => {
    ReactDOM.render(el, document.querySelector('.container'));
  },
  initialState: {count: 0},
  middlewares: [
    // logger
    (state) => {
      console.log(state);
      return state;
    }
  ]
});

page('/goals/:id', function() {
  app.update(_initialState => (_initialState));
});
page();
