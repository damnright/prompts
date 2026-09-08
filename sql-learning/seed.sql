-- 全部是虚构练习数据。固定日期保证以后执行也得到相同答案。
INSERT INTO users (id, name, email) VALUES
    (1, 'Lin', 'lin@example.test'),
    (2, 'Mei', 'mei@example.test'),
    (3, 'Chen', 'chen@example.test'),
    (4, 'An', 'an@example.test'),
    (5, 'Yu', 'yu@example.test');

INSERT INTO words (id, term, level, example) VALUES
    (1, 'apple', 'A1', 'I eat an apple.'),
    (2, 'book', 'A1', 'This is my book.'),
    (3, 'water', 'A1', 'I drink water.'),
    (4, 'learn', 'A1', NULL),
    (5, 'speak', 'A2', 'I speak English.'),
    (6, 'travel', 'A2', 'We travel by train.'),
    (7, 'practice', 'A2', 'I practice every day.'),
    (8, 'improve', 'B1', 'I want to improve.'),
    (9, 'confident', 'B1', 'I feel confident.'),
    (10, 'schedule', 'B1', NULL),
    (11, 'listen', 'A1', 'Please listen.'),
    (12, 'review', 'A2', NULL);

INSERT INTO learning_sessions (id, user_id, started_at, status, duration_minutes, rating) VALUES
    (1, 1, '2026-09-01 09:00:00+00', 'completed', 10, 4),
    (2, 1, '2026-09-02 09:00:00+00', 'completed', 20, 5),
    (3, 1, '2026-09-04 09:00:00+00', 'completed', 15, 5),
    (4, 1, '2026-09-05 09:00:00+00', 'abandoned', 5, NULL),
    (5, 2, '2026-09-01 10:00:00+00', 'completed', 20, 3),
    (6, 2, '2026-09-03 10:00:00+00', 'completed', 25, NULL),
    (7, 3, '2026-09-02 11:00:00+00', 'completed', 15, 4),
    (8, 3, '2026-09-02 11:00:00+00', 'completed', 15, 4),
    (9, 3, '2026-09-06 11:00:00+00', 'abandoned', 3, NULL),
    (10, 5, '2026-09-07 12:00:00+00', 'abandoned', 4, NULL);

-- 每行是一次作答，同一用户可以多次回答同一个单词。
INSERT INTO word_reviews (id, session_id, word_id, is_correct, score) VALUES
    (1, 1, 1, true, 90),
    (2, 1, 2, false, 40),
    (3, 1, 3, true, 95),
    (4, 2, 2, true, 80),
    (5, 2, 4, false, 30),
    (6, 2, 1, true, 92),
    (7, 3, 5, true, 88),
    (8, 3, 2, true, 85),
    (9, 5, 1, true, 93),
    (10, 5, 2, false, 45),
    (11, 5, 6, false, 35),
    (12, 6, 2, false, 48),
    (13, 6, 7, true, 87),
    (14, 7, 3, true, 91),
    (15, 7, 8, true, 89),
    (16, 8, 8, false, 50),
    (17, 8, 9, true, 86),
    (18, 8, 10, true, 94);
