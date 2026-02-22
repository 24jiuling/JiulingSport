/**
 * 华为登录响应数据接口
 */
export interface HuaweiLoginData {
  /**
   * 用户信息
   */
  user: import("../User").User;
  
  /**
   * JWT访问令牌
   */
  token: string;
  
  /**
   * 是否为新创建用户
   */
  created: boolean;
  
  /**
   * 令牌有效期（秒）
   */
  expires_in: number;
}