# 🧰 ClaudeKit

<div align="center">

**A Smarter Toolkit for Claude Code**

[![GitHub](https://img.shields.io/badge/GitHub-ClaudeKit-blue)](https://github.com/zengwenliang416/ClaudeKit)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-orange)](https://github.com/zengwenliang416/ClaudeKit/releases)
[![Node](https://img.shields.io/badge/Node.js-%E2%89%A518.0.0-339933)](https://nodejs.org/)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)](https://github.com/zengwenliang416/ClaudeKit)

**English** | [中文](README-CN.md)

</div>

---

## 🎬 Demo

<details>
<summary>🎯 Auto Tech Stack Detection</summary>

```bash
User: "Start new project"
ClaudeKit: ✅ Detected Vue 3 + Spring Boot
          Loading corresponding guidelines...

User: "Create user component"
ClaudeKit: 🚀 Triggered Vue 3 guidelines
          ✨ Using Composition API pattern...
```
</details>

<details>
<summary>⚡ Smart Skills Activation</summary>

```bash
User: "Build user management API"
ClaudeKit: 🔧 Triggered backend guidelines
          📦 Detected Spring Boot environment
          💡 Generating RESTful API...
```
</details>

<details>
<summary>🤖 Agent Collaboration</summary>

```bash
User: "Refactor authentication system"
ClaudeKit: 📋 Starting task chain
          → refactor-planner: Analyzing code
          → code-refactor-master: Executing refactor
          → auth-route-tester: Verifying functionality
          ✅ Refactoring complete, all tests pass
```
</details>

---

## ✨ Why ClaudeKit?

### 🚀 **Ready Out of the Box**
One-line installation with no complex configuration. Automatically detects your tech stack and loads appropriate guidelines.

### 🎯 **Context-Aware Intelligence**
Skills activate automatically based on context. Supports both English and Chinese keywords, making Claude Code truly understand your intent.

### 🏗️ **Complete Architecture**
Features three core systems - Hooks, Skills, and Agents - covering everything from code hints to complex task orchestration.

### 🌏 **Localization Optimized**
Optimized for Chinese developers with perfect support for Vue, Spring Boot, Egg.js and other popular frameworks in China.

### 📝 **Persistent Memory**
Dev Docs system maintains state across Claude Code sessions, no more repeating the same questions.

---

## 🚀 Quick Start

### One-Line Installation

**macOS/Linux:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.sh)
```

**Windows PowerShell:**
```powershell
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.ps1" -UseBasicParsing).Content
```

### Installation Options

```bash
# Project-level installation (recommended)
bash <(curl -fsSL https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.sh) --project

# Global installation (shared across projects)
bash <(curl -fsSL https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.sh) --global
```

### 30-Second Setup

1. **Install**: Run the installation command above
2. **Configure**: Merge generated config into Claude Code settings
3. **Restart**: Restart Claude Code
4. **Test**: Type "create user component" or "创建用户组件"

---

## 📦 Core Features

### 🎯 Tech Stack Auto-Detection
```yaml
Detects:
  Frontend: Vue 3, React, Angular
  Backend: Spring Boot, Express, Egg.js
  Database: MySQL, PostgreSQL, MongoDB

Smart Adaptation:
  - Auto-loads corresponding guidelines
  - Provides stack-specific best practices
  - Intelligently recommends tools and libraries
```

### ⚡ Smart Skills Activation
```yaml
English Triggers:
  - "create component" → Frontend guidelines
  - "build API" → Backend guidelines
  - "write tests" → Testing guidelines

Chinese Triggers:
  - "创建组件" → Frontend guidelines
  - "开发接口" → Backend guidelines
  - "写测试" → Testing guidelines
```

### 🤖 Agent System
```yaml
Specialized Agents:
  refactor-planner: Refactoring strategy
  code-refactor-master: Code refactoring execution
  auth-route-debugger: Authentication debugging
  auth-route-tester: Route testing
  documentation-architect: Documentation generation

Collaboration:
  - Automatic agent coordination
  - Shared Dev Docs context
  - Chain task execution
```

### 📝 Persistent Dev Docs
```yaml
Features:
  - Cross-session state persistence
  - Automatic project context recording
  - Resume capability
  - Shared memory between agents

Structure:
  dev/
  ├── context.md    # Project context
  ├── plan.md       # Development plan
  └── tasks.md      # Task checklist
```

---

## 🏗️ Project Structure

```
ClaudeKit/
├── .claude/                      # Core system
│   ├── hooks/                    # Hook system - Auto triggers
│   │   ├── skill-activation-prompt.ts    # Skill activator
│   │   ├── post-tool-use-tracker.ts      # Tool usage tracker
│   │   └── tsc-check.ts                  # TypeScript checker
│   │
│   ├── skills/                   # Skills system - Smart library
│   │   ├── skill-rules.json              # Trigger rules
│   │   ├── tech-stack-detector/          # Stack detector
│   │   ├── frontend-dev-guidelines/      # Frontend guides
│   │   │   └── resources/
│   │   │       ├── react-patterns.md
│   │   │       └── vue3-patterns.md      # Vue 3 best practices
│   │   └── backend-dev-guidelines/       # Backend guides
│   │       └── resources/
│   │           ├── express-patterns.md
│   │           └── spring-boot-patterns.md  # Spring Boot patterns
│   │
│   └── agents/                   # Agent system
│       └── [specialized agents]
│
├── dev/                          # Dev Docs - Persistent docs
├── docs/                         # Documentation
└── install-remote.sh/ps1         # Installation scripts
```

---

## 🎮 Usage Examples

### Basic Usage

<table>
<tr>
<td width="50%">

**Component Creation**
```javascript
// Input
"Create a user management component"

// ClaudeKit Response
✨ Detected Vue 3 project
📦 Loading Composition API guide
🎨 Using Element Plus components
```

</td>
<td width="50%">

**API Development**
```javascript
// Input
"Build user authentication API"

// ClaudeKit Response
✨ Detected Spring Boot project
📦 Loading RESTful guidelines
🔧 Using JPA repositories
```

</td>
</tr>
</table>

### Advanced Features

<details>
<summary>🔄 Complex Task Orchestration</summary>

```bash
User: "Refactor entire authentication system"

ClaudeKit Workflow:
1. refactor-planner analyzes current system
2. Creates refactoring plan document
3. code-refactor-master executes refactoring
4. auth-route-tester verifies functionality
5. Updates Dev Docs with changes
```
</details>

<details>
<summary>📊 Tech Stack Migration</summary>

```bash
# Migrating from Express to Spring Boot
User: "Migrate Express API to Spring Boot"

ClaudeKit:
1. Detects current Express structure
2. Loads Spring Boot guidelines
3. Generates migration plan
4. Executes step-by-step migration
5. Verifies functionality integrity
```
</details>

---

## 🔧 Configuration

### Environment Variables

```bash
# Project directory (required for project-level install)
export CLAUDE_PROJECT_DIR="/path/to/your/project"

# Skip specific checks (optional)
export SKIP_FRONTEND_GUIDELINES=true
export SKIP_BACKEND_GUIDELINES=true
```

### Custom Trigger Rules

Edit `.claude/skills/skill-rules.json`:

```json
{
  "skills": [
    {
      "name": "your-custom-skill",
      "triggers": {
        "keywords": ["custom", "specific"],
        "patterns": ["create.*component", "build.*service"]
      }
    }
  ]
}
```

---

## 📊 Performance Metrics

| Metric | Value | Description |
|--------|-------|-------------|
| **Installation** | < 30s | Including dependencies |
| **Startup** | < 100ms | Hook system init |
| **Stack Detection** | < 50ms | Auto-identify stack |
| **Skill Activation** | < 10ms | Keyword matching |
| **Memory Usage** | < 50MB | Runtime memory |

---

## 🤝 Contributing

We welcome all contributions!

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Contribution Ideas

- 🌟 Add new tech stack support
- 📝 Improve documentation
- 🐛 Fix bugs
- ⚡ Performance optimization
- 🌏 Internationalization

---

## 📚 Documentation

### Core Docs
- [🚀 Quick Start Guide](docs/zh-CN/QUICK_START.md)
- [📖 Installation Guide](docs/zh-CN/INSTALLATION_GUIDE_CN.md)
- [🔧 Tech Stack Detector Guide](docs/zh-CN/技术栈检测器使用指南.md)
- [🤖 Agent & Dev Docs Integration](docs/technical/agent-dev-docs-integration.md)

### Technical Docs
- [📝 Project Analysis Report](docs/technical/项目分析报告.md)
- [🏗️ Skills System](.claude/skills/README.md)
- [🪝 Hooks System](.claude/hooks/README.md)
- [🤖 Agents System](.claude/agents/README.md)

### Original Project Docs
- [Claude Integration Guide](docs/guides/CLAUDE_INTEGRATION_GUIDE.md)
- [Dev Docs Pattern](dev/README.md)

---

## 🔄 Changelog

### v1.0.0 (2024-01)
- 🎉 Initial release
- ✨ Tech stack auto-detection
- 🌏 Chinese keyword support
- 🤖 Agent system integration
- 📝 Persistent Dev Docs

### v1.1.0 (Planned)
- 📱 More tech stack support
- 🔌 Plugin system
- 🎨 UI component library integration
- 📊 Performance analysis tools

[View full changelog](CHANGELOG.md)

---

## 🙏 Acknowledgments

- **Claude Code Team** - For the excellent AI programming environment
- **Open Source Community** - Inspiration and technical support
- **Early Users** - Valuable feedback and suggestions
- **All Contributors** - Making the project better

Special thanks to the original [claude-code-infrastructure-showcase](https://github.com/original-author/claude-code-infrastructure-showcase) project for the foundational architecture.

---

## 📝 License

MIT License - see the [LICENSE](LICENSE) file for details

---

## 📮 Contact

- **Issues**: [GitHub Issues](https://github.com/zengwenliang416/ClaudeKit/issues)
- **Discussions**: [GitHub Discussions](https://github.com/zengwenliang416/ClaudeKit/discussions)
- **Security**: security@claudekit.dev
- **Business**: business@claudekit.dev

---

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=zengwenliang416/ClaudeKit&type=Date)](https://star-history.com/#zengwenliang416/ClaudeKit&Date)

---

<div align="center">

**Make Claude Code Smarter!**

Made with ❤️ by [zengwenliang416](https://github.com/zengwenliang416) and contributors

[⬆ Back to Top](#-claudekit)

</div>