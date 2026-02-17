
import { distributedKVStore } from '@kit.ArkData';
import { VideoPlayProgress } from 'lib_entity';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'VideoSyncService';
const STORE_ID: string = 'video_progress_store';
const PROGRESS_KEY_PREFIX: string = 'video_progress_';

export class VideoSyncService {
  private static instance: VideoSyncService;
  private kvManager: distributedKVStore.KVManager | null = null;
  private kvStore: distributedKVStore.SingleKVStore | null = null;
  private isInitialized: boolean = false;

  private constructor() {
  }

  public static getInstance(): VideoSyncService {
    if (!VideoSyncService.instance) {
      VideoSyncService.instance = new VideoSyncService();
    }
    return VideoSyncService.instance;
  }

  // 使用应用上下文初始化分布式 KV Store
  async init(context: Context): Promise<boolean> {
    if (this.isInitialized) {
      return true;
    }
    try {
      let kvManagerConfig: distributedKVStore.KVManagerConfig = {
        bundleName: 'com.example.jiulingsport',
        context: context
      };
      this.kvManager = distributedKVStore.createKVManager(kvManagerConfig);

      let options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: false,
        backup: false,
        autoSync: true,
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
        securityLevel: distributedKVStore.SecurityLevel.S1
      };

      this.kvStore = await this.kvManager.getKVStore(STORE_ID, options) as distributedKVStore.SingleKVStore;
      this.isInitialized = true;
      hilog.info(0x0000, TAG, 'Distributed KV Store initialized successfully');
      return true;
    } catch (e) {
      hilog.error(0x0000, TAG, 'Failed to initialize KV Store: %{public}s', JSON.stringify(e));
      return false;
    }
  }

  // 保存视频播放进度到分布式 KV Store
  async saveProgress(progress: VideoPlayProgress): Promise<boolean> {
    if (this.kvStore === null) {
      hilog.warn(0x0000, TAG, 'KV Store not initialized, cannot save progress');
      return false;
    }
    try {
      let key: string = PROGRESS_KEY_PREFIX + progress.courseId.toString();
      progress.lastUpdated = Date.now();
      let value: string = progress.toJsonString();
      await this.kvStore.put(key, value);
      hilog.info(0x0000, TAG, 'Progress saved for course %{public}d, position: %{public}d',
        progress.courseId, progress.currentPosition);
      return true;
    } catch (e) {
      hilog.error(0x0000, TAG, 'Failed to save progress: %{public}s', JSON.stringify(e));
      return false;
    }
  }

  // 从分布式 KV Store 获取视频播放进度（可从其他设备同步而来）
  async getProgress(courseId: number): Promise<VideoPlayProgress | null> {
    if (this.kvStore === null) {
      hilog.warn(0x0000, TAG, 'KV Store not initialized, cannot get progress');
      return null;
    }
    try {
      let key: string = PROGRESS_KEY_PREFIX + courseId.toString();
      let value: string = await this.kvStore.get(key) as string;
      if (value.length > 0) {
        let progress: VideoPlayProgress = VideoPlayProgress.fromJsonString(value);
        hilog.info(0x0000, TAG, 'Progress loaded for course %{public}d, position: %{public}d',
          courseId, progress.currentPosition);
        return progress;
      }
      return null;
    } catch (e) {
      hilog.info(0x0000, TAG, 'No progress found for course %{public}d', courseId);
      return null;
    }
  }

  // 删除指定课程的视频播放进度
  async deleteProgress(courseId: number): Promise<boolean> {
    if (this.kvStore === null) {
      return false;
    }
    try {
      let key: string = PROGRESS_KEY_PREFIX + courseId.toString();
      await this.kvStore.delete(key);
      hilog.info(0x0000, TAG, 'Progress deleted for course %{public}d', courseId);
      return true;
    } catch (e) {
      hilog.error(0x0000, TAG, 'Failed to delete progress: %{public}s', JSON.stringify(e));
      return false;
    }
  }

  // 注册数据变更监听，用于接收其他设备同步过来的进度
  onProgressChanged(callback: (courseId: number, progress: VideoPlayProgress) => void): void {
    if (this.kvStore === null) {
      hilog.warn(0x0000, TAG, 'KV Store not initialized, cannot register listener');
      return;
    }
    try {
      this.kvStore.on('dataChange', distributedKVStore.SubscribeType.SUBSCRIBE_TYPE_REMOTE,
        (data: distributedKVStore.ChangeNotification) => {
          let insertEntries: distributedKVStore.Entry[] = data.insertEntries;
          let updateEntries: distributedKVStore.Entry[] = data.updateEntries;
          let allEntries: distributedKVStore.Entry[] = [];
          for (let i = 0; i < insertEntries.length; i++) {
            allEntries.push(insertEntries[i]);
          }
          for (let i = 0; i < updateEntries.length; i++) {
            allEntries.push(updateEntries[i]);
          }
          for (let i = 0; i < allEntries.length; i++) {
            let entry: distributedKVStore.Entry = allEntries[i];
            let key: string = entry.key;
            if (key.startsWith(PROGRESS_KEY_PREFIX)) {
              let courseIdStr: string = key.substring(PROGRESS_KEY_PREFIX.length);
              let courseId: number = parseInt(courseIdStr);
              let valueStr: string = entry.value.value as string;
              let progress: VideoPlayProgress = VideoPlayProgress.fromJsonString(valueStr);
              hilog.info(0x0000, TAG, 'Remote progress received for course %{public}d', courseId);
              callback(courseId, progress);
            }
          }
        });
      hilog.info(0x0000, TAG, 'Data change listener registered');
    } catch (e) {
      hilog.error(0x0000, TAG, 'Failed to register data change listener: %{public}s', JSON.stringify(e));
    }
  }

  // 手动触发数据同步
  async syncData(): Promise<boolean> {
    if (this.kvStore === null) {
      return false;
    }
    try {
      // autoSync已设置为true，数据会自动同步
      // 此方法用于需要手动触发的场景
      hilog.info(0x0000, TAG, 'Data sync triggered (autoSync is enabled)');
      return true;
    } catch (e) {
      hilog.error(0x0000, TAG, 'Failed to sync data: %{public}s', JSON.stringify(e));
      return false;
    }
  }

  // 检查分布式服务是否已初始化
  isReady(): boolean {
    return this.isInitialized;
  }
}
