export class ApiUrls {
  // 调试时默认使用模拟器宿主地址，发布时请替换为线上域名并使用 HTTPS
  static readonly BACKEND_BASE: string = 'http://10.0.2.2:8080';
  static readonly HUAWEI_LOGIN: string = ApiUrls.BACKEND_BASE + '/api/auth/huawei-login';
}
