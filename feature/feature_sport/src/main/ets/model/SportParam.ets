
export class SportParam {
  courseId: number = 0;
  courseTitle: string = '';
  courseCalories: number = 0;
  courseDuration: number = 0;

  constructor(courseId: number, courseTitle: string, courseDuration: number, courseCalories: number) {
    this.courseId = courseId;
    this.courseTitle = courseTitle;
    this.courseDuration = courseDuration;
    this.courseCalories = courseCalories;
  }
}
