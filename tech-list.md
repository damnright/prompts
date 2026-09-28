# 英语 App：学习与产品实施路线

学习方式统一见[通用学习流程](learning-flow.md)：**简要提纲 → 指定章节资料 → 对应实操 → 架构与设计补充**。本页负责范围、先后关系与能力验收；第 1～9 项的详细教材、实操与补充放在下方六个主题目录，UI/UX 复用[设计学习路线](design-learning.md)。不设时间表或刷题数量要求。

快速定位：[1～9 学习入口](#foundation-learning) · [开工门槛](#start-building) · [最终学习顺序](#learning-order) · [能力深度](#capabilities)。

## 使用方式与默认范围

- **目标**：能定义、实现、发布并验证一个英语学习产品；能解释和评审 AI 生成的实现，定位问题并判断取舍。
- **技术方向**：iPhone / iPad 使用 Swift / SwiftUI，业务后端使用 Go + PostgreSQL。首版以一个 Go 服务承载业务，按职责组织代码；Python 用于确有需要的分析、评测或独立服务。
- **产品假设**：沿用“单词学习与复习 → AI 文字训练 → 按需加入语音”的默认路径。第 9 项若发现语音才是核心价值，应提前做短轮语音验证，再决定首版范围。
- **学习深度**：语法和低频 API 达到识读；状态、并发、权限、事务、成本等机制需要理解；产品判断、数据建模和关键流程需要应用与评审。已经能通过验收的内容可直接跳过。
- **编号是主题索引**：保留 1～52 项便于回查，实际推进看文末“最终学习顺序”。测试、安全、运行能力和产品验证会穿插开展，不能等到目录末尾才开始。
- **资料使用**：每阶段先读指定范围，再在同一个英语 App 中完成对应编号的实操。教材代码只作示例；按项目实际 Xcode、Swift 语言模式、最低系统版本、Go 与 PostgreSQL 版本核对。未触发的进阶主题先不展开。

## 贯穿全程的工作能力

- Git：读懂状态与 diff，分支、小步提交、合并冲突、恢复方式；能区分未提交工作、暂存区、本地提交和远端。
- 运行与排错：使用 Xcode Preview、模拟器和真机；读编译错误、断点、调用栈、请求响应与服务日志，分清构建失败、运行失败和业务失败。
- 配置与依赖：区分开发、测试和生产；使用环境变量、依赖锁定与迁移记录。服务端密钥不进客户端、仓库或日志；复用已有 OrbStack / TablePlus。
- AI 协作：先明确输入、输出、约束与验收，再按小功能生成、检查 diff、运行验证；能沿“页面 → 请求 → 服务 → 数据库 / AI”解释行为，用失败案例审查结果。

**资料与实操 0：** Git 有缺口时读 [Pro Git 2.2 Recording Changes](https://git-scm.com/book/en/v2/Git-Basics-Recording-Changes-to-the-Repository)、[2.4 Undoing Things](https://git-scm.com/book/en/v2/Git-Basics-Undoing-Things)、[3.2 Basic Branching and Merging](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging) 的例子，在临时仓库演练；Xcode 跟做 [Develop in Swift](https://developer.apple.com/tutorials/develop-in-swift/) 的 Getting started → Meet Xcode、Create a project，以及 App refinement → Investigate and fix a bug。能运行一个页面、定位一个错误，并安全撤销自己的试验改动即可。

**共用实操约定：** 默认复用同一个练习 App、测试账号与独立测试库；每项从已有可运行版本开始，保留输入、预期结果与实际结果。故障注入、迁移、删除、购买与恢复只在隔离环境或沙盒中演练，完成后清理自己创建的测试数据、文件和资源。阶段验收是学习目标，不表示当前仓库已实现这些功能。

---

<a id="foundation-learning"></a>

## 第 1～9 项：按主题进入学习

每个目录以 README 为单一入口，按“指定资料 → 对应实操 → 设计判断 → 验收”推进。紧密相关的编号共用材料，不重复建环境；目录内单元编号与下方总路线编号分别使用。

| 总路线编号 | 独立学习入口 | 主要产出 |
| --- | --- | --- |
| 1～2 | [SQL / PostgreSQL](sql-learning/README.md) | 查询与事务实操、小功能模型、并发与归属反例、设计评审 |
| 3 | [HTTP / API](http-learning/README.md) | 请求响应观察、错误与超时判断、接口边界说明 |
| 4 | [Swift](swift-learning/README.md) | 类型与错误例子、值 / 引用判断、异步取消与隔离实操 |
| 5～6 | [SwiftUI](swiftui-learning/README.md) | 列表 / 详情 / 编辑流程、状态与任务设计、跨设备和无障碍检查 |
| 7～8 | [Go](go-learning/README.md) | 有测试的业务规则、单词 API、数据库事务与 SwiftUI 联调 |
| 9 | [产品与市场](product-learning/README.md) | 有证据的定位、首版与原型、成本与首批用户验证计划 |

SQL 已有资料继续复用；SwiftUI 与 Swift 共用 Xcode，Go 与 SQL 共用 PostgreSQL。第 9 项可以并行开展。练习结果服务于同一个产品，但技术练习的示例功能不替代产品选择。

---

## 阶段一：数据库与网络基础

- [ ] **1～2. SQL / PostgreSQL 基础与设计评审**
  - 表与查询：字段、SELECT、WHERE、NULL、ORDER BY、LIMIT；JOIN、聚合与结果粒度
  - 类型与约束：时间与时区、JSONB、主外键、组合唯一、非空、范围与删除行为
  - 修改与事务：INSERT / UPDATE / DELETE、ACID、自动提交、提交 / 回滚 / 保存点、失败事务、零行更新与重复请求
  - 并发与性能：索引、稳定分页、EXPLAIN、MVCC、隔离级别、行锁与重试
  - 运行与演进：兼容迁移、连接预算、权限、VACUUM、WAL、备份与恢复的职责
  - 数据库设计：实体关系、每行粒度、事实 / 状态 / 快照、归属与生命周期
  - 学习入口：[融合章节导读](sql-learning/README.md) 第 1～9 单元；Neon 为主教材，官方文档按具体问题查证
  - 实操 1～2：[对应实操](sql-learning/practice.md)与[八表案例、设计评审](sql-learning/design.md)；环境复用[OrbStack + TablePlus](sql-learning/environment.md)
  - 完成标准：能设计一个小功能的数据模型，用约束、事务和并发反例检查正确性；基础语法能查能读即可。复杂查询、数据库内核与复制运维不作为开工门槛
  - Go 接入先理解系统边界，驱动与 API 编码在第 7～8 项完成；真实备份恢复演练在对外试用前完成

- [ ] **3. HTTP / API 基础**
  - URL、DNS / TLS 基本作用、HTTP 方法、请求与响应、Header、Status Code、JSON 与 Content-Type
  - REST 资源、分页、Cookie / Token、身份认证与权限检查的区别
  - 超时、取消、连接失败、服务端失败；请求失败不代表服务端一定没写入，重试写操作需要去重设计
  - HTTPS 保护传输；CORS 是浏览器跨源机制，原生 URLSession 的访问控制仍依赖服务端认证与授权
  - SSE、WebSocket、文件上传先识读用途；具体实现随 AI 文字与语音需求展开
  - 学习入口：[HTTP 分单元导读](http-learning/README.md)；先读 H1～H5，再用本地教具观察结果
  - 实操 3：[请求、JSON、状态、超时与边界实验](http-learning/practice.md)；第 8 项完成后用真实 API 复验，说明哪些情况可以安全重试

---

## 阶段二：Swift / SwiftUI

- [ ] **4. Swift 基础与并发入门**
  - 类型、Optional、集合、struct / class、enum、protocol、closure、错误处理；泛型先能识读
  - 值与引用语义、ARC 与循环引用；理解异步任务中的对象生命周期
  - async / await、Task、取消、MainActor / actor 与 Sendable 的用途；认识 await 前后状态可能变化
  - 不用随意加 Task、强制解包或关闭并发检查来消除错误；复杂 TaskGroup、底层锁按需
  - 学习入口：[Swift S1～S5 导读](swift-learning/README.md)，配套共用 Xcode 环境与可运行语言例子
  - 实操 4：[类型、集合、语义、错误与并发](swift-learning/practice.md)；表示单词和作答，处理失败与取消，并解释隔离与生命周期

- [ ] **5. SwiftUI 基础与状态管理**
  - View、组合与重算、稳定身份；区分视图描述和长期存活的业务对象
  - State、Binding、Observable、Environment 的职责与状态归属；按最低系统版本选择兼容写法
  - List / ScrollView、表单、NavigationStack、Sheet / Alert、加载 / 空 / 错误状态
  - 页面生命周期与 `.task`；避免页面重建导致重复请求、重复计数或任务泄漏
  - 学习入口：[SwiftUI U1～U4 导读](swiftui-learning/README.md)与[状态设计补充](swiftui-learning/design.md)
  - 实操 5：[模拟单词列表、详情与编辑](swiftui-learning/practice.md#u1)；保存与取消符合约定，往返页面状态一致，能说明数据归属与任务生命周期

- [ ] **6. SwiftUI 布局与基本体验**
  - 按可用窗口空间组织内容：Safe Area、Size Class、横竖屏、iPad 窗口缩放与多栏导航
  - 优先标准容器与布局规则，GeometryReader / 自定义 Layout 在常规布局无法满足时再用
  - Dynamic Type、VoiceOver 标签、触控区域、键盘遮挡、焦点、深浅色与长文案
  - 页面结构、视觉层级、引导与错误恢复；Mac 专用适配延后
  - 学习入口：[SwiftUI U5～U6 导读](swiftui-learning/README.md)，复用第 5 项的同一个 App
  - 实操 6：[布局与无障碍检查](swiftui-learning/practice.md#u5)；核心流程在 iPhone、iPad 窄窗口与大字体下可用，实际检查键盘和 VoiceOver

> 完成标准：能运行、修改并评审页面，解释状态和任务生命周期；不要求手写熟练所有 SwiftUI API。先做普通文字与表单页面即可进入下一阶段。

---

## 阶段三：Go 后端入门

产品开发前完成 Go 基础和最小 API。这里使用 **net/http + pgx / pgxpool** 理解调用链；无需先引入 Web 框架、ORM 或复杂分层。

- [ ] **7. Go 基础**
  - 类型、控制流、函数与多返回值；struct / method / interface、slice / map / pointer
  - error、errors.Is / errors.As、defer、资源释放；package / Go Modules
  - context 的取消与超时传递；goroutine、channel、共享状态、数据竞争的基本风险
  - gofmt / go test / go vet；并发路径使用 race detector 检查
  - 学习入口：[Go G1～G3 导读](go-learning/README.md)与[环境操作](go-learning/environment.md)
  - 实操 7：[类型、规则测试与取消](go-learning/practice.md#g1)；覆盖错误与边界，确认下游能退出且资源释放

- [ ] **8. Go HTTP / PostgreSQL 实作**
  - Router / Handler / Middleware、JSON 编解码、请求校验、请求体大小限制与统一错误响应
  - 配置、环境变量、slog、Request ID；服务与数据库的超时、连接池与优雅退出
  - 参数化 SQL、CRUD、事务、Rows / 连接释放；context 从 HTTP 传到 SQL
  - 按需要分离 HTTP、业务规则与数据访问；只有一种简单实现时，不强制为每层建立 interface
  - httptest、真实 PostgreSQL 集成测试、迁移与测试数据隔离
  - 学习入口：[Go G4～G7 导读](go-learning/README.md)；接口契约、隔离 schema 与设计评审集中在同一目录
  - 实操 8：[单词 API 与客户端联调](go-learning/practice.md#g4)；完成 CRUD / 分页，验证非法输入、不存在、冲突、超时及关联写入回滚

**进入产品开发的技术验收：**

- Go API 有真实运行记录和请求结果，数据库确实写入；HTTP 测试与 PostgreSQL 集成测试通过。
- 能解释一次请求中的校验、SQL、事务和错误返回，并用重复提交、失败回滚与取消检查边界。
- 按 [Go G7 最小联调](go-learning/practice.md#g7)提前应用第 11 项的 URLSession 基础，让 SwiftUI 页面加载该 API 的列表；能区分网络错误、HTTP 错误与解码错误。
- 能从客户端、服务日志和数据库逐层定位一次故障。此时只需本地或受控测试，不开放未认证的写接口。

---

## 阶段四：产品与市场基础

第 9 项可在技术学习期间提前开展；在投入完整业务功能前，完成一轮用户研究、原型验证与范围选择。

- [ ] **9. 产品定义与市场验证**
  - 目标用户与场景：市场细分、英语水平、学习目标、使用频率、使用者与付费者；明确首发市场、年龄范围和支持语言
  - 需求研究：用户访谈、行为观察、JTBD；关注过去的行为、现有办法、问题频率与实际付出，区分事实与假设
  - 市场与竞品：可触达的人群规模、直接竞品与替代方案、价格、评价、切换成本；从具体人群估算机会
  - 定位与价值：为谁、解决什么问题、带来什么可感知结果、为什么值得换用；能用一句话表达
  - MVP 与 UX：核心任务、学习闭环、低保真原型、需求优先级、验收标准；依据用户价值、风险和成本取舍
  - 商业模式：订阅 / 买断 / 按量、免费边界、付费意愿与价格实验；理解平台费用、AI / 语音成本、毛利、获客成本与生命周期价值，早期估算要注明假设
  - 首批用户与营销：选择能接触目标用户的渠道，理解内容、社群、推荐、App Store 搜索和价值表达；先验证渠道再扩大投入
  - 产品实验：明确假设、证据和决策条件；分别验证使用意愿、持续使用、学习效果与付费，不把下载量或口头好评当作成功

**学习入口：** [产品与市场分单元导读](product-learning/README.md)。以 YC 指定课程为主，SBA 与既有设计路线补充；访谈、竞品、原型、成本和验证的填写框架集中在[实操页](product-learning/practice.md)，判断反例见[设计补充](product-learning/design.md)。

**对应实操与开工验收：** P1～P3 合起来是实操 9。

- **P1：用户与市场。** 有证据的定位、替代方案与差异化理由，标明来源和未验证假设。
- **P2：首版方案。** 核心任务原型、首版 / 暂缓功能、内容来源、验收标准与基于观察的修订。
- **P3：验证计划。** 收费与成本假设、首批用户渠道、明确口径的指标，以及继续、调整或停止的条件。

完成方案与初步验证即可开工。原型反馈是早期信号；真实留存、学习效果和付费证据在可用版本中持续积累。

---

<a id="start-building"></a>

## ★ 完成 1～9 的开工验收后正式开始产品开发

**从一个可运行、可测试的学习闭环开始，以开发为主、按当前问题补学。** 不把后面的全部条目当作开工前置条件，也不把“做出页面”当作已经能对外提供服务。

- 从第一条业务规则开始穿插第 32 项测试、第 37～38 项边界与失败设计。
- 在接触外部用户及其数据前，完成第 26～28 项必要安全能力、第 33～36 项运行基础和第 42～44 项最小验证方案。
- 在开放收费前完成第 29 项；在加入语音前完成第 13、23～25 项。详细交付门槛见文末。

---

## 阶段五：iOS 工程能力

在真实功能中逐步建立结构。第 10～12 项支撑首个学习闭环；第 13 项在语音验证前完成。

- [ ] **10. SwiftUI 项目架构**
  - 按 Feature 组织代码，区分页面状态、业务规则、网络与存储；明确每份状态的唯一来源
  - View / 可观察模型、Service / Repository 的职责；简单页面不强制套完整 MVVM 或多层协议
  - 通过初始化参数等简单方式注入依赖，用模拟服务支持 Preview 和测试
  - 实操 10：画出一个学习功能的调用与状态关系；替换为模拟 API 后页面可运行，业务规则可独立测试

- [ ] **11. iOS 网络层**
  - URLSession、Codable、async / await；DTO 与业务模型按实际差异转换
  - 区分连接、HTTP 状态、解码和业务错误；取消过期请求，避免旧响应覆盖新页面
  - 登录凭据、刷新失败、可重试请求与退避；重试次数和总等待时间有上限
  - SSE 在需要流式文字时加入：事件分片、完成 / 失败、断连、取消与部分结果，不把每个网络分片当成完整消息
  - 实操 11：接通真实 API，覆盖加载、空、失败、重试和快速切换页面；模拟乱序响应，确认最终显示与当前请求一致

- [ ] **12. 本地存储与同步边界**
  - UserDefaults 保存偏好，Keychain 保存敏感凭据；文件缓存与 SwiftData 按数据和查询需求选择
  - 区分服务端权威数据、本地缓存与尚未提交的输入；首版可以在线写入、离线只读，不自动引入完整离线同步
  - 缓存失效、结构迁移、账号切换清理；取消或失败后保留可恢复的用户输入
  - 确有离线写入需求时再设计待同步队列、幂等键、冲突策略与删除传播
  - 实操 12：重启恢复允许缓存的内容；退出 / 换号后不泄露前一账号数据；断网时能解释哪些操作可用、哪些尚未保存

- [ ] **13. AVFoundation / AVFAudio 音频**
  - 麦克风权限、AVAudioRecorder / 播放、AVAudioSession category / mode / activation
  - 采样率、声道、编码与容器、音频时长和文件大小；选择与服务端一致的上传格式
  - 耳机 / 蓝牙路由、中断、前后台切换、停止与释放；区分模拟器和真机表现
  - 临时录音文件、保留期限与删除；未授权时保留文字练习入口
  - 实操 13：真机完成录音和回放，验证拒绝权限、来电或系统中断、耳机切换与再次录音；停止后资源释放，临时文件按策略清理

**学习资料与范围：**

| 资料与具体章节 | 本轮范围与深度 | 对应实操 |
| --- | --- | --- |
| [Managing model data in your app](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app) | 回看状态唯一来源、共享与修改；应用到当前 Feature，不额外建立通用架构框架 | 10 |
| [URLSession](https://developer.apple.com/documentation/foundation/urlsession) | Overview、Types of URL session tasks、Performing asynchronous transfers、Handling errors；WebSocket 和后台传输按需 | 11 |
| [Preserving your app’s model data across launches](https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches)、[Keychain items](https://developer.apple.com/documentation/security/keychain-items) | SwiftData 读配置存储、保存与读取的例子；Keychain 读添加、查询、修改 / 删除的入口，按所用 API 核对错误处理 | 12 |
| [AVAudioRecorder](https://developer.apple.com/documentation/avfaudio/avaudiorecorder)、[AVAudioSession](https://developer.apple.com/documentation/avfaudio/avaudiosession) | Recorder 读创建、控制录音、响应事件；Session 读标准行为配置、激活 / 关闭、路由与中断 | 13 |

---

## 阶段六：API 设计与数据建模

第 14～15 项与第 10～12 项一起完成首个业务闭环；复用第 1～2 项的数据库知识。

- [ ] **14. API 契约与业务一致性**
  - 资源、请求 / 响应、校验、统一错误、稳定排序与分页、认证 / 授权、限流
  - 客户端与服务端的兼容演进：新增可选字段、旧客户端、破坏性变更；需要时用 OpenAPI 表达契约
  - 幂等键的作用域、唯一约束、重复请求返回、并发更新与状态转换；重试不能重复累计学习进度
  - 数据库事务只包住必要业务写入；外部 AI 调用不放进长事务，设计调用前后状态和失败补救
  - 实操 14：为“提交一次作答”写契约并实现；相同请求重复发送、超时后重试及并发提交时，结果符合事先定义的计数与冲突规则

- [ ] **15. 业务模型与学习内容**
  - 按当前功能设计 User、Word / 词义、WordGroup、LearningSession、作答记录与进度；Lesson、Conversation、Message、AI Run、Usage Record、Subscription 按功能逐步加入
  - 区分公共词库、用户词表、学习事实与推导状态；多义词、词形、搭配与例句不简单压成一个字符串
  - 内容来源与使用权、释义 / 例句审核、内容版本、导入校验、纠错与下架；首版可用受控导入流程，无需先做完整 CMS
  - 明确归属、时区、历史快照、删除与保留范围；内容修订后历史作答仍能解释
  - 实操 15：为首版画实体关系并说明每行含义；导入少量有来源的内容，验证重复、坏数据、内容更新、跨用户引用和账号删除的处理

**资料与范围：** [OpenAPI — API Endpoints](https://learn.openapis.org/specification/paths.html) 读 Paths、Path Item 与 Operation 的例子，能表达自己的契约即可，对应实操 14。数据设计复用 [sql-learning/design.md](sql-learning/design.md) 第 1～3 节和第 5.4 节；回查导读第 2、3、6、7、8 单元的约束、事务、并发、迁移与权限，对应实操 14～15。内容使用权按实际来源条款核实。

---

## 阶段七：英语学习核心业务设计

先说明怎样帮助用户学习，再确定表与算法。首版只实现已经选定的核心任务。

- [ ] **16. 学习流程与状态机**
  - 学习 Session 的开始、进行、完成、退出、恢复；AI 会话、音频任务与支付分别有自己的状态
  - 定义状态、事件、允许的转移、执行责任与可恢复点；避免用多个互相冲突的布尔值表达流程
  - 实操 16：画一次练习的状态图，标出重复点击、网络断开、App 退出和再次进入；不合法的转移有测试

- [ ] **17. 学习证据与能力模型**
  - 区分接触过、识别、回忆、在新语境中正确使用；记录任务、答案、提示程度、时间与评价依据
  - 学习事实保留可追溯记录，熟练度和进度是按规则得到的估计；自评、规则判定、AI 评价的来源分开
  - CEFR 用于理解能力描述与任务难度；一次对话或一个模型评分不等于正式等级测评
  - 实操 17：用同一个词设计识别、无提示回忆和造句任务；说明这些结果如何影响进度，以及哪些结论尚无证据

- [ ] **18. 提取练习与间隔重复基础**
  - Active Recall、Spaced Repetition、反馈与复习负担；安排复习和验证真实学习效果是两件事
  - SM-2 / FSRS 先理解输入、状态、评分与下一次复习时间；选用可验证的现有实现，避免从头发明算法
  - 复习历史、遗忘 / 重学、跨天与时区、算法版本；不把“见过”自动等同于“记住”
  - 实操 18：用固定时钟和一组复习历史运行调度，检查正确、遗忘、连续重试与跨天行为；更换算法后历史与结果可解释

- [ ] **19. AI 训练会话设计**
  - 目标词 / 词义、已练习词、薄弱项、用户水平、场景、提示程度、结束条件与反馈时机
  - 区分“出现目标词”“使用正确”“独立完成”；允许换题、纠正和恢复，避免机械塞词
  - 服务端保存会话进度，按需选择上下文；模型上下文不是唯一的业务状态来源
  - 实操 19：手工走通一段训练脚本，包含正常回答、不会回答、偏题和提前结束；能说明反馈怎样服务学习目标

**学习资料与范围：**

| 资料与具体章节 | 本轮范围与深度 | 对应实操 |
| --- | --- | --- |
| [设计学习路线](design-learning.md) 第 2.3、2.4 节和第 3.2 节；[SQL 设计补充](sql-learning/design.md) 第 1～3 节 | 把用户流、状态矩阵和数据含义用于学习 Session；状态转移规则由当前需求给出 | 16、17、19 |
| Council of Europe：[Global scale — Table 1](https://www.coe.int/en/web/common-european-framework-reference-languages/table-1-cefr-3.3-common-reference-levels-global-scale)、[Self-assessment grid — Table 2](https://www.coe.int/en/web/common-european-framework-reference-languages/table-2-cefr-3.3-common-reference-levels-self-assessment-grid) | 识读 A1～C2；Table 2 选 English 中的 Listening、Reading、Spoken interaction、Spoken production、Writing，取目标水平对应描述设计任务 | 17、19 |
| [Anki Manual — Background](https://docs.ankiweb.net/background.html)、[Deck Options](https://docs.ankiweb.net/deck-options.html) | Background 读 Active Recall Testing、Spaced Repetition；Deck Options 读 FSRS、Desired Retention、FSRS Parameters，理解参数与复习负担的关系 | 18 |
| [SuperMemo 2: Algorithm](https://super-memory.com/english/ol/sm2.htm) | 识读评分、间隔更新与遗忘后的处理，用于比较思路；不要求同时实现 SM-2 与 FSRS | 18 |

---

## 阶段八：AI 文字训练 V1

先接通一次完整请求并验证质量，再按体验需要加入流式输出。下列 OpenAI 官方资料是具体学习示例；接入其他供应商时核对其能力、地区可用性、数据处理、价格与限制，不锁死模型或 SDK。

- [ ] **20. LLM API 与调用控制**
  - 指令、用户输入、上下文、Token、模型能力与参数支持范围；结构化输出与 Tool Calling 的适用区别
  - 服务端持有密钥，统一处理超时、取消、限流、重试、拒答和不完整响应
  - 上下文长度与输出上限、单用户额度、总预算和并发上限；记录调用状态与实际用量
  - 流式输出有开始、部分内容、完成、失败和取消；半段文字或 JSON 不直接作为最终业务结果
  - 实操 20：由 Go 调用模型并返回客户端，验证超时、限流、截断和取消；记录耗时与成本，上游不支持去重时明确重试可能再次计费

- [ ] **21. Prompt 与反馈策略**
  - 写清学习目标、输入边界、示例、难度、纠错时机与输出格式；Prompt 和模型配置可追溯
  - 区分指令和用户 / 内容数据；提示注入不能获得用户权限、改写付费权益或直接写入学习结果
  - 结构化输出仍需业务校验；格式正确不表示目标词使用、释义或评分正确
  - 实操 21：比较一组 Prompt 对同一输入的结果，覆盖不会回答、偏题和要求绕过规则；只保留有评测依据的改动

- [ ] **22. AI Evaluation**
  - 建立代表目标用户的固定样本与人工参考：不同水平、词义、错误类型、混合语言、边界和恶意输入
  - 分开评估任务完成、语言准确性、纠错质量、难度、自然度、安全、延迟与成本
  - 自动检查确定性规则；需要判断语义的结果结合人工复核，模型评分先与人工校准
  - 区分调试样本与留出的验收样本；更换模型、Prompt、内容或解析逻辑后回归
  - 实操 22：输出版本可追溯的对比结果与失败案例，按第 9 项的产品目标决定是否上线；不以一次满意回答或总分掩盖关键失败

**学习资料与范围：**

| 资料与具体章节 | 本轮范围与深度 | 对应实操 |
| --- | --- | --- |
| [Structured model outputs](https://developers.openai.com/api/docs/guides/structured-outputs) | 读概览、Function calling 与结构化回复的选择、How to use、Handle edge cases、Supported schemas；Go 侧按所用 SDK 或 HTTP 契约实现 | 20、21 |
| [Streaming API responses](https://developers.openai.com/api/docs/guides/streaming-responses) | 需要流式体验时读 Enable streaming、Read the responses、Moderation risk；先不学实时双向接口 | 20 |
| [Prompt engineering](https://developers.openai.com/api/docs/guides/prompt-engineering) | 读 Message roles and instruction following、Version prompts in code、Few-shot learning、Include relevant context information；结合实测应用 | 21 |
| [Evaluation best practices](https://developers.openai.com/api/docs/guides/evaluation-best-practices) | 读 Design your eval process、Create and combine different types of evaluators、Handle edge cases；实现最小离线回归即可，不要求部署评测平台 | 22 |

> 阶段验收：目标用户能完成一轮文字训练；失败能恢复，业务状态不由模型直接决定；质量、延迟和费用达到预先写明的首版标准。

---

## 阶段九：AI 语音 V2

需要语音才能验证核心假设时可提前做本阶段的小实验；完整交付仍依赖第 13 项音频能力与第 20～22 项调用和评测基础。

- [ ] **23. ASR 与语音输入**
  - 录音 → 有界上传 → 转写；校验格式、时长、大小、权限与关联的学习会话
  - 测试口音、噪声、静音、停顿、专有词和中英混合；关注任务成功率与词错误率
  - 转写文本允许用户确认或修改；识别错误不能直接归因于学习者，ASR 结果不等同于发音评分
  - 实操 23：用获得同意的测试录音评测，保存参考文本和错误类型；验证空音频、超限、超时、重复上传与删除

- [ ] **24. TTS 与语音输出**
  - 文本、声音、语速、格式与播放；用学习材料检查发音、数字、缩写和停顿
  - 缓存键包含文本、声音与影响输出的配置；公共内容与用户私有内容分开缓存
  - 合成失败保留文字，支持停止与重播；说明合成语音来源，确认服务使用条件
  - 实操 24：将同一反馈合成并播放，检查取消、重复播放、缓存命中与配置变更；能比较质量、延迟和成本

- [ ] **25. 轮次式语音链路**
  - 录音 → 上传 → ASR（可查看与纠正）→ LLM → TTS → 播放；每一步有状态、超时和可见反馈
  - 用一次交互标识关联各阶段；失败时重做必要步骤，防止旧音频或旧回复覆盖新一轮
  - 临时文件、音频存储与访问权限、保留期限和删除；需要长期保存时再引入受控对象存储
  - 实操 25：真机完成端到端训练，逐段模拟断网、超时、中断与 App 切换；语音失败能回到文字，重试不会重复保存作答

**资料与范围：** [File transcription](https://developers.openai.com/api/docs/guides/speech-to-text) 读 Quickstart、支持的输入 / 输出与 Prompting，流式转写暂缓，对应实操 23；[Text to speech](https://developers.openai.com/api/docs/guides/text-to-speech) 读 Quickstart、Voice options、Supported output formats 及使用要求，对应实操 24。实操 25 整合两者与第 13 项，后端行为回查第 14、20 项。

**暂缓：** 实时双向语音、VAD、Barge-in、回声消除、流式 ASR / TTS Pipeline。只有轮次式体验已验证、延迟或打断确实阻碍核心任务时，再选择方案并补学。

---

## 阶段十：安全、账号与隐私

这些能力在接触外部用户前补齐；参数化 SQL、服务端密钥和输入校验从第一个 API 开始执行。

- [ ] **26. Authentication 与账号生命周期**
  - 根据产品需要选择登录方式；理解 Sign in with Apple、身份提供方与自己的业务账号 / 会话之间的关系
  - 服务端验证身份凭据的签名、签发者、受众、有效期与相关防重放参数，不信任客户端传来的 user_id
  - 会话过期、刷新、撤销、退出、多设备与账号切换；体验流程可先于登录，业务需要时再关联账号
  - 提供创建、恢复访问和删除账号的完整路径；Sign in with Apple 的授权撤销按官方流程处理
  - 实操 26：验证首次登录、重新登录、过期、撤销和换号；伪造或过期凭据不能获取业务数据

- [ ] **27. Authorization 与数据归属**
  - 每次请求按已验证身份检查对象归属；列表、详情、修改、删除、文件和后台任务均覆盖
  - 区分普通用户、管理职责与付费权益；隐藏按钮和不可猜的 ID 不能代替授权
  - 最小权限、默认拒绝；后台管理入口和运行数据库账号各有边界
  - 实操 27：用两个账号互换资源 ID，检查列表、详情、写入和音频访问；越权请求既不返回数据也不产生副作用

- [ ] **28. 安全基础与数据生命周期**
  - HTTPS、输入与输出校验、SQL Injection、SSRF、文件大小 / 类型限制、限流和滥用成本；按实际攻击面理解 XSS / CSRF
  - 密钥存储与轮换、依赖和 SDK 检查、日志脱敏；采用密码登录时再补安全密码存储与账号防攻击设计
  - 列出录音、转写、对话、学习记录和分析事件的用途、接收方、保留期限与删除方式；仅收集必要数据
  - 个人数据发送给第三方 AI 前，按适用规则告知并取得所需许可；麦克风权限不等于同意所有后续数据用途
  - 账号删除覆盖关联数据、文件、凭据与相关处理方；明确备份保留和到期清除策略，避免恢复后重新激活已删除账号
  - 实操 28：画数据流并检查信任边界，验证超限请求、恶意输入和删除流程；检查日志和客户端包中无密钥或不必要的个人内容

**学习资料与范围：**

| 资料与具体章节 | 本轮范围与深度 | 对应实操 |
| --- | --- | --- |
| Apple：[Implementing User Authentication with Sign in with Apple](https://developer.apple.com/documentation/authenticationservices/implementing-user-authentication-with-sign-in-with-apple)、[Verifying a user](https://developer.apple.com/documentation/signinwithapple/verifying-a-user) | 前者读请求授权与凭据处理；后者读 Verify the identity token、Obtain a refresh token、Manage the user session，区分 Apple 凭据与业务会话 | 26 |
| [OWASP — Authorization Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html) | 读 Least Privilege、Deny by Default、Validate Permissions on Every Request；按对象归属实现和测试 | 27 |
| [OWASP — REST Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/REST_Security_Cheat_Sheet.html) | 读 HTTPS、Access Control、JWT、Input validation、Sensitive information in HTTP requests、Audit logs；其余按产品攻击面查阅 | 26～28 |
| Apple：[Offering account deletion](https://developer.apple.com/support/offering-account-deletion-in-your-app/)、[App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) | 删除指引读 Account deletion guidance 与相关 FAQ；审核指南核对 5.1.1、5.1.2，特别是账号、数据使用与第三方 AI。按首发市场和年龄范围另核实适用要求 | 28、30 |

---

## 阶段十一：Apple 商业化与发布

TestFlight 与设备 QA 在试用前完成；StoreKit 在收费前完成。发布政策、SDK 要求和地区规则随提交版本核对。

- [ ] **29. StoreKit 2 与付费权益**
  - Product、Purchase、Restore、Transaction、Subscription Status；购买成功、待处理、取消与验证失败
  - 服务端校验与用户绑定；权益按可信交易 / 订阅状态决定，客户端不能自行授予 AI 使用额度
  - 续订、到期、退款、撤销、宽限期；通知可能重复、延迟或乱序，需要幂等处理与主动核对
  - 价格、周期、试用、续订与管理订阅入口清楚；删除账号与取消订阅的后果分别说明
  - 实操 29：先在 StoreKit 测试环境，再在沙盒验证购买、恢复、到期、退款和重复通知；Go 端额度与实际权益一致

- [ ] **30. Apple 发布与运营准备**
  - Bundle ID、Signing、Provisioning、最低系统版本、构建号、App Store Connect、TestFlight 与审核材料
  - 隐私政策、App Privacy Details、适用的 Privacy Manifest 与 SDK 声明；这些材料各有用途，需要与实际数据行为一致
  - 支持邮箱 / 反馈入口、账号删除、内容使用权、年龄分级、首发市场；准备商店文案、截图与审核可用账号或演示方式
  - 后端可访问、旧版本兼容、崩溃定位、版本发布与问题处置；不能假设用户会立即更新
  - 实操 30：安装一次 TestFlight 构建并走核心流程，核对发布材料和数据行为；正式发布前完成文末发布门槛

- [ ] **31. iPhone + iPad QA**
  - 代表性的系统版本与尺寸、大字体、深浅色、VoiceOver、横屏、iPad 窗口变化与键盘
  - 弱网 / 断网、重复点击、退出与重启、账号切换；有语音时加麦克风拒绝、蓝牙和系统中断
  - 首次使用、已有数据升级、缓存迁移；有收费时加购买与恢复，有离线能力时加冲突与补同步
  - 实操 31：按用户任务建立检查矩阵，记录可复现步骤和结果；核心路径及数据风险验证通过，已知限制有明确处理

**学习资料与范围：**

| 资料与具体章节 | 本轮范围与深度 | 对应实操 |
| --- | --- | --- |
| [Apple In-App Purchase](https://developer.apple.com/documentation/storekit/in-app-purchase)、[App Store Server Notifications](https://developer.apple.com/documentation/appstoreservernotifications) | StoreKit 读 Product、Purchase requests and results、Transaction history and entitlements、Subscription status、Testing；通知读 Process in-app purchase notifications、Test your server setup | 29 |
| [Develop in Swift](https://developer.apple.com/tutorials/develop-in-swift/) 的 App distribution | 跟做 Preparation for distribution、Testing and feedback、Review and distribution；费用与账号条件按当前账户核对 | 30 |
| [App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)、[Privacy manifest files](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files) | 阅读数据类型、用途和关联 / 跟踪判定；Manifest 阅读创建与适用 API / SDK 声明要求 | 28、30 |
| [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) | 提交前读 Before You Submit，并重点核对 2.1、3.1、4.8、5.1、5.2；具体登录、支付和市场例外按适用条件确认 | 29、30 |
| [设计学习路线](design-learning.md) 第 3、8 节与第 6 项 HIG 资料 | 用状态矩阵、跨端检查和无障碍标准评审真实可交互版本 | 31 |

---

## 阶段十二：工程、运行与稳定性

第 32 项从首个功能开始，第 33～36 项在外部试用前做到最小可用；性能优化以测量结果为依据。

- [ ] **32. Testing**
  - 单元测试覆盖业务规则与状态转换；API / 集成测试覆盖认证、事务、约束、分页和兼容性
  - Swift Testing 适合逻辑测试，UI 流程使用 XCTest / XCUIAutomation；Go 使用 testing / httptest 与真实测试库
  - 对时钟、网络和 AI 做可控替代；数据库关键行为用真实 PostgreSQL 验证，AI 质量回归使用第 22 项
  - 实操 32：覆盖一条正常路径及会改变用户结果的失败路径；重现一个缺陷，修复后防止回归。测试应验证行为，不追求无意义的覆盖率或重复实现

- [ ] **33. Observability 与费用监控**
  - 结构化日志、Request ID、错误 / 崩溃定位；区分业务分析事件、诊断日志和审计记录
  - API / SQL / AI 分段延迟、错误率、并发与连接池；关注分位延迟和失败分布
  - 模型 / Prompt 版本、Token / 音频用量、每次有效练习成本、预算上限与告警；默认不完整记录私人对话和录音
  - 实操 33：从一次客户端报错追到服务和依赖；识别慢在何处、花费多少，并验证预算或错误告警可以触发

- [ ] **34. 性能与容量**
  - 先观察启动、页面卡顿、内存、音频文件、API 延迟、慢 SQL、N+1 与连接饱和
  - 设定符合首批用户规模的并发、请求大小、数据库连接和 AI 调用预算；区分局部慢与上游限流
  - 缓存、索引、批量查询与并发控制按瓶颈选择；用相同条件比较前后效果
  - 实操 34：定位一个真实瓶颈，记录前后数据和资源代价；若无瓶颈则保留基线，不为了学习而优化

- [ ] **35. Docker / Linux 与服务运行**
  - 复用 OrbStack：镜像、Dockerfile、Compose、配置、网络、端口、Volume；理解容器生命周期与持久数据
  - Linux 进程、权限、日志、磁盘、信号、健康检查、重启与优雅退出；区分 localhost、容器地址和真机访问地址
  - 选择能维护的单一部署方式，理解域名 / DNS、HTTPS、运行账号、备份责任与费用；用到音频存储时补访问权限与生命周期
  - 实操 35：在隔离环境启动 Go + PostgreSQL，用实际请求证明可用；重启验证持久数据，再将备份恢复到另一测试库并核对数据

- [ ] **36. CI/CD 与可恢复发布**
  - 自动运行相关测试、检查和构建；Go 后端与需要 macOS / Xcode 的客户端构建分开安排
  - 依赖与产物可追溯，密钥由环境提供，部署权限最小化；先有稳定手动发布流程，再自动化必要步骤
  - 兼容迁移、上线顺序、健康检查、旧客户端兼容、回滚 / 向前修复；回滚应用不等于撤销数据库变化
  - 实操 36：在测试环境完成一次发布、一次兼容迁移及一次失败恢复，验证旧客户端和数据仍正常；服务异常时有明确处理入口

**学习资料与范围：**

| 资料与具体章节 | 本轮范围与深度 | 对应实操 |
| --- | --- | --- |
| [Go — Add a test](https://go.dev/doc/tutorial/add-a-test)、[httptest](https://pkg.go.dev/net/http/httptest)；[Swift Testing](https://developer.apple.com/documentation/testing)、[XCTest](https://developer.apple.com/documentation/xctest) | Go 跟做测试并查 NewRecorder / NewServer 示例；Swift 读 Defining test functions、Expectations、Parameterized tests；XCTest 查 UI tests | 32 |
| [OpenTelemetry — Signals](https://opentelemetry.io/docs/concepts/signals/) | 识读 Logs、Metrics、Traces 的职责，再选择当前需要的观测点；首版无需部署全套遥测平台 | 33 |
| [Go — Diagnostics](https://go.dev/doc/diagnostics)、[SQL 导读](sql-learning/README.md) 第 5 单元 | Diagnostics 读 Profiling 与 Tracing 的用途；SQL 看 EXPLAIN 与索引。客户端用 Xcode Instruments 检查当前瓶颈 | 34 |
| [Docker — What is a container?](https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-a-container/)、[How Compose works](https://docs.docker.com/compose/intro/compose-application-model/) | 前者读 Explanation；后者读 The Compose file、CLI、Illustrative example；复用既有工具，不再安装 Docker Desktop | 35 |
| [GitHub Actions — Quickstart](https://docs.github.com/en/actions/get-started/quickstart)、[SQL 导读](sql-learning/README.md) 第 7 单元 | 跟做一个检查工作流，理解触发、Job、Step、Runner；迁移与恢复按真实部署方式演练 | 36 |

---

## 阶段十三：架构判断与按需演进

第 37～38 项贯穿开发；第 41 项的超时、重试和幂等在调用远端服务时就需要理解。第 39～40 项的额外基础设施按触发条件引入。

- [ ] **37. 模块与系统边界**
  - 客户端负责呈现与交互，服务端负责授权、业务规则和权威数据；AI 提供候选内容与评价，业务代码负责校验和状态变化
  - 按当前变化与测试需求划分模块；在一个服务内先把职责讲清，不为预想规模拆微服务
  - 实操 37：画核心请求的数据流与信任边界，说明每条关键规则由谁保证；更换模型或页面不应迫使无关业务重写

- [ ] **38. Failure-first 思维**
  - 区分未执行、执行中、已成功但响应丢失、部分成功；超时不等于失败已回滚
  - DB / AI / ASR / TTS 失败、断网、重复提交、App 退出和支付通知异常；明确重试、补偿、降级与用户可见结果
  - 实操 38：为核心流程列出失败位置与恢复动作，实际模拟会影响数据或收费的情况；恢复后计数、权益和页面状态仍一致

- [ ] **39. 异步任务：需要时再引入**
  - 触发条件：任务需要跨请求继续、耗时无法接受、可靠批处理或明确的后台重试需求；进程内 goroutine 不等于持久任务
  - Job / Worker、持久状态、领取与租约、重试上限、失败队列 / 人工处理、幂等与去重
  - 数据写入与任务投递的一致性；先评估 PostgreSQL 任务表是否足够，独立消息系统按规模与保证要求选择
  - 实操 39：触发后让 Worker 在处理中退出并重新启动，验证任务可恢复且业务副作用不会重复；未触发时能说明同步方案的限制即可

- [ ] **40. Redis：有证据再加入**
  - 触发条件：测量表明确有高频缓存、跨实例限流等需求，且 PostgreSQL / 进程内方案不合适
  - Cache、TTL、失效、淘汰、命中率与缓存击穿；缓存中存什么、多久过期、故障时如何处理
  - 缓存不是学习记录或付费权益的唯一事实来源；分布式锁的有效期和失效语义按需深入
  - 实操 40：触发后比较前后延迟与数据库负载，模拟旧缓存和 Redis 不可用，验证数据正确性与明确的降级策略

- [ ] **41. 远端调用与分布式基础**
  - 当前必懂：Deadline、有限重试、指数退避与随机抖动、幂等；一次业务操作经过多层重试可能放大调用和费用
  - 按需深入：最终一致性、补偿、熔断、消息交付语义；支付和后台任务中的“最终完成”需要核对与修复机制
  - 实操 41：模拟下游先成功后断连、持续失败和限流，确认请求总预算、重试行为与数据结果；不能靠无限重试恢复

**学习资料与范围：**

| 资料与具体章节 | 阅读条件与范围 | 对应实操 |
| --- | --- | --- |
| [SQL 设计补充](sql-learning/design.md) 第 3 节评审清单、第 5 节反例 | 在首个学习闭环中应用边界、失败与恢复的检查 | 37、38 |
| [AWS — Timeouts, retries, and backoff with jitter](https://aws.amazon.com/builders-library/timeouts-retries-and-backoff-with-jitter/) | 调用远端服务时读 Timeouts、Retries and backoff、Jitter，理解原则；不要求使用 AWS | 38、41 |
| [RabbitMQ — Reliability Guide](https://www.rabbitmq.com/docs/reliability) | 触发异步任务需求后，读 What Can Fail?、Acknowledgements and Confirms 及生产者 / 消费者的数据安全部分，理解确认、重投与去重；这里只借鉴机制，不要求引入 RabbitMQ | 39 |
| [Redis — Keys and values](https://redis.io/docs/latest/develop/using-commands/keyspace/)、[Key eviction](https://redis.io/docs/latest/develop/reference/eviction/) | 触发缓存需求后，前者读 Key expiration，后者读内存限制与淘汰策略；测试所选策略的失败行为 | 40 |

---

## 阶段十四：持续产品验证

承接第 9 项。定义指标与事件在试用前完成，收集证据从首个可用版本开始，随产品迭代持续进行。

- [ ] **42. MVP 指标与决策**
  - 激活：从首次进入到完成一次有价值的学习；同时观察耗时、失败和放弃位置
  - 留存：D1 / D7 / D30 或符合学习频率的回访指标，明确起始事件、返回行为、时区、观察窗口与分母；未满观察期的用户不混入成熟分组
  - 学习效果：延迟回忆、减少提示、在新语境中使用等与目标匹配的证据；使用时长、连续签到和 AI 分数不直接代表学会
  - 商业与运行：付费转化、续订 / 退款、获客成本、每次有效练习及每用户成本，结合免费用户与高频用户估算可持续性
  - 实操 42：为当前假设选少量主指标和护栏指标，写明公式与决策条件；用真实样本说明继续、调整或停止的依据

- [ ] **43. 埋点、漏斗与分组分析**
  - Event、属性、身份、会话、渠道、版本；区分客户端交互、服务端成功与业务事实
  - 定义触发时机与去重标识，处理重试、迟到、时区和测试账号；不要把“点了完成”直接当成事务已提交
  - Funnel、Retention、Cohort、Conversion；按进入时间、版本、渠道与目标人群比较，避免总平均值掩盖差异
  - SQL / 表格先能回答问题即可；不把新增分析平台、全量录屏或收集原始对话当作默认前提
  - 实操 43：从一条测试用户路径逐事件核对数据库与报表，验证重复和失败不误计数；用同一口径算出漏斗和留存

- [ ] **44. 用户反馈与产品迭代**
  - 观察实际任务，结合访谈理解开始、持续使用、流失、付费与不付费的原因
  - 区分用户提出的功能和背后的问题；按影响、证据强度、实现成本与风险取舍
  - 每次迭代写清假设、变化和观察结果；小样本先用行为与定性证据，不急于做无法解释的 A/B 测试
  - 实操 44：用一次完整反馈循环修订产品范围，复测同类任务；记录哪些假设被支持、否定或仍不确定

**学习资料与范围：**

| 资料与具体章节 | 本轮范围与深度 | 对应实操 |
| --- | --- | --- |
| Amplitude：[Build a funnel analysis](https://amplitude.com/docs/analytics/charts/funnel-analysis/funnel-analysis-build)、[Build a retention analysis](https://amplitude.com/docs/analytics/charts/retention-analysis/retention-analysis-build) | 读事件选择、转化窗口、起始 / 返回事件与分组口径；学习概念，用 SQL 或现有工具复现，不要求注册平台 | 42、43 |
| Amplitude：[Create a tracking plan](https://amplitude.com/docs/data/create-tracking-plan) | 读开头、Create a source、Create an event、Create an event property，应用到最小事件表 | 43 |
| 第 9 项 YC 用户访谈资料；[设计学习路线](design-learning.md) 第 2.10 节 | 回看真实经历与可用性测试方法，结合业务数据复测 | 44 |

**是否值得扩大投入：** 预先定义的人群和场景中，用户反复获得价值，学习效果有与目标匹配的证据，付费与成本假设得到支持，且运行问题可控，再扩大功能或平台。指标阈值按产品与样本设定，不套一个通用“成功率”；证据不足时继续验证或收缩范围。

---

# 有明确需求后再扩展

以下内容不与首版争夺注意力。需要少量分析或评测脚本时可以提前使用 Python，无需先完整学完 Python，也无需把业务后端迁移过去。

## 阶段十五：Python 与分析能力

- [ ] **45. Python 基础**
  - 类型、集合、函数、模块、异常、文件 / JSON、typing；虚拟环境与依赖管理，uv 按项目需要使用
  - async 在并发 I/O 场景中再学，不默认把脚本改成异步服务
  - 实操 45：读入脱敏的学习或评测数据，处理坏数据并输出可重复的结果

- [ ] **46. AI / Data Python**
  - 优先用 SQL 或标准库解决；数据整理、分组统计和图表需要时学习 Pandas，数值计算需要时学习 NumPy
  - ETL、缺失值、重复、时间、抽样、数据泄漏与可复现评测；NLP / 音频处理按具体问题展开
  - 实操 46：复现第 42～43 项的一项分析或第 22 项的评测，对照原始样本核实统计口径

- [ ] **47. 独立 Python AI Service：满足条件再拆**
  - 触发条件：依赖 Python 专有能力、独立资源需求或部署边界，且收益足以覆盖双服务维护成本
  - FastAPI / Worker、输入输出契约、超时、认证、资源限制、版本、监控与独立部署
  - Embedding / RAG 只在外部知识检索确有价值时引入；先定义数据来源、检索评测与权限，不把它们当作所有 AI 产品的标配
  - 实操 47：触发后用一个小任务验证边界和失败恢复；未触发时保留 Go 调用供应商 API 或离线脚本的简单方案

**学习资料与范围：**

| 资料与具体章节 | 阅读条件与范围 | 对应实操 |
| --- | --- | --- |
| [Python Tutorial](https://docs.python.org/3/tutorial/index.html) | 需要脚本时读第 3～8 章常用例子和第 12 章 Virtual Environments and Packages；其他语法按缺口回查 | 45 |
| [Pandas Getting started tutorials](https://pandas.pydata.org/docs/getting_started/intro_tutorials/index.html) | 需要表格分析时选 How do I read and write tabular data?、How do I select a subset of a DataFrame?、How to calculate summary statistics、How to combine data from multiple tables；跟例子并应用到脱敏数据 | 46 |
| [FastAPI — First Steps](https://fastapi.tiangolo.com/tutorial/first-steps/)、[Deployments Concepts](https://fastapi.tiangolo.com/deployment/concepts/) | 触发独立服务需求后跟做最小接口；部署读 HTTPS、Running on Startup、Restarts、Replication — Processes and Memory；具体模型工具按所选依赖补齐 | 47 |

---

## 阶段十六：Android 与跨平台评估

触发条件：用户证据表明 Android 值得做，并且已有能力持续维护两个客户端；不因技术清单里出现它就开第二条产品线。

- [ ] **48. Android / Kotlin 基础**
  - Kotlin 类型、空安全、集合、类、错误与协程；Android 生命周期、权限和开发工具
  - 实操 48：读取现有 Go API，完成一个小页面，解释生命周期与请求取消

- [ ] **49. Jetpack Compose**
  - 状态、重组、状态提升、导航、ViewModel 与自适应布局；复用产品行为和 API 契约
  - 实操 49：复现已经验证的核心学习流程，覆盖返回、旋转、进程恢复、长文案和无障碍

- [ ] **50. Android Audio**
  - 录音与播放、权限、音频焦点、路由、生命周期和前后台限制
  - 实操 50：在真机复现第 25 项语音链路及中断测试，补齐 Android 差异

- [ ] **51. Google / 国内 Android 发布**
  - 按目标市场选择商店，核对签名、打包、测试分发、隐私、支付、数据披露和审核；不假设不同商店规则一致
  - 实操 51：在选定渠道发布测试版本，验证安装、升级、数据迁移及适用的支付流程

- [ ] **52. 再评估 KMP**
  - 比较 SwiftUI + Compose 各自维护，与共享稳定业务 / 网络 / 数据逻辑的收益和成本
  - 考虑团队熟悉度、平台差异、库支持、构建与排错；共享 UI 是另一个选择，不和共享业务逻辑自动绑定
  - 实操 52：仅在确有重复维护问题时做小范围验证，用实际复用和维护成本决定是否采用

**学习资料与范围：**

| 资料与具体章节 | 阅读条件与范围 | 对应实操 |
| --- | --- | --- |
| [Android Basics with Compose](https://developer.android.com/courses/android-basics-compose/course) | 确定做 Android 后选 Unit 1 Your first Android app、Unit 2 Building app UI、Unit 4 Navigation and app architecture、Unit 5 Connect to the internet；按缺口跟做，列表与 Material 基础需要时补 Unit 3 | 48、49 |
| [MediaRecorder overview](https://developer.android.com/media/platform/mediarecorder) | 做 Android 语音时读权限、创建 / 配置 / 停止录音与示例；播放和音频焦点按所选播放器补齐 | 50 |
| [Publish your app](https://developer.android.com/studio/publish) | 确定发布渠道后读 Prepare your app for release、Release your app to users；具体商店要求核对其官方规则 | 51 |
| [What is Kotlin Multiplatform](https://kotlinlang.org/docs/multiplatform/kmp-overview.html) | 存在重复维护问题时读概览、Flexibility of code sharing、Native feel on iOS；判断共享边界后再做小范围验证 | 52 |

---

<a id="learning-order"></a>

# 最终学习顺序

### 第一批：开工所需的最小能力

```text
实操 0：能运行、排错并安全管理代码
↓
1～3：数据库、数据设计与 HTTP
↓
4～6：Swift / SwiftUI 页面、状态与基本适配
↓
7～8：Go + PostgreSQL API；借第 11 项完成最小客户端联调
↓
9：明确人群、价值、首版范围和验证计划（可与上述技术学习并行）
↓
通过开工验收，立即进入产品开发
```

### 产品开发：按交付结果补学

| 里程碑 | 此时使用的主题 | 出口证据 |
| --- | --- | --- |
| M1：本地学习闭环 | 10～12、14～18，穿插 32、37～38 | 页面 → API → 数据库跑通一次学习 / 复习；正常、重复、失败和恢复行为可解释、有测试 |
| M2：AI 文字训练 | 19～22，并应用 28、33、41 的安全、预算与调用基础 | 真实完成训练；固定样本评测、成本和延迟达标，超时 / 取消有恢复路径 |
| M3：首批用户试用 | 必要的 26～28、30～36、42～44 | TestFlight 真机可用；身份和数据隔离通过测试；运行、恢复、隐私、反馈与指标已具备 |
| M4：收费与正式发布 | 收费时完成 29，继续 30～36、42～44 | 收费时沙盒权益流程通过；发布材料与产品一致，能支持用户、定位故障和验证商业假设 |

M3 可以在 M1 后开始，只要基础学习流程已经足以验证当前假设；若核心价值依赖 AI，则先完成 M2。免费发布不要求先实现第 29 项收费功能。

**语音分支：** 产品证据需要语音时，补第 13、23～25 项并重新通过相应 QA、隐私和成本检查；不把所有语音能力作为文字版发布条件。

**按需深化：** 第 39～41 项的进阶部分、离线双向同步、复杂 SQL 和性能优化根据真实问题展开；第 45～52 项按分析、独立服务与新平台需求触发。

### 对外试用与正式发布的检查

- **试用前**：核心流程可用，服务有实际请求与日志证据；跨用户访问被阻止；AI 调用受预算控制；必要数据告知、同意与账号删除流程可用。
- **运行保障**：备份已恢复到隔离环境并核对；迁移与旧客户端兼容；知道故障时如何降级、停用问题功能、回滚或向前修复。
- **体验与验证**：目标设备和无障碍基础检查通过；反馈入口可达，关键事件与业务事实核对一致，预先定义了要验证的假设和指标。
- **收费前**：购买、恢复、续订 / 到期、退款 / 撤销和通知异常通过沙盒验证；权益在服务端生效，免费和付费边界与成本假设一致。
- **提交审核前**：签名与构建、商店材料、内容使用权、隐私声明、SDK / 数据行为、审核访问条件和首发地区要求已按实际版本核对。

---

<a id="capabilities"></a>

## 你真正需要掌握到什么程度

| 能力 | 目标深度 | 能拿出的证据 |
| --- | --- | --- |
| 产品、市场与 UX | 应用与评审 | 有来源的需求判断、能完成任务的原型、明确的 MVP 取舍与验证计划 |
| 数据模型、事务、并发和 API | 应用与评审 | 能解释约束与边界，用重复、失败、跨用户和迁移案例验证 |
| SwiftUI 状态与 Swift / Go 并发 | 理解并能定位问题 | 能说明状态归属、取消与生命周期，识别竞争和重复副作用 |
| AI / 音频应用能力 | 能实现、测量和评审 | 可恢复的调用链、可信评测、真机音频证据与费用边界 |
| 安全、隐私、权益与发布 | 能实现并验证关键路径 | 身份与授权测试、数据生命周期说明、沙盒交易、发布与恢复演练 |
| 产品指标与学习效果 | 应用与评审 | 指标口径一致，能分清使用、学习与付费证据，并据此迭代 |
| SQL / Swift / Go 语法与低频 API | 识读、查阅、修改 | 能解释自己采用的实现；不要求默写或记住全部语法 |
| Python、Android、Redis、独立任务系统等扩展 | 先判断是否需要，触发后再学 | 有明确问题、可比较的收益与维护成本 |

核心原则：

> **AI 可以承担大量实现，你负责确定用户价值、规则与边界，检查真实运行结果，并用证据决定继续、修改还是停止。**
