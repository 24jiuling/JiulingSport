import { HttpUtils, HttpCallback } from 'lib_http';
import { ApiUrls } from '../service/ApiUrls';
import { HuaweiLoginRequest, HuaweiLoginResponse } from 'lib_entity';

export class LibApi {
  /**
   * 调用华为登录接口
   * @param request 华为登录请求对象
   * @returns Promise<HuaweiLoginResponse> 登录响应
   */
  static async huaweiLogin(request: HuaweiLoginRequest): Promise<HuaweiLoginResponse> {
    return new Promise((resolve, reject) => {
      const callback: HttpCallback = {
        onSuccess: (response) => {
          try {
            const result: HuaweiLoginResponse = JSON.parse(response.result) as HuaweiLoginResponse;
            resolve(result);
          } catch (error) {
            reject(new Error('JSON解析失败: ' + error.message));
          }
        },
        onError: (error) => {
          reject(new Error('网络请求失败: ' + error));
        }
      };
      
      HttpUtils.postJson(ApiUrls.HUAWEI_LOGIN, request, callback);
    });
  }
}