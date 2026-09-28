# SQL / PostgreSQL 本地实操

[章节导读](README.md) · [环境操作](environment.md) · [设计补充](design.md)

下面的章节与导读第 1～9 单元对应。所有 SQL 题统一放在 [exercises/all.sql](exercises/all.sql)，答案放在 [solutions/all.sql](solutions/all.sql)，连续编号 Q01～Q32，不按天划分。读完一组资料再选做对应实操：先预测、再运行、最后改变一个条件比较，不要求刷完。

所有操作使用现有 sql_learning 学习库。查询与 Q06～Q08、Q32 使用四张练习表；增删改演示用显式事务回滚。事务、模型、索引和迁移实验使用临时表；双连接实验只对现有行加锁。网站示例库不导入当前环境。

## 统一练习索引

原有 Q01～Q24 保留编号；Q25～Q32 补齐阅读内容中的遗漏，按下表穿插，不必等选读题做完。完整题意、输出列和排序要求以统一 SQL 文件为准。

| 题号 | 内容 | 对应阅读 / 实操 |
| --- | --- | --- |
| Q01～Q05 | 字段、筛选、NULL、排序、去重 | 第 1 单元 |
| Q06～Q08 | INSERT / UPDATE / DELETE 与 RETURNING，三题一起执行 | 第 3 单元 |
| Q09～Q16 | JOIN、聚合、正确率、零记录与重复累计 | 第 4 单元 |
| Q17～Q24 | 子查询、CTE、窗口函数与综合概览 | 选读 |
| Q25～Q27 | IN 与逻辑组合、BETWEEN、UTC 时间边界 | 第 1 单元；时间类型可回查第 2 单元 |
| Q28 | MIN / MAX 与零记录 | 第 4 单元 |
| Q29 | NOT IN 与 NULL | 第 1 单元 |
| Q30～Q31 | OFFSET / 游标分页与并列时间 | 第 5 单元，复用第 1 单元 LIMIT / ORDER BY 资料 |
| Q32 | 批量 INSERT、Upsert、重复提交与清理 | 第 3 单元 |

约束、事务失败、索引、锁、迁移和设计评审继续使用下方对应实验；它们需要分段操作、双连接或解释结果，不放进单结果表的自动判题文件。

<a id="basic"></a>

## 1. 表与基本查询

配置与连接步骤见[环境操作](environment.md)。结构见 [schema.sql](schema.sql)，虚构数据见 [seed.sql](seed.sql)，连接检查见 [hello.sql](hello.sql)。

| 表 | 每行代表什么 | 初始行数 |
| --- | --- | --- |
| users | 一个用户 | 5 |
| words | 一个词条 | 12 |
| learning_sessions | 一次学习会话 | 10 |
| word_reviews | 一次作答 | 18 |

核对结果时使用以下口径：

- 作答次数、不同单词数、不同用户数分别计算。
- completed 与 abandoned 按题目筛选；未评分不当作 0 分。
- 正确率按 is_correct 计算；没有作答时为 NULL。
- An 没有会话，Yu 只有退出会话；保留零记录的查询不能漏掉他们。
- Chen 有两个同时开始、时长相同的会话；用于观察稳定排序和错误去重。
- 题目的日期固定在 2026 年 9 月，按 UTC 计算，不替换成当前日期。
- 本地四表用于查询练习，产品设计另见[八表模型](design.md#case)。

先运行 [hello.sql](hello.sql)，核对表的数量与行数。在 TablePlus 执行 `SELECT current_database(), current_schema(), pg_backend_pid();`，说明当前库、schema 与连接各是什么。

文件：[统一题目](exercises/all.sql) · [参考答案](solutions/all.sql)。本单元选做 Q01～Q05、Q25～Q27、Q29。

| 题号 | 操作 | 观察重点 |
| --- | --- | --- |
| Q01～Q02 | 选字段、筛选单词 | 输出列、AND / OR、匹配范围 |
| Q03 | 查缺失例句 | IS NULL 与等号的差别 |
| Q04～Q05 | 排序取部分结果、去重 | 并列时的次序、去重针对哪些列 |
| Q25～Q27 | 集合筛选、逻辑括号、数值 / 时间范围 | 包含哪些端点，时区是否明确 |
| Q29 | 排除指定评分并保留未评分 | NOT IN 与 NULL 的三值逻辑 |

先读答案再运行也可以。改变一个筛选条件或排序，预测返回的行数和顺序。

<a id="constraints"></a>

## 2. 类型、关系与约束

对应[第 2 单元资料](README.md#unit-2)。这一轮先识读：

1. 对照 [schema.sql](schema.sql)，找出主键、外键、唯一、非空与范围约束，解释各自拒绝什么数据。
2. 阅读[八表案例的业务假设与表粒度](design.md#case)，说明“组成员”“会话目标”“作答事件”“当前进度”为什么有不同粒度和生命周期。
3. 评审三句话：有 UUID 就不会业务重复、有外键就不会越权、有范围 CHECK 就不会为空。分别给出反例。
4. 对照 [model.sql](model.sql) 的字段选择，说明日期与时间点、整数与精确小数适合什么需求；哪些信息应有独立列或关系，而不是全部塞进 JSONB。

本单元先看结构和设计含义；学完下一单元的事务后，再运行[完整模型实验](#model)。

<a id="transactions"></a>

## 3. 增删改、事务与失败

### 3.1 修改范围：Q06～Q08

文件：[题目](exercises/all.sql) · [参考答案](solutions/all.sql)。依次新增、修改、删除一个练习词，每步检查 WHERE 范围、RETURNING 和最终数据。

增删改按下面顺序在同一连接执行，使用题目指定的 ID 99；先确认它尚未被自己其他练习占用：

```sql
SELECT id, term FROM words WHERE id = 99;
BEGIN;
-- 依次执行 Q06、Q07、Q08 的 SQL，每次查看 RETURNING 结果。
ROLLBACK;
SELECT id, term FROM words WHERE id = 99;
```

最终应无 ID 99；中途报错也在同一连接执行 ROLLBACK。接着运行下面的独立事务实验，区分整体提交、回滚与局部回滚。

补充 Q32：按题意批量插入两词，再对同一词连续 Upsert 两次，核对只有两行且例句已更新。它可以独立于 Q06～Q08 执行；在 TablePlus 中先确认 ID 99 / 100 与 focus / repeat 均未占用，再用 BEGIN / ROLLBACK 包住整题，结束后核对没有遗留记录。统一答案文件不包含事务命令，由检查器管理回滚。

### 3.2 提交、整体回滚与保存点

按[第 3 单元指定资料](README.md#unit-3)读完事务与保存点例子，再观察下面的结果。

在 TablePlus 一个新连接里打开 [transactions.sql](transactions.sql)，按 A / B / C 三组逐段运行，观察 SELECT 输出。也可在终端一次运行并核对：

```sh
cd /Users/yuyang/Projects/prompts/sql-learning
~/.orbstack/bin/docker --context orbstack compose \
  --project-name prompts-sql-learning --env-file .env --file compose.yaml \
  exec -T postgres psql -X -U sql_learner -d sql_learning \
  -v ON_ERROR_STOP=1 < transactions.sql
```

| 实验 | 操作 | 预期结果（按 id 1、2） |
| --- | --- | --- |
| A | 两条 UPDATE 后 ROLLBACK | 回滚前 70 / 130，回滚后 100 / 100 |
| B | 两条 UPDATE 后 COMMIT | 提交后 70 / 130 |
| C | 保存点后误加 999，局部回滚后改加 10，再 COMMIT | 误加时 60 / 1129；最终 60 / 140 |

最后应看到 transaction checks passed。脚本中的 DO 块只是核对结果，不要求学习它的语法。临时表最后删除，连接断开也会清理。不要用 lab.py sql 执行，因为它会额外包装事务。

<a id="failures"></a>

### 3.3 中途错误与零行更新

在 TablePlus 同一个新连接中，先单独执行初始化：

```sql
CREATE TEMP TABLE tx_failure_points (
    id integer PRIMARY KEY,
    points integer NOT NULL CHECK (points >= 0)
);
INSERT INTO tx_failure_points VALUES (1, 100), (2, 100);
```

逐段执行，观察错误，不要一次运行整个小节：

```sql
BEGIN;
UPDATE tx_failure_points SET points = points - 30 WHERE id = 1;
```

```sql
UPDATE tx_failure_points SET points = -1 WHERE id = 2;
```

预期 CHECK 失败。接着单独执行：

```sql
SELECT * FROM tx_failure_points;
```

预期提示事务已失败。然后在同一连接恢复：

```sql
ROLLBACK;
SELECT * FROM tx_failure_points ORDER BY id;
```

预期仍为 100 / 100。再做零行更新对照：

```sql
BEGIN;
UPDATE tx_failure_points SET points = points - 30 WHERE id = 1;
UPDATE tx_failure_points SET points = points + 30 WHERE id = 999
RETURNING id, points;
SELECT * FROM tx_failure_points ORDER BY id;
ROLLBACK;
```

第二次 UPDATE 返回零行，但不是 SQL 错误；回滚前看到 70 / 100。回答：如果应用此时直接提交，业务会留下什么错误？完成后断开本实验连接，临时表自动清理。

<a id="model"></a>

### 3.4 运行八表模型，观察约束如何拒绝错误

完成第 2 单元的类型与约束、第 3 单元的事务阅读后，对照[八表案例](design.md#case)运行。

文件：[model.sql](model.sql)。包含临时建表、虚构数据、合法写入与预期失败检查。独立连接执行，末尾回滚，不改造原有四张练习表。

先按[环境操作](environment.md)确认同一学习容器正在运行，然后在终端执行：

```sh
cd /Users/yuyang/Projects/prompts/sql-learning
~/.orbstack/bin/docker --context orbstack compose \
  --project-name prompts-sql-learning --env-file .env --file compose.yaml \
  exec -T postgres psql -X -U sql_learner -d sql_learning \
  -v ON_ERROR_STOP=1 < model.sql
```

预期看到 model checks passed，以及一行待复习结果：用户 1、bank、银行、掌握程度 2。固定截止日期用于重复验证，不改成当前日期。

脚本检查：重复事件、跨用户组、跨用户会话、非目标词、越界与空评分、错误状态时间、重复进度；并确认同一事件键重试不插入第二行。

对每个失败案例指出：触发哪条约束、没有该约束会出现什么错误、应用是否还需要授权或并发控制。

<a id="joins"></a>

## 4. 多表查询与统计粒度

文件：[统一题目中的 Q09～Q16、Q28](exercises/all.sql) · [参考答案](solutions/all.sql)。

| 题号 | 操作 | 观察重点 |
| --- | --- | --- |
| Q09 | 会话关联用户名 | 一行仍代表一次会话吗？ |
| Q10 | 按用户统计会话数，保留无会话用户 | An 是否为 0？COUNT(*) 会不会误算？ |
| Q11～Q12 | 汇总时长、筛选分组 | WHERE 与 HAVING 的位置与口径 |
| Q13～Q15 | 单词作答统计、用户正确率与平均评分 | NULL、分母、评分缺失、整数除法 |
| Q16 | 用户、会话、作答一起统计 | 是否重复累计会话时长？ |
| Q28 | 每个用户的最短 / 最长完成会话 | 无记录时 MIN / MAX 为 NULL，不能擅自当作 0 |

先读每题的具体字段与排序要求，再运行答案。额外对照实验：

1. 将 Q10 的 LEFT JOIN 改为 INNER JOIN，观察无会话用户是否消失。
2. 将会话直接关联多条作答再 SUM 时长，与 Q16 的结果比较。
3. 用 SUM(DISTINCT duration_minutes) 尝试修复，检查 Chen 的两个相同时长会话是否被错误合并。

<a id="indexes"></a>

## 5. 索引、执行计划与分页

对应[第 5 单元](README.md#unit-5)，先读 Neon 的索引与 EXPLAIN 指定章节。在同一个连接运行：

```sql
BEGIN;
CREATE TEMP TABLE pg_index_demo AS
SELECT g AS id, g % 100 AS user_id, g AS due_order
FROM generate_series(1, 10000) AS g;
ANALYZE pg_index_demo;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, due_order FROM pg_index_demo
WHERE user_id = 42
ORDER BY due_order, id LIMIT 10;

CREATE INDEX ON pg_index_demo (user_id, due_order, id);
ANALYZE pg_index_demo;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, due_order FROM pg_index_demo
WHERE user_id = 42
ORDER BY due_order, id LIMIT 10;
ROLLBACK;
```

记录建立索引前后的扫描与排序方式、估计 / 实际行数、缓冲区信息。EXPLAIN 显示计划而非业务结果；如需核对数据，在最后 ROLLBACK 之前去掉 EXPLAIN 那一行，单独执行 SELECT，预期 id 为 42、142……942 共十行。执行计划可因环境变化，不要求固定节点或固定耗时，也不以此证明生产性能。

再为八表案例的“待复习列表”和“最近会话列表”写出用户范围、排序、页大小、唯一的排序补充键与索引候选。说明只按一个可能重复的时间字段排序，会给分页带来什么问题。

选做统一列表 Q30～Q31：先用 OFFSET 取第二页，再用上一页最后的 `(started_at, id)` 作为游标取下一页，核对顺序均为 7、2、5。只比较时间会漏掉并列的会话 7。解释列表新增、删除以及排序字段变化可能造成的遗漏或重复；固定数据下两题结果一致不代表跨请求共享同一快照。

<a id="locks"></a>

## 6. 并发、隔离与锁

对应[第 6 单元](README.md#unit-6)，重点核对官方 13.3.2 Row-Level Locks。这是行锁观察，不是完整隔离级别测试。

在 TablePlus 打开两个独立连接 A / B，分别执行 SELECT pg_backend_pid();，确认数字不同；两个查询标签不一定代表不同连接。先确认 words 中 id = 1 存在。

A 执行：

```sql
BEGIN;
SELECT id FROM public.words WHERE id = 1 FOR UPDATE;
```

A 暂不结束。B 执行：

```sql
BEGIN;
SET LOCAL lock_timeout = '2s';
SELECT id FROM public.words WHERE id = 1 FOR UPDATE;
```

预期 B 等待后报锁超时。B 先单独 ROLLBACK；A 再 ROLLBACK。随后在 B 重跑相同三句，应得到一行，再执行 ROLLBACK。

操作完成后两个连接都结束事务。若 A 本身就等待，先取消并回滚，检查是否有自己之前未结束的事务，不终止其他会话。

接着为“保存作答 + 更新进度”画正常、重复请求、并发覆盖和失败重试四条路径，说明哪些由唯一约束、事务、行锁或版本检查处理。单次行锁实验只能验证锁等待；其他隔离行为仍需结合指定章节判断。

<a id="migration"></a>

## 7. 迁移、维护与恢复

对应[第 7 单元](README.md#unit-7)，先读 Neon 的 Alter Table / Add Column 指定章节。在同一个连接运行：

```sql
BEGIN;
CREATE TEMP TABLE pg_migration_demo (id integer PRIMARY KEY);
INSERT INTO pg_migration_demo VALUES (1), (2);

ALTER TABLE pg_migration_demo ADD COLUMN source text;
SELECT * FROM pg_migration_demo ORDER BY id;

UPDATE pg_migration_demo SET source = 'legacy' WHERE source IS NULL;
ALTER TABLE pg_migration_demo ALTER COLUMN source SET NOT NULL;
SELECT * FROM pg_migration_demo ORDER BY id;
ROLLBACK;
```

观察新增列初始为 NULL、回填后两行都是 legacy、之后可加强非空约束。回答：如果旧应用仍不提供 source，新插入会怎样？需要怎样安排默认值、应用发布和约束生效顺序？

这只验证小数据上的命令与结果，不代表在线迁移的锁和资源成本。接着用本节的恢复任务和下一节的系统边界任务理解运行职责。

阅读 Neon 的 Backup / Restore 指定章节后，先写恢复方案，不对现有库执行恢复：备份范围与恢复目标 → 独立目标环境 → 还原 → 数据 / 权限检查 → 应用关键查询。

区分误删、进程崩溃和副本延迟；需要确认时回查章节导读中的 WAL、VACUUM、PITR 指定小节。解释副本为什么不能代替历史备份、修改 schema.sql 为什么不会自动迁移已有数据卷。

<a id="architecture"></a>

## 8. 连接、权限与 Go 边界

对应[第 8 单元资料](README.md#unit-8)。产出流程图或简短说明即可：

1. 画出 TablePlus → 本机 55432 → OrbStack 容器 5432 → PostgreSQL → 数据文件 / WAL 的路径；说明关闭客户端与停止容器各影响什么。
2. 画一次 Go 请求的认证、业务判断、事务与数据库访问路径，标出授权、超时、结果集 / 连接归还，以及外部 AI 调用的位置。
3. 假设最大同时 4 个 API 实例，每个池上限 10，另有 5 个 worker 连接、5 个管理连接：总上限为 50。再考虑滚动发布时实例重叠，说明为什么应按最大同时实例数预算。
4. 说明运行角色、迁移角色、业务用户的区别，以及数据库权限为什么不能自动识别当前请求属于哪个用户。

此处先识读与设计；实际驱动和 API 编码进入 [Go 第 7～8 项](../go-learning/README.md)，数据库复用本环境，应用练习使用独立 schema。此单元不做角色调整或新部署。

<a id="design"></a>

## 9. 综合设计与评审

进入 [design.md 第 4 节](design.md#exercises)：先设计收藏功能，再评审有缺陷的方案；之后查看[参考评审](design.md#answers)。

每条评审应说明问题、触发场景、业务影响、改法与前提。语法允许查阅，能用反例检查模型、并发、查询和生命周期才是本单元的重点。

**第 1～2 项的综合验收：** 选一个收藏或学习记录的小功能，拿出模型说明、正常查询结果、一个失败反例和对应修正理由。可以引用已经做过的实操，不必重做整套题。明确“运行已观察到的结果”和“尚待产品实现验证的方案”，再进入 HTTP / Go 的请求与事务边界练习。

<a id="queries"></a>

## 选读：子查询、CTE 与窗口函数

对应[选读资料](README.md#advanced)，可以在第 4 单元后穿插。

文件：[题目 Q17～Q24](exercises/all.sql) · [参考答案](solutions/all.sql)。

| 题号 | 操作 | 观察重点 |
| --- | --- | --- |
| Q17～Q19 | 标量子查询、存在与不存在 | 内层返回的是一个值、一组行，还是存在性？ |
| Q20 | 分步骤统计后再比较 | 用户总时长的平均数与单次会话平均时长是否混淆？ |
| Q21～Q23 | 最近一条、并列排名与累计 | 分区范围、并列排序、排名差异与窗口边界 |
| Q24 | 学习概览 | 零记录用户、统计口径、JOIN 重复累计与最近会话 |

Q24 可直接对照答案阅读。将每个 CTE 单独作为查询运行，先确认中间结果的一行代表什么，再看最后如何关联。固定时间范围及预期输出以题目和 [expected.json](expected.json) 为准。

<a id="check"></a>

## 保存与检查自己的答案

想核对自己的答案时：

1. 按[章节导读](README.md)与上方统一索引选择练习。
2. 回到本地题目，阅读一题及参考答案，在 TablePlus 运行，核对题目要求和 `expected.json` 对应 Q 编号的预期结果。外部教程使用的表可能不同，不直接粘贴到本地四表上运行。
3. 用平时编辑代码或 Markdown 的编辑器打开 [exercises/all.sql](exercises/all.sql)。在对应 Q 编号下填写自己的答案并保存。
4. 把这道答案复制到 TablePlus，运行并检查结果。遇到错误先看列名、表名和提示位置。
5. 保存已作答的题目，未作答的题保留 TODO；在终端执行：

```sh
cd /Users/yuyang/Projects/prompts/sql-learning
python3 lab.py check exercises/all.sql
```

检查器跳过未作答题，只核对已填写的答案；例如只填写 Q01 时应为 `1/1 道已作答题通过`，全做完为 `32/32`。完全未填写会提示“尚未作答”。Q06～Q08 依赖同一条数据，必须一起填写；Q32 可独立填写。`python3 lab.py test` 检查的是完整参考答案。自动检查证明固定数据下的结果一致，理解能力仍通过解释查询来判断。

| 操作 | 改变什么 |
| --- | --- |
| 在编辑器保存 `.sql` 文件 | 保存答案文本，尚未执行到数据库 |
| 在 TablePlus 执行 SELECT | 查询数据，不修改记录 |
| 在 TablePlus 执行增删改 | 默认可直接提交修改；本地增删改实操用 BEGIN / ROLLBACK 包住演示 |
| `lab.py sql / check / test` | 使用当前连接中的临时表，结束后回滚；不重置 TablePlus 的持久化练习表 |

命令行检查要求每题只输出一张结果表，列名和排序与题目一致，保留统一列表完整 Q01～Q32 编号，不重复或调整顺序。在 TODO 下填写 SQL 即可，未作答位置只保留注释。练习文件不加入 `BEGIN / COMMIT / ROLLBACK`、psql 专用命令或 `public.` 表名前缀，因为运行器已经管理了事务和临时表。带事务的跟做实验，在 TablePlus 中单独执行，不整段放入练习答案。

完整参考答案检查为 `python3 lab.py test`，预期 `32/32 道已作答题通过`，且初始数据完整性通过。检查器会确认 Q08、Q32 清理完成后，四张表与运行前的初始数据一致。

[transactions.sql](transactions.sql) 和 [model.sql](model.sql) 自己管理事务，按本页第 3 单元的命令独立运行，不通过 lab.py sql / check 包装。
