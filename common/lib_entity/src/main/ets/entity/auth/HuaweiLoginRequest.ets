/**
 * 华为登录请求实体类
 * 对应后端 /api/auth/huawei-login 接口的请求参数
 */
export class HuaweiLoginRequest {
  /**
   * 华为OAuth授权码（必需）
   * 支持真实授权码或mock:前缀的测试授权码
   */
  authorizationCode: string = '';
  
  constructor(authorizationCode: string = '') {
    this.authorizationCode = authorizationCode;
  }
}