#!/usr/bin/env bash
# =============================================================================
# GURU AI TECH — AI 工具一键安装脚本
# Claude Code · OpenClaw · CCSwitch · Codex
# Version: 1.0.0 | 2026-03-12
# =============================================================================

set -euo pipefail

# ─────────────────────────────────────────────
# 颜色定义
# ─────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# ─────────────────────────────────────────────
# 工具函数
# ─────────────────────────────────────────────
print_step()    { echo -e "\n${CYAN}▶ $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error()   { echo -e "${RED}❌ $1${NC}"; }
print_info()    { echo -e "${GRAY}   $1${NC}"; }
print_cmd()     { echo -e "${DIM}   $ $1${NC}"; }

# ─────────────────────────────────────────────
# BANNER
# ─────────────────────────────────────────────
print_banner() {
  echo -e "${MAGENTA}"
  echo "  ╔═══════════════════════════════════════════════════════╗"
  echo "  ║                                                       ║"
  echo "  ║        ██████╗ ██╗   ██╗██████╗ ██╗   ██╗            ║"
  echo "  ║       ██╔════╝ ██║   ██║██╔══██╗██║   ██║            ║"
  echo "  ║       ██║  ███╗██║   ██║██████╔╝██║   ██║            ║"
  echo "  ║       ██║   ██║██║   ██║██╔══██╗██║   ██║            ║"
  echo "  ║       ╚██████╔╝╚██████╔╝██║  ██║╚██████╔╝            ║"
  echo "  ║        ╚═════╝  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝             ║"
  echo "  ║                                                       ║"
  echo "  ║              ✦  A I   T E C H  ✦                     ║"
  echo "  ║                                                       ║"
  echo "  ╠═══════════════════════════════════════════════════════╣"
  echo "  ║                                                       ║"
  echo "  ║        AI 编程助手一键安装脚本  v1.0.0                ║"
  echo "  ║        Claude Code · OpenClaw · CCSwitch · Codex      ║"
  echo "  ║                                                       ║"
  echo "  ╚═══════════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

# ─────────────────────────────────────────────
# 检测系统
# ─────────────────────────────────────────────
detect_os() {
  print_step "检测运行环境"
  OS="unknown"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    print_success "macOS $(sw_vers -productVersion)"
  elif grep -qi microsoft /proc/version 2>/dev/null; then
    OS="wsl"
    print_success "Windows WSL2 (Linux 子系统)"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    print_success "Linux $(uname -r)"
  else
    print_error "不支持的操作系统: $OSTYPE"
    echo "Windows 用户请使用 setup.ps1，或先安装 WSL2 后重试"
    exit 1
  fi
}

# ─────────────────────────────────────────────
# 检查并安装 Homebrew（仅 macOS）
# ─────────────────────────────────────────────
check_homebrew() {
  if [[ "$OS" != "macos" ]]; then return; fi

  print_step "检查 Homebrew"
  if command -v brew &>/dev/null; then
    print_success "Homebrew $(brew --version | head -1 | awk '{print $2}')"
    return
  fi

  print_warning "未检测到 Homebrew，准备自动安装..."
  echo ""
  read -p "  是否自动安装 Homebrew？[Y/n] " confirm
  confirm="${confirm:-Y}"
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    print_error "Homebrew 是安装 CCSwitch 的必要依赖"
    print_info "请手动安装：https://brew.sh"
    exit 1
  fi

  print_info "安装 Homebrew（需要输入系统密码）..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Apple Silicon 需要初始化 PATH
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  fi

  if command -v brew &>/dev/null; then
    print_success "Homebrew 安装成功"
  else
    print_error "Homebrew 安装失败，请手动安装后重试：https://brew.sh"
    exit 1
  fi
}

# ─────────────────────────────────────────────
# 检查并安装 Node.js
# ─────────────────────────────────────────────
check_node() {
  print_step "检查 Node.js"

  if command -v node &>/dev/null; then
    NODE_VERSION=$(node --version | tr -d 'v')
    NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
    if [[ "$NODE_MAJOR" -ge 18 ]]; then
      print_success "Node.js v$NODE_VERSION"
      return
    else
      print_warning "Node.js v$NODE_VERSION 版本过低（需要 ≥18），准备升级..."
    fi
  else
    print_warning "未检测到 Node.js，准备自动安装..."
  fi

  if [[ "$OS" == "macos" ]]; then
    print_info "通过 Homebrew 安装 Node.js..."
    brew install node
  elif [[ "$OS" == "linux" || "$OS" == "wsl" ]]; then
    print_info "通过 apt 安装 Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi

  if command -v node &>/dev/null; then
    print_success "Node.js $(node --version) 安装成功"
  else
    print_error "Node.js 安装失败"
    print_info "请手动安装：https://nodejs.org"
    exit 1
  fi
}

# ─────────────────────────────────────────────
# 多选工具菜单
# ─────────────────────────────────────────────
select_tools() {
  print_step "选择要安装的工具"
  echo ""
  echo -e "  ${WHITE}使用空格键选择/取消，回车键确认${NC}"
  echo -e "  ${DIM}（默认全选 Claude Code + OpenClaw + CCSwitch）${NC}"
  echo ""

  # ── 检测已安装工具 ──
  CLAUDE_INSTALLED=false;   command -v claude   &>/dev/null && CLAUDE_INSTALLED=true
  OPENCLAW_INSTALLED=false; command -v openclaw &>/dev/null && OPENCLAW_INSTALLED=true
  CCSWITCH_INSTALLED=false
  { [ -d "/Applications/CCSwitch.app" ] || [ -d "/Applications/CC Switch.app" ]; } && CCSWITCH_INSTALLED=true
  CODEX_INSTALLED=false;    command -v codex    &>/dev/null && CODEX_INSTALLED=true

  local installed=("$CLAUDE_INSTALLED" "$OPENCLAW_INSTALLED" "$CCSWITCH_INSTALLED" "$CODEX_INSTALLED")

  # 默认选中（已安装的安装阶段会自动跳过，这里仍标 true 保持 UI 一致）
  INSTALL_CLAUDE=true
  INSTALL_OPENCLAW=true
  INSTALL_CCSWITCH=true
  INSTALL_CODEX=false

  local tools=("Claude Code  (@anthropic-ai/claude-code)" "OpenClaw     (openclaw)" "CCSwitch     (桌面版，统一管理 API Key)" "Codex        (@openai/codex)")
  local selected=(true true true false)
  local current=0
  local total=${#tools[@]}

  # 菜单行数 = 工具数 + 空行 + 提示行
  local lines=$((total + 2))

  # ── 首次绘制，建立光标基准位置 ──
  for i in "${!tools[@]}"; do
    if [[ "${installed[$i]}" == "true" ]]; then
      marker="${YELLOW}[✓]${NC}"; suffix="${DIM} 已安装${NC}"
    elif [[ "${selected[$i]}" == "true" ]]; then
      marker="${GREEN}[✓]${NC}"; suffix=""
    else
      marker="${GRAY}[ ]${NC}"; suffix=""
    fi
    [[ "$i" == "$current" ]] \
      && echo -e "  ${CYAN}▶${NC} ${marker} ${tools[$i]}${suffix}" \
      || echo -e "    ${marker} ${tools[$i]}${suffix}"
  done
  echo ""
  echo -e "  ${DIM}↑↓ 移动  Space 选择  Enter 确认  ${YELLOW}[✓] 已安装（自动跳过）${NC}"

  while true; do
    printf "\033[%dA\033[J" "$lines"

    for i in "${!tools[@]}"; do
      if [[ "${installed[$i]}" == "true" ]]; then
        marker="${YELLOW}[✓]${NC}"; suffix="${DIM} 已安装${NC}"
      elif [[ "${selected[$i]}" == "true" ]]; then
        marker="${GREEN}[✓]${NC}"; suffix=""
      else
        marker="${GRAY}[ ]${NC}"; suffix=""
      fi
      [[ "$i" == "$current" ]] \
        && echo -e "  ${CYAN}▶${NC} ${marker} ${tools[$i]}${suffix}" \
        || echo -e "    ${marker} ${tools[$i]}${suffix}"
    done
    echo ""
    echo -e "  ${DIM}↑↓ 移动  Space 选择  Enter 确认  ${YELLOW}[✓] 已安装（自动跳过）${NC}"

    IFS= read -rsn1 key
    case "$key" in
      $'\x1b')
        read -rsn2 key2
        case "$key2" in
          '[A') (( current > 0 )) && (( current-- )) ;;
          '[B') (( current < total-1 )) && (( current++ )) ;;
        esac
        ;;
      ' ')
        # 已安装的工具不允许切换
        if [[ "${installed[$current]}" == "false" ]]; then
          if [[ "${selected[$current]}" == "true" ]]; then
            selected[$current]=false
          else
            selected[$current]=true
          fi
        fi
        ;;
      '')
        break
        ;;
    esac
  done

  INSTALL_CLAUDE="${selected[0]}"
  INSTALL_OPENCLAW="${selected[1]}"
  INSTALL_CCSWITCH="${selected[2]}"
  INSTALL_CODEX="${selected[3]}"

  echo ""
  echo -e "  ${WHITE}确认：${NC}"
  if [[ "$CLAUDE_INSTALLED"   == "true" ]]; then echo -e "  ${YELLOW}↷${NC} Claude Code   ${DIM}(已安装，跳过)${NC}"
  elif [[ "$INSTALL_CLAUDE"   == "true" ]]; then echo -e "  ${GREEN}✓${NC} Claude Code   ${DIM}(将安装)${NC}"; fi
  if [[ "$OPENCLAW_INSTALLED" == "true" ]]; then echo -e "  ${YELLOW}↷${NC} OpenClaw      ${DIM}(已安装，跳过)${NC}"
  elif [[ "$INSTALL_OPENCLAW" == "true" ]]; then echo -e "  ${GREEN}✓${NC} OpenClaw      ${DIM}(将安装)${NC}"; fi
  if [[ "$CCSWITCH_INSTALLED" == "true" ]]; then echo -e "  ${YELLOW}↷${NC} CCSwitch      ${DIM}(已安装，跳过)${NC}"
  elif [[ "$INSTALL_CCSWITCH" == "true" ]]; then echo -e "  ${GREEN}✓${NC} CCSwitch      ${DIM}(将安装)${NC}"; fi
  if [[ "$CODEX_INSTALLED"    == "true" ]]; then echo -e "  ${YELLOW}↷${NC} Codex         ${DIM}(已安装，跳过)${NC}"
  elif [[ "$INSTALL_CODEX"    == "true" ]]; then echo -e "  ${GREEN}✓${NC} Codex         ${DIM}(将安装)${NC}"; fi
}

# ─────────────────────────────────────────────
# 配置 API Key
# ─────────────────────────────────────────────
SHELL_RC="$HOME/.zshrc"
[[ "$SHELL" == *"bash"* ]] && SHELL_RC="$HOME/.bash_profile"

write_env_var() {
  local key="$1"
  local val="$2"
  # 移除旧配置（若存在）
  sed -i.bak "/export ${key}=/d" "$SHELL_RC" 2>/dev/null || true
  echo "export ${key}=\"${val}\"" >> "$SHELL_RC"
  export "${key}=${val}"
  print_success "${key} 已写入 $SHELL_RC"
}

configure_claude_auth() {
  echo ""
  echo -e "  ${WHITE}─── Claude Code 认证方式 ───${NC}"
  echo ""
  echo -e "  ${CYAN}[1]${NC} 默认 Auth 登录（浏览器授权，推荐）"
  echo -e "  ${CYAN}[2]${NC} 配置 API Key（自备 Key 或第三方代理）"
  echo ""

  local choice
  while true; do
    read -rp "  请选择 [1/2]: " choice
    case "$choice" in
      1)
        echo ""
        print_info "安装完成后运行 claude，按提示在浏览器完成授权"
        print_info "授权地址：https://console.anthropic.com"
        break
        ;;
      2)
        echo ""
        # API Host（可选）
        if [[ -n "${ANTHROPIC_BASE_URL:-}" ]]; then
          echo -e "  ${GREEN}已检测到 ANTHROPIC_BASE_URL，跳过输入${NC}"
        else
          read -rp "  请输入 API Host（留空使用官方 https://api.anthropic.com）: " CLAUDE_HOST
          if [[ -n "$CLAUDE_HOST" ]]; then
            write_env_var "ANTHROPIC_BASE_URL" "$CLAUDE_HOST"
          fi
        fi
        # API Key（必填）
        if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
          echo -e "  ${GREEN}已检测到 ANTHROPIC_API_KEY，跳过输入${NC}"
        else
          while true; do
            read -rsp "  请输入 Anthropic API Key: " ANTHROPIC_KEY
            echo ""
            if [[ -n "$ANTHROPIC_KEY" ]]; then
              write_env_var "ANTHROPIC_API_KEY" "$ANTHROPIC_KEY"
              break
            else
              print_warning "API Key 不能为空，请重新输入"
            fi
          done
        fi
        break
        ;;
      *)
        print_warning "请输入 1 或 2"
        ;;
    esac
  done
}

configure_codex_auth() {
  echo ""
  echo -e "  ${WHITE}─── Codex 认证方式 ───${NC}"
  echo ""
  echo -e "  ${CYAN}[1]${NC} 默认 Auth 登录（ChatGPT Plus/Pro 订阅浏览器授权）"
  echo -e "  ${CYAN}[2]${NC} 配置 API Key（自备 OpenAI Key 或第三方代理）"
  echo ""

  local choice
  while true; do
    read -rp "  请选择 [1/2]: " choice
    case "$choice" in
      1)
        echo ""
        print_info "安装完成后运行 codex，按提示在浏览器完成授权"
        print_info "需要有效的 ChatGPT Plus/Pro/Business 订阅"
        break
        ;;
      2)
        echo ""
        # API Host（可选）
        if [[ -n "${OPENAI_BASE_URL:-}" ]]; then
          echo -e "  ${GREEN}已检测到 OPENAI_BASE_URL，跳过输入${NC}"
        else
          read -rp "  请输入 API Host（留空使用官方 https://api.openai.com）: " OPENAI_HOST
          if [[ -n "$OPENAI_HOST" ]]; then
            write_env_var "OPENAI_BASE_URL" "$OPENAI_HOST"
          fi
        fi
        # API Key（必填）
        if [[ -n "${OPENAI_API_KEY:-}" ]]; then
          echo -e "  ${GREEN}已检测到 OPENAI_API_KEY，跳过输入${NC}"
        else
          while true; do
            read -rsp "  请输入 OpenAI API Key: " OPENAI_KEY
            echo ""
            if [[ -n "$OPENAI_KEY" ]]; then
              write_env_var "OPENAI_API_KEY" "$OPENAI_KEY"
              break
            else
              print_warning "API Key 不能为空，请重新输入"
            fi
          done
        fi
        break
        ;;
      *)
        print_warning "请输入 1 或 2"
        ;;
    esac
  done
}

configure_api_keys() {
  print_step "配置认证方式"
  if [[ "$INSTALL_CLAUDE" == "true" ]]; then configure_claude_auth; fi
  if [[ "$INSTALL_CODEX"  == "true" ]]; then configure_codex_auth;  fi
}

# ─────────────────────────────────────────────
# 执行安装
# ─────────────────────────────────────────────
install_tools() {
  print_step "开始安装"

  # Claude Code
  if [[ "$INSTALL_CLAUDE" == "true" ]]; then
    echo ""
    if [[ "$CLAUDE_INSTALLED" == "true" ]]; then
      print_info "Claude Code 已安装，跳过"
    else
      echo -e "  ${CYAN}正在安装 Claude Code...${NC}"
      print_cmd "curl -fsSL https://claude.ai/install.sh | bash"
      curl -fsSL https://claude.ai/install.sh | bash
      # Claude Code 默认装到 ~/.local/bin，确保当前 shell 和 rc 文件都有该路径
      if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        sed -i.bak '/export PATH.*\.local\/bin/d' "$SHELL_RC" 2>/dev/null || true
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
        print_success '~/.local/bin 已加入 PATH'
      fi
      print_success "Claude Code 安装完成"
    fi
  fi

  # OpenClaw
  if [[ "$INSTALL_OPENCLAW" == "true" ]]; then
    echo ""
    if [[ "$OPENCLAW_INSTALLED" == "true" ]]; then
      print_info "OpenClaw 已安装，跳过"
    else
      echo -e "  ${CYAN}正在安装 OpenClaw...${NC}"
      print_cmd "npm install -g openclaw@latest"
      npm install -g openclaw@latest
      print_success "OpenClaw 安装完成"
    fi
  fi

  # CCSwitch（macOS 桌面版）
  if [[ "$INSTALL_CCSWITCH" == "true" ]]; then
    echo ""
    if [[ "$CCSWITCH_INSTALLED" == "true" ]]; then
      print_info "CCSwitch 已安装，跳过"
    elif [[ "$OS" == "macos" ]]; then
      echo -e "  ${CYAN}正在安装 CCSwitch（桌面版）...${NC}"
      print_cmd "brew tap farion1231/ccswitch && brew install --cask cc-switch"
      brew tap farion1231/ccswitch 2>/dev/null || true
      brew install --cask cc-switch
      print_success "CCSwitch 安装完成，可在 Applications 中找到"
    else
      print_warning "CCSwitch 桌面版仅支持 macOS，已跳过"
      print_info "Linux/WSL 用户可使用 CLI 版：npm install -g cc-switch-cli"
    fi
  fi

  # Codex
  if [[ "$INSTALL_CODEX" == "true" ]]; then
    echo ""
    if [[ "$CODEX_INSTALLED" == "true" ]]; then
      print_info "Codex 已安装，跳过"
    else
      echo -e "  ${CYAN}正在安装 Codex...${NC}"
      print_cmd "npm install -g @openai/codex"
      npm install -g @openai/codex
      print_success "Codex 安装完成"
    fi
  fi
}

# ─────────────────────────────────────────────
# 验证安装
# ─────────────────────────────────────────────
verify_installation() {
  print_step "验证安装结果"
  echo ""

  local all_ok=true

  if [[ "$INSTALL_CLAUDE" == "true" ]]; then
    if command -v claude &>/dev/null; then
      print_success "Claude Code $(claude --version 2>/dev/null | head -1)"
    else
      print_error "Claude Code 验证失败"
      all_ok=false
    fi
  fi

  if [[ "$INSTALL_OPENCLAW" == "true" ]]; then
    if command -v openclaw &>/dev/null; then
      print_success "OpenClaw $(openclaw --version 2>/dev/null | head -1)"
    else
      print_error "OpenClaw 验证失败"
      all_ok=false
    fi
  fi

  if [[ "$INSTALL_CODEX" == "true" ]]; then
    if command -v codex &>/dev/null; then
      print_success "Codex $(codex --version 2>/dev/null | head -1)"
    else
      print_error "Codex 验证失败"
      all_ok=false
    fi
  fi

  if [[ "$all_ok" == "false" ]]; then
    echo ""
    print_warning "部分工具验证失败，请重新打开终端后运行："
    print_cmd "source $SHELL_RC"
  fi
}

# ─────────────────────────────────────────────
# OpenClaw 渠道配置引导
# ─────────────────────────────────────────────
setup_openclaw_channels() {
  if [[ "$INSTALL_OPENCLAW" != "true" ]]; then return; fi

  print_step "配置 OpenClaw 渠道"
  echo ""
  echo -e "  ${WHITE}即将启动 OpenClaw 配置向导${NC}"
  echo -e "  ${DIM}向导将引导你选择接入渠道（Telegram / Discord / Slack 等）${NC}"
  echo -e "  ${YELLOW}⚠️  请提前准备好你想接入渠道的 Bot Token${NC}"
  echo ""
  echo -e "  ${GRAY}详细配置文档：docs/openclaw-channel-setup.md${NC}"
  echo ""
  read -p "  是否现在启动配置向导？[Y/n] " confirm
  confirm="${confirm:-Y}"

  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo ""
    openclaw onboard --install-daemon
  else
    echo ""
    print_info "稍后可手动运行：openclaw onboard --install-daemon"
    print_info "配置文档参考：docs/openclaw-channel-setup.md"
  fi
}

# ─────────────────────────────────────────────
# 完成总结
# ─────────────────────────────────────────────
print_summary() {
  echo ""
  echo -e "${MAGENTA}  ╔═══════════════════════════════════════════════════════╗${NC}"
  echo -e "${MAGENTA}  ║${NC}  ${GREEN}${BOLD}🎉 安装完成！${NC}                                       ${MAGENTA}║${NC}"
  echo -e "${MAGENTA}  ╠═══════════════════════════════════════════════════════╣${NC}"
  echo -e "${MAGENTA}  ║${NC}                                                       ${MAGENTA}║${NC}"

  if [[ "$INSTALL_CLAUDE" == "true" ]]; then
    echo -e "${MAGENTA}  ║${NC}  ${CYAN}Claude Code${NC}                                          ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}  ║${NC}  ${DIM}$ claude                   # 启动${NC}                   ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}  ║${NC}  ${DIM}$ claude --help            # 查看帮助${NC}               ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}  ║${NC}                                                       ${MAGENTA}║${NC}"
  fi

  if [[ "$INSTALL_OPENCLAW" == "true" ]]; then
    echo -e "${MAGENTA}  ║${NC}  ${CYAN}OpenClaw${NC}                                             ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}  ║${NC}  ${DIM}$ openclaw start           # 启动网关${NC}               ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}  ║${NC}  ${DIM}配置文档：docs/openclaw-channel-setup.md${NC}             ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}  ║${NC}                                                       ${MAGENTA}║${NC}"
  fi

  if [[ "$INSTALL_CCSWITCH" == "true" && "$OS" == "macos" ]]; then
    echo -e "${MAGENTA}  ║${NC}  ${CYAN}CCSwitch${NC}                                             ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}  ║${NC}  ${DIM}在 Applications 中打开 CCSwitch 配置 API Key${NC}         ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}  ║${NC}                                                       ${MAGENTA}║${NC}"
  fi

  if [[ "$INSTALL_CODEX" == "true" ]]; then
    echo -e "${MAGENTA}  ║${NC}  ${CYAN}Codex${NC}                                                ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}  ║${NC}  ${DIM}$ codex                    # 启动${NC}                   ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}  ║${NC}                                                       ${MAGENTA}║${NC}"
  fi

  echo -e "${MAGENTA}  ╠═══════════════════════════════════════════════════════╣${NC}"
  echo -e "${MAGENTA}  ║${NC}  ${YELLOW}⚠️  请重新打开终端使环境变量生效${NC}                     ${MAGENTA}║${NC}"
  echo -e "${MAGENTA}  ║${NC}  ${DIM}或运行：source $SHELL_RC${NC}            ${MAGENTA}║${NC}"
  echo -e "${MAGENTA}  ╚═══════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "  ${DIM}GURU AI TECH · 内部技术分享 · 2026-03-12${NC}"
  echo ""
}

# ─────────────────────────────────────────────
# 主流程
# ─────────────────────────────────────────────
main() {
  clear
  print_banner
  detect_os
  check_homebrew
  check_node
  select_tools
  configure_api_keys
  install_tools
  verify_installation
  setup_openclaw_channels
  print_summary
}

main "$@"
