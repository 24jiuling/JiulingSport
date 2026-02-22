**华为登录接口（/api/auth/huawei-login）**

- **概要**: 本接口用于华为一键登录，通过华为官方OAuth授权码进行安全验证。**注意：现在只接受authorizationCode参数，提高了系统安全性**。

- **URL**: POST /api/auth/huawei-login
- **Content-Type**: application/json

- **请求体 (JSON)**
  - `authorizationCode` string **必需** — 华为OAuth授权码，支持 `mock:xxx` 形式进行本地测试
  
  说明：现在强制要求提供authorizationCode，不再支持直接传unionId/openId

  示例1（mock 授权码）:
  ```json
  {"authorizationCode":"mock:union123"}
  ```
  
  示例2（真实华为授权码）:
  ```json
  {"authorizationCode":"AQAAAC6IrzIAAABkZjNmMzQ2MS04YjQwLTRhYzMtYjFiYS0wZGU0OWY4YjI4Zjgif3ubAgAAAHNjb3BlAQAAAAAAAAAA"}
  ```

- **成功响应 (200)**
  Content-Type: application/json
  ```json
  {
    "code":200,
    "message":"OK",
    "data":{
      "user":{
        "id":123,
        "username":"华为用户",
        "phone":null,
        "avatar":null,
        "unionId":"union_xxx",
        "openId":"open_xxx",
        "totalWorkouts":0,
        "totalTime":0,
        "totalCalories":0,
        "consecutiveDays":0,
        "lastCheckInDate":"2026-02-20"
      },
      "token":"eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjMiLCJ1bmlvbklkIjoidW5pb25feHh4Iiwib3BlbklkIjoib3Blbl94eHgiLCJpYXQiOjE3NDAxMjM0NTYsImV4cCI6MTc0MDEyNzA1Nn0.signature_here",
      "created":true,
      "expires_in":3600
    }
  }
  ```
  
  **响应字段说明**:
  - `code`: 响应码 (200表示成功)
  - `message`: 响应消息
  - `data`: 响应数据对象
  - `data.user`: 用户信息对象
  - `data.token`: 系统生成的JWT访问令牌
  - `data.created`: 布尔值，true表示新创建用户，false表示已有用户
  - `data.expires_in`: 令牌有效期（秒）

- **错误响应**
  ```json
  {
    "code":400,
    "message":"authorizationCode is required for security verification"
  }
  ```
  
  常见错误码：
  - 400 Bad Request：authorizationCode参数缺失或为空
  - 401 Unauthorized：华为OAuth验证失败
  - 500 Internal Server Error：服务器内部错误

- **安全特性**
  - ✅ 强制通过华为官方OAuth流程验证用户身份
  - ✅ 不再接受前端直接传来的unionId/openId，防止身份伪造
  - ✅ 所有用户标识都通过华为服务器验证后获取
  - ✅ 提高了系统的整体安全性

- **常见错误**
  - 400 Bad Request：authorizationCode参数缺失或为空
  - 401 Unauthorized：华为OAuth验证失败（授权码无效或过期）
  - 500 Internal Server Error：服务端异常（华为服务器连接失败等）
  - 推荐在前端发起请求前打印要发送的 JSON、请求头和响应（包含状态码与返回体）。
  - 在 Windows 下用 `curl.exe`（避免 PowerShell 的 `curl` 别名）测试：
    ```cmd
    curl.exe -H "Content-Type: application/json" --data-binary @payload.json http://localhost:8080/api/auth/huawei-login
    ```
    payload.json 内容示例：
    ```json
    {"authorizationCode":"mock:union123","unionId":"","openId":""}
    ```
  - PowerShell 推荐使用 `Invoke-RestMethod`：
    ```powershell
    $body = @{ authorizationCode='mock:union123'; unionId=''; openId='' } | ConvertTo-Json
    Invoke-RestMethod -Uri http://localhost:8080/api/auth/huawei-login -Method Post -ContentType 'application/json' -Body $body
    ```

- **前端（鸿蒙）调用示例（伪代码，替换为实际平台 API）**
  - ArkTS / fetch 风格：
  ```ts
  const payload = { authorizationCode: 'mock:union123' };
  console.info('login payload', JSON.stringify(payload));

  fetch('http://your.server:8081/api/auth/huawei-login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  })
  .then(async r => {
    const text = await r.text();
    console.info('status', r.status, 'body', text);
    try { return JSON.parse(text); } catch { return text; }
  })
  .catch(err => console.error('network error', err));
  ```

- **日志建议（前端）**
  - 发请求前记录：URL、headers、请求体(JSON)。
  - 收到响应后记录：HTTP 状态码、响应体（JSON/text）。
  - 出错时记录网络/异常信息（包括时间戳）。

- **安全/生产注意**
  - ✅ 生产环境必须使用 HTTPS
  - ✅ 不要在客户端或日志中泄露用户敏感字段或 `clientSecret`
  - ✅ JWT secret 请通过环境变量管理（`JWT_SECRET`），并使用强随机值
  - ✅ refresh token/撤销机制本接口当前未实现，如需长期登录请扩展
  - ✅ 现在强制通过华为OAuth验证，大大提高了账户安全性

- **重要变更说明**
  - ⚠️ **安全升级**：接口现在只接受authorizationCode参数
  - ⚠️ **废弃功能**：不再支持直接传unionId/openId参数
  - ⚠️ **验证流程**：所有用户身份都必须通过华为官方OAuth流程验证
  - 📝 **测试支持**：仍然支持mock:前缀进行本地开发测试

---
文档文件位置：`doc/huawei_login_api.md`，如需我把示例直接生成到鸿蒙项目的调用代码片段，我可以继续生成针对你前端语言的完整调用 + 日志代码。