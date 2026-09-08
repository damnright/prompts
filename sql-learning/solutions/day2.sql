-- Q09 INNER JOIN
SELECT s.id AS session_id, u.name, s.duration_minutes
FROM learning_sessions s JOIN users u ON u.id = s.user_id
WHERE s.status = 'completed'
ORDER BY s.id;

-- Q10 LEFT JOIN 与 COUNT
-- COUNT(*) 会把 LEFT JOIN 补出的行也算上；COUNT(s.id) 忽略 NULL。
SELECT u.id AS user_id, u.name, COUNT(s.id) AS session_count
FROM users u LEFT JOIN learning_sessions s ON s.user_id = u.id
GROUP BY u.id, u.name
ORDER BY u.id;

-- Q11 条件位置与 SUM
-- completed 放在 ON 中；放到 WHERE 会丢失没有已完成会话的用户。
SELECT u.id AS user_id, COUNT(s.id) AS completed_sessions,
       COALESCE(SUM(s.duration_minutes), 0) AS total_minutes
FROM users u
LEFT JOIN learning_sessions s ON s.user_id = u.id AND s.status = 'completed'
GROUP BY u.id
ORDER BY u.id;

-- Q12 HAVING
SELECT user_id, SUM(duration_minutes) AS total_minutes
FROM learning_sessions
WHERE status = 'completed'
GROUP BY user_id
HAVING SUM(duration_minutes) >= 40
ORDER BY user_id;

-- Q13 COUNT DISTINCT
SELECT w.id AS word_id, COUNT(r.id) AS review_count,
       COUNT(DISTINCT s.user_id) AS learner_count
FROM words w
LEFT JOIN word_reviews r ON r.word_id = w.id
LEFT JOIN learning_sessions s ON s.id = r.session_id
GROUP BY w.id
ORDER BY w.id;

-- Q14 CASE 与正确率
-- 100.0 保留小数计算；无作答时的正确率不是 0%，而是未知。
SELECT u.id AS user_id, COUNT(r.id) AS attempts,
       SUM(CASE WHEN r.is_correct THEN 1 ELSE 0 END) AS correct_attempts,
       ROUND(100.0 * SUM(CASE WHEN r.is_correct THEN 1 ELSE 0 END)
             / NULLIF(COUNT(r.id), 0), 2) AS accuracy_pct
FROM users u
LEFT JOIN learning_sessions s ON s.user_id = u.id AND s.status = 'completed'
LEFT JOIN word_reviews r ON r.session_id = s.id
GROUP BY u.id
ORDER BY u.id;

-- Q15 NULL 对聚合的影响
-- AVG 忽略 NULL；把未评分写成 0 会改变业务含义。
SELECT COUNT(*) AS completed_sessions, COUNT(rating) AS rated_sessions,
       ROUND(AVG(rating), 2) AS average_rating
FROM learning_sessions WHERE status = 'completed';

-- Q16 修复重复累计
-- 每个会话先压成一行，再累计；SUM(DISTINCT duration_minutes) 也不对，
-- 因为 Chen 有两个不重复的会话，时长恰好都是 15 分钟。
WITH review_counts AS (
    SELECT session_id, COUNT(*) AS review_count
    FROM word_reviews GROUP BY session_id
)
SELECT u.id AS user_id, COUNT(s.id) AS completed_sessions,
       COALESCE(SUM(r.review_count), 0) AS review_count,
       COALESCE(SUM(s.duration_minutes), 0) AS total_minutes
FROM users u
LEFT JOIN learning_sessions s ON s.user_id = u.id AND s.status = 'completed'
LEFT JOIN review_counts r ON r.session_id = s.id
GROUP BY u.id
ORDER BY u.id;
