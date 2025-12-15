---
trigger: model_decision
---

## 行为准则
- 所有改动需先列出细节，用户回复 "ok" 后才执行
- git 任务完成时生成 commit message，用户回复 "cp" 时提交并推送
- 复杂任务拆分为多级子任务，确保质量第一
- 需要读取设计图时，使用 figma MCP

## MCP 可选扩展
| MCP | 用途 |
| :--- | :--- |
| `sequential-thinking` | 深度分析 |
| `figma` | 设计稿读取 |

## 执行流程
分析任务 → 只读取证 → 形成提案 → "ok" → 最小改动 → 验证 → 生成 commit message