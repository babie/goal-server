import React from 'react';
import {Component} from 'flumpt';
import ItemListComponent from './itemlist.js';

class MainComponent extends Component {
  render() {
    return (
      <main>
        <ul className="columns">
          <ItemListComponent {...this.props} />
          <ItemListComponent {...this.props} />
          <ItemListComponent {...this.props} />
        </ul>
      </main>
    );
  }
}

export default MainComponent;
