# Dev Sentinel

<div align="center">

🛡️ **开发哨兵** - 守护你的 Claude Code 开发流程

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/jerryokk/dev-sentinel/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Plugin-purple.svg)](https://docs.claude.com/en/docs/claude-code/plugins)

[功能特性](#-功能特性) • [快速开始](#-快速开始) • [配置](#-配置) • [文档](#-文档)

</div>

---

## 📖 简介

**Dev Sentinel** 是一个强大的 Claude Code 插件，自动追踪文件操作、执行构建检查、并提供智能通知。让你专注于代码，由哨兵守护质量。

### 核心功能

- 🔍 **文件操作追踪** - 自动记录所有文件的创建和修改
- 🏗️ **构建检查** - CMake 自动编译，确保代码可构建
- 🔔 **智能通知** - 支持飞书、Slack、桌面通知
- 📊 **操作统计** - 任务完成时自动汇总文件操作
- 🎨 **代码格式化** - 自动格式化修改的文件（可选）
- 📂 **Git 集成** - 自动暂存、显示 Git 状态（可选）

---

## 🚀 快速开始

### 安装

#### 方式 1：一键安装到项目（推荐）

```bash
# 克隆仓库
git clone https://github.com/jerryokk/dev-sentinel.git /tmp/dev-sentinel

# 进入你的项目目录
cd /path/to/your/project

# 运行安装脚本
bash /tmp/dev-sentinel/install.sh
```

或者在项目目录直接运行：

```bash
curl -fsSL https://raw.githubusercontent.com/jerryokk/dev-sentinel/main/install.sh | bash -s .
```

**特点：**
- ✅ 安装到项目的 `.claude/` 目录，不影响全局
- ✅ 配置可提交到 Git，团队共享
- ✅ 每个项目独立配置

#### 方式 2：通过 Marketplace（全局安装）

```bash
# 添加插件市场
/plugin marketplace add https://github.com/jerryokk/dev-sentinel.git

# 安装插件
/plugin install dev-sentinel

# 给脚本添加执行权限
chmod +x ~/.claude/plugins/marketplaces/dev-sentinel-marketplace/plugins/dev-sentinel/scripts/*.sh
```

#### 方式 3：手动安装（全局）

```bash
# 克隆仓库到插件目录
git clone https://github.com/jerryokk/dev-sentinel.git ~/.claude/plugins/dev-sentinel

# 添加执行权限
chmod +x ~/.claude/plugins/dev-sentinel/plugins/dev-sentinel/scripts/*.sh
```

安装完成后，重启 Claude Code 或开始新会话即可生效。

### 验证安装

```bash
# 在 Claude Code 中查看插件列表
/plugin list

# 应该看到 dev-sentinel
```

### 卸载插件

```bash
# 卸载插件
/plugin uninstall dev-sentinel

# 删除 Marketplace（可选）
/plugin marketplace remove https://github.com/jerryokk/dev-sentinel.git

# 或手动删除
rm -rf ~/.claude/plugins/dev-sentinel
```

---

## ✨ 功能特性

### 1. 文件操作追踪

自动记录所有文件创建和修改操作，生成操作日志。

**特点：**
- ✅ 自动区分"创建"和"修改"操作
- ✅ 只追踪文件操作（Edit/Write/MultiEdit/NotebookEdit）
- ✅ 忽略其他工具调用（Bash/Read/Grep 等）
- ✅ 日志格式：`[时间戳] 操作 | 文件路径`

**日志示例：**
```
[2025-11-05 16:30:15] 创建 | /path/to/main.cpp
[2025-11-05 16:31:22] 修改 | /path/to/config.h
[2025-11-05 16:32:08] 创建 | /path/to/utils.cpp
```

### 2. CMake 构建检查

任务完成时自动运行 CMake 编译，确保代码可构建。

**特点：**
- ✅ 自动检测 CMakeLists.txt
- ✅ 构建失败可阻止任务完成
- ✅ 显示编译错误信息

**启用方法：**
编辑 `scripts/stop.sh:23`，取消注释

### 3. 智能通知

支持多种通知渠道，任务完成时自动发送。

**支持的通知方式：**
- 📱 **飞书 Webhook** - 企业团队推荐
- 💬 **Slack Webhook** - 国际团队推荐
- 🖥️ **桌面通知** - 个人开发推荐
  - ✅ **WSL** - 自动调用 Windows Toast 通知
  - ✅ **Linux** - notify-send
  - ✅ **macOS** - 系统通知

**通知内容：**
- 会话 ID
- 完成时间
- 文件操作统计（创建/修改数量）
- 操作的文件列表（前 10 个）

**启用方法：**
编辑 `scripts/stop.sh:70`，填入 Webhook URL

### 4. 操作统计

任务完成时自动统计文件操作，清晰展示工作成果。

**统计信息：**
```
📊 文件操作统计：
   创建: 3 个
   修改: 5 个
   总计: 8 个

📝 操作的文件（最近 20 个）：
创建 | main.cpp
修改 | config.h
创建 | utils.cpp
...
```

### 5. 代码格式化（可选）

文件修改后自动格式化，保持代码风格一致。

**支持的语言：**
- TypeScript/JavaScript → Prettier
- Python → Black
- C/C++ → clang-format

**启用方法：**
编辑 `scripts/post-tool-use.sh:47`，取消注释

### 6. Git 集成（可选）

**功能：**
- 显示当前分支和未提交文件数
- 自动暂存修改的文件
- 显示环境信息（Node/Python/g++）

**启用方法：**
编辑 `scripts/user-prompt-submit.sh:17`，取消注释

---

## ⚙️ 配置

### 基础配置（开箱即用）

插件默认启用文件追踪和操作统计，无需配置。

### 高级配置

根据需要启用以下功能：

#### 1. 启用 Git 信息

编辑 `scripts/user-prompt-submit.sh`，取消注释第 17-23 行：

```bash
if [ -d "$PROJECT_DIR/.git" ]; then
    cd "$PROJECT_DIR"
    echo "📂 Git 信息："
    echo "   分支: $(git branch --show-current 2>/dev/null)"
    echo "   未提交: $(git status -s 2>/dev/null | wc -l) 个文件"
    echo ""
fi
```

#### 2. 启用 CMake 编译检查

编辑 `scripts/stop.sh`，取消注释第 23-37 行：

```bash
if [ -f "$PROJECT_DIR/CMakeLists.txt" ]; then
    echo "📦 CMake 编译检查..."
    cd "$PROJECT_DIR"
    mkdir -p build && cd build
    cmake .. && make
    # ...
fi
```

#### 3. 启用飞书通知

编辑 `scripts/stop.sh`，填入 Webhook 并取消注释第 70-93 行：

```bash
WEBHOOK="https://open.feishu.cn/open-apis/bot/v2/hook/YOUR_WEBHOOK"

MESSAGE="✅ Claude 任务完成\n\n..."

curl -s -X POST "$WEBHOOK" -H "Content-Type: application/json" \
  -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"$MESSAGE\"}}"
```

#### 4. 启用自动格式化

编辑 `scripts/post-tool-use.sh`，取消注释第 47-58 行：

```bash
case "${FILE_PATH##*.}" in
    ts|tsx|js|jsx)
        prettier --write "$FILE_PATH" 2>&1
        ;;
    py)
        black "$FILE_PATH" 2>&1
        ;;
    cpp|hpp|c|h)
        clang-format -i "$FILE_PATH" 2>&1
        ;;
esac
```

---

## 🔧 故障排查

### 钩子未执行

```bash
# 检查脚本权限
ls -l ~/.claude/plugins/dev-sentinel/scripts/

# 添加执行权限
chmod +x ~/.claude/plugins/dev-sentinel/scripts/*.sh
```

### WSL 桌面通知不显示

**重要**: `notify.ps1` 文件必须保存为 **UTF-8 with BOM** 格式！

在 VS Code 中：
1. 打开 `scripts/notify.ps1`
2. 点击右下角的编码
3. 选择 "Save with Encoding" → "UTF-8 with BOM"

测试通知：
```bash
cd ~/.claude/plugins/dev-sentinel/scripts
bash notify.sh "测试" "通知测试"
```

### jq 未安装

```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq

# CentOS/RHEL
sudo yum install jq
```

### 通知未发送

1. 检查 Webhook URL 是否正确
2. 确保网络连接正常
3. 验证是否取消注释了通知代码

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 开发

```bash
# 克隆仓库
git clone https://github.com/jerryokk/dev-sentinel.git

# 创建分支
git checkout -b feature/your-feature

# 提交更改
git commit -am "Add your feature"

# 推送分支
git push origin feature/your-feature
```

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE)

---

## 🙏 致谢

感谢 Claude Code 团队提供强大的插件系统。

---

## 📞 联系方式

- **Issues**: [GitHub Issues](https://github.com/jerryokk/dev-sentinel/issues)
- **作者**: Jerry

---

<div align="center">

**如果这个插件对你有帮助，请给个 ⭐️ Star！**

Made with ❤️ for Claude Code

</div>
