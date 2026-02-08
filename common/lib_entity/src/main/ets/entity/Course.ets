
export class Course {
  id: number = 0;
  title: string = '';
  description: string = '';
  imageUrl: string = '';
  videoUrl: string = '';
  duration: number = 0; // 分钟
  calories: number = 0;
  category: string = ''; // '减脂' | '增肌' | '耐力' | '柔韧'
  difficulty: string = ''; // '初级' | '中级' | '高级'

  constructor(id: number, title: string, description: string, imageUrl: string, videoUrl: string, duration: number, calories: number) {
    this.id = id;
    this.title = title;
    this.description = description;
    this.imageUrl = imageUrl;
    this.videoUrl = videoUrl;
    this.duration = duration;
    this.calories = calories;
  }
}
