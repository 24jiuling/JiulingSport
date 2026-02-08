
import { Course } from 'lib_entity';
import { FitnessService } from 'lib_api';
import { RouterManager } from 'lib_router';

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

  aboutToAppear() {
    this.allCourses = this.service.getAllCourses();
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
              TextInput({ placeholder: '请输入计划名称' })
                .width('100%').height(44)
                .onChange((value: string) => { this.planName = value; })
            }.width('100%').padding(16).backgroundColor(Color.White).borderRadius(12)

            // 目标选择
            Column({ space: 8 }) {
              Text($r('app.string.goal_select_label'))
                .fontSize(16).fontWeight(FontWeight.Bold)
              Row({ space: 8 }) {
                ForEach(this.goalOptions, (goal: string) => {
                  Text(goal)
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
                  Text(days.toString() + '天')
                    .fontSize(14)
                    .fontColor(this.durationDays === days ? $r('app.color.text_white') : $r('app.color.primary_blue'))
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
                    Text(course.duration.toString() + '分钟 · ' + course.calories.toString() + '千卡')
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
              .enabled(this.planName.length > 0 && this.selectedCourseIds.length > 0)
              .onClick(() => {
                this.service.createCustomPlan(this.planName, this.selectedGoal,
                  this.durationDays, this.selectedCourseIds);
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
