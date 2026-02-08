
import { Badge } from 'lib_entity';
import { FitnessService, UserService } from 'lib_api';
import { RouterManager } from 'lib_router';

@Component
export struct BadgeGalleryPage {
  private service: FitnessService = FitnessService.getInstance();
  private userService: UserService = UserService.getInstance();
  private router: RouterManager = RouterManager.getInstance();
  @State badges: Badge[] = [];
  @State selectedBadge: Badge | null = null;
  @State showDetail: boolean = false;

  aboutToAppear() {
    this.badges = this.service.getAllBadges();
    // 尝试检查新徽章
    let user = this.userService.getCurrentUser();
    if (user !== null) {
      this.service.checkAndUnlockBadges(user);
      this.badges = this.service.getAllBadges();
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部栏
        Row() {
          Button($r('app.string.back_text')).height(32).onClick(() => { this.router.pop(); })
          Text($r('app.string.badge_gallery_title'))
            .fontSize(22).fontWeight(FontWeight.Bold).margin({ left: 12 })
        }.width('100%').padding({ left: 16, right: 16, top: 16, bottom: 8 })

        // 统计概览
        Row() {
          Column() {
            Text(this.getUnlockedCount().toString())
              .fontSize(28).fontWeight(FontWeight.Bold).fontColor($r('app.color.badge_unlocked'))
            Text($r('app.string.badge_unlocked_label'))
              .fontSize(12).fontColor($r('app.color.text_gray'))
          }.layoutWeight(1)
          Column() {
            Text(this.badges.length.toString())
              .fontSize(28).fontWeight(FontWeight.Bold)
            Text($r('app.string.badge_total_label'))
              .fontSize(12).fontColor($r('app.color.text_gray'))
          }.layoutWeight(1)
          Column() {
            Text(this.getProgressPercent())
              .fontSize(28).fontWeight(FontWeight.Bold).fontColor($r('app.color.primary_blue'))
            Text($r('app.string.badge_completion_label'))
              .fontSize(12).fontColor($r('app.color.text_gray'))
          }.layoutWeight(1)
        }.width('90%').padding(16).backgroundColor(Color.White).borderRadius(12)
        .shadow({ radius: 4, color: $r('app.color.shadow_color_light'), offsetY: 2 })
        .margin({ top: 12, bottom: 12 })

        // 徽章网格
        Scroll() {
          Column({ space: 12 }) {
            // 打卡类徽章
            Text($r('app.string.badge_category_streak'))
              .fontSize(16).fontWeight(FontWeight.Bold).width('100%').padding({ left: 20 })
            this.BadgeGrid(this.getBadgesByCategory('streak'))

            // 训练类徽章
            Text($r('app.string.badge_category_training'))
              .fontSize(16).fontWeight(FontWeight.Bold).width('100%').padding({ left: 20 })
            this.BadgeGrid(this.getBadgesByCategory('training'))

            // 卡路里类徽章
            Text($r('app.string.badge_category_calorie'))
              .fontSize(16).fontWeight(FontWeight.Bold).width('100%').padding({ left: 20 })
            this.BadgeGrid(this.getBadgesByCategory('calorie'))

            // 特殊徽章
            Text($r('app.string.badge_category_special'))
              .fontSize(16).fontWeight(FontWeight.Bold).width('100%').padding({ left: 20 })
            this.BadgeGrid(this.getBadgesByCategory('special'))
          }.padding({ bottom: 20 })
        }.layoutWeight(1)

        // 徽章详情弹窗
        if (this.showDetail && this.selectedBadge !== null) {
          Column() {
            Column({ space: 12 }) {
              Circle({ width: 80, height: 80 })
                .fill(this.selectedBadge.isUnlocked ? $r('app.color.badge_unlocked') : $r('app.color.badge_locked'))
              Text(this.selectedBadge.name)
                .fontSize(20).fontWeight(FontWeight.Bold)
              Text(this.selectedBadge.description)
                .fontSize(14).fontColor($r('app.color.text_gray'))
              Text(this.selectedBadge.unlockCondition)
                .fontSize(13).fontColor($r('app.color.primary_blue'))
              if (this.selectedBadge.isUnlocked) {
                Text('解锁日期：' + this.selectedBadge.unlockDate)
                  .fontSize(12).fontColor($r('app.color.text_gray'))
              }
              Button($r('app.string.close_btn'))
                .width('60%').height(36)
                .onClick(() => { this.showDetail = false; })
            }
            .padding(24).backgroundColor(Color.White).borderRadius(16)
            .shadow({ radius: 16, color: $r('app.color.shadow_color_dark'), offsetY: 4 })
          }
          .width('100%').height('100%')
          .backgroundColor('#80000000')
          .justifyContent(FlexAlign.Center)
          .position({ x: 0, y: 0 })
          .onClick(() => { this.showDetail = false; })
        }
      }.width('100%').height('100%').backgroundColor($r('app.color.page_background'))
    }.hideTitleBar(true)
  }

  @Builder BadgeGrid(badgeList: Badge[]) {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
      ForEach(badgeList, (badge: Badge) => {
        Column({ space: 4 }) {
          Circle({ width: 52, height: 52 })
            .fill(badge.isUnlocked ? $r('app.color.badge_unlocked') : $r('app.color.badge_locked'))
          Text(badge.name).fontSize(11)
            .fontColor(badge.isUnlocked ? $r('app.color.text_black') : $r('app.color.text_light_gray'))
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('25%').padding(8).alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.selectedBadge = badge;
          this.showDetail = true;
        })
      })
    }.width('90%').backgroundColor(Color.White).borderRadius(12).padding(8)
  }

  getUnlockedCount(): number {
    let count: number = 0;
    for (let i = 0; i < this.badges.length; i++) {
      if (this.badges[i].isUnlocked) {
        count = count + 1;
      }
    }
    return count;
  }

  getProgressPercent(): string {
    if (this.badges.length === 0) {
      return '0%';
    }
    return Math.round((this.getUnlockedCount() / this.badges.length) * 100).toString() + '%';
  }

  getBadgesByCategory(category: string): Badge[] {
    let result: Badge[] = [];
    for (let i = 0; i < this.badges.length; i++) {
      if (this.badges[i].category === category) {
        result.push(this.badges[i]);
      }
    }
    return result;
  }
}
