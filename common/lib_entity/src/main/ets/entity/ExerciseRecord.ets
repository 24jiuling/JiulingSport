
export class ExerciseRecord {
  id: number = 0;
  courseId: number = 0;
  courseName: string = '';
  date: string = '';
  duration: number = 0; // 分钟
  calories: number = 0;
  type: string = ''; // '瑜伽' | '跑步' | 'HIIT' 等
  isManual: boolean = false; // 是否手动补录
  notes: string = '';

  constructor(id: number, courseId: number, date: string, duration: number, calories: number, type: string) {
    this.id = id;
    this.courseId = courseId;
    this.date = date;
    this.duration = duration;
    this.calories = calories;
    this.type = type;
  }
}
