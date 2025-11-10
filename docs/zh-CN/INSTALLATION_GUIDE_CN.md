# 🚀 ClaudeKit 安装指南

让别人的 Claude Code 也能使用这套智能基础设施！

## 📋 快速开始

### 方式 1: 在线安装（最简单）🔥

无需下载整个仓库，一行命令搞定！

#### 安装到当前项目:
```bash
curl -fsSL https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.sh | bash -s -- --project
```

#### 全局安装（所有项目共享）:
```bash
curl -fsSL https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.sh | bash -s -- --global
```

#### 交互式安装（选择安装位置）:
```bash
curl -fsSL https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.sh | bash
```

### 方式 2: 本地安装

如果你已经克隆了仓库：

#### macOS/Linux:
```bash
# 1. 克隆或下载项目
git clone <your-repo-url>
cd ClaudeKit

# 2. 运行安装脚本
chmod +x install.sh
./install.sh
```

#### Windows:
```powershell
# 1. 克隆或下载项目
git clone <your-repo-url>
cd ClaudeKit

# 2. 运行安装脚本
powershell -ExecutionPolicy Bypass -File install.ps1
```

### 方式 3: 从 Release 下载

从 [GitHub Releases](https://github.com/zengwenliang416/ClaudeKit/releases) 下载最新版本：

```bash
# 下载压缩包
wget https://github.com/zengwenliang416/ClaudeKit/releases/latest/download/claudekit-v1.0.0.tar.gz

# 解压
tar -xzf claudekit-v1.0.0.tar.gz

# 安装
./install-remote.sh --project
```

## 🎯 安装模式说明

### 项目模式 vs 全局模式

| 特性 | 项目模式 (--project) | 全局模式 (--global) |
|-----|---------------------|-------------------|
| **安装位置** | 当前项目目录 | ~/.claudekit |
| **适用场景** | 单个项目使用 | 多个项目共享 |
| **配置方式** | 项目独立配置 | 统一配置 |
| **更新方式** | 每个项目单独更新 | 一次更新，全部生效 |
| **磁盘占用** | 每个项目都有副本 | 只有一份 |
| **推荐用户** | 项目特定需求 | 通用开发环境 |

### 全局模式使用方法

安装后，在任何项目中运行：
```bash
~/.claudekit/init-project.sh
```

这会在当前项目创建符号链接，指向全局安装的基础设施。

## 📦 需要安装的组件

### 1. 核心依赖
| 组件 | 版本要求 | 用途 | 安装检查 |
|------|---------|------|---------|
| **Node.js** | >= 18.0.0 | 运行 TypeScript hooks | `node -v` |
| **npm** | >= 9.0.0 | 管理依赖包 | `npm -v` |
| **Git** | 任意版本 | 版本控制 | `git --version` |

### 2. Hook 系统依赖
```json
{
  "tsx": "^4.7.0",          // TypeScript 执行器
  "typescript": "^5.3.3",    // TypeScript 编译器
  "@types/node": "^20.11.0" // Node.js 类型定义
}
```

### 3. 文件权限
需要执行权限的脚本：
- `skill-activation-prompt.sh` - 技术栈检测入口
- `post-tool-use-tracker.sh` - 文件追踪
- `tsc-check.sh` - TypeScript 检查
- 其他 `.sh` 文件

## 🔧 手动安装步骤

如果自动安装失败，请按以下步骤手动安装：

### Step 1: 安装 Node.js
```bash
# 方式 1: 官网下载
# https://nodejs.org/ (推荐 LTS 版本)

# 方式 2: 使用包管理器
# macOS
brew install node

# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Windows
winget install OpenJS.NodeJS
```

### Step 2: 安装项目依赖
```bash
# 进入 hooks 目录
cd .claude/hooks

# 安装依赖
npm install

# 验证安装
npm run check
```

### Step 3: 设置文件权限
```bash
# macOS/Linux
chmod +x .claude/hooks/*.sh

# Windows (PowerShell as Admin)
# Windows 不需要设置执行权限
```

### Step 4: 创建必要目录
```bash
# 创建 dev 文档目录
mkdir -p dev

# 创建缓存目录
mkdir -p .claude/cache
```

### Step 5: 配置 Claude Code

将以下内容添加到 Claude Code 的 `settings.json`：

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/skill-activation-prompt.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/post-tool-use-tracker.sh"
          }
        ]
      }
    ]
  }
}
```

### Step 6: 设置环境变量
```bash
# macOS/Linux
export CLAUDE_PROJECT_DIR="/path/to/your/project"

# Windows
$env:CLAUDE_PROJECT_DIR = "C:\path\to\your\project"
```

## ✅ 验证安装

### 1. 检查 Node.js
```bash
node -v  # 应该显示 v18.x.x 或更高
npm -v   # 应该显示 9.x.x 或更高
```

### 2. 测试 Hook 系统
```bash
cd .claude/hooks

# 测试 TypeScript 编译
npm run check

# 测试技术栈检测
echo '{"prompt":"开始新项目"}' | npx tsx skill-activation-prompt.ts
```

### 3. 在 Claude Code 中测试

重启 Claude Code 后，测试以下命令：

- **中文触发测试**:
  - 输入: "创建一个用户组件"
  - 期望: 触发 frontend-dev-guidelines

- **技术栈检测测试**:
  - 输入: "开始新的 Vue 项目"
  - 期望: 检测到 Vue，提供 Vue 指南

- **Agent 测试**:
  - 输入: "重构这个代码"
  - 期望: 触发 refactor-planner agent

## 🐛 常见问题解决

### 问题 1: tsx is not installed
```bash
# 解决方案
cd .claude/hooks
npm install
```

### 问题 2: Permission denied
```bash
# 解决方案
chmod +x .claude/hooks/*.sh
```

### 问题 3: Node.js 版本过低
```bash
# 升级 Node.js
nvm install 18
nvm use 18
```

### 问题 4: Hook 不触发
检查清单：
1. ✓ settings.json 配置正确
2. ✓ CLAUDE_PROJECT_DIR 环境变量设置
3. ✓ .sh 文件有执行权限
4. ✓ npm 依赖已安装
5. ✓ 重启 Claude Code

### 问题 5: Windows 上的路径问题
```powershell
# 使用正斜杠或双反斜杠
$env:CLAUDE_PROJECT_DIR = "C:/path/to/project"
# 或
$env:CLAUDE_PROJECT_DIR = "C:\\path\\to\\project"
```

## 📂 安装后的项目结构

```
your-project/
├── .claude/
│   ├── hooks/                 # Hook 系统
│   │   ├── node_modules/      # npm 依赖
│   │   ├── package.json       # 依赖配置
│   │   ├── *.ts               # TypeScript 实现
│   │   └── *.sh               # Shell 包装器
│   ├── skills/                # Skills 系统
│   │   ├── skill-rules.json   # 触发规则
│   │   ├── tech-stack-detector/ # 技术栈检测器
│   │   ├── frontend-dev-guidelines/ # 前端指南
│   │   └── backend-dev-guidelines/  # 后端指南
│   ├── agents/                # Agent 系统
│   └── cache/                 # 缓存目录
├── dev/                       # Dev Docs 目录
├── claude-settings.json       # 生成的配置
└── install.sh/ps1            # 安装脚本
```

## 🎯 功能验证清单

安装完成后，确认以下功能正常：

- [ ] **中文关键词触发**: "创建组件" → 触发前端指南
- [ ] **英文关键词触发**: "create service" → 触发后端指南
- [ ] **技术栈自动检测**: 识别 Vue/React/Spring Boot
- [ ] **文件修改追踪**: 编辑文件后记录到缓存
- [ ] **TypeScript 检查**: 修改 .ts 文件时类型检查
- [ ] **Agent 调用**: Task 工具能调用各种 agents
- [ ] **Dev Docs 持久化**: dev/ 目录正常读写

## 🚀 分享给其他人

### 打包分享
```bash
# 创建分享包
tar -czf claudekit.tar.gz \
  .claude/ \
  install.sh \
  install.ps1 \
  INSTALLATION_GUIDE_CN.md \
  安装需求清单.md

# 或使用 zip
zip -r claudekit.zip \
  .claude/ \
  install.sh \
  install.ps1 \
  INSTALLATION_GUIDE_CN.md \
  安装需求清单.md
```

### 分享说明
告诉使用者：
1. 解压到他们的项目根目录
2. 运行 `./install.sh` (Mac/Linux) 或 `install.ps1` (Windows)
3. 将生成的配置合并到 Claude Code settings.json
4. 重启 Claude Code

## 📚 相关文档

- [安装需求清单](安装需求清单.md) - 详细的依赖说明
- [项目分析报告](项目分析报告.md) - 架构和原理
- [技术栈检测器使用指南](技术栈检测器使用指南.md) - 功能使用
- [Agent 与 Dev Docs 集成](agent-dev-docs-integration.md) - 高级功能

## 💡 提示

1. **版本兼容性**: 确保 Node.js >= 18.0.0
2. **权限问题**: Windows 用户建议使用管理员权限运行
3. **网络问题**: npm 安装慢可以使用镜像源
4. **定制需求**: 可以编辑 skill-rules.json 自定义触发规则

## 🆘 获取帮助

如果遇到问题：
1. 查看错误日志: `.claude/hooks/error.log`
2. 运行诊断: `npm run check`
3. 查看 Hook README: `.claude/hooks/README.md`
4. 提交 Issue 到项目仓库

---

**祝你使用愉快！** 让 Claude Code 变得更智能！ 🎉