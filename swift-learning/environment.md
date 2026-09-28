# Swift / SwiftUI 共用环境：复用 Xcode

[Swift 导读](README.md) · [SwiftUI 导读](../swiftui-learning/README.md)

本页统一说明 Swift 与 SwiftUI 的工具环境，不为两个目录分别安装工具链。

## 1. 检查已有工具

```sh
xcode-select -p
xcrun swift --version
xcrun --find swiftc
```

先记录实际 Xcode、Swift 编译器版本。Xcode 中再查看工程的 **Swift Language Version、Default Actor Isolation（如有）、iOS Deployment Target**；编译器版本、语言模式和最低 iOS 版本是三项不同的设置。

如果没有完整 Xcode，跟随 Apple [Develop in Swift](https://developer.apple.com/tutorials/develop-in-swift/) 的 Getting started → Meet Xcode、Create a project 配置。先检查已安装内容，不重复下载 Xcode 或另装 Swift 工具链。命令行工具足以运行部分语言例子，iOS 模拟器与界面练习需要完整 Xcode。

## 2. 运行本目录的语言例子

从本目录执行：

```sh
cd /Users/yuyang/Projects/prompts/swift-learning
xcrun swift -swift-version 6 Basics.swift
```

预期输出见[实操 S1～S4](practice.md#s1)。并发例子包含 `@main`，按下面编译后运行；产物放进新建临时目录，避免覆盖已有可执行文件：

```sh
swift_lab_dir=$(mktemp -d /tmp/swift-learning.XXXXXX)
xcrun swiftc -swift-version 6 -parse-as-library Concurrency.swift \
  -o "$swift_lab_dir/concurrency"
"$swift_lab_dir/concurrency"
```

只需记录结果，不保存编译产物到仓库。结束后可在 Finder 打开该临时目录，只删除本次创建的可执行文件与空目录；不要清理其他工程的缓存或产物。

## 3. 建立一个可持续复用的 App

1. 在 Xcode 新建 **iOS App**，使用 Swift 与 SwiftUI；已有学习 App 则继续复用它。工程放在自己选择的练习位置，不把示例代码覆盖到现有产品。
2. 教学基线选 **iOS 17 或更高**，用于 Observation / `@Observable`。这是学习示例的选择，产品最低版本仍由产品需求决定；若必须兼容更老系统，改用对应的 ObservableObject / StateObject 方案，别混用两套所有权规则。
3. 选已安装的 iPhone 模拟器，运行默认页面，再加 iPad 模拟器。缺少运行时才在 Xcode 中补装所需平台版本，不下载全部平台。
4. 用断点暂停按钮动作，观察变量；按 Apple 教程 App refinement → Investigate and fix a bug 定位一次自己引入的错误。
5. 纯语法例子使用本目录的命令行入口；App 工程只加入将复用的模型和页面，不把两个带入口的示例文件整体拖入 App target。

模拟器初期不要求配置付费开发者服务。真机签名、设备信任、最低系统和连接要求按 Xcode 实际提示处理；不为运行预览修改生产签名配置。

## 4. 遇到问题先分层

| 现象 | 检查与处理 |
| --- | --- |
| 命令行找不到 SDK / 编译器 | 对照 xcode-select 输出和 Xcode 设置，确认使用预期工具；不要先重装所有依赖 |
| 教材 API 不可用 | 查看 API availability、Deployment Target 与教材版本 |
| 并发隔离或 Sendable 报错 | 标明对象归属和跨域数据，再调整类型；不关闭检查或随意加 unchecked |
| Preview 不工作但 App 能运行 | 看预览专用诊断，继续用模拟器验证，不把预览状态当成启动证据 |
| 编译通过但页面行为错误 | 断点和状态流检查；构建成功只证明能编译 |

停止正在运行的练习 App 即可；练习暂不使用账号、数据库或云资源。
