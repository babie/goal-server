import React from 'react';
import {Component} from 'flumpt';

class SystemNavComponent extends Component {
  render() {
    return (
      <nav id="system-nav">
        <ul>
          <li>
            <i className="fa fa-flag-checkered fa-2x fa-fw"></i>
          </li>
          <li>
            <i className="fa fa-sign-out fa-2x fa-fw"></i>
          </li>
        </ul>
      </nav>
    );
  }
}

export default SystemNavComponent;
