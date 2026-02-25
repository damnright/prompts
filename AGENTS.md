# Agent 工作规范

## 行为准则

- **sequential-thinking** 分析复杂任务
- **大改动**（>50行 或 跨多文件 或 架构变更）需先列出细节，用户回复 "ok" 后执行
- **小改动**（单文件 <50行 的明确修改）可直接执行
- git 任务完成时生成 commit message，用户回复 "cp" 时提交推送
- 需要读取设计图时，使用 figma MCP
- utf8 编码

## Planning Mode（仅复杂任务）

**核心理念**：Thinking before Coding（谋定而后动）。

**工作流程**：

1. **研究**：使用搜索工具扫描相关文件，理解架构与依赖
2. **起草计划**：大任务创建计划，明确目标、变更、验证计划
3. **用户确认**：展示计划，**严禁**在批准前修改生产代码
4. **执行**：计划获批后，严格按计划编码

## MCP 调用规则（按需调用，非强制）

### 通用总则

- 只在需要时调用 MCP
- 只读先行：先检索/取证，确认后再改动
- 禁止执行 `rm -rf` 等破坏性命令
- 密钥/令牌使用环境变量注入，不写入仓库

### 可用 MCP 清单

| MCP | 触发场景 |
|-----|----------|
| **sequential-thinking** | 分解复杂问题、规划步骤、评估方案/风险 |
| **filesystem** | 浏览/读取项目文件、改动前取证 |
| **deepwiki** | 查阅库/框架文档、API 用法、版本差异 |
| **fetch** | 抓取单页权威内容、发布说明 |
| **memory** | 沉淀环境/依赖版本/踩坑记录 |
| **playwright** | 自动化测试、UI 验证 |
| **figma** | 读取设计稿 |

### 执行流程

```
sequential-thinking 分析 → 只读取证 → 形成提案 → 得到"ok" → 最小改动 → 验证 → 沉淀
```

## Artifacts（按需创建，非强制）

仅在复杂任务时创建，保持 Single Source of Truth。文件名只是建议，可自定义

### implementation_plan.md（大改动时创建）

- **Goal**: 简明目标描述
- **User Review Required**: ⚠️ 破坏性变更、依赖变更
- **Proposed Changes**: 按文件列出，使用 `[NEW]`/`[MODIFY]`/`[DELETE]` 前缀
- **Verification Plan**: 测试命令或验证步骤

### task.md（多阶段任务时创建）

```markdown
- [x] 已完成任务
- [/] 进行中任务
- [ ] 待办任务
```
