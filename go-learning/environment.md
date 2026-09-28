# Go 环境：复用工具与 PostgreSQL

[章节导读](README.md) · [本地实操](practice.md)

## 1. 先检查，再配置

```sh
command -v go
go version
```

有 Go 就使用现有工具，并记录版本；找不到时先检查自己使用的版本管理器，确实未安装再按 [Go — Download and install](https://go.dev/doc/install) 的 macOS 步骤配置稳定版本。无需为学习下载测试版或安装多套 Go。语言入门也可先用 Tour 网页中的运行按钮，真实后端必须在本机运行。

创建或选择自己的练习工程。建议放在本目录的 `work/`，已有目录时先检查并继续原工程。初始化只执行一次：

```sh
cd /Users/yuyang/Projects/prompts/go-learning
mkdir -p work
cd work
go mod init example.com/english-learning
```

已有 go.mod 就跳过 init，不改其 module 路径。G1～G4 先使用标准库；G5 再加入 pgx：

```sh
go get github.com/jackc/pgx/v5/pgxpool
```

检查实际解析出的版本及最低 Go 要求，保留 go.mod / go.sum。后续重做练习复用它们，不重复拉取“最新版本”。先用少量文件表达 HTTP、规则、数据访问；确有职责分离需求时再拆包。

## 2. 复用数据库与隔离学习数据

数据库启动、端口检查、密码与 TablePlus 连接统一见 [SQL 环境](../sql-learning/environment.md)。不要修改其 compose.yaml、重置数据卷或新建同端口数据库。

当前 SQL 四张练习表在 `public` schema。Go 使用同一个 `sql_learning` 数据库中的 **go_learning** schema；词条 ID 由数据库生成，不修改 SQL 练习的固定 ID 与种子数据。

在 TablePlus 已连接的学习库中先查询：

```sql
SELECT current_database(), current_user;
SELECT schema_name FROM information_schema.schemata
WHERE schema_name = 'go_learning';
```

确认库为 sql_learning；schema 不存在时才执行 [schema.sql](schema.sql)。存在时先检查是否为自己此前的练习，复用相同结构；不要删除、覆盖或用 IF NOT EXISTS 掩盖结构差异。脚本没有清空数据或导入种子数据的命令，重复运行会报已存在并需要 ROLLBACK。

SQL 统一使用 `go_learning.words` 等完整表名。跨请求的 API 不能复用 SQL 检查器的连接临时表；不要用 `lab.py sql` 执行这个初始化脚本。

## 3. 在本地传入连接配置

下面以当前 macOS 的 zsh 为例。PGPORT 使用 SQL 环境的实际端口；密码从 `sql-learning/.env` 在本地查看，使用不回显输入，不能粘贴进源代码或命令参数：

```sh
export PGHOST=127.0.0.1
export PGPORT=55432
export PGDATABASE=sql_learning
export PGUSER=sql_learner
export PGSSLMODE=disable
read -s 'PGPASSWORD?输入本地学习库密码（不回显）：'
export PGPASSWORD
```

`sslmode=disable` 只用于本机回环的教学连接；线上按部署方要求配置 TLS。pgx 通过标准 PG 环境变量读取连接信息；程序可使用 `pgxpool.ParseConfig("")`，设置有依据的小连接池上限，再 NewWithConfig 与 Ping。不要输出完整连接配置、密码或凭据错误上下文。

## 4. 启动与验证入口

G4～G7 中让应用通过 `HTTP_ADDR` 读取监听地址，默认 `127.0.0.1:8088`。先检查端口，再在练习工程运行：

```sh
lsof -nP -iTCP:8088 -sTCP:LISTEN
export HTTP_ADDR=127.0.0.1:8088
go run .
```

若端口占用，换空闲端口并同步客户端 URL，不停止其他项目。另一个终端实际请求 `/healthz` 与 `/words`；数据库连接成功必须通过查询验证，仅进程存在不够。

测试在练习工程中执行：

```sh
gofmt -w .
go test ./...
go vet ./...
go test -race ./...
```

只对自己维护的练习工程格式化。集成测试须有明确的测试配置和隔离表 / schema；测试进程不能绕过同一连接事务隔离去写 API 的长期练习表。采用 G6 的隔离策略，核实确实运行了集成测试。

## 5. 结束与清理

通过 Ctrl+C 触发程序的退出流程，停止接收新请求，等待已有请求在有限时间内结束，再关闭连接池。只删除本次创建且已记录 ID 的 API 测试词条，保留工程与 schema 供下一单元使用。

```sh
unset PGPASSWORD
unset PGHOST PGPORT PGDATABASE PGUSER PGSSLMODE HTTP_ADDR
```

如这些变量原先已有用途，应恢复原值。不要停止其他任务正在使用的 PostgreSQL，也不删除整个 schema 或数据卷来“恢复初始状态”。
