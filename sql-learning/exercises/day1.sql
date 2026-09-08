-- 第一天：单表查询与增删改。每题保留 Q 编号，替换 TODO。
-- 输出列名和排序按题目要求；执行 python3 lab.py check exercises/day1.sql 检查。
-- 本文件的 Q06～Q08 在同一次运行中依次执行；命令行每次运行都会加载初始数据。

-- Q01 单词列表
-- 查出全部单词，输出 id, term, level，按 id 升序。应有 12 行。
-- TODO

-- Q02 条件组合
-- 查 A1 且 term 包含字母 a 的单词，忽略大小写。
-- 输出 id, term，按 id 升序。应有 apple、water、learn。
-- TODO

-- Q03 NULL
-- 查没有例句的单词，输出 id, term，按 id 升序。应有 3 行。
-- TODO

-- Q04 排序与 LIMIT
-- 查已完成且用时最长的 3 个会话，用时相同时 id 较小的排前面。
-- 输出 id, duration_minutes。预期 id 顺序为 6、2、5。
-- TODO

-- Q05 去重
-- 查所有不同的单词等级，输出 level，按 level 升序。应有 3 行。
-- TODO

-- Q06 INSERT
-- 新建单词：id=99，term='focus'，level='B1'，example=NULL。
-- 使用 RETURNING 输出 id, term, level。
-- TODO

-- Q07 UPDATE
-- 将 id=99 的例句改为 'I focus on learning.'。
-- 使用 RETURNING 输出 id, example；必须只更新目标行。
-- TODO

-- Q08 DELETE
-- 删除 id=99 的单词，使用 RETURNING 输出 id, term；必须只删除目标行。
-- TODO
