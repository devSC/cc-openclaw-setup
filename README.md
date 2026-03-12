# AI 编程助手一键安装

> Claude Code · OpenClaw · CCSwitch · Codex

---

## 仓库内容

| 文件 | 说明 |
|------|------|
| `setup.sh` | 一键安装脚本（macOS / Linux / WSL） |
| `setup.ps1` | Windows 引导脚本（调用 WSL 执行） |
| `docs/claude-code-quickstart.md` | Claude Code 快速上手指南 |
| `docs/openclaw-channel-setup.md` | OpenClaw 渠道配置（Telegram/Discord/Slack 等） |
| `docs/ccswitch-guide.md` | CCSwitch API Key 管理工具指南 |

---

## 快速开始

### 一键安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/devSC/cc-openclaw-setup/refs/tags/v1.0.0/setup.sh | bash
```

### macOS / Linux

```bash
bash setup.sh
```

脚本会引导你：
1. 选择要安装的工具（Claude Code / OpenClaw / CCSwitch / Codex）
2. 输入 API Key
3. 自动完成安装和配置

### Windows

```powershell
.\setup.ps1
```

> Windows 版需要先安装 WSL2，脚本会自动引导安装。

---

## 工具一览

### Claude Code

- **定位**：终端里的 AI 结对编程助手，直接操作你的代码库
- **安装**：`npm install -g @anthropic-ai/claude-code`
- **启动**：在项目目录执行 `claude`
- **详细文档**：[docs/claude-code-quickstart.md](docs/claude-code-quickstart.md)

### OpenClaw

- **定位**：住进你聊天软件里的 AI 助手，支持 Telegram / Discord / Slack / 微信等 20+ 平台
- **安装**：`npm install -g openclaw@latest`
- **配置**：`openclaw onboard --install-daemon`
- **详细文档**：[docs/openclaw-channel-setup.md](docs/openclaw-channel-setup.md)

### CCSwitch（推荐）

- **定位**：统一管理 Claude Code / OpenClaw / Codex / Gemini CLI 的 API Key
- **安装**：`brew tap farion1231/ccswitch && brew install --cask cc-switch`
- **平台**：macOS 专属桌面应用
- **详细文档**：[docs/ccswitch-guide.md](docs/ccswitch-guide.md)

### Codex

- **定位**：OpenAI 出品的终端 AI 编程 Agent（Claude Code 的 OpenAI 版）
- **安装**：`npm install -g @openai/codex`
- **亮点**：ChatGPT Plus/Pro 用户免费使用
- **更多**：见同事专题分享

---

## 配置 API Key

### 方式 1：传统手动配置

```bash
echo 'export ANTHROPIC_API_KEY="sk-ant-xxxxx"' >> ~/.zshrc
source ~/.zshrc
```

### 方式 2：CCSwitch（推荐，macOS）

打开 CCSwitch 应用 → 添加 API Key → 一键切换

### 方式 3：一键脚本

```bash
bash setup.sh   # 交互式引导完成所有配置
```

---

## 团队最佳实践

### CLAUDE.md — 让 AI 了解你的项目规范

在项目根目录创建 `CLAUDE.md`，写入团队规范：

```markdown
## 技术栈
- React + TypeScript + Node.js

## 命名规范
- 组件：PascalCase
- 工具函数：camelCase

## 禁止操作
- 不得直接操作 production 数据库
```

### 共享自定义命令

创建 `.claude/commands/` 目录，提交到 Git，全团队共享：

```bash
# .claude/commands/review.md
对当前 diff 进行代码审查，输出 [必须修复] [建议优化] [可选改进] 三个优先级...
```

使用时输入 `/review` 即可触发。

---

## 问题反馈

遇到问题请在团队内部群 @ 分享者，或查阅各工具官方文档：

- Claude Code 文档：https://docs.anthropic.com/claude-code
- OpenClaw GitHub：https://github.com/openclaw/openclaw
- CCSwitch GitHub：https://github.com/farion1231/cc-switch

---

*GURU AI TECH · 内部技术分享 · 2026-03-12*
