#!/bin/bash
# Dev Sentinel - Stop Hook
# 任务完成时统计文件操作并发送通知

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // ""')
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')

# 防止无限循环
[ "$STOP_HOOK_ACTIVE" = "true" ] && exit 0

echo "=== Dev Sentinel 任务完成 ==="
echo "会话: $SESSION_ID"
echo "项目: $(basename "$PROJECT_DIR")"
echo ""

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
RECORD_FILE="$PROJECT_DIR/.claude/operations.log"

# ==================== CMake 编译检查 ====================

# if [ -f "$PROJECT_DIR/CMakeLists.txt" ]; then
#     echo "📦 CMake 编译检查..."
#     cd "$PROJECT_DIR"
#     mkdir -p build && cd build
#
#     if cmake .. && make; then
#         echo "✅ 编译成功"
#     else
#         echo "❌ 编译失败"
#         # 取消注释以阻止 Claude 停止
#         # cat <<EOF
#         # {
#         #   "decision": "block",
#         #   "reason": "编译失败，请修复错误"
#         # }
#         # EOF
#         # exit 0
#     fi
#     cd "$PROJECT_DIR"
#     echo ""
# fi

# ==================== 统计文件操作 ====================

if [ -f "$RECORD_FILE" ]; then
    CREATE_COUNT=$(grep -c "创建 |" "$RECORD_FILE" 2>/dev/null || echo 0)
    MODIFY_COUNT=$(grep -c "修改 |" "$RECORD_FILE" 2>/dev/null || echo 0)
    TOTAL_COUNT=$((CREATE_COUNT + MODIFY_COUNT))

    echo "📊 文件操作统计："
    echo "   创建: $CREATE_COUNT 个"
    echo "   修改: $MODIFY_COUNT 个"
    echo "   总计: $TOTAL_COUNT 个"
    echo ""

    if [ $TOTAL_COUNT -gt 0 ]; then
        FILE_SUMMARY=$(cat "$RECORD_FILE" | tail -20 | sed 's/\[.*\] //')

        echo "📝 操作的文件（最近 20 个）："
        echo "$FILE_SUMMARY" | head -20
        echo ""
    fi
fi

# ==================== 发送通知 ====================

# 飞书通知
# if [ -f "$RECORD_FILE" ]; then
#     WEBHOOK="https://open.feishu.cn/open-apis/bot/v2/hook/YOUR_WEBHOOK"
#
#     MESSAGE="✅ Claude 任务完成\n\n"
#     MESSAGE+="会话: $SESSION_ID\n"
#     MESSAGE+="时间: $TIMESTAMP\n"
#     MESSAGE+="项目: $(basename "$PROJECT_DIR")\n\n"
#     MESSAGE+="📊 文件操作:\n"
#     MESSAGE+="创建: $CREATE_COUNT 个\n"
#     MESSAGE+="修改: $MODIFY_COUNT 个\n"
#     MESSAGE+="总计: $TOTAL_COUNT 个\n\n"
#
#     if [ -n "$FILE_SUMMARY" ]; then
#         MESSAGE+="📝 操作的文件:\n"
#         MESSAGE+="$(echo "$FILE_SUMMARY" | head -10)\n"
#         [ $TOTAL_COUNT -gt 10 ] && MESSAGE+="... 还有 $((TOTAL_COUNT - 10)) 个\n"
#     fi
#
#     curl -s -X POST "$WEBHOOK" -H "Content-Type: application/json" \
#       -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"$MESSAGE\"}}"
# fi

# Slack 通知
# if [ -f "$RECORD_FILE" ]; then
#     WEBHOOK="https://hooks.slack.com/services/YOUR/WEBHOOK"
#
#     MESSAGE="✅ Claude 完成\n"
#     MESSAGE+="创建: $CREATE_COUNT | 修改: $MODIFY_COUNT\n\n"
#     MESSAGE+="$(echo "$FILE_SUMMARY" | head -5)"
#
#     curl -s -X POST "$WEBHOOK" -H "Content-Type: application/json" \
#       -d "{\"text\":\"$MESSAGE\"}"
# fi

# 桌面通知（跨平台：自动检测 WSL/Linux/macOS）
# if [ -f "$RECORD_FILE" ]; then
#     SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#     MESSAGE="创建 $CREATE_COUNT 个，修改 $MODIFY_COUNT 个文件"
#     bash "$SCRIPT_DIR/notify.sh" "Dev Sentinel" "$MESSAGE"
# fi

# ==================== 清理日志 ====================

if [ -f "$RECORD_FILE" ]; then
    rm "$RECORD_FILE"
    echo "🗑️  已清理日志文件"
fi

echo "✓ 完成"
exit 0
