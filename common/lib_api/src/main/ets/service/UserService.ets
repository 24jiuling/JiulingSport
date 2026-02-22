
import { User, Goal, CheckInRecord, HuaweiLoginRequest, HuaweiLoginResponse } from 'lib_entity';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { StorageKey, AppStorage } from 'appscopecommon';
import auth, { SignInParam, SignInResult } from '@hw-agconnect/auth';
import { BusinessError } from '@kit.BasicServicesKit';

import { RouterKey, RouterManager } from 'lib_router';
import { LibApi } from '../api/LibApi';


const LOG_TAG: string = 'UserService';
const DOMAIN_ID: number = 0x0000;

export class UserService {
  private static instance: UserService;
  private currentUser: User | null = null;
  private checkInRecords: CheckInRecord[] = [];
  private nextCheckInId: number = 1;
  private router: RouterManager = RouterManager.getInstance();

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
    // 从持久化恢复打卡状态
    this.restoreCheckInState();
    return user;
  }

  // --- 华为账号登录 ---
  loginWithHuaweiAccount(unionId: string, openId: string, authCode: string | undefined): User {
    hilog.info(DOMAIN_ID, LOG_TAG,
      `[DEBUG] loginWithHuaweiAccount called - unionId: ${unionId}, openId: ${openId}, hasAuthCode: ${authCode !== undefined && authCode !== ''}`);
    let user = new User(Date.now(), '华为用户', '');
    this.saveUserInfo(user, unionId, openId, authCode);
    this.currentUser = user;
    // this.backLogin(authCode);
    // 从持久化恢复打卡状态
    this.restoreCheckInState();
    this.notifyLoginStateChanged();
    hilog.info(DOMAIN_ID, LOG_TAG,
      `[DEBUG] loginWithHuaweiAccount completed - userId: ${user.id}, isLoggedIn: ${user.isLoggedIn},token: ${user.authorizationCode}`);
    return user;
  }

  // --- 获取当前用户 ---
  getCurrentUser(): User | null {
    return this.currentUser;
  }

  // --- 保存用户信息 ---
  saveUserInfo(user: User, unionId: string, openId: string, authCode: string | undefined): void {
    user.unionId = unionId;
    user.openId = openId;
    user.authorizationCode = authCode ?? '';
    user.isLoggedIn = true;
    user.totalWorkouts = 0;
    user.totalTime = 0;
    user.totalCalories = 0;
    user.consecutiveDays = 0;
  }

  // --- 检查登录状态 ---
  isLoggedIn(): boolean {
    if (this.currentUser !== null) {
      return this.currentUser.isLoggedIn;
    }
    return false;
  }

  // --- 登录 ---
  login(): void {
    auth.signIn({
      autoCreateUser: true,
      credentialInfo: {
        kind: 'hwid'
      }
    } as SignInParam).then((signInResult: SignInResult) => {
      const user = signInResult.getUser();
      hilog.info(DOMAIN_ID, LOG_TAG,
        `[DEBUG] signIn success! uid: ${user.getUid()}, displayName: ${user.getDisplayName()}`);

      user.getToken(true).then((tokenResult) => {
        const token = tokenResult.getString();
        // 登录成功，更新本地用户服务
        this.loginWithHuaweiAccount(user.getUid(), user.getUid(),token);
        hilog.info(DOMAIN_ID, LOG_TAG,
          `[DEBUG] accessToken: ${tokenResult.getString()}`);
      }).catch((err: Error) => {
        hilog.error(DOMAIN_ID, LOG_TAG,
          `[DEBUG] getToken error: ${err.message}`);
      });
      hilog.info(DOMAIN_ID, LOG_TAG, '[DEBUG] loginWithHuaweiAccount completed, navigating to GOAL_SETTING.');
      this.router.replace(RouterKey.GOAL_SETTING);
    }).catch((error: BusinessError) => {
      hilog.error(DOMAIN_ID, LOG_TAG,
        `[DEBUG] signIn error, Code: ${error.code}, Message: ${error.message}`);
      // 用户取消不提示
      if (error.code !== 2) {
        AlertDialog.show({ message: `华为账号登录失败(${error.code})：${error.message}` });
      }
    });
  }

  /**
   * 后端华为登录校验
   * @param authorizationCode 华为授权码
   * @returns Promise<HuaweiLoginResponse> 登录响应结果
   */
  async backLogin(authorizationCode: string | undefined): Promise<HuaweiLoginResponse> {
    try {
      // 参数校验
      if (!authorizationCode || authorizationCode.trim() === '') {
        throw new Error('授权码不能为空');
      }
      
      // 构造请求对象
      const request: HuaweiLoginRequest = new HuaweiLoginRequest(authorizationCode);
      
      // 调用后端接口
      const response: HuaweiLoginResponse = await LibApi.huaweiLogin(request);
      
      // 响应结果校验
      if (!response) {
        throw new Error('后端响应为空');
      }
      
      if (response.code === 200 && response.data) {
        // 登录成功，保存用户信息和token
        const userFromBackend = User.fromUserInfo(response.data.user);
        this.currentUser = userFromBackend;
        this.saveUserInfo(userFromBackend, userFromBackend.unionId, userFromBackend.openId, authorizationCode);

        this.currentUser = response.data.user;
        hilog.info(DOMAIN_ID, LOG_TAG, '[DEBUG] 后端登录校验成功');
        hilog.info(DOMAIN_ID, LOG_TAG, `[DEBUG] 用户ID: ${this.currentUser.id}`);
        hilog.info(DOMAIN_ID, LOG_TAG, `[DEBUG] 用户名: ${this.currentUser.username}`);
        hilog.info(DOMAIN_ID, LOG_TAG, `[DEBUG] 登录状态: ${this.currentUser.isLoggedIn}`);

        return response;
      } else {
        // 登录失败
        const errorMsg: string = response.message || '登录失败';
        hilog.error(DOMAIN_ID, LOG_TAG, `[ERROR] 后端登录校验失败: ${errorMsg}`);
        throw new Error(errorMsg);
      }
    } catch (error) {
      hilog.error(DOMAIN_ID, LOG_TAG, `[ERROR] 后端登录校验异常: ${error.message}`);
      throw new Error(error.message || '未知错误');
    }
  }

  // --- 登出 ---
  logout(): void {
    auth.signOut().then(() => {
      // 登出成功
      hilog.info(DOMAIN_ID, LOG_TAG, '[DEBUG] logout success');
    }).catch((error: BusinessError) => {
      // 登出失败
      hilog.error(DOMAIN_ID, LOG_TAG, '[DEBUG] logout failed - error: %{public}s', error.message);
    });
    if (this.currentUser !== null) {
      this.currentUser.isLoggedIn = false;
    }
    this.currentUser = null;
    this.notifyLoginStateChanged();
  }

  // --- 通知登录状态变化（驱动 UI 响应式更新） ---
  private notifyLoginStateChanged(): void {
    AppStorage.setOrCreate(StorageKey.USER_LOGIN_STATE, Date.now());
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
    hilog.info(DOMAIN_ID, LOG_TAG, '[DEBUG] checkIn called - today: %{public}s, lastCheckInDate: %{public}s',
      today, this.currentUser !== null ? this.currentUser.lastCheckInDate : 'null');
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
      hilog.info(DOMAIN_ID, LOG_TAG, '[DEBUG] checkIn done - lastCheckInDate: %{public}s, consecutiveDays: %{public}d',
        this.currentUser.lastCheckInDate, this.currentUser.consecutiveDays);
      // 持久化保存打卡日期和连续天数
      this.persistCheckInState();
    }
    // 通知UI刷新（驱动 @StorageProp 监听）
    this.notifyLoginStateChanged();
    return record;
  }

  // --- 持久化保存打卡状态 ---
  private persistCheckInState(): void {
    if (this.currentUser !== null) {
      AppStorage.setOrCreate(StorageKey.LAST_CHECK_IN_DATE, this.currentUser.lastCheckInDate);
      AppStorage.setOrCreate(StorageKey.CONSECUTIVE_DAYS, this.currentUser.consecutiveDays);
      hilog.info(DOMAIN_ID, LOG_TAG, '[DEBUG] persistCheckInState - saved lastCheckInDate: %{public}s, consecutiveDays: %{public}d',
        this.currentUser.lastCheckInDate, this.currentUser.consecutiveDays);
    }
  }

  // --- 从持久化存储恢复打卡状态 ---
  restoreCheckInState(): void {
    if (this.currentUser === null) {
      hilog.warn(DOMAIN_ID, LOG_TAG, '[DEBUG] restoreCheckInState - currentUser is null, skip');
      return;
    }
    let savedDate: string = AppStorage.get<string>(StorageKey.LAST_CHECK_IN_DATE) ?? '';
    let savedDays: number = AppStorage.get<number>(StorageKey.CONSECUTIVE_DAYS) ?? 0;
    hilog.info(DOMAIN_ID, LOG_TAG, '[DEBUG] restoreCheckInState - savedDate: %{public}s, savedDays: %{public}d',
      savedDate, savedDays);
    if (savedDate.length > 0) {
      this.currentUser.lastCheckInDate = savedDate;
      this.currentUser.consecutiveDays = savedDays;
      hilog.info(DOMAIN_ID, LOG_TAG, '[DEBUG] restoreCheckInState - restored successfully');
    }
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
