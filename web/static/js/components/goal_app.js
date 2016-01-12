import React from 'react';
import {Component} from 'flumpt';

class GoalAppComponent extends Component {
  render() {
    return (
      <div>
        <nav id="system-nav">
          <ul>
            <li>
              <i className="fa fa-flag-checkered fa-2x"></i>
            </li>
            <li>
              <i className="fa fa-sign-out fa-2x"></i>
            </li>
          </ul>
        </nav>
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
                  Title 2-3
                </li>
                <li className="row">
                  Title 2-3
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
        </main>
        <nav id="user-nav">
          <ul>
            <li>
              <i className="fa fa-user fa-2x"></i>
            </li>
            <li>
              <i className="fa fa-search fa-2x"></i>
            </li>
            <li>
              <i className="fa fa-folder-o fa-2x"></i>
            </li>
            <li>
              <i className="fa fa-paper-plane-o fa-2x"></i>
            </li>
            <li>
              <i className="fa fa-gear fa-2x"></i>
            </li>
          </ul>
        </nav>
      </div>
    );
  }
}

export default GoalAppComponent;
