#!/bin/bash
# Dev Sentinel 跨平台通知脚本
# 自动检测环境并发送通知

TITLE="${1:-Dev Sentinel}"
MESSAGE="${2:-通知消息}"

# 检测环境
detect_environment() {
    if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# WSL 环境通知（调用 Windows）
notify_wsl() {
    local title="$1"
    local message="$2"

    # 查找 notify.ps1 脚本位置
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local ps1_script="$script_dir/notify.ps1"

    # 转换为 Windows 路径
    local win_script=$(wslpath -w "$ps1_script" 2>/dev/null || echo "$ps1_script")

    # 调用 Windows PowerShell
    /mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe \
        -ExecutionPolicy Bypass \
        -File "$win_script" \
        "$message" \
        "$title" 2>/dev/null

    return $?
}

# Linux 原生通知
notify_linux() {
    local title="$1"
    local message="$2"

    if command -v notify-send &> /dev/null; then
        notify-send "$title" "$message" -i dialog-information
        return $?
    else
        echo "⚠️  notify-send 未安装，跳过通知" >&2
        return 1
    fi
}

# macOS 通知
notify_macos() {
    local title="$1"
    local message="$2"

    osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null
    return $?
}

# 主逻辑
ENV=$(detect_environment)

case "$ENV" in
    wsl)
        notify_wsl "$TITLE" "$MESSAGE"
        ;;
    linux)
        notify_linux "$TITLE" "$MESSAGE"
        ;;
    macos)
        notify_macos "$TITLE" "$MESSAGE"
        ;;
    *)
        echo "⚠️  不支持的环境: $ENV" >&2
        exit 1
        ;;
esac

exit $?
