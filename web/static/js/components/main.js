import React from 'react';
import {Component} from 'flumpt';
import ItemTreeComponent from './item_tree.js';

class MainComponent extends Component {
  render() {
    return (
      <main>
        <ul>
          <ItemTreeComponent {...this.props.goal_tree} />
        </ul>
      </main>
    );
  }
}

export default MainComponent;
