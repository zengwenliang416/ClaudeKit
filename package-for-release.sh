#!/bin/bash

# ClaudeKit - 发布打包脚本
# 用于创建 GitHub Release 的压缩包

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo -e "${BLUE}              ClaudeKit 打包工具${NC}"
echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo ""

# 版本号（可以从 package.json 或手动设置）
VERSION="1.0.0"
RELEASE_NAME="claudekit-v$VERSION"

# 创建发布目录
RELEASE_DIR="release"
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

echo -e "${GREEN}[1/4]${NC} 准备文件..."

# 核心文件列表
CORE_FILES=(
    ".claude"
    "install-remote.sh"
    "INSTALLATION_GUIDE_CN.md"
    "安装需求清单.md"
    "技术栈检测器使用指南.md"
    "项目分析报告.md"
    "agent-dev-docs-integration.md"
    "README.md"
)

# 复制核心文件到发布目录
for file in "${CORE_FILES[@]}"; do
    if [ -e "$file" ]; then
        cp -r "$file" "$RELEASE_DIR/"
        echo "   ✓ $file"
    else
        echo -e "${YELLOW}   ⚠ $file 不存在${NC}"
    fi
done

echo ""
echo -e "${GREEN}[2/4]${NC} 清理不必要的文件..."

# 删除 node_modules（用户会自己安装）
rm -rf "$RELEASE_DIR/.claude/hooks/node_modules"
echo "   ✓ 移除 node_modules"

# 删除测试文件和缓存
rm -rf "$RELEASE_DIR/.claude/cache"
rm -f "$RELEASE_DIR/.claude/hooks/test-*.json"
rm -f "$RELEASE_DIR/.claude/hooks/*.log"
echo "   ✓ 移除缓存和测试文件"

echo ""
echo -e "${GREEN}[3/4]${NC} 创建压缩包..."

# 创建 tar.gz 包（Linux/Mac 友好）
tar -czf "$RELEASE_NAME.tar.gz" -C "$RELEASE_DIR" .
echo "   ✓ 创建 $RELEASE_NAME.tar.gz"

# 创建 zip 包（Windows 友好）
cd "$RELEASE_DIR"
zip -qr "../$RELEASE_NAME.zip" .
cd ..
echo "   ✓ 创建 $RELEASE_NAME.zip"

# 计算文件大小
TAR_SIZE=$(du -h "$RELEASE_NAME.tar.gz" | cut -f1)
ZIP_SIZE=$(du -h "$RELEASE_NAME.zip" | cut -f1)

echo ""
echo -e "${GREEN}[4/4]${NC} 生成安装命令..."

# 创建 README-INSTALL.md
cat > "README-INSTALL.md" << 'EOF'
# 🚀 快速安装 Claude Code Infrastructure

## 一键安装（推荐）

### 方式 1: 在线安装（无需下载）

```bash
# 安装到当前项目
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install-remote.sh | bash -s -- --project

# 或全局安装（所有项目共享）
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install-remote.sh | bash -s -- --global
```

### 方式 2: 下载后安装

```bash
# 下载最新版本
wget https://github.com/YOUR_USERNAME/YOUR_REPO/releases/latest/download/claude-code-infrastructure-vX.X.X.tar.gz

# 解压
tar -xzf claude-code-infrastructure-vX.X.X.tar.gz

# 安装
./install-remote.sh --project
```

### Windows 用户

```powershell
# 下载最新版本 ZIP
Invoke-WebRequest -Uri "https://github.com/YOUR_USERNAME/YOUR_REPO/releases/latest/download/claude-code-infrastructure-vX.X.X.zip" -OutFile "claude-infrastructure.zip"

# 解压并安装
Expand-Archive -Path "claude-infrastructure.zip" -DestinationPath "."
powershell -ExecutionPolicy Bypass -File install.ps1
```

## 安装选项

- `--project` 或 `-p`: 安装到当前项目目录
- `--global` 或 `-g`: 全局安装到 ~/.claude-code-infrastructure

## 系统要求

- Node.js >= 18.0.0
- npm >= 9.0.0
- curl 或 wget（用于下载）

## 安装后配置

1. 将生成的 `claude-settings.json` 内容合并到 Claude Code 设置
2. 重启 Claude Code
3. 测试：输入 "创建组件" 或 "create service"

## 获取帮助

- 详细文档: [INSTALLATION_GUIDE_CN.md](INSTALLATION_GUIDE_CN.md)
- 问题反馈: [GitHub Issues](https://github.com/YOUR_USERNAME/YOUR_REPO/issues)

**请记得将 YOUR_USERNAME 和 YOUR_REPO 替换为实际的 GitHub 用户名和仓库名！**
EOF

echo "   ✓ 创建 README-INSTALL.md"

# 清理发布目录
rm -rf "$RELEASE_DIR"

echo ""
echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ 打包完成！${NC}"
echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo ""
echo "📦 生成的文件:"
echo "   • $RELEASE_NAME.tar.gz ($TAR_SIZE)"
echo "   • $RELEASE_NAME.zip ($ZIP_SIZE)"
echo "   • README-INSTALL.md"
echo ""
echo "📤 发布步骤:"
echo "1. 创建 GitHub Release"
echo "2. 上传压缩包作为 Release Assets"
echo "3. 更新 install-remote.sh 中的 GitHub 信息"
echo "4. 提交 install-remote.sh 到仓库"
echo "5. 在 Release 说明中添加安装命令"
echo ""
echo "📝 安装命令示例:"
echo "curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install-remote.sh | bash"
echo ""
echo -e "${YELLOW}⚠️  记得替换 YOUR_USERNAME 和 YOUR_REPO！${NC}"