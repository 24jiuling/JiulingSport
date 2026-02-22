import http from '@ohos.net.http';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';

/**
 * HTTP请求配置接口
 */
export interface HttpConfig {
  method?: http.RequestMethod;
  header?: Record<string, string>;
  readTimeout?: number;
  connectTimeout?: number;
  extraData?: string | Object;
}

/**
 * HTTP响应接口
 */
export interface HttpResponse {
  result: string;
  responseCode: number;
  header: Object;
}

/**
 * 下载配置接口
 */
export interface DownloadConfig {
  filePath: string;
  header?: Record<string, string>;
}

/**
 * 上传配置接口
 */
export interface UploadConfig {
  filePath: string;
  fieldName?: string;
  header?: Record<string, string>;
  formData?: Record<string, string>;
}

/**
 * 文件表单数据接口
 */
export interface FileFormData {
  filename: string | undefined;
  type: string;
  data: ArrayBuffer;
}

/**
 * HTTP回调接口
 */
export interface HttpCallback {
  onSuccess: (data: HttpResponse) => void;
  onError: (error: string) => void;
}

/**
 * 下载回调接口
 */
export interface DownloadCallback {
  onProgress?: (received: number, total: number) => void;
  onSuccess: (filePath: string) => void;
  onError: (error: string) => void;
}

/**
 * HTTP工具类 - 完全类型安全版本
 */
export class HttpUtils {
  private static readonly TAG: string = 'HttpUtils';
  private static readonly EMPTY_HEADER: Record<string, string> = {};

  /**
   * GET请求
   */
  static async get(url: string, callback: HttpCallback): Promise<void>;
  static async get(url: string, params: Record<string, string>, callback: HttpCallback): Promise<void>;
  static async get(url: string, paramsOrCallback: Record<string, string> | HttpCallback, callback?: HttpCallback): Promise<void> {
    let params: Record<string, string> = {};
    let actualCallback: HttpCallback;

    if (callback) {
      params = paramsOrCallback as Record<string, string>;
      actualCallback = callback;
    } else {
      actualCallback = paramsOrCallback as HttpCallback;
    }

    const fullUrl: string = HttpUtils.buildUrlWithParams(url, params);

    try {
      const httpRequest: http.HttpRequest = http.createHttp();

      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.GET,
        readTimeout: 10000,
        connectTimeout: 10000
      };

      const response = await httpRequest.request(fullUrl, options);

      if (response.responseCode === http.ResponseCode.OK) {
        const result: string = HttpUtils.convertResultToString(response.result);
        actualCallback.onSuccess({
          result: result,
          responseCode: response.responseCode,
          header: response.header
        });
      } else {
        const error: string = `HTTP错误: ${response.responseCode}`;
        actualCallback.onError(error);
      }

      httpRequest.destroy();
    } catch (error) {
      const err = error as BusinessError;
      actualCallback.onError(`请求失败: ${err.message}`);
    }
  }

  /**
   * POST请求 - 表单数据
   */
  static async post(url: string, data: Record<string, string>, callback: HttpCallback): Promise<void> {
    try {
      const httpRequest: http.HttpRequest = http.createHttp();

      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        extraData: HttpUtils.buildFormData(data),
        readTimeout: 10000,
        connectTimeout: 10000
      };

      const response = await httpRequest.request(url, options);

      if (response.responseCode === http.ResponseCode.OK) {
        const result: string = HttpUtils.convertResultToString(response.result);
        callback.onSuccess({
          result: result,
          responseCode: response.responseCode,
          header: response.header
        });
      } else {
        const error: string = `HTTP错误: ${response.responseCode}`;
        callback.onError(error);
      }

      httpRequest.destroy();
    } catch (error) {
      const err = error as BusinessError;
      callback.onError(`请求失败: ${err.message}`);
    }
  }

  /**
   * POST请求 - JSON数据
   */
  static async postJson(url: string, data: Object, callback: HttpCallback): Promise<void> {
    try {
      const httpRequest: http.HttpRequest = http.createHttp();

      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(data),
        readTimeout: 10000,
        connectTimeout: 10000
      };

      const response = await httpRequest.request(url, options);

      if (response.responseCode === http.ResponseCode.OK) {
        const result: string = HttpUtils.convertResultToString(response.result);
        callback.onSuccess({
          result: result,
          responseCode: response.responseCode,
          header: response.header
        });
      } else {
        const error: string = `HTTP错误: ${response.responseCode}`;
        callback.onError(error);
      }

      httpRequest.destroy();
    } catch (error) {
      const err = error as BusinessError;
      callback.onError(`请求失败: ${err.message}`);
    }
  }

  /**
   * 自定义请求
   */
  static async request(url: string, config: HttpConfig, callback: HttpCallback): Promise<void> {
    try {
      const httpRequest: http.HttpRequest = http.createHttp();

      const header: Record<string, string> = config.header || HttpUtils.EMPTY_HEADER;

      const options: http.HttpRequestOptions = {
        method: config.method || http.RequestMethod.GET,
        header: header,
        readTimeout: config.readTimeout || 10000,
        connectTimeout: config.connectTimeout || 10000,
        extraData: config.extraData
      };

      const response = await httpRequest.request(url, options);

      if (response.responseCode === http.ResponseCode.OK) {
        const result: string = HttpUtils.convertResultToString(response.result);
        callback.onSuccess({
          result: result,
          responseCode: response.responseCode,
          header: response.header
        });
      } else {
        const error: string = `HTTP错误: ${response.responseCode}`;
        callback.onError(error);
      }

      httpRequest.destroy();
    } catch (error) {
      const err = error as BusinessError;
      callback.onError(`请求失败: ${err.message}`);
    }
  }

  /**
   * 文件下载
   */
  static async download(url: string, config: DownloadConfig, callback: DownloadCallback): Promise<void> {
    try {
      const httpRequest: http.HttpRequest = http.createHttp();

      const header: Record<string, string> = config.header || HttpUtils.EMPTY_HEADER;

      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.GET,
        header: header,
        readTimeout: 60000,
        connectTimeout: 30000
      };

      const response = await httpRequest.request(url, options);

      if (response.responseCode === http.ResponseCode.OK) {
        // 创建文件目录
        const dirPath: string = config.filePath.substring(0, config.filePath.lastIndexOf('/'));
        await HttpUtils.ensureDirectory(dirPath);

        // 写入文件
        const file = fs.openSync(config.filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
        const data = response.result as ArrayBuffer;

        if (data) {
          fs.writeSync(file.fd, data);
          fs.closeSync(file);
          callback.onSuccess(config.filePath);
        } else {
          callback.onError('下载数据为空');
        }
      } else {
        callback.onError(`下载失败: ${response.responseCode}`);
      }

      httpRequest.destroy();
    } catch (error) {
      const err = error as BusinessError;
      callback.onError(`下载失败: ${err.message}`);
    }
  }

  /**
   * 文件上传
   */
  static async upload(url: string, config: UploadConfig, callback: HttpCallback): Promise<void> {
    try {
      // 检查文件是否存在
      let isExist = false;
      try {
        isExist = fs.accessSync(config.filePath);
      } catch (e) {
        isExist = false;
      }

      if (!isExist) {
        callback.onError('文件不存在');
        return;
      }

      // 读取文件数据
      const file = fs.openSync(config.filePath, fs.OpenMode.READ_ONLY);
      const fileStat = fs.statSync(file.fd);
      const fileData = new ArrayBuffer(fileStat.size);
      fs.readSync(file.fd, fileData);
      fs.closeSync(file);

      // 修复：避免在对象字面量中使用计算属性名
      const formData: Record<string, Object> = {};
      const fieldName: string = config.fieldName || 'file';

      // 修复：使用明确的类型而不是未类型化的对象字面量
      const fileFormData: FileFormData = {
        filename: config.filePath.split('/').pop(),
        type: 'application/octet-stream',
        data: fileData
      };

      // 使用动态赋值而不是计算属性名
      formData[fieldName] = fileFormData;

      // 添加其他表单数据 - 修复：避免解构赋值
      if (config.formData) {
        const entries = Object.entries(config.formData);
        for (let i = 0; i < entries.length; i++) {
          const entry = entries[i];
          const key = entry[0];
          const value = entry[1];
          formData[key] = value;
        }
      }

      const httpRequest: http.HttpRequest = http.createHttp();

      const baseHeader: Record<string, string> = {
        'Content-Type': 'multipart/form-data'
      };

      // 修复：避免使用对象展开运算符，手动合并header
      const finalHeader: Record<string, string> = HttpUtils.mergeHeaders(baseHeader, config.header);

      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: finalHeader,
        extraData: formData,
        readTimeout: 60000,
        connectTimeout: 30000
      };

      const response = await httpRequest.request(url, options);

      if (response.responseCode === http.ResponseCode.OK) {
        const result: string = HttpUtils.convertResultToString(response.result);
        callback.onSuccess({
          result: result,
          responseCode: response.responseCode,
          header: response.header
        });
      } else {
        callback.onError(`上传失败: ${response.responseCode}`);
      }

      httpRequest.destroy();
    } catch (error) {
      const err = error as BusinessError;
      callback.onError(`上传失败: ${err.message}`);
    }
  }

  /**
   * 构建带参数的URL - 使用 Record 类型，避免解构赋值，替代URLSearchParams
   */
  private static buildUrlWithParams(url: string, params: Record<string, string>): string {
    if (!params || Object.keys(params).length === 0) {
      return url;
    }

    // 修复：手动构建查询字符串，替代URLSearchParams
    const paramPairs: string[] = [];
    const entries = Object.entries(params);

    for (let i = 0; i < entries.length; i++) {
      const entry = entries[i];
      const key = entry[0];
      const value = entry[1];
      if (value !== null && value !== undefined) {
        // URL编码参数
        const encodedKey = HttpUtils.encodeURIComponent(key);
        const encodedValue = HttpUtils.encodeURIComponent(value);
        paramPairs.push(`${encodedKey}=${encodedValue}`);
      }
    }

    const paramString = paramPairs.join('&');
    if (!paramString) {
      return url;
    }

    const separator: string = url.includes('?') ? '&' : '?';
    return `${url}${separator}${paramString}`;
  }

  /**
   * 构建表单数据 - 使用 Record 类型，避免解构赋值，替代URLSearchParams
   */
  private static buildFormData(data: Record<string, string>): string {
    // 修复：手动构建表单数据，替代URLSearchParams
    const formPairs: string[] = [];
    const entries = Object.entries(data);

    for (let i = 0; i < entries.length; i++) {
      const entry = entries[i];
      const key = entry[0];
      const value = entry[1];
      if (value !== null && value !== undefined) {
        // URL编码表单数据
        const encodedKey = HttpUtils.encodeURIComponent(key);
        const encodedValue = HttpUtils.encodeURIComponent(value);
        formPairs.push(`${encodedKey}=${encodedValue}`);
      }
    }
    return formPairs.join('&');
  }

  /**
   * URL编码组件 - 替代encodeURIComponent
   */
  private static encodeURIComponent(str: string): string {
    // 简单的URL编码实现
    return encodeURIComponent(str)
      .replace(/%20/g, '+')
      .replace(/%2B/g, '+')
      .replace(/%2F/g, '/')
      .replace(/%3F/g, '?')
      .replace(/%3D/g, '=')
      .replace(/%26/g, '&')
      .replace(/%23/g, '#');
  }

  /**
   * 确保目录存在
   */
  private static async ensureDirectory(dirPath: string): Promise<void> {
    try {
      let isExist = false;
      try {
        isExist = fs.accessSync(dirPath);
      } catch (e) {
        isExist = false;
      }

      if (!isExist) {
        fs.mkdirSync(dirPath, true);
      }
    } catch (error) {
      console.error(`创建目录失败: ${dirPath}`, error);
    }
  }

  /**
   * 转换响应结果为字符串
   */
  private static convertResultToString(result: Object | string | ArrayBuffer): string {
    if (typeof result === 'string') {
      return result;
    } else if (result instanceof ArrayBuffer) {
      // 将ArrayBuffer转换为字符串
      const uint8Array = new Uint8Array(result);
      let str = '';
      for (let i = 0; i < uint8Array.length; i++) {
        str += String.fromCharCode(uint8Array[i]);
      }
      return str;
    } else {
      return JSON.stringify(result);
    }
  }

  /**
   * 合并headers - 替代对象展开运算符
   */
  private static mergeHeaders(baseHeader: Record<string, string>, customHeader?: Record<string, string>): Record<string, string> {
    const result: Record<string, string> = {};

    // 先添加baseHeader的所有属性
    const baseEntries = Object.entries(baseHeader);
    for (let i = 0; i < baseEntries.length; i++) {
      const entry = baseEntries[i];
      const key = entry[0];
      const value = entry[1];
      result[key] = value;
    }

    // 再添加customHeader的所有属性（覆盖baseHeader中的同名属性）
    if (customHeader) {
      const customEntries = Object.entries(customHeader);
      for (let i = 0; i < customEntries.length; i++) {
        const entry = customEntries[i];
        const key = entry[0];
        const value = entry[1];
        result[key] = value;
      }
    }

    return result;
  }
}

/**
 * JSON工具类 - 完全类型安全版本，避免使用 in 操作符
 */
export class JsonUtils {
  /**
   * 解析JSON字符串
   */
  static parse<T>(jsonString: string): T | null {
    try {
      return JSON.parse(jsonString) as T;
    } catch (error) {
      console.error('JSON解析失败:', error);
      return null;
    }
  }

  /**
   * 对象转JSON字符串
   */
  static stringify(obj: Object): string {
    try {
      return JSON.stringify(obj);
    } catch (error) {
      console.error('JSON序列化失败:', error);
      return '{}';
    }
  }

  /**
   * 安全获取JSON字符串值 - 避免使用any类型和in操作符
   */
  static getSafeString(obj: Object, key: string, defaultValue: string = ''): string {
    if (obj && typeof obj === 'object') {
      const recordObj = obj as Record<string, Object>;
      // 修复：避免使用 in 操作符，使用 Object.keys 和 includes
      const keys = Object.keys(recordObj);
      if (keys.includes(key)) {
        const value = recordObj[key];
        if (value !== null && value !== undefined) {
          return value.toString();
        }
      }
    }
    return defaultValue;
  }

  /**
   * 安全获取JSON数值 - 避免使用any类型和in操作符
   */
  static getSafeNumber(obj: Object, key: string, defaultValue: number = 0): number {
    if (obj && typeof obj === 'object') {
      const recordObj = obj as Record<string, Object>;
      // 修复：避免使用 in 操作符，使用 Object.keys 和 includes
      const keys = Object.keys(recordObj);
      if (keys.includes(key)) {
        const value = recordObj[key];
        if (value !== null && value !== undefined) {
          const num = Number(value);
          return isNaN(num) ? defaultValue : num;
        }
      }
    }
    return defaultValue;
  }

  /**
   * 安全获取JSON布尔值 - 避免使用any类型和in操作符
   */
  static getSafeBoolean(obj: Object, key: string, defaultValue: boolean = false): boolean {
    if (obj && typeof obj === 'object') {
      const recordObj = obj as Record<string, Object>;
      // 修复：避免使用 in 操作符，使用 Object.keys 和 includes
      const keys = Object.keys(recordObj);
      if (keys.includes(key)) {
        const value = recordObj[key];
        if (value !== null && value !== undefined) {
          return Boolean(value);
        }
      }
    }
    return defaultValue;
  }

  /**
   * 检查对象是否包含指定键 - 类型安全的方法，避免使用in操作符
   */
  static hasKey(obj: Object, key: string): boolean {
    if (obj && typeof obj === 'object') {
      const recordObj = obj as Record<string, Object>;
      // 修复：避免使用 in 操作符，使用 Object.keys 和 includes
      const keys = Object.keys(recordObj);
      return keys.includes(key);
    }
    return false;
  }

  /**
   * 获取对象的所有键 - 类型安全的方法
   */
  static getKeys(obj: Object): string[] {
    if (obj && typeof obj === 'object') {
      return Object.keys(obj);
    }
    return [];
  }

  /**
   * 深度复制对象 - 类型安全的方法
   */
  static deepClone<T>(obj: T): T | null {
    try {
      return JSON.parse(JSON.stringify(obj)) as T;
    } catch (error) {
      console.error('深度复制失败:', error);
      return null;
    }
  }

  /**
   * 获取对象的值，如果不存在则返回默认值 - 通用方法
   */
  static getValue<T>(obj: Object, key: string, defaultValue: T): T {
    if (obj && typeof obj === 'object') {
      const recordObj = obj as Record<string, Object>;
      // 修复：避免使用 in 操作符，使用 Object.keys 和 includes
      const keys = Object.keys(recordObj);
      if (keys.includes(key)) {
        const value = recordObj[key];
        if (value !== null && value !== undefined) {
          return value as T;
        }
      }
    }
    return defaultValue;
  }
}