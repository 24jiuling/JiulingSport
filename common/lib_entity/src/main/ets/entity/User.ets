/**
 * 用户实体类
 * 统一处理本地状态管理和后端数据交互
 */
export class User {
  // 基础用户信息
  id: number = 0;
  username: string = '';
  phone: string | null = null;
  avatar: string | null = null;
  
  // 应用状态字段
  goalType: string = ''; // '减脂' | '增肌' | '提升耐力'
  isLoggedIn: boolean = false;
  consecutiveDays: number = 0;
  totalWorkouts: number = 0;
  totalTime: number = 0;
  totalCalories: number = 0;
  lastCheckInDate: string | null = null;
  
  // 认证相关字段
  unionId: string = '';     // 用户唯一标识
  openId: string = '';      // 开放平台标识
  authorizationCode: string = '';
  agcUid: string = '';
  
  // JWT令牌
  token: string = '';

  constructor(id: number = 0, username: string = '', avatar: string | null = null) {
    this.id = id;
    this.username = username;
    this.avatar = avatar;
  }
  
  /**
   * 从后端用户对象初始化
   * @param userInfo 后端返回的用户信息
   */
  static fromUserInfo(userInfo: User): User {
    const user = new User(userInfo.id, userInfo.username, userInfo.avatar);
    user.phone = userInfo.phone;
    user.unionId = userInfo.unionId;
    user.openId = userInfo.openId;
    user.totalWorkouts = userInfo.totalWorkouts;
    user.totalTime = userInfo.totalTime;
    user.totalCalories = userInfo.totalCalories;
    user.consecutiveDays = userInfo.consecutiveDays;
    user.lastCheckInDate = userInfo.lastCheckInDate;
    return user;
  }

  /**
   * 转换为后端用户信息格式
   */
  toBackendUser(): UserInfo {
    return {
      id: this.id,
      username: this.username,
      phone: this.phone,
      avatar: this.avatar,
      unionId: this.unionId,
      openId: this.openId,
      totalWorkouts: this.totalWorkouts,
      totalTime: this.totalTime,
      totalCalories: this.totalCalories,
      consecutiveDays: this.consecutiveDays,
      lastCheckInDate: this.lastCheckInDate
    };
  }

}

interface UserInfo {
  id: number;
  username: string;
  phone: string | null;
  avatar: string | null;
  unionId: string;
  openId: string;
  totalWorkouts: number;
  totalTime: number;
  totalCalories: number;
  consecutiveDays: number;
  lastCheckInDate: string | null;
}
