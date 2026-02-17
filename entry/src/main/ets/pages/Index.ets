import { Home } from './Home';
import { CourseList } from './CourseList';
import { Mine } from './Mine';
import { GoalSettingPage } from './GoalSettingPage';
import { RouterManager, RouterKey } from 'lib_router';
import { VideoPlayerPage, VideoParam } from 'feature_video';
import { TrainingPlanListPage, PlanDetailPage, CreatePlanPage, TrainingParam } from 'feature_training';
import { ActiveTrainingPage, ManualRecordPage, SportParam } from 'feature_sport';
import { BadgeGalleryPage } from 'feature_medal';
import { ExerciseHistoryPage, LoginPage, SilentLoginHelper } from 'feature_log';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Course } from 'lib_entity';


@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  private controller: TabsController = new TabsController();
  private router: RouterManager = RouterManager.getInstance();

  aboutToAppear(): void {
    // 应用启动时尝试静默登录 — 如果华为账号已登录过，自动恢复登录状态
    SilentLoginHelper.trySilentLogin().then((success: boolean) => {
      if (success) {
        hilog.info(0x0000, 'Index', 'Silent login succeeded, user is logged in.');
      } else {
        hilog.info(0x0000, 'Index', 'Silent login skipped or failed, user can login manually.');
      }
    });
  }

  @Builder TabBuilder(title: ResourceStr, index: number) {
    Column() {
      Text(title)
        .fontColor(this.currentIndex === index ? $r('app.color.primary_blue') : $r('app.color.text_light_gray'))
        .fontSize(12)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height(40) // 强制构建器高度为 40
  }

  @Builder pageMap(name: string, param: Object) {
    if (name === RouterKey.VIDEO_PLAYER && param instanceof VideoParam) {
      VideoPlayerPage({
        title: (param as VideoParam).title,
        videoUrl: (param as VideoParam).videoUrl,
        courseId: (param as VideoParam).courseId
      })
    } else if (name === RouterKey.LOGIN) {
      LoginPage()
    } else if (name === RouterKey.GOAL_SETTING) {
      GoalSettingPage()
    } else if (name === RouterKey.TRAINING_PLAN_LIST) {
      TrainingPlanListPage()
    } else if (name === RouterKey.PLAN_DETAIL && param instanceof TrainingParam) {
      PlanDetailPage({ planId: (param as TrainingParam).planId })
    } else if (name === RouterKey.CREATE_PLAN) {
      CreatePlanPage()
    } else if (name === RouterKey.ACTIVE_TRAINING && param instanceof SportParam) {
      ActiveTrainingPage({
        courseId: (param as SportParam).courseId,
        courseTitle: (param as SportParam).courseTitle,
        courseCalories: (param as SportParam).courseCalories,
        courseDuration: (param as SportParam).courseDuration,
        courseVideoUrl: (param as SportParam).courseVideoUrl
      })
    } else if (name === RouterKey.ACTIVE_TRAINING && param instanceof Course) {
      ActiveTrainingPage({
        courseId: (param as Course).id,
        courseTitle: (param as Course).title,
        courseCalories: (param as Course).calories,
        courseDuration: (param as Course).duration,
        courseVideoUrl: (param as Course).videoUrl
      })
    } else if (name === RouterKey.MANUAL_RECORD) {
      ManualRecordPage()
    } else if (name === RouterKey.BADGE_GALLERY) {
      BadgeGalleryPage()
    } else if (name === RouterKey.EXERCISE_HISTORY) {
      ExerciseHistoryPage()
    }
  }

  build() {

    Navigation(this.router.getStack()) {
      Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
        TabContent() {
          Home()
        }
        .tabBar(this.TabBuilder($r('app.string.tab_home'), 0))

        TabContent() {
          CourseList()
        }
        .tabBar(this.TabBuilder($r('app.string.tab_courses'), 1))

        TabContent() {
          Mine()
        }
        .tabBar(this.TabBuilder($r('app.string.tab_me'), 2))
      }
      .vertical(false)
      .barMode(BarMode.Fixed)
      .barHeight(56) // 恢复标准高度
      .barBackgroundColor(Color.White) // 恢复白色背景，或者保留灰色
      .animationDuration(200)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .height('100%')
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
    .navDestination(this.pageMap)
    .mode(NavigationMode.Stack)
  }
}