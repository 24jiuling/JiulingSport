import { hilog } from '@kit.PerformanceAnalysisKit';
import { StorageKey, AppStorage } from 'appscopecommon';
import auth, { SignInParam, SignInResult, TokenResult } from '@hw-agconnect/auth';
import { LibApi } from 'lib_api';
import { HuaweiLoginRequest, HuaweiLoginResponse } from 'lib_entity';


const LOG_TAG: string = 'LoginViewModel';
const DOMAIN_ID: number = 0x0000;

export class CredentialInfo {
  kind: 'selfBuild' = 'selfBuild';
  accessToken: string = ''; // AGC SDK expects accessToken field
  scopes: string[] = [];
  forceAuthorization: boolean = false;
  state: string = '';
  constructor(kind: 'selfBuild', accessToken: string = '') {
    this.kind = kind;
    this.accessToken = accessToken;
  }
}

export class SignInParamImpl {
  autoCreateUser: boolean = false;
  credentialInfo: CredentialInfo = new CredentialInfo('selfBuild');
  constructor(autoCreateUser: boolean, credentialInfo: CredentialInfo) {
    this.autoCreateUser = autoCreateUser;
    this.credentialInfo = credentialInfo;
  }
}

export class ServerUser {
  id?: number;
  unionId?: string;
  openId?: string;
  username?: string;
  avatar?: string;
  totalWorkouts?: number;
  totalTime?: number;
  totalCalories?: number;
  consecutiveDays?: number;
  lastCheckInDate?: string;
}

export class ServerData {
  token?: string;
  user?: ServerUser;
}

export class LoginResult {
  success: boolean = false;
  agcUser?: AGCUser;
  serverData?: ServerData;
  status?: number;
  body?: string;
  error?: string;
}

// 显式声明 AGC 用户的最小接口以避免把它当作 untyped object
export class AGCUser {
  getUid: () => string = () => '';
}

// 用于描述后端返回结构的显式类，避免使用 any 或对象字面量作为类型
export class RawBackendData {
  token?: string;
  user?: object;
}

export class RawBackendResponse {
  status?: number;
  data?: RawBackendData;
}

export class RawUser {
  id?: number;
  unionId?: string;
  openId?: string;
  username?: string;
  avatar?: string;
  totalWorkouts?: number;
  totalTime?: number;
  totalCalories?: number;
  consecutiveDays?: number;
  lastCheckInDate?: string;
}

export class LoginViewModel {

}
