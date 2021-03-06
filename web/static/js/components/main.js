import React from 'react';
import {Component} from 'flumpt';
import ItemTreeComponent from './item_tree.js';

class MainComponent extends Component {
  render() {
    return (
      <main>
        <ul>
          <ItemTreeComponent
            key={this.props.root.model.id}
            ref={this.props.root.model.id}
            tree={this.props.tree}
            node={this.props.root}
            self_and_ancestor_ids={this.props.self_and_ancestor_ids}
            h={0}
            v={0} />
        </ul>
      </main>
    );
  }
}

export default MainComponent;
