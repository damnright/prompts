---
name: figma-implement-design
description: 根据 Figma 设计稿实现 UI 组件代码
compatibility: Requires figma-remote-mcp-server MCP
---

## when to use
Use this skill when the user wants to implement UI components based on a Figma design.

## steps

1. **读取设计稿**：
   - 从用户提供的 Figma URL 中提取 `fileKey` 和 `nodeId`
   - 使用 `get_design_context` 获取设计代码和资源下载链接
   - 使用 `get_screenshot` 获取设计截图用于视觉对照
   - 设置 `clientFrameworks: "vue"` 和 `clientLanguages: "javascript,css"`

2. **检查 Code Connect**：
   - 使用 `get_code_connect_map` 查看是否已有代码映射
   - 如有映射，优先复用已有组件

3. **分析设计**：
   - 拆解页面/组件结构层级
   - 提取关键设计属性：颜色、字体、间距、圆角、阴影
   - 识别可复用的设计 token 和组件
   - 使用 `get_variable_defs` 获取设计变量

4. **制定实现计划**：
   - 列出需要创建/修改的组件文件
   - 确定组件层级和 props 接口
   - 标注需要下载的图片资源

5. **实现代码**：
   - 按组件粒度逐个实现
   - 使用项目现有技术栈（Vue 3 + CSS）
   - 遵循项目代码风格和目录结构
   - 下载并放置图片资源到 `src/assets/`

6. **视觉验证**：
   - 启动开发服务器预览
   - 使用 Playwright 截图与 Figma 设计截图对比
   - 调整差异直到视觉还原度满意

7. **建立 Code Connect 映射**（可选）：
   - 使用 `add_code_connect_map` 将 Figma 节点映射到代码组件
   - 方便后续维护和同步
