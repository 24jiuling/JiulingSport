
import { Course, TrainingPlan } from 'lib_entity';
import { FitnessService } from 'lib_api';
import { RouterManager, RouterKey } from 'lib_router';
import { SportParam } from 'feature_sport';
import { TrainingParam } from 'feature_training';

@Component
export struct CourseList {
  private service: FitnessService = FitnessService.getInstance();
  private router: RouterManager = RouterManager.getInstance();
  @State courses: Course[] = [];
  @State plans: TrainingPlan[] = [];
  @State activePlan: TrainingPlan | null = null;
  @State selectedCategory: string = '全部';
  private categories: string[] = ['全部', '减脂', '增肌', '耐力', '柔韧'];

  aboutToAppear() {
    this.courses = this.service.getAllCourses();
    this.plans = this.service.getRecommendedPlans();
    this.activePlan = this.service.getActivePlan();
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text($r('app.string.training_tab_title'))
          .fontSize(24).fontWeight(FontWeight.Bold).layoutWeight(1)
        Button($r('app.string.menu_my_plans'))
          .fontSize(12).height(32)
          .onClick(() => { this.router.push(RouterKey.TRAINING_PLAN_LIST); })
      }.padding({ left: 20, right: 20, top: 16, bottom: 8 }).width('100%')

      // 进行中的计划
      if (this.activePlan !== null) {
        Column({ space: 6 }) {
          Text(this.activePlan.name)
            .fontSize(18).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_white'))
          Text(this.activePlan.description)
            .fontSize(13).fontColor($r('app.color.plan_text_secondary'))
          Row() {
            Text($r('app.string.progress_label')).fontSize(12).fontColor($r('app.color.plan_text_secondary'))
            Blank()
            Text(this.activePlan.progress.toString() + '%')
              .fontSize(12).fontColor($r('app.color.text_white'))
          }.width('100%')
          Progress({ value: this.activePlan.progress, total: 100, type: ProgressType.Linear })
            .width('100%').color($r('app.color.text_white'))
          Button($r('app.string.continue_training_btn'))
            .width('100%').height(36).fontSize(13).margin({ top: 4 })
            .backgroundColor('#40FFFFFF').fontColor($r('app.color.text_white'))
            .onClick(() => {
              if (this.activePlan !== null) {
                let param = new TrainingParam(this.activePlan.id);
                this.router.push(RouterKey.PLAN_DETAIL, param);
              }
            })
        }
        .width('90%').padding(16).backgroundColor($r('app.color.plan_ongoing_bg'))
        .borderRadius(12).margin({ bottom: 12 }).alignItems(HorizontalAlign.Start)
      }

      // 课程分类标签
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.categories, (cat: string) => {
            Text(cat)
              .fontSize(13)
              .fontColor(this.selectedCategory === cat ? $r('app.color.text_white') : $r('app.color.primary_blue'))
              .backgroundColor(this.selectedCategory === cat ? $r('app.color.primary_blue') : Color.White)
              .padding({ left: 14, right: 14, top: 6, bottom: 6 })
              .borderRadius(16)
              .border({ width: 1, color: $r('app.color.primary_blue') })
              .onClick(() => { this.selectedCategory = cat; })
          })
        }.padding({ left: 20, right: 20 })
      }.scrollable(ScrollDirection.Horizontal).width('100%').height(40).margin({ bottom: 8 })

      // 课程标题
      Text($r('app.string.all_courses_title'))
        .fontSize(18).fontWeight(FontWeight.Bold)
        .padding({ left: 20, bottom: 10 }).width('100%')

      // 课程列表
      List({ space: 12 }) {
        ForEach(this.getFilteredCourses(), (item: Course) => {
          ListItem() {
            Column() {
              Row() {
                Column()
                  .width('100%').height(120)
                  .backgroundColor($r('app.color.placeholder_bg'))
                  .borderRadius({ topLeft: 12, topRight: 12 })
              }
              Column({ space: 5 }) {
                Row() {
                  Text(item.title).fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1)
                  if (item.difficulty.length > 0) {
                    Text(item.difficulty).fontSize(10)
                      .fontColor($r('app.color.primary_blue'))
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .borderRadius(4).backgroundColor($r('app.color.status_ongoing_bg'))
                  }
                }.width('100%')
                Text(item.description).fontSize(13).fontColor($r('app.color.text_gray'))
                  .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                Row() {
                  Text(item.duration.toString() + '分钟')
                    .fontSize(14).fontColor($r('app.color.text_gray'))
                  Blank()
                  Text(item.calories.toString() + '千卡')
                    .fontSize(14).fontColor($r('app.color.text_gray'))
                  Blank()
                  Button($r('app.string.start_button')).fontSize(11).height(26)
                    .onClick(() => {
                      let param: SportParam = new SportParam(item.id, item.title, item.duration, item.calories);
                      this.router.push(RouterKey.ACTIVE_TRAINING, param);
                    })
                }.width('100%')
              }.padding(12)
            }
            .backgroundColor(Color.White).borderRadius(12)
            .shadow({ radius: 4, color: $r('app.color.shadow_color_light'), offsetY: 2 })
          }
        })
      }.width('90%').layoutWeight(1)
    }.width('100%').height('100%').backgroundColor($r('app.color.page_background'))
  }

  getFilteredCourses(): Course[] {
    if (this.selectedCategory === '全部') {
      return this.courses;
    }
    let result: Course[] = [];
    for (let i = 0; i < this.courses.length; i++) {
      if (this.courses[i].category === this.selectedCategory) {
        result.push(this.courses[i]);
      }
    }
    return result;
  }
}


