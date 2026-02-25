---
trigger: always_on
---

## 技术选型

- 画布渲染引擎 leaferjs 画布相关功能实现时要深入理解、参考leaferjs源码，leaferjs源码位于node_modules目录下
- 基础框架：vue vite axios pnpm '@tanstack/vue-query'
- 错误监控：sentry

## 画布
- 画布中有四种节点：文本、图片、视频、音频；1 种连线；2 种 combo：由节点和连线组成，均为矩形，一种为框选后的临时 combo（无边框淡背景，取消框选后 combo 解组），另一种为框选后确认为组合的正式 combo（有边框深背景）
- 画布渲染：leaferjs
- 节点渲染2态：Normal（Canvas 节点）、Edit（强交互编辑态，单例，使用dom，位于overlay层，不随画布缩放变化）
  - Overlay 同步采用 Viewport 父层 transform（pan/zoom O(1)），节点变化只更新变更 Overlay（O(changed)）
- 节点 kind 与 Port 规则：
  - 四种基本节点 `text | image | video | audio` 各有 `raw`、`inference` 两种 kind
  - `raw`（原始素材：用户编辑的纯文本或上传的图片/视频/音频）：只有 `next` port（右侧）
  - `inference`（推理生成：通过提示词生成的资源）：有 `pre`（左侧）+ `next`（右侧）
  - `combo`（组合节点）：只有 `next` port（右侧），内部 kind 等效 `raw`
- 连线（ports）：左右固定 `pre/next`；只允许 next→pre，反向拖拽自动纠正；raw/combo 无 pre 口因此不能作为 target；连线行为实现 TBD（以验收点约束）> 拖拽画布

## 项目概要
项目类似tapnow： https://app.tapnow.top/，你可先深入研究下tapnow产品和代码逻辑
第一版功能有：
- 工作台：画布编辑、工作流（核心功能）大概样式见 https://www.figma.com/design/i3x3VpzTssn6JRjKjL6t1s/xWoW-%E7%AC%AC%E4%B8%80%E6%9C%9F--Copy-?node-id=4-10775&m=dev
- 消息通知
- 登录注册
- 支付充值、消费记录
- 我的资产
