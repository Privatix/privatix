import { createStore, applyMiddleware } from 'redux';
import { createEpicMiddleware } from 'redux-observable';
import { composeWithDevTools } from 'redux-devtools-extension';

import rootEpic from 'app/epics';
import { RootState, rootReducer } from 'app/reducers';

export function configureStore() {
  const mode = process.env.NODE_ENV;

  const epicMiddleware = createEpicMiddleware();

  if (mode === 'production') {
    const store = createStore(
      rootReducer,
      applyMiddleware(epicMiddleware)
    );

    epicMiddleware.run(rootEpic);

    return store;
  }

  const store = createStore(rootReducer, composeWithDevTools(applyMiddleware(epicMiddleware)));

  epicMiddleware.run(rootEpic);

  return store;
}
