import { handleActions } from 'redux-actions';
import { RootState } from './state';
import { TestActions } from 'app/actions/test';
import { TestModel } from 'app/models';

const initialState: RootState.TestState = {
  inProgress: false
};

export const testReducer = handleActions<RootState.TestState, TestModel>(
  {
    [TestActions.Type.START_TEST]: (state, action) => {
      return {
        inProgress: true
      }
    },
    [TestActions.Type.STOP_TEST]: (state, action) => {
      return {
        inProgress: false
      }
    }
  },
  initialState
);
