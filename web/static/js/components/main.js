import React from 'react';
import {Component} from 'flumpt';
import ItemTreeComponent from './item_tree.js';

class MainComponent extends Component {
  render() {
    return (
      <main>
        <ul>
          <ItemTreeComponent key={this.props.goal_tree.id} {...this.props.goal_tree} self_and_desendant_ids={this.props.self_and_desendant_ids} />
        </ul>
      </main>
    );
  }
}

export default MainComponent;
