# SQL 三天学习计划与本地工程

## 1. 先认识 SQL，再开始三天学习

按顺序阅读本文件的第 1～3 节，完成环境和连接，再进入每天的详细讲义。**默认 SQL 零基础，每天约 4 小时有效学习，共 12 小时；首次下载镜像和休息时间另计。**

### 1.1 SQL 是什么？

SQL 是 Structured Query Language，即“结构化查询语言”。你用它告诉数据库：需要哪些数据、如何筛选和统计，以及要新增或修改哪些记录。

例如，英语 App 需要“列出 A2 等级的单词”，可以写：

```sql
SELECT id, term
FROM words
WHERE level = 'A2'
ORDER BY id;
```

逐行读：选择 `id` 和 `term` 两列；从 `words` 表读取；只保留等级为 A2 的行；按 ID 排序。现在先读懂含义，连接 TablePlus 后再执行。

SQL 的重点是描述结果。在 Go 里，你可能用循环逐个筛选对象；在 SQL 里，你描述需要哪些行，让数据库决定具体怎样查找。三天先练会表达需求，再学习索引和执行计划。

SQL 被 PostgreSQL、MySQL 等多种数据库采用，具体支持的语法会有差异。本教程统一使用 PostgreSQL，遇到 ILIKE 等写法时也以 PostgreSQL 文档为准。

### 1.2 数据库、表、行、列是什么？

把英语 App 想象成需要长期保存以下内容：用户资料、单词、学习会话、每次作答结果。数据库让这些数据在程序关闭后依然存在，并支持查询、校验和更新。

| 概念 | 本工程中的例子 | 如何理解 |
| --- | --- | --- |
| 数据库服务 | PostgreSQL 进程 | 接收连接和 SQL，管理数据；一个服务可以包含多个数据库 |
| 数据库 Database | `sql_learning` | 本次学习使用的一组数据的容器 |
| 模式 Schema | `public` | 数据库内组织表等对象的命名空间；本次先使用默认的 public |
| 表 Table | `words` | 同一种数据的集合；这里每行是一个单词 |
| 行 Row | `1, apple, A1` | 一条记录 |
| 列 Column | `id`, `term`, `level` | 记录的属性，每列有自己的数据类型 |
| 主键 Primary Key | `words.id` | 唯一标识一条记录，不能重复或为 NULL |
| 外键 Foreign Key | `learning_sessions.user_id` | 指向用户表里的 ID，把会话和用户关联起来 |

你可以先把表理解成带有字段类型和规则的表格，但它还支持多表关联、事务和并发访问。更多概念见 [PostgreSQL：关系数据库概念](https://www.postgresql.org/docs/18/tutorial-concepts.html)。

### 1.3 SQL、PostgreSQL、OrbStack、TablePlus 分别做什么？

| 名称 | 职责 | 你会怎样使用它 |
| --- | --- | --- |
| SQL | 操作关系数据库的语言 | 写 `SELECT`、`INSERT`、`UPDATE` 等语句 |
| PostgreSQL | 数据库软件 | 真正保存表、执行 SQL、返回结果 |
| OrbStack | 在 Mac 上运行 Docker 容器的工具 | 启动、查看、停止 PostgreSQL 容器 |
| Docker 镜像 Image | 打包好的软件及运行环境 | 本工程使用 `postgres:18.6-alpine` |
| Docker 容器 Container | 镜像启动后的运行实例 | 本次 PostgreSQL 就在这个实例里运行 |
| Docker Compose | 根据配置文件管理容器的工具 | 读取 `compose.yaml`，安排镜像、端口和数据卷 |
| 数据卷 Volume | 独立保存容器数据的存储空间 | 保留 PostgreSQL 的数据文件 |
| TablePlus | 图形化数据库客户端 | 连接 PostgreSQL、查看表、编辑和运行 SQL |
| psql | PostgreSQL 命令行客户端 | 在终端里完成同样的连接与查询操作 |

本机的连接路径是：

```text
你在 TablePlus 中写 SQL
          ↓
Mac：127.0.0.1:55432
          ↓ 端口转发
OrbStack 中的 PostgreSQL 容器：5432
          ↓
sql_learning 数据库 → public 模式 → users / words / learning_sessions / word_reviews
          ↓
查询结果返回 TablePlus
```

`127.0.0.1` 表示这台 Mac，`55432` 是 Mac 提供给 TablePlus 的入口，`5432` 是容器内 PostgreSQL 的端口。三个名字也要分清：Compose 项目是 `prompts-sql-learning`，容器是 `prompts-sql-learning-postgres-1`，数据库是 `sql_learning`。

### 1.4 三天具体学到什么程度？

| 语句类别 | 常见语句 | 用途 | 安排 |
| --- | --- | --- | --- |
| 定义结构 | CREATE DATABASE / CREATE TABLE | 创建数据库或表 | 建环境时理解，第 1 天体验建表 |
| 查询数据 | SELECT | 过滤、关联、统计和分析 | 三天持续练习 |
| 修改数据 | INSERT / UPDATE / DELETE | 增加、修改、删除记录 | 第 1 天 |
| 控制事务 | BEGIN / COMMIT / ROLLBACK | 将多步修改作为整体提交或撤销 | 第 1 天体验，后续 PostgreSQL 阶段深入 |

目标是能独立写常用 SQL，读懂并检查 AI 生成的查询，完成英语 App 的基础学习统计。完成本教程对应 [技术路线](../tech-list.md) 第 1 项；索引、锁、隔离级别、连接池、迁移和性能调优留到第 2 项。

| 天数 | 详细讲义 | 独立练习 | 当日产出 |
| --- | --- | --- | --- |
| 第 1 天 | [单表查询与增删改](lessons/day1.md) | Q01～Q08 | 单词查询和限定范围的增删改 |
| 第 2 天 | [多表查询与统计](lessons/day2.md) | Q09～Q16 | 学习统计、正确率、修复重复累计 |
| 第 3 天 | [子查询、窗口函数与综合查询](lessons/day3.md) | Q17～Q24 | 最近学习、排名、累计时长、学习概览 |

## 2. 一步步用 OrbStack 建库，再用 TablePlus 连接

**你的当前环境：** 前一步已在 OrbStack 中建立本工程的 PostgreSQL，数据库和练习数据已导入，端口为 `55432`。现在跟随教程检查和连接即可；下面使用的项目名、配置和端口都指向同一套环境，重复启动会复用它。

### 2.1 第一步：打开 OrbStack，确认它在运行

1. 在 macOS“应用程序”中打开已安装的 OrbStack。
2. 在容器列表中找到项目 `prompts-sql-learning`，展开或选中它下面的 PostgreSQL 容器。界面可能按项目分组显示。
3. 如果列表已有该容器，不要另建一个同端口的 PostgreSQL。启动状态随后通过终端核对。
4. OrbStack 是容器运行工具，数据库本身由容器内的 PostgreSQL 创建。下一步通过 OrbStack 自带的 Docker / Compose 命令进行操作。[OrbStack 官方说明](https://docs.orbstack.dev/docker/)

按 `⌘ + 空格` 打开 Spotlight，输入 Terminal，打开“终端”。后面标为 `sh` 的代码在终端执行，标为 `sql` 的代码在数据库查询窗口执行；不要把两者混用。

先进入工程目录：

```sh
cd /Users/yuyang/Projects/prompts/sql-learning
pwd
```

`pwd` 应显示上面的完整目录。后续终端命令默认都在这个目录执行。

### 2.2 第二步：查看已有工具与容器

运行：

```sh
~/.orbstack/bin/docker --version
~/.orbstack/bin/docker --context orbstack compose version
~/.orbstack/bin/docker --context orbstack ps -a
```

你应该看到 Docker / Compose 的版本，以及已有的 `prompts-sql-learning-postgres-1`。`Up` 表示运行中，`Exited` 表示已停止，`healthy` 表示健康检查通过。

每段命令的作用：

- `~/.orbstack/bin/docker`：使用 OrbStack 提供的命令，不另外安装 Docker Desktop。
- `--context orbstack`：这次命令连接 OrbStack 引擎，不切换全局设置。
- `ps -a`：列出容器，包括已停止的容器。

如果找不到这个路径，先确认 OrbStack 已完成首次初始化；它会提供相应的命令行工具，见 [OrbStack 安装说明](https://docs.orbstack.dev/install)。

### 2.3 第三步：认识这次建库的配置

用编辑器打开 [compose.yaml](compose.yaml)，对照下表读一遍，不需要重新新建文件：

| 配置 | 本工程的值 | 实际作用 |
| --- | --- | --- |
| `image` | `postgres:18.6-alpine` | 指定 PostgreSQL 镜像版本 |
| `POSTGRES_DB` | `sql_learning` | 数据目录首次初始化时创建的数据库名称 |
| `POSTGRES_USER` | `sql_learner` | 首次初始化时创建的数据库账号 |
| `POSTGRES_PASSWORD` | 从 `.env` 引用 | 该账号的初始密码 |
| `ports` | `127.0.0.1:55432:5432`，端口可配置 | 将本机 55432 转发到容器的 5432 |
| `pgdata:/var/lib/postgresql` | 数据卷挂载 | PostgreSQL 18 的数据保存在该数据卷中 |
| `01-schema.sql` | 挂载本工程 `schema.sql` | 首次初始化时创建四张表 |
| `02-seed.sql` | 挂载本工程 `seed.sql` | 随后导入虚构的学习数据 |
| `healthcheck` | `pg_isready` | 检查 PostgreSQL 是否可以接受连接 |

因此，第一次启动的实际顺序是：下载镜像 → 创建并启动容器 → 初始化数据目录 → 建立账号和 `sql_learning` 数据库 → 执行建表 SQL → 执行种子数据 SQL → 等待健康检查通过。

**创建数据库和创建表是两步。** `POSTGRES_DB` 负责首次建库，`schema.sql` 中的 `CREATE TABLE` 负责在库里建表。你以后也可以用 SQL 的 `CREATE DATABASE 数据库名` 创建另一个数据库；本次 `sql_learning` 已存在，无需再次执行建库语句。

初始化变量和上述 SQL 文件只在空数据目录首次启动时生效；已经有数据卷时，重启不会重建数据库，也不会再次导入数据。修改 `.env` 的密码文本也不会自动修改已有数据库账号的密码。[PostgreSQL 官方镜像说明](https://hub.docker.com/_/postgres)

### 2.4 第四步：查看本地连接配置

本目录已有 `.env`，用编辑器打开它，找到：

- `SQL_LEARNING_PORT`：当前为 `55432`。
- `SQL_LEARNING_PASSWORD`：本次随机生成的密码，稍后复制到 TablePlus。

`.env.example` 是配置说明，实际使用的是 `.env`。如果 Finder 没显示 `.env`，进入本目录后按 `⌘ + Shift + .` 显示隐藏文件，再用文本编辑器查看。密码只需在本地查看、复制，不放到学习笔记或截图中。

**只有在另一台机器首次搭建、确实没有 `.env` 时**，才需要生成配置。下面的命令只创建缺失的文件，不覆盖现有配置：

```sh
python3 - <<'PYCONFIG'
from pathlib import Path
import os
import secrets

path = Path('.env')
if path.exists():
    print('.env 已存在，继续使用原配置。')
else:
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, 'w') as file:
        file.write('SQL_LEARNING_PORT=55432\n')
        file.write('SQL_LEARNING_PASSWORD=' + secrets.token_hex(24) + '\n')
    print('已生成 .env，请在编辑器中查看连接密码。')
PYCONFIG
```

当前这台 Mac 可以跳过生成步骤。不要用新的 `.env` 配合已有数据卷，否则新文件里的密码可能与数据库账号不一致。

### 2.5 第五步：确认端口，再启动 PostgreSQL

先检查本机端口：

```sh
lsof -nP -iTCP:55432 -sTCP:LISTEN
```

- 没有结果：没有发现该端口的监听进程，可以继续。
- 有结果：结合上一步的容器列表判断来源。本机已有的学习容器就在用这个端口，可以继续复用。
- 如果属于另一个服务：将本工程 `.env` 的端口改成一个空闲值，例如 `55433`，TablePlus 也用同一个新端口。不要停止别的项目来腾端口。

现在执行实际的 Compose 启动命令：

```sh
~/.orbstack/bin/docker --context orbstack compose \
  --project-name prompts-sql-learning \
  --env-file .env \
  --file compose.yaml \
  up -d --wait --wait-timeout 60
```

命令行末尾的 `\` 表示下一行仍属于同一条命令，整段复制执行即可。

| 参数 | 意思 |
| --- | --- |
| `--project-name prompts-sql-learning` | 固定本工程的项目名，便于识别和复用容器、数据卷 |
| `--env-file .env` | 从本地配置文件读取端口和密码 |
| `--file compose.yaml` | 使用当前工程的容器配置 |
| `up` | 根据配置创建或启动服务；已有匹配的服务会复用 |
| `-d` | 后台运行，终端可以继续输入命令 |
| `--wait` | 等到服务运行且健康后返回 |
| `--wait-timeout 60` | 等待服务健康的超时值；镜像下载也可能需要额外时间 |

首次执行时可能看到下载、创建网络和数据卷等信息；本机已有镜像和数据时会更快。此时回到 OrbStack，应看到这个 PostgreSQL 容器正在运行。

### 2.6 第六步：确认数据库确实创建成功

先查看容器状态：

```sh
~/.orbstack/bin/docker --context orbstack compose \
  --project-name prompts-sql-learning --env-file .env --file compose.yaml ps
```

预期看到 `healthy` 和 `127.0.0.1:55432->5432/tcp`。如果你修改了端口，这里应显示新端口。

再直接进入容器，用里面的 psql 查询，确认数据库能工作：

```sh
~/.orbstack/bin/docker --context orbstack compose \
  --project-name prompts-sql-learning --env-file .env --file compose.yaml \
  exec postgres psql -U sql_learner -d sql_learning
```

现在提示符会变成类似 `sql_learning=#`。表示已经进入数据库客户端，接下来输入 SQL：

```sql
SELECT current_database(), current_user;
```

预期分别是 `sql_learning` 和 `sql_learner`。再运行：

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

应看到 `learning_sessions`、`users`、`word_reviews`、`words` 四张表。完成后输入 `\q` 回车退出 psql，回到普通终端。`\q` 是 psql 的专用命令，不是 SQL，不要放进 TablePlus。

至此你完成了“通过 OrbStack 启动 PostgreSQL → 建立学习数据库 → 建表和导入数据 → 验证数据库”的完整过程。后续日常启动可以简写为 `python3 lab.py up`，它使用相同配置，并额外检查端口和连接；前面的步骤解释了它背后做的事情。

### 2.7 第七步：在 TablePlus 新建连接

1. 打开已安装的 TablePlus，回到连接列表。
2. 点击 `Create a new connection`；已有连接列表也可以右键选择 `New`。
3. 在数据库类型中选择 **PostgreSQL**，点击 `Create`。
4. 新建一个单独的学习连接，填写下表。不要覆盖之前保存的其他项目连接。

| 设置 | 填写内容 | 原因 |
| --- | --- | --- |
| Name | `SQL 三天练习` | 仅用于在 TablePlus 中识别连接 |
| Host | `127.0.0.1` | 连接本机；不用加 `http://` |
| Port | `55432` | 使用 `.env` 配置的 Mac 端口 |
| User | `sql_learner` | 与 POSTGRES_USER 一致 |
| Password | `.env` 的 `SQL_LEARNING_PASSWORD` 的值 | 只复制等号后面的密码，不包含字段名 |
| Database | `sql_learning` | 与 POSTGRES_DB 一致 |
| SSH | 不启用 | 本次直接连接本机，无需 SSH 隧道 |
| SSL | 先保留客户端默认设置 | 本地练习不需要额外填写证书文件 |

5. 点击 `Test` 测试连接。成功表示可以使用这些参数连接数据库。
6. 保存连接，然后点击 `Connect`，或在连接列表中双击新连接进入。
7. 在对象列表中查看 `public` 模式下的四张表；双击 `words` 可以先浏览单词数据。

连接入口和名称参考 [TablePlus 连接指南](https://docs.tableplus.com/gui-tools/manage-connections)。不同版本的布局可能略有不同；以按钮文字为准。

### 2.8 第八步：在 TablePlus 执行第一条 SQL

1. 在已连接的数据库窗口点击 **SQL / SQL Query Editor** 按钮，打开查询编辑器。
2. 粘贴下面一条 SQL，选中它：

```sql
SELECT 1 + 1 AS result;
```

3. 查看运行按钮旁的下拉菜单，选择 **Run Current**，执行选中的语句。结果表应有一列 `result`，一行数值 `2`。
4. 再执行前面的 `SELECT current_database(), current_user;`，确认查询发生在学习库中。
5. 打开 [hello.sql](hello.sql)，复制其中的表行数查询执行，确认 **5 个用户、12 个单词、10 个会话、18 次作答**。
6. 执行本教程第 1.1 节的 A2 单词查询，应该得到 `speak`、`travel`、`practice`、`review` 四行。

多条 SQL 用分号分隔。初学时每次只执行明确选中的语句；需要执行整段时再选择 `Run All`。TablePlus 的运行模式可以改变，不只凭快捷键判断执行范围。[TablePlus 查询编辑器说明](https://docs.tableplus.com/query-editor/untitled)

### 2.9 第九步：建立“学习 → 运行 → 保存 → 检查”的习惯

以第一天为例：

1. 阅读 [第一天讲义](lessons/day1.md) 的一小节，理解其中的业务问题。
2. 将讲义里的示例复制到 TablePlus，运行，核对讲义给出的结果。
3. 用平时编辑代码或 Markdown 的编辑器打开 [exercises/day1.sql](exercises/day1.sql)。在对应 Q 编号下填写自己的答案并保存。
4. 把这道答案复制到 TablePlus，运行并检查结果。遇到错误先看列名、表名和提示位置。
5. 8 道题都写好后，在终端执行：

```sh
python3 lab.py check exercises/day1.sql
```

正常结果应为 `8/8 题通过`。还没写的题会提示“未作答”，这是正常的；`python3 lab.py test` 检查的是参考答案，不能代替你完成练习。

| 操作 | 改变什么 |
| --- | --- |
| 在编辑器保存 `.sql` 文件 | 保存答案文本，尚未执行到数据库 |
| 在 TablePlus 执行 SELECT | 查询数据，不修改记录 |
| 在 TablePlus 执行增删改 | 默认可直接提交修改；讲义会用 BEGIN / ROLLBACK 包住演示 |
| `lab.py sql / check / test` | 使用当前连接中的临时表，结束后回滚；不重置 TablePlus 的持久化练习表 |

命令行检查要求每题只输出一张结果表，列名和排序与题目一致，保留当天完整 Q 编号。练习文件只写答案，不加入 `BEGIN / COMMIT / ROLLBACK`、psql 专用命令或 `public.` 表名前缀，因为运行器已经管理了事务和临时表。讲义中带事务的跟做演示，在 TablePlus 中单独执行，不整段放入练习答案。

### 2.10 常见问题：按现象查原因

| 现象 | 先检查 | 怎么处理 |
| --- | --- | --- |
| 找不到 Docker 命令 | OrbStack 是否完成初始化 | 复用 `~/.orbstack/bin/docker`，无需新装 Docker Desktop |
| Cannot connect to Docker daemon | OrbStack 是否正在运行 | 打开 OrbStack 后重试状态命令 |
| Port is already allocated | 端口是否属于其他服务 | 改本工程 `.env` 的端口，重新启动并同步 TablePlus 配置 |
| TablePlus connection refused | 容器状态、Host、Port | 确认 healthy；用 `127.0.0.1` 和本机映射端口 |
| Password authentication failed | User 和 `.env` 中原密码 | 重新核对并复制；改 `.env` 文本不会修改已有数据库密码 |
| Database does not exist | Database 字段 | 核对 `sql_learning`；按第 2.6 节查询，不重新创建同端口容器 |
| SSL 相关连接错误 | 是否强制要求 SSL | 本工程未配置服务端 TLS；仅对此本地学习连接选择 Disable，再测试 |
| relation does not exist / 看不到表 | 数据库与 public 模式 | 运行第 2.6 节的查表语句；查看初始化日志 |
| duplicate key value violates unique constraint | 是否重复执行了 INSERT | 检查记录是否已存在；事务演示可 ROLLBACK 后从 BEGIN 重来 |
| current transaction is aborted | 同一事务中前一条 SQL 是否失败 | 在同一个 TablePlus 查询会话执行 ROLLBACK，再重新开始本段演示 |
| 同一查询在 TablePlus 和检查器里结果不同 | 是否改过持久化练习表 | 检查器每次使用原始临时数据，TablePlus 使用当前持久化数据 |

需要看本工程日志时执行：

```sh
~/.orbstack/bin/docker --context orbstack compose \
  --project-name prompts-sql-learning --env-file .env --file compose.yaml \
  logs --tail 50 postgres
```

学习结束后，在终端运行 `python3 lab.py stop`；下次运行 `python3 lab.py up` 恢复。停止会保留数据，不要为了重新做题删除数据卷。若在 TablePlus 修改了数据，先检查并撤销自己的那次操作。

## 3. 练习数据与统计口径

| 表 | 每行代表什么 | 重要字段 |
| --- | --- | --- |
| `users` | 一个用户 | `id`, `name`, `email` |
| `words` | 一个单词 | `id`, `term`, `level`, `example` |
| `learning_sessions` | 用户的一次学习会话 | `user_id`, `started_at`, `status`, `duration_minutes`, `rating` |
| `word_reviews` | 会话里的一次作答 | `session_id`, `word_id`, `is_correct`, `score` |

```text
users 1 ── N learning_sessions 1 ── N word_reviews N ── 1 words
```

- 同一个单词可被同一用户回答多次；作答次数、不同单词数、不同用户数是三个口径。
- `completed` 表示已完成，`abandoned` 表示中途退出。每题会明确是否只统计已完成会话。
- 正确率使用 `is_correct`，不要自行根据 `score` 推断；无作答时正确率为 NULL。
- `example` 和 `rating` 可以为 NULL；未评分不等于 0 分。
- An 没有会话，Yu 只有退出的会话；查询需要保留零记录用户时，两人都应出现。
- Chen 有两个时间相同、时长同为 15 分钟的会话，用来检查稳定排序与错误去重。
- 时间固定为 2026 年 9 月，题目按 UTC 计算；不要用 `CURRENT_DATE` 替换题目的固定边界。

## 4. 第 1 天：单表查询与增删改

先阅读详细讲义：[第 1 天：单表查询与增删改](lessons/day1.md)。每小节都有阅读范围、跟做 SQL、预期结果和对应题号，再到 [day1.sql](exercises/day1.sql) 完成独立练习。

| 用时 | 安排 |
| --- | --- |
| 30 分钟 | 阅读 SQL、数据库、表和工具的介绍 |
| 45 分钟 | 按步骤检查 OrbStack 建库配置，完成 TablePlus 连接与首次查询 |
| 55 分钟 | 跟做 SELECT、条件、NULL、排序和去重示例 |
| 40 分钟 | 跟做建表和增删改演示，体验事务回滚 |
| 50 分钟 | 独立完成 Q01～Q08 |
| 20 分钟 | 跑检查，复盘错题，口头解释结果 |

**当天必须理解：**

- 表是一组记录，主键标识某一行；这三天先读懂现成表结构。
- `WHERE` 过滤行；字符串用单引号；NULL 用 `IS NULL` 判断。
- 没有 `ORDER BY` 就不能依赖返回顺序；LIMIT 前要明确排序。
- UPDATE / DELETE 前先用相同 WHERE 查询目标行；RETURNING 用于观察实际改动。
- 表结构中的主键、外键和唯一约束为什么会拒绝某些写入，先理解现象即可。

**验收：** Q01～Q08 全部通过；能解释 `= NULL` 为什么不对、没有 WHERE 的 UPDATE 会影响什么、为什么 LIMIT 要配稳定排序。

## 5. 第 2 天：多表查询与统计

先阅读详细讲义：[第 2 天：多表查询与统计](lessons/day2.md)。每小节都有阅读范围、跟做 SQL、预期结果和对应题号，再到 [day2.sql](exercises/day2.sql) 完成独立练习。

| 用时 | 安排 |
| --- | --- |
| 45 分钟 | 理解 INNER JOIN / LEFT JOIN、外键与一对多关系 |
| 45 分钟 | 学 COUNT / SUM / AVG、GROUP BY / HAVING、CASE / COALESCE / NULLIF |
| 100 分钟 | 完成 Q09～Q15，每题先写“输出一行代表什么” |
| 30 分钟 | Q16：定位多表连接导致时长重复累计的问题，先聚合再连接 |
| 20 分钟 | 跑检查，复述统计口径和零记录用户的处理 |

**当天必须理解：**

- INNER JOIN 只保留匹配行；LEFT JOIN 保留左表行，但 WHERE 中的右表条件可能再次把它过滤掉。
- `COUNT(*)` 数行，`COUNT(列)` 忽略该列的 NULL，`COUNT(DISTINCT 列)` 数不同的非 NULL 值。
- WHERE 在聚合前筛行，HAVING 在聚合后筛组。
- 连接一次会话的多次作答，会重复出现会话的时长；应在正确粒度聚合。
- `SUM(DISTINCT 时长)` 不能修复上述问题：两个不同会话可能恰好同样长。
- 比例计算需要小数；分母为零用 NULLIF，不能把“没有数据”随意当成 0%。

**验收：** Q09～Q16 全部通过；Lin 总完成时长是 45 分钟，正确率是 75%；能解释重复 JOIN 为什么可能算出 120 分钟，以及 An 为什么不能从结果中消失。

## 6. 第 3 天：子查询、窗口函数与综合验收

先阅读详细讲义：[第 3 天：子查询、窗口函数与综合查询](lessons/day3.md)。每小节都有阅读范围、跟做 SQL、预期结果和对应题号，再到 [day3.sql](exercises/day3.sql) 完成独立练习。

| 用时 | 安排 |
| --- | --- |
| 40 分钟 | 学标量子查询、EXISTS / NOT EXISTS、WITH / CTE |
| 40 分钟 | 学 OVER / PARTITION BY、ROW_NUMBER / RANK / DENSE_RANK、累计 SUM |
| 90 分钟 | 完成 Q17～Q23，对照分组聚合与窗口函数的行数变化 |
| 45 分钟 | 独立完成 Q24 学习概览；可以查语法，暂不看答案或让 AI 直接生成 |
| 25 分钟 | 跑检查，说明 Q24 的统计口径，复盘并勾选总验收 |

**当天必须理解：**

- 子查询将一个查询的结果用于另一个查询；CTE 给中间结果起名，便于分步推理。
- EXISTS 关心是否存在匹配记录；NOT EXISTS 适合查询“从未发生过”。
- GROUP BY 合并行，窗口函数保留行并在相关行之间计算。
- ROW_NUMBER 分配序号，RANK 并列后跳号，DENSE_RANK 并列后不跳号。
- 窗口函数的 ORDER BY 决定计算顺序，最外层 ORDER BY 决定最终显示顺序。
- 要筛“最近一条”，先计算窗口序号，再用外层查询筛选；时间相同要补充 ID 决定顺序。

**Q24 的核对结果：** 统计区间为 UTC `[2026-09-02 00:00, 2026-09-05 00:00)`，只含已完成会话。

| 用户 | 完成会话 | 总分钟 | 不同单词 | 正确率 | 最近会话 ID |
| --- | --- | --- | --- | --- | --- |
| Lin | 2 | 35 | 4 | 80.00% | 3 |
| Mei | 1 | 25 | 2 | 50.00% | 6 |
| Chen | 2 | 30 | 4 | 80.00% | 8 |
| An | 0 | 0 | 0 | NULL | NULL |
| Yu | 0 | 0 | 0 | NULL | NULL |

## 7. 总验收与后续衔接

- [ ] 24 道题都亲自写过，自己的三个练习文件全部通过检查。
- [ ] Q24 在 45 分钟内独立完成，能解释时间边界、用户范围、去重口径和 NULL。
- [ ] 能从“一行代表什么”判断 JOIN 是否会导致重复统计。
- [ ] 能解释主键/外键关系，安全执行限定范围的增删改，并观察事务回滚。
- [ ] 随机挑一题，先手算一个用户的结果，再验证 SQL；不能只凭“能运行”判断正确。
- [ ] 能检查 AI 写的 SQL，找出 NULL 判断、漏用户、整数除法、不稳定排序或重复累计的问题。

全部完成后，勾选主路线的 SQL 基础，进入 PostgreSQL。继续复用 OrbStack、TablePlus 和这些表，学习约束、索引、事务、锁、隔离级别、EXPLAIN、JSONB、迁移与连接池。进入 Go 阶段后，再用 Go + pgx 把查询接到 HTTP API。

## 8. 学习资料与使用 AI 的方式

以官方资料为主，按当天知识点阅读，不从头背完整手册：

- 第 1～2 天：[PostgreSQL SQL 入门](https://www.postgresql.org/docs/18/tutorial-sql.html)。
- 第 2～3 天：[表表达式、连接与分组](https://www.postgresql.org/docs/18/queries-table-expressions.html)、[子查询表达式](https://www.postgresql.org/docs/18/functions-subquery.html)、[CTE](https://www.postgresql.org/docs/18/queries-with.html)。
- 第 3 天：[窗口函数教程](https://www.postgresql.org/docs/18/tutorial-window.html)。

每题先独立尝试 10～15 分钟，再向 AI 提问：“只指出我的统计口径或 SQL 哪一步有问题，给一个提示，暂时不要给完整答案。”完成后让 AI 追问 NULL、零记录、重复记录等边界情况，再运行检查。参考答案在 `solutions/`，检查用的固定预期结果在 `expected.json`。
