-- 第三天：子查询、CTE、窗口函数与综合验收。

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
-- 先写清统计口径，再组合 CTE / JOIN / 窗口函数；本题限时 45 分钟独立完成。
-- TODO
