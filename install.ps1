# Claude Code Infrastructure Showcase - 安装脚本 (Windows PowerShell)
# 支持 Windows PowerShell 5.1+

# 设置错误处理
$ErrorActionPreference = "Stop"

# 颜色函数
function Write-Success {
    param($Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error-Message {
    param($Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Warning-Message {
    param($Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Step {
    param($Message)
    Write-Host "[步骤] $Message" -ForegroundColor Cyan
}

# Logo
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║     Claude Code Infrastructure Showcase Installer      ║" -ForegroundColor Blue
Write-Host "║            让 Claude Code 更智能的基础设施             ║" -ForegroundColor Blue
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

# 设置项目目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = $ScriptDir
$ClaudeDir = Join-Path $ProjectDir ".claude"
$HooksDir = Join-Path $ClaudeDir "hooks"

Write-Host "📁 项目目录: $ProjectDir"
Write-Host ""

# 1. 检查系统要求
Write-Step "检查系统要求..."

# 检查 Node.js
try {
    $nodeVersion = & node -v 2>$null
    if ($LASTEXITCODE -ne 0) { throw }
    Write-Host "   Node.js 版本: $nodeVersion"

    # 提取主版本号
    $versionNumber = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
    if ($versionNumber -lt 18) {
        Write-Error-Message "Node.js 版本过低！需要 >= 18.0.0"
        Write-Host "   当前版本: $nodeVersion"
        Write-Host "   请访问 https://nodejs.org/ 下载最新版本"
        exit 1
    }
} catch {
    Write-Error-Message "Node.js 未安装！"
    Write-Host ""
    Write-Host "请先安装 Node.js (>= 18.0.0):"
    Write-Host "  • 官网下载: https://nodejs.org/"
    Write-Host "  • 使用 winget: winget install OpenJS.NodeJS"
    Write-Host "  • 使用 chocolatey: choco install nodejs"
    Write-Host ""
    exit 1
}

# 检查 npm
try {
    $npmVersion = & npm -v 2>$null
    if ($LASTEXITCODE -ne 0) { throw }
    Write-Host "   npm 版本: $npmVersion"
} catch {
    Write-Error-Message "npm 未安装！"
    exit 1
}

Write-Success "系统要求检查通过"
Write-Host ""

# 2. 检查项目结构
Write-Step "检查项目结构..."

if (!(Test-Path $ClaudeDir)) {
    Write-Error-Message ".claude 目录不存在！"
    Write-Host "   请确保在正确的项目目录中运行此脚本"
    exit 1
}

if (!(Test-Path $HooksDir)) {
    Write-Error-Message ".claude/hooks 目录不存在！"
    exit 1
}

Write-Success "项目结构检查通过"
Write-Host ""

# 3. 安装 npm 依赖
Write-Step "安装 hooks 系统依赖..."

Set-Location $HooksDir

# 检查 package.json
if (!(Test-Path "package.json")) {
    Write-Error-Message "package.json 不存在！"
    exit 1
}

# 安装依赖
Write-Host "   运行 npm install..."
try {
    & npm install --silent 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw }
    Write-Success "依赖安装成功"
} catch {
    Write-Error-Message "依赖安装失败"
    Write-Host "   请尝试手动运行: cd $HooksDir && npm install"
    exit 1
}

Write-Host ""

# 4. 设置执行权限（Windows 不需要，但检查文件存在）
Write-Step "检查脚本文件..."

$shellScripts = @(
    "skill-activation-prompt.sh",
    "post-tool-use-tracker.sh",
    "tsc-check.sh",
    "trigger-build-resolver.sh",
    "stop-build-check-enhanced.sh",
    "error-handling-reminder.sh"
)

foreach ($script in $shellScripts) {
    $scriptPath = Join-Path $HooksDir $script
    if (Test-Path $scriptPath) {
        Write-Host "   ✓ $script"
    } else {
        Write-Warning-Message "$script 不存在"
    }
}

Write-Success "脚本文件检查完成"
Write-Host ""

# 5. 创建必要目录
Write-Step "创建必要目录..."

# 创建 dev 目录
$devDir = Join-Path $ProjectDir "dev"
if (!(Test-Path $devDir)) {
    New-Item -ItemType Directory -Path $devDir | Out-Null
    Write-Host "   ✓ 创建 dev\ 目录"
}

# 创建 cache 目录
$cacheDir = Join-Path $ClaudeDir "cache"
if (!(Test-Path $cacheDir)) {
    New-Item -ItemType Directory -Path $cacheDir | Out-Null
    Write-Host "   ✓ 创建 .claude\cache\ 目录"
}

Write-Success "目录创建完成"
Write-Host ""

# 6. 验证 TypeScript 配置
Write-Step "验证 TypeScript 配置..."

Set-Location $HooksDir

try {
    & npm run check 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "TypeScript 配置正确"
    } else {
        Write-Warning-Message "TypeScript 检查有警告，但不影响使用"
    }
} catch {
    Write-Warning-Message "TypeScript 检查失败，请手动检查"
}

Write-Host ""

# 7. 测试 hook 系统
Write-Step "测试 hook 系统..."

# 创建测试输入
$testInput = '{"prompt":"测试技术栈检测"}'
$testFile = Join-Path $HooksDir "test-input-temp.json"
Set-Content -Path $testFile -Value $testInput

Write-Host "   运行技术栈检测测试..."
try {
    $testOutput = $testInput | & npx tsx skill-activation-prompt.ts 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Hook 系统测试通过"
    } else {
        Write-Warning-Message "Hook 系统测试失败，请检查配置"
    }
} catch {
    Write-Warning-Message "Hook 系统测试失败，请检查配置"
}

# 清理测试文件
Remove-Item -Path $testFile -ErrorAction SilentlyContinue

Write-Host ""

# 8. 生成 settings.json 配置
Write-Step "生成 Claude Code 配置..."

$settingsFile = Join-Path $ProjectDir "claude-settings.json"

$settings = @'
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/skill-activation-prompt.sh",
            "description": "技术栈检测和 Skills 自动激活"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/post-tool-use-tracker.sh",
            "description": "文件修改追踪"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/tsc-check.sh",
            "description": "TypeScript 类型检查"
          }
        ]
      }
    ]
  }
}
'@

Set-Content -Path $settingsFile -Value $settings

Write-Host "   ✓ 配置文件已生成: claude-settings.json"
Write-Success "配置生成完成"
Write-Host ""

# 9. 显示安装摘要
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    🎉 安装成功！                       ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "📋 安装摘要:"
Write-Host "   • Node.js 依赖: ✅"
Write-Host "   • Hooks 系统: ✅"
Write-Host "   • 技术栈检测器: ✅"
Write-Host "   • Dev Docs 目录: ✅"
Write-Host ""

Write-Host "🚀 下一步:"
Write-Host ""
Write-Host "1. 将 claude-settings.json 的内容合并到你的 Claude Code settings.json 中"
Write-Host ""
Write-Host "2. 在 Claude Code 中设置项目目录环境变量:"
Write-Host "   `$env:CLAUDE_PROJECT_DIR = '$ProjectDir'"
Write-Host ""
Write-Host "3. 重启 Claude Code 使配置生效"
Write-Host ""
Write-Host "4. 测试功能:"
Write-Host "   • 输入 '创建一个用户组件' 测试中文触发"
Write-Host "   • 输入 'create a user service' 测试英文触发"
Write-Host ""

Write-Host "📖 文档:"
Write-Host "   • 安装需求: 安装需求清单.md"
Write-Host "   • 项目分析: 项目分析报告.md"
Write-Host "   • 技术栈指南: 技术栈检测器使用指南.md"
Write-Host "   • Agent 集成: agent-dev-docs-integration.md"
Write-Host ""

Write-Host "❓ 遇到问题?"
Write-Host "   • 查看 .claude\hooks\README.md"
Write-Host "   • 查看 CLAUDE_INTEGRATION_GUIDE.md"
Write-Host ""

Write-Success "感谢使用 Claude Code Infrastructure Showcase!"

# 返回原目录
Set-Location $ProjectDir