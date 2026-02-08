
export class Goal {
  id: number = 0;
  type: string = ''; // '减脂' | '增肌' | '提升耐力'
  description: string = '';
  targetValue: number = 0;
  currentValue: number = 0;
  unit: string = '';
  progress: number = 0; // 0-100
  isCompleted: boolean = false;

  constructor(id: number, type: string, targetValue: number, unit: string) {
    this.id = id;
    this.type = type;
    this.targetValue = targetValue;
    this.unit = unit;
  }
}
