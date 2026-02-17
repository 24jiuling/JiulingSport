
import { ExerciseRecord } from 'lib_entity';
import { FitnessService } from 'lib_api';
import { RouterManager } from 'lib_router';

@Component
export struct ExerciseHistoryPage {
  private service: FitnessService = FitnessService.getInstance();
  private router: RouterManager = RouterManager.getInstance();
  @State records: ExerciseRecord[] = [];
  @State weeklyStats: number[] = [0, 0, 0]; // [count, duration, calories]

  aboutToAppear() {
    this.records = this.service.getRecords();
    this.weeklyStats = this.service.getWeeklyStats();
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部栏
        Row() {
          Button($r('app.string.back_text')).height(32).onClick(() => { this.router.pop(); })
          Text($r('app.string.exercise_history_title'))
            .fontSize(22).fontWeight(FontWeight.Bold).margin({ left: 12 })
        }.width('100%').padding({ left: 16, right: 16, top: 16, bottom: 8 })

        // 本周统计卡片
        Column({ space: 8 }) {
          Text($r('app.string.weekly_summary_title'))
            .fontSize(16).fontWeight(FontWeight.Bold).width('100%')
          Row() {
            Column() {
              Text(this.weeklyStats[0].toString())
                .fontSize(24).fontWeight(FontWeight.Bold).fontColor($r('app.color.primary_blue'))
              Text($r('app.string.stat_workouts'))
                .fontSize(12).fontColor($r('app.color.text_gray'))
            }.layoutWeight(1)
            Column() {
              Text(this.weeklyStats[1].toString())
                .fontSize(24).fontWeight(FontWeight.Bold).fontColor($r('app.color.plan_ongoing_bg'))
              Text($r('app.string.stat_minutes'))
                .fontSize(12).fontColor($r('app.color.text_gray'))
            }.layoutWeight(1)
            Column() {
              Text(this.weeklyStats[2].toString())
                .fontSize(24).fontWeight(FontWeight.Bold).fontColor($r('app.color.badge_unlocked'))
              Text($r('app.string.stat_kcal'))
                .fontSize(12).fontColor($r('app.color.text_gray'))
            }.layoutWeight(1)
          }.width('100%')
        }.width('90%').padding(16).backgroundColor(Color.White).borderRadius(12)
        .shadow({ radius: 4, color: $r('app.color.shadow_color_light'), offsetY: 2 })
        .margin({ top: 12, bottom: 12 })

        // 记录列表
        Text($r('app.string.all_records_title'))
          .fontSize(16).fontWeight(FontWeight.Bold).width('90%').margin({ bottom: 8 })

        List({ space: 8 }) {
          ForEach(this.records, (record: ExerciseRecord) => {
            ListItem() {
              Row() {
                // 左侧运动类型图标
                Column() {
                  Text(this.getTypeIcon(record.type))
                    .fontSize(24)
                }.width(48).height(48).justifyContent(FlexAlign.Center)
                .backgroundColor(record.isManual ? $r('app.color.plan_ongoing_bg') : $r('app.color.primary_blue'))
                .borderRadius(12)

                // 中间信息
                Column({ space: 4 }) {
                  Row() {
                    Text(record.type).fontSize(16).fontWeight(FontWeight.Bold)
                    if (record.isManual) {
                      Text($r('app.string.manual_tag'))
                        .fontSize(10).fontColor($r('app.color.plan_ongoing_bg'))
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .borderRadius(4).backgroundColor($r('app.color.status_ongoing_bg'))
                        .margin({ left: 8 })
                    }
                  }
                  Text(record.date).fontSize(12).fontColor($r('app.color.text_gray'))
                  if (record.notes.length > 0) {
                    Text(record.notes).fontSize(11).fontColor($r('app.color.text_light_gray'))
                      .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                }.layoutWeight(1).alignItems(HorizontalAlign.Start).margin({ left: 12 })

                // 右侧数据
                Column({ space: 2 }) {
                  Row() {
                    Text(record.duration.toString())
                      .fontSize(13).fontColor($r('app.color.text_gray'))
                    Text($r('app.string.unit_min'))
                      .fontSize(13).fontColor($r('app.color.text_gray'))
                  }
                  Row() {
                    Text(record.calories.toString())
                      .fontSize(13).fontWeight(FontWeight.Bold).fontColor($r('app.color.primary_blue'))
                    Text($r('app.string.unit_kcal'))
                      .fontSize(13).fontWeight(FontWeight.Bold).fontColor($r('app.color.primary_blue'))
                  }
                }.alignItems(HorizontalAlign.End)
              }
              .padding(12).backgroundColor(Color.White).borderRadius(12).width('100%')
              .shadow({ radius: 2, color: $r('app.color.shadow_color_light'), offsetY: 1 })
            }
          })
        }.width('90%').layoutWeight(1)
      }.width('100%').height('100%').backgroundColor($r('app.color.page_background'))
    }.hideTitleBar(true)
  }

  getTypeIcon(type: string): string {
    if (type === '瑜伽') {
      return '🧘';
    } else if (type === '跑步') {
      return '🏃';
    } else if (type === 'HIIT' || type === 'HIIT燃脂') {
      return '🔥';
    } else if (type === '游泳') {
      return '🏊';
    } else if (type === '骑行') {
      return '🚴';
    } else if (type === '力量训练') {
      return '💪';
    }
    return '🏅';
  }
}
