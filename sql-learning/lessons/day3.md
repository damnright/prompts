# 第 3 天：组合查询，完成学习概览

前置：[第 2 天](day2.md) 已完成。今天把查询拆成可理解的小步骤，再组合成最近学习、排名和学习概览。

## 1. 阅读与练习对应表

| 内容 | 官方材料与阅读范围 | 对应练习 |
| --- | --- | --- |
| 标量子查询 | [4.2.11 Scalar Subqueries](https://www.postgresql.org/docs/18/sql-expressions.html#SQL-SYNTAX-SCALAR-SUBQUERIES)：读基本定义 | Q17 |
| EXISTS / NOT EXISTS | [9.24 Subquery Expressions](https://www.postgresql.org/docs/18/functions-subquery.html)：只读 EXISTS 和 NOT IN 的 NULL 说明 | Q18、Q19 |
| CTE | [7.8.1 SELECT in WITH](https://www.postgresql.org/docs/18/queries-with.html#QUERIES-WITH-SELECT)：读第一个示例；跳过递归 CTE | Q20 |
| 窗口函数 | [3.5 Window Functions](https://www.postgresql.org/docs/18/tutorial-window.html)：先读 OVER / PARTITION BY / ORDER BY 示例 | Q21、Q23 |
| 三种排名 | [9.22 Window Functions](https://www.postgresql.org/docs/18/functions-window.html)：只查 row_number、rank、dense_rank | Q22 |
| 综合查询 | 本讲第 8 节的拆解步骤 | Q24 |

## 2. 标量子查询：先得到一个值，再用它筛选

业务问题：找出时长最长的已完成会话，时长并列时全部保留。

第一步，求最长时间：

```sql
SELECT MAX(duration_minutes) AS max_minutes
FROM learning_sessions
WHERE status = 'completed';
```

预期 25。第二步，用这个结果筛选会话，避免手工把 25 写死：

```sql
SELECT id, duration_minutes
FROM learning_sessions
WHERE status = 'completed'
  AND duration_minutes = (
      SELECT MAX(duration_minutes)
      FROM learning_sessions
      WHERE status = 'completed'
  )
ORDER BY id;
```

预期 `6 | 25`。括号里的查询返回一行一列，作为一个值参与外层比较，这叫标量子查询。如果作为单个值使用的查询返回多行，就会报错。

**做 Q17：** 将“等于最大时长”变成“超过平均时长”，注意内层平均值和外层候选会话都只考虑 completed。

## 3. EXISTS / NOT EXISTS：查发生过与从未发生

业务问题：哪些用户至少有一次中途退出的会话？

```sql
SELECT u.id AS user_id, u.name
FROM users AS u
WHERE EXISTS (
    SELECT 1
    FROM learning_sessions AS s
    WHERE s.user_id = u.id AND s.status = 'abandoned'
)
ORDER BY u.id;
```

预期 `1 Lin`、`3 Chen`、`5 Yu`。

对外层的每个用户，内层检查有没有与其 ID 匹配的退出会话。`SELECT 1` 只是表示这里关心“存在一行”，并不需要读出那行的全部内容。由于内层引用了外层的 u.id，这也是一种关联子查询。

把 EXISTS 换成 NOT EXISTS，就表示没有任何符合条件的行。必须先定义“没有发生的是什么”：没有任何会话，与没有已完成会话，含义不同。

**做 Q18：** 找从未完成会话的用户；An 和 Yu 都应出现。**做 Q19：** 找没有任何作答记录的单词。

延伸理解：`NOT IN` 的子查询如果包含 NULL，可能使判断结果变成未知；表达“没有匹配记录”时，先掌握 NOT EXISTS 的写法。

## 4. CTE：给中间查询起名字

业务问题：找出至少完成三次会话的用户，并带上累计时长。

```sql
WITH user_totals AS (
    SELECT user_id,
           COUNT(*) AS completed_sessions,
           SUM(duration_minutes) AS total_minutes
    FROM learning_sessions
    WHERE status = 'completed'
    GROUP BY user_id
)
SELECT user_id, completed_sessions, total_minutes
FROM user_totals
WHERE completed_sessions >= 3
ORDER BY user_id;
```

预期 `1 | 3 | 45`。先把每个用户的统计结果命名为 user_totals，再从这个中间结果继续查。

WITH 创建的 CTE 只在当前这一条语句中可见，不会新建一张持久化表。名字可以帮助阅读，但不能据此认定它一定更快；优化留到后续 PostgreSQL 阶段。

**做 Q20：** 第一步得到三个活跃用户的累计时长 45、45、30；第二步求这三个值的平均数 40；第三步找大于 40 的用户。注意“用户总时长的平均数”与“单个会话时长的平均数”不同。

## 5. 窗口函数：保留明细，同时计算相关行

先观察普通聚合：

```sql
SELECT user_id, SUM(duration_minutes) AS total_minutes
FROM learning_sessions
WHERE status = 'completed'
GROUP BY user_id
ORDER BY user_id;
```

结果只有 3 行，一行一个用户。再运行窗口函数：

```sql
SELECT user_id, id AS session_id, duration_minutes,
       SUM(duration_minutes) OVER (PARTITION BY user_id) AS user_total_minutes
FROM learning_sessions
WHERE status = 'completed'
ORDER BY user_id, id;
```

结果保留 7 行，一行仍然是一次会话；Lin 的三行旁边都显示 45，Mei 的两行都显示 45，Chen 的两行都显示 30。

- `OVER (...)`：告诉数据库这是一个窗口计算。
- `PARTITION BY user_id`：每个用户自己的相关行构成一组窗口分区。
- GROUP BY 改变输出粒度，窗口函数在保留明细行的同时增加计算列。

这一节先不做新题，确保你能解释两条查询为什么分别是 3 行和 7 行。

### 5.1 ROW_NUMBER：给每个用户的会话排顺序

```sql
SELECT user_id, id AS session_id, started_at,
       ROW_NUMBER() OVER (
           PARTITION BY user_id
           ORDER BY started_at DESC, id DESC
       ) AS rn
FROM learning_sessions
WHERE status = 'completed'
ORDER BY user_id, rn;
```

先看 rn=1 的行：Lin 是会话 3，Mei 是会话 6，Chen 是会话 8。Chen 的 7、8 开始时间相同，用 ID 倒序明确选 8。

窗口计算发生在 WHERE 筛行之后，不能在同一层 WHERE 中直接筛 rn。下一步需要将这个查询放进 CTE 或子查询，再在外层写 `WHERE rn = 1`。

**做 Q21：** 只保留每个用户的最近一次已完成会话。

## 6. ROW_NUMBER、RANK、DENSE_RANK：并列怎么处理？

用用户累计时长同时观察三种排名：

```sql
WITH totals AS (
    SELECT user_id, SUM(duration_minutes) AS total_minutes
    FROM learning_sessions
    WHERE status = 'completed'
    GROUP BY user_id
)
SELECT user_id, total_minutes,
       ROW_NUMBER() OVER (ORDER BY total_minutes DESC, user_id) AS row_number_value,
       RANK() OVER (ORDER BY total_minutes DESC) AS rank_value,
       DENSE_RANK() OVER (ORDER BY total_minutes DESC) AS dense_rank_value
FROM totals
ORDER BY total_minutes DESC, user_id;
```

| user_id | total_minutes | row_number_value | rank_value | dense_rank_value |
| --- | --- | --- | --- | --- |
| 1 | 45 | 1 | 1 | 1 |
| 2 | 45 | 2 | 1 | 1 |
| 3 | 30 | 3 | 3 | 2 |

ROW_NUMBER 为每一行分配独立序号；RANK 允许并列，后面跳号；DENSE_RANK 允许并列，后面不跳号。

这里给 ROW_NUMBER 补 user_id，是为了明确两个 45 谁在前。RANK / DENSE_RANK 的窗口排序只放总时长，才能让时长相同者并列；最外层仍可按 user_id 排列显示。

**做 Q22：** 选择题目需要的排名函数，并解释为什么 Chen 的排名应为 2。

## 7. 累计窗口：截至当前会话，一共学了多久？

```sql
SELECT id AS session_id, duration_minutes,
       SUM(duration_minutes) OVER (
           ORDER BY started_at, id
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_minutes
FROM learning_sessions
WHERE user_id = 1 AND status = 'completed'
ORDER BY started_at, id;
```

预期：

| session_id | duration_minutes | running_minutes |
| --- | --- | --- |
| 1 | 10 | 10 |
| 2 | 20 | 30 |
| 3 | 15 | 45 |

窗口中的排序从早到晚排列会话；ROWS 子句明确使用从第一行到当前行的范围。每一行累计的范围不同，所以结果依次是 10、30、45。

上面的 WHERE 已限定一个用户。**做 Q23：** 扩展到所有用户，添加 PARTITION BY，保证每个人从自己的第一条记录重新累计。窗口里的排序决定计算顺序，最外层 ORDER BY 决定显示顺序，两者都要写清楚。

## 8. Q24 综合实操：做一个英语 App 学习概览

现在暂时关掉参考答案，计时 45 分钟。可以查语法，但先自己完成结构拆解。

### 8.1 先用中文写清查询需求

你要在一个页面上展示全部用户在指定时间段的学习情况。结果一行代表一个用户，字段为：

`user_id, name, completed_sessions, total_minutes, reviewed_words, accuracy_pct, latest_session_id`

口径必须一致：

- 区间为 UTC `[2026-09-02 00:00, 2026-09-05 00:00)`，以会话的 started_at 判断。
- 只统计 completed 会话。
- reviewed_words 是不同单词数量，accuracy_pct 使用作答次数为分母。
- 最近会话也是这个区间内的已完成会话，按开始时间和 ID 选择。
- 五位用户都要出现；零记录用户的计数为 0，正确率和最近会话为 NULL。

### 8.2 第一步：只筛会话，核对范围

```sql
SELECT id, user_id, duration_minutes
FROM learning_sessions
WHERE status = 'completed'
  AND started_at >= TIMESTAMPTZ '2026-09-02 00:00:00+00'
  AND started_at < TIMESTAMPTZ '2026-09-05 00:00:00+00'
ORDER BY id;
```

预期 ID：`2、3、6、7、8`。`+00` 明确表示 UTC。下界包含、上界不包含，下一段区间可以直接从上界开始，不会重复统计边界时刻。

后续每个统计分支都应从这个范围出发，避免“时长用区间内记录，正确率却用了全部历史”。

### 8.3 第二步：分别计算，不急着连成一张大表

| 中间结果 | 一行代表什么 | 从哪里计算 | 需要输出 |
| --- | --- | --- | --- |
| scoped_sessions | 一个范围内的已完成会话 | 第一步的会话筛选 | 后续要用的会话字段 |
| session_totals | 一个用户 | scoped_sessions | 完成次数、总分钟 |
| review_totals | 一个用户 | scoped_sessions 连接 word_reviews | 不同词数、正确率 |
| latest | 一个带序号的会话 | scoped_sessions | user_id、session_id、rn |

先单独运行每个中间查询，确认行数和结果。特别检查 session_totals 的时长计算不受作答记录数量影响。

### 8.4 第三步：以所有用户为基础连接结果

从 users 出发，用 LEFT JOIN 补上各个“每用户一行”的统计。最近会话只连接 rn=1 的行；必要时把这个条件放在 ON 中，保留零记录用户。

对完成次数、总分钟、词数使用 COALESCE 转成 0。正确率与最近会话保留 NULL。最后按 user_id 排序，检查结果恰好 5 行。

### 8.5 第四步：手算一个用户

Lin 在范围内有会话 2 和 3：

- 总时长：20 + 15 = 35 分钟。
- 作答：3 + 2 = 5 次，其中 4 次正确，正确率 80%。
- 不同单词 ID：1、2、4、5，共 4 个。
- 最近会话：3。

全部结果应为：

| user_id | name | completed_sessions | total_minutes | reviewed_words | accuracy_pct | latest_session_id |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Lin | 2 | 35 | 4 | 80.00 | 3 |
| 2 | Mei | 1 | 25 | 2 | 50.00 | 6 |
| 3 | Chen | 2 | 30 | 4 | 80.00 | 8 |
| 4 | An | 0 | 0 | 0 | NULL | NULL |
| 5 | Yu | 0 | 0 | 0 | NULL | NULL |

独立完成后再看 [参考答案 Q24](../solutions/day3.sql)。比较的是统计口径和查询结构，不要求写法逐字相同。

## 9. 三天总验收

保存答案，在工程目录的终端执行：

```sh
python3 lab.py check exercises/day1.sql
python3 lab.py check exercises/day2.sql
python3 lab.py check exercises/day3.sql
```

应分别通过 8 道题。随后完成下面的人工验收，自动检查只能证明固定数据下的结果一致：

- 不看答案，解释 Q24 的每个中间结果“一行代表什么”。
- 如果新增一个零学习记录的用户，是否仍会显示？为什么？
- 如果一个会话又多了一次作答，时长会不会随之变多？为什么？
- 如果两个会话同时开始，最近会话是否有确定的选择？
- 如果没有作答，正确率应该显示 NULL 还是 0？
- 第一天做过的增删改，如何限定范围并核实实际影响？

全部达到后，在 [技术路线](../../tech-list.md) 中勾选 SQL 基础，再继续 PostgreSQL 的表设计、事务、索引、锁和执行计划。未来 Go 后端会通过数据库驱动执行这些查询；你现在练习的是理解查询与判断结果的能力。
