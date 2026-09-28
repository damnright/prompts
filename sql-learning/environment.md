# 本地环境：OrbStack + TablePlus

**已有配置：** 本工程复用 OrbStack 中的 PostgreSQL，学习库为 `sql_learning`，默认端口为 `55432`。实际是否正在运行，以后面的状态查询为准。现在跟随教程检查和连接即可；下面使用的项目名、配置和端口都指向同一套环境，重复启动会复用它。

## 1 第一步：打开 OrbStack，确认它在运行

1. 在 macOS“应用程序”中打开已安装的 OrbStack。
2. 在容器列表中找到项目 `prompts-sql-learning`，展开或选中它下面的 PostgreSQL 容器。界面可能按项目分组显示。
3. 如果列表已有该容器，不要另建一个同端口的 PostgreSQL。启动状态随后通过终端核对。
4. OrbStack 是容器运行工具，数据库本身由容器内的 PostgreSQL 创建。下一步通过 OrbStack 自带的 Docker / Compose 命令进行操作。

按 `⌘ + 空格` 打开 Spotlight，输入 Terminal，打开“终端”。后面标为 `sh` 的代码在终端执行，标为 `sql` 的代码在数据库查询窗口执行；不要把两者混用。

先进入工程目录：

```sh
cd /Users/yuyang/Projects/prompts/sql-learning
pwd
```

`pwd` 应显示上面的完整目录。后续终端命令默认都在这个目录执行。

## 2 第二步：查看已有工具与容器

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

如果找不到这个路径，先确认 OrbStack 已完成首次初始化；它会提供相应的命令行工具。

## 3 第三步：认识这次建库的配置

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

初始化变量和上述 SQL 文件只在空数据目录首次启动时生效；已经有数据卷时，重启不会重建数据库，也不会再次导入数据。修改 `.env` 的密码文本也不会自动修改已有数据库账号的密码。

## 4 第四步：查看本地连接配置

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

## 5 第五步：确认端口，再启动 PostgreSQL

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

## 6 第六步：确认数据库确实创建成功

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

## 7 第七步：在 TablePlus 新建连接

1. 打开已安装的 TablePlus，回到连接列表。
2. 点击 `Create a new connection`；已有连接列表也可以右键选择 `New`。
3. 在数据库类型中选择 **PostgreSQL**，点击 `Create`。
4. 新建一个单独的学习连接，填写下表。不要覆盖之前保存的其他项目连接。

| 设置 | 填写内容 | 原因 |
| --- | --- | --- |
| Name | `SQL / PostgreSQL 学习` | 仅用于在 TablePlus 中识别连接 |
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

不同版本的布局可能略有不同；以按钮文字为准。

## 8 第八步：在 TablePlus 执行第一条 SQL

1. 在已连接的数据库窗口点击 **SQL / SQL Query Editor** 按钮，打开查询编辑器。
2. 粘贴下面一条 SQL，选中它：

```sql
SELECT 1 + 1 AS result;
```

3. 查看运行按钮旁的下拉菜单，选择 **Run Current**，执行选中的语句。结果表应有一列 `result`，一行数值 `2`。
4. 再执行前面的 `SELECT current_database(), current_user;`，确认查询发生在学习库中。
5. 打开 [hello.sql](hello.sql)，复制其中的表行数查询执行，确认 **5 个用户、12 个单词、10 个会话、18 次作答**。
6. 执行下面的单词查询，应该得到 `speak`、`travel`、`practice`、`review` 四行：

```sql
SELECT id, term FROM words WHERE level = 'A2' ORDER BY id;
```

多条 SQL 用分号分隔。初学时每次只执行明确选中的语句；需要执行整段时再选择 `Run All`。TablePlus 的运行模式可以改变，不只凭快捷键判断执行范围。

## 9 第九步：进入对应实操

连接通过后，按[融合章节导读](README.md)学习，随后进入[本地实操](practice.md)。保存答案与自动检查的方法统一见[答案保存与检查](practice.md#check)。
## 10 常见问题：按现象查原因

| 现象 | 先检查 | 怎么处理 |
| --- | --- | --- |
| 找不到 Docker 命令 | OrbStack 是否完成初始化 | 复用 `~/.orbstack/bin/docker`，无需新装 Docker Desktop |
| Cannot connect to Docker daemon | OrbStack 是否正在运行 | 打开 OrbStack 后重试状态命令 |
| Port is already allocated | 端口是否属于其他服务 | 改本工程 `.env` 的端口，重新启动并同步 TablePlus 配置 |
| TablePlus connection refused | 容器状态、Host、Port | 确认 healthy；用 `127.0.0.1` 和本机映射端口 |
| Password authentication failed | User 和 `.env` 中原密码 | 重新核对并复制；改 `.env` 文本不会修改已有数据库密码 |
| Database does not exist | Database 字段 | 核对 `sql_learning`；按第 6 节查询，不重新创建同端口容器 |
| SSL 相关连接错误 | 是否强制要求 SSL | 本工程未配置服务端 TLS；仅对此本地学习连接选择 Disable，再测试 |
| relation does not exist / 看不到表 | 数据库与 public 模式 | 运行第 6 节的查表语句；查看初始化日志 |
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


工具界面有差异时，参考 [OrbStack Docker 文档](https://docs.orbstack.dev/docker/)、[TablePlus 连接操作](https://docs.tableplus.com/gui-tools/manage-connections)与[查询编辑器](https://docs.tableplus.com/query-editor/untitled)。

[返回章节导读](README.md) · [本地实操](practice.md) · [数据库设计补充](design.md)。
