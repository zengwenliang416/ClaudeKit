#!/bin/bash
# ============================================================================
# ClaudeKit - Hook 环境检测脚本
# ============================================================================
# 这个脚本自动检测项目目录，无需手动设置 CLAUDE_PROJECT_DIR
#
# 使用方式：在每个 hook 脚本开头添加：
#   source "$(dirname "${BASH_SOURCE[0]}")/hook-env.sh"
# ============================================================================

# 如果 CLAUDE_PROJECT_DIR 已经设置，直接使用
if [ -n "$CLAUDE_PROJECT_DIR" ]; then
    export CLAUDE_PROJECT_DIR
else
    # 自动检测：从 hook 脚本位置向上查找项目根目录
    # hooks 脚本在 .claude/hooks/ 下，所以项目根目录是 ../../
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    export CLAUDE_PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

# 导出其他常用路径
export CLAUDE_DIR="$CLAUDE_PROJECT_DIR/.claude"
export HOOKS_DIR="$CLAUDE_DIR/hooks"
export CACHE_DIR="$CLAUDE_DIR/tsc-cache"

# 调试信息（可选）
# echo "[hook-env] CLAUDE_PROJECT_DIR=$CLAUDE_PROJECT_DIR" >&2
