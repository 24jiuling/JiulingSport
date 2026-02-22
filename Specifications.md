你正在为 HarmonyOS 应用开发相关功能。以下是你需要遵循的开发规则。

## ArkTS/ets 语法约束(违反条目将无法编译通过)

- 不支持索引访问类型。请改用类型名称。
- 不支持环境模块声明，因为它有自己的与 JavaScript 互操作的机制。请从原始模块中导入所需的内容。
- 不支持 any 和 unknown 类型。请显式指定类型。
- 不支持 as const 断言，因为在标准 TypeScript 中，as const 用于使用相应的字面量类型标注字面量，而 ArkTS 不支持字面量类型。请避免使用 as const 断言。请改用字面量的显式类型标注。
- 不支持对象类型中的调用签名。请改用 class（类）来实现。
- 不支持类字面量。请显式引入新的命名类类型。
- 不支持将类用作对象（将其赋值给变量等）。这是因为在 ArkTS 中，类声明引入的是一种新类型，而不是一个值。请勿将类用作对象；类声明引入的是一种新类型，而不是一个值。
- 仅在 for 循环中支持逗号运算符。在其他情况下，逗号运算符是无用的，因为它会使执行顺序更难理解。在 for 循环之外，请使用显式执行顺序而不是逗号运算符。
- 不支持条件类型别名。请显式引入带约束的新类型，或使用 Object 重写逻辑。不支持 infer 关键字。
- 不支持在构造函数中声明类字段。请在类声明内部声明类字段。
- 不支持使用构造函数类型。请改用 lambdas（匿名函数）。
- 不支持接口中的构造函数签名。请改用方法（methods）。
- 不支持对象类型中的构造函数签名。请改用 class（类）来实现。
- 不支持声明合并。请保持代码库中所有类和接口的定义紧凑。
- 不支持确定性赋值断言 let v!: T，因为它们被认为是过度的编译器提示。使用确定性赋值断言运算符（!）需要运行时类型检查，导致额外的运行时开销并生成此警告。请改用带初始化的声明。如果使用了!，请确保实例属性在使用前已赋值，并注意运行时开销和警告。
- 假定对象布局在编译时已知且运行时不可更改。因此，删除属性的操作没有意义。为了模拟原始语义，您可以声明一个可空类型并赋值为 null 以标记值的缺失。
- 不支持解构赋值。请改用其他惯用法（例如，在适用情况下使用临时变量）代替。
- 不支持解构变量声明。这是一个依赖于结构兼容性的动态特性。创建中间对象并逐字段操作，不受名称限制。
- 要求参数直接传递给函数，并手动分配局部名称。请将参数直接传递给函数，并手动分配局部名称，而不是使用解构参数声明。
- 不支持枚举的声明合并。请保持代码库中每个枚举的声明紧凑。
- 不支持使用在程序运行时评估的表达式初始化枚举成员。此外，所有显式设置的初始化器必须是相同类型。请仅使用相同类型的编译时表达式初始化枚举成员。
- 不支持 export = ...语法。请改用普通的 export 和 import 语法。
- 不允许接口包含两个具有不可区分签名的方法（例如，参数列表相同但返回类型不同）。请避免接口扩展具有相同方法签名的其他接口。重构方法名称或返回类型。
- 不支持通过 for .. in 循环遍历对象内容。对于对象，运行时遍历属性被认为是冗余的，因为对象布局在编译时已知且运行时不可更改。对于数组，请使用常规的 for 循环进行迭代。
- 不支持 Function.apply 或 Function.call。这些 API 在标准库中用于显式设置被调用函数的 this 参数。在 ArkTS 中，this 的语义被限制为传统的 OOP 风格，并且禁止在独立函数中使用 this。请避免使用 Function.apply 和 Function.call。请遵循传统的 OOP 风格来处理 this 的语义。
- 不支持 Function.bind。这些 API 在标准库中用于显式设置被调用函数的 this 参数。在 ArkTS 中，this 的语义被限制为传统的 OOP 风格，并且禁止在独立函数中使用 this。请避免使用 Function.bind。请遵循传统的 OOP 风格来处理 this 的语义。
- 不支持函数表达式。请改用箭头函数来显式指定。
- 不支持在函数上声明属性，因为不支持具有动态更改布局的对象。函数对象遵循此规则，其布局在运行时不可更改。请勿直接在函数上声明属性，因为它们的布局在运行时不可更改。
- 当前不支持生成器函数。请使用 async/await 机制进行多任务处理。
- 不支持全局作用域和 globalThis，因为不支持具有动态更改布局的无类型对象。请使用显式模块导出和导入来在文件之间共享数据，而不是依赖全局作用域。
- 支持函数返回类型推断，但此功能目前受到限制。特别是，当 return 语句中的表达式是对返回类型被省略的函数或方法的调用时，会发生编译时错误。当返回类型被省略时，请显式指定函数的返回类型。
- 不支持导入断言，因为导入在 ArkTS 中是编译时特性，而不是运行时特性。因此，对于静态类型语言来说，在运行时断言导入 API 的正确性没有意义。请改用普通的 import 语法；导入的正确性将在编译时检查。
- 不支持 in 运算符。此运算符意义不大，因为对象布局在编译时已知且运行时不可更改。如果您想检查是否存在某些类成员，请使用 instanceof 作为替代方案。
- 不允许索引签名。请改用数组（arrays）。
- 允许在函数调用时省略泛型类型参数（如果可以从传递给函数的参数中推断出具体类型），否则会发生编译时错误。特别地，仅基于函数返回类型推断泛型类型参数是被禁止的。当推断受限时（特别是仅基于函数返回类型时），请显式指定返回类型。
- 当前不支持交叉类型。请使用继承（inheritance）作为替代方案。
- 不支持 is 运算符，必须将其替换为 instanceof 运算符。请注意，在使用对象字段之前，必须使用 as 运算符将其转换为适当的类型。请将 is 运算符替换为 instanceof。在使用对象字段之前，请使用 as 运算符将其转换为适当的类型。
- 不支持 JSX 表达式。请勿使用 JSX，因为没有提供替代方案来重写它。
- 不支持映射类型。请使用其他语言惯用法和常规类来实现相同的行为。
- 不支持重新分配对象方法。在静态类型语言中，对象的布局是固定的，同一对象的所有实例必须共享每个方法的相同代码。如果需要为特定对象添加特定行为，可以创建单独的包装函数或使用继承。
- 所有 import 语句都应该在程序中的所有其他语句之前。请将所有 import 语句放在程序的开头，在任何其他语句之前。
- 不支持模块名称中的通配符，因为 import 在 ArkTS 中是编译时特性，而不是运行时特性。请改用普通的 export 语法。
- 不允许类初始化存在多个静态代码块。将所有静态代码块语句合并到一个静态代码块中。
- 不支持嵌套函数。请改用 lambdas（匿名函数）。
- 不支持 new.target，因为语言中没有运行时原型继承的概念。此功能被认为不适用于静态类型。此功能不适用于静态类型和运行时原型继承，因此不受支持。没有提供直接的替代方案，因为它是一个根本性的差异。
- 如果数组字面量中至少有一个元素具有不可推断的类型（例如，无类型对象字面量），则会发生编译时错误。请确保数组字面量中的所有元素都具有可推断的类型，或将元素显式转换为已定义的类型。
- 不支持将命名空间用作对象。请将类或模块解释为命名空间的类似物。
- 不支持命名空间中的语句。请使用函数来执行语句。
- 不支持将对象字面量直接用作类型声明。请显式声明类和接口。
- 只允许一元运算符+、-和~作用于数字类型。如果这些运算符应用于非数字类型，则会发生编译时错误。与 TypeScript 不同，此上下文中不支持字符串的隐式类型转换，必须显式进行类型转换。请确保一元运算符+、-和~仅应用于数字类型。如有必要，请执行显式类型转换。
- 不支持以#符号开头的私有标识符。请改用 private 关键字。
- 不支持动态字段声明和访问，也不支持通过索引访问对象字段（obj["field"]）。请在类中立即声明所有对象字段，并使用 obj.field 语法访问字段。标准库中的所有类型化数组（如 Int32Array）是例外，它们支持通过 container[index]语法访问元素。
- 不支持原型赋值，因为语言中没有运行时原型继承的概念。此功能被认为不适用于静态类型。请改用类和/或接口来静态地将方法与数据“组合”在一起。
- 不支持通过 require 导入。它也不支持 import 赋值。请改用常规的 import 语法。
- 展开运算符唯一支持的场景是将数组或派生自数组的类展开到 rest 参数或数组字面量中。否则，必要时手动从数组和对象中“解包”数据。展开运算符仅用于将数组或派生自数组的类展开到 rest 参数或数组字面量中。对于其他情况，请手动从数组和对象中解包数据。
- 不支持在独立函数和静态方法中使用 this。this 只能在实例方法中使用。
- 当前不支持结构化类型。这意味着编译器无法比较两种类型的公共 API 并判断它们是否相同。请改用其他机制（继承、接口或类型别名）。
- 不支持 Symbol() API，因为其最常见的用例在静态类型环境中没有意义，对象的布局在编译时定义且运行时不可更改。除 Symbol.iterator 外，避免使用 Symbol() API。
- 目前，用标准 TypeScript 语言实现的 codebase 不得通过导入 ArkTS codebase 来依赖 ArkTS。请避免 TypeScript 代码库依赖 ArkTS 代码库。反向导入（ArkTS 导入 TS）是支持的。
- 仅在表达式上下文中支持 typeof 运算符。不支持使用 typeof 指定类型标注。请改用显式类型声明而不是 typeof 进行类型标注。
- 在 TypeScript 中，catch 子句变量类型标注必须是 any 或 unknown（如果指定）。由于 ArkTS 不支持这些类型，因此请省略类型标注。请省略 catch 子句中的类型标注。
- 不支持使用 this 关键字进行类型标注。请改用显式类型。
- 不支持通用模块定义（UMD），因为它没有“脚本”的概念（与“模块”相对）。此外，import 在 ArkTS 中是编译时特性，而不是运行时特性。请改用普通的 export 和 import 语法。
- 支持对象字面量，前提是编译器可以推断出这些字面量所对应的类或接口。否则，会发生编译时错误。在以下上下文中，不支持使用字面量初始化类和接口：初始化 any、Object 或 object 类型；初始化带有方法的类或接口；初始化声明带参数构造函数的类；初始化带有 readonly 字段的类。请确保对象字面量对应于显式声明的类或接口。避免将它们用于 any、Object、object 类型，或用于初始化带有方法、参数化构造函数或只读字段的类。
- 目前不支持 TypeScript 扩展标准库中的实用类型。Partial、Required、Readonly 和 Record 是例外。对于 Record<K, V>类型，索引表达式 rec[index]的类型为 V | undefined。请避免使用不支持的 TypeScript 实用类型。Partial、Required、Readonly 和 Record 可用于其特定目的。
- 不支持 var 关键字。请改用 let 关键字。
- 不支持 with 语句。请使用其他语言惯用法来实现相同的行为。
- 不允许在 @Builder 或 build() 函数体内声明局部变量。ArkTS 声明式 UI 语法严格要求 build 函数体内只能包含 UI 描述语句，不得包含变量声明或非 UI 逻辑。请直接使用表达式或状态变量，或将逻辑提取到组件外部的方法中。


## HarmonyOS API 使用规范(必读条目)

- 优先使用 HarmonyOS 官方提供的 API、UI 组件、动画、代码模板
- API 调用前请确认遵循官方文档入参、返回值及对应 API Level 和设备支持情况
- 对于任何不肯定的语法和 API 使用，不要猜测或自行构造 API，请尝试使用搜索工具获取华为开发者官方文档并进行确认
- 使用 API 前请确认是否需要在文件头添加 import 语句
- 调用 API 前请确认是否需要对应权限，在对应模块的`module.json5`中确认权限配置
- 如需使用依赖库，请确认依赖库的存在和匹配版本，并在对应模块的`oh-package.json5`中添加依赖配置
- 使用`@Component`和`@ComponentV2`时需要区分兼容性，尽量与已有工程代码保持一致
- UI 界面展示引用的常量需要定义 resources 资源值，并使用`$r`引用, 一般不直接使用字面值
- 新增国际化资源字符串时在对应的国际化每种语言下添加值，避免遗漏
- 新增颜色等资源请确认是否需要添加黑色主题支持(参考历史工程)，新工程建议默认支持黑色及白色主题


## ArkUI 动画规范(`animateTo`,`transform`,`renderGroup`,`opacity`)

- 优先使用 HarmonyOS 提供的原生动画 API 和高级模板
- 优先使用 HarmonyOS 的声明式 UI 和 `@State` 驱动动画，通过改变状态变量触发动画
- 对于包含复杂子组件的动画，将其设置为 `renderGroup(true)`，减少渲染批次
- 不可以在动画过程中频繁改变组件的 `width`、`height`、`padding`、`margin` 等布局属性，严重影响性能

## 其他要求

- 代码只能使用鸿蒙 v1 版本的 API。
- 开发规范请遵循鸿蒙的 MVC 原则。
- 对于文本内容封装为resource文件，写在AppScopeCommon\src\main\resources\base\element\string.json。
- 对于颜色内容封装为resource文件，写在AppScopeCommon\src\main\resources\base\element\color.json。
- 对于新增功能及页面，写在feature里面定义好的功能模块
- 对于新增实体类或者工具方法，写在common里面定义好的模块
- 对于entry，只定义首页ui以及跳转其他功能界面入口

## UI 布局与导航规范

- 所有非首页页面（被路由跳转的目标页面）必须使用 `NavDestination` 组件包裹根布局。
- 所有页面布局容器必须显式设置为全屏占满（`.width('100%').height('100%')`），以防止在中大屏幕（md/lg）设备上出现布局塌陷或仅显示在侧边栏的问题。





# 鸿蒙应用华为账号一键登录配置指南

## 一、开发环境准备
```typescript
// module.json5配置示例
{
  "module": {
    "metaData": [{
      "name": "client_id",
      "value": "从AGC控制台获取的Client ID"
    }]
  }
}
二、核心功能实现
1. 授权请求构建




import { authentication, util } from '@kit.AccountKit'<rsup>2</rsup>;

const buildAuthRequest = () => {
  const authRequest = new authentication.HuaweiIDProvider()
    .createAuthorizationWithHuaweiIDRequest();
  
  // 设置必选参数
  authRequest.scopes = ['quickLoginAnonymousPhone'];
  authRequest.state = util.generateRandomUUID();
  authRequest.forceAuthorization = false;

  return authRequest;
}
2. 登录按钮集成




import { LoginWithHuaweiIDButton } from '@kit.AccountKit';

@Entry
@Component
struct LoginPage {
  build() {
    Column() {
      LoginWithHuaweiIDButton({
        params: {
          scopes: ['quickLoginAnonymousPhone'],
          riskLevel: true
        }
      })
      .onClick(result => {
        this.handleLoginResult(result);
      })
    }
  }
}
三、错误处理规范
错误码	处理建议	触发场景示例
1001502014	检查scope权限是否通过审核	未申请quickLoginMobilePhone权限
1001500003	验证服务器是否部署在中国境内	海外服务器调用接口
1001500001	关闭代理或配置证书白名单	开启网络代理工具时触发
四、服务端对接流程
获取Access Token
调用用户信息接口



// 服务端示例（Node.js）
const getUserInfo = async (authCode) => {
  const tokenResponse = await fetch('https://oauth-login.cloud.huawei.com/oauth2/v3/token', {
    method: 'POST',
    body: new URLSearchParams({
      grant_type: 'authorization_code',
      code: authCode,
      client_id: 'your_client_id',
      client_secret: 'your_client_secret'
    })
  });

  const { access_token } = await tokenResponse.json();
  return fetch('https://account.cloud.huawei.com/rest.php', {
    headers: {
      'Authorization': `Bearer ${access_token}`
    }
  });
}
五、调试与优化建议
真机调试前同步系统时间
使用Hilog监控授权流程



import { hilog } from '@kit.PerformanceAnalysisKit'<rsup>1</rsup>;

hilog.info(0x0000, 'AuthFlow', '授权请求已发送');
hilog.error(0x0000, 'AuthError', `错误码: ${error.code}`)<rsup>1</rsup>;
六、合规性要求
登录页面必须包含《华为账号用户协议》跳转
未绑定手机号的账号需提供备选登录方式
中国境外账号需引导至国际版登录入口



// 协议跳转实现示例
Text('用户协议')
  .onClick(() => {
    openUrl('https://developer.huawei.com/consumer/cn/doc/');
  })

## 前端工程约定（ViewModel / lib_api / ApiUrls / StorageKey / Entity）

本文档概述了在本工程中对前端层（ArkTS/ETS）的约定：如何拆分页面逻辑、统一后端 API 调用、管理 URL、持久化 key 和实体类组织。

1) ViewModel 层
- 所有页面中的调用逻辑（网络请求、第三方 SDK 交互、复杂业务逻辑）应从 `build()`/组件中提取到对应页面的 `ViewModel` 类中。
- 位置示例：`feature/<feature_name>/src/main/ets/viewmodel/<Page>ViewModel.ets`。
- `ViewModel` 只负责业务逻辑和数据处理，不直接操作 UI 布局。页面通过调用 `ViewModel` 的方法并根据返回结果或回调更新 `@State`。

2) lib_api
- 所有对后端的 HTTP 请求应由 `common/lib_api` 中的 API 封装实现（如 `AuthApi`、`UserApi` 等），页面或 `ViewModel` 只调用 `lib_api` 暴露的方法。
- 位置示例：`common/lib_api/src/main/ets/service/AuthApi.ets`。
- `lib_api` 内部可以使用统一的 `ApiUrls` 常量类构造 URL。

3) ApiUrls
- 所有后端 url 地址集中管理在一个类中（例如 `ApiUrls`），便于在不同环境下切换基线地址。
- 位置示例：`common/lib_api/src/main/ets/service/ApiUrls.ets`。

4) 实体类组织规范
- **统一存放位置**：所有实体类都应放到 `common/lib_entity` 模块中
- **包结构组织**：在 `lib_entity/src/main/ets/entity/` 目录下，按照接口功能建立对应的包
- **命名规范**：每个接口建立对应的包，包中存放该接口所需要的实体类
- **类定义方式**：实体类采用 `class` 进行定义和接收
- **示例结构**：
  ```
  lib_entity/
  └── src/main/ets/entity/
      ├── auth/                 # 认证相关实体类
      │   ├── HuaweiLoginRequest.ets
      │   ├── UserInfo.ets
      │   └── HuaweiLoginResponse.ets
      ├── user/                # 用户相关实体类
      ├── course/              # 课程相关实体类
      └── ...
  ```

5) 模块导出与依赖规范
- **模块导出（Index.ets）**：每个模块必须在其 `Index.ets` 文件中导出对外公共 API（类、函数或常量），以便其它模块通过模块名直接导入。例如，`common/lib_api/Index.ets` 应导出 `UserService`、`FitnessService` 等对外使用的类型。
- **声明依赖（oh-package.json5）**：如果模块文件中 `import { X } from 'other_module'`，则必须在该模块的 `oh-package.json5` 中把 `other_module` 列为 `dependencies`。这可保证构建工具在打包/解析时能正确解析模块间的引用。
- **检查与验证**：在新增导出或新增模块间引用后，请运行以下检查命令（在项目根目录 PowerShell 中执行）：

```powershell
Select-String -Path "**\*.ets" -Pattern "from 'lib_api'|from 'appscopecommon'|from 'lib_entity'" -SimpleMatch
```

并比对每个 `import` 中使用的模块是否在本模块的 `oh-package.json5` 的 `dependencies` 中列出；同时检查被引用模块的 `Index.ets` 是否包含相应的 `export`。这可以手动执行，也可在 CI 中添加自动化脚本。

示例：如果 `feature_log` 中有 `import { StorageKey } from 'appscopecommon'`，那么 `feature_log/oh-package.json5` 中必须包含 `"appscopecommon": "file:../../AppScopeCommon"`，并且 `AppScopeCommon/Index.ets` 必须导出 `StorageKey`。

## 严格的 ArkTS/ETS 静态检查与修复步骤（必做）

为保证代码在 ArkTS/ETS 环境下可编译通过并符合项目规范，提交 PR 前必须按下列步骤逐项检查并修复：

1) 源码预检查（PowerShell 快速脚本，运行于工程根目录）

```powershell
# 查找未显式类型的 any/unknown 使用
Select-String -Path "**\*.ets" -Pattern '\b(any|unknown)\b' -SimpleMatch

# 查找可能的 TextEncoder/TextDecoder 使用（设备或平台可能不支持）
Select-String -Path "**\*.ets" -Pattern 'TextEncoder|TextDecoder' -SimpleMatch

# 查找 throw 语句（应只 throw Error 实例）
Select-String -Path "**\*.ets" -Pattern '(^|\s)throw\s+' -SimpleMatch

# 查找模块引用缺失（临时检测，若使用自定义 ohos 模块名请使用对应替换）
Select-String -Path "**\*.ets" -Pattern "from 'lib_api'|from 'appscopecommon'" -SimpleMatch

# 查找对象字面量直接用于类型初始化的代码（需人工审查）
Select-String -Path "**\*.ets" -Pattern "= \{[\s\S]*?\}" -AllMatches
```

2) 必要修复清单（每项需在 PR 描述中列出并说明）
- 消除 `any` / `unknown`：替换为明确的类或接口类型；若外部模块缺失类型声明，添加模块的 `.d.ts` 最小声明（例如上游 `feature/*/src/main/ets/types.d.ts`）。
- 模块解析问题：若编译器报 `Cannot find module 'lib_api'`，不要在业务代码里用隐式 any，必须在对应模块下添加类型声明文件或在工程级别维护 typings（已示例：`feature/xxx/src/main/ets/types.d.ts`）。
- TextEncoder/TextDecoder：ArkTS/目标设备可能不提供，避免直接使用或提供轻量 polyfill（仅在运行环境允许时），并在代码中做能力检测（若不可用则走替代实现）。
- `throw` 语句：仅使用 `throw new Error('msg')` 或 `throw new SomeError(...)`，不要 `throw` 原始值或未定义对象。
- 对象字面量：初始化类或接口实例时使用明确类（`new MyClass({...})`）或先构造临时类实例，避免使用纯 untyped object literal。

3) 编译/静态检查（在 DevEco/CI 上执行）
- 在 DevEco Studio 中运行项目编译（Debug 模式），修复所有编译器和 ArkTSCheck 报错。
- 在 CI 上加入一步：运行 ArkTS 编译或项目构建命令并阻断含有错误（exit non-zero）。示例（根据项目构建脚本调整）：

```powershell
# 在 CI 中运行（示例，替换为实际构建命令）
hpm build || exit 1
```

4) 类型声明和第三方模块策略
- 所有对内置/第三方模块（如 `lib_api`, `appscopecommon`, `@hw-agconnect/auth`）的引用必须有对应类型声明；优先做法是由模块提供 `.d.ts`，若无则在项目内为最小暴露 API 添加局部声明文件。

5) PR 模板检查项（在每次 PR 描述里勾选）
- [ ] 已运行预检查脚本并贴结果摘要。
- [ ] 已消除 `any` / `unknown` 的使用或说明为什么必须暂时保留。
- [ ] 所有外部模块类型声明已提交或引用已记录。
- [ ] 已在 DevEco 或 CI 上成功构建通过。

遵循以上流程能显著减少 ArkTS 编译/运行时错误并满足项目规范要求。

- 发布到生产环境时请改为 HTTPS 并替换为线上域名。

4) 存储 key
- 所有写入 `AppStorage` / `PersistentStorage` / `StorageProp` 的 key 常量应统一放入 `AppScopeCommon` 的 `StorageKey`（`AppScopeCommon/src/main/ets/appScopeKey/AppScopeKey.ets`）。
- 例如：`StorageKey.AUTH_TOKEN`、`StorageKey.USER_INFO` 等。

5) 推荐调用流程
1. 页面点击触发 `onClick` → 调用 `this.viewModel.signIn()`。
2. `ViewModel` 内部调用 AGC SDK(`auth.signIn()`)，并将拿到的标识/uid 组装为请求参数。
3. `ViewModel` 调用 `lib_api` 中的 `AuthApi.huaweiLogin(payload)`，统一处理 HTTP 请求与 JSON 解析。
4. `ViewModel` 根据后端返回结果保存 `StorageKey.AUTH_TOKEN` 到 `AppStorage`（或安全存储），并返回结果给页面。
5. 页面根据返回结果更新 `UserService` / `@State` 并导航。

6) 注意事项
- ViewModel 与 lib_api 应尽量返回明确的数据结构（避免页面再做大量字符串解析）。
- 网络请求统一处理超时、错误码和 JSON 解析异常，`lib_api` 可统一返回 `{ status, data, text }` 结构。
- 在调试阶段可记录必要日志，但发布前删除或降级敏感日志（避免打印 token/用户敏感信息）。