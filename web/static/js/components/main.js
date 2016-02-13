import React from 'react';
import {Component} from 'flumpt';
import ItemTreeComponent from './item_tree.js';

class MainComponent extends Component {
  render() {
    return (
      <main>
        <ItemTreeComponent key={this.props.root.id} tree={this.props.tree} node={this.props.root} self_and_ancestor_ids={this.props.self_and_ancestor_ids} h={0} v={0} />
      </main>
    );
  }
}

export default MainComponent;
