SELECT version();

SELECT 'users' AS table_name, COUNT(*) AS row_count FROM users
UNION ALL
SELECT 'words', COUNT(*) FROM words
UNION ALL
SELECT 'learning_sessions', COUNT(*) FROM learning_sessions
UNION ALL
SELECT 'word_reviews', COUNT(*) FROM word_reviews;

SELECT id, term, level FROM words ORDER BY id LIMIT 3;
