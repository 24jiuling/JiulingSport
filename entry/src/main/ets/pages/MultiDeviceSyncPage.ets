
import { VideoSyncService, UserService } from 'lib_api';
import { VideoPlayProgress } from 'lib_entity';
import { RouterManager } from 'lib_router';
import { hilog } from '@kit.PerformanceAnalysisKit';

const SYNC_TAG: string = 'MultiDeviceSyncPage';

@Component
export struct MultiDeviceSyncPage {
  private router: RouterManager = RouterManager.getInstance();
  private syncService: VideoSyncService = VideoSyncService.getInstance();
  private userService: UserService = UserService.getInstance();

  @State isServiceReady: boolean = false;
  @State syncedProgressList: VideoPlayProgress[] = [];
  @State isLoading: boolean = false;
  @State statusMessage: string = '';
  @State isLoggedIn: boolean = false;
  @State showSimulatePanel: boolean = false;
  @State simulateStatus: string = '';

  aboutToAppear(): void {
    this.isServiceReady = this.syncService.isReady();
    this.isLoggedIn = this.userService.isLoggedIn();
    this.loadAllProgress();
  }

  // 加载所有已同步的进度数据
  private loadAllProgress(): void {
    this.isLoading = true;
    this.syncService.getAllProgress().then((list: VideoPlayProgress[]) => {
      this.syncedProgressList = list;
      this.isLoading = false;
      hilog.info(0x0000, SYNC_TAG, 'Loaded %{public}d synced progress entries', list.length);
    });
  }

  // 手动触发同步
  private triggerSync(): void {
    this.statusMessage = '正在同步...';
    this.syncService.syncData().then((success: boolean) => {
      if (success) {
        this.statusMessage = '同步请求已发送';
        // 刷新列表
        this.loadAllProgress();
      } else {
        this.statusMessage = '同步请求失败（模拟器不支持分布式同步，请使用演示模式）';
      }
    });
  }

  // 运行模拟同步演示
  private runSimulateDemo(): void {
    this.simulateStatus = '正在模拟远端设备写入数据...';

    // 模拟3条来自不同设备的同步数据
    let promise1 = this.syncService.simulateRemoteSync(101, '全身燃脂HIIT训练', 185, 600);
    let promise2 = this.syncService.simulateRemoteSync(102, '核心力量强化', 420, 900);
    let promise3 = this.syncService.simulateRemoteSync(103, '晨间拉伸放松', 90, 300);

    Promise.all([promise1, promise2, promise3]).then((results: boolean[]) => {
      let successCount: number = 0;
      for (let i = 0; i < results.length; i++) {
        if (results[i]) {
          successCount++;
        }
      }
      this.simulateStatus = '模拟完成：成功写入 ' + successCount.toString() + ' 条远端同步数据';
      hilog.info(0x0000, SYNC_TAG, 'Simulate demo completed, success: %{public}d', successCount);
      // 刷新列表显示新写入的数据
      this.loadAllProgress();
    });
  }

  // 清空所有同步数据
  private clearAllData(): void {
    this.syncService.clearAllProgress().then((success: boolean) => {
      if (success) {
        this.statusMessage = '已清空所有同步数据';
        this.syncedProgressList = [];
        this.simulateStatus = '';
      }
    });
  }

  // 格式化时间
  private formatTime(seconds: number): string {
    let mins: number = Math.floor(seconds / 60);
    let secs: number = Math.floor(seconds % 60);
    let minStr: string = mins < 10 ? '0' + mins.toString() : mins.toString();
    let secStr: string = secs < 10 ? '0' + secs.toString() : secs.toString();
    return minStr + ':' + secStr;
  }

  // 格式化时间戳
  private formatTimestamp(ts: number): string {
    if (ts <= 0) {
      return '未知';
    }
    let date: Date = new Date(ts);
    let month: string = (date.getMonth() + 1).toString();
    let day: string = date.getDate().toString();
    let hour: string = date.getHours() < 10 ? '0' + date.getHours().toString() : date.getHours().toString();
    let minute: string = date.getMinutes() < 10 ? '0' + date.getMinutes().toString() : date.getMinutes().toString();
    return month + '月' + day + '日 ' + hour + ':' + minute;
  }

  build() {
    NavDestination() {
      Column() {
        // ========== 顶部导航栏 ==========
        Row() {
          Text('←')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .onClick(() => { this.router.pop(); })
            .padding({ right: 12 })
          Text('多端数据同步')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 12 })

        Scroll() {
          Column({ space: 16 }) {

            // ========== 同步服务状态卡片 ==========
            Column({ space: 12 }) {
              Row({ space: 8 }) {
                Text(this.isServiceReady ? '🟢' : '🔴').fontSize(16)
                Text('分布式同步服务')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                Blank()
                Text(this.isServiceReady ? '已就绪' : '未初始化')
                  .fontSize(13)
                  .fontColor(this.isServiceReady ? '#4CAF50' : '#F44336')
              }.width('100%')

              Row({ space: 8 }) {
                Text(this.isLoggedIn ? '🟢' : '🟡').fontSize(16)
                Text('华为账号')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                Blank()
                Text(this.isLoggedIn ? '已登录' : '未登录')
                  .fontSize(13)
                  .fontColor(this.isLoggedIn ? '#4CAF50' : '#FF9800')
              }.width('100%')

              // 同步原理说明
              Column({ space: 6 }) {
                Text('同步原理')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_blue'))
                Text('基于 HarmonyOS 分布式 KV Store（键值数据库）实现。当多台鸿蒙设备登录同一华为账号并处于同一局域网时，KV Store 中的数据会通过分布式软总线自动同步。')
                  .fontSize(12)
                  .fontColor($r('app.color.text_gray'))
                  .lineHeight(18)
                Text('配置：autoSync=true | 安全级别=S1 | 类型=SINGLE_VERSION')
                  .fontSize(11)
                  .fontColor($r('app.color.text_light_gray'))
                  .margin({ top: 4 })
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)

            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .shadow({ radius: 4, color: $r('app.color.shadow_color_light'), offsetY: 2 })

            // ========== 操作按钮区域 ==========
            Column({ space: 10 }) {
              Text('同步操作')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .width('100%')

              Row({ space: 10 }) {
                Button('手动同步')
                  .layoutWeight(1)
                  .height(40)
                  .fontSize(14)
                  .backgroundColor($r('app.color.primary_blue'))
                  .onClick(() => { this.triggerSync(); })

                Button('刷新数据')
                  .layoutWeight(1)
                  .height(40)
                  .fontSize(14)
                  .backgroundColor('#4CAF50')
                  .onClick(() => {
                    this.statusMessage = '正在刷新...';
                    this.loadAllProgress();
                    this.statusMessage = '数据已刷新';
                  })

                Button('清空数据')
                  .layoutWeight(1)
                  .height(40)
                  .fontSize(14)
                  .backgroundColor('#F44336')
                  .onClick(() => { this.clearAllData(); })
              }.width('100%')

              if (this.statusMessage.length > 0) {
                Text(this.statusMessage)
                  .fontSize(13)
                  .fontColor($r('app.color.primary_blue'))
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .margin({ top: 4 })
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .shadow({ radius: 4, color: $r('app.color.shadow_color_light'), offsetY: 2 })

            // ========== 模拟同步演示（核心功能） ==========
            Column({ space: 12 }) {
              Row() {
                Column({ space: 4 }) {
                  Text('📱 模拟同步演示')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                  Text('模拟器不支持分布式软总线，可通过此功能演示完整同步流程')
                    .fontSize(12)
                    .fontColor($r('app.color.text_gray'))
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                Toggle({ type: ToggleType.Switch, isOn: this.showSimulatePanel })
                  .onChange((isOn: boolean) => { this.showSimulatePanel = isOn; })
              }.width('100%')

              if (this.showSimulatePanel) {
                Column({ space: 10 }) {
                  // 演示说明
                  Text('点击下方按钮，将模拟另一台设备（HUAWEI MatePad）向 KV Store 写入 3 条视频播放进度数据。写入后在视频播放页即可看到"发现跨设备同步进度"的恢复提示。')
                    .fontSize(12)
                    .fontColor($r('app.color.text_gray'))
                    .lineHeight(18)

                  // 模拟数据预览
                  Column({ space: 6 }) {
                    Text('将写入的模拟数据：')
                      .fontSize(13)
                      .fontWeight(FontWeight.Bold)
                    this.SimulateDataPreview('全身燃脂HIIT训练', 185, 600, 101)
                    this.SimulateDataPreview('核心力量强化', 420, 900, 102)
                    this.SimulateDataPreview('晨间拉伸放松', 90, 300, 103)
                  }
                  .width('100%')
                  .padding(12)
                  .backgroundColor('#FFF8E1')
                  .borderRadius(8)

                  Button('🚀 执行模拟同步')
                    .width('100%')
                    .height(44)
                    .fontSize(15)
                    .fontWeight(FontWeight.Bold)
                    .backgroundColor('#FF9800')
                    .onClick(() => { this.runSimulateDemo(); })

                  if (this.simulateStatus.length > 0) {
                    Row({ space: 6 }) {
                      Text('✅').fontSize(14)
                      Text(this.simulateStatus)
                        .fontSize(13)
                        .fontColor('#4CAF50')
                        .fontWeight(FontWeight.Bold)
                    }
                    .width('100%')
                    .padding(10)
                    .backgroundColor('#E8F5E9')
                    .borderRadius(8)
                  }

                  // 验证提示
                  Column({ space: 4 }) {
                    Text('如何验证同步效果：')
                      .fontSize(13)
                      .fontWeight(FontWeight.Bold)
                      .fontColor($r('app.color.primary_blue'))
                    Text('1. 执行模拟同步后，下方"已同步数据列表"将显示写入的数据')
                      .fontSize(12).fontColor($r('app.color.text_gray'))
                    Text('2. 返回课程列表，打开对应课程的视频播放')
                      .fontSize(12).fontColor($r('app.color.text_gray'))
                    Text('3. 视频播放页会弹出"发现跨设备同步进度"提示')
                      .fontSize(12).fontColor($r('app.color.text_gray'))
                    Text('4. 点击"继续播放"可跳转到模拟的远端播放位置')
                      .fontSize(12).fontColor($r('app.color.text_gray'))
                  }
                  .width('100%')
                  .padding(12)
                  .backgroundColor('#E3F2FD')
                  .borderRadius(8)
                  .alignItems(HorizontalAlign.Start)
                }.width('100%')
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .shadow({ radius: 4, color: $r('app.color.shadow_color_light'), offsetY: 2 })

            // ========== 已同步数据列表 ==========
            Column({ space: 10 }) {
              Row() {
                Text('已同步数据列表')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                Blank()
                Text(this.syncedProgressList.length.toString() + ' 条记录')
                  .fontSize(13)
                  .fontColor($r('app.color.text_gray'))
              }.width('100%')

              if (this.isLoading) {
                Text('加载中...')
                  .fontSize(14)
                  .fontColor($r('app.color.text_gray'))
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .padding(20)
              } else if (this.syncedProgressList.length === 0) {
                Column({ space: 8 }) {
                  Text('📭').fontSize(40)
                  Text('暂无同步数据')
                    .fontSize(14)
                    .fontColor($r('app.color.text_gray'))
                  Text('可通过"模拟同步演示"功能生成测试数据')
                    .fontSize(12)
                    .fontColor($r('app.color.text_light_gray'))
                }
                .width('100%')
                .padding(30)
                .justifyContent(FlexAlign.Center)
              } else {
                ForEach(this.syncedProgressList, (item: VideoPlayProgress) => {
                  Row() {
                    Column({ space: 4 }) {
                      // 视频标题
                      Text(item.title)
                        .fontSize(15)
                        .fontWeight(FontWeight.Bold)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      // 播放进度
                      Row({ space: 4 }) {
                        Text('进度：').fontSize(12).fontColor($r('app.color.text_gray'))
                        Text(this.formatTime(item.currentPosition) + ' / ' + this.formatTime(item.totalDuration))
                          .fontSize(12).fontColor($r('app.color.primary_blue')).fontWeight(FontWeight.Bold)
                        Text('(' + item.getProgressPercent().toString() + '%)')
                          .fontSize(12).fontColor($r('app.color.text_gray'))
                      }
                      // 进度条
                      Progress({ value: item.getProgressPercent(), total: 100, type: ProgressType.Linear })
                        .width('100%')
                        .height(4)
                        .color($r('app.color.primary_blue'))
                        .backgroundColor('#E0E0E0')
                      // 来源设备与时间
                      Row({ space: 4 }) {
                        Text('📱').fontSize(10)
                        Text(item.deviceInfo.length > 0 ? item.deviceInfo : '未知设备')
                          .fontSize(11).fontColor($r('app.color.text_light_gray'))
                        Text(' · ').fontSize(11).fontColor($r('app.color.text_light_gray'))
                        Text(this.formatTimestamp(item.lastUpdated))
                          .fontSize(11).fontColor($r('app.color.text_light_gray'))
                      }
                    }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  .padding(12)
                  .backgroundColor('#FAFAFA')
                  .borderRadius(8)
                  .border({ width: 1, color: '#EEEEEE' })
                })
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .shadow({ radius: 4, color: $r('app.color.shadow_color_light'), offsetY: 2 })

            // ========== 技术架构说明 ==========
            Column({ space: 10 }) {
              Text('技术架构')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .width('100%')

              Column({ space: 6 }) {
                this.ArchItem('数据存储', 'distributedKVStore.SingleKVStore（分布式键值数据库）')
                this.ArchItem('同步模式', 'autoSync=true（自动同步） + 手动 PUSH_PULL 同步')
                this.ArchItem('数据格式', 'VideoPlayProgress JSON 序列化存储')
                this.ArchItem('监听机制', 'SUBSCRIBE_TYPE_REMOTE 远程数据变更回调')
                this.ArchItem('安全级别', 'SecurityLevel.S1（低安全级别，适合非敏感数据）')
                this.ArchItem('权限要求', 'ohos.permission.DISTRIBUTED_DATASYNC')
                this.ArchItem('适用场景', '真机多设备登录同一账号、同一局域网环境')
              }.width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .shadow({ radius: 4, color: $r('app.color.shadow_color_light'), offsetY: 2 })

          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 30 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_background'))
    }
    .hideTitleBar(true)
  }

  @Builder SimulateDataPreview(title: string, position: number, duration: number, id: number) {
    Row({ space: 8 }) {
      Text('🎬').fontSize(14)
      Column({ space: 2 }) {
        Text(title).fontSize(13).fontWeight(FontWeight.Bold)
        Text('课程ID: ' + id.toString() + '  |  进度: ' + this.formatTime(position) + '/' + this.formatTime(duration))
          .fontSize(11).fontColor($r('app.color.text_gray'))
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
    }.width('100%')
  }

  @Builder ArchItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_blue'))
        .width(80)
      Text(value)
        .fontSize(12)
        .fontColor($r('app.color.text_gray'))
        .layoutWeight(1)
    }.width('100%').padding({ top: 4, bottom: 4 })
  }
}
