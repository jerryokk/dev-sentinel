#!/bin/bash
# Dev Sentinel - PreToolUse Hook
# 在工具执行前检查文件状态

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // {}')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')

FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // ""')

# 只处理文件操作工具
case "$TOOL_NAME" in
    Edit|Write|MultiEdit|NotebookEdit)
        ;;
    *)
        exit 0
        ;;
esac

# 如果没有文件路径，跳过
if [ -z "$FILE_PATH" ] || [ "$FILE_PATH" = "null" ]; then
    exit 0
fi

# 配置状态文件路径
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(echo "$INPUT" | jq -r '.cwd // ""')}"
STATE_DIR="$PROJECT_ROOT/.claude/dev-sentinel"
mkdir -p "$STATE_DIR"

# 生成文件状态标识（使用文件路径的 hash）
FILE_HASH=$(echo "$FILE_PATH" | md5sum | awk '{print $1}')
STATE_FILE="$STATE_DIR/file_state_${FILE_HASH}.tmp"

# 检查文件是否存在，并保存状态
if [ -f "$FILE_PATH" ]; then
    echo "exists" > "$STATE_FILE"
else
    echo "new" > "$STATE_FILE"
fi

# 保存文件路径供 PostToolUse 使用
echo "$FILE_PATH" > "$STATE_DIR/file_path_${FILE_HASH}.tmp"

exit 0
