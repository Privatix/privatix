import { of } from 'rxjs';
import { mergeMap, delay } from 'rxjs/operators';
import { ofType } from 'redux-observable';

import { LoginActions } from 'app/actions/login';

// TODO: add types
export const statsEpic = (actions$: any) => {
  return actions$.pipe(
    ofType(LoginActions.Type.STATS_REQUEST),
    delay(3000),
    mergeMap((action) => of({
      type: LoginActions.Type.STATS_RECEIVED,
      payload: {
        statsData: {
          propA: 1,
          propB: 2
        }
      }
    }))
  )
};
