---
name: screenshot
description: 对当前页面或指定元素进行截图，用于视觉验证和文档
compatibility: Requires mcp-playwright or puppeteer MCP
---

## when to use
Use this skill when the user needs to take a screenshot of a page or element.

## steps

### 方式一：Playwright MCP 截图（推荐）

1. **导航到目标页面**：使用 `browser_navigate` 打开 URL
2. **截取整个视口**：`browser_take_screenshot` → type: png
3. **截取指定元素**：先 `browser_snapshot` 获取 ref，再 `browser_take_screenshot` 指定 ref
4. **截取完整页面**（含滚动区域）：`browser_take_screenshot` → fullPage: true

### 方式二：Puppeteer MCP 截图

1. **导航**：`puppeteer_navigate → url`
2. **全页截图**：`puppeteer_screenshot → name`
3. **元素截图**：`puppeteer_screenshot → name, selector`

## parameters
- **type**：`png`（无损）或 `jpeg`（体积小）
- **filename**：自定义保存文件名
- **fullPage**：`true` 截取完整滚动页面
- **element + ref**：截取特定元素
