import { AbilityConstant, bundleManager, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import auth from '@hw-agconnect/auth';
import { buffer } from '@kit.ArkTS';
import { VideoSyncService } from 'lib_api';
import { StorageKey } from 'appscopecommon';
import { authentication } from '@kit.AccountKit';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }

    // 初始化持久化存储（打卡日期、连续天数）
    PersistentStorage.persistProp(StorageKey.LAST_CHECK_IN_DATE, '');
    PersistentStorage.persistProp(StorageKey.CONSECUTIVE_DAYS, 0);
    hilog.info(DOMAIN, 'testTag', 'PersistentStorage initialized - lastCheckInDate: %{public}s, consecutiveDays: %{public}d',
      AppStorage.get<string>(StorageKey.LAST_CHECK_IN_DATE) ?? '', AppStorage.get<number>(StorageKey.CONSECUTIVE_DAYS) ?? 0);

    let file = this.context.resourceManager.getRawFileContentSync('agconnect-services.json');
    let json: string = buffer.from(file.buffer).toString();
    hilog.info(DOMAIN, 'testTag', '====== AGC Config ======');
    try {
      let configObj: Record<string, Object> = JSON.parse(json) as Record<string, Object>;
      let clientObj = configObj['client'] as Record<string, string>;
      let oauthObj = configObj['oauth_client'] as Record<string, string>;
      let appInfoObj = configObj['app_info'] as Record<string, string>;
      hilog.info(DOMAIN, 'testTag', 'config client.client_id: %{public}s', clientObj?.['client_id'] ?? 'N/A');
      hilog.info(DOMAIN, 'testTag', 'config client.app_id: %{public}s', clientObj?.['app_id'] ?? 'N/A');
      hilog.info(DOMAIN, 'testTag', 'config oauth_client.client_id: %{public}s', oauthObj?.['client_id'] ?? 'N/A');
      hilog.info(DOMAIN, 'testTag', 'config app_info.app_id: %{public}s', appInfoObj?.['app_id'] ?? 'N/A');
      hilog.info(DOMAIN, 'testTag', 'config app_info.package_name: %{public}s', appInfoObj?.['package_name'] ?? 'N/A');
      hilog.info(DOMAIN, 'testTag', 'config region: %{public}s', (configObj['region'] as string) ?? 'N/A');
    } catch (e) {
      hilog.error(DOMAIN, 'testTag', 'Failed to parse agconnect-services.json: %{public}s', JSON.stringify(e));
    }
    hilog.info(DOMAIN, 'testTag', '========================');
    auth.init(this.context, json);
    // 注意：不再调用 setClientId/setClientSecret，auth.init() 已从 JSON 读取完整配置
    // 初始化视频播放进度跨设备同步服务
    let syncService: VideoSyncService = VideoSyncService.getInstance();
    syncService.init(this.context).then((success: boolean) => {
      if (success) {
        hilog.info(DOMAIN, 'testTag', 'VideoSyncService initialized successfully');
      } else {
        hilog.warn(DOMAIN, 'testTag', 'VideoSyncService initialization failed');
      }
    });

    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    // 获取应用证书签名信息并输出到日志
    this.logSignatureInfo();

    // 诊断 Account Kit 可用性
    this.diagnoseAccountKit();
  }

  /**
   * 获取应用的证书签名信息并打印到日志
   */
  private logSignatureInfo(): void {
    try {
      bundleManager.getBundleInfoForSelf(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO
      ).then((bundleInfo) => {
        if (bundleInfo.signatureInfo) {
          hilog.info(DOMAIN, 'testTag', '====== 证书签名信息 ======');
          hilog.info(DOMAIN, 'testTag', 'appId: %{public}s', bundleInfo.signatureInfo.appId);
          hilog.info(DOMAIN, 'testTag', 'fingerprint: %{public}s', bundleInfo.signatureInfo.fingerprint);
          hilog.info(DOMAIN, 'testTag', 'appIdentifier: %{public}s', bundleInfo.signatureInfo.appIdentifier);
          hilog.info(DOMAIN, 'testTag', 'certificate: %{public}s', bundleInfo.signatureInfo.certificate);
          hilog.info(DOMAIN, 'testTag', '==========================');
        } else {
          hilog.warn(DOMAIN, 'testTag', '未获取到签名信息，请确认应用已签名');
        }
      }).catch((err: Error) => {
        hilog.error(DOMAIN, 'testTag', '获取签名信息失败: %{public}s', err.message);
      });
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', '获取签名信息异常: %{public}s', JSON.stringify(err));
    }
  }

  /**
   * 诊断 Account Kit 是否可用
   */
  private diagnoseAccountKit(): void {
    hilog.info(DOMAIN, 'testTag', '====== Account Kit 诊断 ======');
    try {
      // 读取 module.json5 中配置的 metadata
      bundleManager.getBundleInfoForSelf(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE |
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_ABILITY |
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_METADATA
      ).then((bundleInfo) => {
        hilog.info(DOMAIN, 'testTag', 'bundleName: %{public}s', bundleInfo.name);
        if (bundleInfo.hapModulesInfo && bundleInfo.hapModulesInfo.length > 0) {
          for (let mod of bundleInfo.hapModulesInfo) {
            hilog.info(DOMAIN, 'testTag', 'module: %{public}s', mod.name);
            if (mod.abilitiesInfo) {
              for (let ability of mod.abilitiesInfo) {
                hilog.info(DOMAIN, 'testTag', '  ability: %{public}s', ability.name);
                if (ability.metadata) {
                  for (let meta of ability.metadata) {
                    hilog.info(DOMAIN, 'testTag', '    metadata: name=%{public}s, value=%{public}s', meta.name, meta.value);
                  }
                }
              }
            }
          }
        }
      }).catch((err: Error) => {
        hilog.error(DOMAIN, 'testTag', 'getBundleInfo failed: %{public}s', err.message);
      });

      // 尝试最简单的 Account Kit 调用：获取授权（非登录）
      hilog.info(DOMAIN, 'testTag', '尝试 Account Kit AuthorizationWithHuaweiIDRequest...');
      let provider = new authentication.HuaweiIDProvider();
      let authRequest = provider.createAuthorizationWithHuaweiIDRequest();
      authRequest.forceAuthorization = false;
      let controller = new authentication.AuthenticationController();
      controller.executeRequest(authRequest).then((data) => {
        hilog.info(DOMAIN, 'testTag', 'Account Kit AuthorizationRequest 成功! type: %{public}s', typeof data);
        let resp = data as authentication.AuthorizationWithHuaweiIDResponse;
        hilog.info(DOMAIN, 'testTag', 'Authorization data: unionId=%{public}s, openId=%{public}s',
          resp?.data?.unionID ?? 'N/A', resp?.data?.openID ?? 'N/A');
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, 'testTag',
          'Account Kit AuthorizationRequest 失败! Code: %{public}d, Message: %{public}s', err.code, err.message);
      });
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Account Kit 诊断异常: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '==============================');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}