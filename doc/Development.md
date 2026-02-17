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
│   │   ├── CourseList.ets     # 课程列表 (分类筛选、计划集成、视频播放入口)
│   │   ├── Mine.ets           # 用户中心 (登录状态、打卡、成就、菜单)
│   │   ├── LoginPage.ets      # 登录/注册页面
│   │   └── GoalSettingPage.ets# 目标设定页面
│   ├── entryability/
│   │   └── EntryAbility.ets   # 应用入口 (初始化 AGC、VideoSyncService)
├── common/
│   ├── lib_entity/src/main/ets/entity/
│   │   ├── Course.ets         # 课程 (含分类、难度)
│   │   ├── User.ets           # 用户 (含目标、打卡、统计)
│   │   ├── Goal.ets           # 目标 (含进度)
│   │   ├── ExerciseRecord.ets # 运动记录 (含手动标记)
│   │   ├── Badge.ets          # 徽章 (含解锁条件、分类)
│   │   ├── TrainingPlan.ets   # 训练计划 (含进度、状态)
│   │   ├── CheckInRecord.ets  # 打卡记录
│   │   └── VideoPlayProgress.ets # 视频播放进度 (含跨设备同步)
│   ├── lib_api/src/main/ets/service/
│   │   ├── FitnessService.ets # 健身业务服务 (课程/计划/记录/徽章)
│   │   ├── UserService.ets    # 用户管理服务 (登录/注册/打卡/目标)
│   │   └── VideoSyncService.ets # 视频同步服务 (分布式 KV Store 跨设备同步)
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
│   ├── feature_log/src/main/ets/pages/
│   │   └── ExerciseHistoryPage.ets      # 运动历史
│   └── feature_video/src/main/ets/
│       ├── pages/
│       │   └── VideoPlayerPage.ets      # 视频播放 (本地视频+跨设备进度同步)
│       └── model/VideoParam.ets         # 视频参数 (含 courseId)
├── AppScopeCommon/src/main/resources/
│   ├── base/element/
│   │   ├── string.json            # 文本资源
│   │   └── color.json             # 颜色资源
│   └── rawfile/video/             # 本地视频资源文件
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
| **VideoPlayProgress** | `courseId`, `videoUrl`, `title`, `currentPosition`, `totalDuration`, `lastUpdated`, `deviceInfo` | 视频播放进度，含跨设备同步信息，支持 JSON 序列化/反序列化 |

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
- **初始化**: `initMockData()` 包含 8 节课程（视频源使用本地 rawfile 文件）、3 个推荐计划、4 条记录、8 枚徽章

### 5.3 VideoSyncService (视频同步服务)
单例模式，基于 HarmonyOS 分布式数据管理（`distributedKVStore`）实现视频播放进度跨设备同步：
- `init(context)`: 使用应用上下文初始化分布式 KV Store（`autoSync: true`，自动跨设备同步）
- `saveProgress(progress)`: 保存视频播放进度到分布式 KV Store
- `getProgress(courseId)`: 获取指定课程的视频播放进度（可能来自其他设备）
- `deleteProgress(courseId)`: 删除指定课程的播放进度
- `onProgressChanged(callback)`: 注册远程数据变更监听，实时接收其他设备的播放进度更新
- `syncData()`: 手动触发数据同步
- `isReady()`: 检查分布式服务是否已初始化

**跨设备同步原理**:
- 在 `EntryAbility.onCreate()` 中初始化 VideoSyncService，创建分布式 SingleKVStore
- KV Store 设置 `autoSync: true`，数据自动在登录同一华为账号的设备间同步
- 视频播放过程中每 5 秒自动保存一次播放进度
- 切换设备时，新设备自动从 KV Store 读取最新进度，用户可选择继续播放或从头开始
- 需要 `ohos.permission.DISTRIBUTED_DATASYNC` 权限

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
| `VIDEO_PLAYER` | VideoPlayerPage | feature_video |

页面间传参通过 `RouterManager.push(key, param)` 实现，目标页面通过 `NavPathStack` 参数获取。

## 7. 功能模块详细说明

### 7.1 用户注册/登录与目标设定
- **LoginPage**: 支持华为账号登录按钮。
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
- **视频播放进度跨设备同步**: 在手机上观看课程视频，切换到平板后可自动恢复播放进度。基于 HarmonyOS 分布式 KV Store 实现，登录同一华为账号的设备自动同步。
- 视频播放过程中每 5 秒自动保存进度到分布式数据库。
- 切换设备打开同一课程视频时，自动检测已同步的进度并提示用户选择"继续播放"或"从头开始"。
- 训练完成后显示多设备同步提示文案。
- 菜单入口展示多端同步功能说明。
- **权限要求**: `ohos.permission.DISTRIBUTED_DATASYNC`，在 `entry/src/main/module.json5` 中配置。

### 7.6 视频课程播放 (`feature_video`)
- **VideoPlayerPage**: 支持本地 rawfile 视频和网络视频的播放，带完整的播放控制。
- **本地视频资源**: 视频文件放置在 `AppScopeCommon/src/main/resources/rawfile/video/` 目录下，通过 `$rawfile()` 引用。
- **播放进度追踪**: 实时显示播放位置、总时长和进度百分比。
- **跨设备进度同步**: 播放过程中每 5 秒自动将进度保存到分布式 KV Store。
- **进度恢复提示**: 打开视频时检测是否有来自其他设备的播放进度，支持一键继续或忽略。
- **同步状态指示**: 页面顶部显示同步服务状态（已开启/未开启）。
- 入口位置: 首页推荐课程"观看视频"按钮、课程列表页"观看视频"按钮。

### 7.7 首页 (`Home.ets`)
- 登录感知头部（登录后显示用户名，未登录显示登录提示）。
- 今日概览 Banner（运动次数、时长、卡路里、连续打卡天数）。
- 四宫格快捷入口（训练计划、手动记录、成就徽章、运动历史）。
- 当前进行中训练计划卡片。
- 推荐课程横向列表（含分类标签和开始训练按钮）。
- 每个推荐课程卡片包含"观看视频"和"开始训练"两个入口按钮。

### 7.8 课程列表 (`CourseList.ets`)
- 分类筛选标签（全部/减脂/增肌/耐力/柔韧）。
- 活跃计划卡片（含进度和继续训练按钮）。
- 课程卡片（难度标签、分类标签、"观看视频"按钮、开始训练按钮）。

### 7.9 用户中心 (`Mine.ets`)
- 已登录状态：用户信息头部、连续打卡天数、统计数据卡片、打卡按钮、徽章横向列表（含查看全部链接）、功能菜单（我的计划/运动历史/手动记录/目标设定/多端同步/设置）、退出登录。
- 未登录状态：头像占位、登录提示文案、登录/注册按钮。

## 8. 规范符合性
- **禁止 `any` 类型**: 所有变量均有显式类型（例如：`item: Course`、`badge: Badge`）。
- **类使用**: 所有数据模型使用 `class`，通过构造函数初始化。
- **导入/导出**: 使用严格的 ES 模块语法，各模块通过 `Index.ets` 统一导出。
- **UI 组件**: 使用标准的 ArkUI `@Builder` 和 `@Component` 装饰器。
- **资源管理**: 文本和颜色还有appscopekey统一在 `AppScopeCommon` 中管理，通过文本颜色 `$r` 引用，key放在AppScopeKey中供外部使用。
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
  └── feature_video     → lib_entity, lib_api, lib_router, AppScopeCommon
```

## 10. 后端 API 接口需求

> **当前状态说明**: 前端所有数据均为 Mock（内存数据），无任何网络 API 调用。以下梳理了前端各功能模块需要后端提供的接口，以及需要前后端交互的数据结构。

### 10.1 总体架构

```
┌──────────────────────────────────────┐
│         HarmonyOS 前端 (ArkUI)        │
│  ┌──────────┐  ┌──────────────────┐  │
│  │UserService│  │ FitnessService   │  │
│  │(当前Mock) │  │  (当前Mock)      │  │
│  └─────┬────┘  └────────┬─────────┘  │
│        │                │            │
│  ┌─────▼────────────────▼─────────┐  │
│  │       lib_http (网络请求层)      │  │
│  │  统一封装 HTTP 请求、Token 管理   │  │
│  └─────────────┬──────────────────┘  │
└────────────────┼─────────────────────┘
                 │  RESTful API (JSON)
                 ▼
┌──────────────────────────────────────┐
│            后端服务器                  │
│  ┌────────┐ ┌────────┐ ┌─────────┐  │
│  │用户模块 │ │课程模块 │ │记录模块  │  │
│  │认证/目标│ │计划/徽章│ │打卡/统计 │  │
│  └────────┘ └────────┘ └─────────┘  │
│            数据库 (MySQL/PostgreSQL)   │
└──────────────────────────────────────┘
```

### 10.2 用户认证模块

#### 10.2.1 手机号注册
- **接口**: `POST /api/auth/register`
- **前端发送**:
```json
{
  "phone": "13800138000",
  "password": "加密后的密码",
  "username": "用户昵称"
}
```
- **后端返回**:
```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "id": 1,
    "username": "用户昵称",
    "phone": "13800138000",
    "avatar": "",
    "token": "JWT_TOKEN_STRING"
  }
}
```

#### 10.2.2 手机号登录
- **接口**: `POST /api/auth/login`
- **前端发送**:
```json
{
  "phone": "13800138000",
  "password": "加密后的密码"
}
```
- **后端返回**:
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "id": 1,
    "username": "用户昵称",
    "phone": "13800138000",
    "avatar": "https://xxx/avatar.png",
    "goalType": "减脂",
    "consecutiveDays": 7,
    "totalWorkouts": 15,
    "totalTime": 450,
    "totalCalories": 3200,
    "lastCheckInDate": "2026-02-15",
    "token": "JWT_TOKEN_STRING"
  }
}
```

#### 10.2.3 华为账号登录
- **接口**: `POST /api/auth/huawei-login`
- **前端发送**:
```json
{
  "unionID": "华为unionID",
  "openID": "华为openID",
  "authorizationCode": "华为授权码"
}
```
- **后端返回**: 同手机号登录返回格式（后端用 authorizationCode 向华为服务器验证并创建/关联用户）

#### 10.2.4 退出登录
- **接口**: `POST /api/auth/logout`
- **请求头**: `Authorization: Bearer <token>`
- **后端返回**:
```json
{
  "code": 200,
  "message": "退出成功"
}
```

#### 10.2.5 获取当前用户信息
- **接口**: `GET /api/user/profile`
- **请求头**: `Authorization: Bearer <token>`
- **后端返回**:
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "username": "用户昵称",
    "phone": "13800138000",
    "avatar": "https://xxx/avatar.png",
    "goalType": "减脂",
    "consecutiveDays": 7,
    "totalWorkouts": 15,
    "totalTime": 450,
    "totalCalories": 3200,
    "lastCheckInDate": "2026-02-15"
  }
}
```

### 10.3 健身目标模块

#### 10.3.1 设定/更新健身目标
- **接口**: `PUT /api/user/goal`
- **请求头**: `Authorization: Bearer <token>`
- **前端发送**:
```json
{
  "goalType": "减脂"
}
```
- **后端返回**:
```json
{
  "code": 200,
  "message": "目标设定成功",
  "data": {
    "id": 1,
    "type": "减脂",
    "description": "通过有氧运动减少体脂",
    "targetValue": 30,
    "currentValue": 5,
    "unit": "次",
    "progress": 16,
    "isCompleted": false
  }
}
```

#### 10.3.2 获取用户目标详情
- **接口**: `GET /api/user/goal`
- **请求头**: `Authorization: Bearer <token>`
- **后端返回**: 同上 `data` 部分

### 10.4 课程模块

#### 10.4.1 获取全部课程
- **接口**: `GET /api/courses`
- **可选查询参数**: `?category=减脂&difficulty=初级`
- **后端返回**:
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "title": "全身燃脂训练",
      "description": "高效全身燃脂课程",
      "imageUrl": "https://xxx/course1.png",
      "videoUrl": "https://xxx/video1.mp4",
      "duration": 30,
      "calories": 300,
      "category": "减脂",
      "difficulty": "中级"
    }
  ]
}
```
> **说明**: 前端当前将 `videoUrl` 设置为本地 `rawfile` 路径，接入后端后应改为服务器视频 URL 或 CDN 地址。

#### 10.4.2 获取单个课程详情
- **接口**: `GET /api/courses/{id}`
- **后端返回**: 同上单个课程对象

#### 10.4.3 按目标类型筛选课程
- **接口**: `GET /api/courses?goalType=减脂`
- **后端逻辑**: 根据目标类型映射到课程分类进行筛选
  - 减脂 → 减脂+耐力类课程
  - 增肌 → 增肌类课程
  - 提升耐力 → 耐力+减脂类课程

### 10.5 训练计划模块

#### 10.5.1 获取推荐计划
- **接口**: `GET /api/plans/recommended`
- **请求头**: `Authorization: Bearer <token>`
- **后端返回**:
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "name": "四周减脂计划",
      "description": "循序渐进的减脂训练",
      "courses": [
        { "id": 1, "title": "全身燃脂训练", "duration": 30, "calories": 300 }
      ],
      "startDate": "",
      "durationDays": 28,
      "progress": 0,
      "isCustom": false,
      "targetGoal": "减脂",
      "completedDays": 0,
      "status": "not_started"
    }
  ]
}
```

#### 10.5.2 获取用户的计划列表
- **接口**: `GET /api/plans?goalType=减脂`
- **请求头**: `Authorization: Bearer <token>`
- **后端返回**: 同上

#### 10.5.3 获取当前进行中计划
- **接口**: `GET /api/plans/active`
- **请求头**: `Authorization: Bearer <token>`
- **后端返回**: 单个计划对象或 null

#### 10.5.4 开始计划
- **接口**: `POST /api/plans/{planId}/start`
- **请求头**: `Authorization: Bearer <token>`
- **前端发送**: 无请求体
- **后端操作**: 设置 `status="ongoing"`、`startDate=当前日期`
- **后端返回**:
```json
{
  "code": 200,
  "message": "计划已开始",
  "data": { "...更新后的计划对象" }
}
```

#### 10.5.5 更新计划进度
- **接口**: `PUT /api/plans/{planId}/progress`
- **请求头**: `Authorization: Bearer <token>`
- **前端发送**: 无请求体（后端自动 `completedDays++` 并计算 `progress`）
- **后端返回**: 更新后的计划对象

#### 10.5.6 创建自定义计划
- **接口**: `POST /api/plans`
- **请求头**: `Authorization: Bearer <token>`
- **前端发送**:
```json
{
  "name": "我的增肌计划",
  "description": "专注上肢力量训练",
  "targetGoal": "增肌",
  "durationDays": 21,
  "courseIds": [2, 5, 7]
}
```
- **后端返回**: 创建后的完整计划对象

### 10.6 运动记录模块

#### 10.6.1 自动创建运动记录（课程完成后）
- **接口**: `POST /api/records`
- **请求头**: `Authorization: Bearer <token>`
- **前端发送**:
```json
{
  "courseId": 1,
  "courseName": "全身燃脂训练",
  "duration": 25,
  "calories": 280,
  "type": "HIIT",
  "isManual": false,
  "date": "2026-02-15",
  "notes": ""
}
```
- **后端返回**:
```json
{
  "code": 200,
  "message": "记录已保存",
  "data": {
    "id": 10,
    "courseId": 1,
    "courseName": "全身燃脂训练",
    "duration": 25,
    "calories": 280,
    "type": "HIIT",
    "isManual": false,
    "date": "2026-02-15",
    "notes": ""
  }
}
```
> **后端额外操作**: 记录创建成功后，后端应同时更新用户统计字段（`totalWorkouts++`、`totalTime += duration`、`totalCalories += calories`），并触发徽章检查。

#### 10.6.2 手动补录运动记录
- **接口**: `POST /api/records`
- **请求头**: `Authorization: Bearer <token>`
- **前端发送**:
```json
{
  "courseId": 0,
  "courseName": "",
  "duration": 40,
  "calories": 200,
  "type": "跑步",
  "isManual": true,
  "date": "2026-02-15",
  "notes": "公园慢跑"
}
```
- **后端返回**: 同上

#### 10.6.3 按日期查询运动记录
- **接口**: `GET /api/records?date=2026-02-15`
- **请求头**: `Authorization: Bearer <token>`
- **后端返回**: 记录数组

#### 10.6.4 获取今日统计
- **接口**: `GET /api/records/stats/today`
- **请求头**: `Authorization: Bearer <token>`
- **后端返回**:
```json
{
  "code": 200,
  "data": {
    "workoutCount": 2,
    "totalDuration": 55,
    "totalCalories": 480
  }
}
```

#### 10.6.5 获取本周统计
- **接口**: `GET /api/records/stats/weekly`
- **请求头**: `Authorization: Bearer <token>`
- **后端返回**: 同今日统计格式

#### 10.6.6 获取全部运动历史
- **接口**: `GET /api/records`
- **可选参数**: `?page=1&size=20`（分页）
- **请求头**: `Authorization: Bearer <token>`
- **后端返回**: 记录数组 + 分页信息

### 10.7 每日打卡模块

#### 10.7.1 执行打卡
- **接口**: `POST /api/checkin`
- **请求头**: `Authorization: Bearer <token>`
- **前端发送**: 无请求体
- **后端操作**: 创建打卡记录，更新用户 `consecutiveDays`（如连续则 +1，否则重置为 1），更新 `lastCheckInDate`
- **后端返回**:
```json
{
  "code": 200,
  "message": "打卡成功",
  "data": {
    "id": 5,
    "userId": 1,
    "date": "2026-02-15",
    "isCheckedIn": true,
    "consecutiveDays": 8
  }
}
```

#### 10.7.2 查询今日是否已打卡
- **接口**: `GET /api/checkin/today`
- **请求头**: `Authorization: Bearer <token>`
- **后端返回**:
```json
{
  "code": 200,
  "data": {
    "isCheckedIn": true,
    "consecutiveDays": 8
  }
}
```

#### 10.7.3 获取打卡记录列表
- **接口**: `GET /api/checkin/records`
- **请求头**: `Authorization: Bearer <token>`
- **后端返回**: CheckInRecord 数组

### 10.8 徽章/成就模块

#### 10.8.1 获取全部徽章（含解锁状态）
- **接口**: `GET /api/badges`
- **请求头**: `Authorization: Bearer <token>`
- **后端返回**:
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "name": "初次训练",
      "description": "完成第一次训练",
      "iconUrl": "badge_first.png",
      "isUnlocked": true,
      "unlockCondition": "完成1次训练",
      "unlockDate": "2026-02-10",
      "category": "training",
      "requiredValue": 1
    }
  ]
}
```

#### 10.8.2 检查并解锁徽章
- **接口**: `POST /api/badges/check`
- **请求头**: `Authorization: Bearer <token>`
- **前端发送**: 无请求体（后端根据用户最新统计数据自动判定）
- **后端返回**:
```json
{
  "code": 200,
  "data": {
    "newlyUnlocked": [
      { "id": 3, "name": "连续打卡7天", "category": "streak" }
    ]
  }
}
```
> **触发时机**: 每次运动完成后、每次打卡后前端调用此接口。

### 10.9 视频播放进度模块（可选云端备份）

> **说明**: 视频播放进度当前使用 HarmonyOS 分布式 KV Store 进行跨设备同步，不依赖后端。以下接口为可选的**云端备份**方案，用于在用户更换设备或重装应用后恢复进度。

#### 10.9.1 保存播放进度
- **接口**: `POST /api/video/progress`
- **请求头**: `Authorization: Bearer <token>`
- **前端发送**:
```json
{
  "courseId": 1,
  "videoUrl": "https://xxx/video1.mp4",
  "title": "全身燃脂训练",
  "currentPosition": 185,
  "totalDuration": 1800,
  "deviceInfo": "HUAWEI Mate 60"
}
```

#### 10.9.2 获取播放进度
- **接口**: `GET /api/video/progress/{courseId}`
- **请求头**: `Authorization: Bearer <token>`
- **后端返回**: VideoPlayProgress 对象

### 10.10 数据表设计参考

| 数据表 | 对应实体 | 关键字段 | 说明 |
|--------|---------|---------|------|
| `users` | User | id, username, phone, password_hash, avatar, goal_type, consecutive_days, total_workouts, total_time, total_calories, last_checkin_date, union_id, open_id, agc_uid | 用户主表 |
| `courses` | Course | id, title, description, image_url, video_url, duration, calories, category, difficulty | 课程表（后台管理维护） |
| `training_plans` | TrainingPlan | id, user_id, name, description, is_custom, target_goal, duration_days, completed_days, progress, status, start_date | 训练计划表 |
| `plan_courses` | — | plan_id, course_id, day_number | 计划-课程关联表（多对多） |
| `exercise_records` | ExerciseRecord | id, user_id, course_id, course_name, date, duration, calories, type, is_manual, notes | 运动记录表 |
| `checkin_records` | CheckInRecord | id, user_id, date, is_checked_in | 打卡记录表 |
| `badges` | Badge | id, name, description, icon_url, category, unlock_condition, required_value | 徽章定义表（后台管理维护） |
| `user_badges` | — | user_id, badge_id, unlock_date | 用户-徽章关联表 |
| `goals` | Goal | id, user_id, type, description, target_value, current_value, unit, progress, is_completed | 用户目标表 |
| `video_progress` | VideoPlayProgress | course_id, user_id, video_url, title, current_position, total_duration, last_updated, device_info | 视频播放进度表（可选） |

### 10.11 统一响应格式

所有接口使用统一的 JSON 响应格式：

```json
{
  "code": 200,
  "message": "操作成功",
  "data": { }
}
```

**错误码约定**:

| code | 含义 | 说明 |
|------|------|------|
| 200 | 成功 | 操作成功 |
| 400 | 参数错误 | 请求参数不合法 |
| 401 | 未认证 | Token 缺失或过期 |
| 403 | 无权限 | 无权访问该资源 |
| 404 | 未找到 | 请求的资源不存在 |
| 409 | 冲突 | 今日已打卡 / 用户已注册等 |
| 500 | 服务器错误 | 服务端内部错误 |

### 10.12 前端改造要点

接入后端时，前端需要改造的核心文件：

| 改造文件 | 改造内容 |
|---------|---------|
| `common/lib_http/` | 实现 HTTP 请求封装，统一 Token 注入、错误处理、响应解析 |
| `common/lib_api/UserService.ets` | `loginWithPhone()` / `register()` / `loginWithHuaweiAccount()` 改为调用后端 API；`checkIn()` 改为后端持久化 |
| `common/lib_api/FitnessService.ets` | 移除 `initMockData()`；所有 `get*()` 方法改为调用后端 API；`createAutoRecord()` / `createManualRecord()` 改为 POST 请求 |
| `entry/src/main/ets/pages/Home.ets` | 页面加载时从后端拉取今日统计、推荐课程、活跃计划 |
| `entry/src/main/ets/pages/Mine.ets` | 用户信息、打卡状态、徽章列表从后端获取 |
| 各 feature 模块页面 | 数据源从本地 Mock 切换为后端 API 返回 |

### 10.13 接口优先级

| 优先级 | 模块 | 接口 | 理由 |
|--------|------|------|------|
| **P0 (必须)** | 用户认证 | 注册/登录/华为登录/登出 | 所有功能的基础 |
| **P0 (必须)** | 运动记录 | 创建记录/查询记录/统计 | 核心业务数据，不可丢失 |
| **P0 (必须)** | 每日打卡 | 打卡/查询打卡状态 | 用户活跃度核心功能 |
| **P1 (重要)** | 课程管理 | 课程列表/详情/筛选 | 内容数据后台管理 |
| **P1 (重要)** | 训练计划 | 计划CRUD/进度更新 | 用户个性化训练 |
| **P1 (重要)** | 徽章系统 | 徽章列表/解锁检查 | 成就激励 |
| **P2 (可选)** | 用户目标 | 目标设定/查询 | 可先在本地处理 |
| **P2 (可选)** | 视频进度 | 云端备份进度 | 已有分布式KV Store方案 |

## 11. 构建与运行
1. 在 DevEco Studio 中打开项目。
2. 同步 ohpm 依赖（确保所有模块间依赖正确配置）。
3. 选择 `entry` 模块并在模拟器/真机上运行。
4. 首次启动进入首页，点击"我的"页面可进行登录注册。
5. 登录后可设定健身目标，制定训练计划并开始运动。

