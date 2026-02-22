import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { UserService } from 'lib_api';
import { RouterManager, RouterKey } from 'lib_router';
import auth, { SignInParam, SignInResult, TokenResult } from '@hw-agconnect/auth';
import { loginComponentManager } from '@kit.AccountKit';


const LOG_TAG: string = 'LoginPage';
const DOMAIN_ID: number = 0x0000;

@Component
export struct LoginPage {
  private userService: UserService = UserService.getInstance();
  private router: RouterManager = RouterManager.getInstance();
  @State isSelected: boolean = false;

  // 协议弹框
  agreementDialog: CustomDialogController = new CustomDialogController({
    builder: HuaweiAgreementDialog({
      cancel: () => {
        this.agreementDialog.close();
      },
      confirm: () => {
        this.agreementDialog.close();
        this.isSelected = true;
        // 同意协议后直接执行登录
        this.doHuaweiSignIn();
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
  });

  /**
   * 华为账号登录入口 - 点击按钮时调用
   */
  private onLoginClick(): void {
    if (!this.isSelected) {
      // 未勾选协议，弹出协议弹框
      this.agreementDialog.open();
      return;
    }
    this.doHuaweiSignIn();
  }

  /**
   * 使用 AGC 认证服务直接登录华为账号
   * 按照官方文档示例：auth.signIn({ credentialInfo: { kind: 'hwid' }, autoCreateUser: true })
   * AGC SDK 会自动拉起华为账号授权界面
   */
  private doHuaweiSignIn(): void {
    if (this.userService.isLoggedIn()) {
      return;
    }
    hilog.info(DOMAIN_ID, LOG_TAG, '[DEBUG] doHuaweiSignIn - 开始 AGC 华为账号登录...');
    this.userService.login()
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部返回按钮
        Row() {
          Button({ type: ButtonType.Normal }) {
            Text('←').fontSize(20).fontColor($r('app.color.text_black'))
          }
          .width(40).height(40).borderRadius(20)
          .backgroundColor($r('app.color.page_background'))
          .onClick(() => { this.router.pop(); })
          Blank()
        }.width('100%').padding({ left: 16, right: 16, top: 12 })

        Scroll() {
          Column() {
            // Logo 区域
            Column({ space: 8 }) {
              Text($r('app.string.app_name'))
                .fontSize(32).fontWeight(FontWeight.Bold).fontColor($r('app.color.primary_blue'))
              Text($r('app.string.login_subtitle'))
                .fontSize(14).fontColor($r('app.color.text_gray'))
            }.margin({ top: 60, bottom: 48 })

            // 华为账号登录
            Column({ space: 16 }) {
              // 同步提示
              Row({ space: 6 }) {
                Text('🔄').fontSize(14)
                Text($r('app.string.sync_login_hint'))
                  .fontSize(12).fontColor($r('app.color.text_gray'))
              }.width('85%')

              // 华为账号登录按钮（直接调用 AGC Auth signIn）
              Button($r('app.string.huawei_login_btn'))
                .width('85%')
                .height(40)
                .borderRadius(24)
                .backgroundColor('#CE0E2D')
                .fontColor(Color.White)
                .fontSize(16)
                .enabled(!this.userService.isLoggedIn())
                .onClick(() => {
                  this.onLoginClick();
                })

              // 协议勾选
              Row() {
                Checkbox({ name: 'agreementCheckbox', group: 'agreementGroup' })
                  .width(20).height(20)
                  .select(this.isSelected)
                  .selectedColor($r('app.color.primary_blue'))
                  .onChange((value: boolean) => {
                    this.isSelected = value;
                  })

                Text() {
                  Span($r('app.string.agree_text'))
                    .fontSize(11).fontColor($r('app.color.text_gray'))
                  Span($r('app.string.user_agreement'))
                    .fontSize(11).fontColor($r('app.color.primary_blue'))
                  Span($r('app.string.and_text'))
                    .fontSize(11).fontColor($r('app.color.text_gray'))
                  Span($r('app.string.privacy_policy'))
                    .fontSize(11).fontColor($r('app.color.primary_blue'))
                }
                .margin({ left: 8 })
              }
              .width('85%')
              .alignItems(VerticalAlign.Top)
            }
          }.width('100%').padding({ bottom: 30 })
        }.layoutWeight(1)
      }.width('100%').height('100%').backgroundColor($r('app.color.page_background'))
    }
    .hideTitleBar(true)
  }
}

@CustomDialog
struct HuaweiAgreementDialog {
  dialogController?: CustomDialogController;
  cancel: () => void = () => {};
  confirm: () => void = () => {};

  build() {
    Column() {
      Row() {
        Text($r('app.string.agreement_dialog_title'))
          .fontSize(18).fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_black'))
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 24, bottom: 16 })

      Row() {
        Text() {
          Span($r('app.string.agree_text'))
            .fontSize(14).fontColor($r('app.color.text_gray'))
          Span($r('app.string.user_agreement'))
            .fontSize(14).fontColor($r('app.color.primary_blue'))
          Span($r('app.string.and_text'))
            .fontSize(14).fontColor($r('app.color.text_gray'))
          Span($r('app.string.privacy_policy'))
            .fontSize(14).fontColor($r('app.color.primary_blue'))
        }
      }
      .width('100%')
      .padding({ left: 24, right: 24 })

      Row({ space: 16 }) {
        Button($r('app.string.cancel_text'))
          .layoutWeight(1).height(40)
          .backgroundColor(Color.Transparent)
          .fontColor($r('app.color.text_gray'))
          .onClick(() => { this.cancel(); })

        Button($r('app.string.agree_and_login'))
          .layoutWeight(1).height(40)
          .backgroundColor($r('app.color.primary_blue'))
          .fontColor(Color.White)
          .onClick(() => { this.confirm(); })
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 16, bottom: 24 })
    }
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}
