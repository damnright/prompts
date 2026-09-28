# Go：从语言基础到 HTTP / PostgreSQL 联调

[技术路线：第 7～8 项](../tech-list.md) · [通用学习流程](../learning-flow.md) · [环境操作](environment.md) · [实操](practice.md) · [设计与评审](design.md)

第 7 项以 **A Tour of Go + 官方入门教程**为主；第 8 项按一个单词 API 的实现顺序读标准库、Go 数据库指南和 pgx 文档。采用 `net/http + pgx / pgxpool`，复用已有 PostgreSQL，不增加 Web 框架、ORM、Redis 或第二套数据库容器。

## 1. 学习要点与前置条件

完成 SQL 的查询、约束、修改与事务基础，以及 [HTTP H1～H5](../http-learning/README.md)。Go 语言可以先学，真实数据库实验前再补齐相应 SQL 单元。

- 类型、集合、方法与接口表达业务；error、defer、context 表达失败与资源责任。
- goroutine 不自动保证并发安全，也不等于可靠后台任务。
- HTTP 层、业务规则和 SQL 的职责要清楚，目录和 interface 数量不作为架构质量指标。
- 参数化查询、连接池、事务、结果集关闭与错误检查共同决定数据库访问是否正确。
- 单元测试、HTTP 测试和真实数据库测试覆盖不同边界；实际监听与请求结果才证明服务启动。

## 2. 阅读单元与对应实操

G1～G3 对应实操 7；G4～G7 对应实操 8。包文档只读表中点名的函数与例子，不通读全部标准库。

| 单元 | 资料与具体阅读范围 | 深度与暂缓内容 | 实操 |
| --- | --- | --- | --- |
| G1：模块、值与类型 | [Create a Go module](https://go.dev/doc/tutorial/create-module)：完整跟做模块创建；[A Tour of Go](https://go.dev/tour/list)：Basics 的 Packages, variables, and functions / Flow control statements / More types；Methods and interfaces 的 Methods、Pointers and functions、Interfaces、Errors | 语法识读，理解 slice / map 的共享与 nil；泛型、反射与深入编译原理暂缓 | [G1](practice.md#g1) |
| G2：错误与测试 | 官方入门教程 [Return and handle an error](https://go.dev/doc/tutorial/handle-errors)、[Add a test](https://go.dev/doc/tutorial/add-a-test) 全文；[errors](https://pkg.go.dev/errors)：Overview、Is、As 的例子 | 应用输入边界、错误传播与行为测试，不依赖错误文本做业务判断 | [G2](practice.md#g2) |
| G3：取消与最小并发 | A Tour of Go → Concurrency：Goroutines、Channels、Select、sync.Mutex；[context](https://pkg.go.dev/context)：Overview、WithCancel、WithTimeout；[Data Race Detector](https://go.dev/doc/articles/race_detector)：Usage、Report Format、Typical Data Races | 理解取消传播、资源释放与共享状态；复杂 channel 网络和 worker 框架暂缓 | [G3](practice.md#g3) |
| G4：HTTP 边界 | [net/http](https://pkg.go.dev/net/http)：Handler、ServeMux 的 Patterns / Precedence、Request.Context、MaxBytesReader、Server 相关超时与 Shutdown；[encoding/json](https://pkg.go.dev/encoding/json)：Decoder.Decode / DisallowUnknownFields、Encoder.Encode；[httptest](https://pkg.go.dev/net/http/httptest)：NewRequest、NewRecorder、NewServer | 应用路由、JSON 校验、错误响应与测试；按实际 Go 版本核对路由模式，流式响应暂缓 | [G4](practice.md#g4) |
| G5：数据库与 CRUD | Go [Querying for data](https://go.dev/doc/database/querying)：Querying for a single row、Querying for multiple rows、Avoiding SQL injection risk；[pgxpool](https://pkg.go.dev/github.com/jackc/pgx/v5/pgxpool)：Establishing a Connection、NewWithConfig、Ping、Query、QueryRow、Exec、Close；[pgx](https://pkg.go.dev/github.com/jackc/pgx/v5)：Rows 的 Close / Err、ErrNoRows | Go 教材用 database/sql 讲机制，本地统一用 pgx；不混用两套连接池 | [G5](practice.md#g5) |
| G6：事务与失败恢复 | Go [Executing transactions](https://go.dev/doc/database/execute-transactions)：Best practices 与事务例子；[Canceling in-progress operations](https://go.dev/doc/database/cancel-operations)：全文；pgxpool 的 Begin、pgx 的 Tx.Commit / Tx.Rollback | 理解同一事务连接、显式结束与取消边界；完整幂等协议连接 SQL 设计单元，分布式事务暂缓 | [G6](practice.md#g6) |
| G7：运行与客户端联调 | net/http 的 Server.Shutdown 示例；[log/slog](https://pkg.go.dev/log/slog)：Overview；Apple [URLSession](https://developer.apple.com/documentation/foundation/urlsession)：Overview、Asynchronicity and URL sessions；回查 [SwiftUI U4](../swiftui-learning/practice.md#u4) | 应用有限超时、脱敏日志、优雅退出与一次 URLSession 解码；完整客户端网络层留到第 11 项 | [G7](practice.md#g7) |

## 3. 交付顺序

```text
纯业务函数与测试 → 可取消的工作 → 内存 HTTP 版本
→ PostgreSQL 持久化 → 事务 / 失败测试 → SwiftUI 读取真实列表
```

实操页给出业务契约、操作步骤、反例、预期结果与验收。你在练习工程逐段实现；允许 AI 辅助，但不要一次生成完整后台再只检查“能启动”。本目录不是已经上线的后端工程。

## 4. 完成标准

- 能解释 Go 值 / 引用相关行为、error 与 context，且小业务规则测试通过。
- API 支持有上限的稳定分页和单词增删改查，非法输入、不存在、唯一冲突有明确响应。
- 数据实际持久化；关联写入失败能回滚；Rows、连接和事务能够释放。
- HTTP 测试、真实 PostgreSQL 集成测试、相关并发路径 race 检查通过；不能把未运行或被跳过的集成测试算作通过。
- 有监听端口、请求响应、数据库查询和 SwiftUI 列表的真实证据；取消、失败与优雅退出行为可解释。

做到这些即可进入产品开发。认证与多用户隔离仍按第 26～28 项在外部试用前实现；当前未认证的练习 API 只监听本机。
