# 🚀 ClaudeKit - 快速使用指南

## 一行命令安装

复制下面的命令，在终端执行即可：

### macOS/Linux
```bash
curl -fsSL https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.sh | bash
```

### Windows (PowerShell)
```powershell
iwr -useb https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.ps1 | iex
```


## 安装选项

### 选项 1: 项目级安装（推荐）
在你的项目目录中运行，只影响当前项目：
```bash
curl -fsSL https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.sh | bash -s -- --project
```

### 选项 2: 全局安装
一次安装，所有项目共享：
```bash
curl -fsSL https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.sh | bash -s -- --global
```

## 安装后配置

### 1. 更新 Claude Code 设置

安装完成后会生成 `claude-settings.json`，将其内容合并到你的 Claude Code 设置中：

```json
{
  "hooks": {
    "UserPromptSubmit": [...],
    "PostToolUse": [...],
    "PreToolUse": [...]
  }
}
```

### 2. 设置环境变量

如果是项目级安装：
```bash
export CLAUDE_PROJECT_DIR="/path/to/your/project"
```

### 3. 重启 Claude Code

配置生效需要重启 Claude Code。

## 测试功能

### 中文触发
输入以下内容测试：
- "创建一个用户组件" → 触发前端开发指南
- "开发用户管理接口" → 触发后端开发指南
- "开始新的 Vue 项目" → 触发技术栈检测器

### 英文触发
- "create a user component" → Frontend guidelines
- "create user service" → Backend guidelines
- "refactor this code" → Refactor planner agent

## 核心功能

### 1. 技术栈自动检测 🔍
- 自动识别项目使用的技术栈
- 支持 Vue/React 前端框架
- 支持 Express/Spring Boot/Egg.js 后端
- 根据技术栈提供对应的开发指南

### 2. Skills 自动激活 ⚡
- 根据上下文自动激活相关技能
- 无需手动调用，智能触发
- 支持中英文关键词

### 3. Agent 智能系统 🤖
- 多种专业 Agent 协助开发
- 支持重构、调试、文档等任务
- Agent 间可以协作完成复杂任务

### 4. Dev Docs 持久化 📝
- 跨会话保持工作状态
- 自动记录项目上下文
- 支持断点续传

## 常见问题

### Q: 安装失败怎么办？
A: 检查 Node.js 版本是否 >= 18.0.0，运行 `node -v` 查看。

### Q: Hook 不触发？
A: 确保：
1. 已将配置合并到 Claude Code 设置
2. 已设置 CLAUDE_PROJECT_DIR 环境变量
3. 已重启 Claude Code

### Q: 如何卸载？
A:
- 项目级：删除项目中的 `.claude` 目录
- 全局：删除 `~/.claude-code-infrastructure` 目录

## 获取帮助

- 📖 [完整安装指南](INSTALLATION_GUIDE_CN.md)
- 🔧 [技术栈检测器使用指南](技术栈检测器使用指南.md)
- 🤖 [Agent 与 Dev Docs 集成](agent-dev-docs-integration.md)
- 📝 [项目分析报告](项目分析报告.md)

## 反馈与贡献

- 提交 Issue: [GitHub Issues](https://github.com/zengwenliang416/ClaudeKit/issues)
- 贡献代码: Fork 后提交 Pull Request

---

**让 Claude Code 变得更智能！** 🎉