#!/bin/bash
set -e

# 加载环境检测
source "$(dirname "${BASH_SOURCE[0]}")/hook-env.sh"

cd "$HOOKS_DIR"
cat | npx tsx skill-activation-prompt.ts
