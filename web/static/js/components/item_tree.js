import React from 'react';
import {Component} from 'flumpt';
import _ from 'lodash';
import {scroll} from '../utils.js';

class ItemTreeComponent extends Component {
  componentDidMount() {
    if (this.props.id === this.props.self_and_desendant_ids[0]) {
      const width = this.refs.current.offsetWidth;
      const height = this.refs.current.offsetHeight;
      const x = width * 1.5 + width * this.props.h;
      const y = height * this.props.v;
      setTimeout(function() {
        scroll(x, y, 500);
      }, 1000);
    }
  }
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
    let current = null;
    if (this.props.id === this.props.self_and_desendant_ids[0]) {
      current = "current";
    }

    return (
      <li className={open}>
        <section className={current} ref="current">
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
