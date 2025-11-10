#!/bin/bash
# ============================================================================
# ClaudeKit - Skill Trigger 诊断测试工具
# ============================================================================
# 用途: 测试技能触发器是否正常工作
# 使用: ./test-skill-triggers.sh ["test prompt"]
# ============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 加载环境检测
source "$(dirname "${BASH_SOURCE[0]}")/hook-env.sh"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}🔍 ClaudeKit Skill Trigger 诊断工具${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# 1. 检查环境变量
echo -e "${YELLOW}1. 环境检查${NC}"
echo "   CLAUDE_PROJECT_DIR: ${CLAUDE_PROJECT_DIR}"
echo "   CLAUDE_DIR: ${CLAUDE_DIR}"
echo "   HOOKS_DIR: ${HOOKS_DIR}"
echo

# 2. 检查文件是否存在
echo -e "${YELLOW}2. 文件检查${NC}"
RULES_PATH="$CLAUDE_DIR/skills/skill-rules.json"
TS_SCRIPT="$HOOKS_DIR/skill-activation-prompt.ts"

if [ -f "$RULES_PATH" ]; then
    echo -e "   ✅ skill-rules.json: ${GREEN}存在${NC}"
else
    echo -e "   ❌ skill-rules.json: ${RED}不存在${NC} ($RULES_PATH)"
fi

if [ -f "$TS_SCRIPT" ]; then
    echo -e "   ✅ skill-activation-prompt.ts: ${GREEN}存在${NC}"
else
    echo -e "   ❌ skill-activation-prompt.ts: ${RED}不存在${NC} ($TS_SCRIPT)"
fi
echo

# 3. 检查 Node.js 和 tsx
echo -e "${YELLOW}3. 依赖检查${NC}"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "   ✅ Node.js: ${GREEN}$NODE_VERSION${NC}"
else
    echo -e "   ❌ Node.js: ${RED}未安装${NC}"
fi

if command -v npx &> /dev/null; then
    echo -e "   ✅ npx: ${GREEN}可用${NC}"

    # 检查 tsx
    if npx tsx --version &> /dev/null; then
        TSX_VERSION=$(npx tsx --version 2>&1 | head -1)
        echo -e "   ✅ tsx: ${GREEN}$TSX_VERSION${NC}"
    else
        echo -e "   ❌ tsx: ${RED}不可用${NC}"
    fi
else
    echo -e "   ❌ npx: ${RED}不可用${NC}"
fi
echo

# 4. 测试技能触发
echo -e "${YELLOW}4. 技能触发测试${NC}"

# 测试用的提示词
if [ -n "$1" ]; then
    TEST_PROMPT="$1"
else
    TEST_PROMPT="create user component"
fi

echo "   测试提示词: \"$TEST_PROMPT\""
echo

# 创建测试输入 JSON
TEST_INPUT=$(cat <<EOF
{
    "session_id": "test-session",
    "transcript_path": "/tmp/test-transcript",
    "cwd": "$CLAUDE_PROJECT_DIR",
    "permission_mode": "auto",
    "prompt": "$TEST_PROMPT"
}
EOF
)

# 运行测试
echo "   执行中..."
cd "$HOOKS_DIR"

if echo "$TEST_INPUT" | npx tsx skill-activation-prompt.ts; then
    echo -e "${GREEN}   ✅ Hook 执行成功${NC}"
else
    EXIT_CODE=$?
    echo -e "${RED}   ❌ Hook 执行失败 (退出码: $EXIT_CODE)${NC}"
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}📝 测试其他提示词:${NC}"
echo "   ./test-skill-triggers.sh \"create component\""
echo "   ./test-skill-triggers.sh \"创建组件\""
echo "   ./test-skill-triggers.sh \"build API\""
echo "   ./test-skill-triggers.sh \"开发接口\""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
