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
