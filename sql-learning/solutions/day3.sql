-- Q17 标量子查询
SELECT id, duration_minutes FROM learning_sessions
WHERE status = 'completed'
  AND duration_minutes > (
      SELECT AVG(duration_minutes) FROM learning_sessions WHERE status = 'completed'
  )
ORDER BY id;

-- Q18 NOT EXISTS
SELECT u.id AS user_id, u.name FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM learning_sessions s WHERE s.user_id = u.id AND s.status = 'completed'
)
ORDER BY u.id;

-- Q19 未作答的单词
-- NOT EXISTS 判断是否有匹配行，避免 NOT IN 子查询含 NULL 时的陷阱。
SELECT w.id AS word_id, w.term FROM words w
WHERE NOT EXISTS (SELECT 1 FROM word_reviews r WHERE r.word_id = w.id)
ORDER BY w.id;

-- Q20 CTE
WITH totals AS (
    SELECT user_id, SUM(duration_minutes) AS total_minutes
    FROM learning_sessions WHERE status = 'completed' GROUP BY user_id
)
SELECT user_id, total_minutes FROM totals
WHERE total_minutes > (SELECT AVG(total_minutes) FROM totals)
ORDER BY user_id;

-- Q21 ROW_NUMBER：最近一次完成
WITH ranked AS (
    SELECT user_id, id AS session_id,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY started_at DESC, id DESC) AS rn
    FROM learning_sessions WHERE status = 'completed'
)
SELECT user_id, session_id FROM ranked WHERE rn = 1 ORDER BY user_id;

-- Q22 DENSE_RANK：并列排名
WITH totals AS (
    SELECT user_id, SUM(duration_minutes) AS total_minutes
    FROM learning_sessions WHERE status = 'completed' GROUP BY user_id
)
SELECT user_id, total_minutes,
       DENSE_RANK() OVER (ORDER BY total_minutes DESC) AS learning_rank
FROM totals
ORDER BY learning_rank, user_id;

-- Q23 累计窗口
SELECT user_id, id AS session_id,
       SUM(duration_minutes) OVER (
           PARTITION BY user_id ORDER BY started_at, id
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_minutes
FROM learning_sessions WHERE status = 'completed'
ORDER BY user_id, started_at, id;

-- Q24 综合验收：学习概览
-- 分开聚合会话和作答，避免在作答粒度上重复累计会话时长。
WITH scoped_sessions AS (
    SELECT * FROM learning_sessions
    WHERE status = 'completed'
      AND started_at >= TIMESTAMPTZ '2026-09-02 00:00:00+00'
      AND started_at < TIMESTAMPTZ '2026-09-05 00:00:00+00'
), session_totals AS (
    SELECT user_id, COUNT(*) AS completed_sessions, SUM(duration_minutes) AS total_minutes
    FROM scoped_sessions GROUP BY user_id
), review_totals AS (
    SELECT s.user_id, COUNT(DISTINCT r.word_id) AS reviewed_words,
           ROUND(100.0 * SUM(CASE WHEN r.is_correct THEN 1 ELSE 0 END)
                 / NULLIF(COUNT(r.id), 0), 2) AS accuracy_pct
    FROM scoped_sessions s JOIN word_reviews r ON r.session_id = s.id
    GROUP BY s.user_id
), latest AS (
    SELECT user_id, id AS session_id,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY started_at DESC, id DESC) AS rn
    FROM scoped_sessions
)
SELECT u.id AS user_id, u.name,
       COALESCE(s.completed_sessions, 0) AS completed_sessions,
       COALESCE(s.total_minutes, 0) AS total_minutes,
       COALESCE(r.reviewed_words, 0) AS reviewed_words,
       r.accuracy_pct, l.session_id AS latest_session_id
FROM users u
LEFT JOIN session_totals s ON s.user_id = u.id
LEFT JOIN review_totals r ON r.user_id = u.id
LEFT JOIN latest l ON l.user_id = u.id AND l.rn = 1
ORDER BY u.id;
