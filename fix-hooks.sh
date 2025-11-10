#!/bin/bash
# 修复 hooks 系统的脚本

echo "🔧 修复 Claude Code Hooks 系统..."

# 1. 进入 hooks 目录
cd .claude/hooks

# 2. 检查 npm 是否存在
if ! command -v npm &> /dev/null; then
    echo "❌ npm 未安装，请先安装 Node.js"
    exit 1
fi

# 3. 安装依赖
echo "📦 安装 hooks 依赖..."
npm install

# 4. 设置执行权限
echo "🔑 设置脚本执行权限..."
chmod +x *.sh

# 5. 验证 tsx 安装
if npm list tsx &>/dev/null; then
    echo "✅ tsx 已成功安装"
else
    echo "⚠️ tsx 未正确安装，尝试全局安装..."
    npm install -g tsx
fi

# 6. 测试 hook 功能
echo "🧪 测试 hook 系统..."
echo '{"prompt":"测试 backend 开发"}' | npx tsx skill-activation-prompt.ts

echo ""
echo "✅ Hooks 系统修复完成！"
echo ""
echo "提示："
echo "1. 如果仍有问题，可以尝试重启 Claude Code"
echo "2. 确保环境变量 CLAUDE_PROJECT_DIR 已设置"
echo "3. 可以通过 'npm run test' 测试 hooks"