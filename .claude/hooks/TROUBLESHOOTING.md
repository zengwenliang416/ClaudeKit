# Hooks 故障排查指南

当 ClaudeKit 的技能无法正确触发时,使用本指南进行诊断和修复。

---

## 🔍 快速诊断

### 运行诊断工具

```bash
cd .claude/hooks
./test-skill-triggers.sh "create component"
```

如果工具报错,请按照下面的步骤排查。

---

## 常见问题

### 1. ❌ Hook 完全不执行

**症状**: 输入关键词后完全没有技能推荐

**可能原因**:
- Hook 未在 Claude Code 配置中注册
- Hook 脚本没有执行权限
- 环境变量 `CLAUDE_PROJECT_DIR` 未设置(项目级安装)

**解决方法**:

```bash
# 检查 hook 权限
ls -la .claude/hooks/*.sh

# 如果没有执行权限,添加权限
chmod +x .claude/hooks/*.sh

# 验证环境变量(仅全局安装需要)
echo $CLAUDE_PROJECT_DIR

# 如果使用项目级安装,确保 hook-env.sh 存在
cat .claude/hooks/hook-env.sh
```

---

### 2. ⚠️ Hook 执行但无匹配

**症状**: Hook 运行了但没有推荐任何技能

**可能原因**:
- 关键词不在 skill-rules.json 中
- 关键词拼写错误
- 触发规则配置过于严格

**解决方法**:

```bash
# 测试具体的提示词
./test-skill-triggers.sh "your prompt here"

# 检查 skill-rules.json 配置
cat .claude/skills/skill-rules.json | grep -A5 "keywords"

# 查看所有可用关键词
cat .claude/skills/skill-rules.json | jq '.skills[].promptTriggers.keywords'
```

**添加自定义关键词**:

编辑 `.claude/skills/skill-rules.json`:

```json
{
  "skills": {
    "frontend-dev-guidelines": {
      "promptTriggers": {
        "keywords": [
          "component",
          "组件",
          "your-custom-keyword"  // 添加这里
        ]
      }
    }
  }
}
```

---

### 3. 🐛 Hook 执行报错

**症状**: Hook 输出错误信息

**常见错误信息**:

#### Error: "skill-rules.json not found"

```bash
# 检查文件是否存在
ls -la .claude/skills/skill-rules.json

# 如果不存在,可能安装不完整,重新安装
./install.sh --project
```

#### Error: "Invalid project directory"

```bash
# 检查 hook-env.sh 是否正常工作
source .claude/hooks/hook-env.sh
echo $CLAUDE_PROJECT_DIR

# 应该输出项目根目录的绝对路径
# 如果为空或错误,检查 hook-env.sh 脚本
```

#### Error: "npx tsx not found"

```bash
# 检查 Node.js 是否安装
node --version

# 检查 tsx 是否可用
cd .claude/hooks
npx tsx --version

# 如果不可用,安装依赖
npm install
```

---

### 4. 🔄 触发不稳定

**症状**: 同样的提示词有时触发,有时不触发

**可能原因**:
- 输入中有额外的空格或标点符号
- 中英文标点混用
- 大小写不一致

**解决方法**:

✅ **优化后的匹配逻辑已自动处理这些问题**

新版本的触发器已经具有:
- 自动规范化空格
- 忽略标点符号
- 不区分大小写
- 支持多词关键词的灵活匹配

如果仍有问题:

```bash
# 使用诊断工具测试
./test-skill-triggers.sh "your exact prompt"

# 查看详细错误信息
CLAUDE_PROJECT_DIR=/path/to/project \
  echo '{"session_id":"test","transcript_path":"","cwd":"/path/to/project","permission_mode":"auto","prompt":"your prompt"}' | \
  npx tsx skill-activation-prompt.ts
```

---

## 🛠️ 高级调试

### 启用详细日志

临时修改 `skill-activation-prompt.ts`,在主函数开头添加:

```typescript
async function main() {
    try {
        const input = readFileSync(0, 'utf-8');
        const data: HookInput = JSON.parse(input);

        // 添加调试日志
        console.error('[DEBUG] Prompt:', data.prompt);
        console.error('[DEBUG] Project dir:', projectDir);
        console.error('[DEBUG] Rules path:', rulesPath);

        // ... 其余代码
```

### 手动测试 Hook

```bash
cd .claude/hooks

# 创建测试输入
cat > test-input.json <<EOF
{
  "session_id": "manual-test",
  "transcript_path": "/tmp/test",
  "cwd": "$(pwd)/../..",
  "permission_mode": "auto",
  "prompt": "create user component"
}
EOF

# 运行 hook
cat test-input.json | npx tsx skill-activation-prompt.ts

# 清理
rm test-input.json
```

---

## 📊 验证修复

修复后,运行完整测试:

```bash
# 测试英文关键词
./test-skill-triggers.sh "create component"
./test-skill-triggers.sh "build API"
./test-skill-triggers.sh "test route"

# 测试中文关键词
./test-skill-triggers.sh "创建组件"
./test-skill-triggers.sh "开发接口"
./test-skill-triggers.sh "测试路由"

# 测试技术栈检测
./test-skill-triggers.sh "start new project"
./test-skill-triggers.sh "初始化项目"
```

所有测试应该显示:
```
✅ Hook 执行成功
```

并且相应的技能应该出现在推荐列表中。

---

## 🆘 获取帮助

如果以上方法都无法解决问题:

1. **收集诊断信息**:
   ```bash
   ./test-skill-triggers.sh "your prompt" > diagnostic-output.txt 2>&1
   ```

2. **检查环境**:
   ```bash
   echo "Node: $(node --version)" >> diagnostic-output.txt
   echo "NPM: $(npm --version)" >> diagnostic-output.txt
   echo "PWD: $(pwd)" >> diagnostic-output.txt
   echo "CLAUDE_PROJECT_DIR: $CLAUDE_PROJECT_DIR" >> diagnostic-output.txt
   ```

3. **提交 Issue**:
   在 GitHub 上提交 issue,附上 `diagnostic-output.txt`

---

## 📝 改进日志

### v1.1.0 优化 (当前版本)

✨ **触发可靠性提升**:
- ✅ 修复环境变量回退路径问题
- ✅ 增强关键词匹配灵活性
- ✅ 添加详细错误日志
- ✅ 新增诊断测试工具
- ✅ 改进错误处理,避免阻塞 Claude

🔧 **技术改进**:
- 自动检测项目目录(无需手动设置环境变量)
- 规范化提示词处理(空格、标点、大小写)
- 多词关键词的灵活匹配
- 正则表达式错误捕获
- 非阻塞错误处理

---

## 📖 相关文档

- [Hook 系统说明](README.md)
- [技能规则配置](../skills/skill-rules.json)
- [安装指南](../../docs/zh-CN/INSTALLATION_GUIDE_CN.md)
