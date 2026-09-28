-- SQL 统一练习列表：保留 Q 编号，在 TODO 下填写答案；可以按阅读进度选做。
-- 输出列名与排序按题目要求；执行 python3 lab.py check exercises/all.sql 检查已作答题。
-- 作答依赖：Q06～Q08 必须一起作答并依次执行；Q32 自带清理。命令行每次加载初始临时数据。
-- 事务、约束、索引、并发与迁移实验见 practice.md。

-- Q01 单词列表
-- 查出全部单词，输出 id, term, level，按 id 升序。应有 12 行。
-- TODO

-- Q02 条件组合
-- 查 A1 且 term 包含字母 a 的单词，忽略大小写。
-- 输出 id, term，按 id 升序。应有 apple、water、learn。
-- TODO

-- Q03 NULL
-- 查没有例句的单词，输出 id, term，按 id 升序。应有 3 行。
-- TODO

-- Q04 排序与 LIMIT
-- 查已完成且用时最长的 3 个会话，用时相同时 id 较小的排前面。
-- 输出 id, duration_minutes。预期 id 顺序为 6、2、5。
-- TODO

-- Q05 去重
-- 查所有不同的单词等级，输出 level，按 level 升序。应有 3 行。
-- TODO

-- Q06 INSERT
-- 新建单词：id=99，term='focus'，level='B1'，example=NULL。
-- 使用 RETURNING 输出 id, term, level。
-- TODO

-- Q07 UPDATE
-- 将 id=99 的例句改为 'I focus on learning.'。
-- 使用 RETURNING 输出 id, example；必须只更新目标行。
-- TODO

-- Q08 DELETE
-- 删除 id=99 的单词，使用 RETURNING 输出 id, term；必须只删除目标行。
-- TODO

-- Q09 INNER JOIN
-- 查所有已完成会话及用户名，输出 session_id, name, duration_minutes。
-- 按 session_id 升序，应有 7 行。
-- TODO

-- Q10 LEFT JOIN 与 COUNT
-- 统计每个用户的全部会话数（包括 abandoned 和零会话用户）。
-- 输出 user_id, name, session_count，按 user_id 升序。An 的数量必须为 0。
-- TODO

-- Q11 条件位置与 SUM
-- 统计每个用户的已完成会话数和总分钟数，仍保留零完成用户。
-- 输出 user_id, completed_sessions, total_minutes，按 user_id 升序；空计数/分钟均为 0。
-- TODO

-- Q12 HAVING
-- 查已完成会话累计至少 40 分钟的用户。
-- 输出 user_id, total_minutes，按 user_id 升序。Lin 和 Mei 均为 45 分钟。
-- TODO

-- Q13 COUNT DISTINCT
-- 统计每个单词的作答次数和作答用户数，包括从未作答的单词。
-- 输出 word_id, review_count, learner_count，按 word_id 升序。
-- book 有 5 次作答、2 个用户，不能把 5 次当成 5 人。
-- TODO

-- Q14 CASE 与正确率
-- 统计所有用户在已完成会话中的作答次数、正确次数、正确率百分数（两位小数）。
-- 输出 user_id, attempts, correct_attempts, accuracy_pct，按 user_id 升序。
-- 无作答者次数为 0、正确率为 NULL；Lin 是 75.00。使用 NULLIF 避免除零。
-- TODO

-- Q15 NULL 对聚合的影响
-- 统计已完成会话数、有评分的会话数、平均评分（两位小数）。
-- 输出 completed_sessions, rated_sessions, average_rating。预期 7、6、4.17。
-- TODO

-- Q16 修复重复累计
-- 按用户输出 user_id, completed_sessions, review_count, total_minutes，按 user_id 升序。
-- 只统计已完成会话，保留所有用户，空计数和分钟均为 0。
-- 直接连接 sessions 和 reviews 再 SUM(duration_minutes) 会重复累计分钟数。
-- 先把作答按 session_id 聚合，再连接会话。Lin 应为 3、8、45，不能是 120 分钟。
-- TODO

-- Q17 标量子查询
-- 查时长超过所有已完成会话平均时长的已完成会话。
-- 输出 id, duration_minutes，按 id 升序。应有 3 行。
-- TODO

-- Q18 NOT EXISTS
-- 查从未完成过会话的用户，输出 user_id, name，按 user_id 升序。
-- An 没有会话，Yu 只有 abandoned，会同时出现在结果里。
-- TODO

-- Q19 未作答的单词
-- 使用 NOT EXISTS 查没有任何作答记录的单词。
-- 输出 word_id, term，按 word_id 升序。应有 listen、review。
-- TODO

-- Q20 CTE
-- 先算每个有已完成会话用户的总分钟数，再找超过这些用户平均总分钟数的人。
-- 输出 user_id, total_minutes，按 user_id 升序。均值只含 Lin、Mei、Chen，应为 40。
-- TODO

-- Q21 ROW_NUMBER：最近一次完成
-- 查询每个有已完成会话用户的最近一次已完成会话。
-- started_at 相同时取 id 较大的；输出 user_id, session_id，按 user_id 升序。
-- Chen 的会话 7 和 8 同时开始，必须选 8。用子查询或 CTE 过滤窗口函数结果。
-- TODO

-- Q22 DENSE_RANK：并列排名
-- 按用户的已完成会话总分钟数降序排名，仅含有已完成会话的用户。
-- 输出 user_id, total_minutes, learning_rank，按 learning_rank、user_id 升序。
-- Lin、Mei 并列第 1，Chen 第 2；思考改为 RANK / ROW_NUMBER 后的区别。
-- TODO

-- Q23 累计窗口
-- 每个用户的已完成会话按 started_at、id 升序，计算截至当前会话的累计分钟数。
-- 输出 user_id, session_id, running_minutes，按 user_id、started_at、id 升序。
-- 显式写 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW；Chen 的结果为 15、30。
-- TODO

-- Q24 综合验收：学习概览
-- 统计 UTC 时间 [2026-09-02 00:00, 2026-09-05 00:00) 开始的已完成会话。
-- 每个用户一行，保留全部 5 位用户，按 user_id 升序。
-- 输出 user_id, name, completed_sessions, total_minutes, reviewed_words,
--      accuracy_pct, latest_session_id。
-- reviewed_words 是期间作答的不同单词数；accuracy_pct 是正确次数 / 作答次数 * 100，保留两位小数。
-- 零记录用户的计数和分钟为 0，正确率、最近会话为 NULL。
-- 最近会话按 started_at DESC、id DESC 选取；避免多表 JOIN 重复累计时长。
-- Lin：2 次、35 分钟、4 词、80.00%、最近会话 3。
-- 先写清统计口径，再组合 CTE / JOIN / 窗口函数；本题可选，重点是解释统计口径与查询结构。
-- TODO

-- Q25 IN、AND / OR 与括号
-- 查等级属于 A1、A2，且“例句缺失或 term 以 s 开头”的单词。
-- 输出 id, term，按 id 升序；应为 learn、speak、review。
-- 使用 IN 与括号组合条件；去掉括号后，观察 B1 的 schedule 是否被混入。
-- TODO

-- Q26 BETWEEN 的边界
-- 查已完成且用时在 15～20 分钟之间的会话，包含两个端点。
-- 输出 id, duration_minutes，按 id 升序；应有 5 行。
-- 用 BETWEEN，并用 >= / <= 改写核对；不要混入 abandoned 会话。
-- TODO

-- Q27 时间范围与时区
-- 查 UTC 时间 [2026-09-02 09:00, 2026-09-04 09:00) 开始的已完成会话。
-- 使用带 +00 偏移的时间常量；输出 id，按 id 升序，应为 2、6、7、8。
-- 起点会话 2 应包含，终点会话 3 应排除；解释 BETWEEN 在这里为什么不合适。
-- TODO

-- Q28 MIN / MAX 与零记录
-- 按用户统计已完成会话的最短、最长分钟数，保留所有用户。
-- 输出 user_id, min_minutes, max_minutes，按 user_id 升序。
-- 无完成会话者两项均为 NULL，不能用 0 表示；Chen 的两项均为 15。
-- TODO

-- Q29 NOT IN 与 NULL
-- 查已完成会话中“评分既不是 4 也不是 5，或者尚未评分”的记录。
-- 输出 id, rating，按 id 升序；应为 (5, 3)、(6, NULL)。
-- 使用 NOT IN 加显式空值判断；思考只用 NOT IN (4, 5) 会漏掉谁，
-- 以及把 NULL 写进 NOT IN (4, 5, NULL) 为什么不能表达“包括未评分”。
-- TODO

-- Q30 OFFSET 分页
-- 全部已完成会话按 started_at DESC、id DESC 排序，每页 3 条，取第二页。
-- 输出 session_id，预期顺序为 7、2、5；使用 LIMIT / OFFSET。
-- 对照第一页 3、6、8，解释为什么必须补 id 排序。
-- TODO

-- Q31 游标分页与并列时间
-- 沿用 Q30 的范围与排序，上一页最后一行为 id=8、UTC 2026-09-02 11:00。
-- 用“时间更早，或时间相同但 id 更小”的条件取后续 3 条，不使用 OFFSET。
-- 输出 session_id，预期仍为 7、2、5；只比较时间会漏掉会话 7。
-- 思考两次翻页之间新增一条更晚的会话，对 OFFSET 与此游标分别有什么影响。
-- TODO

-- Q32 批量 INSERT 与 Upsert
-- 在同一题依次执行：①一次 INSERT 新建两词 (99, 'focus', 'B1', NULL)、
-- (100, 'repeat', 'A2', NULL)；②按 term 唯一键 Upsert 'focus'，
-- 冲突时只把 example 更新为 'I focus on learning.'，再原样重试一次；
-- ③查询 id IN (99, 100)，输出 id, term, level, example，按 id 升序，应只有两行；
-- ④删除本题新增的 99、100，恢复初始数据。
-- 本题只让步骤③输出结果，不给 INSERT / UPDATE / DELETE 添加 RETURNING。
-- TablePlus 中先确认两个 ID 与词条未被占用，用 BEGIN / ROLLBACK 包住整题；
-- 保存到本文件时不写事务命令。解释“重复请求没有多插一行”是否等于业务完整幂等。
-- TODO
