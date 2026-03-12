# CCSwitch 使用指南

**CCSwitch** 是一个 macOS 桌面应用，统一管理 Claude Code、OpenClaw、Codex 和 Gemini CLI 的 API Key，支持多账号、延迟测速和一键切换。

> ⚠️ CCSwitch 桌面版仅支持 macOS。Windows/Linux 用户请参考文末的替代方案。

---

## 安装

```bash
brew tap farion1231/ccswitch
brew install --cask cc-switch
```

安装完成后，在 **应用程序（Applications）** 中找到并打开 CCSwitch。

---

## 主要功能

### 1. 多 API Key 管理

CCSwitch 支持为同一个工具配置多个 API Key，场景：

- **个人账号 + 公司账号**：不同项目用不同计费账号
- **多个代理节点**：配置不同的第三方 API 代理，自动测速选最快
- **测试账号**：开发时用测试 Key，避免消耗生产配额

### 2. 一键切换

在菜单栏点击 CCSwitch 图标，即可切换活跃的 API Key，无需手动编辑 `~/.zshrc`。

### 3. 内置延迟测速

自动测量每个 API 节点的响应延迟，帮助选择最快的连接节点（对国内用户特别有用）。

### 4. 支持的工具

| 工具 | 环境变量 | 说明 |
|------|----------|------|
| Claude Code | `ANTHROPIC_API_KEY` | 支持官方 + 第三方代理 |
| OpenClaw | `ANTHROPIC_API_KEY` | 共用 Claude API Key |
| Codex | `OPENAI_API_KEY` | 支持官方 + Azure + 代理 |
| Gemini CLI | `GOOGLE_API_KEY` | Google AI Studio API |

---

## 配置步骤

### 添加 Claude Code API Key

1. 打开 CCSwitch
2. 点击 **+ 添加**
3. 选择工具类型：**Claude Code**
4. 填写：
   - 名称：如「个人账号」「公司账号」
   - API Key：从 [Anthropic Console](https://console.anthropic.com) 获取
   - API Base URL（可选）：如需使用第三方代理，填写代理地址

### 获取 Anthropic API Key

1. 访问 [https://console.anthropic.com](https://console.anthropic.com)
2. 登录或注册账号
3. 左侧导航 → **API Keys**
4. 点击 **Create Key**
5. 复制 Key（以 `sk-ant-` 开头）

> ⚠️ API Key 只显示一次，请立即保存到 CCSwitch 或安全的地方

### 添加 OpenAI API Key（Codex）

1. 访问 [https://platform.openai.com](https://platform.openai.com)
2. 右上角头像 → **API Keys**
3. 点击 **Create new secret key**
4. 复制 Key（以 `sk-` 开头）

---

## 国内用户：使用第三方代理

如果官方 API 访问不稳定，可以使用第三方 API 代理服务（需自行评估服务商可信度）。

### 配置代理

在 CCSwitch 添加 Key 时，在 **API Base URL** 填写代理地址，例如：

```
https://api.your-proxy.com/v1
```

CCSwitch 会将该 Key 的所有请求转发到代理地址，代理透传至 Anthropic 官方 API。

### 测速比较

点击 **测速** 按钮，CCSwitch 会自动测试所有配置的节点延迟，显示：

```
官方节点      ████████░░  320ms
代理节点 A    ██████████   85ms  ← 最快
代理节点 B    ███████░░░  180ms
```

---

## 使用场景

### 场景 1：团队共用一个 API Key

如果公司购买了团队账号：

1. 管理员在 Anthropic Console 创建 API Key
2. 通过 CCSwitch 分发给团队成员
3. 成员统一使用同一个 Key，便于集中管控用量

### 场景 2：个人多项目切换

```
工作项目  → 公司 API Key（记公司账单）
个人项目  → 个人 API Key（自己付费）
```

在 CCSwitch 中一键切换，无需手动修改环境变量。

### 场景 3：开发 vs 生产环境

```
开发调试  → 测试 Key（设置低用量上限）
正式使用  → 生产 Key（完整配额）
```

---

## Windows / Linux 替代方案

CCSwitch 桌面版不支持 Windows/Linux，可以用以下方式手动管理：

### 方式 1：Shell 别名

在 `~/.zshrc`（macOS/Linux）或 `~/.bashrc` 中添加：

```bash
# 定义切换函数
use-claude-personal() {
  export ANTHROPIC_API_KEY="sk-ant-personal-xxx"
  echo "✅ 已切换到个人账号"
}

use-claude-company() {
  export ANTHROPIC_API_KEY="sk-ant-company-xxx"
  echo "✅ 已切换到公司账号"
}
```

使用时：

```bash
use-claude-company   # 切换到公司账号
claude               # 启动 Claude Code
```

### 方式 2：direnv（按项目自动切换）

安装 `direnv` 后，在每个项目目录创建 `.envrc`：

```bash
# ~/projects/work-project/.envrc
export ANTHROPIC_API_KEY="sk-ant-company-xxx"
```

进入目录时自动加载，离开时自动卸载。

---

## 常见问题

### Q：CCSwitch 安全吗？API Key 存储在哪里？

CCSwitch 将 API Key 加密存储在 macOS Keychain 中，安全性与系统密码管理器相同。

### Q：切换 Key 后需要重启 Claude Code 吗？

需要。CCSwitch 修改的是系统环境变量，已运行的 Claude Code 进程不会自动感知变化。重新打开终端并启动 `claude` 即可生效。

### Q：如何删除不再使用的 Key？

在 CCSwitch 中选中 Key → 右键 → 删除。

---

*GURU AI TECH · 内部技术分享 · 2026-03-12*
