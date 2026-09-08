-- 练习简化模型。固定 ID 便于对照答案；产品中的 ID 生成和迁移留到 PostgreSQL 阶段。
CREATE TABLE users (
    id integer PRIMARY KEY,
    name text NOT NULL,
    email text NOT NULL UNIQUE
);

CREATE TABLE words (
    id integer PRIMARY KEY,
    term text NOT NULL UNIQUE,
    level text NOT NULL CHECK (level IN ('A1', 'A2', 'B1')),
    example text
);

CREATE TABLE learning_sessions (
    id integer PRIMARY KEY,
    user_id integer NOT NULL REFERENCES users(id),
    started_at timestamptz NOT NULL,
    status text NOT NULL CHECK (status IN ('completed', 'abandoned')),
    duration_minutes integer NOT NULL CHECK (duration_minutes >= 0),
    rating integer CHECK (rating BETWEEN 1 AND 5)
);

CREATE TABLE word_reviews (
    id integer PRIMARY KEY,
    session_id integer NOT NULL REFERENCES learning_sessions(id),
    word_id integer NOT NULL REFERENCES words(id),
    is_correct boolean NOT NULL,
    score integer NOT NULL CHECK (score BETWEEN 0 AND 100)
);
