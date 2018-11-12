import { combineReducers } from 'redux';
import { RootState } from './state';
import { testReducer } from './test';
import { loginReducer } from './login';

export { RootState };

// NOTE: current type definition of Reducer in 'redux-actions' module
// doesn't go well with redux@4
export const rootReducer = combineReducers<RootState>({
  test: testReducer as any,
  login: loginReducer as any
});
