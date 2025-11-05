#!/bin/bash
# Dev Sentinel - PostToolUse Hook
# 追踪文件创建和修改操作

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

# 配置记录文件路径
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(echo "$INPUT" | jq -r '.cwd // ""')}"
RECORD_FILE="$PROJECT_ROOT/.claude/operations.log"
mkdir -p "$(dirname "$RECORD_FILE")"

# 基础信息
echo "=== Dev Sentinel 文件追踪 ==="
echo "工具: $TOOL_NAME"
echo "文件: $FILE_PATH"
echo ""

# ==================== 记录文件操作 ====================

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 从 PreToolUse 钩子保存的状态文件读取文件原始状态
STATE_DIR="$PROJECT_ROOT/.claude/dev-sentinel"
FILE_HASH=$(echo "$FILE_PATH" | md5sum | awk '{print $1}')
STATE_FILE="$STATE_DIR/file_state_${FILE_HASH}.tmp"

# 判断是创建还是修改
if [ -f "$STATE_FILE" ]; then
    FILE_STATE=$(cat "$STATE_FILE")
    if [ "$FILE_STATE" = "new" ]; then
        OPERATION="创建"
    else
        OPERATION="修改"
    fi
    # 清理临时状态文件
    rm -f "$STATE_FILE"
    rm -f "$STATE_DIR/file_path_${FILE_HASH}.tmp"
else
    # 如果没有状态文件（可能 PreToolUse 未执行），回退到原逻辑
    if [ -f "$FILE_PATH" ]; then
        OPERATION="修改"
    else
        OPERATION="创建"
    fi
fi

# 记录格式：[时间戳] 操作类型 | 文件路径
echo "[$TIMESTAMP] $OPERATION | $FILE_PATH" >> "$RECORD_FILE"

echo "✓ 已记录: $OPERATION"

# ==================== 自动化操作 ====================

# 自动格式化（可选）
# case "${FILE_PATH##*.}" in
#     ts|tsx|js|jsx)
#         prettier --write "$FILE_PATH" 2>&1
#         ;;
#     py)
#         black "$FILE_PATH" 2>&1
#         ;;
#     cpp|hpp|c|h)
#         clang-format -i "$FILE_PATH" 2>&1
#         ;;
# esac

# Git 自动暂存（可选）
# if [ -d "$PROJECT_ROOT/.git" ]; then
#     cd "$PROJECT_ROOT" && git add "$FILE_PATH"
#     echo "✓ 已暂存到 Git"
# fi

exit 0
