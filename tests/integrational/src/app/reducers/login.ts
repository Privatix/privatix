import { handleActions } from 'redux-actions';
import { RootState } from './state';
import { LoginActions } from 'app/actions/login';
import { LoginModel } from 'app/models';
import { Status } from "app/models/shared/Status";

const initialState: RootState.LoginState = {
  status: Status.NOT_STARTED
};

export const loginReducer = handleActions<RootState.LoginState, LoginModel>(
  {
    [LoginActions.Type.AUTH_START]: (state, action) => {
      return {
        ...state,
        status: Status.IN_PROGRESS
      }
    },
    [LoginActions.Type.AUTH_DONE]: (state, action) => {
      return {
        ...state,
        // status: Status.DONE,
        ...action.payload
        // authToken: action.payload.authToken
      }
    },
    [LoginActions.Type.STATS_REQUEST]: (state, action) => {
      return {
        ...state,
        // status: Status.IN_PROGRESS
      }
    },
    [LoginActions.Type.STATS_RECEIVED]: (state, action) => {
      return {
        ...state,
        status: Status.DONE,
        ...action.payload
        // statsData: action.payload.statsData
      }
    },
    [LoginActions.Type.LOGIN_FAILED]: (state, action) => {
      return {
        ...state,
        status: Status.FAILED,
        ...action.payload
      }
    }
  },
  initialState
);
