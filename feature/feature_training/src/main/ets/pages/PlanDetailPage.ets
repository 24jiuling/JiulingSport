
import { TrainingPlan, Course } from 'lib_entity';
import { FitnessService } from 'lib_api';
import { RouterManager, RouterKey } from 'lib_router';
import { TrainingParam } from '../model/TrainingParam';
import promptAction from '@ohos.promptAction';
import { hilog } from '@kit.PerformanceAnalysisKit';

const PLAN_DETAIL_TAG: string = 'PlanDetailPage';
const PLAN_DETAIL_DOMAIN: number = 0x0000;

@Component
export struct PlanDetailPage {
  private service: FitnessService = FitnessService.getInstance();
  private router: RouterManager = RouterManager.getInstance();
  @Prop planId: number = 0;
  @State plan: TrainingPlan | null = null;

  aboutToAppear() {
    hilog.info(PLAN_DETAIL_DOMAIN, PLAN_DETAIL_TAG, 'aboutToAppear - 加载计划, planId: %{public}d', this.planId);
    this.plan = this.service.getPlanById(this.planId);
    hilog.info(PLAN_DETAIL_DOMAIN, PLAN_DETAIL_TAG, '计划加载结果: %{public}s', this.plan !== null ? this.plan.name : 'null');
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
                    .borderRadius(10).backgroundColor($r('app.color.semi_transparent_white'))
                  Blank()
                  Text(this.plan.durationDays.toString())
                    .fontSize(12).fontColor($r('app.color.text_white'))
                  Text($r('app.string.unit_day_plan'))
                    .fontSize(12).fontColor($r('app.color.text_white'))
                }.width('100%')
                // 进度
                Column({ space: 4 }) {
                  Row() {
                    Text($r('app.string.progress_label')).fontSize(12).fontColor($r('app.color.plan_text_secondary'))
                    Blank()
                    Text(this.plan.completedDays.toString() + '/' + this.plan.durationDays.toString())
                      .fontSize(12).fontColor($r('app.color.text_white'))
                  Text($r('app.string.unit_day'))
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
                    hilog.info(PLAN_DETAIL_DOMAIN, PLAN_DETAIL_TAG, '点击开始计划按钮');
                    if (this.plan !== null) {
                      // 必填项校验：名称、目标、课程
                      if (!this.plan.name || !this.plan.targetGoal || !this.plan.courses || this.plan.courses.length === 0) {
                        hilog.warn(PLAN_DETAIL_DOMAIN, PLAN_DETAIL_TAG, '计划信息不完整, name: %{public}s, goal: %{public}s, coursesLen: %{public}d',
                          this.plan.name, this.plan.targetGoal, this.plan.courses ? this.plan.courses.length : 0);
                        promptAction.showToast({ message: getContext(this).resourceManager.getStringSync($r('app.string.plan_incomplete_hint')) });
                        return;
                      }
                      hilog.info(PLAN_DETAIL_DOMAIN, PLAN_DETAIL_TAG, '开始计划 - planId: %{public}d, name: %{public}s', this.plan.id, this.plan.name);
                      this.service.startPlan(this.plan.id);
                      this.plan = this.service.getPlanById(this.planId);
                      hilog.info(PLAN_DETAIL_DOMAIN, PLAN_DETAIL_TAG, '计划状态更新为: %{public}s', this.plan !== null ? this.plan.status : 'null');
                    }
                  })
              } else if (this.plan.status === 'ongoing') {
                Button($r('app.string.continue_training_btn')).width('100%').height(44)
                  .onClick(() => {
                    hilog.info(PLAN_DETAIL_DOMAIN, PLAN_DETAIL_TAG, '点击继续训练按钮');
                    if (this.plan !== null && this.plan.courses.length > 0) {
                      let course = this.plan.courses[0];
                      hilog.info(PLAN_DETAIL_DOMAIN, PLAN_DETAIL_TAG, '跳转训练 - courseId: %{public}d, title: %{public}s', course.id, course.title);
                      this.router.push(RouterKey.ACTIVE_TRAINING, course);
                    } else {
                      hilog.warn(PLAN_DETAIL_DOMAIN, PLAN_DETAIL_TAG, '无法继续训练: plan为null或courses为空');
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
                      Text(course.duration.toString())
                        .fontSize(12).fontColor($r('app.color.text_gray'))
                      Text($r('app.string.duration_unit_join'))
                        .fontSize(12).fontColor($r('app.color.text_gray'))
                      Text(course.calories.toString())
                        .fontSize(12).fontColor($r('app.color.text_gray'))
                      Text($r('app.string.calories_unit_suffix'))
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
                    Text(this.getWeekdayDisplayName(day))
                      .fontSize(12).fontColor($r('app.color.text_gray'))
                    Circle({ width: 28, height: 28 })
                      .fill(index < 5 ? $r('app.color.primary_blue') : $r('app.color.placeholder_bg'))
                      .margin({ top: 4 })
                    Text(index < 5 ? '✓' : '')
                      .fontSize(10).fontColor(index < 5 ? $r('app.color.text_white') : $r('app.color.text_gray'))
                      .margin({ top: -22 })
                    if (index >= 5) {
                      Text($r('app.string.weekday_rest'))
                        .fontSize(10).fontColor($r('app.color.text_gray')).margin({ top: -22 })
                    }
                  }.layoutWeight(1)
                })
              }.width('100%').padding(12).backgroundColor(Color.White).borderRadius(12)
            }.padding(16)
          }.layoutWeight(1)
        }
      }.width('100%').height('100%').backgroundColor($r('app.color.page_background'))
    }.hideTitleBar(true)
  }

  getWeekdayDisplayName(day: string): ResourceStr {
    if (day === '一') {
      return $r('app.string.weekday_mon');
    } else if (day === '二') {
      return $r('app.string.weekday_tue');
    } else if (day === '三') {
      return $r('app.string.weekday_wed');
    } else if (day === '四') {
      return $r('app.string.weekday_thu');
    } else if (day === '五') {
      return $r('app.string.weekday_fri');
    } else if (day === '六') {
      return $r('app.string.weekday_sat');
    }
    return $r('app.string.weekday_sun');
  }
}
