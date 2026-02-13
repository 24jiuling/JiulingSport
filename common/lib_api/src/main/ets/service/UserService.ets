
import { User, Goal, CheckInRecord } from 'lib_entity';

export class UserService {
  private static instance: UserService;
  private currentUser: User | null = null;
  private checkInRecords: CheckInRecord[] = [];
  private nextCheckInId: number = 1;

  private constructor() {}

  public static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService();
    }
    return UserService.instance;
  }

  // --- 手机号登录 ---
  loginWithPhone(phone: string, password: string): User {
    let user = new User(1, '用户_' + phone.substring(7), '');
    user.phone = phone;
    user.isLoggedIn = true;
    user.totalWorkouts = 12;
    user.totalTime = 340;
    user.totalCalories = 1500;
    user.consecutiveDays = 5;
    this.currentUser = user;
    return user;
  }

  // --- 华为账号登录 ---
  loginWithHuaweiAccount(unionID: string, openID: string, authCode: string | undefined): User {
    let user = new User(Date.now(), '华为用户', '');
    user.unionID = unionID;
    user.openID = openID;
    user.authorizationCode = authCode ?? '';
    user.isLoggedIn = true;
    user.totalWorkouts = 0;
    user.totalTime = 0;
    user.totalCalories = 0;
    user.consecutiveDays = 0;
    this.currentUser = user;
    this.notifyLoginStateChanged();
    return user;
  }

  // --- 注册 ---
  register(phone: string, password: string, username: string): User {
    let user = new User(Date.now(), username, '');
    user.phone = phone;
    user.isLoggedIn = true;
    this.currentUser = user;
    return user;
  }

  // --- 获取当前用户 ---
  getCurrentUser(): User | null {
    return this.currentUser;
  }

  // --- 检查登录状态 ---
  isLoggedIn(): boolean {
    if (this.currentUser !== null) {
      return this.currentUser.isLoggedIn;
    }
    return false;
  }

  // --- 登出 ---
  logout(): void {
    if (this.currentUser !== null) {
      this.currentUser.isLoggedIn = false;
    }
    this.currentUser = null;
    this.notifyLoginStateChanged();
  }

  // --- 通知登录状态变化（驱动 UI 响应式更新） ---
  private notifyLoginStateChanged(): void {
    AppStorage.setOrCreate('userLoginState', Date.now());
  }

  // --- 设定健身目标 ---
  setGoal(goalType: string): Goal {
    if (this.currentUser !== null) {
      this.currentUser.goalType = goalType;
    }
    let targetValue: number = 0;
    let unit: string = '';
    if (goalType === '减脂') {
      targetValue = 10;
      unit = 'kg';
    } else if (goalType === '增肌') {
      targetValue = 5;
      unit = 'kg';
    } else {
      targetValue = 30;
      unit = '分钟';
    }
    let goal = new Goal(1, goalType, targetValue, unit);
    goal.description = '当前目标：' + goalType;
    return goal;
  }

  // --- 每日打卡 ---
  checkIn(): CheckInRecord {
    let today = this.getTodayString();
    let record = new CheckInRecord(this.nextCheckInId, this.currentUser !== null ? this.currentUser.id : 0, today);
    this.nextCheckInId = this.nextCheckInId + 1;
    this.checkInRecords.push(record);
    if (this.currentUser !== null) {
      if (this.currentUser.lastCheckInDate === this.getYesterdayString()) {
        this.currentUser.consecutiveDays = this.currentUser.consecutiveDays + 1;
      } else if (this.currentUser.lastCheckInDate !== today) {
        this.currentUser.consecutiveDays = 1;
      }
      this.currentUser.lastCheckInDate = today;
    }
    return record;
  }

  // --- 获取今日日期字符串 ---
  getTodayString(): string {
    let now = new Date();
    let year = now.getFullYear();
    let month = now.getMonth() + 1;
    let day = now.getDate();
    let monthStr = month < 10 ? '0' + month.toString() : month.toString();
    let dayStr = day < 10 ? '0' + day.toString() : day.toString();
    return year.toString() + '-' + monthStr + '-' + dayStr;
  }

  // --- 获取昨日日期字符串 ---
  getYesterdayString(): string {
    let now = new Date();
    now.setDate(now.getDate() - 1);
    let year = now.getFullYear();
    let month = now.getMonth() + 1;
    let day = now.getDate();
    let monthStr = month < 10 ? '0' + month.toString() : month.toString();
    let dayStr = day < 10 ? '0' + day.toString() : day.toString();
    return year.toString() + '-' + monthStr + '-' + dayStr;
  }

  // --- 获取打卡记录 ---
  getCheckInRecords(): CheckInRecord[] {
    return this.checkInRecords;
  }

  // --- 今日是否已打卡 ---
  isTodayCheckedIn(): boolean {
    if (this.currentUser === null) {
      return false;
    }
    return this.currentUser.lastCheckInDate === this.getTodayString();
  }

  // --- 更新用户统计数据 ---
  updateStats(duration: number, calories: number): void {
    if (this.currentUser !== null) {
      this.currentUser.totalWorkouts = this.currentUser.totalWorkouts + 1;
      this.currentUser.totalTime = this.currentUser.totalTime + duration;
      this.currentUser.totalCalories = this.currentUser.totalCalories + calories;
    }
  }
}
