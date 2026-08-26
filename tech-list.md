## 阶段一：数据库与网络基础

- [ ] **1. SQL 基础**
  - SELECT / INSERT / UPDATE / DELETE
  - JOIN
  - GROUP BY
  - 子查询
  - 窗口函数基础

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

## ★ 完成 1～6 后正式开始产品开发

不要继续纯学习。

从这里开始：

> **产品开发 70% + 针对性学习 30%。**

---

## 阶段三：iOS 工程能力

- [ ] **7. SwiftUI 项目架构**
  - Feature 模块化
  - View / ViewModel
  - Service
  - Repository
  - Dependency Injection
  - 状态与业务逻辑分离

- [ ] **8. iOS 网络层**
  - URLSession
  - Codable
  - async / await
  - API Client
  - Error Handling
  - Token / Authentication
  - SSE Streaming

- [ ] **9. 本地数据**
  - UserDefaults
  - Keychain
  - SwiftData
  - 本地缓存
  - Offline 基础
  - 数据同步思路

- [ ] **10. AVFoundation / 音频**
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

## 阶段四：后端与 API

你已经熟 TypeScript，因此直接学习工程和架构部分。

- [ ] **11. TypeScript 后端**
  - Node.js
  - Fastify 或 NestJS
  - Router
  - Middleware
  - Validation
  - Error Handling
  - Config
  - Logging
  - PostgreSQL

- [ ] **12. API 设计**
  - REST Resource
  - Pagination
  - Filtering
  - Error Schema
  - API Version
  - Idempotency
  - Rate Limit
  - Authentication / Authorization

- [ ] **13. 数据建模**
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

## 阶段五：英语学习核心业务架构

- [ ] **14. 状态机**
  - 学习 Session 状态
  - 单词掌握状态
  - AI 对话状态
  - 任务状态
  - 支付状态

- [ ] **15. 学习数据模型**
  - 学过
  - 见过
  - 正确使用
  - 错误使用
  - 发音评分
  - 熟练度
  - 遗忘
  - Review Schedule

- [ ] **16. 间隔重复基础**
  - Spaced Repetition
  - Forgetting Curve
  - SM-2 基本思想
  - FSRS 基本思想
  - 不必一开始自己发明算法

- [ ] **17. AI 训练会话设计**
  - Target Words
  - Completed Words
  - Weak Words
  - Context
  - Scenario
  - Prompt
  - Session Memory
  - Evaluation

---

## 阶段六：AI 对话 V1

- [ ] **18. LLM API**
  - System / User / Assistant
  - Structured Output
  - Tool Calling
  - Streaming
  - Context Management
  - Token
  - Temperature 等基础参数

- [ ] **19. Prompt Engineering**
  - 目标单词约束
  - 自然引导
  - 不机械塞词
  - 纠错策略
  - 用户水平控制
  - CEFR 等级
  - 对话场景控制

- [ ] **20. AI Evaluation**
  - 是否覆盖目标词
  - 是否正确使用
  - 是否自然
  - 语法质量
  - 对话难度
  - Hallucination
  - 固定测试集

---

## 阶段七：AI 语音 V2

- [ ] **21. ASR**
  - Audio → Text
  - 音频格式
  - 上传
  - 超时
  - 错误处理
  - 英语识别效果评测

- [ ] **22. TTS**
  - Text → Speech
  - Voice
  - Accent
  - Speed
  - Streaming / 非 Streaming
  - 音频缓存

- [ ] **23. V2 语音链路**
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

## 阶段八：安全与账号

- [ ] **24. Authentication**
  - Session / Token
  - Sign in with Apple
  - Refresh Token
  - Device 登录

- [ ] **25. Authorization**
  - 用户只能访问自己的数据
  - 管理员权限
  - Resource Ownership

- [ ] **26. 安全基础**
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

## 阶段九：Apple 商业化

- [ ] **27. StoreKit 2**
  - Product
  - Subscription
  - Purchase
  - Restore
  - Transaction
  - Subscription Status
  - Server Verification 基础

- [ ] **28. Apple 发布**
  - Bundle ID
  - Signing
  - Provisioning
  - TestFlight
  - App Store Connect
  - Privacy Manifest
  - App Review
  - Crash Log

- [ ] **29. iPhone + iPad QA**
  - 多尺寸
  - 横屏
  - iPad Split View
  - 键盘
  - 麦克风
  - 蓝牙耳机
  - 弱网
  - 前后台切换

---

## 阶段十：工程与稳定性

- [ ] **30. Testing**
  - Unit Test
  - Integration Test
  - API Test
  - AI Evaluation Test
  - 核心学习流程测试

- [ ] **31. Observability**
  - Structured Logging
  - Request ID
  - Error Tracking
  - Crash Reporting
  - AI 调用日志
  - Token / Cost
  - Latency

- [ ] **32. 性能**
  - Slow SQL
  - Index
  - N+1
  - Memory
  - 图片 / 音频缓存
  - App 启动
  - API latency

- [ ] **33. Docker / Linux**
  - Dockerfile
  - Docker Compose
  - Environment
  - Volume
  - Network
  - Linux Process / Port / Log

- [ ] **34. CI/CD**
  - GitHub Actions
  - Test
  - Build
  - Migration
  - Deploy
  - Rollback

---

## 阶段十一：产品架构能力

- [ ] **35. 模块边界**
  - UI / Domain / Infrastructure
  - 客户端 / 服务端职责
  - AI / 业务职责

- [ ] **36. Failure-first 思维**
  - AI超时
  - ASR失败
  - TTS失败
  - DB失败
  - 网络中断
  - 重复提交
  - App退出
  - 支付回调异常

- [ ] **37. 异步系统**
  - Queue
  - Job
  - Worker
  - Retry
  - Dead Letter
  - Idempotency
  - Deduplication

> MVP 没有长任务时，先理解，不一定实现。

- [ ] **38. Redis**
  - Cache
  - TTL
  - Rate Limit
  - Session
  - Lock 基础

> PostgreSQL 能解决时不要急着加 Redis。

- [ ] **39. 分布式系统基础**
  - Timeout
  - Retry
  - Backoff
  - Circuit Breaker
  - Eventual Consistency
  - Idempotency

---

## 阶段十二：产品验证

- [ ] **40. MVP 指标**
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

- [ ] **41. 埋点与分析**
  - Event
  - Funnel
  - Retention
  - Cohort
  - Conversion
  - Feature Usage

- [ ] **42. 用户反馈**
  - TestFlight
  - 用户访谈
  - 学习过程观察
  - 流失原因
  - 付费原因
  - 不付费原因

---

# 产品验证成功后再学

## 阶段十三：Python

- [ ] **43. Python 基础**
  - typing
  - async
  - package
  - uv
  - exception

- [ ] **44. AI / Data Python**
  - Pandas
  - NumPy
  - 数据分析
  - ETL
  - NLP
  - 音频处理
  - 模型评测

- [ ] **45. 真正需要时再拆 Python AI Service**
  - FastAPI
  - Worker
  - Model Service
  - Embedding
  - RAG
  - ML

---

## 阶段十四：Java 后端

产品验证成功后，再系统学习 Java 后端：

- [ ] **46. Java 后端**
  - Java 核心语法
  - 集合 / 泛型
  - 异常处理
  - 并发基础
  - Maven
  - Spring Boot
  - Spring MVC
  - Bean Validation
  - Spring Security
  - JPA / MyBatis
  - PostgreSQL
  - Transaction
  - API Test

适合未来：

- 复杂业务后端
- 企业级权限与事务
- 管理后台与运营系统
- 定时任务与异步任务
- 与现有 Java 系统集成
- 大型团队长期维护

> 不要为了学习 Java 就在 MVP 阶段重写正常工作的 TypeScript 后端；优先用于产品验证成功后的新模块或明确需要升级的服务。

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
```

### ★ 到这里立即开始英语 App

然后产品需要什么，就按：

```text
7～13
Swift工程 + TS后端 + 数据建模

↓

14～17
学习系统架构

↓

18～23
AI文字 + AI语音

↓

24～29
账号、安全、IAP、发布

↓

30～42
测试、架构、产品验证
```

### 产品确认成立后

```text
Python
↓
Java 后端
↓
Android
↓
KMP（再评估）
```

## 你现阶段真正需要深入掌握的

**优先深入：**

- PostgreSQL / SQL
- HTTP / API
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
- Node框架API
- Python语法
- Java语法细节与 Spring API
- Kotlin语法

核心原则还是：

> **AI 负责大量代码实现，你负责数据模型、架构、系统边界、失败场景、技术取舍和产品判断。**
