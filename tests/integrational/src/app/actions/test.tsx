export namespace TestActions {
  export enum Type {
    START_TEST = 'START_LOGIN',
    STOP_TEST = 'STOP_TEST',
  }

  export const startTest = () => ({ type: Type.START_TEST });
  export const stopTest = () => ({ type: Type.STOP_TEST });
}

export type TestActions = Omit<typeof TestActions, 'Type'>;

