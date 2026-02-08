
import { Course, TrainingPlan } from 'lib_entity';
import { FitnessService, UserService } from 'lib_api';
import { RouterManager, RouterKey } from 'lib_router';
import { VideoParam } from 'feature_video';
import { SportParam } from 'feature_sport';


@Component
export struct Home {
  private service: FitnessService = FitnessService.getInstance();
  private userService: UserService = UserService.getInstance();
  private router: RouterManager = RouterManager.getInstance();
  @State featuredCourses: Course[] = [];
  @State activePlan: TrainingPlan | null = null;
  @State isLoggedIn: boolean = false;
  @State userName: string = '';
  @State todayStats: number[] = [0, 0, 0]; // [count, duration, calories]
  @State consecutiveDays: number = 0;

  aboutToAppear() {
    this.refreshData();
  }

  refreshData(): void {
    this.featuredCourses = this.service.getAllCourses();
    this.activePlan = this.service.getActivePlan();
    this.todayStats = this.service.getTodayStats();
    let currentUser = this.userService.getCurrentUser();
    if (currentUser !== null) {
      this.isLoggedIn = currentUser.isLoggedIn;
      this.userName = currentUser.username;
      this.consecutiveDays = currentUser.consecutiveDays;
    } else {
      this.isLoggedIn = false;
    }
  }

  build() {
    Scroll() {
      Column({ space: 15 }) {
        // 顶部: App名 + 登录/用户名
        Row() {
          Text($r('app.string.app_name'))
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)

          if (this.isLoggedIn) {
            Row({ space: 6 }) {
              Circle({ width: 28, height: 28 }).fill($r('app.color.primary_blue'))
              Text(this.userName).fontSize(14).fontColor($r('app.color.primary_blue'))
            }
          } else {
            Button($r('app.string.login_text'))
              .fontSize(14)
              .height(32)
              .onClick(() => {
                this.router.push(RouterKey.LOGIN);
              })
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20 })

        // Banner: 目标设定 / 今日概览
        Column({ space: 8 }) {
          if (this.isLoggedIn) {
            // 登录后: 今日概览
            Text($r('app.string.today_overview'))
              .fontColor($r('app.color.text_white')).fontSize(18).fontWeight(FontWeight.Bold)
            Row() {
              Column() {
                Text(this.todayStats[0].toString())
                  .fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_white'))
                Text($r('app.string.stat_workouts'))
                  .fontSize(11).fontColor($r('app.color.plan_text_secondary'))
              }.layoutWeight(1)
              Column() {
                Text(this.todayStats[1].toString())
                  .fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_white'))
                Text($r('app.string.stat_minutes'))
                  .fontSize(11).fontColor($r('app.color.plan_text_secondary'))
              }.layoutWeight(1)
              Column() {
                Text(this.todayStats[2].toString())
                  .fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_white'))
                Text($r('app.string.stat_kcal'))
                  .fontSize(11).fontColor($r('app.color.plan_text_secondary'))
              }.layoutWeight(1)
            }.width('100%')
            // 连续打卡
            if (this.consecutiveDays > 0) {
              Row() {
                Text('🔥').fontSize(14)
                Text(' ' + this.consecutiveDays.toString() + '天连续打卡')
                  .fontSize(12).fontColor($r('app.color.text_white'))
              }
            }
          } else {
            // 未登录: 欢迎 Banner
            Text($r('app.string.banner_title'))
              .fontColor($r('app.color.text_white'))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
          }
        }
        .width('90%')
        .padding(20)
        .backgroundColor($r('app.color.banner_bg'))
        .borderRadius(16)
        .alignItems(HorizontalAlign.Start)
        .onClick(() => {
          if (!this.isLoggedIn) {
            this.router.push(RouterKey.LOGIN);
          }
        })

        // 快捷操作区
        if (this.isLoggedIn) {
          Row() {
            Column({ space: 4 }) {
              Text('📋').fontSize(24)
              Text($r('app.string.quick_plan')).fontSize(11).fontColor($r('app.color.text_gray'))
            }.layoutWeight(1).onClick(() => { this.router.push(RouterKey.TRAINING_PLAN_LIST); })
            Column({ space: 4 }) {
              Text('✏️').fontSize(24)
              Text($r('app.string.quick_record')).fontSize(11).fontColor($r('app.color.text_gray'))
            }.layoutWeight(1).onClick(() => { this.router.push(RouterKey.MANUAL_RECORD); })
            Column({ space: 4 }) {
              Text('🏅').fontSize(24)
              Text($r('app.string.quick_badge')).fontSize(11).fontColor($r('app.color.text_gray'))
            }.layoutWeight(1).onClick(() => { this.router.push(RouterKey.BADGE_GALLERY); })
            Column({ space: 4 }) {
              Text('📊').fontSize(24)
              Text($r('app.string.quick_history')).fontSize(11).fontColor($r('app.color.text_gray'))
            }.layoutWeight(1).onClick(() => { this.router.push(RouterKey.EXERCISE_HISTORY); })
          }.width('90%').padding(12).backgroundColor(Color.White).borderRadius(12)
          .shadow({ radius: 4, color: $r('app.color.shadow_color_light'), offsetY: 2 })
        }

        // 进行中的计划
        if (this.activePlan !== null) {
          Column({ space: 6 }) {
            Row() {
              Text($r('app.string.active_plan_title'))
                .fontSize(16).fontWeight(FontWeight.Bold).layoutWeight(1)
              Text($r('app.string.view_all_plans')).fontSize(12).fontColor($r('app.color.primary_blue'))
                .onClick(() => { this.router.push(RouterKey.TRAINING_PLAN_LIST); })
            }.width('100%')
            Column({ space: 6 }) {
              Text(this.activePlan.name)
                .fontSize(16).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_white'))
              Row() {
                Text($r('app.string.progress_label')).fontSize(12).fontColor($r('app.color.plan_text_secondary'))
                Blank()
                Text(this.activePlan.completedDays.toString() + '/' + this.activePlan.durationDays.toString() + '天')
                  .fontSize(12).fontColor($r('app.color.text_white'))
              }.width('100%')
              Progress({ value: this.activePlan.progress, total: 100, type: ProgressType.Linear })
                .width('100%').color($r('app.color.text_white'))
            }.padding(12).backgroundColor($r('app.color.plan_ongoing_bg')).borderRadius(12)
          }.width('90%').padding(8)
        }

        // 推荐课程
        Text($r('app.string.recommendations_title'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 20 })
          .width('100%')

        List({ space: 10 }) {
          ForEach(this.featuredCourses, (item: Course) => {
            ListItem() {
              Row() {
                Column()
                  .width(60)
                  .height(60)
                  .backgroundColor($r('app.color.placeholder_bg'))
                  .borderRadius(8)

                Column({ space: 4 }) {
                  Text(item.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)

                  Row({ space: 6 }) {
                    Text(item.duration.toString() + '分钟')
                      .fontSize(12).fontColor($r('app.color.text_gray'))
                    Text(item.calories.toString() + '千卡')
                      .fontSize(12).fontColor($r('app.color.text_gray'))
                  }

                  if (item.category.length > 0) {
                    Text(item.category)
                      .fontSize(10).fontColor($r('app.color.primary_blue'))
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .borderRadius(4).backgroundColor($r('app.color.status_ongoing_bg'))
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 10 })

                Button($r('app.string.start_button'))
                  .fontSize(12)
                  .height(28)
                  .onClick(() => {
                    if (this.isLoggedIn) {
                      let param: SportParam = new SportParam(item.id, item.title, item.duration, item.calories);
                      this.router.push(RouterKey.ACTIVE_TRAINING, param);
                    } else {
                      let param: VideoParam = new VideoParam(item.title, item.videoUrl);
                      this.router.push(RouterKey.VIDEO_PLAYER, param);
                    }
                  })
              }
              .padding(10)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .width('100%')
            }
          })
        }
        .width('90%')
      }
      .width('100%')
      .padding({ bottom: 20 })
    }
    .align(Alignment.Top)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .onAppear(() => { this.refreshData(); })
  }
}


