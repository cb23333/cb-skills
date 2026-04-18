# cb-skills

A curated collection of high-quality skills for AI coding assistants. Each skill is a self-contained module that provides structured workflows, reference documentation, and battle-tested patterns for specific domains.

## Skills

| Skill | Description | Status |
|-------|-------------|--------|
| [flutter-app-dev](./flutter-app-dev) | End-to-end Flutter mobile app development | Available |
| [kali-security](./kali-security) | Kali Linux security testing & penetration testing | Available |
| [moments-copy](./moments-copy) | 朋友圈文案生成器，根据场景/心情/事件生成多种风格短文案 | Available |

## What is a Skill?

A skill is a plugin that enhances an AI assistant's capabilities in a specific domain. Each skill includes:

- **SKILL.md** — The main skill definition with frontmatter metadata and a structured workflow guide
- **references/** — Deep-dive reference documents that the AI loads on demand

Skills follow a consistent pattern: they define clear phases, provide code examples and command templates, and link to reference files for detailed information. This keeps the main skill concise while giving the AI access to deep domain knowledge when needed.

## Skill Details

### flutter-app-dev

Full-stack Flutter app development workflow covering:

- Project setup with feature-first architecture
- State management (Riverpod), navigation (GoRouter), networking (Dio)
- Data → Domain → Presentation layered development
- Testing, polish checklist, and deployment

References: `pubspec-guide.md`, `core-setup.md`, `feature-patterns.md`, `deployment-guide.md`

### kali-security

Professional security testing workflow covering:

- Reconnaissance (passive & active)
- Vulnerability analysis & web testing
- Exploitation, post-exploitation, forensics
- Password attacks & wireless testing
- Reporting & documentation

Enforces authorized-use-only principles with built-in authorization checks.

References: `reconnaissance.md`, `web-testing.md`, `password-attacks.md`, `wireless-testing.md`, `exploitation.md`, `post-exploitation.md`, `forensics.md`, `reporting.md`

### moments-copy

朋友圈文案生成器，支持自由描述和结构化输入，根据场景、心情、事件等信息生成多种风格的朋友圈短文案：

- 12 种文案风格：文艺清新、诗意文案、日常碎碎念、简洁高级、幽默轻松、温馨治愈、旅行记录、美食打卡、情感感悟、萌宠日记、运动/健身、节日/纪念日
- 混合输入模式：自由描述或结构化字段
- 每次输出 3-5 条不同风格文案（20-150字）
- 支持交互式调整风格、字数、语气

## Usage

Skills are designed to be installed into AI coding assistant skill directories. Each skill folder can be symlinked or copied to your assistant's skill path.

For example, with Claude Code:

```bash
# Symlink a skill to your Claude Code skills directory
ln -s /path/to/cb-skills/flutter-app-dev ~/.claude/skills/flutter-app-dev
```

The AI assistant will automatically discover and activate the skill when the user's request matches the skill's trigger keywords defined in the SKILL.md frontmatter.

## Creating a New Skill

To add a new skill to this collection:

1. Create a new directory with the skill name (use `kebab-case`)
2. Add a `SKILL.md` with frontmatter (`name`, `description`) and the skill content
3. Add a `references/` directory for detailed reference documents
4. Keep the main SKILL.md concise — link to reference files for deep dives

## License

MIT
