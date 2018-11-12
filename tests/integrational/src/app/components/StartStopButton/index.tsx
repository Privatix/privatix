import React, { Component } from 'react';

import { TestActions } from "app/actions/test";

export namespace StartStopButton {
  export interface Props {
    workingOnTest: boolean;
    startTest: typeof TestActions.startTest;
    stopTest: typeof TestActions.stopTest;
  }
}

export class StartStopButton extends Component<StartStopButton.Props> {
  constructor(props: StartStopButton.Props, context?: any) {
    super(props, context);
    this.startStop = this.startStop.bind(this);
  }

  startStop() {
    if (this.props.workingOnTest) {
      this.props.stopTest();
    } else {
      this.props.startTest();
    }
  }

  render() {
    let label = this.props.workingOnTest
      ? 'Stop Test'
      : 'Start Test';

    return (
      <button onClick={this.startStop}>
        {label}
      </button>
    )
  }
}

