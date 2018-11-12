import * as React from 'react';
import { connect } from 'react-redux';
import { bindActionCreators, Dispatch } from 'redux';
import { RouteComponentProps } from "react-router";

import { RootState } from 'app/reducers';
import { TestActions, LoginActions } from 'app/actions';
import { Status } from 'app/models/shared/Status';
import { omit } from "app/utils";

import { Header, LoginLogs } from 'app/components';

export namespace App {
  export interface Props extends RouteComponentProps<void> {
    login: RootState.LoginState;
    testActions: TestActions;
    loginActions: LoginActions;
    workingOnTest: boolean;
  }
}

const mapStateToProps = (state: RootState) => ({
  workingOnTest: state.login.status === Status.IN_PROGRESS, // state.test.inProgress,
  login: state.login
});

const mapDispatchToProps = (dispatch: Dispatch) => ({
  testActions: bindActionCreators(omit(TestActions, 'Type'), dispatch),
  loginActions: bindActionCreators(omit(LoginActions, 'Type'), dispatch)
});

@connect(mapStateToProps, mapDispatchToProps)
export class App extends React.Component<App.Props> {
  constructor(props: App.Props, context?: any) {
    super(props, context);
  }

  render() {
    const {
      workingOnTest,
      login,
      testActions,
      // loginActions
    } = this.props;

    return (
      <div>
        <Header startTest={testActions.startTest}
                stopTest={testActions.stopTest}
                workingOnTest={workingOnTest} />
        <LoginLogs
          inProgress={login.status !== Status.NOT_STARTED}
          authToken={login.authToken}
          statsData={login.statsData} />
      </div>
    )
  }
}
