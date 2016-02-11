import React from 'react';
import {Component} from 'flumpt';
import _ from 'lodash';
import KeyStringDetector from 'key-string';

class ItemTreeComponent extends Component {
  constructor(props) {
    super(props);
    this.state = {
      newing: false,
      newTitle: "",
    };
  }

  calculatePosition() {
    const width = this.refs.current.offsetWidth;
    const height = this.refs.current.offsetHeight;
    const x = width * this.props.h;
    const y = height * this.props.v;
    return [x, y];
  }

  handleFocus(event) {
    const [x, y] = this.calculatePosition();
    window.scrollTo(x, y);
    if (this.props.node.model.id !== this.props.self_and_ancestor_ids[0]) {
      this.dispatch("self_and_ancestor_ids:update", this.props.node);
    }
  }

  handleKeyDown(event) {
    const current = this.props.node;
    let sibling = null;

    const detector = new KeyStringDetector();
    switch (detector.detect(event)) {
      case 'J':
        if (current.parent) {
          sibling = current.parent.children[current.model.position + 1];
          if (sibling) {
            this.dispatch("self_and_ancestor_ids:update", sibling);
          }
        }
        break;
      case 'K':
        if (current.parent) {
          sibling = current.parent.children[current.model.position - 1];
          if (sibling) {
            this.dispatch("self_and_ancestor_ids:update", sibling);
          }
        }
        break;
      case 'H':
        if (current.parent) {
          this.dispatch("self_and_ancestor_ids:update", current.parent);
        }
        break;
      case 'L':
        const child = current.children[0];
        if (child) {
          this.dispatch("self_and_ancestor_ids:update", child);
        }
        else {
          this.setState({newing: true});
        }
        break;
    }
  }

  handleNewTitleBlur(event) {
    // TODO: think case of body... editing
    if (this.state.newing) {
      this.setState({newing: false, newTitle: ""});
    }
  }

  handleNewTitleChange(event) {
    if (this.state.newing) {
      this.setState({newTitle: event.target.value});
    }
  }

  handleNewTitleKeyDown(event) {
    const detector = new KeyStringDetector();
    switch (detector.detect(event)) {
      case 'Esc':
        this.setState({newing: false, newTitle: ""});
        break;
      case 'Return':
        const newGoal = this.props.tree.parse({
          title: event.target.value.trim(),
          body: "",
          parent_id: this.props.node.model.id
        });
        console.log(newGoal);
        //this.props.node.addChild(newGoal);
        // this.dispatch("goal:create", newGoal);
        this.setState({newing: false, newTitle: ""});
        break;
      default:
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

  componentDidUpdate(prevProps) {
    if (!prevProps.newing && this.state.newing) {
      const input = this.refs.newTitleField;
      input.focus();
    }
    else if (this.props.node.model.id === this.props.self_and_ancestor_ids[0]) {
      this.refs.current.focus();
    }
  }

  render() {
    let descendants_tree = null;
    if (!_.isEmpty(this.props.node.children)) {
      descendants_tree = this.props.node.children.map((n, i) => {
        return <ItemTreeComponent key={n.model.id} tree={this.props.tree} node={n} self_and_ancestor_ids={this.props.self_and_ancestor_ids} h={this.props.h + 1} v={this.props.v + i} />;
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
    let newItem = null;
    if (this.state.newing) {
      newItem = (
        <li className="open">
          <section tabIndex="0">
            <input
              ref="newTitleField"
              className="new"
              value={this.state.newTitle}
              onBlur={this.handleNewTitleBlur.bind(this)}
              onChange={this.handleNewTitleChange.bind(this)}
              onKeyDown={this.handleNewTitleKeyDown.bind(this)}
            />
          </section>
        </li>
      );
    }

    return (
      <li className={openClass}>
        <section className={currentClass} tabIndex="0" onFocus={this.handleFocus.bind(this)} onClick={this.handleFocus.bind(this)} onKeyDown={this.handleKeyDown.bind(this)} ref="current">
          {this.props.node.model.title}
        </section>
        <ul>
          {newItem}
          {descendants_tree}
        </ul>
      </li>
    );
  }
}

export default ItemTreeComponent;
