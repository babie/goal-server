import React from 'react';
import {Component} from 'flumpt';
import _ from 'lodash';
import KeyStringDetector from 'key-string';

class ItemTreeComponent extends Component {
  calculatePosition() {
    const width = this.refs.current.offsetWidth;
    const height = this.refs.current.offsetHeight;
    const x = width * this.props.h;
    const y = height * this.props.v;
    return [x, y];
  }

  handleFocus(event) {
    const [x, y] = this.calculatePosition();
    this.dispatch("goal:focus", this.props.node.model.id, x, y);
  }

  handleKeyDown(event) {
    let self_and_ancestor_ids = this.props.self_and_ancestor_ids;
    const root = this.props.root;
    const current = root.first((node) => {
      return node.model.id === _.first(this.props.self_and_ancestor_ids)
    });
    let sibling = null;

    const detector = new KeyStringDetector();
    switch (detector.detect(event)) {
      case 'J':
        sibling = root.first((node) => {
          return (
            node.model.parent_id === current.model.parent_id &&
            node.model.position === current.model.position + 1
          );
        });
        if (sibling) {
          self_and_ancestor_ids = [sibling.model.id].concat(_.tail(self_and_ancestor_ids));
          this.dispatch("self_and_ancestor_ids:update", self_and_ancestor_ids);
        }
        break;
      case 'K':
        sibling = root.first((node) => {
          return (
            node.model.parent_id === current.model.parent_id &&
            node.model.position === current.model.position - 1
          );
        });
        if (sibling) {
          self_and_ancestor_ids = [sibling.model.id].concat(_.tail(self_and_ancestor_ids));
          this.dispatch("self_and_ancestor_ids:update", self_and_ancestor_ids);
        }
        break;
      case 'H':
        if (self_and_ancestor_ids.length >= 2) {
          self_and_ancestor_ids = _.drop(self_and_ancestor_ids, 1);
          this.dispatch("self_and_ancestor_ids:update", self_and_ancestor_ids);
        }
        break;
      case 'L':
        const first_child = current.children[0];
        if (first_child) {
          self_and_ancestor_ids = [first_child.model.id].concat(self_and_ancestor_ids);
          this.dispatch("self_and_ancestor_ids:update", self_and_ancestor_ids);
        }
        break;
    }
  }

  componentDidMount() {
    if (this.props.node.model.id === this.props.self_and_ancestor_ids[0]) {
      setTimeout(() => { 
        this.refs.current.focus();
      }, 1000);
    }
  }

  componentDidUpdate() {
    if (this.props.node.model.id === this.props.self_and_ancestor_ids[0]) {
      if (document.activeElement != this.refs.current) {
        this.refs.current.focus();
      }
    }
  }

  render() {
    let descendants_tree = null;
    if (!_.isEmpty(this.props.node.children)) {
      descendants_tree = this.props.node.children.map((n, i) => {
        return <ItemTreeComponent key={n.model.id} root={this.props.root} node={n} self_and_ancestor_ids={this.props.self_and_ancestor_ids} h={this.props.h + 1} v={this.props.v + i} />;
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
        <section className={currentClass} tabIndex="0" onFocus={this.handleFocus.bind(this)} onClick={this.handleFocus.bind(this)} onKeyDown={this.handleKeyDown.bind(this)} ref="current">
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
