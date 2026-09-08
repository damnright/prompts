-- 第二天：JOIN 与聚合。保留没有学习记录的用户，留意一对多关系。

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
