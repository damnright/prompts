# Go 实操：业务函数 → 单词 API → SwiftUI

[章节导读](README.md) · [环境操作](environment.md) · [设计补充](design.md)

本页是逐步实现任务与验收依据；不是现成后端。先读对应单元，再在自己的练习工程完成小块代码。只用虚构数据与本地回环服务，密码留在环境变量中。

<a id="g1"></a>

## G1. 模块、类型与集合

**前置：** 阅读 G1，初始化或复用模块。

定义 `Word`，字段为 id、term、level、可空 example；给 JSON 字段加明确 tag。用 `*string` 或其他明确的可空表示区分 null 与空字符串。写按 level 筛选并按 ID 排序的函数，输入为空时返回可编码为 `[]` 的集合。

观察 slice 共享底层数组：复制 slice 后修改一个元素，再追加使容量变化，解释何时是共享数据，何时可能分配新数组；不要把 slice 赋值当作深复制。给 Word 写一个方法，再识读一个只由消费者需要的简单 interface。

**预期：** 固定输入得到固定输出；未知 level 的行为有明确约定。运行代码能解释值、指针、slice、map 与 nil 的基本区别。

**清理：** 保留词条类型，删除只用于观察的临时打印与变体。

<a id="g2"></a>

## G2. 输入规则与行为测试

**前置：** 阅读 G2。

练习规则：term 去两端空白、转小写，结果长度为 1～80 个 Unicode 字符；level 仅 A1 / A2 / B1；example 可为 null。这里的规范化是教学假设，正式词典的词性、大小写与多义项规则另行设计。

实现规范化 / 校验函数，返回可识别的错误。给规则写表驱动测试，覆盖正常、两端空白、空白输入、长度边界、未知 level、null 与空例句。错误包了一层上下文后，用 errors.Is / As 仍能辨别类型。

**预期：** `" Speak "` 变为 `"speak"`；空白 term 和非法 level 被拒绝；example 的 null 不被悄悄变成空字符串。只测公开行为，不测试私有函数被调用几次。

**验收与清理：** 在本工程运行 `go test ./...` 与 `go vet ./...`；保留有意义的规则测试，移除故意失败的实验改动。

<a id="g3"></a>

## G3. 取消、资源与并发

**前置：** 阅读 G3。

写一个接收 context 的等待函数，用 select 同时等待工作完成和 `ctx.Done()`。调用方用 WithCancel / WithTimeout 创建派生 context，并负责 cancel；函数退出后用明确完成信号证明工作已结束，不能只等待一个猜测的 sleep 时长。

再让两个 goroutine 修改一个共享计数，运行 race detector 观察报告；只在练习副本保留故意错误的版本。用合理的互斥或单一所有者修复，再运行同一用例。

**预期：** 取消后返回对应错误，defer 完成清理，没有继续增长的后台工作；修复后的已执行路径没有 race 报告。无报告不等于证明所有可能并发路径安全。

**清理：** 结束全部实验 goroutine，恢复通过检查的版本。

<a id="g4"></a>

## G4. 先明确 HTTP 契约

**前置：** 阅读 G4 与 HTTP H1～H5。先用内存数据完成边界，G5 再换持久化。

用 ServeMux 选择路由，Handler 完成请求处理；把统一行为写成接收并返回 Handler 的小型中间件，例如 G7 的请求 ID 与耗时记录。先解释包裹顺序与错误路径，不引入框架才能完成的隐藏行为。

| 操作 | 请求约定 | 成功结果与主要失败 |
| --- | --- | --- |
| 检查进程 | GET /healthz | 200；只表示进程能响应，不声称数据库健康 |
| 列表 | GET /words?limit=20&after_id=0 | 200，items 数组、next_after_id；limit 为 1～100，after_id 为非负整数，否则 400 |
| 单条 | GET /words/{id} | 200 单条 Word；非法 ID 400，不存在 404 |
| 新建 | POST /words，JSON 含 term、level、example | 201、Location 与服务端生成 ID 的 Word；非法 400、同名 409 |
| 替换可编辑内容 | PUT /words/{id}，完整提交 term、level、example | 200 Word；非法 400、不存在 404、同名 409 |
| 删除 | DELETE /words/{id} | 首次 204 且无 Body；已不存在 404 |

列表按 id 升序，查询 `id > after_id`，最多返回 limit 条。可额外查一条判断是否还有下一页；有下一页时游标是本页最后一条 ID，否则 null。空列表返回 `{"items":[],"next_after_id":null}`。这不是冻结全库的快照分页。

创建与修改示例：

```json
{"term":"speak","level":"A2","example":null}
```

Word 响应示例：

```json
{"id":1,"term":"speak","level":"A2","example":null}
```

错误统一为 `{"error":{"code":"invalid_input","message":"可供用户理解的说明"}}`。练习约定拒绝未知字段、多个连续 JSON 值和非对象 Body；example 缺失在 POST 视为 null，在完整替换 PUT 中要求显式提供。由此观察“类型零值”和“字段是否出现”的区别。

按 Content-Type 校验 JSON，非支持类型返回 415；请求体设置 16 KiB 上限，超过返回 413。用明确的大小限制、解码后 EOF 检查与校验完成输入处理；`DisallowUnknownFields` 本身不能完成所有业务检查。

**验证：** 使用 httptest 检查状态、响应 JSON、Location、204 无正文和错误格式；测试错误输入、空结果、不存在、重复创建与两个 JSON 拼接。使用 NewServer 观察一次真实 HTTP 往返。内存版共享集合需保证并发安全。

**清理：** 关闭测试 server，保持回环监听；不添加用于“模拟已登录”的真实鉴权旁路。

<a id="g5"></a>

## G5. 接入 PostgreSQL，让数据真实保存

**前置：** 阅读 G5，按环境页准备隔离 schema 与 pgxpool。Go 代码访问完整表名 `go_learning.words`。

1. 启动时建一个连接池并 Ping；退出时关闭。数据库暂不可达应明确失败，不能继续报告所有功能可用。
2. 先做 GET 列表与单条，用参数传入 limit、游标和 ID；QueryRow 在 Scan 时判断无记录，多行查询处理 Rows.Close 与 Rows.Err。
3. 实现 INSERT / UPDATE 的 RETURNING，DELETE 检查 RowsAffected。只有数据库生成 ID；不要拿 SQL public.words 的固定 ID 当作序列值。
4. 用唯一约束处理并发重复，识别 PgError 的唯一冲突并映射为 409；不按错误字符串包含某个词来判断。
5. 完成真实数据库集成测试，再接回原来 HTTP 契约。不要把原有 public 表当成可重置测试夹具。

服务运行后，用单独终端创建测试词条：

```sh
curl -i 'http://127.0.0.1:8088/words' \
  -H 'Content-Type: application/json' \
  --data '{"term":"route-lab-word","level":"A2","example":null}'
curl -i 'http://127.0.0.1:8088/words?limit=2&after_id=0'
```

先确认示例 term 未被自己的其他练习占用；冲突时改用自己的唯一测试词，记录创建响应中的 ID。随后在 TablePlus 查询这个 term，停止再启动 Go，确认该词仍在。

再按记录的 ID 执行 PUT、GET、DELETE；重复 POST 应为 409，更新 / 删除不存在 ID 应为 404，错误载荷不应写入。分页多次返回的 ID 必须有序且不重叠；测试结束后仅删除自己创建的词条。

**验收：** 请求结果、TablePlus 查询、重启后读取三者相互印证；SQL 注入样式输入只能成为参数值或被规则拒绝，不能改变查询结构。

**连接迁移知识：** 在隔离测试 schema 中给已有词条表新增一个可空字段，验证旧的显式列查询与新代码都能运行；再分析“立刻改成无默认值的必填字段”为什么会让旧写入失败。记录迁移顺序与兼容验证，实验结束后按测试隔离方式清理，不修改 public 表，也不把重新执行 schema.sql 当作迁移。

<a id="g6"></a>

## G6. 关联写入、失败回滚与测试隔离

**前置：** 阅读 G6，回看 SQL 事务与并发单元。

实现一个被测试直接调用的 `CreateWordWithNote` 操作：同一个 Tx 插入 words 与 word_notes，再 Commit。不必为此新增公开路由，备注只是关联写入练习。

在隔离测试中让第二条插入故意触发备注约束错误，确认第一条词条没有留下；再测试合法备注，两条记录一起存在。生产业务仍先校验输入，故障注入只在测试中保留，不做成客户端参数。

| 验证场景 | 必须核对的结果 |
| --- | --- |
| 第二条 SQL 失败 | 整体回滚，不存在半个业务结果 |
| context 在 SQL 前已取消 | 返回取消错误，无新增记录 |
| 受控慢查询超过短 deadline | 返回超时 / 取消，连接随后能正常使用；不把客户端错误当成提交已撤销 |
| 两个请求并发创建规范化后相同 term | 一条成功、一条冲突，表里只有一行 |
| 反复触发错误后继续正常请求 | 没有因 Rows / Tx 泄漏而耗尽连接池 |
| Commit / 返回结果不确定 | 给出核对方式，不盲重跑具有额外副作用的动作 |

**隔离方式：** 单连接数据库函数测试可注入同一 Tx 并在结束后回滚；会创建自己的事务、通过连接池或通过 HTTP 的测试，改用测试专属且唯一命名的 schema，配置对应数据访问路径。不能以“外层开了事务”误以为其他连接的写入也会被回滚。测试专属 schema 仅在确认归本次测试所有后清理；失败时保留定位信息而不扩大清理范围。

**验收：** 真 PostgreSQL 上的查询证明数据与资源状态，不能仅检查函数返回了 error。运行完整相关测试、vet 与 race；数据库未连接而被跳过的测试列为未验证。

<a id="g7"></a>

## G7. 服务运行与 SwiftUI 最小联调

**前置：** G4～G6 完成，SwiftUI U1～U4 的模拟流程可运行。数据库凭据始终留在 Go 侧。

1. 为 HTTP Server 设置合理的读取、写入和空闲超时，为 SQL 派生有限 context；知道不同超时约束的是哪个阶段。
2. 用 slog 记录请求 ID、方法、规范化路由、状态和耗时，不输出凭据、完整 Body 或连接串。数据库错误有排查线索，客户端只收到稳定错误结构。
3. 保留监听证据和 curl 请求结果，再用 URLSession 请求 GET /words。先检查 HTTPURLResponse 的状态，再把 Body 解码为 items 与 next_after_id；区分传输、HTTP、解码三类失败。
4. 将结果交给 MainActor 上的页面模型，复用 U4 的加载 / 空 / 错误 / 重试状态；取消与过期结果仍然受控。此时仅联调读取即可，完整客户端写流程留给产品开发。
5. 在本地让一个请求延迟，触发退出流程；通过 Server.Shutdown 的有限等待与连接池关闭确认资源归还。

**网络位置：** 先用 iOS 模拟器访问 Mac 的回环服务。若系统网络策略阻止本地 HTTP，查看 URLSession 错误并按 Apple [ATS 配置](https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity)核对必要的开发配置；不全局关闭传输安全。真机的 127.0.0.1 指向真机自身，不能直接访问 Mac；真机联网验证放在受控网络与必要安全配置完成之后。

**验收证据：** Go 的真实请求记录、数据库中的同一行、SwiftUI 实际显示、失败重试结果；构建通过或固定模拟数组不算联调成功。

**结束：** 停止本次 Go 进程，按环境页清除本次凭据变量与测试记录；保留可工作的 App / 后端继续产品开发。
