#!/bin/bash

# ============================================================================
# ClaudeKit - 远程安装脚本
# ============================================================================
# 使用方式:
#   bash <(curl -fsSL https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.sh)
#
# 选项:
#   --project, -p    安装到当前项目目录
#   --global, -g     全局安装到 ~/.claudekit
# ============================================================================

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
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# 符号定义
CHECKMARK="✓"
CROSS="✗"
ARROW="→"
INFO="ℹ"
WARNING="⚠"
ROCKET="🚀"
PACKAGE="📦"
GEAR="⚙"
SPARKLES="✨"
FOLDER="📁"
FILE="📄"
LOCK="🔒"

# ============================================================================
# 辅助函数
# ============================================================================

print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
}

print_success() {
    echo -e "  ${GREEN}${CHECKMARK}${NC} $1"
}

print_error() {
    echo -e "  ${RED}${CROSS}${NC} $1"
}

print_warning() {
    echo -e "  ${YELLOW}${WARNING}${NC} $1"
}

print_info() {
    echo -e "  ${CYAN}${INFO}${NC} $1"
}

print_step() {
    echo ""
    echo -e "${BOLD}${ARROW} $1${NC}"
}

print_substep() {
    echo -e "  ${DIM}${ARROW}${NC} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================================================
# Logo 展示
# ============================================================================

show_logo() {
    clear
    echo ""
    echo -e "${BOLD}${CYAN}"
    cat << "EOF"
   ┌─────────────────────────────────────────────────────────────┐
   │                                                             │
   │   ╔═══╗╔╗       ╔╗╔═══╗╔╗  ╔╗╔═══╗╔╗ ╔╗╔══╗╔════╗          │
   │   ║╔═╗║║║       ║║║╔═╗║║║  ║║║╔═╗║║║ ║║╚╣╠╝╚══╗ ║          │
   │   ║║ ╚╝║║╔══╗╔╗╔╝║║╚══╗║║ ╔╝║║║ ║║║╚═╝║ ║║    ║ ║          │
   │   ║║ ╔╗║║╚╣╠╝║║║╚╗╚══╗║║║ ╚╗║║║ ║║║╔═╗║ ║║    ║ ║          │
   │   ║╚═╝║║╚═╣╠╗║╚═╗║║╚═╝║║╚══╝║║╚═╝║║║ ║║╔╣╠╗   ║ ║          │
   │   ╚═══╝╚══╩═╝╚══╝╚═══╝╚════╝╚═══╝╚╝ ╚╝╚══╝   ╚═╝          │
   │                                                             │
   │              让 Claude Code 更智能的工具箱                   │
   │                                                             │
   └─────────────────────────────────────────────────────────────┘
EOF
    echo -e "${NC}"
    echo -e "${DIM}                     Version 1.0.0 | MIT License${NC}"
    echo -e "${DIM}           https://github.com/zengwenliang416/ClaudeKit${NC}"
    echo ""
}

# ============================================================================
# 进度条
# ============================================================================

show_progress() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))

    printf "\r  ${BOLD}进度:${NC} ["
    printf "${GREEN}%${completed}s${NC}" | tr ' ' '█'
    printf "${DIM}%${remaining}s${NC}" | tr ' ' '░'
    printf "] ${BOLD}%3d%%${NC}" $percentage
}

# ============================================================================
# 系统检查
# ============================================================================

check_requirements() {
    print_header "${GEAR} 系统环境检查"

    local checks=0
    local total=4

    # 检查 Node.js
    ((checks++))
    show_progress $checks $total
    sleep 0.1

    if ! command_exists node; then
        echo ""
        print_error "Node.js 未安装"
        echo ""
        echo -e "${YELLOW}请先安装 Node.js (>= 18.0.0):${NC}"
        echo -e "  ${CYAN}${ARROW}${NC} 官网: ${BOLD}https://nodejs.org/${NC}"
        echo -e "  ${CYAN}${ARROW}${NC} macOS: ${DIM}brew install node${NC}"
        echo -e "  ${CYAN}${ARROW}${NC} Ubuntu: ${DIM}curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -${NC}"
        echo ""
        exit 1
    fi

    NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_VERSION" -lt 18 ]; then
        echo ""
        print_error "Node.js 版本过低 (需要 >= 18.0.0, 当前: $(node -v))"
        exit 1
    fi

    # 检查 npm
    ((checks++))
    show_progress $checks $total
    sleep 0.1

    if ! command_exists npm; then
        echo ""
        print_error "npm 未安装"
        exit 1
    fi

    # 检查下载工具
    ((checks++))
    show_progress $checks $total
    sleep 0.1

    if command_exists curl; then
        DOWNLOAD_CMD="curl -fsSL"
    elif command_exists wget; then
        DOWNLOAD_CMD="wget -qO-"
    else
        echo ""
        print_error "需要 curl 或 wget 来下载文件"
        exit 1
    fi

    # 完成检查
    ((checks++))
    show_progress $checks $total
    echo ""

    # 显示检查结果
    echo ""
    print_success "Node.js ${DIM}$(node -v)${NC}"
    print_success "npm ${DIM}$(npm -v)${NC}"
    print_success "下载工具 ${DIM}$(command_exists curl && echo "curl" || echo "wget")${NC}"
    print_success "系统环境检查通过"
}

# ============================================================================
# 选择安装位置
# ============================================================================

select_install_location() {
    print_header "${FOLDER} 选择安装位置"

    # 检查命令行参数
    if [ "$1" = "--project" ] || [ "$1" = "-p" ]; then
        INSTALL_MODE="project"
        INSTALL_DIR="$(pwd)"
        print_info "模式: ${BOLD}项目级安装${NC}"
    elif [ "$1" = "--global" ] || [ "$1" = "-g" ]; then
        INSTALL_MODE="global"
        INSTALL_DIR="$HOME/.claudekit"
        print_info "模式: ${BOLD}全局安装${NC}"
    else
        # 交互式选择
        echo ""
        echo -e "  ${BOLD}请选择安装位置:${NC}"
        echo ""
        echo -e "    ${CYAN}1)${NC} ${BOLD}当前项目目录${NC}"
        echo -e "       ${DIM}推荐用于单个项目，配置独立${NC}"
        echo -e "       ${DIM}路径: $(pwd)${NC}"
        echo ""
        echo -e "    ${CYAN}2)${NC} ${BOLD}全局安装${NC}"
        echo -e "       ${DIM}所有项目共享，便于统一管理${NC}"
        echo -e "       ${DIM}路径: ~/.claudekit${NC}"
        echo ""
        echo -n -e "  ${BOLD}请输入选择 (1/2):${NC} "
        read -r choice

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
                echo ""
                print_error "无效的选择"
                exit 1
                ;;
        esac
    fi

    echo ""
    print_success "安装目录: ${DIM}$INSTALL_DIR${NC}"

    # 创建安装目录
    if [ ! -d "$INSTALL_DIR" ]; then
        mkdir -p "$INSTALL_DIR"
    fi
}

# ============================================================================
# 下载文件
# ============================================================================

download_infrastructure() {
    print_header "${PACKAGE} 下载 ClaudeKit"

    # 创建临时目录
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    print_substep "下载源: ${DIM}GitHub Release${NC}"
    print_substep "目标: ${DIM}$GITHUB_ARCHIVE_URL${NC}"

    echo ""
    echo -n "  "

    # 下载压缩包
    if [ "$DOWNLOAD_CMD" = "curl -fsSL" ]; then
        if curl -fsSL --progress-bar "$GITHUB_ARCHIVE_URL" -o "$TEMP_DIR/infrastructure.tar.gz"; then
            echo ""
            print_success "下载完成"
        else
            echo ""
            print_error "下载失败"
            exit 1
        fi
    else
        if wget -q --show-progress "$GITHUB_ARCHIVE_URL" -O "$TEMP_DIR/infrastructure.tar.gz" 2>&1; then
            echo ""
            print_success "下载完成"
        else
            echo ""
            print_error "下载失败"
            exit 1
        fi
    fi

    # 解压
    print_substep "解压文件..."
    cd "$TEMP_DIR"
    tar -xzf infrastructure.tar.gz

    # 找到解压后的目录
    EXTRACT_DIR=$(find . -maxdepth 1 -type d -name "*$GITHUB_REPO*" | head -1)

    if [ -z "$EXTRACT_DIR" ]; then
        print_error "解压失败"
        exit 1
    fi

    print_success "解压完成"

    # 复制文件
    echo ""
    print_step "${SPARKLES} 安装文件"

    # 增量安装逻辑
    if [ -d "$INSTALL_DIR/.claude" ]; then
        print_info "检测到现有配置，使用${BOLD}增量模式${NC}"
        echo ""

        print_substep "分析现有文件..."
        sleep 0.2

        print_substep "保留用户自定义内容..."
        sleep 0.2

        # 创建文件清单
        CLAUDEKIT_MANIFEST="$INSTALL_DIR/.claude/.claudekit-files"

        if command -v rsync >/dev/null 2>&1; then
            print_substep "使用 rsync 智能合并..."
            rsync -ru --quiet "$EXTRACT_DIR/.claude/" "$INSTALL_DIR/.claude/"
        else
            print_substep "复制新增文件..."
            cp -rn "$EXTRACT_DIR/.claude/"* "$INSTALL_DIR/.claude/" 2>/dev/null || true
        fi

        # 记录 ClaudeKit 文件清单
        find "$EXTRACT_DIR/.claude" -type f \( -name "*.md" -o -name "*.json" -o -name "*.sh" -o -name "*.ts" \) | \
            sed "s|$EXTRACT_DIR/.claude/||" > "$CLAUDEKIT_MANIFEST" 2>/dev/null || true

        echo ""
        print_success "增量安装完成"
        print_info "你的自定义文件已完全保留"
    else
        print_info "执行全新安装"
        echo ""

        mkdir -p "$INSTALL_DIR/.claude"
        cp -r "$EXTRACT_DIR/.claude/"* "$INSTALL_DIR/.claude/"

        # 创建文件清单
        CLAUDEKIT_MANIFEST="$INSTALL_DIR/.claude/.claudekit-files"
        find "$INSTALL_DIR/.claude" -type f \( -name "*.md" -o -name "*.json" -o -name "*.sh" -o -name "*.ts" \) | \
            sed "s|$INSTALL_DIR/.claude/||" > "$CLAUDEKIT_MANIFEST" 2>/dev/null || true

        print_success "文件复制完成"
    fi

    # 复制文档文件
    if [ "$INSTALL_MODE" = "global" ]; then
        cp -f "$EXTRACT_DIR"/*.md "$INSTALL_DIR/" 2>/dev/null || true
    fi

    cd - > /dev/null
}

# ============================================================================
# 安装依赖
# ============================================================================

install_dependencies() {
    print_header "${PACKAGE} 安装依赖"

    cd "$INSTALL_DIR/.claude/hooks"

    if [ ! -f package.json ]; then
        print_error "package.json 不存在"
        exit 1
    fi

    echo ""
    print_substep "运行 npm install..."
    echo ""

    # 显示 npm 输出，但抑制警告
    if npm install --silent --no-audit 2>&1 | grep -v "npm WARN" | sed 's/^/    /'; then
        echo ""
        print_success "依赖安装完成"
    else
        echo ""
        print_warning "依赖安装可能有警告，但可以继续"
    fi
}

# ============================================================================
# 设置权限
# ============================================================================

set_permissions() {
    print_header "${LOCK} 配置权限"

    # 设置所有 .sh 文件的执行权限
    chmod +x "$INSTALL_DIR"/.claude/hooks/*.sh 2>/dev/null || true

    local count=$(find "$INSTALL_DIR/.claude/hooks" -name "*.sh" 2>/dev/null | wc -l)
    print_success "设置了 ${BOLD}$count${NC} 个脚本的执行权限"
}

# ============================================================================
# 创建必要目录
# ============================================================================

create_directories() {
    print_header "${FOLDER} 创建目录结构"

    # 创建 dev 目录
    if [ ! -d "$INSTALL_DIR/dev" ] && [ "$INSTALL_MODE" = "project" ]; then
        mkdir -p "$INSTALL_DIR/dev"
        print_success "创建 ${DIM}dev/${NC} 目录"
    fi

    # 创建 cache 目录
    if [ ! -d "$INSTALL_DIR/.claude/cache" ]; then
        mkdir -p "$INSTALL_DIR/.claude/cache"
        print_success "创建 ${DIM}.claude/cache/${NC} 目录"
    fi
}

# ============================================================================
# 生成配置
# ============================================================================

generate_config() {
    print_header "${FILE} 生成配置文件"

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

    print_success "配置文件: ${DIM}$CONFIG_DIR/claude-settings.json${NC}"

    # 如果是全局安装，创建初始化脚本
    if [ "$INSTALL_MODE" = "global" ]; then
        cat > "$INSTALL_DIR/init-project.sh" << 'EOF'
#!/bin/bash
# ============================================================================
# ClaudeKit - 项目初始化脚本 (增量模式)
# ============================================================================

GLOBAL_DIR="$HOME/.claudekit"
PROJECT_DIR="$(pwd)"

echo ""
echo "🚀 正在为当前项目初始化 ClaudeKit..."
echo ""

# 增量安装:只添加/更新 ClaudeKit 文件,完全不影响现有文件
if [ -d "$PROJECT_DIR/.claude" ]; then
    echo "🔍 检测到现有 .claude 目录，进行增量更新..."

    # 删除旧的符号链接（如果存在）
    if [ -L "$PROJECT_DIR/.claude/.claude" ]; then
        rm "$PROJECT_DIR/.claude/.claude"
        echo "   ✓ 清理旧的错误符号链接"
    fi

    echo "   📦 增量复制 ClaudeKit 文件..."

    if command -v rsync >/dev/null 2>&1; then
        rsync -ru --info=name1 "$GLOBAL_DIR/.claude/" "$PROJECT_DIR/.claude/" 2>/dev/null
        echo "   ✓ 使用 rsync 增量更新"
    else
        cp -rn "$GLOBAL_DIR/.claude/"* "$PROJECT_DIR/.claude/" 2>/dev/null || true
        echo "   ✓ 使用 cp 增量更新"
    fi

    echo ""
    echo "✅ 增量更新完成!"
    echo ""
    echo "📊 更新说明:"
    echo "  • 新增的 ClaudeKit 文件已添加"
    echo "  • 你的自定义文件完全保留,未被修改"
    echo "  • 你修改过的 ClaudeKit 文件也保留了你的版本"
else
    # 全新安装
    echo "📦 全新安装 ClaudeKit..."
    mkdir -p "$PROJECT_DIR/.claude"
    cp -r "$GLOBAL_DIR/.claude/"* "$PROJECT_DIR/.claude/" 2>/dev/null || true
    echo "   ✓ 复制完成"
    echo ""
    echo "✅ 初始化完成!"
fi

# 创建 dev 目录
mkdir -p "$PROJECT_DIR/dev"

echo ""
echo "📝 下一步:"
echo "  1. 在 Claude Code 中打开此项目"
echo "  2. Skills 会自动激活"
echo "  3. 尝试说 '创建组件' 或 '项目技术栈' 来测试"
echo ""
echo "💡 说明:"
echo "  • 增量模式: 只添加新文件,不覆盖已存在文件"
echo "  • 你可以安全地修改任何 ClaudeKit 文件"
echo "  • 再次运行此脚本可获取最新的 ClaudeKit 文件"
echo ""
EOF
        chmod +x "$INSTALL_DIR/init-project.sh"
        print_success "初始化脚本: ${DIM}$INSTALL_DIR/init-project.sh${NC}"
    fi
}

# ============================================================================
# 验证安装
# ============================================================================

verify_installation() {
    print_header "${GEAR} 验证安装"

    cd "$INSTALL_DIR/.claude/hooks"

    # TypeScript 检查
    if npm run check > /dev/null 2>&1; then
        print_success "TypeScript 配置正确"
    else
        print_warning "TypeScript 检查有警告"
    fi

    # Hook 系统测试
    if echo '{"prompt":"test"}' | npx tsx skill-activation-prompt.ts > /dev/null 2>&1; then
        print_success "Hook 系统正常"
    else
        print_warning "Hook 系统测试未通过"
    fi
}

# ============================================================================
# 显示完成信息
# ============================================================================

show_completion() {
    echo ""
    echo ""
    echo -e "${GREEN}${BOLD}"
    cat << "EOF"
   ┌─────────────────────────────────────────────────────────────┐
   │                                                             │
   │                     🎉  安装成功！                          │
   │                                                             │
   └─────────────────────────────────────────────────────────────┘
EOF
    echo -e "${NC}"

    if [ "$INSTALL_MODE" = "project" ]; then
        echo -e "${BOLD}📦 项目级安装完成${NC}"
        echo -e "${DIM}   安装位置: $INSTALL_DIR${NC}"
        echo ""
        echo -e "${BOLD}🚀 下一步操作:${NC}"
        echo ""
        echo -e "  ${CYAN}1.${NC} 合并配置文件"
        echo -e "     ${DIM}将 claude-settings.json 的内容合并到 Claude Code 设置${NC}"
        echo ""
        echo -e "  ${CYAN}2.${NC} 设置环境变量"
        echo -e "     ${DIM}export CLAUDE_PROJECT_DIR=\"$INSTALL_DIR\"${NC}"
        echo ""
        echo -e "  ${CYAN}3.${NC} 重启 Claude Code"
        echo ""
    else
        echo -e "${BOLD}🌍 全局安装完成${NC}"
        echo -e "${DIM}   安装位置: $INSTALL_DIR${NC}"
        echo ""
        echo -e "${BOLD}🚀 在项目中使用:${NC}"
        echo ""
        echo -e "  ${CYAN}1.${NC} 进入你的项目目录"
        echo ""
        echo -e "  ${CYAN}2.${NC} 运行初始化脚本"
        echo -e "     ${DIM}$INSTALL_DIR/init-project.sh${NC}"
        echo ""
        echo -e "  ${CYAN}3.${NC} 合并配置到 Claude Code 设置"
        echo ""
        echo -e "  ${CYAN}4.${NC} 重启 Claude Code"
        echo ""
    fi

    echo -e "${BOLD}✨ 功能特性:${NC}"
    echo ""
    echo -e "  ${GREEN}${CHECKMARK}${NC} ${BOLD}中文支持${NC}      ${DIM}'创建组件'、'开发接口'${NC}"
    echo -e "  ${GREEN}${CHECKMARK}${NC} ${BOLD}技术栈检测${NC}    ${DIM}自动识别 Vue/React/Spring Boot${NC}"
    echo -e "  ${GREEN}${CHECKMARK}${NC} ${BOLD}Skills 激活${NC}   ${DIM}智能技能自动激活${NC}"
    echo -e "  ${GREEN}${CHECKMARK}${NC} ${BOLD}Agent 系统${NC}    ${DIM}专业代理协作${NC}"
    echo -e "  ${GREEN}${CHECKMARK}${NC} ${BOLD}Dev Docs${NC}      ${DIM}持久化项目上下文${NC}"
    echo ""
    echo -e "${BOLD}📚 文档资源:${NC}"
    echo ""
    echo -e "  ${CYAN}${ARROW}${NC} 使用指南: ${DIM}$INSTALL_DIR/.claude/hooks/README.md${NC}"
    echo -e "  ${CYAN}${ARROW}${NC} GitHub: ${DIM}https://github.com/$GITHUB_USER/$GITHUB_REPO${NC}"
    echo ""
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    echo ""
    echo -e "         ${GREEN}感谢使用 ClaudeKit! ${SPARKLES}${NC}"
    echo ""
}

# ============================================================================
# 主函数
# ============================================================================

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
