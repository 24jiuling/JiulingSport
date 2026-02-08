
import { TrainingPlan, Course } from 'lib_entity';
import { FitnessService } from 'lib_api';
import { RouterManager, RouterKey } from 'lib_router';
import { TrainingParam } from '../model/TrainingParam';

@Component
export struct PlanDetailPage {
  private service: FitnessService = FitnessService.getInstance();
  private router: RouterManager = RouterManager.getInstance();
  @Prop planId: number = 0;
  @State plan: TrainingPlan | null = null;

  aboutToAppear() {
    this.plan = this.service.getPlanById(this.planId);
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部栏
        Row() {
          Button($r('app.string.back_text')).height(32).onClick(() => { this.router.pop(); })
          Text($r('app.string.plan_detail_title'))
            .fontSize(22).fontWeight(FontWeight.Bold).margin({ left: 12 })
        }.width('100%').padding({ left: 16, right: 16, top: 16, bottom: 8 })

        if (this.plan !== null) {
          Scroll() {
            Column({ space: 16 }) {
              // 计划头部卡片
              Column({ space: 8 }) {
                Text(this.plan.name).fontSize(24).fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_white'))
                Text(this.plan.description).fontSize(14).fontColor($r('app.color.plan_text_secondary'))
                Row() {
                  Text(this.plan.targetGoal).fontSize(12).fontColor($r('app.color.text_white'))
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(10).backgroundColor('#40FFFFFF')
                  Blank()
                  Text(this.plan.durationDays.toString() + '天计划')
                    .fontSize(12).fontColor($r('app.color.text_white'))
                }.width('100%')
                // 进度
                Column({ space: 4 }) {
                  Row() {
                    Text($r('app.string.progress_label')).fontSize(12).fontColor($r('app.color.plan_text_secondary'))
                    Blank()
                    Text(this.plan.completedDays.toString() + '/' + this.plan.durationDays.toString() + '天')
                      .fontSize(12).fontColor($r('app.color.text_white'))
                  }.width('100%')
                  Progress({ value: this.plan.progress, total: 100, type: ProgressType.Linear })
                    .width('100%').color($r('app.color.text_white'))
                }
              }.width('100%').padding(20).backgroundColor($r('app.color.primary_blue')).borderRadius(16)

              // 操作按钮
              if (this.plan.status === 'not_started') {
                Button($r('app.string.start_plan_btn')).width('100%').height(44)
                  .onClick(() => {
                    if (this.plan !== null) {
                      this.service.startPlan(this.plan.id);
                      this.plan = this.service.getPlanById(this.planId);
                    }
                  })
              } else if (this.plan.status === 'ongoing') {
                Button($r('app.string.continue_training_btn')).width('100%').height(44)
                  .onClick(() => {
                    if (this.plan !== null && this.plan.courses.length > 0) {
                      let course = this.plan.courses[0];
                      this.router.push(RouterKey.ACTIVE_TRAINING, course);
                    }
                  })
              }

              // 课程列表
              Text($r('app.string.plan_courses_title'))
                .fontSize(18).fontWeight(FontWeight.Bold).width('100%')
              Column({ space: 8 }) {
                ForEach(this.plan.courses, (course: Course, index: number) => {
                  Row() {
                    Column()
                      .width(50).height(50)
                      .backgroundColor($r('app.color.placeholder_bg'))
                      .borderRadius(8)
                    Column({ space: 4 }) {
                      Text(course.title).fontSize(16).fontWeight(FontWeight.Bold)
                      Text(course.duration.toString() + '分钟 · ' + course.calories.toString() + '千卡')
                        .fontSize(12).fontColor($r('app.color.text_gray'))
                    }.layoutWeight(1).alignItems(HorizontalAlign.Start).margin({ left: 12 })
                    Text((index + 1).toString()).fontSize(20).fontWeight(FontWeight.Bold)
                      .fontColor($r('app.color.text_light_gray'))
                  }
                  .padding(12).backgroundColor(Color.White).borderRadius(12).width('100%')
                  .shadow({ radius: 2, color: $r('app.color.shadow_color_light'), offsetY: 1 })
                })
              }

              // 每周安排示意
              Text($r('app.string.weekly_schedule_title'))
                .fontSize(18).fontWeight(FontWeight.Bold).width('100%')
              Row() {
                ForEach(['一', '二', '三', '四', '五', '六', '日'], (day: string, index: number) => {
                  Column() {
                    Text(day).fontSize(12).fontColor($r('app.color.text_gray'))
                    Circle({ width: 28, height: 28 })
                      .fill(index < 5 ? $r('app.color.primary_blue') : $r('app.color.placeholder_bg'))
                      .margin({ top: 4 })
                    Text(index < 5 ? '✓' : '休')
                      .fontSize(10).fontColor(index < 5 ? $r('app.color.text_white') : $r('app.color.text_gray'))
                      .margin({ top: -22 })
                  }.layoutWeight(1)
                })
              }.width('100%').padding(12).backgroundColor(Color.White).borderRadius(12)
            }.padding(16)
          }.layoutWeight(1)
        }
      }.width('100%').height('100%').backgroundColor($r('app.color.page_background'))
    }.hideTitleBar(true)
  }
}
