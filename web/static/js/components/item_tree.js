import React from 'react';
import {Component} from 'flumpt';
import _ from 'lodash';

class ItemTreeComponent extends Component {
  render() {
    let descendants_tree = null;
    if (this.props.children) {
      descendants_tree = this.props.children.map((c, i) => {
        return <ItemTreeComponent key={c.id} {...c} self_and_desendant_ids={this.props.self_and_desendant_ids} h={this.props.h + 1} v={this.props.v + i} />;
      });
    }
    let open = null;
    if (_.some(this.props.self_and_desendant_ids, (v) => (v === this.props.id || v === this.props.parent_id))) {
      open = "open";
    }

    return (
      <li className={open}>
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
