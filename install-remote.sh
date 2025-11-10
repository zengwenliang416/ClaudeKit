#!/bin/bash

# ClaudeKit - 远程安装脚本
# 使用方式: curl -fsSL https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.sh | bash
# 或指定安装位置: curl -fsSL ... | bash -s -- --project

set -e

# GitHub 仓库配置
GITHUB_USER="zengwenliang416"
GITHUB_REPO="ClaudeKit"
GITHUB_BRANCH="main"
GITHUB_RAW_URL="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$GITHUB_BRANCH"
GITHUB_ARCHIVE_URL="https://github.com/$GITHUB_USER/$GITHUB_REPO/archive/refs/heads/$GITHUB_BRANCH.tar.gz"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 函数定义
print_step() {
    echo -e "${GREEN}[步骤]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Logo
show_logo() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║              ClaudeKit Remote Installer                ║${NC}"
    echo -e "${BLUE}║         让 Claude Code 更智能的工具箱                    ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 检查系统要求
check_requirements() {
    print_step "检查系统要求..."

    # 检查 Node.js
    if ! command_exists node; then
        print_error "Node.js 未安装！"
        echo ""
        echo "请先安装 Node.js (>= 18.0.0):"
        echo "  • 官网: https://nodejs.org/"
        echo "  • macOS: brew install node"
        echo "  • Ubuntu: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -"
        echo ""
        exit 1
    fi

    NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_VERSION" -lt 18 ]; then
        print_error "Node.js 版本过低！需要 >= 18.0.0"
        echo "   当前版本: $(node -v)"
        exit 1
    fi
    echo "   Node.js: $(node -v) ✓"

    # 检查 npm
    if ! command_exists npm; then
        print_error "npm 未安装！"
        exit 1
    fi
    echo "   npm: $(npm -v) ✓"

    # 检查下载工具
    if command_exists curl; then
        DOWNLOAD_CMD="curl -fsSL"
        echo "   下载工具: curl ✓"
    elif command_exists wget; then
        DOWNLOAD_CMD="wget -qO-"
        echo "   下载工具: wget ✓"
    else
        print_error "需要 curl 或 wget 来下载文件！"
        exit 1
    fi

    print_success "系统要求检查通过"
    echo ""
}

# 选择安装位置
select_install_location() {
    print_step "选择安装位置..."

    # 检查命令行参数
    if [ "$1" = "--project" ] || [ "$1" = "-p" ]; then
        INSTALL_MODE="project"
        INSTALL_DIR="$(pwd)"
        print_info "安装模式: 当前项目目录"
    elif [ "$1" = "--global" ] || [ "$1" = "-g" ]; then
        INSTALL_MODE="global"
        # ClaudeKit 全局安装目录
        INSTALL_DIR="$HOME/.claudekit"
        print_info "安装模式: 全局安装"
    else
        # 交互式选择
        echo ""
        echo "请选择安装位置:"
        echo "  1) 当前项目目录 (推荐用于单个项目)"
        echo "  2) 全局安装 (所有项目共享)"
        echo ""
        read -p "请输入选择 (1/2): " choice

        case $choice in
            1)
                INSTALL_MODE="project"
                INSTALL_DIR="$(pwd)"
                ;;
            2)
                INSTALL_MODE="global"
                INSTALL_DIR="$HOME/.claudekit"
                ;;
            *)
                print_error "无效的选择！"
                exit 1
                ;;
        esac
    fi

    echo "   安装目录: $INSTALL_DIR"

    # 创建安装目录
    if [ ! -d "$INSTALL_DIR" ]; then
        mkdir -p "$INSTALL_DIR"
    fi

    print_success "安装位置确定"
    echo ""
}

# 下载文件
download_infrastructure() {
    print_step "下载 ClaudeKit..."

    # 创建临时目录
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    echo "   下载地址: $GITHUB_ARCHIVE_URL"

    # 下载压缩包
    if [ "$DOWNLOAD_CMD" = "curl -fsSL" ]; then
        curl -fsSL "$GITHUB_ARCHIVE_URL" -o infrastructure.tar.gz
    else
        wget -q "$GITHUB_ARCHIVE_URL" -O infrastructure.tar.gz
    fi

    if [ ! -f infrastructure.tar.gz ]; then
        print_error "下载失败！"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # 解压
    echo "   解压文件..."
    tar -xzf infrastructure.tar.gz

    # 找到解压后的目录
    EXTRACT_DIR=$(find . -maxdepth 1 -type d -name "*$GITHUB_REPO*" | head -1)

    if [ -z "$EXTRACT_DIR" ]; then
        print_error "解压失败！"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # 复制 .claude 目录到安装位置
    echo "   复制文件到安装目录..."

    # 备份现有的 .claude 目录（如果存在）
    if [ -d "$INSTALL_DIR/.claude" ]; then
        BACKUP_DIR="$INSTALL_DIR/.claude.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "发现现有 .claude 目录，备份到: $BACKUP_DIR"
        mv "$INSTALL_DIR/.claude" "$BACKUP_DIR"
    fi

    # 复制新文件
    cp -r "$EXTRACT_DIR/.claude" "$INSTALL_DIR/"

    # 复制文档文件（如果是全局安装）
    if [ "$INSTALL_MODE" = "global" ]; then
        cp -f "$EXTRACT_DIR"/*.md "$INSTALL_DIR/" 2>/dev/null || true
    fi

    # 清理临时文件
    cd - > /dev/null
    rm -rf "$TEMP_DIR"

    print_success "文件下载完成"
    echo ""
}

# 安装依赖
install_dependencies() {
    print_step "安装 npm 依赖..."

    cd "$INSTALL_DIR/.claude/hooks"

    if [ ! -f package.json ]; then
        print_error "package.json 不存在！"
        exit 1
    fi

    echo "   运行 npm install..."
    if npm install --silent > /dev/null 2>&1; then
        print_success "依赖安装成功"
    else
        print_warning "依赖安装可能有警告，尝试继续..."
    fi

    echo ""
}

# 设置权限
set_permissions() {
    print_step "设置文件权限..."

    # 设置所有 .sh 文件的执行权限
    chmod +x "$INSTALL_DIR"/.claude/hooks/*.sh 2>/dev/null || true

    # 列出设置权限的文件
    local count=$(find "$INSTALL_DIR/.claude/hooks" -name "*.sh" | wc -l)
    echo "   设置了 $count 个脚本的执行权限"

    print_success "权限设置完成"
    echo ""
}

# 创建必要目录
create_directories() {
    print_step "创建必要目录..."

    # 创建 dev 目录
    if [ ! -d "$INSTALL_DIR/dev" ] && [ "$INSTALL_MODE" = "project" ]; then
        mkdir -p "$INSTALL_DIR/dev"
        echo "   ✓ 创建 dev/ 目录"
    fi

    # 创建 cache 目录
    if [ ! -d "$INSTALL_DIR/.claude/cache" ]; then
        mkdir -p "$INSTALL_DIR/.claude/cache"
        echo "   ✓ 创建 .claude/cache/ 目录"
    fi

    print_success "目录创建完成"
    echo ""
}

# 生成配置
generate_config() {
    print_step "生成配置文件..."

    # 根据安装模式生成不同的配置
    if [ "$INSTALL_MODE" = "project" ]; then
        CONFIG_DIR="$INSTALL_DIR"
        HOOKS_PATH="\$CLAUDE_PROJECT_DIR/.claude/hooks"
    else
        CONFIG_DIR="$INSTALL_DIR"
        HOOKS_PATH="$INSTALL_DIR/.claude/hooks"
    fi

    cat > "$CONFIG_DIR/claude-settings.json" << EOF
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOOKS_PATH/skill-activation-prompt.sh",
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
            "command": "$HOOKS_PATH/post-tool-use-tracker.sh",
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
            "command": "$HOOKS_PATH/tsc-check.sh",
            "description": "TypeScript 类型检查"
          }
        ]
      }
    ]
  }
}
EOF

    echo "   配置文件: $CONFIG_DIR/claude-settings.json"

    # 如果是全局安装，创建初始化脚本
    if [ "$INSTALL_MODE" = "global" ]; then
        cat > "$INSTALL_DIR/init-project.sh" << 'EOF'
#!/bin/bash
# 在项目中初始化 ClaudeKit

GLOBAL_DIR="$HOME/.claudekit"
PROJECT_DIR="$(pwd)"

echo "正在为当前项目初始化 ClaudeKit..."

# 备份现有 .claude 目录（如果存在）
if [ -d "$PROJECT_DIR/.claude" ] && [ ! -L "$PROJECT_DIR/.claude" ]; then
    BACKUP_DIR="$PROJECT_DIR/.claude.backup.$(date +%Y%m%d_%H%M%S)"
    echo "⚠️  发现现有 .claude 目录，备份到: $BACKUP_DIR"
    mv "$PROJECT_DIR/.claude" "$BACKUP_DIR"
fi

# 删除旧的符号链接（如果存在）
if [ -L "$PROJECT_DIR/.claude" ]; then
    rm "$PROJECT_DIR/.claude"
fi

# 复制 ClaudeKit 文件到项目
echo "📦 复制 ClaudeKit 文件..."
cp -r "$GLOBAL_DIR/.claude" "$PROJECT_DIR/"

# 创建 dev 目录
mkdir -p "$PROJECT_DIR/dev"

echo "✅ 初始化完成！"
echo ""
echo "📝 下一步:"
echo "  1. 在 Claude Code 中打开此项目"
echo "  2. Skills 会自动激活"
echo "  3. 尝试说 '创建组件' 或 '项目技术栈' 来测试"
EOF
        chmod +x "$INSTALL_DIR/init-project.sh"
        echo "   初始化脚本: $INSTALL_DIR/init-project.sh"
    fi

    print_success "配置生成完成"
    echo ""
}

# 验证安装
verify_installation() {
    print_step "验证安装..."

    cd "$INSTALL_DIR/.claude/hooks"

    # TypeScript 检查
    if npm run check > /dev/null 2>&1; then
        echo "   ✓ TypeScript 配置正确"
    else
        print_warning "TypeScript 检查有警告"
    fi

    # Hook 系统测试
    echo '{"prompt":"test"}' | npx tsx skill-activation-prompt.ts > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "   ✓ Hook 系统正常"
    else
        print_warning "Hook 系统测试失败，请手动检查"
    fi

    print_success "安装验证完成"
    echo ""
}

# 显示完成信息
show_completion() {
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    🎉 安装成功！                       ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [ "$INSTALL_MODE" = "project" ]; then
        echo "📋 项目模式安装完成"
        echo "   安装位置: $INSTALL_DIR"
        echo ""
        echo "🚀 下一步:"
        echo "1. 将 claude-settings.json 的内容合并到 Claude Code 设置中"
        echo "2. 设置环境变量: export CLAUDE_PROJECT_DIR=\"$INSTALL_DIR\""
        echo "3. 重启 Claude Code"
    else
        echo "📋 全局模式安装完成"
        echo "   安装位置: $INSTALL_DIR"
        echo ""
        echo "🚀 在项目中使用:"
        echo "1. 进入你的项目目录"
        echo "2. 运行: $INSTALL_DIR/init-project.sh"
        echo "3. 将配置合并到 Claude Code 设置中"
        echo "4. 重启 Claude Code"
    fi

    echo ""
    echo "📖 功能特性:"
    echo "   • 中文支持：'创建组件'、'开发接口'"
    echo "   • 技术栈检测：自动识别 Vue/React/Spring Boot"
    echo "   • Skills 自动激活"
    echo "   • Agent 智能系统"
    echo "   • Dev Docs 持久化"
    echo ""
    echo "❓ 需要帮助？"
    echo "   • 查看文档: $INSTALL_DIR/.claude/hooks/README.md"
    echo "   • GitHub: https://github.com/$GITHUB_USER/$GITHUB_REPO"
    echo ""
    print_success "感谢使用 ClaudeKit！"
}

# 主函数
main() {
    show_logo
    check_requirements
    select_install_location "$@"
    download_infrastructure
    install_dependencies
    set_permissions
    create_directories
    generate_config
    verify_installation
    show_completion
}

# 运行主函数
main "$@"