## 软件工程

core：multi-agent cooperation，spec driven，AI self-iteration

doc：prd文档，设计文档+Figma，系分文档，验收文档

flow: 产品需求->设计->ai开发->ai用例测试->浏览器自动测试->人工测试->代码审查->部署

role: project manager/product manager/UI/web developer/test manager/devops

图片：GPT-Image-2/nano banana pro2/Seedream 5.0
视频：Seedance2
设计：Stitch -> Figma

playwright

架构：

integration：code rabbit/cloudflare

toolchain: biome

## AGENTS 应用开发

Mirofish
启示一：GraphRAG 作为 Agent 世界构建器。 MiroFish 用知识图谱自动从文档提取实体和关系、再转化为 Agent 人设和环境配置的管线，是一种可复用的设计模式。如果你在做任何需要”理解一个领域然后在其中部署 Agent”的项目——无论是客户支持、安全分析还是流程自动化——这个 GraphRAG → Agent Profile 的路线值得借鉴。

启示二：”仿真即推理”的范式。 传统 Agent 开发中，我们习惯了 ReACT 循环、RAG 检索、Tool-Use 这套工具箱。MiroFish 提出了一个不同的推理路径：不是让一个 Agent 反复推理，而是让一群 Agent 在一个结构化环境中交互，从群体行为中提取结论。这种”仿真即推理”（simulation-as-reasoning）的范式对特定问题类型（涉及多方博弈、信息不对称、群体动力学的场景）可能比单体推理更有效。

启示三：OASIS 作为 Agent 社交基础设施。 MiroFish 实际上是 OASIS + Zep + GraphRAG 的组合。CAMEL-AI 的 OASIS 框架本身是一个强大的多 Agent 社交仿真引擎，但知名度远不如 LangChain 或 CrewAI。如果你的项目需要模拟信息传播、舆论演化或社交网络动态，OASIS 值得直接评估——不一定非要通过 MiroFish。