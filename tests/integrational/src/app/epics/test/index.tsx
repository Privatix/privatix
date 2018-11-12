import { of } from 'rxjs';
import { mergeMap, delay } from 'rxjs/operators';
import { ofType } from 'redux-observable';

import { TestActions } from 'app/actions/index';

// TODO: add types
export const autoStopEpic = (actions$) => {
  return actions$.pipe(
    ofType(TestActions.Type.START_TEST),
    delay(3000),
    mergeMap(() => of({
      type: TestActions.Type.STOP_TEST
    }))
  )
}
