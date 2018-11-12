import { of } from 'rxjs';
import { mergeMap } from 'rxjs/operators';
import { ofType } from 'redux-observable';

import { TestActions, LoginActions } from 'app/actions';

// TODO: add types
export const loginStartEpic = (actions$) => {
  return actions$.pipe(
    ofType(TestActions.Type.START_TEST),
    mergeMap(() => of({
      type: LoginActions.Type.AUTH_START,
      payload: 'my-password'
    }))
  )
};
