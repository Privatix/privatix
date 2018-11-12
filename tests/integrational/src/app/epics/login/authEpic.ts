import { of } from 'rxjs';
import { mergeMap, delay } from 'rxjs/operators';
import { ofType } from 'redux-observable';

import { LoginActions } from 'app/actions/login';

// TODO: add types
export const authEpic = (actions$: any) => {
  return actions$.pipe(
    ofType(LoginActions.Type.AUTH_START),
    delay(2000),
    mergeMap((action) => of({
      type: LoginActions.Type.AUTH_DONE,
      payload: {
        authToken: 'auth-token'
      }
    }, {
      type: LoginActions.Type.STATS_REQUEST,
      payload: {
        authToken: 'auth-token'
      }
    }))
  )
};
