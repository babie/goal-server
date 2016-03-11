import React from 'react';
import {Component} from 'flumpt';

class UserNavComponent extends Component {
  render() {
    return (
      <nav id="user-nav">
        <ul>
          <li>
            <i className="fa fa-user fa-2x fa-fw"></i>
          </li>
          <li>
            <i className="fa fa-search fa-2x fa-fw"></i>
          </li>
          <li>
            <i className="fa fa-folder-o fa-2x fa-fw"></i>
          </li>
          <li>
            <i className="fa fa-paper-plane-o fa-2x fa-fw"></i>
          </li>
          <li>
            <i className="fa fa-gear fa-2x fa-fw"></i>
          </li>
        </ul>
      </nav>
    );
  }
}
export default UserNavComponent;
