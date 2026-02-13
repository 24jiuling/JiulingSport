
export class User {
  id: number = 0;
  username: string = '';
  phone: string = '';
  avatar: string = '';
  goalType: string = ''; // '减脂' | '增肌' | '提升耐力'
  isLoggedIn: boolean = false;
  consecutiveDays: number = 0;
  totalWorkouts: number = 0;
  totalTime: number = 0;
  totalCalories: number = 0;
  lastCheckInDate: string = '';
  unionID: string = '';
  openID: string = '';
  authorizationCode: string = '';
  agcUid: string = '';

  constructor(id: number, username: string, avatar: string) {
    this.id = id;
    this.username = username;
    this.avatar = avatar;
  }
}
