
export class CheckInRecord {
  id: number = 0;
  userId: number = 0;
  date: string = '';
  isCheckedIn: boolean = false;

  constructor(id: number, userId: number, date: string) {
    this.id = id;
    this.userId = userId;
    this.date = date;
    this.isCheckedIn = true;
  }
}
