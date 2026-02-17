import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { UserService } from 'lib_api';
import auth, { AuthUser } from '@hw-agconnect/auth';

const LOG_TAG: string = 'SilentLoginHelper';
const DOMAIN_ID: number = 0x0000;

/**
 * 静默登录帮助类
 * 仅通过 AGC Auth 缓存恢复登录态，不主动调用 Account Kit
 */
export class SilentLoginHelper {
  static async trySilentLogin(): Promise<boolean> {
    hilog.info(DOMAIN_ID, LOG_TAG, '[DEBUG] trySilentLogin() called.');
    const userService: UserService = UserService.getInstance();
    if (userService.isLoggedIn()) {
      hilog.info(DOMAIN_ID, LOG_TAG, '[DEBUG] User already logged in, skip silent login.');
      return true;
    }

    // 仅尝试 AGC Auth 的 getCurrentUser，检查是否有缓存的登录态
    try {
      const cachedUser: AuthUser | null = await auth.getCurrentUser();
      if (cachedUser !== null && cachedUser !== undefined) {
        hilog.info(DOMAIN_ID, LOG_TAG,
          `[DEBUG] AGC Auth cached user found! uid: ${cachedUser.getUid()}, displayName: ${cachedUser.getDisplayName()}`);
        userService.loginWithHuaweiAccount(cachedUser.getUid(), cachedUser.getUid(), '');
        return true;
      }
      hilog.info(DOMAIN_ID, LOG_TAG, '[DEBUG] No AGC cached user, silent login skipped.');
    } catch (err) {
      const e = err as BusinessError;
      hilog.info(DOMAIN_ID, LOG_TAG,
        `[DEBUG] getCurrentUser failed: code=${e.code}, msg=${e.message}`);
    }
    return false;
  }
}