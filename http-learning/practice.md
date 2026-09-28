# HTTP / API 本地实操

[章节导读](README.md) · [教学工具](lab.py)

每个实验先预测结果，再运行，最后说明差异。使用虚构数据；工具只监听本机、不读写数据库、不提供目录或文件下载。

## 0. 启动与结束

终端 A：

```sh
cd /Users/yuyang/Projects/prompts/http-learning
python3 --version
curl --version
lsof -nP -iTCP:8083 -sTCP:LISTEN
python3 lab.py --port 8083
```

若端口已被其他程序占用，改成空闲端口，并同步下面的 URL；不要停止其他项目。启动后应打印 `HTTP 教具：http://127.0.0.1:8083`。终端 A 保持运行，在终端 B 发请求。

结束时在终端 A 按 `Ctrl+C`。没有持久数据需要清理。工具基于 Python 标准库 [http.server](https://docs.python.org/3/library/http.server.html)，只作本地教学；不需要通读它的实现。

<a id="h1"></a>

## H1. 观察一来一回

**前置：** 阅读 H1，启动工具。

```sh
curl -v 'http://127.0.0.1:8083/words'
```

观察 `>` 开头的请求与 `<` 开头的响应，指出端口、GET、路径、200、Content-Type 和 JSON。解释为什么访问 IP 地址的本次实验没有演示域名解析，也没有演示 HTTPS / TLS。

**预期：** 得到含 `items` 的 JSON，里面有 `speak` 和 `review`。这是固定测试数据，来源不是 PostgreSQL。

**验收：** 画出 `curl → 本机监听端口 → 教学进程 → curl`，再把教学进程替换成未来的 Go 服务和数据库。

<a id="h2"></a>

## H2. Header、JSON 与输入校验

**前置：** 阅读 H2。以下 POST 只回显经过校验的输入，不创建词条。

```sh
curl -i 'http://127.0.0.1:8083/echo' \
  -H 'Content-Type: application/json' \
  --data '{"term":"speak","example":null}'

curl -i 'http://127.0.0.1:8083/echo' \
  -H 'Content-Type: application/json' --data '{broken'

curl -i 'http://127.0.0.1:8083/echo' \
  -H 'Content-Type: text/plain' --data 'speak'
```

**预期：** 依次为 200、400、415；第一项返回 `received` 对象。`--data` 让 curl 使用 POST；`-i` 同时显示响应头。把 `null` 改成空字符串，再删掉 `example`，观察三种不同的 JSON。

**验收：** 能说明 JSON 语法正确不等于词条业务规则正确，Content-Type 是发送格式，Accept 是期望接收格式。教具不实施完整 HTTP 内容协商。

<a id="h3"></a>

## H3. 收到响应不等于成功

**前置：** 阅读 H3。下面是人为选择状态的演示路由。

```sh
curl -i 'http://127.0.0.1:8083/status/401'
curl -i 'http://127.0.0.1:8083/status/403'
curl -i 'http://127.0.0.1:8083/status/404'
curl -i 'http://127.0.0.1:8083/status/409'
curl -i 'http://127.0.0.1:8083/status/429'
curl -i 'http://127.0.0.1:8083/status/503'
```

**预期：** 每次都建立连接并收到相应 HTTP 状态；401 带 `WWW-Authenticate`，429 / 503 带 `Retry-After`。它们没有真的执行身份、权限、冲突或流量检查。

为 400 / 401 / 403 / 404 / 409 / 429 / 503 各写一句客户端动作，例如提示修正输入、重新认证、停止越权访问、展示不存在、核对冲突或按策略稍后重试。不要把所有错误统一处理成“重登”。

**验收：** 能解释 curl 默认打印 4xx / 5xx 响应不代表业务成功；自动化检查要显式判断状态或采用适合的失败选项。

<a id="h4"></a>

## H4. 等待超时与结果未知

**前置：** 阅读 H4，工具仍运行。

```sh
curl -i --max-time 0.2 'http://127.0.0.1:8083/slow'
curl -i --max-time 4 'http://127.0.0.1:8083/slow'
```

**预期：** `/slow` 等待约 2 秒，第一条以超时结束，第二条收到 200。第一条没有收到 HTTP 响应，不能把它当作服务端返回 500。工具没有写入，所以本实验只证明客户端停止等待。

接着评审场景：“Go 已提交一次作答，响应途中断线；客户端又发送相同 POST。”说明为什么需要业务操作标识、去重约束和结果核对。判断连续两次 DELETE 可以分别返回 204 和 404，而仍然符合删除同一资源的幂等效果。

**验收：** 分开描述取消等待、取消服务端工作、事务回滚、提交结果未知；不能假设取消一定撤销写入。

<a id="h5"></a>

## H5. 评审接口边界，再接真实服务

**前置：** 阅读 H5。当前只做方案评审，完成 Go G4～G7 后再用真实服务核对。

| 待评审说法 | 应指出的边界 |
| --- | --- |
| 传入 user_id 就代表已经登录 | 身份需要可信凭据与验证，不能相信自报的用户 ID |
| 登录后可以读取任意词库 ID | 每次访问仍要检查对象是否归当前用户或有明确共享规则 |
| 开 CORS 就能保护 iPhone API | CORS 约束浏览器跨源读取，不能代替服务端授权 |
| GET 请求绝对不会产生任何副作用 | 方法定义约束预期语义，服务端实现仍需遵守；日志等附带效果不等于业务修改 |
| 添加 X-Request-ID 就能防止重复扣费 | 追踪 ID 不自动提供业务幂等与并发保证 |

**产出：** 给[Go 单词 API](../go-learning/practice.md#g4)的列表和新建请求写出预期状态、JSON、空值与失败规则。Go 完成后比较真实响应与契约，客户端联调见 [G7](../go-learning/practice.md#g7)。

**清理：** 关闭本次教学进程。真实 API 实验使用 Go 目录的隔离表，不修改 SQL 四张练习表。
