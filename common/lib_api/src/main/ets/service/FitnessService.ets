
import { User, Goal, TrainingPlan, ExerciseRecord, Badge, Course } from 'lib_entity';

export class FitnessService {
  private static instance: FitnessService;
  private records: ExerciseRecord[] = [];
  private plans: TrainingPlan[] = [];
  private badges: Badge[] = [];
  private allCourses: Course[] = [];
  private nextRecordId: number = 100;
  private nextPlanId: number = 100;

  private constructor() {
    this.initMockData();
  }

  public static getInstance(): FitnessService {
    if (!FitnessService.instance) {
      FitnessService.instance = new FitnessService();
    }
    return FitnessService.instance;
  }

  // ==================== 初始化模拟数据 ====================

  private initMockData(): void {
    // 初始化课程库
    let c1 = new Course(1, '瑜伽基础', '放松身心，提升柔韧性', '', 'https://vjs.zencdn.net/v/oceans.mp4', 30, 80);
    c1.category = '柔韧';
    c1.difficulty = '初级';
    let c2 = new Course(2, 'HIIT燃脂', '高强度间歇训练，快速燃脂', '', 'https://vjs.zencdn.net/v/oceans.mp4', 20, 250);
    c2.category = '减脂';
    c2.difficulty = '高级';
    let c3 = new Course(3, '力量训练', '全身肌肉构建训练', '', 'https://vjs.zencdn.net/v/oceans.mp4', 45, 300);
    c3.category = '增肌';
    c3.difficulty = '中级';
    let c4 = new Course(4, '普拉提', '核心力量提升', '', 'https://vjs.zencdn.net/v/oceans.mp4', 30, 100);
    c4.category = '柔韧';
    c4.difficulty = '初级';
    let c5 = new Course(5, '耐力跑步', '提升心肺耐力', '', 'https://vjs.zencdn.net/v/oceans.mp4', 40, 400);
    c5.category = '耐力';
    c5.difficulty = '中级';
    let c6 = new Course(6, '哑铃增肌', '上肢肌群专项训练', '', 'https://vjs.zencdn.net/v/oceans.mp4', 35, 280);
    c6.category = '增肌';
    c6.difficulty = '中级';
    let c7 = new Course(7, '有氧操', '全身有氧燃脂操', '', 'https://vjs.zencdn.net/v/oceans.mp4', 25, 200);
    c7.category = '减脂';
    c7.difficulty = '初级';
    let c8 = new Course(8, '拉伸恢复', '运动后放松拉伸', '', 'https://vjs.zencdn.net/v/oceans.mp4', 15, 40);
    c8.category = '柔韧';
    c8.difficulty = '初级';
    this.allCourses = [c1, c2, c3, c4, c5, c6, c7, c8];

    // 初始化推荐计划
    let plan1 = new TrainingPlan(1, '28天减脂挑战', '2026-02-10', 28);
    plan1.description = '科学减脂，每天30分钟高效燃脂';
    plan1.targetGoal = '减脂';
    plan1.courses = [c2, c7, c5];
    plan1.status = 'ongoing';
    plan1.completedDays = 8;
    plan1.progress = 29;
    let plan2 = new TrainingPlan(2, '增肌塑形计划', '2026-02-15', 42);
    plan2.description = '系统增肌训练，打造完美身材';
    plan2.targetGoal = '增肌';
    plan2.courses = [c3, c6];
    plan2.status = 'not_started';
    let plan3 = new TrainingPlan(3, '耐力提升计划', '2026-03-01', 30);
    plan3.description = '循序渐进提升心肺耐力';
    plan3.targetGoal = '提升耐力';
    plan3.courses = [c5, c7];
    plan3.status = 'not_started';
    this.plans = [plan1, plan2, plan3];

    // 初始化运动记录
    let r1 = new ExerciseRecord(1, 1, '2026-02-06', 30, 150, '瑜伽');
    r1.courseName = '瑜伽基础';
    let r2 = new ExerciseRecord(2, 2, '2026-02-07', 45, 300, 'HIIT');
    r2.courseName = 'HIIT燃脂';
    let r3 = new ExerciseRecord(3, 5, '2026-02-07', 40, 400, '跑步');
    r3.courseName = '耐力跑步';
    let r4 = new ExerciseRecord(4, 0, '2026-02-08', 60, 350, '游泳');
    r4.isManual = true;
    r4.courseName = '手动记录';
    r4.notes = '室外游泳';
    this.records = [r1, r2, r3, r4];

    // 初始化徽章
    let b1 = new Badge(1, '初次运动', '完成第一次运动', '');
    b1.category = 'training';
    b1.requiredValue = 1;
    b1.unlockCondition = '完成1次运动';
    b1.isUnlocked = true;
    b1.unlockDate = '2026-02-06';
    let b2 = new Badge(2, '连续7天', '连续运动7天', '');
    b2.category = 'streak';
    b2.requiredValue = 7;
    b2.unlockCondition = '连续打卡7天';
    let b3 = new Badge(3, '连续30天', '连续运动30天', '');
    b3.category = 'streak';
    b3.requiredValue = 30;
    b3.unlockCondition = '连续打卡30天';
    let b4 = new Badge(4, '卡路里燃烧者', '单次消耗500千卡', '');
    b4.category = 'calorie';
    b4.requiredValue = 500;
    b4.unlockCondition = '单次运动消耗500千卡';
    let b5 = new Badge(5, '健身达人', '累计运动50次', '');
    b5.category = 'training';
    b5.requiredValue = 50;
    b5.unlockCondition = '累计完成50次运动';
    let b6 = new Badge(6, '计划完成者', '完成一个训练计划', '');
    b6.category = 'special';
    b6.requiredValue = 1;
    b6.unlockCondition = '完成任意一个训练计划';
    let b7 = new Badge(7, '万卡俱乐部', '累计消耗10000千卡', '');
    b7.category = 'calorie';
    b7.requiredValue = 10000;
    b7.unlockCondition = '累计消耗10000千卡';
    let b8 = new Badge(8, '早起鸟', '早上6点前开始运动', '');
    b8.category = 'special';
    b8.requiredValue = 1;
    b8.unlockCondition = '早上6点前开始运动';
    this.badges = [b1, b2, b3, b4, b5, b6, b7, b8];
  }

  // ==================== 课程管理 ====================

  getAllCourses(): Course[] {
    return this.allCourses;
  }

  getCoursesByGoal(goalType: string): Course[] {
    let result: Course[] = [];
    for (let i = 0; i < this.allCourses.length; i++) {
      let course = this.allCourses[i];
      if (goalType === '减脂' && (course.category === '减脂' || course.category === '耐力')) {
        result.push(course);
      } else if (goalType === '增肌' && (course.category === '增肌')) {
        result.push(course);
      } else if (goalType === '提升耐力' && (course.category === '耐力' || course.category === '减脂')) {
        result.push(course);
      }
    }
    return result;
  }

  getCourseById(id: number): Course | null {
    for (let i = 0; i < this.allCourses.length; i++) {
      if (this.allCourses[i].id === id) {
        return this.allCourses[i];
      }
    }
    return null;
  }

  // ==================== 训练计划管理 ====================

  getRecommendedPlans(): TrainingPlan[] {
    return this.plans;
  }

  getPlansByGoal(goalType: string): TrainingPlan[] {
    let result: TrainingPlan[] = [];
    for (let i = 0; i < this.plans.length; i++) {
      if (this.plans[i].targetGoal === goalType) {
        result.push(this.plans[i]);
      }
    }
    return result;
  }

  getPlanById(id: number): TrainingPlan | null {
    for (let i = 0; i < this.plans.length; i++) {
      if (this.plans[i].id === id) {
        return this.plans[i];
      }
    }
    return null;
  }

  getActivePlan(): TrainingPlan | null {
    for (let i = 0; i < this.plans.length; i++) {
      if (this.plans[i].status === 'ongoing') {
        return this.plans[i];
      }
    }
    return null;
  }

  startPlan(planId: number): boolean {
    let plan = this.getPlanById(planId);
    if (plan !== null) {
      plan.status = 'ongoing';
      plan.startDate = this.getTodayString();
      return true;
    }
    return false;
  }

  updatePlanProgress(planId: number): void {
    let plan = this.getPlanById(planId);
    if (plan !== null) {
      plan.completedDays = plan.completedDays + 1;
      if (plan.durationDays > 0) {
        plan.progress = Math.round((plan.completedDays / plan.durationDays) * 100);
      }
      if (plan.completedDays >= plan.durationDays) {
        plan.status = 'completed';
        plan.progress = 100;
      }
    }
  }

  createCustomPlan(name: string, goalType: string, durationDays: number, selectedCourseIds: number[]): TrainingPlan {
    let plan = new TrainingPlan(this.nextPlanId, name, this.getTodayString(), durationDays);
    this.nextPlanId = this.nextPlanId + 1;
    plan.isCustom = true;
    plan.targetGoal = goalType;
    plan.description = '自定义' + goalType + '计划';
    let courses: Course[] = [];
    for (let i = 0; i < selectedCourseIds.length; i++) {
      let course = this.getCourseById(selectedCourseIds[i]);
      if (course !== null) {
        courses.push(course);
      }
    }
    plan.courses = courses;
    this.plans.push(plan);
    return plan;
  }

  // ==================== 运动记录管理 ====================

  addRecord(record: ExerciseRecord): boolean {
    this.records.push(record);
    console.info('记录已保存: ' + record.type);
    return true;
  }

  createAutoRecord(courseId: number, courseName: string, duration: number, calories: number, type: string): ExerciseRecord {
    let record = new ExerciseRecord(this.nextRecordId, courseId, this.getTodayString(), duration, calories, type);
    this.nextRecordId = this.nextRecordId + 1;
    record.courseName = courseName;
    record.isManual = false;
    this.records.push(record);
    return record;
  }

  createManualRecord(type: string, duration: number, calories: number, notes: string): ExerciseRecord {
    let record = new ExerciseRecord(this.nextRecordId, 0, this.getTodayString(), duration, calories, type);
    this.nextRecordId = this.nextRecordId + 1;
    record.isManual = true;
    record.courseName = '手动记录';
    record.notes = notes;
    this.records.push(record);
    return record;
  }

  getRecords(): ExerciseRecord[] {
    return this.records;
  }

  getRecordsByDate(date: string): ExerciseRecord[] {
    let result: ExerciseRecord[] = [];
    for (let i = 0; i < this.records.length; i++) {
      if (this.records[i].date === date) {
        result.push(this.records[i]);
      }
    }
    return result;
  }

  getTodayRecords(): ExerciseRecord[] {
    return this.getRecordsByDate(this.getTodayString());
  }

  getTodayStats(): number[] {
    let todayRecords = this.getTodayRecords();
    let totalDuration: number = 0;
    let totalCalories: number = 0;
    let count: number = todayRecords.length;
    for (let i = 0; i < todayRecords.length; i++) {
      totalDuration = totalDuration + todayRecords[i].duration;
      totalCalories = totalCalories + todayRecords[i].calories;
    }
    return [count, totalDuration, totalCalories];
  }

  getWeeklyStats(): number[] {
    let totalDuration: number = 0;
    let totalCalories: number = 0;
    let count: number = 0;
    let now = new Date();
    for (let i = 0; i < this.records.length; i++) {
      let recordDate = new Date(this.records[i].date);
      let diff = now.getTime() - recordDate.getTime();
      let daysDiff = diff / (1000 * 60 * 60 * 24);
      if (daysDiff <= 7) {
        count = count + 1;
        totalDuration = totalDuration + this.records[i].duration;
        totalCalories = totalCalories + this.records[i].calories;
      }
    }
    return [count, totalDuration, totalCalories];
  }

  // ==================== 徽章管理 ====================

  getAllBadges(): Badge[] {
    return this.badges;
  }

  getUnlockedBadges(): Badge[] {
    let result: Badge[] = [];
    for (let i = 0; i < this.badges.length; i++) {
      if (this.badges[i].isUnlocked) {
        result.push(this.badges[i]);
      }
    }
    return result;
  }

  checkAndUnlockBadges(user: User): Badge[] {
    let newlyUnlocked: Badge[] = [];
    let today = this.getTodayString();
    for (let i = 0; i < this.badges.length; i++) {
      let badge = this.badges[i];
      if (badge.isUnlocked) {
        continue;
      }
      let shouldUnlock: boolean = false;
      if (badge.category === 'streak' && user.consecutiveDays >= badge.requiredValue) {
        shouldUnlock = true;
      } else if (badge.category === 'training' && user.totalWorkouts >= badge.requiredValue) {
        shouldUnlock = true;
      } else if (badge.category === 'calorie' && user.totalCalories >= badge.requiredValue) {
        shouldUnlock = true;
      }
      if (shouldUnlock) {
        badge.isUnlocked = true;
        badge.unlockDate = today;
        newlyUnlocked.push(badge);
      }
    }
    return newlyUnlocked;
  }

  // 兼容旧接口
  checkBadges(): Badge[] {
    return this.badges;
  }

  // ==================== 工具方法 ====================

  private getTodayString(): string {
    let now = new Date();
    let year = now.getFullYear();
    let month = now.getMonth() + 1;
    let day = now.getDate();
    let monthStr = month < 10 ? '0' + month.toString() : month.toString();
    let dayStr = day < 10 ? '0' + day.toString() : day.toString();
    return year.toString() + '-' + monthStr + '-' + dayStr;
  }

  // ==================== 兼容旧接口 ====================

  login(phoneNumber: string): User {
    return new User(1, '用户_' + phoneNumber.substring(7), '');
  }

  setUserGoal(goalType: string): Goal {
    return new Goal(1, goalType, 10, 'kg');
  }
}
