import React, { Component } from 'react';

import { TestActions } from 'app/actions/test';
import { StartStopButton } from '../StartStopButton';

export namespace Header {
  export interface Props {
    workingOnTest: boolean;
    startTest: typeof TestActions.startTest;
    stopTest: typeof TestActions.stopTest;
  }
}

export class Header extends Component<Header.Props> {
  constructor(props: Header.Props, context?: any) {
    super(props, context);
  }

  render() {
    return (
      <header>
        { this.props.workingOnTest &&
          <span>Working on test</span> }
        <StartStopButton {...this.props} />
      </header>
    );
  }
}
