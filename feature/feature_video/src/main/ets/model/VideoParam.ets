export class VideoParam {
  title: string = '';
  videoUrl: string = '';
  courseId: number = 0;

  constructor(title: string, videoUrl: string, courseId: number) {
    this.title = title;
    this.videoUrl = videoUrl;
    this.courseId = courseId;
  }
}
