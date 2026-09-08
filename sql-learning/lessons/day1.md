# 第 1 天：从第一条查询到增删改

前置步骤：[主教程第 1～3 节](../README.md)。先完成 OrbStack、TablePlus 连接，确认四张表的行数，再开始本讲。

每节都按“读概念 → 跟做 → 对结果 → 自己写题”推进。SQL 在 TablePlus 的学习库执行；只将独立练习的答案保存到 [exercises/day1.sql](../exercises/day1.sql)。演示中的事务语句不要复制到答案文件。

## 1. 这一讲与练习怎么对应？

| 本讲内容 | 官方材料与阅读范围 | 跟做后自己完成 |
| --- | --- | --- |
| 表、列、类型 | [2.3 Creating a New Table](https://www.postgresql.org/docs/18/tutorial-table.html)：读开头的列定义 | 看懂 schema.sql；为 Q01～Q08 做准备 |
| SELECT、WHERE、排序、去重 | [2.5 Querying a Table](https://www.postgresql.org/docs/18/tutorial-select.html)：整节 | Q01、Q02、Q04、Q05 |
| 文本匹配 | [9.7.1 LIKE](https://www.postgresql.org/docs/18/functions-matching.html#FUNCTIONS-LIKE)：只读 %、_ 和 ILIKE | Q02 |
| 截取前几条 | [7.6 LIMIT and OFFSET](https://www.postgresql.org/docs/18/queries-limit.html)：先读 LIMIT 与排序的关系 | Q04 |
| NULL | [9.2 Comparison Functions and Operators](https://www.postgresql.org/docs/18/functions-comparison.html)：只查 IS NULL | Q03 |
| INSERT | [2.4 Populating a Table](https://www.postgresql.org/docs/18/tutorial-populate.html)：读 INSERT 示例 | Q06 |
| UPDATE、DELETE | [2.8 Updates](https://www.postgresql.org/docs/18/tutorial-update.html)、[2.9 Deletions](https://www.postgresql.org/docs/18/tutorial-delete.html)：各读一遍 | Q07、Q08 |
| RETURNING、事务 | [6.4 Returning Data](https://www.postgresql.org/docs/18/dml-returning.html)、[3.4 Transactions](https://www.postgresql.org/docs/18/tutorial-transactions.html)：读基本示例 | 观察实际写入，并练习回滚 |

外部文档使用自己的演示表。先理解它展示的语法，再在本讲的英语 App 数据上操作；不需要将文档中的演示数据库另装一遍。

## 2. 认识一张表，并亲手建一次临时表

先打开 [schema.sql](../schema.sql)，观察 `words` 的定义：`id` 是整数主键，`term` 是不允许缺失且不能重复的文本，`level` 是文本，`example` 是可缺失的文本。

| 类型或约束 | 意义 | 本次例子 |
| --- | --- | --- |
| integer | 整数 | ID、分钟数、评分 |
| text | 文本 | 单词、例句、用户名 |
| boolean | 真或假 | 是否回答正确 |
| timestamptz | 带时区语义的时间点 | 会话开始时间 |
| PRIMARY KEY | 不重复且非空的行标识 | 单词 ID |
| NOT NULL | 必须提供一个非 NULL 值 | 单词文本 |
| UNIQUE | 值不可重复 | 单词文本、用户邮箱 |
| REFERENCES | 指向另一张表中已有的标识 | 会话指向用户 |

在 TablePlus 的同一查询窗口，选中下面整段运行：

```sql
BEGIN;

CREATE TEMP TABLE sql_demo_words (
    id integer PRIMARY KEY,
    term text NOT NULL
);

INSERT INTO sql_demo_words (id, term)
VALUES (1, 'hello');

SELECT id, term FROM sql_demo_words;

ROLLBACK;
```

观察中间 SELECT 的结果：`1 | hello`。`CREATE TEMP TABLE` 建立临时表；INSERT 加一行；SELECT 读这一行；ROLLBACK 撤销这段事务中的建表和写入。本段不改变四张练习表。

你应该能回答：建数据库、建表、往表里插入一行分别是哪件事？一张空表为什么也有列定义？

## 3. SELECT：选择输出列

业务问题：我只想看用户 ID 和名字。

```sql
SELECT id, name
FROM users
ORDER BY id;
```

预期：`1 Lin`、`2 Mei`、`3 Chen`、`4 An`、`5 Yu`，共 5 行。

- `SELECT id, name`：输出这两列，逗号用于分隔。
- `FROM users`：数据来自 users 表。
- `ORDER BY id`：按 ID 从小到大显示。
- 最后的分号表示这条语句结束；换行主要为了易读。

把第一行改成 `SELECT id AS user_id, name`，观察结果列名变化。`AS` 给输出列起别名，不会修改表结构。

**现在做 Q01：** 把数据来源换成 words，按题目要求选择三列并排序。不要直接使用 `SELECT *`，先练习准确表达想要的列。

## 4. WHERE：选择需要的行

业务问题：查看 A2 等级且单词文本包含字母 r 的单词。

```sql
SELECT id, term, level
FROM words
WHERE level = 'A2'
  AND term ILIKE '%r%'
ORDER BY id;
```

预期：`6 travel`、`7 practice`、`12 review`。

逐步理解：

1. `level = 'A2'`：等级必须相等。文本写在单引号中，数字可以直接写。
2. `AND`：两个条件必须同时成立；`OR` 表示任一个成立。
3. `ILIKE`：PostgreSQL 中忽略大小写的文本匹配；`%` 表示任意长度的文本，`_` 表示一个字符。
4. `'%r%'`：r 前后可以有其他字符。将它改成 `'%R%'`，结果应保持一致。

常见条件：`=`、`<>`、`>`、`>=`、`<`、`<=`、`IN (...)`。组合 AND / OR 时，用括号写清分组。

**现在做 Q02：** 条件改成题目要求的 A1 和字母 a，先预测会出现哪些词，再执行。

## 5. NULL：缺失值怎么判断？

业务问题：哪些学习会话没有评分？

```sql
SELECT id, status, rating
FROM learning_sessions
WHERE rating IS NULL
ORDER BY id;
```

预期会话 ID：`4、6、9、10`。其中会话 6 已完成，但没有评分。

NULL 表示缺失或未知。它与数值 0、空字符串、false 的含义不同：没评分不能直接算成 0 分。

使用 `IS NULL` 判断缺失，使用 `IS NOT NULL` 判断有值。不要写 `rating = NULL`，普通等号无法完成这个判断。

**现在做 Q03：** 在 words 中找没有例句的单词。解释为什么过滤条件必须放在 example 列上。

## 6. ORDER BY 与 LIMIT：取哪几条？

业务问题：查看最近开始的三个会话。

```sql
SELECT id, user_id, started_at
FROM learning_sessions
ORDER BY started_at DESC, id DESC
LIMIT 3;
```

预期 ID 顺序：`10、9、4`。

- `ASC` 从小到大，`DESC` 从大到小；默认 ASC。
- 两个排序项按先后使用：先比较时间，时间相同时比较 ID。
- `LIMIT 3` 截取排序结果的前三条。
- 只有 LIMIT 没有排序，不能保证每次取到同样的三条。

**现在做 Q04：** 把业务目标改为“已完成、用时最长的三个”，并按题目处理相同时长的顺序。开始时间与时长是不同列。

## 7. DISTINCT：对输出结果去重

业务问题：会话有哪几种状态？

```sql
SELECT DISTINCT status
FROM learning_sessions
ORDER BY status;
```

预期两行：`abandoned`、`completed`。虽然会话表有 10 行，但这列只有两个不同值。

DISTINCT 按 SELECT 中的整组输出列去重。如果同时输出 ID 和状态，由于每个 ID 不同，就不会只剩两行。

**现在做 Q05：** 查看单词表中有哪些不同的等级。

## 8. INSERT / UPDATE / DELETE：跟着做一次完整修改

先读本讲第 1 节的 INSERT、UPDATE、DELETE、RETURNING 文档。下面在 **同一个 TablePlus 查询会话** 中逐段执行，最后回滚。

### 8.1 开始事务并新增一条记录

```sql
BEGIN;

INSERT INTO words (id, term, level, example)
VALUES (98, 'notice', 'B1', NULL)
RETURNING id, term, level, example;
```

预期返回新增的一行：ID 98、notice、B1，例句 NULL。括号里的列与 VALUES 中的值按顺序对应；RETURNING 展示实际新增的行。

### 8.2 修改前先检查范围

```sql
SELECT id, term, level, example
FROM words
WHERE id = 98;
```

应该只返回一行。确认条件后，执行修改：

```sql
UPDATE words
SET level = 'A2',
    example = 'I notice a new word.'
WHERE id = 98
RETURNING id, term, level, example;
```

预期仍是一行，但等级变为 A2，例句已更新。WHERE 决定修改范围；没有 WHERE 会尝试更新所有行。

### 8.3 删除刚才新增的行

```sql
DELETE FROM words
WHERE id = 98
RETURNING id, term;
```

预期返回 `98 | notice`。RETURNING 告诉你实际删除了哪一行。

### 8.4 回滚并确认

```sql
ROLLBACK;

SELECT id, term FROM words WHERE id = 98;
```

最终 SELECT 应返回 0 行。你已结束这段事务，练习库恢复到演示之前的状态。

COMMIT 会确认提交，ROLLBACK 会撤销当前事务中尚未提交的修改；默认自动提交时，已经完成的语句不能靠后来单独执行 ROLLBACK 撤销。这里的演示统一使用 ROLLBACK。

如果中途任何语句报错，先在同一个查询会话执行 ROLLBACK，再从 BEGIN 重新开始。不要跳到另一个连接继续一半的事务。

**现在做 Q06～Q08：** 使用题目指定的 ID 99 和 focus，完成新增、修改例句、删除。TablePlus 跟做时在外面包一层 BEGIN / ROLLBACK；答案文件仅保留三题本身的 SQL 和 RETURNING。

## 9. 检查、纠错与当日验收

保存自己的八题后，在工程目录的终端运行：

```sh
python3 lab.py check exercises/day1.sql
```

| 检查失败现象 | 先想什么 |
| --- | --- |
| 列名不一致 | 是否按题目使用别名，是否多输出了列 |
| 行顺序不同 | ORDER BY 是否正确，是否补全相同时的排序 |
| 多出或缺少单词 | WHERE 条件、AND / OR、ILIKE 模式是否正确 |
| 更新影响多行 | WHERE 是否只限定目标 ID |
| INSERT 失败 | 是否列和值不对应，或同一会话里重复插入了相同 ID / term |

验收时合上答案，解释：

- SELECT 和 WHERE 分别选择什么？
- NULL 为什么不能直接用等号判断？
- 为什么取前三条也需要确定相同时的排序？
- 什么决定 UPDATE / DELETE 影响几行？
- 保存 SQL 文件、执行 SQL、COMMIT 是哪三件事？

全部通过后进入 [第 2 天](day2.md)。卡住超过 10～15 分钟时，可以让 AI 只给一条提示；先尝试修改，再打开 [参考答案](../solutions/day1.sql)。
