/**
 * 通用响应基类
 * 所有接口响应都应该继承此类
 */
export class BaseResponse {
  /**
   * 响应码
   */
  code: number = 0;
  
  /**
   * 响应消息
   */
  message: string = '';
  
  constructor() {}
}