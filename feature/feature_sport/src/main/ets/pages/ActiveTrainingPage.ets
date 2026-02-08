
import { Course } from 'lib_entity';
import { FitnessService, UserService } from 'lib_api';
import { RouterManager } from 'lib_router';

@Component
export struct ActiveTrainingPage {
  private service: FitnessService = FitnessService.getInstance();
  private userService: UserService = UserService.getInstance();
  private router: RouterManager = RouterManager.getInstance();
  @Prop courseTitle: string = '';
  @Prop courseCalories: number = 0;
  @Prop courseDuration: number = 0;
  @Prop courseId: number = 0;
  @State elapsedSeconds: number = 0;
  @State isRunning: boolean = false;
  @State isPaused: boolean = false;
  @State currentCalories: number = 0;
  @State isCompleted: boolean = false;
  private timerId: number = -1;

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部栏
        Row() {
          Button($r('app.string.back_text')).height(32).onClick(() => {
            if (this.timerId !== -1) {
              clearInterval(this.timerId);
            }
            this.router.pop();
          })
          Text($r('app.string.active_training_title'))
            .fontSize(22).fontWeight(FontWeight.Bold).margin({ left: 12 })
        }.width('100%').padding({ left: 16, right: 16, top: 16, bottom: 8 })

        Scroll() {
          Column({ space: 20 }) {
            // 课程名称
            Text(this.courseTitle).fontSize(24).fontWeight(FontWeight.Bold)
              .margin({ top: 20 })

            // 计时器圆环
            Stack() {
              Circle({ width: 200, height: 200 })
                .fill(Color.Transparent)
                .stroke($r('app.color.placeholder_bg'))
                .strokeWidth(8)
              Progress({
                value: this.courseDuration > 0 ?
                  Math.min(this.elapsedSeconds / (this.courseDuration * 60) * 100, 100) : 0,
                total: 100,
                type: ProgressType.Ring
              })
                .width(200).height(200)
                .color($r('app.color.primary_blue'))
                .style({ strokeWidth: 8 })
              Column({ space: 4 }) {
                Text(this.formatTime(this.elapsedSeconds))
                  .fontSize(36).fontWeight(FontWeight.Bold)
                Text(this.courseDuration > 0 ? '/' + this.courseDuration.toString() + '分钟' : '')
                  .fontSize(14).fontColor($r('app.color.text_gray'))
              }
            }.width(220).height(220)

            // 实时数据卡片
            Row() {
              Column() {
                Text(this.currentCalories.toString())
                  .fontSize(28).fontWeight(FontWeight.Bold).fontColor($r('app.color.primary_blue'))
                Text($r('app.string.unit_kcal'))
                  .fontSize(14).fontColor($r('app.color.text_gray'))
              }.layoutWeight(1)
              Column() {
                Text(Math.floor(this.elapsedSeconds / 60).toString())
                  .fontSize(28).fontWeight(FontWeight.Bold).fontColor($r('app.color.plan_ongoing_bg'))
                Text($r('app.string.unit_min'))
                  .fontSize(14).fontColor($r('app.color.text_gray'))
              }.layoutWeight(1)
            }.width('80%').padding(20).backgroundColor(Color.White).borderRadius(16)
            .shadow({ radius: 4, color: $r('app.color.shadow_color_light'), offsetY: 2 })

            // 多端同步提示
            Row() {
              Text('📱')
                .fontSize(16)
              Text($r('app.string.multi_device_hint'))
                .fontSize(12).fontColor($r('app.color.text_gray')).margin({ left: 8 })
            }.width('80%').padding(12).backgroundColor($r('app.color.status_ongoing_bg'))
            .borderRadius(8)

            if (this.isCompleted) {
              // 完成界面
              Column({ space: 12 }) {
                Text('🎉').fontSize(48)
                Text($r('app.string.training_complete'))
                  .fontSize(20).fontWeight(FontWeight.Bold)
                Text(Math.floor(this.elapsedSeconds / 60).toString() + '分钟 · ' +
                  this.currentCalories.toString() + '千卡')
                  .fontSize(16).fontColor($r('app.color.text_gray'))
                Button($r('app.string.finish_btn')).width('80%').height(44)
                  .onClick(() => { this.router.pop(); })
              }.margin({ top: 20 })
            } else {
              // 控制按钮
              Row({ space: 16 }) {
                if (!this.isRunning) {
                  Button($r('app.string.start_training_btn'))
                    .width(140).height(48)
                    .onClick(() => { this.startTimer(); })
                } else {
                  if (this.isPaused) {
                    Button($r('app.string.resume_btn'))
                      .width(120).height(48)
                      .onClick(() => { this.resumeTimer(); })
                  } else {
                    Button($r('app.string.pause_btn'))
                      .width(120).height(48)
                      .backgroundColor($r('app.color.plan_ongoing_bg'))
                      .onClick(() => { this.pauseTimer(); })
                  }
                  Button($r('app.string.finish_training_btn'))
                    .width(120).height(48)
                    .backgroundColor($r('app.color.badge_unlocked'))
                    .fontColor($r('app.color.text_black'))
                    .onClick(() => { this.finishTraining(); })
                }
              }.margin({ top: 20 })
            }
          }.width('100%')
        }.layoutWeight(1)
      }.width('100%').height('100%').backgroundColor($r('app.color.page_background'))
    }.hideTitleBar(true)
  }

  startTimer(): void {
    this.isRunning = true;
    this.isPaused = false;
    let caloriesPerMinute: number = this.courseDuration > 0 ?
      this.courseCalories / this.courseDuration : 5;
    this.timerId = setInterval(() => {
      this.elapsedSeconds = this.elapsedSeconds + 1;
      this.currentCalories = Math.round((this.elapsedSeconds / 60) * caloriesPerMinute);
      // 自动完成检测
      if (this.courseDuration > 0 && this.elapsedSeconds >= this.courseDuration * 60) {
        this.finishTraining();
      }
    }, 1000);
  }

  pauseTimer(): void {
    this.isPaused = true;
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  resumeTimer(): void {
    this.isPaused = false;
    let caloriesPerMinute: number = this.courseDuration > 0 ?
      this.courseCalories / this.courseDuration : 5;
    this.timerId = setInterval(() => {
      this.elapsedSeconds = this.elapsedSeconds + 1;
      this.currentCalories = Math.round((this.elapsedSeconds / 60) * caloriesPerMinute);
      if (this.courseDuration > 0 && this.elapsedSeconds >= this.courseDuration * 60) {
        this.finishTraining();
      }
    }, 1000);
  }

  finishTraining(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    this.isRunning = false;
    this.isCompleted = true;
    // 保存运动记录
    let durationMin = Math.floor(this.elapsedSeconds / 60);
    this.service.createAutoRecord(this.courseId, this.courseTitle, durationMin, this.currentCalories, this.courseTitle);
    // 更新用户统计
    this.userService.updateStats(durationMin, this.currentCalories);
    // 自动打卡
    if (!this.userService.isTodayCheckedIn()) {
      this.userService.checkIn();
    }
    // 检查徽章解锁
    let user = this.userService.getCurrentUser();
    if (user !== null) {
      this.service.checkAndUnlockBadges(user);
    }
  }

  formatTime(totalSeconds: number): string {
    let minutes = Math.floor(totalSeconds / 60);
    let seconds = totalSeconds % 60;
    let minStr = minutes < 10 ? '0' + minutes.toString() : minutes.toString();
    let secStr = seconds < 10 ? '0' + seconds.toString() : seconds.toString();
    return minStr + ':' + secStr;
  }
}
