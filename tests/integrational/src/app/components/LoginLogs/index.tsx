import React, { Component } from 'react';

export namespace LoginLogs {
  export interface Props {
    inProgress: boolean;
    authToken?: string;
    statsData?: object;
  }
}

export class LoginLogs extends Component<LoginLogs.Props> {
  constructor(props: LoginLogs.Props, context?: any) {
    super(props, context);
  }

  render() {
    return (
      <div>
        <ul>
          { this.props.inProgress &&
            <li>Authenticating... {this.props.authToken && 'done'}</li> }
          { this.props.authToken &&
            <li>Getting Stats... {this.props.statsData && 'done'}</li> }
        </ul>
      </div>
    )
  }
}

