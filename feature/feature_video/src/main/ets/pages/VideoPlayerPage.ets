import { RouterManager } from 'lib_router';

@Component
export struct VideoPlayerPage {
  @Prop title: string = '';
  @Prop videoUrl: string = '';

  private router: RouterManager = RouterManager.getInstance();

  build() {
    NavDestination() {
      Column() {
        Row() {
          Button($r('app.string.back_text'))
            .height(32)
            .onClick(() => {
              this.router.pop();
            })

          Text($r('app.string.video_page_title'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 12 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 8 })

        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .padding({ left: 16, right: 16, bottom: 8 })
          .width('100%')

        // 视频播放区域
        Video({ src: this.videoUrl })
          .width('100%')
          .height(220)
          .autoPlay(true)
          .controls(true)

        Text($r('app.string.video_tip'))
          .fontSize(12)
          .fontColor($r('app.color.text_gray'))
          .padding({ left: 16, right: 16, top: 12 })
          .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_background'))
    }
    .hideTitleBar(true)
  }
}
