-- 只在已确认的 sql_learning 学习库首次创建；不修改 public 四张练习表。
-- schema 已存在时停止核对，不覆盖或重置。出错后在同一连接 ROLLBACK。
BEGIN;

CREATE SCHEMA go_learning;

CREATE TABLE go_learning.words (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    term text NOT NULL UNIQUE CHECK (char_length(btrim(term)) BETWEEN 1 AND 80),
    level text NOT NULL CHECK (level IN ('A1', 'A2', 'B1')),
    example text,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- 仅用于 G6 演示“词条与学习备注必须一起保存”的关联写入。
CREATE TABLE go_learning.word_notes (
    word_id bigint PRIMARY KEY REFERENCES go_learning.words(id) ON DELETE CASCADE,
    note text NOT NULL CHECK (char_length(btrim(note)) BETWEEN 1 AND 200)
);

COMMIT;
