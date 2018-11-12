import { combineEpics } from 'redux-observable';

import { authEpic } from './authEpic';
import { statsEpic } from './statsEpic';
import { loginStartEpic } from './loginStartEpic';

export const loginEpic = combineEpics(
  authEpic,
  statsEpic,
  loginStartEpic
);
