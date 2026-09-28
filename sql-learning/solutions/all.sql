-- SQL 统一参考答案；执行 python3 lab.py test 检查全部答案。

-- Q01 单词列表
SELECT id, term, level FROM words ORDER BY id;

-- Q02 条件组合
SELECT id, term FROM words
WHERE level = 'A1' AND term ILIKE '%a%'
ORDER BY id;

-- Q03 NULL
-- NULL 表示未知/缺失；不能写 example = NULL。
SELECT id, term FROM words WHERE example IS NULL ORDER BY id;

-- Q04 排序与 LIMIT
-- 相同时补上唯一 ID，才能确定返回哪三条及其顺序。
SELECT id, duration_minutes FROM learning_sessions
WHERE status = 'completed'
ORDER BY duration_minutes DESC, id ASC
LIMIT 3;

-- Q05 去重
SELECT DISTINCT level FROM words ORDER BY level;

-- Q06 INSERT
INSERT INTO words (id, term, level, example)
VALUES (99, 'focus', 'B1', NULL)
RETURNING id, term, level;

-- Q07 UPDATE
-- 写 UPDATE / DELETE 前，先用相同 WHERE 做 SELECT 确认范围。
UPDATE words SET example = 'I focus on learning.'
WHERE id = 99
RETURNING id, example;

-- Q08 DELETE
DELETE FROM words WHERE id = 99 RETURNING id, term;

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

-- Q25 IN、AND / OR 与括号
SELECT id, term FROM words
WHERE level IN ('A1', 'A2') AND (example IS NULL OR term LIKE 's%')
ORDER BY id;

-- Q26 BETWEEN 的边界
SELECT id, duration_minutes FROM learning_sessions
WHERE status = 'completed' AND duration_minutes BETWEEN 15 AND 20
ORDER BY id;

-- Q27 时间范围与时区
SELECT id FROM learning_sessions
WHERE status = 'completed'
  AND started_at >= TIMESTAMPTZ '2026-09-02 09:00:00+00'
  AND started_at < TIMESTAMPTZ '2026-09-04 09:00:00+00'
ORDER BY id;

-- Q28 MIN / MAX 与零记录
SELECT u.id AS user_id, MIN(s.duration_minutes) AS min_minutes,
       MAX(s.duration_minutes) AS max_minutes
FROM users u
LEFT JOIN learning_sessions s ON s.user_id = u.id AND s.status = 'completed'
GROUP BY u.id
ORDER BY u.id;

-- Q29 NOT IN 与 NULL
-- NOT IN 不会把未知值当成符合条件；显式列出未评分分支。
SELECT id, rating FROM learning_sessions
WHERE status = 'completed' AND (rating NOT IN (4, 5) OR rating IS NULL)
ORDER BY id;

-- Q30 OFFSET 分页
SELECT id AS session_id FROM learning_sessions
WHERE status = 'completed'
ORDER BY started_at DESC, id DESC
LIMIT 3 OFFSET 3;

-- Q31 游标分页与并列时间
-- 游标包含排序中的两个字段，才能保留同一时刻的下一条记录。
SELECT id AS session_id FROM learning_sessions
WHERE status = 'completed'
  AND (started_at < TIMESTAMPTZ '2026-09-02 11:00:00+00'
       OR (started_at = TIMESTAMPTZ '2026-09-02 11:00:00+00' AND id < 8))
ORDER BY started_at DESC, id DESC
LIMIT 3;

-- Q32 批量 INSERT 与 Upsert
INSERT INTO words (id, term, level, example)
VALUES (99, 'focus', 'B1', NULL), (100, 'repeat', 'A2', NULL);

INSERT INTO words (id, term, level, example)
VALUES (99, 'focus', 'B1', 'I focus on learning.')
ON CONFLICT (term) DO UPDATE SET example = EXCLUDED.example;

INSERT INTO words (id, term, level, example)
VALUES (99, 'focus', 'B1', 'I focus on learning.')
ON CONFLICT (term) DO UPDATE SET example = EXCLUDED.example;

SELECT id, term, level, example FROM words WHERE id IN (99, 100) ORDER BY id;
DELETE FROM words WHERE id IN (99, 100);
