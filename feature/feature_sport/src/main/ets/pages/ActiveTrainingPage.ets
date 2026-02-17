
import { FitnessService, UserService } from 'lib_api';
import { RouterManager } from 'lib_router';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TRAINING_TAG: string = 'ActiveTrainingPage';
const TRAINING_DOMAIN: number = 0x0000;

@Component
export struct ActiveTrainingPage {
  private service: FitnessService = FitnessService.getInstance();
  private userService: UserService = UserService.getInstance();
  private router: RouterManager = RouterManager.getInstance();
  @Prop courseTitle: string = '';
  @Prop courseVideoUrl: string = '';
  @Prop courseCalories: number = 0;
  @Prop courseDuration: number = 0;
  @Prop courseId: number = 0;
  @State elapsedSeconds: number = 0;
  @State isRunning: boolean = false;
  @State isPaused: boolean = false;
  @State currentCalories: number = 0;
  @State isCompleted: boolean = false;
  private videoController: VideoController = new VideoController();
  private timerId: number = -1;

  aboutToDisappear() {
    hilog.info(TRAINING_DOMAIN, TRAINING_TAG, 'aboutToDisappear - 页面销毁, courseId: %{public}d, elapsed: %{public}d秒', this.courseId, this.elapsedSeconds);
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

        // 视频播放组件
        if (this.courseVideoUrl.length > 0) {
          if (!this.courseVideoUrl.startsWith('http')) {
            Video({ src: $rawfile(this.courseVideoUrl), controller: this.videoController })
              .width('100%').height(220).autoPlay(false).controls(true)
          } else {
            Video({ src: this.courseVideoUrl, controller: this.videoController })
              .width('100%').height(220).autoPlay(false).controls(true)
          }
        }

        Scroll() {
          Column({ space: 20 }) {
            // 课程名称
            Text(this.courseTitle).fontSize(24).fontWeight(FontWeight.Bold)
              .margin({ top: 20 })

            // 胶囊型计时器，水平居中
            Row() {
              Column() {
                Text(this.formatTime(this.elapsedSeconds))
                  .fontSize(28).fontWeight(FontWeight.Bold).fontColor(Color.White)
                Text(this.courseDuration > 0 ? '/' + this.courseDuration.toString() : '')
                  .fontSize(14).fontColor(Color.White)
                if (this.courseDuration > 0) {
                  Text($r('app.string.unit_min'))
                    .fontSize(14).fontColor(Color.White)
                }
              }
              .padding({ left: 32, right: 32, top: 12, bottom: 12 })
              .backgroundColor($r('app.color.primary_blue'))
              .borderRadius(24)
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)

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
                Text(Math.floor(this.elapsedSeconds / 60).toString())
                  .fontSize(16).fontColor($r('app.color.text_gray'))
                Text($r('app.string.duration_unit_join'))
                  .fontSize(16).fontColor($r('app.color.text_gray'))
                Text(this.currentCalories.toString())
                  .fontSize(16).fontColor($r('app.color.text_gray'))
                Text($r('app.string.calories_unit_suffix'))
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
    hilog.info(TRAINING_DOMAIN, TRAINING_TAG, '开始训练计时 - courseId: %{public}d, title: %{public}s, duration: %{public}d分钟, videoUrl: %{public}s',
      this.courseId, this.courseTitle, this.courseDuration, this.courseVideoUrl);
    this.isRunning = true;
    this.isPaused = false;
    this.timerId = setInterval(() => {
      this.elapsedSeconds = this.elapsedSeconds + 1;
      this.currentCalories = this.service.calculateCalories(
        this.courseId,
        this.elapsedSeconds,
        this.courseDuration,
        this.courseCalories
      );
      // 自动完成检测
      if (this.courseDuration > 0 && this.elapsedSeconds >= this.courseDuration * 60) {
        this.finishTraining();
      }
    }, 1000);
  }

  pauseTimer(): void {
    hilog.info(TRAINING_DOMAIN, TRAINING_TAG, '暂停训练 - elapsed: %{public}d秒, calories: %{public}d', this.elapsedSeconds, this.currentCalories);
    this.isPaused = true;
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  resumeTimer(): void {
    hilog.info(TRAINING_DOMAIN, TRAINING_TAG, '恢复训练 - elapsed: %{public}d秒, calories: %{public}d', this.elapsedSeconds, this.currentCalories);
    this.isPaused = false;
    this.timerId = setInterval(() => {
      this.elapsedSeconds = this.elapsedSeconds + 1;
      this.currentCalories = this.service.calculateCalories(
        this.courseId,
        this.elapsedSeconds,
        this.courseDuration,
        this.courseCalories
      );
      if (this.courseDuration > 0 && this.elapsedSeconds >= this.courseDuration * 60) {
        this.finishTraining();
      }
    }, 1000);
  }

  finishTraining(): void {
    hilog.info(TRAINING_DOMAIN, TRAINING_TAG, '结束训练 - courseId: %{public}d, elapsed: %{public}d秒, calories: %{public}d',
      this.courseId, this.elapsedSeconds, this.currentCalories);
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    this.isRunning = false;
    this.isCompleted = true;
    // 保存运动记录
    let durationMin = Math.floor(this.elapsedSeconds / 60);
    hilog.info(TRAINING_DOMAIN, TRAINING_TAG, '保存运动记录 - duration: %{public}d分钟, calories: %{public}d', durationMin, this.currentCalories);
    this.service.createAutoRecord(this.courseId, this.courseTitle, durationMin, this.currentCalories, this.courseTitle);
    // 更新用户统计
    hilog.info(TRAINING_DOMAIN, TRAINING_TAG, '更新用户统计数据');
    this.userService.updateStats(durationMin, this.currentCalories);
    // 自动打卡
    if (!this.userService.isTodayCheckedIn()) {
      hilog.info(TRAINING_DOMAIN, TRAINING_TAG, '自动执行今日打卡');
      this.userService.checkIn();
    } else {
      hilog.info(TRAINING_DOMAIN, TRAINING_TAG, '今日已打卡, 跳过自动打卡');
    }
    // 检查徽章解锁
    let user = this.userService.getCurrentUser();
    if (user !== null) {
      hilog.info(TRAINING_DOMAIN, TRAINING_TAG, '检查徽章解锁 - userId: %{public}d', user.id);
      this.service.checkAndUnlockBadges(user);
    } else {
      hilog.warn(TRAINING_DOMAIN, TRAINING_TAG, '用户为null, 跳过徽章检查');
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
