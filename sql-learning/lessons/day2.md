# 第 2 天：把多张表关联起来，再正确统计

前置：[第 1 天](day1.md) 已完成，TablePlus 连接学习库。今天最重要的习惯：**写查询前先说清楚，结果中的一行代表什么。**

## 1. 阅读与练习对应表

| 内容 | 官方材料与阅读范围 | 对应练习 |
| --- | --- | --- |
| INNER JOIN / LEFT JOIN | [2.6 Joins Between Tables](https://www.postgresql.org/docs/18/tutorial-join.html)：整节 | Q09、Q10 |
| 条件放在 ON 还是 WHERE | [7.2.1.1 Joined Tables](https://www.postgresql.org/docs/18/queries-table-expressions.html#QUERIES-JOIN)：找 LEFT JOIN 示例 | Q11 |
| GROUP BY / HAVING | [2.7 Aggregate Functions](https://www.postgresql.org/docs/18/tutorial-agg.html)：整节 | Q11、Q12 |
| COUNT / AVG 与 NULL | [9.21 Aggregate Functions](https://www.postgresql.org/docs/18/functions-aggregate.html)：只查 count、sum、avg | Q10、Q13、Q15 |
| CASE / COALESCE / NULLIF | [9.18 Conditional Expressions](https://www.postgresql.org/docs/18/functions-conditional.html)：对应三个小节 | Q11、Q14 |
| 一对多与重复统计 | 本讲第 9 节先观察明细，再读 [7.2.1.3 Subqueries](https://www.postgresql.org/docs/18/queries-table-expressions.html#QUERIES-SUBQUERIES) 的 FROM 子查询示例 | Q16 |

## 2. INNER JOIN：给学习会话补上用户名

会话表只有 `user_id`，用户名保存在 users 中。先从两张表各查一次：

```sql
SELECT id, name FROM users WHERE id = 2;

SELECT id, user_id, duration_minutes
FROM learning_sessions
WHERE user_id = 2
ORDER BY id;
```

第一条返回 Mei；第二条返回会话 5、6，分钟数分别为 20、25。现在用 JOIN 一次完成：

```sql
SELECT s.id AS session_id, u.name, s.duration_minutes
FROM learning_sessions AS s
JOIN users AS u ON u.id = s.user_id
WHERE s.user_id = 2
ORDER BY s.id;
```

| session_id | name | duration_minutes |
| --- | --- | --- |
| 5 | Mei | 20 |
| 6 | Mei | 25 |

`s` 和 `u` 是表别名，`s.id` 明确表示会话表的 ID。`ON u.id = s.user_id` 是两表配对的条件。这里一行仍代表一次会话，用户名只是补充进来的信息。

JOIN 默认是 INNER JOIN，只保留匹配行。**做 Q09：** 查所有已完成会话，补上用户名；不要只查 Mei。

## 3. LEFT JOIN：没学过的用户也要显示

业务问题：查看 An 有没有会话。

```sql
SELECT u.id AS user_id, u.name, s.id AS session_id
FROM users AS u
LEFT JOIN learning_sessions AS s ON s.user_id = u.id
WHERE u.id = 4;
```

预期仍有一行：`4 | An | NULL`。LEFT JOIN 保留左边的用户；右边没有匹配会话时，用 NULL 补上会话字段。

现在用计数观察差异：

```sql
SELECT u.id AS user_id,
       COUNT(*) AS joined_rows,
       COUNT(s.id) AS actual_sessions
FROM users AS u
LEFT JOIN learning_sessions AS s ON s.user_id = u.id
WHERE u.id = 4
GROUP BY u.id;
```

预期 `user_id=4, joined_rows=1, actual_sessions=0`。

- `COUNT(*)` 数连接后的行，补出来的那行也会被计入。
- `COUNT(s.id)` 只数非 NULL 的会话 ID，所以正确地得到 0。
- `GROUP BY u.id` 把同一用户的行归在一组，输出每个用户的计数。

**做 Q10：** 统计全部五个用户的会话数，确保 An 是 0。

## 4. GROUP BY、SUM、COALESCE：每个用户学了多久？

先只考虑有已完成会话的用户：

```sql
SELECT user_id,
       COUNT(*) AS completed_sessions,
       SUM(duration_minutes) AS total_minutes
FROM learning_sessions
WHERE status = 'completed'
GROUP BY user_id
ORDER BY user_id;
```

预期：Lin 对应 `1 | 3 | 45`，Mei 对应 `2 | 2 | 45`，Chen 对应 `3 | 2 | 30`。输入一行代表会话，分组后输出一行代表用户。

如果要包含 An 和 Yu，就从 users 出发 LEFT JOIN。比较下面两种条件位置：

```sql
SELECT u.id AS user_id, COUNT(s.id) AS completed_sessions
FROM users AS u
LEFT JOIN learning_sessions AS s ON s.user_id = u.id
WHERE s.status = 'completed'
GROUP BY u.id
ORDER BY u.id;
```

这条仍只返回 3 个用户，因为 WHERE 把没有匹配完成会话的行过滤掉了。将完成条件放进 ON：

```sql
SELECT u.id AS user_id,
       COUNT(s.id) AS completed_sessions,
       COALESCE(SUM(s.duration_minutes), 0) AS total_minutes
FROM users AS u
LEFT JOIN learning_sessions AS s
  ON s.user_id = u.id AND s.status = 'completed'
GROUP BY u.id
ORDER BY u.id;
```

这次应有 5 行，An 和 Yu 的计数、分钟数都为 0。`SUM` 没有可累计的非 NULL 值时返回 NULL，`COALESCE(值, 0)` 在值为 NULL 时改用 0，符合“没有完成会话，累计完成时长为零”的业务含义。

**做 Q11：** 合上示例，自己重写一次，并解释为什么 ON 中的完成条件不能随意挪到 WHERE。

## 5. HAVING：筛选统计后的分组

业务问题：找出至少完成 3 次会话的用户。

```sql
SELECT user_id, COUNT(*) AS completed_sessions
FROM learning_sessions
WHERE status = 'completed'
GROUP BY user_id
HAVING COUNT(*) >= 3
ORDER BY user_id;
```

预期只有 `1 | 3`。

按下面的顺序理解：先从会话表取行 → WHERE 只留下已完成 → 按用户分组 → 每组计数 → HAVING 只留下数量达标的组。这是理解语义的顺序，不代表数据库实际执行计划必须按此机械执行。

**做 Q12：** 将“次数门槛”换成题目的“总分钟数门槛”。WHERE 用于原始行条件，HAVING 用于分组后的统计条件。

## 6. COUNT DISTINCT：次数、人次、词数不同

业务问题：book 被回答过几次，涉及多少用户？

```sql
SELECT w.term,
       COUNT(r.id) AS review_count,
       COUNT(DISTINCT s.user_id) AS learner_count
FROM words AS w
JOIN word_reviews AS r ON r.word_id = w.id
JOIN learning_sessions AS s ON s.id = r.session_id
WHERE w.id = 2
GROUP BY w.term;
```

预期 `book | 5 | 2`。同一个用户可以多次回答同一个词，所以作答记录数不能当成用户数。

表之间的路径是 `words → word_reviews → learning_sessions`；最后一张表才提供 user_id。COUNT DISTINCT 按用户 ID 去重。

**做 Q13：** 扩展到全部单词，并保留没有作答记录的 listen 和 review。思考该在哪些位置使用 LEFT JOIN。

## 7. CASE、NULLIF、ROUND：正确率怎么计算？

先把真假转换成可累计的数值：

```sql
SELECT id, is_correct,
       CASE WHEN is_correct THEN 1 ELSE 0 END AS correct_value
FROM word_reviews
WHERE session_id = 5
ORDER BY id;
```

会话 5 的三次作答依次是正确、错误、错误，转换后为 `1、0、0`。CASE 在条件成立时返回 THEN 的值，否则返回 ELSE 的值。

先体验整数除法：

```sql
SELECT 1 / 2 AS integer_result,
       1.0 / 2 AS decimal_result;
```

预期分别是 0 和 0.5。因此计算正确率时要保留小数。下面只计算 Mei 的已完成会话：

```sql
SELECT COUNT(r.id) AS attempts,
       SUM(CASE WHEN r.is_correct THEN 1 ELSE 0 END) AS correct_attempts,
       ROUND(
           100.0 * SUM(CASE WHEN r.is_correct THEN 1 ELSE 0 END)
           / NULLIF(COUNT(r.id), 0),
           2
       ) AS accuracy_pct
FROM learning_sessions AS s
JOIN word_reviews AS r ON r.session_id = s.id
WHERE s.user_id = 2 AND s.status = 'completed';
```

预期：5 次作答、2 次正确、`40.00`。`NULLIF(数量, 0)` 在数量为 0 时返回 NULL，避免除零；`ROUND(..., 2)` 保留两位小数。

**做 Q14：** 扩展到所有用户。没有作答时次数为 0、正确率为 NULL；0% 则表示确实作答过但全错，两者含义不同。

## 8. AVG 与 NULL：没有评分怎么平均？

```sql
SELECT COUNT(*) AS all_sessions,
       COUNT(rating) AS rated_sessions,
       ROUND(AVG(rating), 2) AS average_rating
FROM learning_sessions;
```

预期 `10 | 6 | 4.17`。10 个会话里只有 6 个评分，AVG 使用这 6 个非 NULL 评分；把缺失评分填成 0 再平均会改变问题。

**做 Q15：** 只统计已完成会话。预期会话总数变成 7，有评分数量仍是 6，平均评分仍是 4.17。解释为什么这两个平均值恰好一样。

## 9. 一对多 JOIN：为什么 45 分钟可能算成 120？

先看 Lin 的一个会话在连接作答记录后变成几行：

```sql
SELECT s.id AS session_id, s.duration_minutes, r.id AS review_id
FROM learning_sessions AS s
JOIN word_reviews AS r ON r.session_id = s.id
WHERE s.id = 1
ORDER BY r.id;
```

预期有 3 行，三行的时长都是 10，因为同一个会话有 3 次作答。如果现在 SUM 时长，就会把这次 10 分钟算成 30 分钟。

下面这条 SQL 能运行，但统计口径错误：

```sql
SELECT SUM(s.duration_minutes) AS duplicated_minutes
FROM learning_sessions AS s
JOIN word_reviews AS r ON r.session_id = s.id
WHERE s.user_id = 1 AND s.status = 'completed';
```

结果是 120，而 Lin 真实总时长是 `10 + 20 + 15 = 45`。错误来自“一行已经变成一次作答，却还把时长当成一次会话来加”。

修复前，先把作答压成每会话一行：

```sql
SELECT session_id, COUNT(*) AS review_count
FROM word_reviews
GROUP BY session_id
ORDER BY session_id;
```

再把这个中间结果连接到会话表：

```sql
SELECT s.id AS session_id, s.duration_minutes, r.review_count
FROM learning_sessions AS s
LEFT JOIN (
    SELECT session_id, COUNT(*) AS review_count
    FROM word_reviews
    GROUP BY session_id
) AS r ON r.session_id = s.id
WHERE s.user_id = 1 AND s.status = 'completed'
ORDER BY s.id;
```

预期三行：`1 | 10 | 3`、`2 | 20 | 3`、`3 | 15 | 2`。现在每个会话只出现一次，可以再按用户累计。

括号里的 SELECT 作为一张临时的查询结果表参与 JOIN，这种写法叫子查询，明天继续系统学习。今天先理解：**统计时长前，要保证每个会话只被累计一次。**

不要改成 `SUM(DISTINCT duration_minutes)`：Chen 有两次不同的会话都长 15 分钟，按时长去重会误算为 15，而实际是 30。

**做 Q16：** 结合用户表，输出每个用户的完成会话数、作答数、总时长，同时保留没有完成会话的用户。

## 10. 当日检查

```sh
python3 lab.py check exercises/day2.sql
```

检查通过后，不看 SQL，解释下面五件事：

- 一次会话为什么会在连接后出现多行？
- COUNT(*)、COUNT(s.id)、COUNT(DISTINCT user_id) 分别在数什么？
- 为什么 LEFT JOIN 后写 WHERE 可能把 An 丢掉？
- 正确率为什么需要小数和 NULLIF？
- 为什么按分钟数 DISTINCT 不能修复重复累计？

先手算 Lin 的 45 分钟、Mei 的 40% 正确率，再用查询验证。需要时对照 [参考答案](../solutions/day2.sql)，完成后进入 [第 3 天](day3.md)。
