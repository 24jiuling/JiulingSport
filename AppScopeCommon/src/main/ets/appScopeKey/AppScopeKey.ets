/**
 * StorageKey - 统一管理 StorageProp / AppStorage / PersistentStorage 的 key 常量
 * 供各模块通过 import 引用，避免硬编码字符串拼写错误
 *
 * 注意：字符串资源和颜色资源直接使用 $r('app.string.xxx') / $r('app.color.xxx') 调用即可，
 * 不需要在此处维护。此文件只管理跨组件/跨模块的存储 key。
 */
export class StorageKey {
  /** 用户登录状态 */
  static readonly USER_LOGIN_STATE: string = 'userLoginState';
  /** 最近一次打卡日期 (yyyy-MM-dd) */
  static readonly LAST_CHECK_IN_DATE: string = 'lastCheckInDate';
  /** 连续打卡天数 */
  static readonly CONSECUTIVE_DAYS: string = 'consecutiveDays';
  /** 后端鉴权用 token */
  static readonly AUTH_TOKEN: string = 'auth_token';
  /** 序列化的用户信息（JSON） */
  static readonly USER_INFO: string = 'user_info';
}
