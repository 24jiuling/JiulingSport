
import { Course } from './Course';

export class TrainingPlan {
  id: number = 0;
  name: string = '';
  description: string = '';
  courses: Course[] = [];
  startDate: string = '';
  durationDays: number = 0;
  progress: number = 0; // 0-100
  isCustom: boolean = false;
  targetGoal: string = ''; // '减脂' | '增肌' | '提升耐力'
  completedDays: number = 0;
  status: string = 'not_started'; // 'not_started' | 'ongoing' | 'completed'

  constructor(id: number, name: string, startDate: string, durationDays: number) {
    this.id = id;
    this.name = name;
    this.startDate = startDate;
    this.durationDays = durationDays;
  }
}
