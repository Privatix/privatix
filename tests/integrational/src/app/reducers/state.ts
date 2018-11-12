import { TestModel, LoginModel } from 'app/models';

export interface RootState {
  readonly test: RootState.TestState;
  readonly login: RootState.LoginState;
  readonly router?: any;
}

export namespace RootState {
  export type TestState = TestModel;
  export type LoginState = LoginModel;
}
