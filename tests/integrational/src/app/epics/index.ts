import { combineEpics } from 'redux-observable';

// import { autoStopEpic } from './test';
import { loginEpic } from 'app/epics/login';


export default combineEpics(
  // autoStopEpic,
  loginEpic
);
