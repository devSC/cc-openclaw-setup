# =============================================================================
# GURU AI TECH — AI 工具一键安装脚本 (Windows PowerShell)
# Claude Code · OpenClaw · CCSwitch · Codex
# Version: 1.0.0 | 2026-03-12
# =============================================================================

#Requires -Version 5.1

$ErrorActionPreference = "Stop"

# ─────────────────────────────────────────────
# 颜色工具函数
# ─────────────────────────────────────────────
function Write-Step    { Write-Host "`n▶ $args" -ForegroundColor Cyan }
function Write-Success { Write-Host "✅ $args" -ForegroundColor Green }
function Write-Warning { Write-Host "⚠️  $args" -ForegroundColor Yellow }
function Write-Err     { Write-Host "❌ $args" -ForegroundColor Red }
function Write-Info    { Write-Host "   $args" -ForegroundColor Gray }
function Write-Cmd     { Write-Host "   `$ $args" -ForegroundColor DarkGray }

# ─────────────────────────────────────────────
# BANNER
# ─────────────────────────────────────────────
function Print-Banner {
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "  ║                                                       ║" -ForegroundColor Magenta
    Write-Host "  ║        ██████╗ ██╗   ██╗██████╗ ██╗   ██╗            ║" -ForegroundColor Magenta
    Write-Host "  ║       ██╔════╝ ██║   ██║██╔══██╗██║   ██║            ║" -ForegroundColor Magenta
    Write-Host "  ║       ██║  ███╗██║   ██║██████╔╝██║   ██║            ║" -ForegroundColor Magenta
    Write-Host "  ║       ██║   ██║██║   ██║██╔══██╗██║   ██║            ║" -ForegroundColor Magenta
    Write-Host "  ║       ╚██████╔╝╚██████╔╝██║  ██║╚██████╔╝            ║" -ForegroundColor Magenta
    Write-Host "  ║        ╚═════╝  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝             ║" -ForegroundColor Magenta
    Write-Host "  ║                                                       ║" -ForegroundColor Magenta
    Write-Host "  ║              ✦  A I   T E C H  ✦                     ║" -ForegroundColor Magenta
    Write-Host "  ║                                                       ║" -ForegroundColor Magenta
    Write-Host "  ╠═══════════════════════════════════════════════════════╣" -ForegroundColor Magenta
    Write-Host "  ║                                                       ║" -ForegroundColor Magenta
    Write-Host "  ║        AI 编程助手一键安装脚本  v1.0.0                ║" -ForegroundColor Magenta
    Write-Host "  ║        Claude Code · OpenClaw · CCSwitch · Codex      ║" -ForegroundColor Magenta
    Write-Host "  ║                                                       ║" -ForegroundColor Magenta
    Write-Host "  ║        Windows 版本 (WSL2 方案)                       ║" -ForegroundColor Magenta
    Write-Host "  ║                                                       ║" -ForegroundColor Magenta
    Write-Host "  ╚═══════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
}

# ─────────────────────────────────────────────
# 检测 WSL2
# ─────────────────────────────────────────────
function Check-WSL2 {
    Write-Step "检测 WSL2 环境"

    $wslInstalled = Get-Command wsl -ErrorAction SilentlyContinue
    if (-not $wslInstalled) {
        Write-Err "未检测到 WSL（Windows Subsystem for Linux）"
        Write-Host ""
        Write-Host "  Claude Code 和 OpenClaw 在 Windows 上需要通过 WSL2 运行。" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  ┌─────────────────────────────────────────────────────┐"
        Write-Host "  │  一键安装 WSL2（以管理员身份运行 PowerShell）       │"
        Write-Host "  │                                                     │"
        Write-Host "  │  wsl --install                                      │"
        Write-Host "  │                                                     │"
        Write-Host "  │  安装完成后重启电脑，再次运行本脚本                 │"
        Write-Host "  └─────────────────────────────────────────────────────┘"
        Write-Host ""
        $choice = Read-Host "  是否现在自动安装 WSL2？需要管理员权限。[Y/n]"
        if ($choice -eq "" -or $choice -match "^[Yy]$") {
            Install-WSL2
        }
        else {
            Write-Info "请手动安装 WSL2 后重新运行此脚本"
            Write-Info "官方文档：https://docs.microsoft.com/zh-cn/windows/wsl/install"
            exit 1
        }
    }

    # 检查 WSL2 是否有可用发行版
    $wslList = wsl --list --quiet 2>$null
    if (-not $wslList) {
        Write-Warning "WSL 已安装，但未找到 Linux 发行版"
        Write-Host ""
        Write-Host "  请安装 Ubuntu（推荐）：" -ForegroundColor Yellow
        Write-Cmd "wsl --install -d Ubuntu"
        Write-Host ""
        $choice = Read-Host "  是否现在安装 Ubuntu？[Y/n]"
        if ($choice -eq "" -or $choice -match "^[Yy]$") {
            wsl --install -d Ubuntu
            Write-Warning "Ubuntu 安装完成后需要重启，请重启后重新运行此脚本"
            exit 0
        }
        else {
            exit 1
        }
    }

    Write-Success "WSL2 已就绪"
    Write-Host ""

    # 显示当前发行版
    Write-Info "可用的 Linux 发行版："
    wsl --list --verbose 2>$null | ForEach-Object { Write-Info "  $_" }
}

# ─────────────────────────────────────────────
# 安装 WSL2
# ─────────────────────────────────────────────
function Install-WSL2 {
    Write-Info "正在启用 WSL 功能..."
    try {
        # 检查是否有管理员权限
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $isAdmin) {
            Write-Err "需要管理员权限安装 WSL2"
            Write-Info "请右键点击 PowerShell → 以管理员身份运行，然后重新执行此脚本"
            exit 1
        }
        wsl --install
        Write-Success "WSL2 安装完成，请重启电脑后再次运行此脚本"
        Read-Host "按 Enter 退出"
        exit 0
    }
    catch {
        Write-Err "WSL2 安装失败：$_"
        Write-Info "请参考官方文档手动安装：https://docs.microsoft.com/zh-cn/windows/wsl/install"
        exit 1
    }
}

# ─────────────────────────────────────────────
# 将 setup.sh 传入 WSL2 执行
# ─────────────────────────────────────────────
function Run-InWSL {
    Write-Step "在 WSL2 中执行安装脚本"
    Write-Host ""
    Write-Host "  ℹ️  Claude Code 和 OpenClaw 将安装在 WSL2（Linux）环境中" -ForegroundColor Cyan
    Write-Host "  ℹ️  安装完成后，在 WSL2 终端中使用这些工具" -ForegroundColor Cyan
    Write-Host ""

    # 获取脚本所在目录
    $scriptDir = Split-Path -Parent $MyInvocation.ScriptName
    $setupSh = Join-Path $scriptDir "setup.sh"

    if (-not (Test-Path $setupSh)) {
        Write-Err "找不到 setup.sh（应与 setup.ps1 在同一目录）"
        Write-Info "请确保 setup.sh 存在于：$scriptDir"
        exit 1
    }

    # 将 Windows 路径转换为 WSL 路径
    $wslPath = wsl wslpath -a ($setupSh -replace '\\', '/')
    $wslPath = $wslPath.Trim()

    Write-Info "执行：bash $wslPath"
    Write-Host ""

    # 在 WSL 中执行
    wsl bash "$wslPath"
}

# ─────────────────────────────────────────────
# CCSwitch 说明（Windows 无桌面版）
# ─────────────────────────────────────────────
function Show-CCSwitchNote {
    Write-Host ""
    Write-Host "  ┌─────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "  │  CCSwitch 桌面版仅支持 macOS                           │" -ForegroundColor DarkGray
    Write-Host "  │                                                         │" -ForegroundColor DarkGray
    Write-Host "  │  Windows / WSL 用户可使用以下方式管理 API Key：        │" -ForegroundColor DarkGray
    Write-Host "  │                                                         │" -ForegroundColor DarkGray
    Write-Host "  │  方式 1：在 ~/.bashrc 或 ~/.zshrc 中写入              │" -ForegroundColor DarkGray
    Write-Host "  │    export ANTHROPIC_API_KEY=""sk-ant-xxx""             │" -ForegroundColor DarkGray
    Write-Host "  │                                                         │" -ForegroundColor DarkGray
    Write-Host "  │  方式 2：在 Windows 系统环境变量中配置                │" -ForegroundColor DarkGray
    Write-Host "  │    系统属性 → 高级 → 环境变量 → 新建                 │" -ForegroundColor DarkGray
    Write-Host "  └─────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
}

# ─────────────────────────────────────────────
# 完成提示
# ─────────────────────────────────────────────
function Print-Summary {
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "  ║  🎉 安装完成！                                        ║" -ForegroundColor Magenta
    Write-Host "  ╠═══════════════════════════════════════════════════════╣" -ForegroundColor Magenta
    Write-Host "  ║                                                       ║" -ForegroundColor Magenta
    Write-Host "  ║  工具已安装在 WSL2 中，使用方式：                    ║" -ForegroundColor Magenta
    Write-Host "  ║                                                       ║" -ForegroundColor Magenta
    Write-Host "  ║  1. 打开 Windows Terminal → 选择 Ubuntu               ║" -ForegroundColor Magenta
    Write-Host "  ║  2. 或在 PowerShell 中输入 wsl 进入 Linux 环境        ║" -ForegroundColor Magenta
    Write-Host "  ║                                                       ║" -ForegroundColor Magenta
    Write-Host "  ║  $ claude         # 启动 Claude Code                 ║" -ForegroundColor Magenta
    Write-Host "  ║  $ openclaw start # 启动 OpenClaw                    ║" -ForegroundColor Magenta
    Write-Host "  ║                                                       ║" -ForegroundColor Magenta
    Write-Host "  ╠═══════════════════════════════════════════════════════╣" -ForegroundColor Magenta
    Write-Host "  ║  ⚠️  CCSwitch 桌面版仅支持 macOS                      ║" -ForegroundColor Yellow
    Write-Host "  ║     Windows 用户请在 WSL2 环境变量中配置 API Key     ║" -ForegroundColor Yellow
    Write-Host "  ╚═══════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  GURU AI TECH · 内部技术分享 · 2026-03-12" -ForegroundColor DarkGray
    Write-Host ""
}

# ─────────────────────────────────────────────
# 主流程
# ─────────────────────────────────────────────
function Main {
    Clear-Host
    Print-Banner
    Check-WSL2
    Show-CCSwitchNote
    Write-Host ""

    $confirm = Read-Host "  准备好了吗？即将在 WSL2 中启动安装向导。按 Enter 继续，或 Ctrl+C 取消"
    Write-Host ""

    Run-InWSL
    Print-Summary
}

Main
