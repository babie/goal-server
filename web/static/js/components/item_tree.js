import React from 'react';
import {Component} from 'flumpt';
import _ from 'lodash';
import KeyStringDetector from 'key-string';
import {smoothScroll, currentPosition} from '../utils.js';

class ItemTreeComponent extends Component {
  calculatePosition() {
    const width = this.refs.current.offsetWidth;
    const height = this.refs.current.offsetHeight;
    const x = width * 1.5 + width * this.props.h;
    const y = height * this.props.v;
    return [x, y];
  }
  handleKeyDown(ev) {
    const current = document.querySelector('section.current');
    const width = current.offsetWidth;
    const height = current.offsetHeight;
    let [x, y] = currentPosition();
    const detector = new KeyStringDetector();
    switch (detector.detect(ev)) {
      case 'J':
        y += height;
        smoothScroll(x, y, 400);
        break;
      case 'K':
        y -= height;
        smoothScroll(x, y, 400);
        break;
      case 'H':
        x -= width;
        smoothScroll(x, y, 400);
        break;
      case 'L':
        x += width;
        smoothScroll(x, y, 400);
        break;
    }
  }
  componentDidMount() {
    if (this.props.id === this.props.self_and_ancestor_ids[0]) {
      const [x, y] = this.calculatePosition();
      setTimeout(() => { 
        this.dispatch("goal:scroll", x, y);
      }, 1000);
      document.body.addEventListener('keydown', this.handleKeyDown);
    }
  }
  componentDidUpdate() {
    if (this.props.id === this.props.self_and_ancestor_ids[0]) {
      const [x, y] = this.calculatePosition();
      this.dispatch("goal:scroll", x, y);
    }
  }
  componentWillUnmount() {
    document.body.removeEventListener('keydown', this.handleKeyDown);
  }
  render() {
    let descendants_tree = null;
    if (this.props.descendants) {
      descendants_tree = this.props.descendants.map((c, i) => {
        return <ItemTreeComponent key={c.id} {...c} self_and_ancestor_ids={this.props.self_and_ancestor_ids} h={this.props.h + 1} v={this.props.v + i} />;
      });
    }
    let open = null;
    if (_.some(this.props.self_and_ancestor_ids, (v) => (v === this.props.id || v === this.props.parent_id))) {
      open = "open";
    }
    let current = null;
    if (this.props.id === this.props.self_and_ancestor_ids[0]) {
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
