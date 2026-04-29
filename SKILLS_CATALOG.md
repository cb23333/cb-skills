# Skills 技能目录总览

> 最后更新：2026-04-29
> 本文档列出所有可用的系统级 Skills 和本地自定义 Skills，方便随时查阅。

---

## 一、本地自定义 Skills（cb-skills 仓库）

位于 `D:\Program\cb-skills`，共 **5 个** skill。

### 1. flutter-app-dev — Flutter 应用开发

| 项目 | 内容 |
|------|------|
| **路径** | `flutter-app-dev/` |
| **触发词** | Flutter、mobile app、iOS、Android、Dart、widget、pubspec、跨平台 |
| **用途** | 端到端 Flutter 移动应用开发工作流 |

**覆盖内容：**
- 项目搭建（feature-first 架构）
- 状态管理（Riverpod）、路由（GoRouter）、网络（Dio）
- Data → Domain → Presentation 分层开发
- 测试、打磨清单、部署

**参考文档：**
- `references/pubspec-guide.md` — 依赖版本与配置
- `references/core-setup.md` — 主题/路由/网络详细配置
- `references/feature-patterns.md` — 各层代码模式
- `references/deployment-guide.md` — 平台构建与部署

---

### 2. kali-security — Kali Linux 安全测试

| 项目 | 内容 |
|------|------|
| **路径** | `kali-security/` |
| **触发词** | Kali、pentest、CTF、nmap、metasploit、sqlmap、hashcat、burpsuite |
| **用途** | 专业安全测试全流程指南（仅限授权场景） |

**覆盖内容：**
- 侦察（被动 & 主动扫描）
- Web 应用测试、漏洞分析
- 漏洞利用、后渗透、数字取证
- 密码攻击、无线测试
- 报告撰写

**参考文档：**
- `references/reconnaissance.md`、`references/web-testing.md`
- `references/password-attacks.md`、`references/wireless-testing.md`
- `references/exploitation.md`、`references/post-exploitation.md`
- `references/forensics.md`、`references/reporting.md`

---

### 3. moments-copy — 朋友圈文案生成器

| 项目 | 内容 |
|------|------|
| **路径** | `moments-copy/` |
| **触发词** | 朋友圈文案、发朋友圈、朋友圈配文、帮我写个朋友圈 |
| **用途** | 根据场景/心情/事件生成多种风格的朋友圈短文案 |

**支持 12 种风格：**
文艺清新、诗意文案、日常碎碎念、简洁高级、幽默轻松、温馨治愈、旅行记录、美食打卡、情感感悟、萌宠日记、运动/健身、节日/纪念日

**特点：** 每次输出 3-5 条不同风格文案（20-150 字），支持交互式调整

---

### 4. report-writing — 汇报稿撰写专家

| 项目 | 内容 |
|------|------|
| **路径** | `report-writing/` |
| **触发词** | 写汇报、写报告、工作总结、述职、竞聘演讲、年终总结、发言稿 |
| **用途** | 撰写各类正式汇报文稿并输出 Word 文档 |

**覆盖类型：**
工作总结、述职报告、项目总结、年终总结、竞聘报告、调研报告、经验交流发言、对照检查材料

**特点：** 自动判断汇报类型，智能适配文风（机关风/务实风/亲切风），生成符合公文格式规范的 .docx 文件

---

### 5. photo-doodle — 照片手绘涂鸦标注

| 项目 | 内容 |
|------|------|
| **路径** | `photo-doodle/` |
| **触发词** | 照片加标注、图片加文字、手绘注释、涂鸦标注、照片上写字、小红书风标注 |
| **用途** | 给照片添加手绘风格的中文文字注释和小装饰 |

**功能特点：**
- 自动识别画面元素（饮品/食物/人物/环境/自然等）
- 手绘风格注释：白色细线、一笔画、略有抖动
- 中文手写感文字，口语化碎碎念风格
- 小装饰点缀（星星/爱心/热气/简单表情）
- 多图单独处理，不拼图
- 自适应文字颜色（暗区白字、亮区深色）

**参考代码：** `references/annotator.py` — Python + Pillow 手绘标注脚本

---

## 二、系统级 Skills（随工具自动加载）

以下 skills 通过 Skill 工具调用，按类别整理。

### 工具配置类

| Skill | 说明 |
|-------|------|
| `update-config` | 配置 Claude Code 的 settings.json（权限、环境变量、hooks） |
| `keybindings-help` | 自定义键盘快捷键，修改 ~/.claude/keybindings.json |
| `statusline` | 设置 Claude Code 状态栏 UI |
| `init` | 初始化新的 CLAUDE.md 文件 |

### 代码质量类

| Skill | 说明 |
|-------|------|
| `simplify` | 审查已修改代码的复用性、质量和效率，自动修复问题 |
| `code-review:code-review` | Code Review 一个 Pull Request |
| `superpowers:requesting-code-review` | 完成任务后请求代码审查 |
| `superpowers:receiving-code-review` | 收到代码审查反馈后处理（避免盲目接受） |
| `superpowers:systematic-debugging` | 系统化调试 bug/测试失败/异常行为 |
| `superpowers:verification-before-completion` | 完成前验证，确保测试通过/代码正确 |

### 开发流程类

| Skill | 说明 |
|-------|------|
| `superpowers:brainstorming` | 创意工作前的头脑风暴（功能/组件/行为设计） |
| `superpowers:writing-plans` | 编写多步骤任务的实施计划 |
| `superpowers:executing-plans` | 执行已有的实施计划（含审查检查点） |
| `superpowers:test-driven-development` | TDD 测试驱动开发 |
| `superpowers:dispatching-parallel-agents` | 并行分发多个独立任务给子代理 |
| `superpowers:subagent-driven-development` | 子代理驱动开发（在当前会话中执行计划） |
| `superpowers:using-git-worktrees` | 创建隔离的 git worktree 进行特性开发 |
| `superpowers:finishing-a-development-branch` | 完成开发分支（合并/PR/清理决策） |
| `superpowers:writing-skills` | 创建/编辑/验证 skill |

### 规划类（planning-with-files）

| Skill | 说明 |
|-------|------|
| `planning-with-files:planning-with-files` | Manus 风格文件规划系统（task_plan.md + findings.md + progress.md） |
| `planning-with-files:plan` | 英文版 — 启动文件规划 |
| `planning-with-files:plan-zh` | 中文版 — 启动文件规划 |
| `planning-with-files:plan-ar` | 阿拉伯文版 — 启动文件规划 |
| `planning-with-files:plan-de` | 德文版 — 启动文件规划 |
| `planning-with-files:plan-es` | 西班牙文版 — 启动文件规划 |
| `planning-with-files:status` | 查看当前规划状态 |

### AI/应用开发类

| Skill | 说明 |
|-------|------|
| `claude-api` | 构建/调试 Claude API 和 Anthropic SDK 应用 |
| `example-skills:mcp-builder` | 创建 MCP (Model Context Protocol) 服务器 |

### 前端/UI 设计类

| Skill | 说明 |
|-------|------|
| `ui-ux-pro-max:ui-ux-pro-max` | UI/UX 设计智能（50+ 风格、161 色板、57 字体搭配、10 技术栈） |
| `example-skills:frontend-design` | 高质量前端界面设计（网站/仪表盘/React 组件等） |
| `example-skills:web-artifacts-builder` | 多组件 HTML artifacts（React + Tailwind + shadcn/ui） |
| `example-skills:webapp-testing` | Playwright 本地 Web 应用测试 |

### 文档/文件处理类

| Skill | 说明 |
|-------|------|
| `example-skills:pdf` | PDF 读取/合并/拆分/水印/加密/OCR 等 |
| `example-skills:docx` | Word 文档创建/读取/编辑（格式、目录、页码等） |
| `example-skills:pptx` | PowerPoint 演示文稿创建/编辑/读取 |
| `example-skills:xlsx` | Excel/CSV 电子表格处理 |
| `example-skills:doc-coauthoring` | 文档协作撰写（技术规格/提案/决策文档） |
| `example-skills:internal-comms` | 内部沟通文稿（状态报告/领导汇报/FAQ 等） |

### 创意/设计类

| Skill | 说明 |
|-------|------|
| `example-skills:algorithmic-art` | p5.js 生成艺术（流场/粒子系统） |
| `example-skills:canvas-design` | PNG/PDF 视觉设计（海报/艺术品） |
| `example-skills:slack-gif-creator` | Slack 优化的 GIF 动画创建 |
| `example-skills:theme-factory` | 10 种预设主题 + 自定义主题样式工具 |
| `example-skills:brand-guidelines` | Anthropic 品牌配色和排版规范 |

### 其他工具类

| Skill | 说明 |
|-------|------|
| `loop` | 定时循环执行任务（如每 5 分钟检查部署状态） |
| `example-skills:skill-creator` | 创建/修改/优化/评估 skill |
| `skill-creator:skill-creator` | 创建/修改/优化/评估 skill（另一版本） |
| `review` | Review 一个 Pull Request |
| `security-review` | 对当前分支的待合并更改做安全审查 |
| `insights` | 生成 Claude Code 使用会话分析报告 |
| `team-onboarding` | 帮助团队成员上手 Claude Code |

### 已弃用（Deprecated）

| Skill | 替代方案 |
|-------|---------|
| `superpowers:brainstorm` | 使用 `superpowers:brainstorming` |
| `superpowers:execute-plan` | 使用 `superpowers:executing-plans` |
| `superpowers:write-plan` | 使用 `superpowers:writing-plans` |

---

## 三、Skill 调用方式

在 Claude Code 中，使用 Skill 工具调用：

```
Skill: "skill-name"
Skill: "skill-name", args: "参数"
```

例如：
- `Skill: "report-writing"` — 触发汇报稿撰写
- `Skill: "moments-copy"` — 触发朋友圈文案生成
- `Skill: "planning-with-files:plan-zh"` — 触发中文文件规划

---

## 四、本地 Skill 触发词速查

| 想做什么 | 说什么 |
|---------|-------|
| 开发 Flutter App | "帮我开发一个 Flutter 应用"、"建一个移动端 App" |
| 安全测试/CTF | "帮我做个渗透测试"、"CTF 解题"、"扫描端口" |
| 写朋友圈文案 | "帮我写个朋友圈"、"发个朋友圈配文" |
| 写汇报稿 | "帮我写个工作总结"、"述职报告"、"竞聘演讲稿" |
| 给照片加手绘标注 | "帮我给这张照片加点字"、"给图片加涂鸦" |

---

## 五、统计

| 类别 | 数量 |
|------|------|
| 本地自定义 Skills | 5 |
| 系统级 Skills（含各语言变体） | ~70+ |
| 已弃用 Skills | 3 |
