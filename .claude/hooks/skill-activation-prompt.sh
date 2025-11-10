#!/bin/bash

# 加载环境检测
source "$(dirname "${BASH_SOURCE[0]}")/hook-env.sh"

# Export environment for TypeScript script
export CLAUDE_PROJECT_DIR

# Change to hooks directory
cd "$HOOKS_DIR" || {
    echo "❌ Failed to change to hooks directory: $HOOKS_DIR" >&2
    exit 0  # Don't block Claude on error
}

# Run TypeScript hook with error handling
if ! cat | npx tsx skill-activation-prompt.ts 2>&1; then
    echo "⚠️ skill-activation-prompt hook encountered an error (non-blocking)" >&2
fi

exit 0
