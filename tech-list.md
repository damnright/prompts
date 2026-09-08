## 阶段一：数据库与网络基础

- [ ] **1. SQL 基础（三天）**
  - SELECT / INSERT / UPDATE / DELETE
  - JOIN
  - GROUP BY
  - 子查询
  - 窗口函数基础
  - 学习安排：[SQL 三天从零教程：概念、建库、连接与逐节实操](sql-learning/README.md)
  - 本地工具：复用 OrbStack + TablePlus，运行独立的 PostgreSQL 学习数据库
  - 每天约 4 小时，通过英语 App 数据练习完成查询、增删改、多表统计和窗口函数
  - 验收：24 道练习通过结果检查；独立完成学习概览查询，并解释 NULL、JOIN 重复行和统计口径
  - 三天完成 SQL 入门；索引、锁、隔离级别、性能调优等继续在第 2 项 PostgreSQL 中学习

- [ ] **2. PostgreSQL**
  - 表设计
  - Primary Key / Foreign Key
  - Unique
  - Index
  - Transaction
  - Lock
  - Isolation Level
  - EXPLAIN / EXPLAIN ANALYZE
  - JSONB
  - Migration
  - Connection Pool

- [ ] **3. HTTP / API 基础**
  - HTTP / HTTPS
  - REST
  - Status Code
  - Header / Cookie
  - CORS
  - SSE
  - WebSocket
  - 文件上传
  - Streaming

---

## 阶段二：Swift / SwiftUI

- [ ] **4. Swift 基础**
  - 类型系统
  - Optional
  - struct / class
  - protocol
  - enum
  - closure
  - error handling
  - async / await
  - Task
  - actor / MainActor 基础

> 目标：能看懂、修改、Review AI 写的 Swift，不需要追求手写熟练度。

- [ ] **5. SwiftUI 基础**
  - View
  - State
  - Binding
  - Observable
  - Environment
  - NavigationStack
  - NavigationSplitView
  - List / ScrollView
  - Sheet / Alert
  - 生命周期

- [ ] **6. SwiftUI 响应式布局**
  - iPhone / iPad 布局差异
  - 横竖屏
  - Split View
  - Size Class
  - Geometry / Layout
  - iPad 多栏布局
  - Mac 布局基础

---

## 阶段三：Go 后端入门

产品开发前完成 Go 基础和最小 API 实作。后续产品业务后端统一使用 **Go + PostgreSQL**；iOS / iPadOS 客户端继续使用 Swift / SwiftUI。

- [ ] **7. Go 基础**
  - 类型、变量、控制流、函数与多返回值
  - struct / method / interface
  - slice / map / pointer
  - error / errors.Is / errors.As
  - defer / 资源释放
  - package / Go Modules
  - context / 超时 / 取消
  - goroutine / channel / 同步基础
  - gofmt / go test / go vet

> 目标：能读、改、Review AI 写的 Go；能解释错误传播、资源释放和请求取消，不要求先深入复杂并发。

- [ ] **8. Go HTTP / PostgreSQL 实作**
  - net/http / Router / Handler / Middleware
  - JSON 编解码 / 请求校验
  - Status Code / 统一错误响应
  - Config / 环境变量 / slog
  - pgx / pgxpool / 参数化 SQL
  - PostgreSQL CRUD / Transaction
  - 请求 context 传递 / 查询超时
  - Handler / Service / Repository 的职责
  - httptest / 数据库集成测试

先用标准库 net/http 和 pgx 完成练习，理解从 HTTP 请求到 SQL 的完整调用链。

**进入产品开发的验收：**

- 独立运行一个 Go + PostgreSQL 单词 API，支持列表、新建、修改、删除和分页。
- 使用参数化 SQL，能正确处理非法输入、记录不存在、唯一约束冲突和数据库超时。
- 用一次事务完成关联写入，并验证失败时回滚。
- 跑通 HTTP 测试和数据库集成测试；能逐层解释 AI 生成的实现。

学习资料：[Go Tour](https://go.dev/tour/)、[Go 数据库访问](https://go.dev/doc/database/)、[net/http](https://pkg.go.dev/net/http)、[pgx](https://pkg.go.dev/github.com/jackc/pgx/v5)。

---

## ★ 完成 1～8 后正式开始产品开发

不要继续纯学习。

从这里开始：

> **产品开发 70% + 针对性学习 30%。**

> 产品业务后端统一使用 Go，数据库使用 PostgreSQL；后续 Python 用于分析、评测及确有需要的独立 AI 服务。

---

## 阶段四：iOS 工程能力

- [ ] **9. SwiftUI 项目架构**
  - Feature 模块化
  - View / ViewModel
  - Service
  - Repository
  - Dependency Injection
  - 状态与业务逻辑分离

- [ ] **10. iOS 网络层**
  - URLSession
  - Codable
  - async / await
  - API Client
  - Error Handling
  - Token / Authentication
  - SSE Streaming

- [ ] **11. 本地数据**
  - UserDefaults
  - Keychain
  - SwiftData
  - 本地缓存
  - Offline 基础
  - 数据同步思路

- [ ] **12. AVFoundation / 音频**
  - 麦克风权限
  - Audio Recording
  - Audio Playback
  - AVAudioSession
  - 耳机 / 蓝牙
  - 系统中断
  - 前后台切换
  - 音频格式基础

> 这是英语 App 最值得你亲自理解的 iOS 能力之一。

---

## 阶段五：API 设计与数据建模

在产品开发中继续深化 Go 后端的 API 设计和数据建模。

- [ ] **13. API 设计**
  - REST Resource
  - Pagination
  - Filtering
  - Error Schema
  - API Version
  - Idempotency
  - Rate Limit
  - Authentication / Authorization

- [ ] **14. 数据建模**
  - User
  - Word
  - WordGroup
  - Lesson
  - LearningSession
  - Conversation
  - Message
  - AI Run
  - Usage Record
  - Subscription
  - 学习进度

---

## 阶段六：英语学习核心业务架构

- [ ] **15. 状态机**
  - 学习 Session 状态
  - 单词掌握状态
  - AI 对话状态
  - 任务状态
  - 支付状态

- [ ] **16. 学习数据模型**
  - 学过
  - 见过
  - 正确使用
  - 错误使用
  - 发音评分
  - 熟练度
  - 遗忘
  - Review Schedule

- [ ] **17. 间隔重复基础**
  - Spaced Repetition
  - Forgetting Curve
  - SM-2 基本思想
  - FSRS 基本思想
  - 不必一开始自己发明算法

- [ ] **18. AI 训练会话设计**
  - Target Words
  - Completed Words
  - Weak Words
  - Context
  - Scenario
  - Prompt
  - Session Memory
  - Evaluation

---

## 阶段七：AI 对话 V1

- [ ] **19. LLM API**
  - System / User / Assistant
  - Structured Output
  - Tool Calling
  - Streaming
  - Context Management
  - Token
  - Temperature 等基础参数

- [ ] **20. Prompt Engineering**
  - 目标单词约束
  - 自然引导
  - 不机械塞词
  - 纠错策略
  - 用户水平控制
  - CEFR 等级
  - 对话场景控制

- [ ] **21. AI Evaluation**
  - 是否覆盖目标词
  - 是否正确使用
  - 是否自然
  - 语法质量
  - 对话难度
  - Hallucination
  - 固定测试集

---

## 阶段八：AI 语音 V2

- [ ] **22. ASR**
  - Audio → Text
  - 音频格式
  - 上传
  - 超时
  - 错误处理
  - 英语识别效果评测

- [ ] **23. TTS**
  - Text → Speech
  - Voice
  - Accent
  - Speed
  - Streaming / 非 Streaming
  - 音频缓存

- [ ] **24. V2 语音链路**
  - 开始录音
  - 停止录音
  - 上传
  - ASR
  - LLM
  - TTS
  - 播放
  - 中断 / Retry
  - Loading UX

> 第一版做到“轮次式语音”即可。

暂时不学习：

- 实时双向语音
- VAD
- Barge-in
- Echo Cancellation
- Streaming ASR
- Streaming TTS Pipeline

等产品验证后再做。

---

## 阶段九：安全与账号

- [ ] **25. Authentication**
  - Session / Token
  - Sign in with Apple
  - Refresh Token
  - Device 登录

- [ ] **26. Authorization**
  - 用户只能访问自己的数据
  - 管理员权限
  - Resource Ownership

- [ ] **27. 安全基础**
  - SQL Injection
  - XSS
  - CSRF
  - SSRF
  - Secret Management
  - Password Hash
  - Rate Limit
  - 文件上传安全
  - API Key 不放客户端

---

## 阶段十：Apple 商业化

- [ ] **28. StoreKit 2**
  - Product
  - Subscription
  - Purchase
  - Restore
  - Transaction
  - Subscription Status
  - Server Verification 基础

- [ ] **29. Apple 发布**
  - Bundle ID
  - Signing
  - Provisioning
  - TestFlight
  - App Store Connect
  - Privacy Manifest
  - App Review
  - Crash Log

- [ ] **30. iPhone + iPad QA**
  - 多尺寸
  - 横屏
  - iPad Split View
  - 键盘
  - 麦克风
  - 蓝牙耳机
  - 弱网
  - 前后台切换

---

## 阶段十一：工程与稳定性

- [ ] **31. Testing**
  - Unit Test
  - Integration Test
  - API Test
  - AI Evaluation Test
  - 核心学习流程测试

- [ ] **32. Observability**
  - Structured Logging
  - Request ID
  - Error Tracking
  - Crash Reporting
  - AI 调用日志
  - Token / Cost
  - Latency

- [ ] **33. 性能**
  - Slow SQL
  - Index
  - N+1
  - Memory
  - 图片 / 音频缓存
  - App 启动
  - API latency

- [ ] **34. Docker / Linux**
  - Dockerfile
  - Docker Compose
  - Environment
  - Volume
  - Network
  - Linux Process / Port / Log

- [ ] **35. CI/CD**
  - GitHub Actions
  - Test
  - Build
  - Migration
  - Deploy
  - Rollback

---

## 阶段十二：产品架构能力

- [ ] **36. 模块边界**
  - UI / Domain / Infrastructure
  - 客户端 / 服务端职责
  - AI / 业务职责

- [ ] **37. Failure-first 思维**
  - AI超时
  - ASR失败
  - TTS失败
  - DB失败
  - 网络中断
  - 重复提交
  - App退出
  - 支付回调异常

- [ ] **38. 异步系统**
  - Queue
  - Job
  - Worker
  - Retry
  - Dead Letter
  - Idempotency
  - Deduplication

> MVP 没有长任务时，先理解，不一定实现。

- [ ] **39. Redis**
  - Cache
  - TTL
  - Rate Limit
  - Session
  - Lock 基础

> PostgreSQL 能解决时不要急着加 Redis。

- [ ] **40. 分布式系统基础**
  - Timeout
  - Retry
  - Backoff
  - Circuit Breaker
  - Eventual Consistency
  - Idempotency

---

## 阶段十三：产品验证

- [ ] **41. MVP 指标**
  - 首次学习完成率
  - 单词组完成率
  - AI 对话启动率
  - AI 对话完成率
  - 语音使用率
  - D1
  - D7
  - D30
  - 付费转化
  - AI 成本 / 用户

- [ ] **42. 埋点与分析**
  - Event
  - Funnel
  - Retention
  - Cohort
  - Conversion
  - Feature Usage

- [ ] **43. 用户反馈**
  - TestFlight
  - 用户访谈
  - 学习过程观察
  - 流失原因
  - 付费原因
  - 不付费原因

---

# 产品验证成功后再学

## 阶段十四：Python

- [ ] **44. Python 基础**
  - typing
  - async
  - package
  - uv
  - exception

- [ ] **45. AI / Data Python**
  - Pandas
  - NumPy
  - 数据分析
  - ETL
  - NLP
  - 音频处理
  - 模型评测

- [ ] **46. 真正需要时再拆 Python AI Service**
  - FastAPI
  - Worker
  - Model Service
  - Embedding
  - RAG
  - ML

---

## 阶段十五：Android

iOS 产品验证后：

- [ ] **47. Android / Kotlin 基础**
- [ ] **48. Jetpack Compose**
- [ ] **49. Android Audio**
- [ ] **50. Google / 国内 Android 发布**
- [ ] **51. 再评估 KMP**

这时再决定：

```text
SwiftUI iOS
+
Compose Android
```

还是：

```text
SwiftUI
+
KMP共享业务逻辑
+
Compose Android
```

不要现在提前引入 KMP。

---

# 最终学习顺序

### 第一批：开始产品前

```text
1 SQL
↓
2 PostgreSQL
↓
3 HTTP/API
↓
4 Swift
↓
5 SwiftUI
↓
6 响应式布局
↓
7 Go 基础
↓
8 Go HTTP / PostgreSQL 实作
```

### ★ 到这里立即开始英语 App

然后产品需要什么，就按：

```text
9～14
Swift工程 + API设计 + 数据建模（Go后端）

↓

15～18
学习系统架构

↓

19～24
AI文字 + AI语音

↓

25～30
账号、安全、IAP、发布

↓

31～43
测试、架构、产品验证
```

### 产品确认成立后

```text
Python（分析 / 评测 / 必要的 AI 服务）
↓
Android
↓
KMP（再评估）
```

## 你现阶段真正需要深入掌握的

**优先深入：**

- PostgreSQL / SQL
- HTTP / API
- Go 后端工程：错误处理、context、事务、测试与资源生命周期
- 数据建模
- 系统架构
- SwiftUI运行机制
- Swift Concurrency
- AVFoundation
- AI应用架构
- 安全
- 产品指标

**只需要达到能读、能改、能 Review AI：**

- Swift语法细节
- 各种 SwiftUI API
- Go 语法细节与标准库 API（错误处理、context 等核心机制需要理解）
- Python语法
- Kotlin语法

核心原则还是：

> **AI 负责大量代码实现，你负责数据模型、架构、系统边界、失败场景、技术取舍和产品判断。**
