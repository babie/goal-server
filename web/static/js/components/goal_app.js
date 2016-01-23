import React from 'react';
import {Component} from 'flumpt';
import SystemNavComponent from './system_nav.js';
import UserNavComponent from './user_nav.js';

class GoalAppComponent extends Component {
  render() {
    return (
      <div id="wrap">
        <SystemNavComponent {...this.props} />
        <main>
          <ul className="columns">
            <li className="column">
              <ul className="rows">
                <li className="row">
                  Title 1-1
                </li>
                <li className="row">
                  Title 1-2
                </li>
                <li className="row">
                  Title 1-3
                </li>
              </ul>
            </li>
            <li className="column center">
              <ul className="rows">
                <li className="row">
                  Title 2-1
                </li>
                <li className="row center">
                  Title 2-2
                </li>
                <li className="row">
                  Title 2-3
                </li>
                <li className="row">
                  Title 2-4
                </li>
                <li className="row">
                  Title 2-5
                </li>
                <li className="row">
                  Title 2-6
                </li>
                <li className="row">
                  Title 2-7
                </li>
              </ul>
            </li>
            <li className="column">
              <ul className="rows">
                <li className="row">
                  Title 3-1
                </li>
                <li className="row">
                  Title 3-2
                </li>
                <li className="row">
                  Title 3-3
                </li>
              </ul>
            </li>
          </ul>
        <UserNavComponent {...this.props} />
        </main>
      </div>
    );
  }
}

export default GoalAppComponent;
