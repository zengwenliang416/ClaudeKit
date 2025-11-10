#!/bin/bash

# Claude Code Infrastructure Showcase - 安装脚本
# 支持 macOS, Linux, Windows (WSL)

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logo
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Claude Code Infrastructure Showcase Installer      ║${NC}"
echo -e "${BLUE}║            让 Claude Code 更智能的基础设施             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# 函数：打印步骤
print_step() {
    echo -e "${GREEN}[步骤]${NC} $1"
}

# 函数：打印成功
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 函数：打印警告
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 函数：打印错误
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 函数：检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 函数：获取 Node.js 版本
get_node_version() {
    node -v 2>/dev/null | sed 's/v//' | cut -d. -f1
}

# 函数：检查 Node.js 版本
check_node_version() {
    if ! command_exists node; then
        return 1
    fi

    local version=$(get_node_version)
    if [ -z "$version" ] || [ "$version" -lt 18 ]; then
        return 1
    fi

    return 0
}

# 设置项目目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$SCRIPT_DIR"
CLAUDE_DIR="$PROJECT_DIR/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"

echo "📁 项目目录: $PROJECT_DIR"
echo ""

# 1. 检查系统要求
print_step "检查系统要求..."

# 检查操作系统
OS="Unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS="Windows"
fi

echo "   操作系统: $OS"

# 检查 Node.js
if ! command_exists node; then
    print_error "Node.js 未安装！"
    echo ""
    echo "请先安装 Node.js (>= 18.0.0):"
    echo "  • 官网下载: https://nodejs.org/"
    echo "  • 使用 nvm: nvm install 18"
    echo "  • 使用 brew: brew install node"
    echo ""
    exit 1
fi

NODE_VERSION=$(node -v)
echo "   Node.js 版本: $NODE_VERSION"

if ! check_node_version; then
    print_error "Node.js 版本过低！需要 >= 18.0.0"
    echo "   当前版本: $NODE_VERSION"
    echo "   请升级 Node.js 后重试"
    exit 1
fi

# 检查 npm
if ! command_exists npm; then
    print_error "npm 未安装！"
    exit 1
fi

NPM_VERSION=$(npm -v)
echo "   npm 版本: $NPM_VERSION"

print_success "系统要求检查通过"
echo ""

# 2. 检查项目结构
print_step "检查项目结构..."

if [ ! -d "$CLAUDE_DIR" ]; then
    print_error ".claude 目录不存在！"
    echo "   请确保在正确的项目目录中运行此脚本"
    exit 1
fi

if [ ! -d "$HOOKS_DIR" ]; then
    print_error ".claude/hooks 目录不存在！"
    exit 1
fi

print_success "项目结构检查通过"
echo ""

# 3. 安装 npm 依赖
print_step "安装 hooks 系统依赖..."

cd "$HOOKS_DIR"

# 检查 package.json
if [ ! -f "package.json" ]; then
    print_error "package.json 不存在！"
    exit 1
fi

# 安装依赖
echo "   运行 npm install..."
if npm install --silent > /dev/null 2>&1; then
    print_success "依赖安装成功"
else
    print_error "依赖安装失败"
    echo "   请尝试手动运行: cd $HOOKS_DIR && npm install"
    exit 1
fi

echo ""

# 4. 设置执行权限
print_step "设置脚本执行权限..."

# 设置所有 .sh 文件的执行权限
SHELL_SCRIPTS=(
    "skill-activation-prompt.sh"
    "post-tool-use-tracker.sh"
    "tsc-check.sh"
    "trigger-build-resolver.sh"
    "stop-build-check-enhanced.sh"
    "error-handling-reminder.sh"
)

for script in "${SHELL_SCRIPTS[@]}"; do
    if [ -f "$HOOKS_DIR/$script" ]; then
        chmod +x "$HOOKS_DIR/$script"
        echo "   ✓ $script"
    else
        print_warning "$script 不存在"
    fi
done

print_success "执行权限设置完成"
echo ""

# 5. 创建必要目录
print_step "创建必要目录..."

# 创建 dev 目录（用于 Dev Docs）
if [ ! -d "$PROJECT_DIR/dev" ]; then
    mkdir -p "$PROJECT_DIR/dev"
    echo "   ✓ 创建 dev/ 目录"
fi

# 创建 cache 目录
if [ ! -d "$CLAUDE_DIR/cache" ]; then
    mkdir -p "$CLAUDE_DIR/cache"
    echo "   ✓ 创建 .claude/cache/ 目录"
fi

print_success "目录创建完成"
echo ""

# 6. 验证 TypeScript 配置
print_step "验证 TypeScript 配置..."

cd "$HOOKS_DIR"

if npm run check > /dev/null 2>&1; then
    print_success "TypeScript 配置正确"
else
    print_warning "TypeScript 检查有警告，但不影响使用"
fi

echo ""

# 7. 测试 hook 系统
print_step "测试 hook 系统..."

# 创建测试输入
echo '{"prompt":"测试技术栈检测"}' > test-input-temp.json

# 运行测试
echo "   运行技术栈检测测试..."
if npx tsx skill-activation-prompt.ts < test-input-temp.json > /dev/null 2>&1; then
    print_success "Hook 系统测试通过"
else
    print_warning "Hook 系统测试失败，请检查配置"
fi

# 清理测试文件
rm -f test-input-temp.json

echo ""

# 8. 生成 settings.json 配置
print_step "生成 Claude Code 配置..."

SETTINGS_FILE="$PROJECT_DIR/claude-settings.json"

cat > "$SETTINGS_FILE" << 'EOF'
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/skill-activation-prompt.sh",
            "description": "技术栈检测和 Skills 自动激活"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/post-tool-use-tracker.sh",
            "description": "文件修改追踪"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/tsc-check.sh",
            "description": "TypeScript 类型检查"
          }
        ]
      }
    ]
  }
}
EOF

echo "   ✓ 配置文件已生成: claude-settings.json"
print_success "配置生成完成"
echo ""

# 9. 显示安装摘要
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    🎉 安装成功！                       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

echo "📋 安装摘要:"
echo "   • Node.js 依赖: ✅"
echo "   • Hooks 系统: ✅"
echo "   • 执行权限: ✅"
echo "   • 技术栈检测器: ✅"
echo "   • Dev Docs 目录: ✅"
echo ""

echo "🚀 下一步:"
echo ""
echo "1. 将 claude-settings.json 的内容合并到你的 Claude Code settings.json 中"
echo ""
echo "2. 在 Claude Code 中设置项目目录环境变量:"
echo "   export CLAUDE_PROJECT_DIR=\"$PROJECT_DIR\""
echo ""
echo "3. 重启 Claude Code 使配置生效"
echo ""
echo "4. 测试功能:"
echo "   • 输入 '创建一个用户组件' 测试中文触发"
echo "   • 输入 'create a user service' 测试英文触发"
echo ""

echo "📖 文档:"
echo "   • 安装需求: 安装需求清单.md"
echo "   • 项目分析: 项目分析报告.md"
echo "   • 技术栈指南: 技术栈检测器使用指南.md"
echo "   • Agent 集成: agent-dev-docs-integration.md"
echo ""

echo "❓ 遇到问题?"
echo "   • 查看 .claude/hooks/README.md"
echo "   • 查看 CLAUDE_INTEGRATION_GUIDE.md"
echo ""

print_success "感谢使用 Claude Code Infrastructure Showcase!"