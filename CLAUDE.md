# Claude Agent 配置

## 行为准则

- 所有改动需先列出细节，用户回复 "ok" 后才执行
- git 任务完成时生成 commit message，用户回复 "cp" 时提交并推送
- 复杂任务拆分为多级子任务，确保质量第一
- 需要读取设计图时，使用 figma MCP
- 深度分析使用 ultrathink / extended thinking

## 核心工作模式 (Planning Mode)

**核心理念**：Thinking before Coding（谋定而后动）

1. **研究阶段**：收到请求先扫描相关文件，理解架构与依赖
2. **计划阶段**：创建 `implementation_plan.md`，明确目标、变更、验证计划
3. **审查阶段**：展示计划请求审查，**严禁**批准前修改生产代码
4. **执行阶段**：获批后严格按计划编码

## 工具映射

| 能力 | 工具 |
| :--- | :--- |
| 代码编辑 | `str_replace_editor` / `Write` / `Edit` |
| 文件系统 | `Read`, `list_files` |
| 终端命令 | `Bash` / `execute_command` |
| 深度分析 | Extended Thinking (内置) |

## MCP 通用规则

- **必要性原则**：只在需要时调用 MCP
- **专用优先**：能用专用 MCP（context7/serena/git）不走兜底
- **只读先行**：先检索/取证，确认后再改动
- **安全约束**：
  - 禁止 `rm -rf` 等破坏性命令
  - 密钥/令牌使用环境变量，不写入仓库

## MCP 触发清单

| MCP | 触发场景 | 产出 |
| :--- | :--- | :--- |
| `sequential-thinking` | 分解复杂问题、规划步骤 | 精简计划（3-8条） |
| `filesystem` | 浏览/读取项目文件 | 文件内容 |
| `fetch` | 抓取单页权威内容 | 关键段落 |
| `memory` | 沉淀环境/依赖版本/踩坑 | 持久化记录 |
| `figma` | 读取设计稿 | 设计信息 |
| `playwright` | 浏览器测试 | 测试结果 |

## 执行流程

```text
ultrathink 深度分析 → 选 MCP → 只读取证 → 形成提案 → "ok" → 最小改动 → 验证 → memory 记录
```

## Artifacts 规范

| Artifact | 用途 | 格式 |
| :--- | :--- | :--- |
| `task.md` | 任务清单 | `[x]` 完成 / `[/]` 进行中 / `[ ]` 待办 |
| `implementation_plan.md` | 技术方案 | Goal / Changes / Verification |
| `walkthrough.md` | 验收报告 | Changes / Evidence / Next Steps |

## 配置方式

```bash
# MCP 配置
cp .mcp/claude.mcp.json ~/.claude/mcp.json
```

## 注意事项

- `str_replace_editor` 要求精确匹配目标字符串
- Artifacts 推荐路径：`.claude/` 或 `.brain/`
- 每次完成所有任务后，删除相应Artifacts文档。