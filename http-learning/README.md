# HTTP / API：读懂一次请求与失败边界

[技术路线：第 3 项](../tech-list.md) · [通用学习流程](../learning-flow.md) · [本地实操](practice.md)

以 **MDN HTTP 文档**为主教材。先理解客户端与服务端怎样交换数据，再观察正常、错误和超时；Go 第 8 项完成后，用真实单词 API 再验证一次。当前不要求实现登录、网关或流式协议。

## 1. 学习要点与前置条件

- 一次请求包含方法、地址、Header 和可选 Body；响应包含状态码、Header 和可选 Body。
- DNS、连接、TLS、HTTP、JSON 解码和业务校验是不同的失败位置。
- HTTP 成功、业务成功、数据库提交、客户端收到响应是不同事实。
- 身份认证回答“是谁”，授权回答“是否允许做这件事”；CORS 不能代替它们。
- 分页、空值、错误格式、超时与重试需要客户端和服务端共同约定。

只需会打开终端。使用现有 `curl` 和 Python 3 运行本目录的教学工具，不需要学习 Python，也不安装接口调试平台。SQL 未学完也可以开始。

## 2. 阅读单元与对应实操

英文材料可使用浏览器翻译；方法、状态码、字段名保持原文。下面的 H1～H5 合起来对应总路线的实操 3。

| 单元 | 资料与具体阅读范围 | 深度与暂缓内容 | 实操 |
| --- | --- | --- | --- |
| H1：请求经过哪里 | [Overview of HTTP](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Overview)：Components of HTTP-based systems、Basic aspects of HTTP、HTTP flow、HTTP Messages | 理解 client / server / proxy 和请求响应；连接协议的实现细节暂缓 | [H1](practice.md#h1) |
| H2：方法、地址与消息 | [HTTP messages](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Messages)：Anatomy of an HTTP message、HTTP requests、HTTP responses；[HTTP request methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Methods)：GET、POST、PUT、PATCH、DELETE、HEAD、OPTIONS 的说明与汇总表 | 理解路径与查询参数、Header 与 Body、Content-Type 与 Accept；HTTP/2 帧只识读用途 | [H2](practice.md#h2) |
| H3：结果与错误 | [HTTP response status codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status)：200、201、204、400、401、403、404、409、413、415、429、500、503 | 识读含义，理解调用方下一步；其余代码按需查，不背全表 | [H3](practice.md#h3) |
| H4：超时与重试 | [Idempotent](https://developer.mozilla.org/en-US/docs/Glossary/Idempotent)：全文与 Examples；[HTTP request methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Methods) 中 Safe / Idempotent 列 | 理解重复执行的预期效果；幂等不保证每次响应完全相同，POST 不因有请求 ID 自动幂等 | [H4](practice.md#h4) |
| H5：身份、浏览器与接口约定 | [HTTP authentication](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Authentication)：The general HTTP authentication framework、Access forbidden；[CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS)：开头与 Functional overview | 识读认证信息传递、401 / 403；理解浏览器跨源边界。Cookie 登录实现、OAuth 和预检细节暂缓 | [H5](practice.md#h5) |

## 3. 与英语 App 的设计连接

一次“保存作答”的路径可以画成：

```text
页面收集输入 → HTTP 请求 → 身份与权限 → 业务校验
→ 数据库事务 → 提交 → HTTP 响应 → 页面确认
```

分别回答：如果在提交前失败、提交后断网、用户又点一次，应该显示什么，服务端如何判断是不是同一次操作？`request_id` 只用于追踪时，不能承担业务去重；去重还需要作用域、唯一约束、载荷一致性检查和返回已有结果的约定。详细机制连接 [SQL 设计补充](../sql-learning/design.md)。

列表契约至少明确：筛选条件、固定排序、数量上限、下一页标记、无记录时返回空数组、可空字段如何表达。修改契约还需说明“字段缺失”与“显式置空”的区别。第 8 项的[单词 API 实操](../go-learning/practice.md#g4)给出一份固定练习契约，客户端与服务端共同采用。

本地 HTTP 教具没有 TLS、真实鉴权和持久化。它只帮助观察协议现象，不能证明产品已经具备访问控制、可靠重试或上线能力。HTTPS 保护传输，但不会修复错误的业务授权；原生 URLSession 不受浏览器 CORS 机制保护。

## 4. 完成标准与下一步

- 能在一次真实请求里指出方法、目标、请求头、请求体、状态码与响应体。
- 能区分连接失败、收到错误响应、JSON 不符合预期、业务失败，并给出不同的处理方式。
- 能解释“客户端超时，但服务端可能已提交”，说明哪些操作不能直接盲重试。
- 能说明 401 / 403、认证 / 授权、CORS / 服务端权限的区别。
- 第 8 项完成后，重新检查真实列表、新建、冲突与不存在响应；不要把教学工具的固定返回当作业务验证。

完成 H1～H5 即可继续 [Swift](../swift-learning/README.md)。SSE、WebSocket、上传、缓存协商及完整认证实现随产品需求补学。
