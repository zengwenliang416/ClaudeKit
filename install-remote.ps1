# ClaudeKit - 远程安装脚本 (Windows PowerShell)
# 使用方式: iwr -useb https://raw.githubusercontent.com/zengwenliang416/ClaudeKit/main/install-remote.ps1 | iex

param(
    [string]$Mode = ""  # --project 或 --global
)

# GitHub 仓库配置
$GitHubUser = "zengwenliang416"
$GitHubRepo = "ClaudeKit"
$GitHubBranch = "main"
$GitHubRawUrl = "https://raw.githubusercontent.com/$GitHubUser/$GitHubRepo/$GitHubBranch"
$GitHubArchiveUrl = "https://github.com/$GitHubUser/$GitHubRepo/archive/refs/heads/$GitHubBranch.zip"

# 设置错误处理
$ErrorActionPreference = "Stop"

# 颜色函数
function Write-Success {
    Write-Host "✅ $args" -ForegroundColor Green
}

function Write-Error-Message {
    Write-Host "❌ $args" -ForegroundColor Red
}

function Write-Warning-Message {
    Write-Host "⚠️  $args" -ForegroundColor Yellow
}

function Write-Step {
    Write-Host "[步骤] $args" -ForegroundColor Cyan
}

function Write-Info {
    Write-Host "ℹ️  $args" -ForegroundColor Cyan
}

# 显示 Logo
function Show-Logo {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║              ClaudeKit Remote Installer                ║" -ForegroundColor Blue
    Write-Host "║         让 Claude Code 更智能的工具箱                    ║" -ForegroundColor Blue
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Blue
    Write-Host ""
}

# 检查系统要求
function Check-Requirements {
    Write-Step "检查系统要求..."

    # 检查 Node.js
    try {
        $nodeVersion = & node -v 2>$null
        if ($LASTEXITCODE -ne 0) { throw }

        $versionNumber = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
        if ($versionNumber -lt 18) {
            Write-Error-Message "Node.js 版本过低！需要 >= 18.0.0"
            Write-Host "   当前版本: $nodeVersion"
            Write-Host "   请访问 https://nodejs.org/ 下载最新版本"
            exit 1
        }
        Write-Host "   Node.js: $nodeVersion ✓"
    } catch {
        Write-Error-Message "Node.js 未安装！"
        Write-Host ""
        Write-Host "请先安装 Node.js (>= 18.0.0):"
        Write-Host "  • 官网: https://nodejs.org/"
        Write-Host "  • winget: winget install OpenJS.NodeJS"
        Write-Host "  • chocolatey: choco install nodejs"
        Write-Host ""
        exit 1
    }

    # 检查 npm
    try {
        $npmVersion = & npm -v 2>$null
        if ($LASTEXITCODE -ne 0) { throw }
        Write-Host "   npm: $npmVersion ✓"
    } catch {
        Write-Error-Message "npm 未安装！"
        exit 1
    }

    Write-Success "系统要求检查通过"
    Write-Host ""
}

# 选择安装位置
function Select-InstallLocation {
    Write-Step "选择安装位置..."

    # 检查命令行参数
    if ($Mode -eq "--project" -or $Mode -eq "-p") {
        $script:InstallMode = "project"
        $script:InstallDir = (Get-Location).Path
        Write-Info "安装模式: 当前项目目录"
    } elseif ($Mode -eq "--global" -or $Mode -eq "-g") {
        $script:InstallMode = "global"
        $script:InstallDir = "$env:USERPROFILE\.claudekit"
        Write-Info "安装模式: 全局安装"
    } else {
        # 交互式选择
        Write-Host ""
        Write-Host "请选择安装位置:"
        Write-Host "  1) 当前项目目录 (推荐用于单个项目)"
        Write-Host "  2) 全局安装 (所有项目共享)"
        Write-Host ""
        $choice = Read-Host "请输入选择 (1/2)"

        switch ($choice) {
            "1" {
                $script:InstallMode = "project"
                $script:InstallDir = (Get-Location).Path
            }
            "2" {
                $script:InstallMode = "global"
                $script:InstallDir = "$env:USERPROFILE\.claudekit"
            }
            default {
                Write-Error-Message "无效的选择！"
                exit 1
            }
        }
    }

    Write-Host "   安装目录: $InstallDir"

    # 创建安装目录
    if (!(Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }

    Write-Success "安装位置确定"
    Write-Host ""
}

# 下载文件
function Download-Infrastructure {
    Write-Step "下载 ClaudeKit..."

    # 创建临时目录
    $tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
    Set-Location $tempDir

    Write-Host "   下载地址: $GitHubArchiveUrl"

    # 下载压缩包
    try {
        Invoke-WebRequest -Uri $GitHubArchiveUrl -OutFile "infrastructure.zip"
    } catch {
        Write-Error-Message "下载失败！"
        Remove-Item -Recurse -Force $tempDir
        exit 1
    }

    # 解压
    Write-Host "   解压文件..."
    Expand-Archive -Path "infrastructure.zip" -DestinationPath "." -Force

    # 找到解压后的目录
    $extractDir = Get-ChildItem -Directory | Where-Object { $_.Name -like "*$GitHubRepo*" } | Select-Object -First 1

    if (!$extractDir) {
        Write-Error-Message "解压失败！"
        Remove-Item -Recurse -Force $tempDir
        exit 1
    }

    # 备份现有的 .claude 目录
    $claudeDir = Join-Path $InstallDir ".claude"
    if (Test-Path $claudeDir) {
        $backupDir = "$claudeDir.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Warning-Message "发现现有 .claude 目录，备份到: $backupDir"
        Move-Item $claudeDir $backupDir
    }

    # 复制新文件
    Write-Host "   复制文件到安装目录..."
    Copy-Item -Path "$($extractDir.FullName)\.claude" -Destination $InstallDir -Recurse -Force

    # 复制文档文件（如果是全局安装）
    if ($InstallMode -eq "global") {
        Get-ChildItem "$($extractDir.FullName)\*.md" -ErrorAction SilentlyContinue |
            Copy-Item -Destination $InstallDir -Force
    }

    # 清理临时文件
    Set-Location $InstallDir
    Remove-Item -Recurse -Force $tempDir

    Write-Success "文件下载完成"
    Write-Host ""
}

# 安装依赖
function Install-Dependencies {
    Write-Step "安装 npm 依赖..."

    $hooksDir = Join-Path $InstallDir ".claude\hooks"
    Set-Location $hooksDir

    if (!(Test-Path "package.json")) {
        Write-Error-Message "package.json 不存在！"
        exit 1
    }

    Write-Host "   运行 npm install..."
    try {
        & npm install --silent 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { throw }
        Write-Success "依赖安装成功"
    } catch {
        Write-Warning-Message "依赖安装可能有警告，尝试继续..."
    }

    Write-Host ""
}

# 创建目录
function Create-Directories {
    Write-Step "创建必要目录..."

    # 创建 dev 目录
    if ($InstallMode -eq "project") {
        $devDir = Join-Path $InstallDir "dev"
        if (!(Test-Path $devDir)) {
            New-Item -ItemType Directory -Path $devDir | Out-Null
            Write-Host "   ✓ 创建 dev\ 目录"
        }
    }

    # 创建 cache 目录
    $cacheDir = Join-Path $InstallDir ".claude\cache"
    if (!(Test-Path $cacheDir)) {
        New-Item -ItemType Directory -Path $cacheDir | Out-Null
        Write-Host "   ✓ 创建 .claude\cache\ 目录"
    }

    Write-Success "目录创建完成"
    Write-Host ""
}

# 生成配置
function Generate-Config {
    Write-Step "生成配置文件..."

    if ($InstallMode -eq "project") {
        $configDir = $InstallDir
        $hooksPath = "`$CLAUDE_PROJECT_DIR/.claude/hooks"
    } else {
        $configDir = $InstallDir
        $hooksPath = "$InstallDir/.claude/hooks"
    }

    $settings = @{
        hooks = @{
            UserPromptSubmit = @(
                @{
                    hooks = @(
                        @{
                            type = "command"
                            command = "$hooksPath/skill-activation-prompt.sh"
                            description = "技术栈检测和 Skills 自动激活"
                        }
                    )
                }
            )
            PostToolUse = @(
                @{
                    hooks = @(
                        @{
                            type = "command"
                            command = "$hooksPath/post-tool-use-tracker.sh"
                            description = "文件修改追踪"
                        }
                    )
                }
            )
            PreToolUse = @(
                @{
                    hooks = @(
                        @{
                            type = "command"
                            command = "$hooksPath/tsc-check.sh"
                            description = "TypeScript 类型检查"
                        }
                    )
                }
            )
        }
    }

    $settingsJson = $settings | ConvertTo-Json -Depth 10
    $settingsPath = Join-Path $configDir "claude-settings.json"
    Set-Content -Path $settingsPath -Value $settingsJson

    Write-Host "   配置文件: $settingsPath"

    # 生成代理配置示例
    $proxySettings = @{
        hooks = $settings.hooks
        env = @{
            HTTP_PROXY = "http://127.0.0.1:7897"
            HTTPS_PROXY = "http://127.0.0.1:7897"
            http_proxy = "http://127.0.0.1:7897"
            https_proxy = "http://127.0.0.1:7897"
            NO_PROXY = "localhost,127.0.0.1"
        }
    }

    $proxySettingsJson = $proxySettings | ConvertTo-Json -Depth 10
    $proxySettingsPath = Join-Path $configDir "claude-settings.proxy-example.json"
    Set-Content -Path $proxySettingsPath -Value $proxySettingsJson

    Write-Host "   代理配置示例: $proxySettingsPath"

    # 如果是全局安装，创建初始化脚本
    if ($InstallMode -eq "global") {
        $initScript = @"
# 在项目中初始化 ClaudeKit
`$globalDir = "$InstallDir"
`$projectDir = Get-Location

Write-Host "正在为当前项目初始化 ClaudeKit..."

# 创建符号链接
New-Item -ItemType SymbolicLink -Path "`$projectDir\.claude" -Target "`$globalDir\.claude" -Force

# 创建 dev 目录
New-Item -ItemType Directory -Path "`$projectDir\dev" -Force | Out-Null

Write-Host "✅ 初始化完成！"
Write-Host "请将 `$globalDir\claude-settings.json 的内容合并到你的 Claude Code 设置中"
"@
        $initScriptPath = Join-Path $InstallDir "init-project.ps1"
        Set-Content -Path $initScriptPath -Value $initScript
        Write-Host "   初始化脚本: $initScriptPath"
    }

    Write-Success "配置生成完成"
    Write-Host ""
}

# 验证安装
function Verify-Installation {
    Write-Step "验证安装..."

    $hooksDir = Join-Path $InstallDir ".claude\hooks"
    Set-Location $hooksDir

    # TypeScript 检查
    try {
        & npm run check 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✓ TypeScript 配置正确"
        } else {
            Write-Warning-Message "TypeScript 检查有警告"
        }
    } catch {
        Write-Warning-Message "TypeScript 检查失败"
    }

    # Hook 系统测试
    try {
        '{"prompt":"test"}' | & npx tsx skill-activation-prompt.ts 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✓ Hook 系统正常"
        } else {
            Write-Warning-Message "Hook 系统测试失败，请手动检查"
        }
    } catch {
        Write-Warning-Message "Hook 系统测试失败"
    }

    Write-Success "安装验证完成"
    Write-Host ""
}

# 显示完成信息
function Show-Completion {
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                    🎉 安装成功！                       ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""

    if ($InstallMode -eq "project") {
        Write-Host "📋 项目模式安装完成"
        Write-Host "   安装位置: $InstallDir"
        Write-Host ""
        Write-Host "🚀 下一步:"
        Write-Host "1. 将 claude-settings.json 的内容合并到 Claude Code 设置中"
        Write-Host "2. (可选) 如需使用代理,参考 claude-settings.proxy-example.json"
        Write-Host "   在 Claude Code 设置中添加 env 配置并修改代理端口号"
        Write-Host "3. 重启 Claude Code"
    } else {
        Write-Host "📋 全局模式安装完成"
        Write-Host "   安装位置: $InstallDir"
        Write-Host ""
        Write-Host "🚀 在项目中使用:"
        Write-Host "1. 进入你的项目目录"
        Write-Host "2. 运行: & '$InstallDir\init-project.ps1'"
        Write-Host "3. 将配置合并到 Claude Code 设置中"
        Write-Host "4. (可选) 如需使用代理,参考 claude-settings.proxy-example.json"
        Write-Host "5. 重启 Claude Code"
    }

    Write-Host ""
    Write-Host "📖 功能特性:"
    Write-Host "   • 中文支持：'创建组件'、'开发接口'"
    Write-Host "   • 技术栈检测：自动识别 Vue/React/Spring Boot"
    Write-Host "   • Skills 自动激活"
    Write-Host "   • Agent 智能系统"
    Write-Host "   • Dev Docs 持久化"
    Write-Host ""
    Write-Host "❓ 需要帮助？"
    Write-Host "   • 查看文档: $InstallDir\.claude\hooks\README.md"
    Write-Host "   • GitHub: https://github.com/$GitHubUser/$GitHubRepo"
    Write-Host ""
    Write-Success "感谢使用 ClaudeKit！"
}

# 主函数
function Main {
    Show-Logo
    Check-Requirements
    Select-InstallLocation
    Download-Infrastructure
    Install-Dependencies
    Create-Directories
    Generate-Config
    Verify-Installation
    Show-Completion
}

# 运行主函数
Main