# OpenClaw 主控的精简多 Agent 工作流（MacBook）

> 文件名：`openclaw-agent-workflow-v2.md`  
> 版本：2.0（根据原对话摘要恢复）  
> 恢复与核对日期：2026-09-02  
> 适用组合：OpenClaw + GPT-5.6 Sol + Native Codex + GLM-5.3 + GLM-5.3-Flash

## 0. 恢复说明

原计划文件 `/mnt/data/openclaw-multi-agent-workflow-macbook.md` 已不存在，且关联对话没有保留原附件正文。本文件依据关联对话中仍可读取的方案摘要、上一版双 Agent 指南，以及当前 OpenClaw 官方文档恢复。

恢复的核心原则是：

- OpenClaw 是常驻主控和自动编排层。
- 正式任务先冻结 brief，再让不同 Agent 独立分析，避免互相锚定。
- 主 Agent 负责证据裁决，而不是要求模型强行达成共识。
- Native Codex 是代码任务的唯一写入者。
- GLM-5.3 reviewer 默认只读；GLM-5.3-Flash 独立复核 UI、截图和 E2E 证据。
- 测试、浏览器、日志和截图证据优先于模型意见。
- ChatGPT Chat / Work 保留为外部专家台，不作为 OpenClaw 内部自动子 Agent 假装调用。

OpenClaw 的配置结构和模型目录可能随版本变化。本文中的 JSON5 是“起步配置”，使用前必须替换路径，并在 Gateway 所在 Mac 上执行 `openclaw config validate` 和实际冒烟测试。

## 1. 一句话结论

推荐把原来分散在 ChatGPT Work、Codex、Claude Code 侧车、自建 GLM MCP、shell wrapper 和未来 DAG 中的控制逻辑，收敛到 OpenClaw：

```text
                           你
                           │
                    OpenClaw Main
              路由 / 派单 / 状态 / 裁决
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
  独立方案分析        Native Codex        视觉与 E2E
 OpenAI + GLM-5.3      唯一代码写入者     Browser + GLM-Flash
        │                  │                  │
        └──────────────证据回传───────────────┘
                           │
                   Main 最终验收与交付
```

不再默认建设：

- Claude Code 侧车链路。
- 自建 GLM MCP bridge。
- 任意 shell wrapper。
- 过早的 DAG / 工作流平台。
- 多个 Agent 同时写同一份代码。

需要外部完整 coding harness 时，再使用 OpenClaw ACP 运行 Claude Code、Gemini CLI、OpenCode、Cursor 等；Native Codex 的默认路径应使用 OpenClaw 的 Codex app-server runtime，而不是 ACP。

## 2. 角色与权限边界

| 角色 | 推荐模型/runtime | 主要职责 | 默认权限 |
|---|---|---|---|
| `main` | GPT-5.6 Sol + OpenClaw runtime | 路由、冻结 brief、派单、状态、裁决、最终交付 | 可写协作工件；不写产品代码 |
| `analyst-openai` | GPT-5.6 Sol + OpenClaw runtime | 产品、市场、商业或架构的第一份独立方案 | 无代码写权限 |
| `analyst-glm` | GLM-5.3 | 第二份独立方案、反例、风险和替代路径 | 无代码写权限 |
| `codex` | GPT-5.6 Sol + Native Codex runtime | 阅读仓库、实施、修复、测试、集成 | 目标 worktree 内唯一写入者 |
| `reviewer-glm` | GLM-5.3 | 只读代码/方案审查、找遗漏、补测试建议 | 仓库只读，无 shell 写入 |
| `ui-reviewer` | GLM-5.3-Flash | 截图、页面状态、布局、可用性和视觉差异复核 | 证据只读；浏览器仅限测试环境 |

### 2.1 不可混淆的三个概念

- **Provider / model**：例如 `openai/gpt-5.6-sol`、`zai/glm-5.3`。
- **Agent runtime**：真正拥有模型循环和工具调用的一层，例如 `openclaw` 或 `codex`。
- **Channel**：用户从哪里进入，例如 OpenClaw UI、Telegram、Slack。

对 OpenAI agent 模型，未显式指定 runtime 时，符合条件的官方路由可能自动选择 Codex harness。为了让 `main` 明确由 OpenClaw 自身编排、让 `codex` 明确由 Native Codex 执行，本文在各自的 model policy 中显式写入 `agentRuntime.id`。

### 2.2 ChatGPT Work 的定位

ChatGPT Work 作为你主动打开的外部专家台，适合：

- 一次性深度研究或综合写作。
- 人工主持的高价值决策复核。
- 把 OpenClaw 审议包作为附件交给另一个独立环境检查。

不要把 ChatGPT Work 描述成 OpenClaw 已自动调用的内部子 Agent。除非你确实安装并验证了可用连接器或远程工具，否则两者没有自动调用关系。

## 3. 五种日常工作模式

| 模式 | 适用场景 | 默认流程 | 完成条件 |
|---|---|---|---|
| `solo` | 简单解释、低风险小任务 | Main 或最合适的单 Agent 直接完成 | 结果可快速人工检查 |
| `dual-review` | 产品、市场、商业方案 | OpenAI 与 GLM 独立方案 → 交叉审查 → Main 裁决 | 来源、假设、分歧和结论齐全 |
| `design-review` | 技术设计、架构、迁移 | Codex 只读分析 + GLM reviewer 独立分析 → ADR | 当前实现、替代方案、风险和验证计划齐全 |
| `implementation` | 代码修改、修复、重构 | Codex 独占 worktree 写入 → GLM 只读 review → Codex 修正并验证 | diff 与相关测试通过 |
| `ui-e2e` | 页面功能、UI、UE、视觉回归 | Codex/Browser 执行 → 固定证据 → GLM-Flash 复核 → Codex 最终复测 | 浏览器、控制台、请求和截图证据齐全 |

选择规则：

1. 用户显式指定模式时优先。
2. 涉及代码写入时，默认进入 `implementation`。
3. 涉及真实页面或视觉主张时，增加 `ui-e2e`。
4. 高风险、不可逆、生产、费用、权限或真实用户数据操作，无论模式都必须停在审批门。
5. 第二个 Agent 带来的成本明显高于收益，而且结果容易验证时，使用 `solo`。

## 4. 统一状态机

```text
DRAFT
  ↓
BRIEF_FROZEN
  ↓
INDEPENDENT
  ↓
CROSS_REVIEW
  ↓
ADJUDICATED
  ↓
AUTHORIZED
  ↓
IMPLEMENTING
  ↓
VERIFYING
  ↓
DONE
```

异常状态：

```text
BLOCKED | RED | NEEDS_USER_DECISION | CANCELLED
```

状态规则：

- brief 没冻结，不能进入独立分析。
- 独立阶段的 Agent 不能提前看到对方结论。
- 没有裁决，不进入代码实现。
- 涉及需审批动作时，没有 `AUTHORIZED` 不执行。
- 任一相关测试失败，立即进入 `RED`，不能用“两个模型都认为没问题”覆盖失败证据。
- 没有实际验证证据，不能进入 `DONE`。

## 5. 四个精简任务工件

每个正式任务只维护四个 Markdown 主工件，额外的日志、diff 和截图放入 `evidence/`：

```text
.ai-collab/tasks/TASK-001/
├── 00-brief.md
├── 10-proposals.md
├── 20-review.md
├── 30-decision.md
└── evidence/
    ├── tests/
    ├── browser/
    ├── screenshots/
    └── notes/
```

### 5.1 `00-brief.md`：唯一事实源

```markdown
# TASK-001

- Brief version: 1
- Status: DRAFT
- Base commit/snapshot:
- Goal:
- Non-goals:
- Known facts and sources:
- Unverified assumptions:
- Constraints:
- Acceptance criteria:
- Required evidence:
- Allowed files/directories:
- Forbidden actions:
- Risk level: low | medium | high
- User decisions already made:
- Actions requiring user approval:
```

目标、范围或验收标准变化时，先提高 `Brief version`，再让参与 Agent 同步。聊天历史不能成为隐性规格。

### 5.2 `10-proposals.md`：盲式独立方案包

```markdown
# Independent proposals

## Proposal A — OpenAI
- Recommendation:
- Evidence:
- Key assumptions:
- Alternatives and trade-offs:
- Failure modes:
- Validation plan:
- Confidence: low | medium | high

## Proposal B — GLM
- Recommendation:
- Evidence:
- Key assumptions:
- Alternatives and trade-offs:
- Failure modes:
- Validation plan:
- Confidence: low | medium | high
```

Main 必须先分别获得两份输出，再合并进同一文件。不要把 A 的全文放进 B 的首次任务，反之亦然。

### 5.3 `20-review.md`：编号交叉审查

```markdown
# Cross-review

## C-001
- Reviewer:
- Severity: blocker | major | minor
- Claim being challenged:
- Evidence or counterexample:
- Impact if unresolved:
- Suggested validation:

## Response to C-001
- Owner:
- Decision: accept | partially accept | reject
- Reason and evidence:
```

默认只做一轮交叉审查；复杂任务最多两轮。超过上限仍缺证据时，保留异议或交给用户，不进入无休止辩论。

### 5.4 `30-decision.md`：裁决与验收记录

```markdown
# Final decision

- Final recommendation:
- Agreed points:
- Disagreements resolved by evidence:
- Main Agent trade-offs:
- Unresolved dissent:
- Items requiring user decision:
- Authorized implementation scope:
- Verification performed:
- Evidence paths:
- Residual risks:
- Final status:
```

工件采用“新增或显式版本化”，不要静默覆盖旧结果。重跑时保留 brief 版本、模型、runtime、时间、状态和证据路径。

## 6. 四个证据与审批门

### Gate 1：Brief Freeze

进入条件：目标、非目标、约束、验收标准、证据要求和风险等级已写清。

未通过时：Main 继续澄清或采用低风险、可逆的明确默认值，并在 brief 中记录。

### Gate 2：Evidence Adjudication

进入条件：需要双审的任务已经得到相互独立的方案与编号审查；Main 能说明每个关键取舍依赖什么证据。

未通过时：补官方资料、仓库事实、数据、原型或实验。模型数量和模型一致性不算证据。

### Gate 3：Write / Approval

进入条件：写入范围、唯一写入者、基础 commit、回滚方案和需用户批准的动作已明确。

必须让用户决定的情况：

- 删除或不可逆覆盖重要数据。
- 生产环境、线上资源、真实用户数据、权限或认证变更。
- 明显费用、长期付费依赖或难回滚迁移。
- commit、push、部署、force push 或共享历史改写，除非用户已经明确授权相应动作。
- 多个方案会造成明显不同的产品、架构或业务结果，且证据无法可靠裁决。

### Gate 4：Independent Verification

进入条件：实现者自测完成，Main/Codex 独立复跑关键检查；视觉任务还要有真实浏览器和截图证据。

未通过时：进入 `RED` 或 `BLOCKED`，明确失败命令、现象、影响和下一步。不得把“已修改”写成“已完成”。

## 7. 各模式的标准工作流

### 7.1 `solo`

```text
用户请求
  → Main 判断低风险且容易验证
  → 单 Agent 完成
  → 做最小必要检查
  → 交付
```

升级条件：发现范围跨模块、结论依赖易变化事实、出现重要分歧、需要代码写入或视觉验收。

### 7.2 `dual-review`：产品 / 市场 / 商业方案

```text
Main 冻结 00-brief.md
  ├─ analyst-openai：只看同版 brief，独立输出 A
  └─ analyst-glm：只看同版 brief，独立输出 B
             ↓
        Main 形成 10-proposals.md
             ↓
        双方各做一轮编号 critique
             ↓
          20-review.md
             ↓
      Main 查证关键事实并裁决
             ↓
          30-decision.md
```

市场、价格、政策、产品能力、竞品和软件版本等易变化事实，必须在裁决前查最新一手来源。可选择：

- 共同证据包 + 独立推理：成本较低，适合普通方案。
- 独立检索 + 独立来源日志：独立性更强，适合高价值决策。

### 7.3 `design-review`：技术设计

1. Codex 只读检查项目规则、配置、调用链、相邻实现和测试。
2. GLM reviewer 基于同一技术 brief 独立提出方案和风险。
3. 双方交叉检查接口、数据流、并发、兼容性、安全、迁移、失败恢复和测试。
4. Main/Codex 用当前代码、官方文档、原型或基准测试裁决。
5. `30-decision.md` 输出 ADR、实施拆分和验证计划；本阶段不改代码。

### 7.4 `implementation`：代码实现

```text
已裁决的 00-brief.md + 30-decision.md
  → 创建/选择 managed worktree
  → Codex 成为唯一写入者
  → Codex 实施并运行相关检查
  → reviewer-glm 只读检查 diff 与测试缺口
  → Codex 逐项接受/拒绝并说明证据
  → Codex 独立重跑关键测试
  → DONE 或 RED
```

强制规则：

- 同一文件同一时间只有一个 Agent 写入。
- GLM reviewer 不修代码；它只输出可定位、可验证的问题。
- 不让 Main、reviewer 或 UI reviewer 绕过 Codex 修改产品代码。
- managed worktree 用于隔离任务分支和 checkout；移除或回收前先确认内容已经保留。
- 默认不 commit、不 push、不部署。

### 7.5 `ui-e2e`：浏览器、UI 与视觉验收

1. Codex 启动真实应用并记录可访问地址、进程或监听端口。
2. 固定测试账户、数据、视口、主题、语言和页面状态。
3. 使用 OpenClaw Browser 执行用户路径，记录页面快照、控制台错误和关键网络请求。
4. 保存关键步骤截图；若有设计稿或基准图，一起放入 `evidence/screenshots/`。
5. GLM-5.3-Flash 独立检查层级、间距、文本、状态、响应式、可访问性和差异。
6. Codex 复现每个重要问题，修复后重跑功能与截图证据。
7. Main 只在功能和视觉证据都满足验收标准时标记 `DONE`。

视觉审美偏好无法由证据裁决时，列出明确选项并交给用户。

## 8. OpenClaw 起步配置（JSON5）

配置文件通常位于 `~/.openclaw/openclaw.json`。下面是结构示例，不应覆盖已有配置。先把现有配置备份，通过 Control UI 或 `openclaw config patch --dry-run` 合并，并替换所有 `/ABSOLUTE/PATH/...` 占位路径。

```json5
{
  // 主机命令默认走 Guardian 审查。
  tools: {
    exec: { mode: "auto" },
    sessions: { visibility: "tree" },
  },

  plugins: {
    entries: {
      codex: {
        enabled: true,
        config: {
          appServer: {
            mode: "guardian",
          },
        },
      },
    },
  },

  agents: {
    ownership: "explicit",

    defaults: {
      skipBootstrap: true,
      models: {
        "openai/gpt-5.6-sol": {},
        "zai/glm-5.3": {},
        "zai/glm-5.3-flash": {},
      },
      subagents: {
        maxSpawnDepth: 1,
        maxChildrenPerAgent: 5,
        maxConcurrent: 5,
        runTimeoutSeconds: 1800,
        archiveAfterMinutes: 120,
      },
    },

    entries: {
      main: {
        name: "OpenClaw Main",
        workspace: "~/.openclaw/workspace-main",
        model: { primary: "openai/gpt-5.6-sol", fallbacks: [] },
        models: {
          "openai/gpt-5.6-sol": {
            agentRuntime: { id: "openclaw" },
          },
        },
        thinkingDefault: "max",
        sandbox: { mode: "off" },
        subagents: {
          requireAgentId: true,
          allowAgents: [
            "analyst-openai",
            "analyst-glm",
            "codex",
            "reviewer-glm",
            "ui-reviewer",
          ],
        },
        tools: {
          profile: "coding",
          alsoAllow: ["browser"],
          deny: ["exec", "process"],
        },
      },

      "analyst-openai": {
        name: "Independent OpenAI Analyst",
        workspace: "~/.openclaw/workspace-analyst-openai",
        model: { primary: "openai/gpt-5.6-sol", fallbacks: [] },
        models: {
          "openai/gpt-5.6-sol": {
            agentRuntime: { id: "openclaw" },
          },
        },
        thinkingDefault: "max",
        sandbox: {
          mode: "all",
          scope: "session",
          workspaceAccess: "none",
          docker: { network: "none" },
        },
        tools: {
          allow: ["web_search", "web_fetch"],
          deny: ["read", "write", "edit", "apply_patch", "exec", "process"],
        },
      },

      "analyst-glm": {
        name: "Independent GLM Analyst",
        workspace: "~/.openclaw/workspace-analyst-glm",
        model: { primary: "zai/glm-5.3", fallbacks: [] },
        thinkingDefault: "max",
        sandbox: {
          mode: "all",
          scope: "session",
          workspaceAccess: "none",
          docker: { network: "none" },
        },
        tools: {
          allow: ["web_search", "web_fetch"],
          deny: ["read", "write", "edit", "apply_patch", "exec", "process"],
        },
      },

      codex: {
        name: "Native Codex Implementer",
        workspace: "/ABSOLUTE/PATH/TO/REPO",
        model: { primary: "openai/gpt-5.6-sol", fallbacks: [] },
        models: {
          "openai/gpt-5.6-sol": {
            agentRuntime: { id: "codex" },
          },
        },
        thinkingDefault: "max",
        // 不启用普通 OpenClaw Docker sandbox；由 Codex Guardian 提供
        // workspace-write。活动的 OpenClaw sandbox 会关闭 Codex 原生 Code Mode。
        sandbox: { mode: "off" },
        tools: {
          profile: "coding",
          alsoAllow: ["browser"],
          exec: { mode: "auto" },
        },
      },

      "reviewer-glm": {
        name: "Read-only GLM Reviewer",
        workspace: "/ABSOLUTE/PATH/TO/REPO",
        model: { primary: "zai/glm-5.3", fallbacks: [] },
        thinkingDefault: "max",
        sandbox: {
          mode: "all",
          backend: "docker",
          scope: "session",
          workspaceAccess: "ro",
          docker: {
            network: "none",
            readOnlyRoot: true,
            capDrop: ["ALL"],
          },
        },
        tools: {
          allow: ["read"],
          deny: ["write", "edit", "apply_patch", "exec", "process", "browser"],
        },
      },

      "ui-reviewer": {
        name: "GLM Visual Reviewer",
        workspace: "/ABSOLUTE/PATH/TO/REPO",
        model: { primary: "zai/glm-5.3-flash", fallbacks: [] },
        thinkingDefault: "max",
        sandbox: {
          mode: "all",
          backend: "docker",
          scope: "session",
          workspaceAccess: "ro",
          docker: {
            network: "none",
            readOnlyRoot: true,
            capDrop: ["ALL"],
          },
        },
        tools: {
          allow: ["read", "browser"],
          deny: ["write", "edit", "apply_patch", "exec", "process"],
        },
      },
    },
  },

  // Control UI / talk surface 默认进入主控 Agent。
  talk: { agentId: "main" },
}
```

### 8.1 配置说明

- `main` 被显式固定为 `openclaw` runtime，负责协调而不是伪装成 Codex。
- `codex` 被显式固定为 `codex` runtime，并使用 Guardian。Guardian 在允许时对应 `on-request`、`auto_review` 和 `workspace-write`。
- `codex` 不放入普通 OpenClaw sandbox，因为活动 sandbox 会关闭 Native Codex Code Mode、用户 MCP 和 app-backed plugin execution；审查 Agent 才使用只读 Docker sandbox。
- `reviewer-glm` 和 `ui-reviewer` 的 repo workspace 只读。若你不希望多个 Agent 共用 repo 路径，可给它们独立 workspace，并通过 `sandbox.docker.binds` 把 repo 挂载为 `:ro`。
- 示例把分析 Agent 的 sandbox 网络设为 `none`，因此其中的 sandbox shell 无外网；若允许 `web_search` / `web_fetch`，网络请求仍应受相应工具策略和 Gateway 配置约束。高敏感任务可直接移除网络工具，改用 Main 提供的固定证据包。
- `ui-reviewer` 的浏览器权限只应用于测试环境。对会提交订单、发送消息、修改数据的页面，浏览器操作必须另设审批门。
- 多 Agent 路由需要显式入口或 binding；本文用 `talk.agentId = "main"` 作为 Control UI 默认入口，外部 channel 需按实际账号添加 bindings。

## 9. MacBook 安装与验证

### 9.1 安装 OpenClaw

优先使用官方 macOS 应用；CLI 用户也可使用官方安装器：

```zsh
curl -fsSL https://openclaw.ai/install.sh | bash
```

安装器脚本应先从官方站点人工核对再执行。完成后：

```zsh
openclaw --version
openclaw onboard
openclaw gateway status
```

### 9.2 配置 OpenAI / Codex

```zsh
openclaw models auth login --provider openai
openclaw models list --provider openai
```

如果当前账户不显示 `openai/gpt-5.6-sol`，不要静默替换；显式选择目录中可用的模型，并同步修改本文配置。

CLI 安装若还没有官方 Codex plugin：

```zsh
openclaw plugins install @openclaw/codex
openclaw plugins enable codex
openclaw plugins list --enabled
```

macOS 应用可能在启用 Codex 功能时自动安装。不要重复安装来源不明的同名 plugin。

### 9.3 配置 Z.AI / GLM

推荐通过 onboarding 让 OpenClaw 自动识别 Key 对应的区域和端点：

```zsh
openclaw onboard --auth-choice zai-api-key
openclaw models list --all --provider zai
```

确认目录中确实出现：

```text
zai/glm-5.3
zai/glm-5.3-flash
```

不要把 Key 写进仓库、任务工件或截图。使用 OpenClaw 的 auth/secret 存储；区域、Coding Plan 和普通 API Key 不要混用。

### 9.4 合并并验证配置

先查看实际配置路径和 schema：

```zsh
openclaw config file
openclaw config schema --json
```

把第 8 节保存为一个临时 patch，替换绝对路径后先 dry-run：

```zsh
openclaw config patch --file ./openclaw.patch.json5 --dry-run
openclaw config validate --json
openclaw doctor
```

确认无误再应用 patch，并按提示重启 Gateway。若现有配置已经失败，先运行：

```zsh
openclaw configure
openclaw doctor --fix
```

最后检查：

```zsh
openclaw agents list --bindings
openclaw models list --provider openai
openclaw models list --all --provider zai
openclaw browser status
openclaw config validate --json
```

在聊天中再检查 `/status`、`/codex status` 或 `/codex models`，确认实际完成结果记录的 runtime 是预期的 `openclaw` 或 `codex`。配置意图本身不是运行证据。

## 10. 项目 `AGENTS.md` 建议片段

把下面片段合并到项目已有 `AGENTS.md`，不要覆盖原规则：

```markdown
## OpenClaw 多 Agent 协作

- OpenClaw Main 负责路由、冻结 brief、派单、状态和最终裁决。
- 简单、低风险且容易验证的任务允许单 Agent 完成；用户显式模式优先。
- 产品、市场、商业和重要架构方案先让 OpenAI 与 GLM-5.3 基于同版 brief 独立输出，再做一轮编号交叉审查。
- Native Codex 是产品代码的唯一写入者；其他 Agent 默认不得修改代码。
- GLM-5.3 reviewer 只读代码和 diff，只报告可定位、可验证的问题与测试缺口。
- UI/E2E 由 Codex 或 OpenClaw Browser 获取真实运行证据，GLM-5.3-Flash 独立审查截图和页面状态。
- 主 Agent 按当前仓库、官方资料、真实数据、测试、浏览器和截图证据裁决；模型共识不能替代证据。
- 同一文件同一时间只能有一个写入者。发现范围重叠、brief 或基础 commit 漂移时停止并重新同步。
- 实现者自测不能替代 Codex 的独立验证。相关测试失败时状态进入 RED。
- 未经用户明确授权，不 commit、push、部署、操作生产、修改权限、产生明显费用或执行不可逆动作。
- 最终交付必须说明已验证项、证据、未验证项、剩余风险和未解决异议。
```

## 11. Main 的派单提示词

### 11.1 通用主控

```text
[mode: auto-route]

你是 OpenClaw Main。先把请求整理成同一版本的冻结 brief，再选择最低成本且足够可靠的模式。
需要双审时，让 Agent 先独立工作，禁止在首次输出前看到对方结论。
所有 critique 编号；你按证据裁决并保留未解决异议。
代码只交给 Native Codex 写；reviewer 不得修代码。
遇到生产、费用、权限、真实用户数据、删除、不可逆操作或显著业务分歧时停在用户审批门。
没有实际验证证据，不得宣称 DONE。
```

### 11.2 产品 / 市场双审

```text
[mode: dual-review]

冻结 00-brief.md。
分别把相同 brief 交给 analyst-openai 和 analyst-glm，使用 isolated context；两者首次输出不能包含对方答案。
把独立方案写入 10-proposals.md，再让双方进行一轮编号交叉审查，形成 20-review.md。
对易变化事实查一手来源，最后输出 30-decision.md：一致项、证据解决的分歧、你的取舍、未决异议和需用户决定的事项。
```

### 11.3 技术设计

```text
[mode: design-review]

本阶段只读。让 Codex 先检查仓库真实实现、项目规则、配置、调用链和测试；让 reviewer-glm 基于同版技术 brief 独立设计。
交叉检查 API、数据、并发、安全、兼容、迁移、失败恢复和测试。
最终输出 ADR、替代方案、拒绝原因、实施拆分和验证计划，不修改代码。
```

### 11.4 代码实现

```text
[mode: implementation]

仅在方案已裁决、写入范围已授权后开始。
为任务选择 managed worktree，记录 base commit。Native Codex 是唯一写入者。
Codex 实施并运行相关 lint/typecheck/unit/build/start/E2E；reviewer-glm 只读检查 diff 和测试缺口。
Codex 逐项处理 review 后独立重跑关键检查。任何相关检查失败则进入 RED。
不要自行 commit、push 或部署。
```

### 11.5 UI / E2E

```text
[mode: ui-e2e]

Codex 启动真实应用并给出进程/端口及直接访问证据。
固定数据、账户、视口、主题和语言，通过 OpenClaw Browser 完成关键用户路径，保存快照、请求、控制台错误和截图。
把固定证据交给 ui-reviewer 独立审查；Codex 复现、修复并重测。
只有功能和视觉证据都满足验收标准时才标记 DONE。
```

## 12. Main 的裁决规则

Main 可以自行裁决：

- 低或中风险、可逆。
- 当前仓库、官方资料、真实数据、原型或测试足以支持。
- 方案差异不会明显改变产品、商业或架构结果。

Main 必须交给用户：

- 生产、真实用户数据、费用、权限、安全或不可逆操作。
- 两个方案会造成明显不同的产品、商业或架构结果。
- 关键分歧缺少证据，无法可靠判断。
- 品牌、审美、风险偏好等本质上属于所有者的选择。

证据最低要求：

| 结论类型 | 最低证据 |
|---|---|
| 最新能力、价格、规则 | 官方一手资料，并记录核对日期 |
| 市场判断 | 多来源、真实用户数据或可解释估算 |
| 产品决策 | 用户问题证据、约束、原型或实验 |
| 架构结论 | ADR、原型、容量估算、基准测试或回滚方案 |
| 代码正确 | 相关 lint/typecheck/单测/构建/运行结果 |
| 功能正确 | 真实浏览器路径、请求、控制台和状态证据 |
| 视觉正确 | 基准图、实际图、差异与多模态复核 |

## 13. 失败与降级

| 故障 | 处理 |
|---|---|
| GLM 不可用或额度不足 | 低风险任务可由 Main 单独继续并标注“未完成副审”；高风险任务暂停 |
| OpenAI/Codex 模型不可用 | 显式选择已验证模型；不静默降级，不伪造原模型结果 |
| Codex plugin/runtime 启动失败 | 运行 `openclaw doctor`，核对 plugin、auth、model 和实际 runtime；在修复前不让其他 Agent接管写权限 |
| Reviewer sandbox 无法创建 | 任务保持未审查；不要直接改成无限制 host 权限 |
| 双方意见不一致 | 补证据；仍无法解决则保留异议或交给用户 |
| 测试失败 | 进入 `RED`，回到实现阶段 |
| 视觉结论冲突 | 固定视口、数据和状态重测；纯审美分歧交给用户 |
| brief / base commit 漂移 | 停止当前写入，提升 brief 版本或重建 worktree 后再执行 |
| Agent 声称成功但无证据 | 判定为未验证 |
| 讨论循环 | 一轮 critique、最多两轮修订，随后保留未决项 |
| Key 泄漏 | 停止任务、撤销 Key、清理暴露面并人工审计 |

## 14. 何时才需要 ACP、自建 MCP 或 DAG

### 使用 ACP

仅当任务确实需要外部完整 coding harness 时使用，例如 Claude Code、Gemini CLI、OpenCode 或 Cursor。ACP 会管理会话、后台任务和绑定，但外部 harness 的文件权限由其自身和所选 `cwd` 决定；它当前不等同于 OpenClaw sandbox。

### 自建 MCP

只有当现有 OpenClaw 工具和 provider 无法覆盖一个稳定、重复且边界清晰的外部能力时再建。MCP 只暴露窄工具，不暴露任意 shell；参数、可读写目录、审批和错误必须结构化。

### DAG / 自动工作流

满足以下条件后再建设：

- 已连续跑过至少 10～20 个真实任务。
- 四个工件和审批点基本不再变化。
- 人工调度成为可量化瓶颈。
- 能记录模型、runtime、brief 版本、输入输出、费用、耗时和验证状态。
- 超时、重试、幂等、取消和人工接管策略已经明确。

## 15. 推荐落地顺序

### 第一天

- 安装并完成 OpenClaw onboarding。
- 验证 OpenAI/Codex 和 Z.AI 模型目录。
- 启用 Native Codex plugin 与 Guardian。
- 创建六个角色，但先只启用 `main`、两个 analyst 和 reviewer。
- 用一个低风险产品方案跑通 `dual-review`。

### 第一周

- 用一个只读技术任务验证 `design-review`。
- 用一个小型、可回滚任务验证 managed worktree、Codex 独占写入和 GLM 只读 review。
- 固定首批 UI/E2E 的视口、数据、截图和浏览器证据格式。
- 记录耗时、token/费用、分歧、误报和返工。

### 稳定后

- 只对重复流程增加自动路由或定时任务。
- 根据真实瓶颈决定是否启用 ACP、MCP 或更深的 sub-agent nesting。
- 每次 OpenClaw 大版本升级后重新运行 schema 校验、doctor 和五模式冒烟测试。

## 16. 最终验收清单

### 安装与运行

- [ ] `openclaw --version` 正常。
- [ ] Gateway 已真实运行，`openclaw gateway status` 正常。
- [ ] `openclaw config validate --json` 通过。
- [ ] `openclaw doctor` 没有未处理的 blocker。
- [ ] OpenAI 和 Z.AI 目录显示实际可用模型。
- [ ] 完成结果中的 runtime 与角色设计一致。
- [ ] Key 未进入配置明文、仓库、任务工件或日志。

### 协作协议

- [ ] 所有 Agent 收到同一版本 brief。
- [ ] 独立阶段没有看到对方答案。
- [ ] critique 有编号、证据、严重度和影响。
- [ ] Main 区分一致、裁决、异议和用户待决项。
- [ ] 默认只有一轮交叉审查。

### 工程与验证

- [ ] Native Codex 是唯一代码写入者。
- [ ] 任务使用隔离 worktree，并记录 base commit。
- [ ] reviewer 的 repo 权限实际为只读。
- [ ] Codex 检查 diff 并独立重跑相关检查。
- [ ] 启动类任务有进程/端口和直接请求证据。
- [ ] UI/E2E 有真实浏览器、控制台、请求和截图证据。
- [ ] 未经授权没有 commit、push、部署或生产变更。

## 17. 官方资料

- [OpenClaw 安装](https://docs.openclaw.ai/install)
- [OpenClaw 配置与 JSON5 文件](https://docs.openclaw.ai/configuration)
- [OpenClaw Config CLI 与 validate](https://docs.openclaw.ai/cli/config)
- [Agent runtimes：OpenClaw 与 Codex 的边界](https://docs.openclaw.ai/concepts/agent-runtimes)
- [Native Codex harness](https://docs.openclaw.ai/plugins/codex-harness)
- [Codex harness 配置参考](https://docs.openclaw.ai/plugins/codex-harness-reference)
- [OpenClaw Sub-agents](https://docs.openclaw.ai/tools/subagents)
- [Managed worktrees](https://docs.openclaw.ai/concepts/managed-worktrees)
- [Sandboxing](https://docs.openclaw.ai/sandboxing)
- [Permission modes 与 Codex Guardian](https://docs.openclaw.ai/tools/permission-modes)
- [OpenClaw-managed Browser](https://docs.openclaw.ai/tools/browser)
- [Z.AI / GLM provider](https://docs.openclaw.ai/glm)
- [ACP agents](https://docs.openclaw.ai/tools/acp-agents)

---

本方案的关键不是“同时使用更多模型”，而是让每个角色有清晰权限，让独立分析真正独立，让分歧落到可验证证据上，并让唯一实现者对最终运行结果负责。
