
import { User, Badge } from 'lib_entity';
import { FitnessService, UserService } from 'lib_api';
import { RouterManager, RouterKey } from 'lib_router';
import { StorageKey } from 'appscopecommon';
import { hilog } from '@kit.PerformanceAnalysisKit';

const MINE_TAG: string = 'MinePage';
const MINE_DOMAIN: number = 0x0000;

@Component
export struct Mine {
  @State user: User | null = null;
  @State badges: Badge[] = [];
  @State isLoggedIn: boolean = false;
  @State isTodayCheckedIn: boolean = false;
  @StorageProp(StorageKey.USER_LOGIN_STATE) @Watch('onLoginStateChange') loginState: number = 0;
  @StorageProp(StorageKey.LAST_CHECK_IN_DATE) @Watch('onPersistedCheckInChange') persistedCheckInDate: string = '';
  private service: FitnessService = FitnessService.getInstance();
  private userService: UserService = UserService.getInstance();
  private router: RouterManager = RouterManager.getInstance();

  aboutToAppear() {
    this.refreshData();
  }

  onLoginStateChange(): void {
    this.refreshData();
  }

  onPersistedCheckInChange(): void {
    let today = this.userService.getTodayString();
    this.isTodayCheckedIn = this.persistedCheckInDate === today;
    hilog.info(MINE_DOMAIN, MINE_TAG, 'onPersistedCheckInChange - persistedDate: %{public}s, today: %{public}s, isTodayCheckedIn: %{public}s',
      this.persistedCheckInDate, today, this.isTodayCheckedIn.toString());
  }

  refreshData(): void {
    hilog.info(MINE_DOMAIN, MINE_TAG, 'refreshData - 刷新我的页数据');
    this.user = this.userService.getCurrentUser();
    this.isLoggedIn = this.userService.isLoggedIn();
    // 直接从持久化存储读取打卡状态，不依赖 currentUser 内存状态
    let today = this.userService.getTodayString();
    this.isTodayCheckedIn = this.persistedCheckInDate === today;
    hilog.info(MINE_DOMAIN, MINE_TAG, 'refreshData - isLoggedIn: %{public}s, isTodayCheckedIn: %{public}s, persistedDate: %{public}s',
      this.isLoggedIn.toString(), this.isTodayCheckedIn.toString(), this.persistedCheckInDate);
    this.badges = this.service.getAllBadges();
    if (this.user !== null) {
      this.service.checkAndUnlockBadges(this.user);
      this.badges = this.service.getAllBadges();
    }
  }

  build() {
    Column({ space: 0 }) {
      Scroll() {
        Column({ space: 16 }) {
          // ========== 用户头部 ==========
          Column() {
            if (this.isLoggedIn && this.user !== null) {
              // 已登录：显示用户信息
              Row({ space: 16 }) {
                Circle({ width: 72, height: 72 }).fill($r('app.color.placeholder_bg'))
                Column({ space: 5 }) {
                  Text(this.user.username)
                    .fontSize(22).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_white'))
                  Text('ID: ' + this.user.id.toString())
                    .fontSize(13).fontColor($r('app.color.plan_text_secondary'))
                  if (this.user.goalType.length > 0) {
                    Row({ space: 4 }) {
                      Text('🎯').fontSize(12)
                      Text(this.user.goalType)
                        .fontSize(12).fontColor($r('app.color.text_white'))
                    }
                    .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                    .borderRadius(10).backgroundColor($r('app.color.semi_transparent_white'))
                  }
                }.alignItems(HorizontalAlign.Start)
              }.padding({ left: 24, right: 24, top: 20, bottom: 12 })

              // 同步状态
              Row({ space: 4 }) {
                Text('✅').fontSize(12)
                Text($r('app.string.sync_enabled_hint'))
                  .fontSize(12).fontColor($r('app.color.plan_text_secondary'))
              }.padding({ left: 24, bottom: 16 })
            } else {
              // 未登录：显示本地模式头部 + 登录入口
              Row({ space: 16 }) {
                Circle({ width: 72, height: 72 }).fill($r('app.color.placeholder_bg'))
                Column({ space: 6 }) {
                  Text($r('app.string.local_mode_title'))
                    .fontSize(22).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_white'))
                  Text($r('app.string.local_mode_hint'))
                    .fontSize(12).fontColor($r('app.color.plan_text_secondary'))
                    .maxLines(2)
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
              }.padding({ left: 24, right: 24, top: 20, bottom: 12 })

              // 登录按钮
              Row() {
                Button($r('app.string.login_register_btn'))
                  .height(36).fontSize(14)
                  .backgroundColor($r('app.color.semi_transparent_white')).fontColor($r('app.color.text_white'))
                  .onClick(() => { this.router.push(RouterKey.LOGIN); })
              }.padding({ left: 24, right: 24, bottom: 16 })
            }

            // 连续打卡（已登录且有打卡记录）
            if (this.isLoggedIn && this.user !== null && this.user.consecutiveDays > 0) {
              Row({ space: 4 }) {
                Text('🔥 ' + this.user.consecutiveDays.toString())
                  .fontSize(13).fontColor($r('app.color.text_white'))
                Text($r('app.string.consecutive_days_suffix'))
                  .fontSize(13).fontColor($r('app.color.text_white'))
              }.padding({ left: 24, bottom: 16 })
            }
          }.width('100%').backgroundColor($r('app.color.primary_blue'))

          // ========== 统计数据卡片 ==========
          Row() {
            Column() {
              Text(this.user !== null ? this.user.totalWorkouts.toString() : '0')
                .fontSize(24).fontWeight(FontWeight.Bold)
              Text($r('app.string.stat_workouts'))
                .fontSize(13).fontColor($r('app.color.text_gray'))
            }.layoutWeight(1)
            Column() {
              Text(this.user !== null ? this.user.totalTime.toString() : '0')
                .fontSize(24).fontWeight(FontWeight.Bold)
              Text($r('app.string.stat_minutes'))
                .fontSize(13).fontColor($r('app.color.text_gray'))
            }.layoutWeight(1)
            Column() {
              Text(this.user !== null ? this.user.totalCalories.toString() : '0')
                .fontSize(24).fontWeight(FontWeight.Bold)
              Text($r('app.string.stat_kcal'))
                .fontSize(13).fontColor($r('app.color.text_gray'))
            }.layoutWeight(1)
          }
          .padding(20).backgroundColor(Color.White)
          .margin({ left: 16, right: 16, top: -20 })
          .borderRadius(16)
          .shadow({ radius: 8, color: $r('app.color.shadow_color_dark'), offsetY: 4 })

          // ========== 打卡按钮 ==========
          if (!this.isTodayCheckedIn) {
            Button($r('app.string.check_in_btn'))
              .width('90%').height(44)
              .onClick(() => {
                hilog.info(MINE_DOMAIN, MINE_TAG, '我的页今日打卡 - 开始执行');
                this.userService.checkIn();
                // 直接更新 @State 驱动 UI 立即刷新
                this.isTodayCheckedIn = true;
                this.user = this.userService.getCurrentUser();
                hilog.info(MINE_DOMAIN, MINE_TAG, '我的页今日打卡 - 打卡完成, isTodayCheckedIn=%{public}s',
                  this.isTodayCheckedIn.toString());
                AlertDialog.show({ message: getContext(this).resourceManager.getStringSync($r('app.string.check_in_success')) });
              })
          } else {
            Row() {
              Text('✅').fontSize(16)
              Text($r('app.string.already_checked_in'))
                .fontSize(14).fontColor($r('app.color.primary_blue')).margin({ left: 8 })
            }.width('90%').padding(12).justifyContent(FlexAlign.Center)
            .backgroundColor($r('app.color.status_ongoing_bg')).borderRadius(12)
          }

          // ========== 徽章成就 ==========
          Column({ space: 8 }) {
            Row() {
              Text($r('app.string.achievements_title'))
                .fontSize(16).fontWeight(FontWeight.Bold).layoutWeight(1)
              Text($r('app.string.view_all_text'))
                .fontSize(12).fontColor($r('app.color.primary_blue'))
                .onClick(() => { this.router.push(RouterKey.BADGE_GALLERY); })
            }.width('100%').padding({ left: 16, right: 16 })

            List({ space: 10 }) {
              ForEach(this.badges, (badge: Badge) => {
                ListItem() {
                  Column({ space: 3 }) {
                    Circle({ width: 44, height: 44 })
                      .fill(badge.isUnlocked ? $r('app.color.badge_unlocked') : $r('app.color.badge_locked'))
                    Text(badge.name).fontSize(10).maxLines(1)
                      .fontColor(badge.isUnlocked ? $r('app.color.text_black') : $r('app.color.text_light_gray'))
                  }.width(70)
                }
              })
            }.listDirection(Axis.Horizontal).width('100%').height(80).padding({ left: 16 })
          }
          .backgroundColor(Color.White).margin({ left: 16, right: 16 }).borderRadius(12)
          .padding({ top: 12, bottom: 10 })

          // ========== 功能菜单（所有用户可用） ==========
          Column({ space: 1 }) {
            this.MenuItem($r('app.string.menu_my_plans'), () => {
              this.router.push(RouterKey.TRAINING_PLAN_LIST);
            })
            this.MenuItem($r('app.string.menu_history'), () => {
              this.router.push(RouterKey.EXERCISE_HISTORY);
            })
            this.MenuItem($r('app.string.menu_manual_record'), () => {
              this.router.push(RouterKey.MANUAL_RECORD);
            })
            this.MenuItem($r('app.string.menu_goal_setting'), () => {
              this.router.push(RouterKey.GOAL_SETTING);
            })
            this.MenuItem($r('app.string.menu_multi_device'), () => {
              this.router.push(RouterKey.MULTI_DEVICE_SYNC);
            })
            this.MenuItem($r('app.string.menu_settings'), () => {
              // 设置页面占位
            })
          }.width('90%').backgroundColor(Color.White).borderRadius(12)

          // ========== 退出登录（仅已登录时显示） ==========
          if (this.isLoggedIn) {
            Button($r('app.string.logout_btn'))
              .width('90%').height(44).margin({ top: 8 })
              .backgroundColor(Color.White).fontColor(Color.Red)
              .border({ width: 1, color: Color.Red })
              .onClick(() => {
                this.userService.logout();
                this.refreshData();
              })
          }
        }.padding({ bottom: 20 })
      }.width('100%').layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .onAppear(() => { this.refreshData(); })
  }

  @Builder MenuItem(title: ResourceStr, action: () => void) {
    Row() {
      Text(title).fontSize(16).fontWeight(FontWeight.Medium)
      Blank()
      Text('>').fontColor($r('app.color.arrow_gray'))
    }
    .width('100%').padding(16)
    .onClick(() => { action(); })
  }
}

