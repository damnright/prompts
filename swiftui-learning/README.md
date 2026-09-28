# SwiftUI：页面、状态与跨设备体验

[技术路线：第 5～6 项](../tech-list.md) · [通用学习流程](../learning-flow.md) · [共用 Xcode 环境](../swift-learning/environment.md) · [实操](practice.md) · [设计补充](design.md)

主教材为 Apple **Develop in Swift** 的 SwiftUI 与 Data modeling 指定章节。先跟做教材中的最小例子，再把相同机制用到自己的单词列表；不另做一套与英语 App 无关的完整教程项目。

## 1. 学习要点与前置条件

先完成 [Swift S1～S4](../swift-learning/README.md)，任务生命周期单元同时用到 S5。复用一个 iOS 练习 App，教学基线与环境设置见上方共用入口。

- View 是随状态变化产生的界面描述；状态所有者与列表身份影响数据是否保留。
- `State`、`Binding`、`@Observable`、`@Bindable`、`Environment` 分别处理持有、传递和访问，不能互相随意替换。
- 列表、详情、编辑需要共享一份明确的权威数据，编辑草稿与已保存结果应分开。
- 页面需要正常、加载、空、失败、取消和恢复路径。
- 适配取决于可用窗口、内容与输入方式，不能只区分设备名称或把手机放大。

## 2. 阅读单元与对应实操

U1～U4 对应第 5 项；U5～U6 对应第 6 项。Apple 教程从 [Develop in Swift 目录](https://developer.apple.com/tutorials/develop-in-swift/)按同名章节进入；下面同时给出核心课的直达链接。

| 单元 | 资料与具体范围 | 本轮深度与暂缓内容 | 实操 |
| --- | --- | --- | --- |
| U1：View 与组合 | SwiftUI → Explore Xcode 的 [Hello, SwiftUI](https://developer.apple.com/tutorials/develop-in-swift/hello-swiftui)；Views, structures, and properties 的 [Customize views with properties](https://developer.apple.com/tutorials/develop-in-swift/customize-views-with-properties) | 跟做页面、属性、modifier 与预览；理解声明式组合，不展开渲染内部实现 | [U1](practice.md#u1) |
| U2：状态与编辑 | Buttons and state 的 [Update the UI with state](https://developer.apple.com/tutorials/develop-in-swift/update-the-ui-with-state)；[Managing model data in your app](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)：Make model data observable、Observe model data in a view、Create the source of truth for model data、Share model data throughout a view hierarchy、Change model data in a view | 应用 Observation、所有权与绑定；对照[本地设计补充](design.md)区分保存和取消 | [U2](practice.md#u2) |
| U3：列表、输入与导航 | Lists and text fields 的 [Create dynamic content](https://developer.apple.com/tutorials/develop-in-swift/create-dynamic-content)；Data modeling → Navigation, editing, and relationships 的 [Navigate sample data](https://developer.apple.com/tutorials/develop-in-swift/navigate-sample-data) | 跟做列表、输入与导航；本轮以模拟数据代替持久层，SwiftData 细节留到第 12 项 | [U3](practice.md#u3) |
| U4：异步状态与页面生命期 | 回查 Swift [Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/) 的 Task Cancellation / The Main Actor；SwiftUI [task(id:name:priority:file:line:_:)](https://developer.apple.com/documentation/swiftui/view/task%28id%3Aname%3Apriority%3Afile%3Aline%3A_%3A%29)：Parameters 中 id / action、Discussion | 理解 `.task` 和 `.task(id:)` 的重启、取消；新 SDK 增加的默认参数按已安装版本识读，不为练习采用新平台专属功能 | [U4](practice.md#u4) |
| U5：布局与窗口 | Layout and style 的 [Design an interface](https://developer.apple.com/tutorials/develop-in-swift/design-an-interface)；[HIG — Layout](https://developer.apple.com/design/human-interface-guidelines/layout)：Visual hierarchy、Adaptability、Size classes、Guides and safe areas | 应用标准容器、尺寸优先级、安全区与窗口适配；复杂自定义 Layout 暂缓 | [U5](practice.md#u5) |
| U6：无障碍与可用性 | [HIG — Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)：Vision、Hearing、Mobility、Cognitive；App refinement 的 [Add inclusive features](https://developer.apple.com/tutorials/develop-in-swift/add-inclusive-features)；[设计学习路线](../design-learning.md) 2.4、2.5、2.7、2.10 与第 3 节 | 在同一流程检查文字、读屏、焦点、输入、错误文案；无需先学完整设计工具 | [U6](practice.md#u6) |

## 3. 本轮产出与验收

产出一个**模拟数据可运行的单词列表 → 详情 → 编辑流程**。保存能同步、取消不污染原值，重新排序不丢失身份；加载失败可以恢复，离开页面不会让过期结果覆盖新页面。

在 iPhone、iPad 窄窗口、大字体和深浅色下检查同一任务；至少用 VoiceOver 或 Accessibility Inspector 检查语义，并实际尝试键盘输入与按钮操作。截图和 Preview 不替代交互验证。

这里不要求已经保存到磁盘或完成离线同步。关掉 App 丢失模拟数据是当前范围内的正常行为；第 8 项完成后进入 [G7 最小联调](../go-learning/practice.md#g7)，让列表读取 Go + PostgreSQL 的真实数据。持久化、完整客户端分层、音频和商业化分别在后续条目展开。
