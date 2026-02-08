
import { UserService } from 'lib_api';
import { RouterManager } from 'lib_router';

@Component
export struct GoalSettingPage {
  private userService: UserService = UserService.getInstance();
  private router: RouterManager = RouterManager.getInstance();
  @State selectedGoal: string = '';
  private goalOptions: string[] = ['减脂', '增肌', '提升耐力'];

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column({ space: 24 }) {
            // 标题区
            Column({ space: 8 }) {
              Text($r('app.string.goal_setting_title'))
                .fontSize(28).fontWeight(FontWeight.Bold)
              Text($r('app.string.goal_setting_subtitle'))
                .fontSize(14).fontColor($r('app.color.text_gray'))
            }.margin({ top: 60 })

            // 目标选择卡片
            ForEach(this.goalOptions, (goal: string) => {
              Row() {
                Column({ space: 4 }) {
                  Text(this.getGoalIcon(goal)).fontSize(32)
                }.width(60)
                Column({ space: 4 }) {
                  Text(goal).fontSize(18).fontWeight(FontWeight.Bold)
                  Text(this.getGoalDescription(goal))
                    .fontSize(13).fontColor($r('app.color.text_gray'))
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                if (this.selectedGoal === goal) {
                  Text('✓').fontSize(22).fontColor($r('app.color.primary_blue'))
                }
              }
              .width('85%').padding(16).backgroundColor(Color.White).borderRadius(16)
              .border({
                width: 2,
                color: this.selectedGoal === goal ? $r('app.color.primary_blue') : Color.Transparent
              })
              .shadow({ radius: 4, color: $r('app.color.shadow_color_light'), offsetY: 2 })
              .onClick(() => { this.selectedGoal = goal; })
            })

            // 确认按钮
            Button($r('app.string.goal_confirm_btn'))
              .width('85%').height(48).margin({ top: 20 })
              .enabled(this.selectedGoal.length > 0)
              .onClick(() => {
                this.userService.setGoal(this.selectedGoal);
                this.router.pop();
              })

            // 跳过
            Text($r('app.string.skip_text'))
              .fontSize(14).fontColor($r('app.color.text_gray'))
              .onClick(() => { this.router.pop(); })
          }.width('100%')
        }.layoutWeight(1)
      }.width('100%').height('100%').backgroundColor($r('app.color.page_background'))
    }.hideTitleBar(true)
  }

  getGoalIcon(goal: string): string {
    if (goal === '减脂') {
      return '🔥';
    } else if (goal === '增肌') {
      return '💪';
    }
    return '🏃';
  }

  getGoalDescription(goal: string): string {
    if (goal === '减脂') {
      return '通过有氧运动和HIIT训练减少体脂';
    } else if (goal === '增肌') {
      return '通过力量训练增加肌肉量和力量';
    }
    return '通过持续训练提升心肺功能和耐力';
  }
}
