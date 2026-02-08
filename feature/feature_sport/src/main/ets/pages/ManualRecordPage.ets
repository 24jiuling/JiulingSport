
import { FitnessService, UserService } from 'lib_api';
import { RouterManager } from 'lib_router';

@Component
export struct ManualRecordPage {
  private service: FitnessService = FitnessService.getInstance();
  private userService: UserService = UserService.getInstance();
  private router: RouterManager = RouterManager.getInstance();
  @State exerciseType: string = '';
  @State durationMinutes: string = '';
  @State caloriesBurned: string = '';
  @State notes: string = '';
  @State isSubmitted: boolean = false;
  private exerciseTypes: string[] = ['跑步', '游泳', '骑行', '跳绳', '球类', '舞蹈', '登山', '其他'];

  build() {
    NavDestination() {
      Column() {
        // 顶部栏
        Row() {
          Button($r('app.string.back_text')).height(32).onClick(() => { this.router.pop(); })
          Text($r('app.string.manual_record_title'))
            .fontSize(22).fontWeight(FontWeight.Bold).margin({ left: 12 })
        }.width('100%').padding({ left: 16, right: 16, top: 16, bottom: 8 })

        if (this.isSubmitted) {
          // 提交成功界面
          Column({ space: 16 }) {
            Text('✅').fontSize(64)
            Text($r('app.string.record_saved_success'))
              .fontSize(20).fontWeight(FontWeight.Bold)
            Text(this.exerciseType + ' · ' + this.durationMinutes + '分钟 · ' + this.caloriesBurned + '千卡')
              .fontSize(14).fontColor($r('app.color.text_gray'))
            Button($r('app.string.back_text')).width('60%').height(44)
              .onClick(() => { this.router.pop(); })
          }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: 16 }) {
              // 运动类型选择
              Column({ space: 8 }) {
                Text($r('app.string.exercise_type_label'))
                  .fontSize(16).fontWeight(FontWeight.Bold)
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.exerciseTypes, (type: string) => {
                    Text(type)
                      .fontSize(14)
                      .fontColor(this.exerciseType === type ? $r('app.color.text_white') : $r('app.color.primary_blue'))
                      .backgroundColor(this.exerciseType === type ? $r('app.color.primary_blue') : Color.White)
                      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                      .borderRadius(20)
                      .border({ width: 1, color: $r('app.color.primary_blue') })
                      .margin({ right: 8, bottom: 8 })
                      .onClick(() => { this.exerciseType = type; })
                  })
                }.width('100%')
              }.width('100%').padding(16).backgroundColor(Color.White).borderRadius(12)
              .alignItems(HorizontalAlign.Start)

              // 运动时长
              Column({ space: 8 }) {
                Text($r('app.string.duration_input_label'))
                  .fontSize(16).fontWeight(FontWeight.Bold)
                Row() {
                  TextInput({ placeholder: '请输入时长' })
                    .type(InputType.Number).layoutWeight(1).height(44)
                    .onChange((value: string) => { this.durationMinutes = value; })
                  Text($r('app.string.unit_min')).fontSize(14).margin({ left: 8 })
                    .fontColor($r('app.color.text_gray'))
                }.width('100%')
              }.width('100%').padding(16).backgroundColor(Color.White).borderRadius(12)
              .alignItems(HorizontalAlign.Start)

              // 消耗卡路里
              Column({ space: 8 }) {
                Text($r('app.string.calories_input_label'))
                  .fontSize(16).fontWeight(FontWeight.Bold)
                Row() {
                  TextInput({ placeholder: '请输入消耗卡路里' })
                    .type(InputType.Number).layoutWeight(1).height(44)
                    .onChange((value: string) => { this.caloriesBurned = value; })
                  Text($r('app.string.unit_kcal')).fontSize(14).margin({ left: 8 })
                    .fontColor($r('app.color.text_gray'))
                }.width('100%')
              }.width('100%').padding(16).backgroundColor(Color.White).borderRadius(12)
              .alignItems(HorizontalAlign.Start)

              // 备注
              Column({ space: 8 }) {
                Text($r('app.string.notes_label'))
                  .fontSize(16).fontWeight(FontWeight.Bold)
                TextInput({ placeholder: '可选：添加备注' })
                  .width('100%').height(44)
                  .onChange((value: string) => { this.notes = value; })
              }.width('100%').padding(16).backgroundColor(Color.White).borderRadius(12)
              .alignItems(HorizontalAlign.Start)

              // 提交按钮
              Button($r('app.string.submit_record_btn'))
                .width('100%').height(48)
                .enabled(this.exerciseType.length > 0 && this.durationMinutes.length > 0 &&
                  this.caloriesBurned.length > 0)
                .onClick(() => {
                  let duration: number = parseInt(this.durationMinutes);
                  let calories: number = parseInt(this.caloriesBurned);
                  this.service.createManualRecord(this.exerciseType, duration, calories, this.notes);
                  this.userService.updateStats(duration, calories);
                  if (!this.userService.isTodayCheckedIn()) {
                    this.userService.checkIn();
                  }
                  this.isSubmitted = true;
                })
            }.padding(16)
          }.layoutWeight(1)
        }
      }.width('100%').height('100%').backgroundColor($r('app.color.page_background'))
    }.hideTitleBar(true)
  }
}
