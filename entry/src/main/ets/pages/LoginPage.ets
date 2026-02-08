
import { UserService } from 'lib_api';
import { RouterManager, RouterKey } from 'lib_router';

@Component
export struct LoginPage {
  private userService: UserService = UserService.getInstance();
  private router: RouterManager = RouterManager.getInstance();
  @State isLogin: boolean = true; // true=登录, false=注册
  @State phone: string = '';
  @State password: string = '';
  @State username: string = '';
  @State errorMsg: string = '';

  build() {
    NavDestination() {
      Column() {
        // 顶部关闭按钮
        Row() {
          Button($r('app.string.back_text')).height(32).onClick(() => { this.router.pop(); })
          Blank()
        }.width('100%').padding({ left: 16, right: 16, top: 16 })

        Scroll() {
          Column({ space: 20 }) {
            // Logo区域
            Column({ space: 8 }) {
              Text($r('app.string.app_name'))
                .fontSize(32).fontWeight(FontWeight.Bold).fontColor($r('app.color.primary_blue'))
              Text($r('app.string.login_subtitle'))
                .fontSize(14).fontColor($r('app.color.text_gray'))
            }.margin({ top: 40, bottom: 30 })

            // 登录/注册切换
            Row() {
              Text($r('app.string.login_tab'))
                .fontSize(16).fontWeight(this.isLogin ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.isLogin ? $r('app.color.primary_blue') : $r('app.color.text_gray'))
                .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                .onClick(() => { this.isLogin = true; this.errorMsg = ''; })
              Text($r('app.string.register_tab'))
                .fontSize(16).fontWeight(!this.isLogin ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(!this.isLogin ? $r('app.color.primary_blue') : $r('app.color.text_gray'))
                .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                .onClick(() => { this.isLogin = false; this.errorMsg = ''; })
            }

            // 表单
            Column({ space: 12 }) {
              if (!this.isLogin) {
                // 用户名(仅注册)
                TextInput({ placeholder: '请输入用户名' })
                  .width('100%').height(48)
                  .onChange((value: string) => { this.username = value; })
              }

              // 手机号
              TextInput({ placeholder: '请输入手机号' })
                .type(InputType.PhoneNumber)
                .width('100%').height(48)
                .onChange((value: string) => { this.phone = value; })

              // 密码
              TextInput({ placeholder: '请输入密码' })
                .type(InputType.Password)
                .width('100%').height(48)
                .onChange((value: string) => { this.password = value; })

              // 错误提示
              if (this.errorMsg.length > 0) {
                Text(this.errorMsg).fontSize(13).fontColor(Color.Red)
              }

              // 登录/注册按钮
              Button(this.isLogin ? $r('app.string.login_btn') : $r('app.string.register_btn'))
                .width('100%').height(48).margin({ top: 8 })
                .onClick(() => { this.handleSubmit(); })
            }.width('85%')

            // 分隔线
            Row() {
              Divider().layoutWeight(1)
              Text($r('app.string.or_text'))
                .fontSize(12).fontColor($r('app.color.text_light_gray'))
                .margin({ left: 12, right: 12 })
              Divider().layoutWeight(1)
            }.width('85%').margin({ top: 12 })

            // 华为账号一键登录
            Button($r('app.string.huawei_login_btn'))
              .width('85%').height(48)
              .backgroundColor(Color.White)
              .fontColor($r('app.color.text_black'))
              .border({ width: 1, color: $r('app.color.placeholder_bg') })
              .onClick(() => {
                this.userService.loginWithHuaweiAccount();
                this.router.replace(RouterKey.GOAL_SETTING);
              })
          }.width('100%')
        }.layoutWeight(1)
      }.width('100%').height('100%').backgroundColor($r('app.color.page_background'))
    }.hideTitleBar(true)
  }

  handleSubmit(): void {
    // 简单校验
    if (this.phone.length < 11) {
      this.errorMsg = '请输入正确的手机号';
      return;
    }
    if (this.password.length < 6) {
      this.errorMsg = '密码至少6位';
      return;
    }
    if (this.isLogin) {
      this.userService.loginWithPhone(this.phone, this.password);
      this.router.pop();
    } else {
      if (this.username.length === 0) {
        this.errorMsg = '请输入用户名';
        return;
      }
      this.userService.register(this.phone, this.password, this.username);
      this.router.replace(RouterKey.GOAL_SETTING);
    }
  }
}
