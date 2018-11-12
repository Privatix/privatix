export namespace LoginActions {
  export enum Type {
    AUTH_START = 'AUTH_START',
    AUTH_DONE = 'AUTH_DONE',

    STATS_REQUEST = 'STATS_REQUEST',
    STATS_RECEIVED = 'STATS_RECEIVED',

    LOGIN_FAILED = 'LOGIN_FAILED'
  }

  export const authStart = (password: string) => ({
    type: Type.AUTH_START,
    payload: password
  });
  export const authDone = (token: string) => ({
    type: Type.AUTH_DONE,
    payload: token
  });

  export const statsRequest = (token: string) => ({
    type: Type.STATS_REQUEST,
    payload: token
  });
  export const statsReceived = (data: object) => ({
    type: Type.STATS_RECEIVED,
    payload: data
  });

  export const loginFailed = (error: object) => ({
    type: Type.LOGIN_FAILED,
    payload: error
  });
}

export type LoginActions = Omit<typeof LoginActions, 'Type'>;

