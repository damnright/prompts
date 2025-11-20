# Common Prompts

尽量使用ask模式  比agent模式性能好

AI工作模式，提示词的质量极大影响产品质量

## prototype design

1. 您是一位熟练的开发人员，精通 HTML 、JavaScript 、CSS 和 TailwindCSS 。请根据以下要求创建一个网页：使用 Font Awesome 图标和 fakeimg 处理图片占位，确保页面设计美观且响应式，包含必要的 HTML 结构和样式。
   Font Awesome 使用 cloudflare 提供的 CDN 服务，而不要使用 kit.fontawesome.com 提供的 CDN 服务
2. 根据 HTML 提炼出界面模板，也就是相同的 HTML 文档结构、头部导航栏、底部导航栏，预留出主要内容区域
3.

## UI design

### html设计稿：

1. 您是一位专业的 UI 设计师，精通 Figma、Sketch 等工具。请根据以下要求创建一个界面：使用 Figma 或 Sketch 提供的组件库，确保界面设计美观且响应式，包含必要的 UI 组件和样式。
2. {{“优秀 html 案例”}}
   {{用来做什么/需求}} 的 app/ios/网页应用，请模拟用户来提出需求，请自己构思好功能需求和界面，然后设计 UI/UX，然后给我所有页面的 html
3. https://ew6rccvpnmz.feishu.cn/wiki/ILO2waqXLi1EvqkuKHvcceMOnVd?fromScene=spaceOverview
```markdown
你是一位资深 SVG 绘画设计师，现需根据以下产品需求创建SVG方案：

产品需求文档：
1. 应用类型：高端健康管理移动应用
2. 核心模块：
   - 数据仪表盘 (实时健康指标)
   - 运动计划系统 (训练课程+进度追踪) 
   - 睡眠质量分析 (多维数据可视化)
   - 营养管理 (智能食物数据库)
3. 交互要求：
   • 全矢量图形界面
   • 动态数据可视化动画
   • 符合Figma设计规范
   • 三级明暗层级关系

技术规格：
▸ 单文件SVG包含6个横向排列的页面预览
▸ 画板尺寸：375x812（带1px描边模拟手机边框）
▸ 配色方案：深空蓝(#1A202C)+活力橙(#DD6B20)+医疗白(#F7FAFC) 
▸ 必须包含：
   - 矢量图标系统（使用<symbol>定义）
   - 动态折线图（stroke-dasharray动画）
   - 卡片悬浮效果（通过filter实现）
   - 图片占位使用<image>标签外链unsplash

 
   
输出流程：
1. 先确认信息架构和交互流程
2. 分阶段输出SVG代码（每完成2个页面请求确认）
3. 最终生成完整可运行的svg文件
```

```markdown
我想开发一个旅行行程规划app，现在需要输出高保真的原型图，请通过以下方式帮我完成所有界面的原型设计，并确保这些原型界面可以直接用于开发：

1、核心需求：新建行程、目的地推荐、天气预警、小红书攻略识别

2、用户体验分析：先分析这个 App 的主要功能和用户需求，确定核心交互逻辑。

3、产品界面规划：作为产品经理，定义关键界面，确保信息架构合理。

4、高保真 UI 设计：作为 UI 设计师，设计贴近真实 iOS/Android 设计规范的界面，使用现代化的 UI 元素，使其具有良好的视觉体验。

5、HTML 原型实现：使用 HTML + Tailwind CSS（或 Bootstrap）生成所有原型界面，并使用 FontAwesome（或其他开源 UI 组件）让界面更加精美、接近真实的 App 设计。

拆分代码文件，保持结构清晰：
6、每个界面应作为独立的 HTML 文件存放，例如 home.html、profile.html、settings.html 等。
- index.html 作为主入口，不直接写入所有界面的 HTML 代码，而是使用 iframe 的方式嵌入这些 HTML 片段，并将所有页面直接平铺展示在 index 页面中，而不是跳转链接，index.html不需要副标题和需求介绍，iframe所在的div，尺寸375x812。
- 真实感增强：
  - 界面尺寸应模拟 iPhone 15 Pro，并让界面圆角化，隐藏所有横向/竖向滚动条并保留滚动功能，尺寸375x812，使其更像真实的手机界面。
  - 使用真实的 UI 图片，而非占位符图片（可从 Unsplash、Pexels、Apple 官方 UI 资源中选择）。
  - 添加顶部状态栏（模拟 iOS 状态栏），并包含 App 导航栏（类似 iOS 底部 Tab Bar）。
   
7、风格需要具有视觉冲击力和美感，配色可以大胆一点
  - index.html不需要风格设计
  1. 高级视觉层次
   - 使用玻璃拟态
   - 多层阴影系统
  2. 交互细节
   - 悬停时组件的微缩放
   - 按钮点击的粒子动画效果（通过JavaScript动态生成span元素）
   - 聚焦状态的光晕扩散（box-shadow过渡）
   
8. 生成代码前，先构思哪部分代码可以复用，生成js或者css文件

   - 导航条和状态栏可以以innerHTML的方式引入（导航条和状态栏需要有悬浮效果，上下拖动时，已经保留在顶部或者底部），宽度375
   - css可以以link方式引入
   
按照以上要求先生成2个页面代码
```

```markdown
我想开发一个{类似小宇宙的播客app}，现在需要输出高保真的原型图，请通过以下方式帮我完成所有界面的原型设计，并确保这些原型界面可以直接用于开发：
1、用户体验分析：先分析这个 App 的主要功能和用户需求，确定核心交互逻辑。
2、产品界面规划：作为产品经理，定义关键界面，确保信息架构合理。
3、高保真 UI 设计：作为 UI 设计师，设计贴近真实 iOS/Android 设计规范的界面，使用现代化的 UI 元素，使其具有良好的视觉体验。
4、HTML 原型实现：使用 HTML + Tailwind CSS（或 Bootstrap）生成所有原型界面，并使用 FontAwesome（或其他开源 UI 组件）让界面更加精美、接近真实的 App 设计。
拆分代码文件，保持结构清晰：
5、每个界面应作为独立的 HTML 文件存放，例如 home.html、profile.html、settings.html 等。
- index.html 作为主入口，不直接写入所有界面的 HTML 代码，而是使用 iframe 的方式嵌入这些 HTML 片段，并将所有页面直接平铺展示在 index 页面中，而不是跳转链接。
- 真实感增强：
- 界面尺寸应模拟 iPhone 15 Pro，并让界面圆角化，使其更像真实的手机界面。
- 使用真实的 UI 图片，而非占位符图片（可从 Unsplash、Pexels、Apple 官方 UI 资源中选择）。
- 添加顶部状态栏（模拟 iOS 状态栏），并包含 App 导航栏（类似 iOS 底部 Tab Bar）。
  请按照以上要求生成完整的 HTML 代码，并确保其可用于实际开发。
```
```markdown
## 你是谁

你是一位资深全栈工程师，设计工程师，拥有丰富的全栈开发经验及极高的审美造诣，擅长现代化设计风格，擅长移动端设计及开发。

## 你要做什么

1. 用户将提出一个【APP 需求】
2. 设计这个【APP 需求】，模拟产品经理提出需求和信息架构，请自己构思好功能需求和界面

> 下面这两个步骤，每一个小功能（根据功能划分，可能有多个页面）就输出一个html，输出完成后提示用户是否继续，如果用户输入继续，则继续根据按照下面步骤输出下一个功能的 UI/UX 参考图

3. 然后使用 html + tailwindcss 设计 UI/UX 参考图
4. 调用【Artifacts】插件可视化预览该 UI/UX 图（可视化你编写的 html 代码）

## 要求

- 要高级有质感（运用玻璃拟态等视觉效果），遵守设计规范，注重UI细节
- 请引入 tailwindcss CDN 来完成，而不是编写 style 样式，图片使用 unslash，界面中不要有滚动条出现
- 图标使用 Lucide Static CDN 方式引入，如`https://unpkg.com/lucide-static@latest/icons/XXX.svg`，而不是手动输出 icon svg 路径
- 将一个功能的所有页面写入到一个 html 中（为每个页面创建简单的 mockup 边框预览，横向排列），每个页面在各自的 mockup 边框内相互独立，互不影响
- 思考过程仅思考功能需求、设计整体风格等，不要在思考时就写代码，仅在最终结果中输出代码
```
```markdown
#角色
你是一位资深前端开发工程师

#设计风格
优雅的极简主义美学与功能的完美平衡;
清新柔和的渐变配色与品牌色系浑然一体;
恰到好处的留白设计;
轻盈通透的沉浸式体验;
信息层级通过微妙的阴影过渡与模块化卡片布局清晰呈现;
用户视线能自然聚焦核心功能;
精心打磨的圆角;
细腻的微交互;
舒适的视觉比例;
强调色：按APP类型选择;

#技术规格
1、单个页面尺寸为 375x812PX，带有描边，模拟手机边框
2、图标:引用在线矢量图标库内的图标(任何图标都不要带有背景色块、底板、外框）
3、图片: 使用开源图片网站链接的形式引入
4、样式必须引入 tailwindcss CDN来完成
5、不要显示状态栏以及时间、信号等信息
6、不要显示非移动端元素，如滚动条
7、所有文字只可以使用黑色或白色

#任务:
这是一个【番茄钟】APP
模拟产品经理输出详细功能设计、信息架构设计，结合{设计风格}和{技术规格}输出一套UI设计方案。
生成一个Ul.html文件，放入所有页面，横向排列。
现在生成前【2】个页面。
```
```markdown
我会给你一个文件，分析内容，并将其转化为美观漂亮的中文可视化网页：

## 内容要求
- 所有页面内容必须为简体中文
- 保持原文件的核心信息，但以更易读、可视化的方式呈现
- 在页面底部添加作者信息区域，包含：
  * 作者姓名: [作者姓名]
  * 社交媒体链接: 至少包含GitHub、Twitter/X、LinkedIn等主流平台
  * 版权信息和年份

## 设计风格
- 整体风格参考Linear App的简约现代设计
- 使用清晰的视觉层次结构，突出重要内容
- 配色方案应专业、和谐，适合长时间阅读

## 技术规范
- 使用HTML5、TailwindCSS 3.0+（通过CDN引入）和必要的JavaScript
- 实现完整的深色/浅色模式切换功能，默认跟随系统设置
- 代码结构清晰，包含适当注释，便于理解和维护

## 响应式设计
- 页面必须在所有设备上（手机、平板、桌面）完美展示
- 针对不同屏幕尺寸优化布局和字体大小
- 确保移动端有良好的触控体验

## 图标与视觉元素
- 使用专业图标库如Font Awesome或Material Icons（通过CDN引入）
- 根据内容主题选择合适的插图或图表展示数据
- 避免使用emoji作为主要图标

## 交互体验
- 添加适当的微交互效果提升用户体验：
  * 按钮悬停时有轻微放大和颜色变化
  * 卡片元素悬停时有精致的阴影和边框效果
  * 页面滚动时有平滑过渡效果
  * 内容区块加载时有优雅的淡入动画

## 性能优化
- 确保页面加载速度快，避免不必要的大型资源
- 图片使用现代格式(WebP)并进行适当压缩
- 实现懒加载技术用于长页面内容

## 输出要求
- 提供完整可运行的单一HTML文件，包含所有必要的CSS和JavaScript
- 确保代码符合W3C标准，无错误警告
- 页面在不同浏览器中保持一致的外观和功能

请根据上传文件的内容类型（文档、数据、图片等），创建最适合展示该内容的可视化网页。
```
## web development

1. 您是一位全栈开发专家

## entire project
Please generate a single-file React application for a "Retro Camera Web App" with the following specifications:



1. Visual Layout & Container Strategy

- Theme: Retro aesthetic with a "Handwritten" font style for all text.

- Title: "Bao Retro Camera" displayed at the top center.

- Instructions: Display usage instructions at the bottom right.

- Main Camera Container: 

 - Create a fixed wrapper `div` that acts as the parent for the camera image, viewfinder, shutter button, and photo ejection slot.

 - Positioning: This container must be fixed at exactly 64px from the bottom and 64px from the left of the viewport (`bottom: 64px; left: 64px;`).

 - Dimensions: Width 450px, Height 450px.

 - Z-index: 20

 - All subsequent positioning coordinates (percentages) for camera elements are relative to this container.

- Background Image within Container:

 - Image Source: `https://s.baoyu.io/images/retro-camera.webp`﻿

 - Size: 100% width and height of the container.

 - Position: Left 0, Bottom 0



2. Camera Functionality (The Viewfinder)

- Access the user's webcam.

- Viewfinder Position: The live video feed must be masked to a circle and positioned exactly over the camera lens.

- CSS for Video (Relative to Container): `bottom: 32%; left: 62%; transform: translateX(-50%); width: 27%; height: 27%; border-radius: 50%;z-index: 30`.

- Layering: The video must sit *above* the camera base image visually but within the container.



3. Shutter & Photo Interaction

- Shutter Button: Create an invisible clickable area over the camera's button.

- CSS for Button (Relative to Container): `bottom: 40%; left: 18%; width: 11%; height: 11%; cursor: pointer;z-index: 30`.

- Action: When clicked, play a shutter sound effect and trigger the "Photo Ejection" animation.



4. Photo Ejection & Development Animation

- Aspect Ratio: The generated Polaroid-style photo card must strictly follow a 3:4 portrait aspect ratio (Vertical).

- Ejection Animation: The photo paper slides UPWARDS (negative Y) from behind the camera body.

- Layering: The photo must appear to emerge from *inside* the camera (start with z-index(10) lower than camera body, then animate out).

- Ejection Container Origin CSS: `transform: translateX(-50%); top: 0; left: 50%; width: 35%;height: 100%;` (start position relative to the camera container).

- Ejection Container anmiation position from: ` translateY(0)` to ` translateY(-40%)`

- Developing Effect: Once the photo is taken, the image on the paper should transition from white/blurry to clear/sharp over a few seconds.



5. Drag & Drop "Photo Wall"

- Interaction: The user must be able to drag the ejected photo *out* of the camera slot and drop it anywhere on the rest of the screen (the "Photo Wall").

- Drag Handle: The entire Polaroid card (the white frame and the photo) must be interactive. The user should be able to click and drag from any part of the card to move it.

- Logic: While developing, the photo is attached to the camera container. Once dragged, it becomes absolutely positioned on the main screen body.

- Freedom: Once on the wall, photos can be dragged and repositioned freely.



6. AI Integration & Text Interactions

- Caption Generation: Use the Gemini Flash API to analyze the captured image content.

- Prompt: Generate a warm, short blessing or nice comment based on the photo content.

- Language Requirement: The generated text language must match the user's browser language.

- Footer Layout: The bottom of the Polaroid paper (below the image) should display the current date and the AI-generated text.

- Text Interaction & Icons:

 - When hovering specifically over the text area, display two small icons:

 1. Pencil Icon: Enters edit mode.

 2. Refresh Icon: Re-triggers the AI generation for that specific photo to get a new caption.

- Editing Logic:

 - Trigger: Edit mode can be entered by clicking the Pencil icon OR by double-clicking the text itself.

 - Behavior: When editing, replace the text display with an input/textarea showing the raw text.

 - Controls: Pressing Enter saves the changes. Pressing Esc cancels the edit and reverts to the previous text.



7. Photo Controls (Card Level)

- Hover Actions: When hovering over a developed photo card on the wall (general hover), show a small toolbar at the top of the photo with:

 - Download Button: When clicked, this must render the entire Polaroid card (including the white frame, the photo, the date, and the handwritten caption) into a single image file and download it. (Recommended: use `html2canvas` or similar logic).

 - Delete Button: Removes the photo from the screen.



Technical Stack

- React (functional components).

- Tailwind CSS for styling.

- Framer Motion (recommended for complex dragging and layout animations).

- Lucide-react for icons.

- html2canvas (or similar) for snapshotting the DOM elements.