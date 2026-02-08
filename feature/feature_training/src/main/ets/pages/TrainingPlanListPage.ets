
import { TrainingPlan } from 'lib_entity';
import { FitnessService } from 'lib_api';
import { RouterManager, RouterKey } from 'lib_router';
import { TrainingParam } from '../model/TrainingParam';

@Component
export struct TrainingPlanListPage {
  private service: FitnessService = FitnessService.getInstance();
  private router: RouterManager = RouterManager.getInstance();
  @State plans: TrainingPlan[] = [];
  @State selectedTab: number = 0;

  aboutToAppear() {
    this.plans = this.service.getRecommendedPlans();
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部栏
        Row() {
          Button($r('app.string.back_text')).height(32).onClick(() => { this.router.pop(); })
          Text($r('app.string.training_plan_title'))
            .fontSize(22).fontWeight(FontWeight.Bold).margin({ left: 12 }).layoutWeight(1)
          Button($r('app.string.create_plan_btn')).height(32).fontSize(12)
            .onClick(() => { this.router.push(RouterKey.CREATE_PLAN); })
        }.width('100%').padding({ left: 16, right: 16, top: 16, bottom: 8 })

        // 标签切换: 推荐 / 自定义
        Row() {
          Text($r('app.string.tab_recommended'))
            .fontSize(14).fontWeight(this.selectedTab === 0 ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.selectedTab === 0 ? $r('app.color.primary_blue') : $r('app.color.text_gray'))
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(() => { this.selectedTab = 0; })
          Text($r('app.string.tab_custom'))
            .fontSize(14).fontWeight(this.selectedTab === 1 ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.selectedTab === 1 ? $r('app.color.primary_blue') : $r('app.color.text_gray'))
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(() => { this.selectedTab = 1; })
        }.width('100%').padding({ left: 8 })

        // 计划列表
        List({ space: 12 }) {
          ForEach(this.getFilteredPlans(), (plan: TrainingPlan) => {
            ListItem() {
              Column({ space: 8 }) {
                Row() {
                  Text(plan.name).fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1)
                  Text(this.getStatusText(plan.status))
                    .fontSize(12)
                    .fontColor(plan.status === 'ongoing' ? $r('app.color.primary_blue') : $r('app.color.text_gray'))
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(10)
                    .backgroundColor(plan.status === 'ongoing' ? $r('app.color.status_ongoing_bg') : $r('app.color.page_background'))
                }.width('100%')

                Text(plan.description).fontSize(14).fontColor($r('app.color.text_gray')).maxLines(2)

                Row() {
                  Text(plan.targetGoal).fontSize(12).fontColor($r('app.color.primary_blue'))
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .borderRadius(8).backgroundColor($r('app.color.status_ongoing_bg'))
                  Blank()
                  Text(plan.durationDays.toString() + '天').fontSize(12).fontColor($r('app.color.text_gray'))
                }.width('100%')

                if (plan.status === 'ongoing') {
                  Column({ space: 4 }) {
                    Row() {
                      Text($r('app.string.progress_label')).fontSize(12).fontColor($r('app.color.text_gray'))
                      Blank()
                      Text(plan.progress.toString() + '%').fontSize(12).fontColor($r('app.color.primary_blue'))
                    }.width('100%')
                    Progress({ value: plan.progress, total: 100, type: ProgressType.Linear })
                      .width('100%').color($r('app.color.primary_blue'))
                  }
                }
              }
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .shadow({ radius: 4, color: $r('app.color.shadow_color_light'), offsetY: 2 })
              .onClick(() => {
                let param = new TrainingParam(plan.id);
                this.router.push(RouterKey.PLAN_DETAIL, param);
              })
            }
          })
        }.width('90%').layoutWeight(1).margin({ top: 12 })
      }.width('100%').height('100%').backgroundColor($r('app.color.page_background'))
    }.hideTitleBar(true)
  }

  getFilteredPlans(): TrainingPlan[] {
    let result: TrainingPlan[] = [];
    for (let i = 0; i < this.plans.length; i++) {
      if (this.selectedTab === 0 && !this.plans[i].isCustom) {
        result.push(this.plans[i]);
      } else if (this.selectedTab === 1 && this.plans[i].isCustom) {
        result.push(this.plans[i]);
      }
    }
    return result;
  }

  getStatusText(status: string): string {
    if (status === 'ongoing') {
      return '进行中';
    } else if (status === 'completed') {
      return '已完成';
    }
    return '未开始';
  }
}
