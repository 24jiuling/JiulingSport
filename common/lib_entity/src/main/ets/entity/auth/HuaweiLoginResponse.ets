import { BaseResponse } from "../BaseResponse";
import { HuaweiLoginData } from "./HuaweiLoginData";

/**
 * 华为登录响应实体类
 * 对应后端 /api/auth/huawei-login 接口的响应数据结构
 */
export class HuaweiLoginResponse extends BaseResponse {
  
  /**
   * 响应数据
   */
  data: HuaweiLoginData | null = null;
  
  constructor() {
    super();
  }
}