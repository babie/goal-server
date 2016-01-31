import React from 'react';
import {Component} from 'flumpt';
import _ from 'lodash';

class ItemTreeComponent extends Component {
  calculatePosition() {
    const width = this.refs.current.offsetWidth;
    const height = this.refs.current.offsetHeight;
    const x = width * 1.5 + width * this.props.h;
    const y = height * 1.5 + height * this.props.v;
    return [x, y];
  }

  handleFocus(event) {
    this.dispatch("goal:focus", this.props.id);
  }

  componentDidMount() {
    if (this.props.id === this.props.self_and_ancestor_ids[0]) {
      const [x, y] = this.calculatePosition();
      setTimeout(() => { 
        this.dispatch("goal:scroll", x, y);
      }, 1000);
    }
  }

  componentDidUpdate() {
    if (this.props.id === this.props.self_and_ancestor_ids[0]) {
      const [x, y] = this.calculatePosition();
      this.dispatch("goal:scroll", x, y);
    }
  }

  render() {
    let descendants_tree = null;
    if (this.props.descendants) {
      descendants_tree = this.props.descendants.map((c, i) => {
        return <ItemTreeComponent key={c.id} {...c} self_and_ancestor_ids={this.props.self_and_ancestor_ids} h={this.props.h + 1} v={this.props.v + i} />;
      });
    }
    let openClass = null;
    if (_.some(this.props.self_and_ancestor_ids, (v) => (v === this.props.id || v === this.props.parent_id))) {
      openClass = "open";
    }
    let currentClass = null;
    if (this.props.id === this.props.self_and_ancestor_ids[0]) {
      currentClass = "current";
    }

    return (
      <li className={openClass}>
        <section className={currentClass} tabIndex={0} onFocus={this.handleFocus.bind(this)} onClick={this.handleFocus.bind(this)} ref="current">
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
