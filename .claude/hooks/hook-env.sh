#!/bin/bash
# ============================================================================
# ClaudeKit - Hook 环境检测脚本 (支持全局和项目安装)
# ============================================================================
# 这个脚本自动检测项目目录，无需手动设置 CLAUDE_PROJECT_DIR
#
# 使用方式：在每个 hook 脚本开头添加：
#   source "$(dirname "${BASH_SOURCE[0]}")/hook-env.sh"
# ============================================================================

# 优先级 1: 使用 Claude Code 注入的环境变量（运行时由 Claude Code 提供）
if [ -n "$CLAUDE_PROJECT_DIR" ]; then
    export CLAUDE_PROJECT_DIR
# 优先级 2: 对于项目本地 hooks，使用相对路径检测
# 检查 hook 脚本是否在项目的 .claude/hooks/ 下（而非全局 ~/.claude/hooks/）
elif [ -f "$(dirname "${BASH_SOURCE[0]}")/package.json" ]; then
    # 通过检查 package.json 确认这是 hooks 目录
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # 确保不是全局安装（~/.claude/hooks/）
    if [[ "$SCRIPT_DIR" != "$HOME/.claude/hooks" ]] && [[ "$SCRIPT_DIR" == *"/.claude/hooks" ]]; then
        export CLAUDE_PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
    fi
fi

# 优先级 3: 对于全局 hooks 或未能通过优先级2检测的情况，从当前工作目录向上查找 .claude 目录
if [ -z "$CLAUDE_PROJECT_DIR" ]; then
    current_dir="$PWD"
    found=false

    # 向上遍历目录树，最多查找 10 层
    for i in {1..10}; do
        if [ -d "$current_dir/.claude" ]; then
            export CLAUDE_PROJECT_DIR="$current_dir"
            found=true
            break
        fi

        # 到达根目录，停止查找
        if [ "$current_dir" = "/" ]; then
            break
        fi

        current_dir="$(dirname "$current_dir")"
    done

    # 如果还是没找到，使用 PWD 作为备选（Claude Code 通常在项目根目录运行）
    if [ "$found" = false ]; then
        export CLAUDE_PROJECT_DIR="$PWD"
    fi
fi

# 导出其他常用路径
export CLAUDE_DIR="$CLAUDE_PROJECT_DIR/.claude"
export HOOKS_DIR="$CLAUDE_DIR/hooks"
export CACHE_DIR="$CLAUDE_DIR/tsc-cache"

# 调试信息（可选，取消注释以启用）
# echo "[hook-env] Detection mode: ${CLAUDE_PROJECT_DIR:+env-var}${SCRIPT_DIR:+relative}${PWD:+pwd-search}" >&2
# echo "[hook-env] CLAUDE_PROJECT_DIR=$CLAUDE_PROJECT_DIR" >&2
# echo "[hook-env] PWD=$PWD" >&2
