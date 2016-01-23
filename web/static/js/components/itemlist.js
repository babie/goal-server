import React from 'react';
import {Component} from 'flumpt';

class ItemListComponent extends Component {
  render() {
    return (
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
    );
  }
}

export default ItemListComponent;
