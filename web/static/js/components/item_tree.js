import React from 'react';
import {Component} from 'flumpt';

class ItemTreeComponent extends Component {
  render() {
    let descendants_tree = null;
    if (this.props.children) {
      descendants_tree = this.props.children.map((c) => {
        return <ItemTreeComponent key={c.id} {...c} />;
      });
    }
    return (
      <li className="open">
        <section>
          {this.props.title}
        </section>
        <ul>
          {descendants_tree}
        </ul>
      </li>
    );
  }
}

export default ItemTreeComponent;
