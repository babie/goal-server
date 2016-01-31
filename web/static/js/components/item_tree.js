import React from 'react';
import {Component} from 'flumpt';
import _ from 'lodash';

class ItemTreeComponent extends Component {
  calculatePosition() {
    const width = this.refs.current.offsetWidth;
    const height = this.refs.current.offsetHeight;
    const x = width * this.props.h;
    const y = height * this.props.v;
    return [x, y];
  }

  handleFocus(event) {
    this.dispatch("goal:focus", this.props.node.model.id);
  }

  componentDidMount() {
    if (this.props.node.model.id === this.props.self_and_ancestor_ids[0]) {
      const [x, y] = this.calculatePosition();
      setTimeout(() => { 
        this.dispatch("goal:scroll", x, y);
      }, 1000);
      this.refs.current.focus();
    }
  }

  componentDidUpdate() {
    if (this.props.node.model.id === this.props.self_and_ancestor_ids[0]) {
      const [x, y] = this.calculatePosition();
      this.dispatch("goal:scroll", x, y);
      this.refs.current.focus();
    }
  }

  render() {
    let descendants_tree = null;
    if (!_.isEmpty(this.props.node.children)) {
      descendants_tree = this.props.node.children.map((n, i) => {
        return <ItemTreeComponent key={n.model.id} node={n} self_and_ancestor_ids={this.props.self_and_ancestor_ids} h={this.props.h + 1} v={this.props.v + i} />;
      });
    }
    let openClass = null;
    if (_.some(this.props.self_and_ancestor_ids, (v) => (v === this.props.node.model.id || v === this.props.node.model.parent_id))) {
      openClass = "open";
    }
    let currentClass = null;
    if (this.props.node.model.id === this.props.self_and_ancestor_ids[0]) {
      currentClass = "current";
    }

    return (
      <li className={openClass}>
        <section className={currentClass} tabIndex="0" onFocus={this.handleFocus.bind(this)} onClick={this.handleFocus.bind(this)} ref="current">
          {this.props.node.model.title}
        </section>
        <ul>
          {descendants_tree}
        </ul>
      </li>
    );
  }
}

export default ItemTreeComponent;
