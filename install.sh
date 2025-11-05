#!/bin/bash
# Dev Sentinel 一键安装脚本

set -e

echo "🛡️  Dev Sentinel 安装程序"
echo ""

# 检测安装目录
if [ -z "$1" ]; then
    INSTALL_DIR="$(pwd)"
    echo "📂 安装到当前目录: $INSTALL_DIR"
else
    INSTALL_DIR="$1"
    echo "📂 安装到指定目录: $INSTALL_DIR"
fi

echo ""

# GitHub 仓库信息
GITHUB_REPO="jerryokk/dev-sentinel"
GITHUB_RAW="https://raw.githubusercontent.com/$GITHUB_REPO/main"

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
PLUGIN_DIR="$SCRIPT_DIR/plugins/dev-sentinel"

# 检测是否从管道安装（curl | bash）
IS_REMOTE_INSTALL=false
if [[ "${BASH_SOURCE[0]}" == *"/dev/fd/"* ]] || [ -z "${BASH_SOURCE[0]}" ] || [ ! -d "$PLUGIN_DIR" ]; then
    IS_REMOTE_INSTALL=true
    echo "🌐 检测到远程安装模式"
    echo "📥 正在下载文件..."

    # 创建临时目录
    TMP_DIR=$(mktemp -d)
    PLUGIN_DIR="$TMP_DIR/plugins/dev-sentinel"
    mkdir -p "$PLUGIN_DIR/scripts"
    mkdir -p "$PLUGIN_DIR/hooks"

    # 下载所需文件
    FILES=(
        "plugins/dev-sentinel/scripts/user-prompt-submit.sh"
        "plugins/dev-sentinel/scripts/pre-tool-use.sh"
        "plugins/dev-sentinel/scripts/post-tool-use.sh"
        "plugins/dev-sentinel/scripts/stop-notification.sh"
        "plugins/dev-sentinel/scripts/notify.sh"
        "plugins/dev-sentinel/scripts/notify.ps1"
    )

    for file in "${FILES[@]}"; do
        target="$TMP_DIR/$file"
        mkdir -p "$(dirname "$target")"
        if ! curl -fsSL "$GITHUB_RAW/$file" -o "$target"; then
            echo "❌ 错误: 下载文件失败 $file"
            rm -rf "$TMP_DIR"
            exit 1
        fi
    done

    echo "✅ 文件下载完成"
    echo ""
fi

# 创建目录
echo "📁 创建目录..."
mkdir -p "$INSTALL_DIR/.claude/hooks"
mkdir -p "$INSTALL_DIR/.claude/scripts"

# 复制脚本文件
echo "📋 复制脚本文件..."
cp "$PLUGIN_DIR/scripts/user-prompt-submit.sh" "$INSTALL_DIR/.claude/hooks/"
cp "$PLUGIN_DIR/scripts/pre-tool-use.sh" "$INSTALL_DIR/.claude/hooks/"
cp "$PLUGIN_DIR/scripts/post-tool-use.sh" "$INSTALL_DIR/.claude/hooks/"
cp "$PLUGIN_DIR/scripts/stop-notification.sh" "$INSTALL_DIR/.claude/hooks/"
cp "$PLUGIN_DIR/scripts/notify.sh" "$INSTALL_DIR/.claude/scripts/"
cp "$PLUGIN_DIR/scripts/notify.ps1" "$INSTALL_DIR/.claude/scripts/"

# 添加执行权限
echo "🔑 设置执行权限..."
chmod +x "$INSTALL_DIR/.claude/hooks"/*.sh
chmod +x "$INSTALL_DIR/.claude/scripts"/*.sh

# 更新脚本中的路径引用
echo "🔧 更新路径配置..."
sed -i.bak 's|\${CLAUDE_PLUGIN_ROOT}|${CLAUDE_PROJECT_DIR}/.claude|g' "$INSTALL_DIR/.claude/hooks/stop-notification.sh"
rm -f "$INSTALL_DIR/.claude/hooks/stop-notification.sh.bak"

# 创建或更新 settings.json
SETTINGS_FILE="$INSTALL_DIR/.claude/settings.json"
echo "⚙️  配置钩子..."

if [ -f "$SETTINGS_FILE" ]; then
    echo "⚠️  settings.json 已存在，请手动合并以下配置："
    echo ""
    cat << 'EOF'
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PROJECT_DIR}/.claude/hooks/user-prompt-submit.sh",
            "timeout": 30
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PROJECT_DIR}/.claude/hooks/pre-tool-use.sh",
            "timeout": 30
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PROJECT_DIR}/.claude/hooks/post-tool-use.sh",
            "timeout": 30
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PROJECT_DIR}/.claude/hooks/stop-notification.sh",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
EOF
else
    cat > "$SETTINGS_FILE" << 'EOF'
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PROJECT_DIR}/.claude/hooks/user-prompt-submit.sh",
            "timeout": 30
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PROJECT_DIR}/.claude/hooks/post-tool-use.sh",
            "timeout": 30
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PROJECT_DIR}/.claude/hooks/pre-tool-use.sh",
            "timeout": 30
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PROJECT_DIR}/.claude/hooks/stop-notification.sh",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
EOF
    echo "✅ 已创建 settings.json"
fi

# 清理临时目录
if [ "$IS_REMOTE_INSTALL" = true ]; then
    echo "🧹 清理临时文件..."
    rm -rf "$TMP_DIR"
fi

echo ""
echo "✨ 安装完成！"
echo ""
echo "📁 文件位置："
echo "   配置: $INSTALL_DIR/.claude/settings.json"
echo "   钩子: $INSTALL_DIR/.claude/hooks/"
echo "   脚本: $INSTALL_DIR/.claude/scripts/"
echo ""
echo "📝 下一步："
echo "   1. 查看日志: cat $INSTALL_DIR/.claude/operations.log"
echo "   2. 自定义钩子: 编辑 .claude/hooks/*.sh 中的注释代码"
echo "   3. 重启 Claude Code 使钩子生效"
echo ""
echo "📖 文档: https://github.com/jerryokk/dev-sentinel"
