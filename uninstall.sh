#!/usr/bin/env bash
# =============================================================================
# GURU AI TECH — AI 工具一键卸载脚本（测试用）
# Claude Code · OpenClaw · CCSwitch · Codex
# =============================================================================

set -euo pipefail

SHELL_RC="$HOME/.zshrc"
[[ "$SHELL" == *"bash"* ]] && SHELL_RC="$HOME/.bash_profile"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
DIM='\033[2m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✅ $1${NC}"; }
skip() { echo -e "${YELLOW}⏭  $1${NC}"; }
info() { echo -e "${CYAN}ℹ  $1${NC}"; }
err()  { echo -e "${RED}❌ $1${NC}"; }

# ─────────────────────────────────────────────
# 检测已安装的工具
# ─────────────────────────────────────────────
CLAUDE_INSTALLED=false
OPENCLAW_INSTALLED=false
CCSWITCH_INSTALLED=false
CODEX_INSTALLED=false

[[ -f "$HOME/.local/bin/claude" ]] || command -v claude &>/dev/null && CLAUDE_INSTALLED=true || true
command -v openclaw &>/dev/null && OPENCLAW_INSTALLED=true || true
{ [[ -d "/Applications/CCSwitch.app" ]] || [[ -d "/Applications/CC Switch.app" ]]; } && CCSWITCH_INSTALLED=true || true
command -v codex &>/dev/null && CODEX_INSTALLED=true || true

installed=("$CLAUDE_INSTALLED" "$OPENCLAW_INSTALLED" "$CCSWITCH_INSTALLED" "$CODEX_INSTALLED")

# ─────────────────────────────────────────────
# 多选菜单
# ─────────────────────────────────────────────
echo ""
echo -e "${CYAN}▶ 选择要卸载的工具${NC}"
echo ""
echo -e "  ${WHITE}使用空格键选择/取消，回车键确认${NC}"
echo -e "  ${DIM}（已安装的工具默认全选）${NC}"
echo ""

tools=(
  "Claude Code  (@anthropic-ai/claude-code)"
  "OpenClaw     (openclaw)"
  "CCSwitch     (桌面版)"
  "Codex        (@openai/codex)"
)

# 默认选中所有已安装的工具
selected=("$CLAUDE_INSTALLED" "$OPENCLAW_INSTALLED" "$CCSWITCH_INSTALLED" "$CODEX_INSTALLED")

current=0
total=${#tools[@]}
lines=$((total + 2))

draw_menu() {
  for i in "${!tools[@]}"; do
    if [[ "${installed[$i]}" == "false" ]]; then
      marker="${GRAY}[ ]${NC}"; suffix="${DIM} 未安装${NC}"
    elif [[ "${selected[$i]}" == "true" ]]; then
      marker="${RED}[✓]${NC}"; suffix=""
    else
      marker="${GRAY}[ ]${NC}"; suffix=""
    fi
    [[ "$i" == "$current" ]] \
      && echo -e "  ${CYAN}▶${NC} ${marker} ${tools[$i]}${suffix}" \
      || echo -e "    ${marker} ${tools[$i]}${suffix}"
  done
  echo ""
  echo -e "  ${DIM}↑↓ 移动  Space 选择  Enter 确认  ${GRAY}[ ] 未安装（不可选）${NC}"
}

draw_menu

while true; do
  printf "\033[%dA\033[J" "$lines"
  draw_menu

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
      # 未安装的不可选
      if [[ "${installed[$current]}" == "true" ]]; then
        if [[ "${selected[$current]}" == "true" ]]; then
          selected[$current]=false
        else
          selected[$current]=true
        fi
      fi
      ;;
    '') break ;;
  esac
done

UNINSTALL_CLAUDE="${selected[0]}"
UNINSTALL_OPENCLAW="${selected[1]}"
UNINSTALL_CCSWITCH="${selected[2]}"
UNINSTALL_CODEX="${selected[3]}"

# 确认摘要
echo ""
echo -e "  ${WHITE}确认卸载：${NC}"
[[ "$UNINSTALL_CLAUDE"   == "true" ]] && echo -e "  ${RED}✗${NC} Claude Code" || true
[[ "$UNINSTALL_OPENCLAW" == "true" ]] && echo -e "  ${RED}✗${NC} OpenClaw"    || true
[[ "$UNINSTALL_CCSWITCH" == "true" ]] && echo -e "  ${RED}✗${NC} CCSwitch"    || true
[[ "$UNINSTALL_CODEX"    == "true" ]] && echo -e "  ${RED}✗${NC} Codex"       || true

# 检查是否一项都没选
if [[ "$UNINSTALL_CLAUDE$UNINSTALL_OPENCLAW$UNINSTALL_CCSWITCH$UNINSTALL_CODEX" != *"true"* ]]; then
  echo ""
  info "未选择任何工具，退出。"
  exit 0
fi

echo ""
read -rp "  确认卸载以上工具？[y/N] " confirm
confirm="${confirm:-N}"
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo ""
  info "已取消。"
  exit 0
fi

# ─────────────────────────────────────────────
# 执行卸载
# ─────────────────────────────────────────────
echo ""
echo -e "${CYAN}▶ 开始卸载${NC}"

if [[ "$UNINSTALL_CLAUDE" == "true" ]]; then
  echo ""
  echo -e "  ${CYAN}正在卸载 Claude Code...${NC}"
  rm -f "$HOME/.local/bin/claude"
  ok "Claude Code 已卸载"
fi

if [[ "$UNINSTALL_OPENCLAW" == "true" ]]; then
  echo ""
  echo -e "  ${CYAN}正在卸载 OpenClaw...${NC}"
  npm uninstall -g openclaw && ok "OpenClaw 已卸载" || err "OpenClaw 卸载失败"
fi

if [[ "$UNINSTALL_CCSWITCH" == "true" ]]; then
  echo ""
  echo -e "  ${CYAN}正在卸载 CCSwitch...${NC}"
  brew uninstall --cask cc-switch && ok "CCSwitch 已卸载" || err "CCSwitch 卸载失败"
fi

if [[ "$UNINSTALL_CODEX" == "true" ]]; then
  echo ""
  echo -e "  ${CYAN}正在卸载 Codex...${NC}"
  npm uninstall -g @openai/codex && ok "Codex 已卸载" || err "Codex 卸载失败"
fi

# ─────────────────────────────────────────────
# 清理 rc 文件
# ─────────────────────────────────────────────
echo ""
echo -e "${CYAN}▶ 清理环境变量${NC}"
echo ""

for key in ANTHROPIC_API_KEY ANTHROPIC_BASE_URL OPENAI_API_KEY OPENAI_BASE_URL; do
  if grep -q "export ${key}=" "$SHELL_RC" 2>/dev/null; then
    sed -i.bak "/export ${key}=/d" "$SHELL_RC"
    ok "已移除 ${key}"
  else
    skip "${key} 不存在，跳过"
  fi
done

if grep -q '\.local/bin' "$SHELL_RC" 2>/dev/null; then
  sed -i.bak '/\.local\/bin/d' "$SHELL_RC"
  ok "已移除 ~/.local/bin PATH 条目"
fi

echo ""
echo -e "${GREEN}✅ 卸载完成。重新打开终端或运行：source $SHELL_RC${NC}"
echo ""
