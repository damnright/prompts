-- 独立连接执行整个文件；只使用当前连接的临时表。
-- 实验包含真实 COMMIT，不要通过 lab.py sql 包装执行。
CREATE TEMP TABLE tx_demo_points (
    id integer PRIMARY KEY,
    points integer NOT NULL CHECK (points >= 0)
);
INSERT INTO tx_demo_points VALUES (1, 100), (2, 100);

-- A：本事务内先看到 70 / 130，整体回滚后恢复为 100 / 100。
BEGIN;
UPDATE tx_demo_points SET points = points - 30 WHERE id = 1;
UPDATE tx_demo_points SET points = points + 30 WHERE id = 2;
SELECT 'A_before_rollback' AS stage, * FROM tx_demo_points ORDER BY id;
ROLLBACK;
SELECT 'A_after_rollback' AS stage, * FROM tx_demo_points ORDER BY id;
DO $$
BEGIN
    IF (SELECT array_agg(points ORDER BY id) FROM tx_demo_points) <> ARRAY[100, 100] THEN
        RAISE EXCEPTION 'rollback result mismatch';
    END IF;
END $$;

-- B：提交后保留 70 / 130。
BEGIN;
UPDATE tx_demo_points SET points = points - 30 WHERE id = 1;
UPDATE tx_demo_points SET points = points + 30 WHERE id = 2;
COMMIT;
SELECT 'B_after_commit' AS stage, * FROM tx_demo_points ORDER BY id;
DO $$
BEGIN
    IF (SELECT array_agg(points ORDER BY id) FROM tx_demo_points) <> ARRAY[70, 130] THEN
        RAISE EXCEPTION 'commit result mismatch';
    END IF;
END $$;

-- C：先扣 10；保存点之后的错误加分撤销，再正确加 10。
BEGIN;
UPDATE tx_demo_points SET points = points - 10 WHERE id = 1;
SAVEPOINT before_credit;
UPDATE tx_demo_points SET points = points + 999 WHERE id = 2;
SELECT 'C_wrong_credit' AS stage, * FROM tx_demo_points ORDER BY id;
ROLLBACK TO before_credit;
UPDATE tx_demo_points SET points = points + 10 WHERE id = 2;
RELEASE SAVEPOINT before_credit;
COMMIT;
SELECT 'C_after_commit' AS stage, * FROM tx_demo_points ORDER BY id;
DO $$
BEGIN
    IF (SELECT array_agg(points ORDER BY id) FROM tx_demo_points) <> ARRAY[60, 140] THEN
        RAISE EXCEPTION 'savepoint result mismatch';
    END IF;
END $$;

DROP TABLE pg_temp.tx_demo_points;
SELECT 'transaction checks passed' AS check_result;
