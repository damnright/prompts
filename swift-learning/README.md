# Swift：类型、错误、内存与并发

[技术路线：第 4 项](../tech-list.md) · [通用学习流程](../learning-flow.md) · [环境操作](environment.md) · [对应实操](practice.md)

主教材为 **The Swift Programming Language（TSPL）**。先用 A Swift Tour 建立全貌，再针对影响正确性的机制补读 Language Guide。语法达到能查、能读、能修改；Optional、值与引用、错误、生命周期和取消需要能解释。

## 1. 本轮目标与边界

用 Swift 表达单词、作答、加载状态，并能说明一次异步操作何时成功、失败或取消。SwiftUI 的页面和状态归属在[下一个目录](../swiftui-learning/README.md)学习；这一步不引入网络库或完整 App 架构。

按[环境操作](environment.md)复用 Xcode。书籍网站可能显示比已安装编译器更新的语言版本，优先使用本机支持的语法；本目录例子以 Swift 6 语言模式检查，不要求升级到测试版工具链。

## 2. 阅读单元与对应实操

S1～S5 合起来对应总路线的实操 4。先连续读完一组指定章节，再做本地例子。

| 单元 | 资料与具体范围 | 深度与暂缓内容 | 实操 |
| --- | --- | --- | --- |
| S1：值、分支与 Optional | [A Swift Tour](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/guidedtour/) 的 Simple Values、Control Flow；[The Basics](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/thebasics/) 的 Constants and Variables、Type Safety and Type Inference、Optionals 下 nil / Optional Binding / Providing a Fallback Value / Force Unwrapping | 基础识读；理解缺失值、条件解包、默认值与强制解包的后果 | [S1](practice.md#s1) |
| S2：集合、函数与闭包 | A Swift Tour 的 Functions and Closures；[Collection Types](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/collectiontypes/) 的 Arrays、Sets、Dictionaries 中创建、访问修改与遍历；[Functions](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/functions/) 的 Function Parameters and Return Values、Function Argument Labels and Parameter Names | 能识读 filter / map / sorted 的闭包；复杂泛型、函数式组合和自定义运算符暂缓 | [S2](practice.md#s2) |
| S3：模型与值 / 引用 | A Swift Tour 的 Objects and Classes、Enumerations and Structures、Protocols and Extensions、Generics；[Structures and Classes](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/classesandstructures/) 的 Structures and Enumerations Are Value Types、Classes Are Reference Types | 理解复制与共享、enum 表达状态；protocol 和泛型先认识用途，不为每个类型抽协议 | [S3](practice.md#s3) |
| S4：错误与资源生命周期 | [Error Handling](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/errorhandling/) 的 Representing and Throwing Errors、Handling Errors、Specifying Cleanup Actions；[Automatic Reference Counting](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/automaticreferencecounting/) 的 How ARC Works、Strong Reference Cycles for Closures、Resolving Strong Reference Cycles for Closures | 理解 throws / do-catch / defer，辨别 nil 与失败；理解循环引用和捕获列表，unowned 细节按需 | [S4](practice.md#s4) |
| S5：异步、取消与隔离 | [Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/) 的 Defining and Calling Asynchronous Functions、Tasks and Task Groups 的基本任务概念、Task Cancellation、Unstructured Concurrency、Isolation、The Main Actor、Actors、Sendable Types | 理解挂起、取消协作、隔离和跨域传值；复杂任务组、执行器与锁暂缓 | [S5](practice.md#s5) |

## 3. 设计判断：从语法连接到产品

- **Optional** 表示缺失，不应把缺失例句强制变成“接口坏了”；解析失败与接口没提供字段也不是同一件事。
- **struct / enum** 适合表达值与互斥状态；需要共享身份和持续观察的对象再考虑 class。不要以“后面也许会扩展”为由全面改成引用类型。
- **错误** 先区分用户可以修正、可以重试、应当取消和需要排查的问题；`try?` 会丢掉错误原因，只在这种丢失符合语义时使用。
- **异步** 不自动等于在后台线程执行。隔离由类型、函数、任务上下文和项目设置决定，不能靠函数名称中有 `async` 推断。
- **actor** 保护其隔离状态，但 `await` 让出执行后，之前读到的状态可能已经改变。搜索先后返回、页面离开后回调等仍要设计。
- **取消** 是协作信号，不是强制杀死，更不自动撤销服务端写入。UI 取消加载通常不应显示普通失败弹窗。

## 4. 完成标准

能运行并解释本地例子，用 Optional、类型和错误表达真实边界；能指出一处引用共享和一处循环引用风险；能取消异步工作、解释隔离并避免过期结果覆盖新状态。允许查阅语法，不要求从零默写所有例子。

继续 [SwiftUI 第 5～6 项](../swiftui-learning/README.md)，把本目录的单词类型用于同一个列表、详情与编辑流程。
