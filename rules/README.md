# Agent 规则(Claude Code + Codex 共用)

一套规则,两个工具共用。本目录是唯一事实来源。

| 文件 | 层级 | 用途 |
|------|------|------|
| [agents-global.md](agents-global.md) | 用户全局(底层规则) | 跨项目的身份分工、工作流、安全红线、Git 约定 |
| [agents-project.md](agents-project.md) | 项目根目录(初始通用规则) | 新项目起步模板,填占位符后作为该项目的 AGENTS.md |

## 设计依据(2026-08)

- Codex 原生读取 AGENTS.md:全局 `~/.codex/AGENTS.md` + 项目根 `AGENTS.md`。
- Claude Code 原生只读 CLAUDE.md,**不直接读 AGENTS.md**;官方做法是在 CLAUDE.md 中用 `@AGENTS.md` 导入(Windows 下无需管理员权限,比符号链接省事)。
- 分层原则:全局层管"我如何与 Agent 协作",项目层只写增量(这个项目怎么跑),不重述全局规则。
- 规则文件保持精简:单文件 200 行以内;一条规则值不值得写,标准是"它能否改变 Agent 的实际行为"。过时的规则删除,不注释保留。

## 安装

### 全局层(装一次)

1. **Codex**:把 `agents-global.md` 的内容放到 `~/.codex/AGENTS.md`(Windows:`C:\Users\<你>\.codex\AGENTS.md`)。
   - 直接复制;或用符号链接保持自动同步(**须在 cmd.exe 中执行**,PowerShell/Git Bash 无此内建命令):
     `mklink C:\Users\<你>\.codex\AGENTS.md D:\project2\prompts\rules\agents-global.md`
     (PowerShell 替代:`New-Item -ItemType SymbolicLink -Path $env:USERPROFILE\.codex\AGENTS.md -Target D:\project2\prompts\rules\agents-global.md`)
2. **Claude Code**:把 `~/.claude/CLAUDE.md` 的内容替换为一行:
   `@D:/project2/prompts/rules/agents-global.md`
   (若绝对路径导入不生效,退回直接复制全文;两种方式 token 成本相同。)
3. 若你的 CODEX_HOME 指向本仓库,则本仓库根目录的 `AGENTS.md` 即 Codex 全局层,直接用 `agents-global.md` 内容替换它即可。
4. **旧版处置**:本仓库根目录的旧 `AGENTS.md` 与新全局层冲突(维护 MCP 清单、更严的 Planning 限制),两份并存会导致 Agent 行为不确定——安装新规则时删除旧版,或用项目模板重写为本仓库的项目规则。

### 项目层(每个新项目)

1. 复制 `agents-project.md` 到项目根目录,重命名为 `AGENTS.md`;填完所有 `{{占位符}}`,删除用不上的段落和文件头部注释。
2. 在项目根目录创建 `CLAUDE.md`,内容仅一行:`@AGENTS.md`。
3. 首次提交前自查:全文搜索 `{{` 确认无占位符残留。

### 安装验证(两台工具各做一次)

新开一个会话,让 Agent 复述全局规则中的 Git 约定——能答出"任务完成生成 commit message、等 'cp' 再提交推送"即确认两层均已加载;答不出说明导入/复制未生效。

## 维护约定

- 改全局规则:只改本目录 `agents-global.md`,再同步到 `~/.codex/AGENTS.md`;若 Claude Code 侧是复制安装(非 @导入、非符号链接),`~/.claude/CLAUDE.md` 也要同步更新。
- 项目规则随项目演进在各自仓库维护,不回抄到本目录。
