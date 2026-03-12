# Claude Code 快速上手指南

**Claude Code** 是 Anthropic 出品的终端 AI 编程助手，直接在你的代码库里工作——读文件、改代码、跑命令、提交 PR，全部在终端完成。

---

## 目录

- [安装](#安装)
- [首次启动](#首次启动)
- [基本使用](#基本使用)
- [团队配置](#团队配置)
- [使用技巧](#使用技巧)
- [非技术人员使用场景](#非技术人员使用场景)

---

## 安装

### 前置条件

- Node.js 18 或更高版本
- macOS / Linux / Windows（WSL2）

### 安装命令

```bash
npm install -g @anthropic-ai/claude-code
```

### 配置 API Key

**方式 1：传统配置（手动）**

```bash
echo 'export ANTHROPIC_API_KEY="sk-ant-xxxxx"' >> ~/.zshrc
source ~/.zshrc
```

**方式 2：CCSwitch（推荐）**

CCSwitch 是图形界面的 API Key 管理工具，同时支持 Claude Code / OpenClaw / Codex。

```bash
# macOS 安装
brew tap farion1231/ccswitch
brew install --cask cc-switch
```

安装后在应用程序中打开 CCSwitch，添加你的 API Key。

**方式 3：一键脚本（最简单）**

使用本次分享提供的安装脚本，3 分钟完成全套安装：

```bash
bash setup.sh
```

---

## 首次启动

在你的项目目录中执行：

```bash
cd /path/to/your/project
claude
```

首次运行会引导你完成 OAuth 登录或 API Key 验证。

---

## 基本使用

### 自然语言指令

Claude Code 的核心是**自然语言对话**。你不需要记住任何命令语法，直接描述你想要什么：

```
帮我把 src/utils.js 里的 getUserInfo 函数重构成可测试的结构

为 login.ts 里的所有函数生成单元测试

分析 sales_data.csv，找出上个月销售额最高的 5 个产品，生成 Markdown 报告

把所有 console.log 替换为 logger.info
```

### Plan Mode（计划模式）

对于复杂任务，先让 Claude Code 列出执行计划，确认后再执行：

```
/plan 重构整个用户认证模块，使其支持 OAuth 和传统密码两种方式
```

Claude Code 会先列出详细步骤，你确认后才开始实际操作。**复杂任务强烈建议先用 Plan Mode。**

### 常用斜杠命令

| 命令 | 功能 |
|------|------|
| `/help` | 显示帮助 |
| `/plan` | 进入计划模式 |
| `/clear` | 清空对话历史 |
| `/compact` | 压缩对话上下文（节省 token） |
| `/review` | 对当前变更进行代码审查 |
| `/commit` | 生成 commit message 并提交 |

---

## 团队配置

### CLAUDE.md（团队规范文件）

在项目根目录创建 `CLAUDE.md`，定义团队规范。Claude Code 每次启动都会读取这个文件：

```markdown
# 项目规范

## 技术栈
- 前端：React + TypeScript
- 后端：Node.js + Express
- 数据库：PostgreSQL

## 命名规范
- 组件：PascalCase（如 UserProfile）
- 工具函数：camelCase（如 formatDate）
- 常量：UPPER_SNAKE_CASE（如 MAX_RETRY_COUNT）

## 禁止操作
- 不得直接操作 production 数据库
- 不得提交未经测试的代码
- API Key 不得硬编码到代码中

## 代码风格
- 函数不超过 40 行
- 必须有 JSDoc 注释
- 错误必须显式处理，不得吞掉
```

### 自定义命令（.claude/commands/）

团队可以创建共享的自定义命令，提交到 Git 后全团队都能使用：

```bash
mkdir -p .claude/commands

# 创建 /review 命令
cat > .claude/commands/review.md << 'EOF'
对当前 git diff 进行代码审查，重点检查：
1. 是否有安全漏洞（SQL 注入、XSS 等）
2. 命名是否符合项目规范
3. 是否有遗漏的错误处理
4. 性能是否有明显问题

输出格式：用中文，分 [必须修复] [建议优化] [可选改进] 三个优先级
EOF

# 创建 /commit 命令
cat > .claude/commands/commit.md << 'EOF'
根据 git diff 生成符合 Conventional Commits 规范的 commit message。
格式：<type>(<scope>): <subject>
类型：feat/fix/docs/refactor/test/chore
全程用中文
EOF
```

### Git Hooks（强制规范执行）

不依赖"Claude 记不记得"，通过 Git Hooks 确保每次提交前执行检查：

```bash
# .git/hooks/pre-commit
#!/bin/sh
echo "运行 lint 检查..."
npm run lint
if [ $? -ne 0 ]; then
  echo "Lint 检查失败，请修复后重新提交"
  exit 1
fi
```

---

## 使用技巧

### 1. 描述越简洁越好

❌ 不推荐：
```
我希望你能帮我查看一下我们项目里面的登录页面，然后把那个登录按钮的颜色改一下，改成蓝色的那种，大概是品牌色那种蓝色
```

✅ 推荐：
```
把登录页面的提交按钮颜色改为 #2563EB
```

### 2. 每个项目独立文件夹启动

Claude Code 在哪个目录启动，就只操作那个目录范围内的文件：

```bash
# 在项目根目录启动，保证操作范围
cd ~/projects/my-game
claude
```

### 3. 使用 Plan Mode 处理复杂任务

```
/plan 将 MySQL 迁移到 PostgreSQL，保证数据完整性
```

先看计划，确认无误后再执行，避免大规模误操作。

### 4. 明确指定文件范围

```
只修改 src/auth/ 目录下的文件，为登录流程添加 2FA 支持
```

### 5. 善用上下文

Claude Code 能理解整个代码库的上下文，可以问：

```
这个 API 调用失败的根本原因是什么？（附上错误日志）

这段代码和 src/utils/auth.ts 里的 validateToken 有什么关系？
```

---

## 非技术人员使用场景

Claude Code 不只是给程序员用的，任何需要在电脑上处理文件的工作都可以用：

### 产品经理

```
分析 user_feedback.xlsx，找出出现频率最高的 10 个用户问题，
按严重程度排序，生成一份结构化的产品反馈报告（Markdown 格式）
```

### 运营

```
把 marketing/ 目录下所有 .docx 文件转换为 PDF

根据 campaign_data.csv 生成一份月度运营数据摘要，
包含关键指标、环比变化、异常点分析
```

### 设计师

```
把 assets/icons/ 目录下所有 PNG 文件批量重命名，
命名规则：icon_{原文件名小写}_24.png

把 design_spec.md 里的所有尺寸数值从 px 转换为 pt（1px = 0.75pt）
```

---

## 常见问题

### Q：API 费用大概多少？

Claude Code 使用 Anthropic API 按量计费：
- **轻度使用**（每天 1-2 小时）：约 $5–10/月
- **中度使用**（每天 3-5 小时）：约 $20–40/月
- **重度使用**（全天编码）：约 $50–100/月

可在 [Anthropic Console](https://console.anthropic.com) 查看用量和设置用量上限。

### Q：Claude Code 会不会不小心删除我的文件？

Claude Code 会在执行危险操作前征求你的确认。建议：
- 在 Git 仓库中工作，所有变更都有记录
- 使用 Plan Mode 提前查看操作计划
- 重要操作前先备份

### Q：如何退出 Claude Code？

```
/exit    # 退出
Ctrl+C   # 强制退出
```

---

*GURU AI TECH · 内部技术分享 · 2026-03-12*
