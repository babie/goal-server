import React from 'react';
import {Component} from 'flumpt';
import _ from 'lodash';
import KeyStringDetector from 'key-string';

class ItemTreeComponent extends Component {
  constructor(props) {
    super(props);
    this.state = {
      newing: false,
      newPosition: null,
      newTitle: "",
      editing: false,
      editTitle: this.props.node.model.title,
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
    let parent = null;

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
          this.setState({newing: true, newPosition: "child", newTitle: ""});
        }
        break;
      case 'N':
        this.setState({newing: true, newPosition: "after", newTitle: ""});
        break;
      case 'Shift+N':
        this.setState({newing: true, newPosition: "before", newTitle: ""});
        break;
      case 'E':
        this.setState({editing: true, editTitle: this.props.node.model.title});
        break;
      case 'Shift+X':
        parent = this.props.parent;
        fetch('/api/goals/' + current.model.id, {
          credentials: 'include',
          method: 'delete',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
        }).then((res) => {
          console.log(res);
          return res.status;
        }).then((status) => {
          current.drop();
          parent.forceUpdate();
        });
        if (current.parent) {
          sibling = current.parent.children[current.model.position - 1] || current.parent.children[current.model.position + 1];
          if (sibling) {
            this.dispatch("self_and_ancestor_ids:update", sibling);
          }
          else {
            this.dispatch("self_and_ancestor_ids:update", current.parent);
          }
        }
        break;
    }
  }

  handleNewTitleBlur(event) {
    if (this.state.newing) {
      this.setState({newing: false, newPosition: null, newTitle: ""});
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
        this.setState({newing: false, newPosition: null, newTitle: ""});
        break;
      case 'Return':
        let parent = null;
        let parent_id = null;
        let position = null;
        switch (this.state.newPosition) {
          case "before":
            parent = this.props.node.parent;
            parent_id = this.props.node.model.parent_id;
            position = this.props.node.model.position;
            break;
          case "after":
            parent = this.props.node.parent;
            parent_id = this.props.node.model.parent_id;
            position = this.props.node.model.position + 1;
            break;
          case "child":
            parent = this.props.node;
            parent_id = this.props.node.model.id;
            position = 0;
            break;
        }
        fetch('/api/goals', {
          credentials: 'include',
          method: 'post',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            goal: {
              title: event.target.value.trim(),
              parent_id: parent_id,
              position: position,
              status: "todo",
            }
          }),
        }).then((res) => {
          return res.json();
        }).then((json) => {
          const newGoal = this.props.tree.parse(json.data);
          parent.children.forEach((c) => {
            if (c.model.position >= newGoal.model.position) {
              c.model.position += 1;
            }
          })
          const node = parent.addChild(newGoal);
          this.dispatch("self_and_ancestor_ids:update", node);
        });
        this.setState({newing: false, newPosition: null, newTitle: ""});
        break;
      default:
        break;
    }
  }

  handleEditTitleBlur(event) {
    if (this.state.editing) {
      this.setState({editiing: false, editTitle: this.props.node.model.title});
    }
  }

  handleEditTitleChange(event) {
    if (this.state.editing) {
      this.setState({editTitle: event.target.value});
    }
  }

  handleEditTitleKeyDown(event) {
    const detector = new KeyStringDetector();
    switch (detector.detect(event)) {
      case 'Esc':
        this.setState({editing: false, editTitle: this.props.node.model.title});
        break;
      case 'Return':
        const current = this.props.node;
        fetch('/api/goals/' + current.model.id, {
          credentials: 'include',
          method: 'put',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            goal: {
              title: event.target.value.trim(),
              body: null,
              parent_id: current.model.parent_id,
              position: current.model.position,
              status: "todo",
            }
          }),
        }).then((res) => {
          return res.json();
        }).then((json) => {
          current.model.title = json.data.title;
          this.dispatch("self_and_ancestor_ids:update", current);
        });
        this.setState({editing: false});
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
    else if (!prevProps.editing && this.state.editing) {
      const input = this.refs.editTitleField;
      input.focus();
      input.setSelectionRange(input.value.length, input.value.length);
    }
    else if (this.props.node.model.id === this.props.self_and_ancestor_ids[0]) {
      this.refs.current.focus();
    }
  }

  render() {
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
    let tree = null;
    if (!_.isEmpty(this.props.node.children)) {
      tree = this.props.node.children.map((n, i) => {
        return (
          <ItemTreeComponent
            key={n.model.id}
            parent={this}
            tree={this.props.tree} 
            node={n}
            self_and_ancestor_ids={this.props.self_and_ancestor_ids}
            h={this.props.h + 1}
            v={this.props.v + i} />
        );
      });
    }
    let newBeforeItem = null;
    let newAfterItem = null;
    let newChildItem = null;
    switch (this.state.newPosition) {
      case "before":
        newBeforeItem = newItem;
        break;
      case "after":
        newAfterItem = newItem;
        break;
      case "child":
        newChildItem = newItem;
        break;
    }
    const descendants_tree = (
      <ul>
        {newChildItem}
        {tree}
      </ul>
    );
    let section = null;
    let editItem = null;
    if (this.state.editing) {
      editItem = (
        <section tabIndex="0">
          <input
            ref="editTitleField"
            className="edit"
            value={this.props.editTitle}
            onBlur={this.handleEditTitleBlur.bind(this)}
            onChange={this.handleEditTitleChange.bind(this)}
            onKeyDown={this.handleEditTitleKeyDown.bind(this)}
          />
        </section>
      );
    }
    else {
      let currentClass = null;
      if (this.props.node.model.id === this.props.self_and_ancestor_ids[0]) {
        currentClass = "current";
      }
      section = (
        <section
          className={currentClass}
          tabIndex="0"
          onFocus={this.handleFocus.bind(this)}
          onClick={this.handleFocus.bind(this)}
          onKeyDown={this.handleKeyDown.bind(this)}
          ref="current">
          {this.props.node.model.title}
        </section>
      );
    }
    let openClass = null;
    if (_.some(this.props.self_and_ancestor_ids, (v) => (v === this.props.node.model.id || v === this.props.node.model.parent_id))) {
      openClass = "open";
    }

    return (
      <div ref="self">
        {newBeforeItem}
        <li className={openClass}>
          {section}
          {editItem}
          {descendants_tree}
        </li>
        {newAfterItem}
      </div>
    );
  }
}

export default ItemTreeComponent;
