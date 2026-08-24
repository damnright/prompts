# Project Agent Rules

## Project Overview
- **Purpose**:
- **Primary users / scenarios**:
- **Tech stack**:
- **Runtime / versions**:
- **Supported platforms / environments**:

## Commands
仅填写项目真实可用的命令，不为补全模板而虚构。
- **Install**:
- **Dev**:
- **Test**:
- **Typecheck**:
- **Lint**:
- **Build**:
- **E2E / UI**:

## Architecture
- **Main entry points**:
- **Frontend / client**:
- **Backend / services**:
- **Database / storage**:
- **Shared modules**:
- **External services**:
- **Important boundaries / data flow**:

开始实现前，先读取与任务直接相关的 README、配置、目标文件及相邻实现；已有项目约定优先于通用偏好。

## Project Conventions
只记录无法由 formatter、lint、类型系统或现有代码可靠推断的重要约定。
- **Naming / code organization**:
- **UI / UX**:
- **API / database**:
- **Error / logging**:
- **Other project-specific rules**:

## Working Rules
- 只修改完成当前任务所必需的内容；发现超出范围的问题时报告，不自动扩大任务。
- 优先复用现有模式、组件、工具和依赖，不因个人偏好替换架构、库、命名或目录结构。
- 不擅自升级依赖、改变公共 API、引入新基础设施或新增长期抽象；确有必要时说明理由和影响。
- 修改前定位真实调用链和依赖关系；修复根因，不通过关闭校验或永久 workaround 掩盖问题。
- 不默认创建 `task.md`、`implementation_plan.md` 等过程文件；仅在跨会话、多阶段、多人/多 Agent 协作或需要持久状态时创建。

## Verification
按改动类型执行项目已有的相关验证：
- 业务逻辑：相关单元/集成测试；
- 类型或接口：typecheck + 相关测试；
- UI：相关页面/组件验证，必要时 E2E 或视觉检查；
- 构建或配置：build / start / smoke test；
- 数据库或 API：迁移安全、兼容性和相关测试；
- 依赖变更：安装、构建、启动及关键路径验证。

无法执行验证时，必须说明：**未验证什么、原因、剩余风险**。不能把“代码已修改”等同于“任务已完成”。

## Constraints
- **Must support**:
- **Must not break**:
- **Security / compliance**:
- **Performance / compatibility**:
- **Forbidden changes**:
- **Release / branch constraints**:

## Documentation
- **Primary docs**:
- **Architecture / API docs**:
- **Runbook / deployment docs**:

当变更影响长期存在的 API、配置、命令、架构、开发流程或公开行为时，同步更新对应文档。

## Definition of Done
- 需求已实现并符合项目约定；
- 没有明显无关改动；
- 相关验证已通过，或未验证项已明确说明；
- 必要文档已同步；
- 没有通过绕过错误、测试或校验来掩盖问题。
