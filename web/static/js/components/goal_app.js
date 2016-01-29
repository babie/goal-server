import React from 'react';
import {Component} from 'flumpt';
import SystemNavComponent from './system_nav.js';
import UserNavComponent from './user_nav.js';
import MainComponent from './main.js';

class GoalAppComponent extends Component {
  handleEvent(event) {
    this.dispatch("goal:keydown", event);
  }

  componentDidMount() {
    document.body.addEventListener('keydown', this);
  }

  componentWillUnmount() {
    document.body.removeEventListener('keydown', this);
  }

  render() {
    return (
      <div id="wrap">
        <SystemNavComponent {...this.props} />
        <MainComponent {...this.props} />
        <UserNavComponent {...this.props} />
      </div>
    );
  }
}

export default GoalAppComponent;
