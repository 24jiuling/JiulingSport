# 久令健身 APP 开发文档

## 1. 项目概述
本项目是一个严格遵循 ArkTS 语言规范开发的 HarmonyOS 健身应用程序。基于"久令健身 APP"毕业设计需求，实现了用户管理、训练计划、运动记录、成就系统和多端协同五大核心功能模块。

## 2. 技术架构
- **语言**: ArkTS (严格模式，禁止 `any`，基于类的模型)。
- **框架**: ArkUI (声明式 UI)。
- **导航**: `Navigation` + `NavPathStack`，通过 `RouterManager` 单例统一管理页面跳转。
- **模块化**:
  - `entry`: 应用入口，主页面（首页、课程、我的）及登录/目标设定页面。
  - `common/lib_entity`: 跨模块共享的数据模型。
  - `common/lib_api`: 业务逻辑服务层（`FitnessService`、`UserService`）。
  - `common/lib_router`: 路由管理（`RouterManager`、`RouterKey`）。
  - `AppScopeCommon`: 公共资源文件 (Strings, Colors) 与 Native 库。
  - `feature/feature_training`: 训练计划功能模块。
  - `feature/feature_sport`: 运动记录功能模块。
  - `feature/feature_medal`: 成就徽章功能模块。
  - `feature/feature_log`: 运动历史功能模块。
  - `feature/feature_video`: 视频课程功能模块。

## 3. 目录结构
```
JiulingSport/
├── entry/src/main/ets/
│   ├── pages/
│   │   ├── Index.ets          # 主容器 (Tabs + Navigation 路由注册)
│   │   ├── Home.ets           # 首页 (登录感知、今日概览、快捷入口)
│   │   ├── CourseList.ets     # 课程列表 (分类筛选、计划集成)
│   │   ├── Mine.ets           # 用户中心 (登录状态、打卡、成就、菜单)
│   │   ├── LoginPage.ets      # 登录/注册页面
│   │   └── GoalSettingPage.ets# 目标设定页面
├── common/
│   ├── lib_entity/src/main/ets/entity/
│   │   ├── Course.ets         # 课程 (含分类、难度)
│   │   ├── User.ets           # 用户 (含目标、打卡、统计)
│   │   ├── Goal.ets           # 目标 (含进度)
│   │   ├── ExerciseRecord.ets # 运动记录 (含手动标记)
│   │   ├── Badge.ets          # 徽章 (含解锁条件、分类)
│   │   ├── TrainingPlan.ets   # 训练计划 (含进度、状态)
│   │   └── CheckInRecord.ets  # 打卡记录
│   ├── lib_api/src/main/ets/service/
│   │   ├── FitnessService.ets # 健身业务服务 (课程/计划/记录/徽章)
│   │   └── UserService.ets    # 用户管理服务 (登录/注册/打卡/目标)
│   ├── lib_router/src/main/ets/
│   │   ├── routerkey/routerKey.ets  # 路由键常量
│   │   └── routermanager/RouterManager.ets # 路由管理器
│   └── lib_http/              # 网络请求模块 (预留)
├── feature/
│   ├── feature_training/src/main/ets/
│   │   ├── pages/
│   │   │   ├── TrainingPlanListPage.ets # 训练计划列表
│   │   │   ├── PlanDetailPage.ets       # 计划详情
│   │   │   └── CreatePlanPage.ets       # 自定义计划创建
│   │   └── model/TrainingParam.ets      # 计划参数
│   ├── feature_sport/src/main/ets/
│   │   ├── pages/
│   │   │   ├── ActiveTrainingPage.ets   # 实时训练 (计时器)
│   │   │   └── ManualRecordPage.ets     # 手动补录
│   │   └── model/SportParam.ets         # 运动参数
│   ├── feature_medal/src/main/ets/pages/
│   │   └── BadgeGalleryPage.ets         # 徽章图鉴
│   └── feature_log/src/main/ets/pages/
│       └── ExerciseHistoryPage.ets      # 运动历史
├── AppScopeCommon/src/main/resources/base/element/
│   ├── string.json            # 文本资源
│   └── color.json             # 颜色资源
```

## 4. 数据模型 (`common/lib_entity`)

所有模型严格遵循 `Specifications.md`：使用 `class`、显式类型声明、构造函数初始化。

| 模型 | 关键字段 | 说明 |
|------|---------|------|
| **User** | `id`, `username`, `phone`, `goalType`, `isLoggedIn`, `consecutiveDays`, `totalWorkouts`, `totalTime`, `totalCalories`, `lastCheckInDate` | 用户档案，含目标设定与打卡统计 |
| **Course** | `id`, `title`, `duration`, `calories`, `category`(减脂/增肌/耐力/柔韧), `difficulty`(初级/中级/高级) | 健身课程，支持分类与难度筛选 |
| **TrainingPlan** | `id`, `name`, `description`, `isCustom`, `targetGoal`, `totalDays`, `completedDays`, `status`(not_started/ongoing/completed), `courses` | 训练计划，含进度跟踪 |
| **ExerciseRecord** | `id`, `userId`, `courseId`, `courseName`, `duration`, `calories`, `date`, `isManual`, `notes` | 运动记录，区分自动/手动记录 |
| **Badge** | `id`, `name`, `icon`, `isUnlocked`, `unlockCondition`, `unlockDate`, `category`(streak/training/calorie/special), `requiredValue` | 成就徽章，含解锁条件与分类 |
| **Goal** | `id`, `userId`, `targetType`, `targetValue`, `currentValue`, `description`, `progress`, `isCompleted` | 用户目标，含进度百分比 |
| **CheckInRecord** | `id`, `userId`, `date`, `isCheckedIn` | 每日打卡记录 |

## 5. 服务层 (`common/lib_api`)

### 5.1 UserService (用户管理服务)
单例模式，负责用户全生命周期管理：
- `loginWithPhone(phone, password)`: 手机号密码登录
- `loginWithHuaweiAccount()`: 华为账号一键登录
- `register(username, phone, password)`: 注册新用户
- `getCurrentUser()` / `isLoggedIn()` / `logout()`: 状态管理
- `setGoal(goalType)`: 设定健身目标
- `checkIn()` / `isTodayCheckedIn()`: 每日打卡
- `updateStats(duration, calories)`: 更新运动统计

### 5.2 FitnessService (健身业务服务)
单例模式，管理课程、计划、记录与徽章：
- **课程管理**: `getAllCourses()`, `getCoursesByGoal(goal)`, `getCourseById(id)`
- **计划管理**: `getRecommendedPlans()`, `getPlansByGoal(goal)`, `getActivePlan()`, `startPlan(planId)`, `updatePlanProgress(planId)`, `createCustomPlan(...)`
- **记录管理**: `createAutoRecord(userId, course, duration)`, `createManualRecord(...)`, `getRecordsByDate(date)`, `getTodayStats()`, `getWeeklyStats()`
- **徽章管理**: `getAllBadges()`, `getUnlockedBadges()`, `checkAndUnlockBadges(user)`
- **初始化**: `initMockData()` 包含 8 节课程、3 个推荐计划、4 条记录、8 枚徽章

## 6. 路由系统 (`common/lib_router`)

使用 `RouterManager` 单例管理 `NavPathStack`，在 `Index.ets` 的 `@Builder pageMap` 中统一注册页面：

| RouterKey | 目标页面 | 所属模块 |
|-----------|---------|---------|
| `LOGIN` | LoginPage | entry |
| `GOAL_SETTING` | GoalSettingPage | entry |
| `TRAINING_PLAN_LIST` | TrainingPlanListPage | feature_training |
| `PLAN_DETAIL` | PlanDetailPage | feature_training |
| `CREATE_PLAN` | CreatePlanPage | feature_training |
| `ACTIVE_TRAINING` | ActiveTrainingPage | feature_sport |
| `MANUAL_RECORD` | ManualRecordPage | feature_sport |
| `BADGE_GALLERY` | BadgeGalleryPage | feature_medal |
| `EXERCISE_HISTORY` | ExerciseHistoryPage | feature_log |

页面间传参通过 `RouterManager.push(key, param)` 实现，目标页面通过 `NavPathStack` 参数获取。

## 7. 功能模块详细说明

### 7.1 用户注册/登录与目标设定
- **LoginPage**: 支持登录/注册切换，手机号+密码表单验证，华为账号一键登录按钮。
- **GoalSettingPage**: 三选一目标（减脂/增肌/提升耐力），每个选项含图标和描述，支持跳过。
- **登录状态感知**: Home、Mine 页面根据登录状态显示不同内容。

### 7.2 训练计划管理
- **TrainingPlanListPage**: 推荐/自定义计划分类展示，进度百分比可视化，状态标签。
- **PlanDetailPage**: 计划信息卡片、包含课程列表、每周训练安排、开始/继续训练按钮。
- **CreatePlanPage**: 自定义计划表单（名称、目标、时长、课程选择）。

### 7.3 运动数据记录
- **ActiveTrainingPage**: 环形进度条计时器、实时卡路里计算、暂停/恢复/结束控制、训练完成后自动创建记录并检查徽章解锁、多端同步提示。
- **ManualRecordPage**: 8 种运动类型选择、时长与卡路里输入、备注功能、提交成功反馈。

### 7.4 成就徽章系统
- **BadgeGalleryPage**: 徽章统计概览、按分类分组展示（连续打卡/训练次数/卡路里/特殊成就）、点击查看徽章详情弹窗。
- **自动解锁**: 训练完成时自动调用 `checkAndUnlockBadges()` 检测并解锁满足条件的徽章。

### 7.5 多端协同
- 训练完成后显示多设备同步提示文案。
- 菜单入口展示多端同步功能说明。

### 7.6 首页 (`Home.ets`)
- 登录感知头部（登录后显示用户名，未登录显示登录提示）。
- 今日概览 Banner（运动次数、时长、卡路里、连续打卡天数）。
- 四宫格快捷入口（训练计划、手动记录、成就徽章、运动历史）。
- 当前进行中训练计划卡片。
- 推荐课程横向列表（含分类标签和开始训练按钮）。

### 7.7 课程列表 (`CourseList.ets`)
- 分类筛选标签（全部/减脂/增肌/耐力/柔韧）。
- 活跃计划卡片（含进度和继续训练按钮）。
- 课程卡片（难度标签、分类标签、开始训练按钮）。

### 7.8 用户中心 (`Mine.ets`)
- 已登录状态：用户信息头部、连续打卡天数、统计数据卡片、打卡按钮、徽章横向列表（含查看全部链接）、功能菜单（我的计划/运动历史/手动记录/目标设定/多端同步/设置）、退出登录。
- 未登录状态：头像占位、登录提示文案、登录/注册按钮。

## 8. 规范符合性
- **禁止 `any` 类型**: 所有变量均有显式类型（例如：`item: Course`、`badge: Badge`）。
- **类使用**: 所有数据模型使用 `class`，通过构造函数初始化。
- **导入/导出**: 使用严格的 ES 模块语法，各模块通过 `Index.ets` 统一导出。
- **UI 组件**: 使用标准的 ArkUI `@Builder` 和 `@Component` 装饰器。
- **资源管理**: 文本和颜色统一在 `AppScopeCommon` 中管理，通过 `$r` 引用。
- **不使用 `var`**: 全部使用 `let` 或 `const`。
- **不使用解构**: 逐字段访问对象属性。
- **MVC 原则**: 模型（lib_entity）、视图（pages/components）、控制（lib_api services）分层清晰。

## 9. 模块依赖关系
```
entry
  ├── lib_entity
  ├── lib_api
  ├── lib_router
  ├── AppScopeCommon
  ├── feature_training  → lib_entity, lib_api, lib_router
  ├── feature_sport     → lib_entity, lib_api, lib_router
  ├── feature_medal     → lib_entity, lib_api, lib_router
  ├── feature_log       → lib_entity, lib_api, lib_router
  └── feature_video     → lib_entity, lib_api, lib_router
```

## 10. 构建与运行
1. 在 DevEco Studio 中打开项目。
2. 同步 ohpm 依赖（确保所有模块间依赖正确配置）。
3. 选择 `entry` 模块并在模拟器/真机上运行。
4. 首次启动进入首页，点击"我的"页面可进行登录注册。
5. 登录后可设定健身目标，制定训练计划并开始运动。

