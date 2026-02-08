
export class Badge {
  id: number = 0;
  name: string = '';
  description: string = '';
  iconUrl: string = '';
  isUnlocked: boolean = false;
  unlockCondition: string = ''; // 解锁条件描述
  unlockDate: string = '';
  category: string = ''; // 'streak' | 'training' | 'calorie' | 'special'
  requiredValue: number = 0; // 达成所需数值

  constructor(id: number, name: string, description: string, iconUrl: string) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.iconUrl = iconUrl;
  }
}
