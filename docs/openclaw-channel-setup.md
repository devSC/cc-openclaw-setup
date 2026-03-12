# OpenClaw 渠道配置指南

**OpenClaw** 是一个本地运行的 AI 网关，让 Claude 住进你每天用的聊天软件里。本文档介绍各主要平台的配置方法。

---

## 目录

- [快速开始](#快速开始)
- [Telegram（推荐）](#telegram推荐)
- [Discord](#discord)
- [Slack](#slack)
- [WeChat（企业微信）](#wechat企业微信)
- [DingTalk（钉钉）](#dingtalk钉钉)
- [Feishu（飞书）](#feishu飞书)
- [常见问题](#常见问题)

---

## 快速开始

### 安装 OpenClaw

```bash
npm install -g openclaw@latest
```

### 启动配置向导

```bash
openclaw onboard --install-daemon
```

向导会引导你：
1. 选择接入渠道（Telegram / Discord / Slack 等）
2. 输入对应的 Bot Token
3. 配置 Anthropic API Key
4. 启动守护进程（每 30 分钟自动检查任务）

### 查看运行状态

```bash
openclaw status      # 查看当前状态
openclaw start       # 手动启动
openclaw stop        # 停止
openclaw logs        # 查看日志
```

---

## Telegram（推荐）

Telegram 配置最简单，国内访问稳定，**推荐优先选择**。

### 第一步：创建 Bot

1. 在 Telegram 中搜索 **@BotFather**，点击 Start
2. 发送 `/newbot`
3. 输入 Bot 名称（如 `My Claude Bot`）
4. 输入 Bot 用户名（必须以 `bot` 结尾，如 `myclaudebot`）
5. BotFather 会返回一个 **HTTP API Token**，格式如：

```
1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
```

6. 复制这个 Token

### 第二步：获取 Chat ID

发消息给你的 Bot，然后访问：

```
https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates
```

在返回的 JSON 中找到 `chat.id`，这就是你的 Chat ID。

### 第三步：配置 OpenClaw

```bash
openclaw onboard --install-daemon
```

选择 `Telegram`，输入：
- Bot Token：上面获取的 Token
- Chat ID：你的 Chat ID

### 使用示例

在 Telegram 中向你的 Bot 发送：

```
帮我分析一下 /home/user/sales.csv 文件，找出上个月销售最高的 5 个产品
```

---

## Discord

### 第一步：创建 Discord Application

1. 访问 [Discord Developer Portal](https://discord.com/developers/applications)
2. 点击 **New Application**，填写名称
3. 左侧选择 **Bot** → 点击 **Add Bot**
4. 点击 **Reset Token** 获取 Token（保存好，只显示一次）
5. 开启以下权限：
   - **Message Content Intent**（接收消息内容）
   - **Server Members Intent**（可选）

### 第二步：邀请 Bot 到服务器

1. 左侧选择 **OAuth2** → **URL Generator**
2. Scopes 选择：`bot`
3. Bot Permissions 选择：`Send Messages`, `Read Message History`
4. 复制生成的 URL，在浏览器打开，将 Bot 添加到你的服务器

### 第三步：配置 OpenClaw

```bash
openclaw onboard --install-daemon
```

选择 `Discord`，输入 Bot Token。

### 使用示例

在 Discord 频道中 @ 你的 Bot：

```
@ClaudeBot 帮我总结一下今天的会议记录
```

---

## Slack

### 第一步：创建 Slack App

1. 访问 [Slack API](https://api.slack.com/apps) → **Create New App** → **From scratch**
2. 填写 App 名称和工作区
3. 左侧选择 **OAuth & Permissions**
4. 在 **Bot Token Scopes** 添加：
   - `chat:write`（发送消息）
   - `channels:history`（读取频道历史）
   - `im:history`（读取私信历史）
   - `im:write`（发送私信）

5. 点击 **Install to Workspace** → 授权
6. 复制 **Bot User OAuth Token**（`xoxb-...` 格式）

### 第二步：配置 OpenClaw

```bash
openclaw onboard --install-daemon
```

选择 `Slack`，输入 Bot Token。

### 使用示例

在 Slack 中 @ 你的 Bot：

```
@claude-bot 帮我写一份竞品分析报告，竞品是 XXX
```

---

## WeChat（企业微信）

> ⚠️ 个人微信暂不支持官方 Bot API，如需接入个人微信请使用第三方方案（需自行评估合规风险）

### 企业微信接入

1. 登录 [企业微信管理后台](https://work.weixin.qq.com/)
2. **应用管理** → **自建** → 创建应用
3. 填写应用信息，获取：
   - `AgentId`
   - `Secret`（点击查看）
4. 在**可信IP**中添加你的服务器 IP（本地运行填本机公网 IP）
5. 企业 ID 在**我的企业**页面底部

### 配置 OpenClaw

```bash
openclaw onboard --install-daemon
```

选择 `WeChat Work`，输入：
- 企业 ID（CorpID）
- 应用 AgentId
- 应用 Secret

---

## DingTalk（钉钉）

### 第一步：创建自定义机器人

**方式 A：群机器人（推荐，最简单）**

1. 打开钉钉群 → 群设置 → 机器人 → 添加机器人 → 自定义
2. 填写机器人名称
3. 安全设置选择**加签**（记录 Secret）
4. 获取 **Webhook URL**，格式：

```
https://oapi.dingtalk.com/robot/send?access_token=xxx
```

### 配置 OpenClaw

```bash
openclaw onboard --install-daemon
```

选择 `DingTalk`，输入：
- Webhook URL
- 加签 Secret

---

## Feishu（飞书）

### 第一步：创建飞书应用

1. 访问[飞书开放平台](https://open.feishu.cn/)
2. **创建企业自建应用**
3. 在**权限管理**中开通：
   - `im:message`（消息读写）
   - `im:message.group_at_msg`（读取群 @ 消息）
4. 添加机器人能力
5. 获取 **App ID** 和 **App Secret**

### 配置 Event 订阅（接收消息）

1. 进入**事件订阅**
2. 填写请求 URL（OpenClaw 会提供，格式：`http://localhost:PORT/feishu`）
3. 订阅事件：`im.message.receive_v1`

### 配置 OpenClaw

```bash
openclaw onboard --install-daemon
```

选择 `Feishu`，输入：
- App ID
- App Secret
- Verification Token（在事件订阅页面获取）

---

## 常见问题

### Q：OpenClaw 守护进程是什么？

守护进程（Daemon）让 OpenClaw 在后台持续运行，即使你关闭了终端窗口。它会每 30 分钟自动"醒来"检查是否有新任务，实现主动推送。

```bash
# 查看守护进程状态
openclaw daemon status

# 停止守护进程
openclaw daemon stop

# 重启守护进程
openclaw daemon restart
```

### Q：如何同时接入多个渠道？

OpenClaw 支持多渠道并行运行：

```bash
# 添加新渠道而不影响现有配置
openclaw channel add telegram
openclaw channel add discord
openclaw channel list    # 查看所有渠道
```

### Q：数据安全吗？

- **本地运行**：OpenClaw 跑在你自己的电脑上，消息不经过任何第三方服务器
- **直接调用 API**：直接连接 Anthropic API，无中间层
- **配置存储**：Token 等配置保存在本地 `~/.openclaw/config.json`

### Q：如何更新 OpenClaw？

```bash
npm update -g openclaw
openclaw --version    # 确认版本
```

### Q：遇到连接问题怎么办？

```bash
openclaw logs --tail 50    # 查看最近 50 行日志
openclaw doctor            # 运行诊断检查
```

---

## 进阶配置

### 自定义 AI 指令

在 `~/.openclaw/config.json` 中添加自定义系统提示词：

```json
{
  "system_prompt": "你是一个出海游戏公司的 AI 助手，专注于帮助团队提高工作效率..."
}
```

### 配置任务调度

```json
{
  "schedules": [
    {
      "cron": "0 9 * * 1-5",
      "task": "生成今日竞品动态摘要并发送到 Telegram"
    }
  ]
}
```

---

*GURU AI TECH · 内部技术分享 · 2026-03-12*
