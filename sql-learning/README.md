# SQL / PostgreSQL：数据库基础与设计评审

[技术路线](../tech-list.md) · [通用学习流程](../learning-flow.md)

SQL 是定义、查询和修改关系数据的语言，PostgreSQL 是本工程使用的数据库系统。沿一条主线同时学习语言与数据库行为，基础以识读为主，重点理解正确性、数据模型和架构取舍。

**Neon 是主教材 → 本地实操观察行为 → 本地案例练习设计 → 官方文档定点查证。** 按下面第 1～9 单元推进；子查询、CTE、窗口函数列为选读，可以在需要时穿插。没有时间安排或刷题数量要求。

先按[环境操作](environment.md)连接已有 OrbStack / TablePlus。继续使用 `prompts-sql-learning` 项目、`sql_learning` 数据库和默认 `127.0.0.1:55432`，密码保留在本地 .env。

## 对应第 1～2 项：怎样把握学习深度

本目录的“第 1～9 单元”是 SQL 内部的学习单元，不是总路线第 1～9 项的重新编号。SQL 与 PostgreSQL 共用一套材料和环境，避免先学抽象语法、再从头重复数据库教程。

| 总路线范围 | 本目录学习任务 | 开工前应拿出的证据 |
| --- | --- | --- |
| 第 1 项：数据库基础 | 单元 1～5：查询、类型、约束、增删改、事务、关联与索引 | 能读写一个小功能的数据，解释 NULL、统计粒度、失败回滚和重复输入；能提出稳定排序与索引候选 |
| 第 2 项：设计与评审 | 单元 6～9：并发、演进、系统边界和综合设计 | 能给出并发与归属反例，完成收藏设计和问题方案评审，说明历史、状态与删除的区别 |
| 产品运行前再深化 | 单元 7 的恢复方案、单元 8 的连接与权限，结合总路线第 26～28、33～36 项 | 对外试用前真实恢复备份、落实权限并验证；不能把“读过”当作已经具备运行保障 |

已有能力可以通过对应反例与实操证明后跳过。复杂报表、所有隔离级别的逐项实验、数据库内核和完整运维不作为开工门槛；不要求做完 Q01～Q32 才继续。

## 学习要点

- 表、字段、类型、筛选、排序、空值与修改范围。
- 实体关系、主外键、唯一性、非空与范围约束。
- 多条修改的事务边界，以及重复、失败和并发时的行为。
- JOIN 与统计粒度；查询、索引、排序与执行计划的联系。
- 迁移、维护、恢复、权限与连接的职责。
- 从业务需求设计数据模型，用具体反例评审方案。

## 章节阅读与对应实操

Neon 的 Section 编号来自 [Basic Tutorial](https://neon.com/postgresql/tutorial)；索引、窗口函数与 [Administration](https://neon.com/postgresql/administration) 使用各自目录。下面同时标明标题，网站调整目录时按标题定位。

**识读**：知道用途、看懂常见写法与例子。**理解**：能解释正常结果、失败行为和适用条件。**按需**：碰到相应问题再查。英文正文可用浏览器翻译，SQL 保留原文；网站示例库与本地练习库分别使用，不混用表名。

<a id="unit-1"></a>

### 1. 表与基本查询

- **资料**：Section 12 **Managing Tables** 的 [Data Types](https://neon.com/postgresql/tutorial/data-types)、[Create Table](https://neon.com/postgresql/tutorial/create-table)；Section 1 **Querying Data** 的 [SELECT](https://neon.com/postgresql/tutorial/select)、[Column Aliases](https://neon.com/postgresql/tutorial/column-alias)、[ORDER BY](https://neon.com/postgresql/tutorial/order-by)、[SELECT DISTINCT](https://neon.com/postgresql/tutorial/select-distinct)。
- **接着读**：Section 2 **Filtering Data** 的 [WHERE](https://neon.com/postgresql/tutorial/where)、[AND](https://neon.com/postgresql/tutorial/and)、[OR](https://neon.com/postgresql/tutorial/or)、[LIMIT](https://neon.com/postgresql/tutorial/limit)、[IN](https://neon.com/postgresql/tutorial/in)、[BETWEEN](https://neon.com/postgresql/tutorial/between)、[LIKE](https://neon.com/postgresql/tutorial/like)、[IS NULL](https://neon.com/postgresql/tutorial/is-null)。
- **范围**：识读上述章节的用途、基本语法和例子；类型先认识 integer / text / boolean。理解 NULL、筛选范围和稳定排序；FETCH 暂缓。
- **实操**：[第 1 单元](practice.md#basic)，核对四张表的每行含义，选做 Q01～Q05、Q25～Q27、Q29，改变筛选条件并核对边界。

<a id="unit-2"></a>

### 2. 类型、关系与约束

- **资料**：Section 12 的 [Identity Column](https://neon.com/postgresql/tutorial/identity-column)、[Temporary Table](https://neon.com/postgresql/tutorial/temporary-table)；Section 14 **PostgreSQL Data Types in Depth** 的 [Integer](https://neon.com/postgresql/tutorial/integer)、[NUMERIC](https://neon.com/postgresql/tutorial/numeric)、[CHAR, VARCHAR, and TEXT](https://neon.com/postgresql/tutorial/char-varchar-text)、[Boolean](https://neon.com/postgresql/tutorial/boolean)、[DATE](https://neon.com/postgresql/tutorial/date)、[TIMESTAMP](https://neon.com/postgresql/tutorial/timestamp)、[UUID](https://neon.com/postgresql/tutorial/uuid)、[JSON](https://neon.com/postgresql/tutorial/json)。
- **接着读**：Section 13 **PostgreSQL Constraints** 的 [Primary Key](https://neon.com/postgresql/tutorial/primary-key)、[Foreign Key](https://neon.com/postgresql/tutorial/foreign-key)、[DELETE CASCADE](https://neon.com/postgresql/tutorial/delete-cascade)、[CHECK](https://neon.com/postgresql/tutorial/check-constraint)、[UNIQUE](https://neon.com/postgresql/tutorial/unique-constraint)、[NOT NULL](https://neon.com/postgresql/tutorial/not-null-constraint)、[DEFAULT](https://neon.com/postgresql/tutorial/default-value)。
- **范围**：类型读用途与选择；Identity 读 Introduction 和 ALWAYS / BY DEFAULT 两个例子；JSON 先理解 json / jsonb 的区别。约束要理解组合键、NULL 和删除行为，不展开所有类型参数与 JSON 操作符。
- **实操与补充**：[第 2 单元](practice.md#constraints)，先对照现有表和[八表案例](design.md#case)识别关系、粒度与约束。完整模型运行放在第 3 单元学完事务之后，避免还没认识命令就运行大段脚本。

<a id="unit-3"></a>

### 3. 增删改、事务与重复请求

- **资料**：Section 9 **Modifying Data** 的 [INSERT](https://neon.com/postgresql/tutorial/insert)、[Insert Multiple Rows](https://neon.com/postgresql/tutorial/insert-multiple-rows)、[UPDATE](https://neon.com/postgresql/tutorial/update)、[DELETE](https://neon.com/postgresql/tutorial/delete)、[Upsert](https://neon.com/postgresql/tutorial/upsert)；Section 10 **Transactions** 的 [PostgreSQL Transaction](https://neon.com/postgresql/tutorial/transaction)。
- **范围**：事务全文阅读，理解用途、ACID、自动提交、BEGIN / COMMIT / ROLLBACK 及转账例子；增删改读基本写法与 RETURNING，Upsert 识读 ON CONFLICT。UPDATE JOIN 暂缓。
- **定点补充**：保存点实验前读官方 [3.4 Transactions](https://www.postgresql.org/docs/18/tutorial-transactions.html) 的 SAVEPOINT / ROLLBACK TO 例子；RETURNING 不清楚时查 [6.4 Returning Data from Modified Rows](https://www.postgresql.org/docs/18/dml-returning.html)。
- **实操**：[第 3 单元](practice.md#transactions)：Q06～Q08、Q32 → 提交 / 回滚 / 保存点 → SQL 错误与零行更新 → 八表模型。解释“事务执行成功”和“业务完成”之间还需要哪些检查；去重与完整业务幂等的差别在设计案例中补充。

<a id="unit-4"></a>

### 4. 多表查询与统计粒度

- **资料**：Section 3 **Joining Multiple Tables** 的 [Joins](https://neon.com/postgresql/tutorial/joins)、[Table Aliases](https://neon.com/postgresql/tutorial/alias)、[INNER JOIN](https://neon.com/postgresql/tutorial/inner-join)、[LEFT JOIN](https://neon.com/postgresql/tutorial/left-join)；Section 4 **Grouping Data** 的 [GROUP BY](https://neon.com/postgresql/tutorial/group-by)、[HAVING](https://neon.com/postgresql/tutorial/having)。
- **接着读**：[Aggregate Functions](https://neon.com/postgresql/aggregate-functions) 的 Introduction 及 COUNT / SUM / AVG / MIN / MAX examples；Section 15 **Conditional Expressions & Operators** 的 [CASE](https://neon.com/postgresql/tutorial/case)、[COALESCE](https://neon.com/postgresql/tutorial/coalesce)、[NULLIF](https://neon.com/postgresql/tutorial/nullif)。
- **范围**：理解 INNER / LEFT JOIN 的行数变化、统计粒度、NULL 与除零。其他 JOIN 类型先认识用途，CAST 按需查。
- **实操**：[第 4 单元](practice.md#joins)，Q09～Q16、Q28；观察无会话用户是否丢失、会话时长是否被重复累计、没有数据的最小 / 最大值如何表达。

<a id="unit-5"></a>

### 5. 索引、执行计划与分页

- **资料**：独立专题 **PostgreSQL Indexes** 的 [CREATE INDEX](https://neon.com/postgresql/indexes/create-index)、[UNIQUE Index](https://neon.com/postgresql/indexes/unique-index)、[Multicolumn Indexes](https://neon.com/postgresql/indexes/multicolumn-indexes)、[Partial Index](https://neon.com/postgresql/indexes/partial-index)；Section 17 **Recipes** 的 [EXPLAIN](https://neon.com/postgresql/tutorial/explain)。
- **范围**：理解读取收益、写入代价与组合列顺序；EXPLAIN 读基本语法、ANALYZE、BUFFERS 及例子。结合第 1 单元的 LIMIT / ORDER BY 思考分页，其他索引类型细节按需。
- **实操与补充**：[第 5 单元](practice.md#indexes)，比较索引前后的同一查询，选做 Q30～Q31 的 OFFSET / 游标分页；再从待复习列表与最近会话列表提出排序、分页键和索引候选。PostgreSQL 18 的具体优化行为按下面的官方查证表核对。

<a id="unit-6"></a>

### 6. 并发、隔离与锁

- **要点**：多个请求同时执行时，分别可能看到什么、覆盖什么、等待什么；什么时候要重试整个事务。
- **资料**：Neon 的事务入门已在第 3 单元完成。这里由双连接实验引出问题，定点阅读官方 [13.1 Introduction](https://www.postgresql.org/docs/18/mvcc-intro.html)、[13.2 Transaction Isolation](https://www.postgresql.org/docs/18/transaction-iso.html)、[13.3 Explicit Locking](https://www.postgresql.org/docs/18/explicit-locking.html)、[13.5 Serialization Failure Handling](https://www.postgresql.org/docs/18/mvcc-serialization-failure-handling.html)。
- **范围**：13.1 识读 MVCC；13.2 理解 **13.2.1 Read Committed**，识读 Repeatable Read / Serializable 的差异与重试例子；13.3 读 **13.3.2 Row-Level Locks、13.3.4 Deadlocks**；13.5 看失败后为什么要完整重试。锁冲突矩阵按需查。
- **实操**：[第 6 单元](practice.md#locks)，两个独立连接观察锁等待；再给“保存作答 + 更新进度”标出并发风险。单次锁实验不等于验证了所有隔离级别。

<a id="unit-7"></a>

### 7. 迁移、维护与恢复

- **资料**：Neon Section 12 的 [Alter Table](https://neon.com/postgresql/tutorial/alter-table)、[Add Column](https://neon.com/postgresql/tutorial/add-column)、[Change Column's Data Type](https://neon.com/postgresql/tutorial/change-column-type)；**Administration → Section 5 Backup & Restore** 的 [Backup Databases](https://neon.com/postgresql/administration/backup-database)、[Restore Databases](https://neon.com/postgresql/administration/restore-database)。
- **范围**：读增列、默认值、改类型的基本例子；Backup 读 Introduction、pg_dump / pg_dumpall 介绍及“Backing up a single database”例子；Restore 读“Introduction to PostgreSQL pg_restore tool”和恢复示例。纯 SQL 文件的恢复方式按下面的官方 25.1.1 核对。工具选项不背诵，这里先做恢复方案说明。
- **实操与补充**：[第 7 单元](practice.md#migration)，在临时表完成“增列 → 回填 → 非空约束”，解释旧代码兼容性；区分误删、进程崩溃和副本延迟。遇到 VACUUM、WAL、时间点恢复的保证范围问题时，用下面的官方查证表补齐。

<a id="unit-8"></a>

### 8. 连接、权限与 Go 边界

- **资料**：**Administration → Section 2 Managing Schemas** 的 [Schema](https://neon.com/postgresql/administration/schema)；**Section 4 Roles & Privileges** 的 [Create Roles](https://neon.com/postgresql/administration/roles)、[Grant Privileges](https://neon.com/postgresql/administration/grant)、[Revoke Privileges](https://neon.com/postgresql/administration/revoke)、[Role Membership](https://neon.com/postgresql/administration/role-membership)。
- **范围**：识读 database / schema、角色、对象权限及成员关系；理解运行账号与管理职责、数据库权限与业务用户授权的区别。当前只阅读，不修改学习库的角色与权限。
- **实操与补充**：[第 8 单元](practice.md#architecture)，画请求到事务的路径，计算连接预算，标出授权、超时、外部 AI 调用与数据库事务的边界。实际驱动与 API 编码在 [Go 第 7～8 项](../go-learning/README.md)完成，使用独立的 go_learning schema，不修改 public 练习表。

<a id="unit-9"></a>

### 9. 综合设计与评审

- **补充材料**：[design.md](design.md)：第 1～2 节“数据含义与八表案例”，第 3 节“评审清单”，第 4 节“收藏设计与问题方案”，做完后再看第 5 节参考评审。
- **练习**：[第 9 单元](practice.md#design)，从收藏功能需求推导表粒度、唯一性、事务、索引、历史与删除行为，再评审有缺陷的设计。
- **完成标准**：能解释选择依据，用重复请求、跨用户关联、并发覆盖、历史变化等反例检验设计；语法不熟可以查，业务前提必须说清。

<a id="advanced"></a>

### 选读：子查询、CTE 与窗口函数

第 4 单元后可按需要穿插，用于读懂复杂报表。

- **资料**：Neon Section 7 **Subquery** 的 [Subquery](https://neon.com/postgresql/tutorial/subquery)、[Correlated Subquery](https://neon.com/postgresql/tutorial/correlated-subquery)、[EXISTS](https://neon.com/postgresql/tutorial/exists)；Section 8 **Common Table Expressions** 的 [CTE](https://neon.com/postgresql/tutorial/cte)。
- **窗口函数**：[PostgreSQL Window Functions](https://neon.com/postgresql/window-function) 的 Introduction、Syntax 中 PARTITION BY / ORDER BY / frame_clause，以及 ROW_NUMBER / RANK / DENSE_RANK 小节。
- **范围与实操**：识读用途与中间结果，进入[选读练习 Q17～Q24](practice.md#queries)，可以拆解答案。ANY / ALL、Recursive CTE、FIRST_VALUE / LAST_VALUE、LAG / LEAD 按需；不要求默写复杂查询。

## 官方文档：遇到具体问题时查

版本固定为 **PostgreSQL 18**，与本地环境主版本一致。第 3 单元的保存点、第 6 单元的并发机制已在对应位置指定；其他内容按下表的问题选择，不另外通读一套教材。

| 需要查证的问题 | 具体章节与阅读范围 |
| --- | --- |
| 客户端、服务端和连接分别是什么？ | [1.2 Architectural Fundamentals](https://www.postgresql.org/docs/18/tutorial-arch.html)，读客户端 / 服务端关系 |
| NULL、组合键或删除行为判断不准 | [5.5 Constraints](https://www.postgresql.org/docs/18/ddl-constraints.html) 的 **5.5.1～5.5.5**，查对应约束的例子和限制 |
| 时间点与时区、json 与 jsonb 如何选择？ | [8.5 Date/Time Types](https://www.postgresql.org/docs/18/datatype-datetime.html) 的 timestamp / time zone 部分；[8.14 JSON Types](https://www.postgresql.org/docs/18/datatype-json.html) 开头对比 |
| 组合索引规则是否绝对？计划中的数字如何解释？ | [11.3 Multicolumn Indexes](https://www.postgresql.org/docs/18/indexes-multicolumn.html)，含 skip scan 说明；[14.1 Using EXPLAIN](https://www.postgresql.org/docs/18/using-explain.html) 的 **14.1.1～14.1.2** |
| 增列、默认值、约束和类型变更对旧数据有什么影响？ | [5.7 Modifying Tables](https://www.postgresql.org/docs/18/ddl-alter.html) 的 **5.7.1、5.7.3、5.7.5、5.7.6**；[CREATE INDEX](https://www.postgresql.org/docs/18/sql-createindex.html) 的 **Building Indexes Concurrently** 按需 |
| VACUUM、ANALYZE 与 WAL 各负责什么？ | [24.1 Routine Vacuuming](https://www.postgresql.org/docs/18/routine-vacuuming.html) 的 **24.1.1～24.1.3**；[28.3 Write-Ahead Logging](https://www.postgresql.org/docs/18/wal-intro.html) 的用途说明 |
| 如何恢复到误删之前？ | [25.3 Continuous Archiving and PITR](https://www.postgresql.org/docs/18/continuous-archiving.html) 的开头原理；[25.1 SQL Dump](https://www.postgresql.org/docs/18/backup-dump.html) 中 **25.1.1 Restoring the Dump** 核对逻辑恢复 |
| 是否需要行级权限，哪些角色能绕过？ | [5.9 Row Security Policies](https://www.postgresql.org/docs/18/ddl-rowsecurity.html)，先读策略用途、默认行为、所有者与绕过说明 |

**本轮暂缓**：Neon 的集合运算、GROUPING SETS / CUBE / ROLLUP、导入导出、PL/pgSQL、触发器实现，以及分区、复制部署、内核与复杂调优。遇到产品需求再展开。

## 目录用途

继续学习时，协议进入 [HTTP](../http-learning/README.md)，客户端进入 [Swift](../swift-learning/README.md)与 [SwiftUI](../swiftui-learning/README.md)，数据库访问实现进入 [Go](../go-learning/README.md)。产品规则的来源与取舍见[产品与市场](../product-learning/README.md)。

| 文件 | 用途 |
| --- | --- |
| 本页 | 唯一阅读入口：要点、章节范围、实操与完成标准 |
| [environment.md](environment.md) | OrbStack 建库 / 启动、TablePlus 连接与排错 |
| [practice.md](practice.md) | 与主线对应的操作、观察、失败案例与答案检查 |
| [design.md](design.md) | 数据模型、系统边界、设计练习与参考评审 |
| [transactions.sql](transactions.sql)、[model.sql](model.sql) | 事务实验与八表模型，按实操页独立运行 |
| [exercises/all.sql](exercises/all.sql)、[solutions/all.sql](solutions/all.sql) | 统一练习列表 Q01～Q32 与参考答案，不按天或固定题数组合；按学习内容选做 |
| compose.yaml、.env.example、.gitignore | 环境配置、配置说明及本地密码文件的忽略规则 |
| schema.sql、seed.sql、hello.sql | 四表结构、初始数据和连接检查 |
| lab.py、expected.json | 启停环境及核对练习结果 |
