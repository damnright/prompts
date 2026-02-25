---
name: doc
description: 查阅 GitHub 仓库文档、API 文档和技术资料
compatibility: Requires deepwiki MCP or fetch MCP
---

## when to use
Use this skill when the user needs to look up documentation, API references, or technical resources.

## steps

### 查阅 GitHub 仓库文档

1. **获取文档结构**：使用 `read_wiki_structure` 获取仓库文档目录（格式 `owner/repo`）
2. **阅读文档内容**：使用 `read_wiki_contents` 获取完整文档
3. **提问**：使用 `ask_question` 针对仓库提问，支持多仓库查询（最多 10 个）

### 查阅在线文档

1. **抓取网页**：使用 `fetch` 工具抓取在线文档页面，自动转为 Markdown
2. **分页阅读**：内容截断时使用 `start_index` 参数继续阅读

## common doc sources

- **LeaferJS**：`leaferjs/leafer` / https://www.leaferjs.com/
- **Vue 3**：`vuejs/core` / https://vuejs.org/
- **Vite**：`vitejs/vite` / https://vitejs.dev/
- **TanStack Query**：`TanStack/query` / https://tanstack.com/query/latest
- **Sentry Vue**：https://docs.sentry.io/platforms/javascript/guides/vue/
