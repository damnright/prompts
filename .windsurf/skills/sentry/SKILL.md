---
name: sentry
description: Sentry 错误监控集成与问题排查
compatibility: Requires @sentry/vue package
---

## when to use
Use this skill when the user needs to set up, configure, or troubleshoot Sentry error monitoring.

## setup

1. **安装依赖**：
   ```bash
   pnpm add @sentry/vue
   ```

2. **在 main.js 中初始化**：
   ```javascript
   import * as Sentry from '@sentry/vue'

   Sentry.init({
     app,
     dsn: import.meta.env.VITE_SENTRY_DSN,
     integrations: [
       Sentry.browserTracingIntegration(),
       Sentry.replayIntegration(),
     ],
     tracesSampleRate: 1.0,
     replaysSessionSampleRate: 0.1,
     replaysOnErrorSampleRate: 1.0,
   })
   ```

3. **环境变量**：`VITE_SENTRY_DSN` 存放在 `.env` 文件中，不提交到仓库

## error handling

- **自动捕获**：未处理的异常和 Promise rejection 自动上报
- **手动上报**：`Sentry.captureException(error)` / `Sentry.captureMessage('msg')`
- **用户上下文**：`Sentry.setUser({ id, email })`
- **面包屑**：`Sentry.addBreadcrumb({ category, message, level })`

## source map upload

```bash
pnpm add -D @sentry/vite-plugin
```

在 `vite.config.js` 中配置 `sentryVitePlugin`，构建时自动上传 source map。
