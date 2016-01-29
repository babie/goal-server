import React from 'react';
import {Component} from 'flumpt';
import ItemTreeComponent from './item_tree.js';

class MainComponent extends Component {
  render() {
    return (
      <main>
        <ul>
          <ItemTreeComponent key={this.props.root.id} {...this.props.root.model} self_and_ancestor_ids={this.props.self_and_ancestor_ids} h={0} v={0} />
        </ul>
      </main>
    );
  }
}

export default MainComponent;
