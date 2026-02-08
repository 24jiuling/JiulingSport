export class VideoParam {
  title: string = '';
  videoUrl: string = '';

  constructor(title: string, videoUrl: string) {
    this.title = title;
    this.videoUrl = videoUrl;
  }
}
