#!/bin/bash
# Dev Sentinel - UserPromptSubmit Hook
# 用户提交提示词时触发

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // ""')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')

echo "=== Dev Sentinel 开发哨兵 ==="
echo "会话: $SESSION_ID"
echo "提示词长度: ${#PROMPT} 字符"
echo ""

# ==================== 附加项目信息 ====================

# Git 信息
# if [ -d "$PROJECT_DIR/.git" ]; then
#     cd "$PROJECT_DIR"
#     echo "📂 Git 信息："
#     echo "   分支: $(git branch --show-current 2>/dev/null)"
#     echo "   未提交: $(git status -s 2>/dev/null | wc -l) 个文件"
#     echo ""
# fi

# 环境信息
# echo "🔧 环境："
# [ -x "$(command -v node)" ] && echo "   Node: $(node --version)"
# [ -x "$(command -v python3)" ] && echo "   Python: $(python3 --version)"
# [ -x "$(command -v g++)" ] && echo "   g++: $(g++ --version | head -1)"
# echo ""

# ==================== 智能技能推荐 ====================

# 根据提示词关键词自动推荐 Claude Code 技能

# 数据库相关
# if echo "$PROMPT" | grep -Eqi "数据库|database|mysql|postgresql|sql|查询"; then
#     echo "💡 检测到数据库操作，建议："
#     echo "   /skill mysql     - MySQL 数据库操作"
#     echo "   /skill postgres  - PostgreSQL 数据库操作"
#     echo ""
# fi

# 测试相关
# if echo "$PROMPT" | grep -Eqi "测试|test|playwright|selenium|单元测试|集成测试"; then
#     echo "💡 检测到测试任务，建议："
#     echo "   /skill playwright - Web 端到端测试"
#     echo "   /skill pytest     - Python 单元测试"
#     echo ""
# fi

# PDF 处理
# if echo "$PROMPT" | grep -Eqi "pdf|文档处理|解析pdf"; then
#     echo "💡 检测到 PDF 处理，建议："
#     echo "   /skill pdf - PDF 文件读取和处理"
#     echo ""
# fi

# Excel 处理
# if echo "$PROMPT" | grep -Eqi "excel|xlsx|xls|电子表格|表格处理"; then
#     echo "💡 检测到 Excel 处理，建议："
#     echo "   /skill xlsx - Excel 文件读取和处理"
#     echo ""
# fi

# 包管理相关
# if echo "$PROMPT" | grep -Eqi "conan|c\+\+.*依赖|c\+\+.*包管理"; then
#     echo "💡 检测到 C++ 包管理，建议："
#     echo "   /skill conan - Conan C/C++ 包管理器"
#     echo ""
# fi

# 网络爬虫
# if echo "$PROMPT" | grep -Eqi "爬虫|抓取|scrape|spider|网页数据"; then
#     echo "💡 检测到网页抓取任务，建议："
#     echo "   使用 playwright 技能进行网页自动化"
#     echo ""
# fi

# API 开发
# if echo "$PROMPT" | grep -Eqi "api|接口|restful|graphql|swagger"; then
#     echo "💡 检测到 API 开发，建议："
#     echo "   - 使用 OpenAPI/Swagger 规范"
#     echo "   - 考虑使用 Postman 测试"
#     echo ""
# fi

# 前端开发
# if echo "$PROMPT" | grep -Eqi "react|vue|angular|前端|页面|组件"; then
#     echo "💡 检测到前端开发，建议："
#     echo "   - 使用 TypeScript 增强类型安全"
#     echo "   - 考虑启用代码格式化"
#     echo ""
# fi

# Docker/容器
# if echo "$PROMPT" | grep -Eqi "docker|容器|dockerfile|镜像"; then
#     echo "💡 检测到容器相关操作，建议："
#     echo "   - 检查 Dockerfile 最佳实践"
#     echo "   - 使用多阶段构建减小镜像大小"
#     echo ""
# fi

# 自定义技能推荐
# 根据你的项目需求添加更多关键词检测和技能推荐

exit 0
