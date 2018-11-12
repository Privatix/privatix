import { of } from 'rxjs';
import { mergeMap, delay, catchError } from 'rxjs/operators';
import { ofType } from 'redux-observable';

import { LoginActions } from 'app/actions/login';

// TODO: add types
export const statsEpic = (actions$) => {
  return actions$.pipe(
    ofType(LoginActions.Type.STATS_REQUEST),
    delay(3000),
    mergeMap((action) => of({
      type: LoginActions.Type.STATS_RECEIVED,
      payload: {
        propA: 1,
        propB: 2
      }
    }))
  )
};
