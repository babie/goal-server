import React from 'react';
import {Component} from 'flumpt';
import ItemComponent from './item.js';

class ItemListComponent extends Component {
  render() {
    return (
      <li className="column">
        <ul className="rows">
          <ItemComponent {...this.props} />
          <ItemComponent {...this.props} />
          <ItemComponent {...this.props} />
          <ItemComponent {...this.props} />
          <ItemComponent {...this.props} />
          <ItemComponent {...this.props} />
          <ItemComponent {...this.props} />
          <ItemComponent {...this.props} />
          <ItemComponent {...this.props} />
        </ul>
      </li>
    );
  }
}

export default ItemListComponent;
