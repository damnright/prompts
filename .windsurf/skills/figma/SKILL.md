---
name: figma
description: 从 Figma 设计稿中读取设计信息、截图、变量和元数据
compatibility: Requires figma-remote-mcp-server MCP
---

## when to use
Use this skill when the user needs to read or inspect a Figma design file.

## steps

1. **解析 URL**：从 URL 中提取 `fileKey` 和 `nodeId`
   - URL 格式：`https://figma.com/design/:fileKey/:fileName?node-id=:int1-:int2`
   - `fileKey` = `:fileKey`
   - `nodeId` = `:int1::int2`（将 `-` 替换为 `:`）

2. **获取设计上下文**：使用 `get_design_context` 工具获取节点的设计代码和资源
   - 传入 `fileKey` 和 `nodeId`
   - 设置 `clientFrameworks` 和 `clientLanguages` 为项目实际技术栈（如 `vue`, `javascript,css`）

3. **获取截图**（可选）：使用 `get_screenshot` 工具获取节点的视觉截图
   - 传入 `fileKey` 和 `nodeId`

4. **获取元数据**（可选）：使用 `get_metadata` 工具获取节点结构树
   - 用于了解节点层级、尺寸、位置

5. **获取变量定义**（可选）：使用 `get_variable_defs` 工具获取设计变量
   - 如颜色、间距等设计 token

6. **输出结果**：
   - 以结构化方式呈现设计信息
   - 列出关键样式属性（颜色、字体、间距、圆角等）
   - 如有图片资源，列出下载 URL
