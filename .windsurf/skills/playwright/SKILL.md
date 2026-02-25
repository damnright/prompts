---
name: playwright
description: 使用 Playwright 进行浏览器自动化测试和交互验证
compatibility: Requires mcp-playwright MCP
---

## when to use
Use this skill when the user needs browser automation, E2E testing, or interaction verification.

## steps

1. **导航到页面**：
   - 使用 `browser_navigate` 打开目标 URL
   - 确保开发服务器已启动

2. **获取页面快照**：
   - 使用 `browser_snapshot` 获取页面无障碍树（推荐，用于交互）
   - 使用 `browser_take_screenshot` 截图保存（用于视觉验证）

3. **页面交互**：
   - `browser_click` - 点击元素（需要先通过 snapshot 获取 ref）
   - `browser_type` - 在输入框中输入文本
   - `browser_fill_form` - 批量填写表单
   - `browser_hover` - 悬停
   - `browser_select_option` - 下拉选择
   - `browser_press_key` - 按键操作
   - `browser_drag` - 拖拽操作

4. **等待与断言**：
   - `browser_wait_for` - 等待文本出现/消失或等待指定时间
   - `browser_console_messages` - 查看控制台日志
   - `browser_network_requests` - 查看网络请求

5. **高级操作**：
   - `browser_evaluate` - 执行任意 JavaScript
   - `browser_run_code` - 运行 Playwright 代码片段
   - `browser_tabs` - 管理标签页
   - `browser_resize` - 调整窗口尺寸
   - `browser_file_upload` - 文件上传

## notes
- 每个测试场景先 `browser_snapshot` 获取页面结构
- 使用 `ref` 而非选择器进行元素交互（更稳定）
- 关键步骤截图留证
- 测试结束使用 `browser_close` 关闭浏览器
