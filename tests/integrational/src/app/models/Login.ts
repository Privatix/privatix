import { Status } from './shared/Status';

export interface LoginModel {
  status: Status;
  authPassword?: string;
  authToken?: string;
  statsData?: object;
  error?: object;
}

