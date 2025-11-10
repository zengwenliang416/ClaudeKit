# 🧰 ClaudeKit

<div align="center">

**让 Claude Code 更智能的工具箱**

[![GitHub](https://img.shields.io/badge/GitHub-ClaudeKit-blue)](https://github.com/zengwenliang416/ClaudeKit)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-orange)](https://github.com/zengwenliang416/ClaudeKit/releases)
[![Node](https://img.shields.io/badge/Node.js-%E2%89%A518.0.0-339933)](https://nodejs.org/)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)](https://github.com/zengwenliang416/ClaudeKit)

[English](README.md) | **中文**

</div>

---

## 🎬 演示

<details>
<summary>🎯 技术栈自动检测演示</summary>

```bash
用户: "开始新项目"
ClaudeKit: ✅ 检测到 Vue 3 + Spring Boot
          已加载对应的开发指南...

用户: "创建用户组件"
ClaudeKit: 🚀 触发 Vue 3 开发指南
          ✨ 使用 Composition API 创建组件...
```
</details>

<details>
<summary>⚡ Skills 自动激活演示</summary>

```bash
用户: "开发用户管理接口"
ClaudeKit: 🔧 触发后端开发指南
          📦 检测到 Spring Boot 环境
          💡 生成 RESTful API...
```
</details>

<details>
<summary>🤖 Agent 协作演示</summary>

```bash
用户: "重构这个认证系统"
ClaudeKit: 📋 启动任务链
          → refactor-planner: 分析现有代码
          → code-refactor-master: 执行重构
          → auth-route-tester: 验证功能
          ✅ 重构完成，所有测试通过
```
</details>

---

## ✨ 为什么选择 ClaudeKit

### 🚀 **开箱即用**
一键安装，无需复杂配置。自动检测项目技术栈，智能加载对应开发指南。

### 🎯 **智能感知**
基于上下文自动激活相关技能，中英文关键词均可触发，让 Claude Code 真正理解你的意图。

### 🏗️ **架构完整**
包含 Hooks、Skills、Agents 三大系统，覆盖从代码提示到复杂任务编排的全部场景。

### 🌏 **本土化优化**
专为中国开发者优化，完美支持 Vue、Spring Boot、Egg.js 等国内主流技术栈。

### 📝 **持久化记忆**
Dev Docs 系统让 Claude Code 跨会话保持工作状态，不再重复询问相同问题。

---

## 🚀 快速开始

### 一键安装

**macOS/Linux:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.sh)
```

**Windows PowerShell:**
```powershell
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.ps1" -UseBasicParsing).Content
```

### 安装选项

```bash
# 项目级安装（推荐）
bash <(curl -fsSL https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.sh) --project

# 全局安装（所有项目共享）
bash <(curl -fsSL https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.sh) --global
```

### 30 秒体验

1. **安装**: 运行上面的安装命令
2. **配置**: 将生成的配置合并到 Claude Code 设置
3. **重启**: 重启 Claude Code
4. **测试**: 输入 "创建用户组件" 或 "create user service"

---

## 📦 核心功能

### 🎯 技术栈自动检测
```yaml
检测技术栈:
  前端: Vue 3, React, Angular
  后端: Spring Boot, Express, Egg.js
  数据库: MySQL, PostgreSQL, MongoDB

智能适配:
  - 自动加载对应开发指南
  - 提供技术栈特定的最佳实践
  - 智能推荐相关工具和库
```

### ⚡ Skills 智能激活
```yaml
中文触发:
  - "创建组件" → 前端开发指南
  - "开发接口" → 后端开发指南
  - "写测试" → 测试指南

英文触发:
  - "create component" → Frontend guidelines
  - "build API" → Backend guidelines
  - "write tests" → Testing guidelines
```

### 🤖 Agent 系统
```yaml
专业 Agents:
  refactor-planner: 重构规划
  code-refactor-master: 代码重构执行
  auth-route-debugger: 认证路由调试
  auth-route-tester: 路由测试
  documentation-architect: 文档架构师

协作模式:
  - Agent 间自动协作
  - 共享 Dev Docs 上下文
  - 任务链式执行
```

### 📝 Dev Docs 持久化
```yaml
功能特性:
  - 跨会话保持状态
  - 自动记录项目上下文
  - 支持断点续传
  - Agent 间共享记忆

文件结构:
  dev/
  ├── context.md    # 项目上下文
  ├── plan.md       # 开发计划
  └── tasks.md      # 任务清单
```

---

## 🏗️ 项目结构

```
ClaudeKit/
├── .claude/                      # 核心系统
│   ├── hooks/                    # Hook 系统 - 自动触发机制
│   │   ├── skill-activation-prompt.ts    # Skill 激活器
│   │   ├── post-tool-use-tracker.ts      # 工具使用追踪
│   │   └── tsc-check.ts                  # TypeScript 检查
│   │
│   ├── skills/                   # Skills 系统 - 智能技能库
│   │   ├── skill-rules.json              # 技能触发规则
│   │   ├── tech-stack-detector/          # 技术栈检测器
│   │   ├── frontend-dev-guidelines/      # 前端开发指南
│   │   │   └── resources/
│   │   │       ├── react-patterns.md
│   │   │       └── vue3-patterns.md      # Vue 3 最佳实践
│   │   └── backend-dev-guidelines/       # 后端开发指南
│   │       └── resources/
│   │           ├── express-patterns.md
│   │           └── spring-boot-patterns.md  # Spring Boot 最佳实践
│   │
│   └── agents/                   # Agent 系统 - 智能代理
│       └── [各种专业 agents]
│
├── dev/                          # Dev Docs - 持久化文档
├── docs/                         # 使用文档
└── install-remote.sh/ps1         # 安装脚本
```

---

## 🎮 使用示例

### 基础使用

<table>
<tr>
<td width="50%">

**中文示例**
```javascript
// 输入
"创建一个用户管理组件"

// ClaudeKit 响应
✨ 检测到 Vue 3 项目
📦 加载 Vue Composition API 指南
🎨 使用 Element Plus 组件库
```

</td>
<td width="50%">

**英文示例**
```javascript
// 输入
"Create user management API"

// ClaudeKit 响应
✨ Detected Spring Boot project
📦 Loading RESTful API guidelines
🔧 Using JPA repositories
```

</td>
</tr>
</table>

### 高级功能

<details>
<summary>🔄 复杂任务编排</summary>

```bash
用户: "重构整个认证系统"

ClaudeKit 执行流程:
1. refactor-planner 分析现有系统
2. 创建重构计划文档
3. code-refactor-master 执行重构
4. auth-route-tester 验证功能
5. 更新 Dev Docs 记录变更
```
</details>

<details>
<summary>📊 技术栈切换</summary>

```bash
# 从 Express 迁移到 Spring Boot
用户: "将 Express API 迁移到 Spring Boot"

ClaudeKit:
1. 检测当前 Express 结构
2. 加载 Spring Boot 指南
3. 生成迁移计划
4. 逐步执行迁移
5. 验证功能完整性
```
</details>

---

## 🔧 配置选项

### 环境变量

```bash
# 项目目录（项目级安装需要）
export CLAUDE_PROJECT_DIR="/path/to/your/project"

# 跳过特定检查（可选）
export SKIP_FRONTEND_GUIDELINES=true
export SKIP_BACKEND_GUIDELINES=true
```

### 自定义触发规则

编辑 `.claude/skills/skill-rules.json`:

```json
{
  "skills": [
    {
      "name": "your-custom-skill",
      "triggers": {
        "keywords": ["自定义", "custom"],
        "patterns": ["创建.*组件", "create.*component"]
      }
    }
  ]
}
```

---

## 📊 性能指标

| 指标 | 数值 | 说明 |
|------|------|------|
| **安装时间** | < 30s | 包含依赖下载 |
| **启动时间** | < 100ms | Hook 系统初始化 |
| **技术栈检测** | < 50ms | 自动识别技术栈 |
| **Skill 激活** | < 10ms | 关键词匹配响应 |
| **内存占用** | < 50MB | 运行时内存使用 |

---

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 如何贡献

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 贡献方向

- 🌟 新增技术栈支持
- 📝 改进文档
- 🐛 修复问题
- ⚡ 性能优化
- 🌏 国际化支持

---

## 📚 文档

### 核心文档
- [🚀 快速开始指南](docs/zh-CN/QUICK_START.md)
- [📖 完整安装指南](docs/zh-CN/INSTALLATION_GUIDE_CN.md)
- [🔧 技术栈检测器使用指南](docs/zh-CN/技术栈检测器使用指南.md)
- [🤖 Agent 与 Dev Docs 集成](docs/technical/agent-dev-docs-integration.md)

### 技术文档
- [📝 项目分析报告](docs/technical/项目分析报告.md)
- [🏗️ Skills 系统文档](.claude/skills/README.md)
- [🪝 Hooks 系统文档](.claude/hooks/README.md)
- [🤖 Agents 系统文档](.claude/agents/README.md)

### 原项目文档
- [Claude Integration Guide](docs/guides/CLAUDE_INTEGRATION_GUIDE.md)
- [Dev Docs Pattern](dev/README.md)

---

## 🔄 更新日志

### v1.0.0 (2024-01)
- 🎉 首次发布
- ✨ 技术栈自动检测
- 🌏 中文关键词支持
- 🤖 Agent 系统集成
- 📝 Dev Docs 持久化

### v1.1.0 (规划中)
- 📱 更多技术栈支持
- 🔌 插件系统
- 🎨 UI 组件库集成
- 📊 性能分析工具

[查看完整更新日志](CHANGELOG.md)

---

## 🙏 致谢

- **Claude Code 团队** - 提供了优秀的 AI 编程环境
- **开源社区** - 灵感和技术支持
- **早期用户** - 宝贵的反馈和建议
- **所有贡献者** - 让项目越来越好

特别感谢原项目 [claude-code-infrastructure-showcase](https://github.com/original-author/claude-code-infrastructure-showcase) 提供的基础架构。

---

## 📝 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 📮 联系我们

- **问题反馈**: [GitHub Issues](https://github.com/zengwenliang416/ClaudeKit/issues)
- **功能建议**: [Discussions](https://github.com/zengwenliang416/ClaudeKit/discussions)
- **安全问题**: security@claudekit.dev
- **商业合作**: business@claudekit.dev

---

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=zengwenliang416/ClaudeKit&type=Date)](https://star-history.com/#zengwenliang416/ClaudeKit&Date)

---

<div align="center">

**让 Claude Code 更懂你！**

Made with ❤️ by [zengwenliang416](https://github.com/zengwenliang416) and contributors

[⬆ 回到顶部](#-claudekit)

</div>