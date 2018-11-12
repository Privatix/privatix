import React, { Component } from 'react';

export namespace LoginLogs {
  export interface Props {
    authToken?: string;
    statsData?: object;
  }
}

export class LoginLogs extends Component<LoginLogs.Props> {
  constructor(props: StartStopButton.Props, context?: any) {
    super(props, context);
  }

  render() {
    return (
      <div>
        <ul>
          <li>Authenticating... {this.props.authToken && 'done'}</li>
          <li>Getting Stats... {this.props.statsData && 'done'}</li>
        </ul>
      </div>
    )
  }
}

