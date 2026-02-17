import { RouterManager } from 'lib_router';
import { VideoPlayProgress } from 'lib_entity';
import { VideoSyncService } from 'lib_api';
import { hilog } from '@kit.PerformanceAnalysisKit';

const VIDEO_TAG: string = 'VideoPlayerPage';

@Component
export struct VideoPlayerPage {
  @Prop title: string = '';
  @Prop videoUrl: string = '';
  @Prop courseId: number = 0;

  @State currentPosition: number = 0; // 当前播放位置（秒）
  @State totalDuration: number = 0; // 视频总时长（秒）
  @State isPlaying: boolean = false;
  @State syncStatusText: string = '';
  @State hasSyncedProgress: boolean = false;
  @State savedPosition: number = 0; // 从其他设备同步来的播放位置
  @State showSyncDialog: boolean = false;
  @State syncDeviceInfo: string = '';
  @State progressPercent: number = 0;

  private router: RouterManager = RouterManager.getInstance();
  private syncService: VideoSyncService = VideoSyncService.getInstance();
  private videoController: VideoController = new VideoController();
  private saveTimerId: number = -1;
  private isVideoReady: boolean = false;

  aboutToAppear(): void {
    // 尝试加载跨设备同步的播放进度
    this.loadSyncedProgress();
    // 注册远程数据变更监听
    this.registerSyncListener();
  }

  aboutToDisappear(): void {
    // 页面销毁前保存一次当前进度
    this.saveCurrentProgress();
    // 清除定时保存器
    if (this.saveTimerId !== -1) {
      clearInterval(this.saveTimerId);
      this.saveTimerId = -1;
    }
  }

  // 加载同步的播放进度
  private loadSyncedProgress(): void {
    this.syncService.getProgress(this.courseId).then((progress: VideoPlayProgress | null) => {
      if (progress !== null && progress.currentPosition > 0) {
        this.savedPosition = progress.currentPosition;
        this.syncDeviceInfo = progress.deviceInfo;
        this.showSyncDialog = true;
        this.syncStatusText = getContext(this).resourceManager.getStringSync($r('app.string.sync_progress_found_prefix')) + this.formatTime(progress.currentPosition);
        hilog.info(0x0000, VIDEO_TAG, 'Synced progress found: %{public}d seconds', progress.currentPosition);
      }
    });
  }

  // 注册远程数据变更监听
  private registerSyncListener(): void {
    this.syncService.onProgressChanged((courseId: number, progress: VideoPlayProgress) => {
      if (courseId === this.courseId) {
        this.syncStatusText = getContext(this).resourceManager.getStringSync($r('app.string.sync_remote_update'));
        hilog.info(0x0000, VIDEO_TAG, 'Remote progress update: %{public}d', progress.currentPosition);
      }
    });
  }

  // 保存当前播放进度
  private saveCurrentProgress(): void {
    if (this.currentPosition <= 0) {
      return;
    }
    let progress: VideoPlayProgress = new VideoPlayProgress(this.courseId, this.videoUrl, this.title);
    progress.currentPosition = this.currentPosition;
    progress.totalDuration = this.totalDuration;
    progress.deviceInfo = getContext(this).resourceManager.getStringSync($r('app.string.sync_current_device'));
    this.syncService.saveProgress(progress).then((success: boolean) => {
      if (success) {
        hilog.info(0x0000, VIDEO_TAG, 'Progress saved successfully at %{public}d', this.currentPosition);
      }
    });
  }

  // 开始定期保存进度（每5秒）
  private startPeriodicSave(): void {
    if (this.saveTimerId !== -1) {
      return;
    }
    this.saveTimerId = setInterval(() => {
      if (this.isPlaying && this.currentPosition > 0) {
        this.saveCurrentProgress();
      }
    }, 5000);
  }

  // 跳转到同步位置
  private seekToSyncedPosition(): void {
    if (this.savedPosition > 0 && this.isVideoReady) {
      this.videoController.setCurrentTime(this.savedPosition);
      this.currentPosition = this.savedPosition;
      this.syncStatusText = getContext(this).resourceManager.getStringSync($r('app.string.sync_seeked_prefix')) + this.formatTime(this.savedPosition);
      this.showSyncDialog = false;
    }
  }

  // 格式化时间显示
  private formatTime(seconds: number): string {
    let mins: number = Math.floor(seconds / 60);
    let secs: number = Math.floor(seconds % 60);
    let minStr: string = mins < 10 ? '0' + mins.toString() : mins.toString();
    let secStr: string = secs < 10 ? '0' + secs.toString() : secs.toString();
    return minStr + ':' + secStr;
  }

  // 判断是否为本地 rawfile 视频
  private isLocalVideo(): boolean {
    return !this.videoUrl.startsWith('http');
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部导航栏
        Row() {
          Button($r('app.string.back_text'))
            .height(32)
            .onClick(() => {
              this.saveCurrentProgress();
              this.router.pop();
            })

          Text($r('app.string.video_page_title'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 12 })
            .layoutWeight(1)

          // 同步状态指示器
          if (this.syncService.isReady()) {
            Row({ space: 4 }) {
              Text('🔄').fontSize(14)
              Text($r('app.string.video_sync_enabled'))
                .fontSize(11)
                .fontColor($r('app.color.success_green'))
            }
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 8 })

        // 视频标题
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .padding({ left: 16, right: 16, bottom: 8 })
          .width('100%')

        // 视频播放区域
        if (this.isLocalVideo()) {
          Video({ src: $rawfile(this.videoUrl), controller: this.videoController })
            .width('100%')
            .height(220)
            .autoPlay(false)
            .controls(true)
            .onPrepared((event) => {
              if (event !== undefined) {
                this.totalDuration = event.duration;
                this.isVideoReady = true;
                hilog.info(0x0000, VIDEO_TAG, 'Video prepared, duration: %{public}d', event.duration);
              }
            })
            .onUpdate((event) => {
              if (event !== undefined) {
                this.currentPosition = event.time;
                if (this.totalDuration > 0) {
                  this.progressPercent = Math.round((this.currentPosition / this.totalDuration) * 100);
                }
              }
            })
            .onStart(() => {
              this.isPlaying = true;
              this.startPeriodicSave();
            })
            .onPause(() => {
              this.isPlaying = false;
              this.saveCurrentProgress();
            })
            .onFinish(() => {
              this.isPlaying = false;
              this.saveCurrentProgress();
              this.syncStatusText = getContext(this).resourceManager.getStringSync($r('app.string.sync_play_complete'));
            })
        } else {
          Video({ src: this.videoUrl, controller: this.videoController })
            .width('100%')
            .height(220)
            .autoPlay(false)
            .controls(true)
            .onPrepared((event) => {
              if (event !== undefined) {
                this.totalDuration = event.duration;
                this.isVideoReady = true;
              }
            })
            .onUpdate((event) => {
              if (event !== undefined) {
                this.currentPosition = event.time;
                if (this.totalDuration > 0) {
                  this.progressPercent = Math.round((this.currentPosition / this.totalDuration) * 100);
                }
              }
            })
            .onStart(() => {
              this.isPlaying = true;
              this.startPeriodicSave();
            })
            .onPause(() => {
              this.isPlaying = false;
              this.saveCurrentProgress();
            })
            .onFinish(() => {
              this.isPlaying = false;
              this.saveCurrentProgress();
            })
        }

        // 同步进度恢复提示
        if (this.showSyncDialog && this.savedPosition > 0) {
          Row() {
            Column({ space: 4 }) {
              Text($r('app.string.video_sync_found'))
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.primary_blue'))
              Text(this.syncStatusText)
                .fontSize(12)
                .fontColor($r('app.color.text_gray'))
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Button($r('app.string.video_sync_resume'))
              .fontSize(12)
              .height(32)
              .onClick(() => {
                this.seekToSyncedPosition();
              })
            Button($r('app.string.video_sync_ignore'))
              .fontSize(12)
              .height(32)
              .backgroundColor(Color.White)
              .fontColor($r('app.color.text_gray'))
              .border({ width: 1, color: $r('app.color.text_light_gray') })
              .margin({ left: 8 })
              .onClick(() => {
                this.showSyncDialog = false;
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor($r('app.color.status_ongoing_bg'))
        }

        // 播放进度信息
        Row() {
          Text(this.formatTime(this.currentPosition))
            .fontSize(14)
            .fontColor($r('app.color.text_gray'))
          Text(' / ')
            .fontSize(14)
            .fontColor($r('app.color.text_gray'))
          Text(this.formatTime(this.totalDuration))
            .fontSize(14)
            .fontColor($r('app.color.text_gray'))
          Blank()
          Text(this.progressPercent.toString() + '%')
            .fontSize(14)
            .fontColor($r('app.color.primary_blue'))
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8 })

        // 多端同步信息卡片
        Column({ space: 8 }) {
          Row({ space: 6 }) {
            Text('📱').fontSize(16)
            Text($r('app.string.video_multi_device_title'))
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
          }
          Text($r('app.string.video_multi_device_desc'))
            .fontSize(12)
            .fontColor($r('app.color.text_gray'))
          if (this.syncStatusText.length > 0) {
            Row({ space: 4 }) {
              Text('✅').fontSize(12)
              Text(this.syncStatusText)
                .fontSize(12)
                .fontColor($r('app.color.success_green'))
            }
          }
        }
        .width('100%')
        .padding(16)
        .margin({ left: 16, right: 16, top: 12 })
        .backgroundColor(Color.White)
        .borderRadius(12)
        .alignItems(HorizontalAlign.Start)
        .shadow({ radius: 4, color: $r('app.color.shadow_color_light'), offsetY: 2 })

        // 视频提示
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
