
import { Course } from 'lib_entity';
import { FitnessService } from 'lib_api';
import { RouterManager } from 'lib_router';
import promptAction from '@ohos.promptAction';
import { hilog } from '@kit.PerformanceAnalysisKit';

const CREATE_PLAN_TAG: string = 'CreatePlanPage';
const CREATE_PLAN_DOMAIN: number = 0x0000;

@Component
export struct CreatePlanPage {
  private service: FitnessService = FitnessService.getInstance();
  private router: RouterManager = RouterManager.getInstance();
  @State planName: string = '';
  @State selectedGoal: string = '减脂';
  @State durationDays: number = 28;
  @State allCourses: Course[] = [];
  @State selectedCourseIds: number[] = [];
  private goalOptions: string[] = ['减脂', '增肌', '提升耐力'];
  private durationOptions: number[] = [7, 14, 28, 42];

  getGoalDisplayName(goal: string): ResourceStr {
    if (goal === '减脂') {
      return $r('app.string.goal_lose_fat_label');
    } else if (goal === '增肌') {
      return $r('app.string.goal_gain_muscle_label');
    }
    return $r('app.string.goal_endurance_label');
  }

  aboutToAppear() {
    hilog.info(CREATE_PLAN_DOMAIN, CREATE_PLAN_TAG, 'aboutToAppear - 加载所有课程');
    this.allCourses = this.service.getAllCourses();
    hilog.info(CREATE_PLAN_DOMAIN, CREATE_PLAN_TAG, '课程加载完成, 数量: %{public}d', this.allCourses.length);
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部栏
        Row() {
          Button($r('app.string.back_text')).height(32).onClick(() => { this.router.pop(); })
          Text($r('app.string.create_plan_title'))
            .fontSize(22).fontWeight(FontWeight.Bold).margin({ left: 12 })
        }.width('100%').padding({ left: 16, right: 16, top: 16, bottom: 8 })

        Scroll() {
          Column({ space: 16 }) {
            // 计划名称
            Column({ space: 8 }) {
              Text($r('app.string.plan_name_label'))
                .fontSize(16).fontWeight(FontWeight.Bold)
              TextInput({ placeholder: getContext(this).resourceManager.getStringSync($r('app.string.plan_name_placeholder')) })
                .width('100%').height(44)
                .onChange((value: string) => { this.planName = value; })
            }.width('100%').padding(16).backgroundColor(Color.White).borderRadius(12)

            // 目标选择
            Column({ space: 8 }) {
              Text($r('app.string.goal_select_label'))
                .fontSize(16).fontWeight(FontWeight.Bold)
              Row({ space: 8 }) {
                ForEach(this.goalOptions, (goal: string) => {
                  Text(this.getGoalDisplayName(goal))
                    .fontSize(14)
                    .fontColor(this.selectedGoal === goal ? $r('app.color.text_white') : $r('app.color.primary_blue'))
                    .backgroundColor(this.selectedGoal === goal ? $r('app.color.primary_blue') : Color.White)
                    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                    .borderRadius(20)
                    .border({ width: 1, color: $r('app.color.primary_blue') })
                    .onClick(() => { this.selectedGoal = goal; })
                })
              }
            }.width('100%').padding(16).backgroundColor(Color.White).borderRadius(12)
            .alignItems(HorizontalAlign.Start)

            // 持续时间
            Column({ space: 8 }) {
              Text($r('app.string.duration_label'))
                .fontSize(16).fontWeight(FontWeight.Bold)
              Row({ space: 8 }) {
                ForEach(this.durationOptions, (days: number) => {
                  Row() {
                    Text(days.toString())
                      .fontSize(14)
                      .fontColor(this.durationDays === days ? $r('app.color.text_white') : $r('app.color.primary_blue'))
                    Text($r('app.string.unit_day'))
                      .fontSize(14)
                      .fontColor(this.durationDays === days ? $r('app.color.text_white') : $r('app.color.primary_blue'))
                  }
                    .backgroundColor(this.durationDays === days ? $r('app.color.primary_blue') : Color.White)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .borderRadius(20)
                    .border({ width: 1, color: $r('app.color.primary_blue') })
                    .onClick(() => { this.durationDays = days; })
                })
              }
            }.width('100%').padding(16).backgroundColor(Color.White).borderRadius(12)
            .alignItems(HorizontalAlign.Start)

            // 选择课程
            Column({ space: 8 }) {
              Text($r('app.string.select_courses_label'))
                .fontSize(16).fontWeight(FontWeight.Bold)
              ForEach(this.allCourses, (course: Course) => {
                Row() {
                  Column({ space: 2 }) {
                    Text(course.title).fontSize(15).fontWeight(FontWeight.Medium)
                    Text(course.duration.toString())
                      .fontSize(12).fontColor($r('app.color.text_gray'))
                    Text($r('app.string.duration_unit_join'))
                      .fontSize(12).fontColor($r('app.color.text_gray'))
                    Text(course.calories.toString())
                      .fontSize(12).fontColor($r('app.color.text_gray'))
                    Text($r('app.string.calories_unit_suffix'))
                      .fontSize(12).fontColor($r('app.color.text_gray'))
                  }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                  Checkbox()
                    .select(this.isCourseSelected(course.id))
                    .onChange((checked: boolean) => {
                      this.toggleCourse(course.id, checked);
                    })
                }
                .padding({ top: 8, bottom: 8 })
                .width('100%')
              })
            }.width('100%').padding(16).backgroundColor(Color.White).borderRadius(12)
            .alignItems(HorizontalAlign.Start)

            // 创建按钮
            Button($r('app.string.create_plan_confirm'))
              .width('100%').height(48).margin({ top: 8 })
              .onClick(() => {
                hilog.info(CREATE_PLAN_DOMAIN, CREATE_PLAN_TAG, '点击创建计划 - planName: %{public}s, goal: %{public}s, days: %{public}d, courses: %{public}d',
                  this.planName, this.selectedGoal, this.durationDays, this.selectedCourseIds.length);
                if (this.planName.length === 0 || this.selectedCourseIds.length === 0) {
                  hilog.warn(CREATE_PLAN_DOMAIN, CREATE_PLAN_TAG, '计划信息不完整 - planName为空: %{public}s, courses为空: %{public}s',
                    (this.planName.length === 0).toString(), (this.selectedCourseIds.length === 0).toString());
                  promptAction.showToast({ message: getContext(this).resourceManager.getStringSync($r('app.string.plan_info_incomplete_hint')) });
                  return;
                }
                this.service.createCustomPlan(this.planName, this.selectedGoal,
                  this.durationDays, this.selectedCourseIds);
                hilog.info(CREATE_PLAN_DOMAIN, CREATE_PLAN_TAG, '计划创建成功, 返回上一页');
                this.router.pop();
              })
          }.padding(16)
        }.layoutWeight(1)
      }.width('100%').height('100%').backgroundColor($r('app.color.page_background'))
    }.hideTitleBar(true)
  }

  isCourseSelected(courseId: number): boolean {
    for (let i = 0; i < this.selectedCourseIds.length; i++) {
      if (this.selectedCourseIds[i] === courseId) {
        return true;
      }
    }
    return false;
  }

  toggleCourse(courseId: number, checked: boolean): void {
    hilog.info(CREATE_PLAN_DOMAIN, CREATE_PLAN_TAG, '切换课程选择 - courseId: %{public}d, checked: %{public}s', courseId, checked.toString());
    if (checked) {
      if (!this.isCourseSelected(courseId)) {
        let newIds: number[] = [];
        for (let i = 0; i < this.selectedCourseIds.length; i++) {
          newIds.push(this.selectedCourseIds[i]);
        }
        newIds.push(courseId);
        this.selectedCourseIds = newIds;
      }
    } else {
      let newIds: number[] = [];
      for (let i = 0; i < this.selectedCourseIds.length; i++) {
        if (this.selectedCourseIds[i] !== courseId) {
          newIds.push(this.selectedCourseIds[i]);
        }
      }
      this.selectedCourseIds = newIds;
    }
  }
}
