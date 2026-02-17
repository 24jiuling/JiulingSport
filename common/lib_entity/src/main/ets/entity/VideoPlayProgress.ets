
export class VideoPlayProgress {
  courseId: number = 0;
  videoUrl: string = '';
  title: string = '';
  currentPosition: number = 0; // 当前播放位置（秒）
  totalDuration: number = 0; // 视频总时长（秒）
  lastUpdated: number = 0; // 最后更新时间戳
  deviceInfo: string = ''; // 来源设备标识

  constructor(courseId: number, videoUrl: string, title: string) {
    this.courseId = courseId;
    this.videoUrl = videoUrl;
    this.title = title;
    this.lastUpdated = Date.now();
  }

  // 将进度转换为 JSON 字符串，用于 KV Store 存储
  toJsonString(): string {
    let json: string = '{'
      + '"courseId":' + this.courseId.toString()
      + ',"videoUrl":"' + this.videoUrl + '"'
      + ',"title":"' + this.title + '"'
      + ',"currentPosition":' + this.currentPosition.toString()
      + ',"totalDuration":' + this.totalDuration.toString()
      + ',"lastUpdated":' + this.lastUpdated.toString()
      + ',"deviceInfo":"' + this.deviceInfo + '"'
      + '}';
    return json;
  }

  // 从 JSON 字符串解析进度
  static fromJsonString(jsonStr: string): VideoPlayProgress {
    let progress = new VideoPlayProgress(0, '', '');
    try {
      let obj: Record<string, Object> = JSON.parse(jsonStr) as Record<string, Object>;
      progress.courseId = obj['courseId'] as number;
      progress.videoUrl = obj['videoUrl'] as string;
      progress.title = obj['title'] as string;
      progress.currentPosition = obj['currentPosition'] as number;
      progress.totalDuration = obj['totalDuration'] as number;
      progress.lastUpdated = obj['lastUpdated'] as number;
      progress.deviceInfo = obj['deviceInfo'] as string;
    } catch (e) {
      // 解析失败返回空进度
    }
    return progress;
  }

  // 获取进度百分比
  getProgressPercent(): number {
    if (this.totalDuration <= 0) {
      return 0;
    }
    return Math.round((this.currentPosition / this.totalDuration) * 100);
  }
}
