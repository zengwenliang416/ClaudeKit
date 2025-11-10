---
name: china-frontend-practices
version: 1.0.0
description: Vue 3 + Element Plus + Vite 国内主流前端技术栈最佳实践
tags: [vue3, element-plus, vite, pinia, typescript, china-tech-stack]
author: Claude Code CN
---

# Vue 3 + Element Plus 开发指南（国内技术栈）

> 本指南专为使用 Vue 生态的国内开发者设计，包含 Element Plus、Pinia、Vite 等主流技术。

---

## 快速开始

### 项目初始化
```bash
# 使用官方脚手架创建项目
npm create vue@latest my-app

# 选择配置
✔ Add TypeScript? Yes
✔ Add JSX Support? No
✔ Add Vue Router? Yes
✔ Add Pinia? Yes
✔ Add Vitest? Yes

cd my-app

# 安装 UI 框架
npm install element-plus @element-plus/icons-vue

# 安装常用依赖
npm install axios dayjs lodash-es
```

### 配置 Element Plus
```typescript
// main.ts
import { createApp } from 'vue'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import zhCn from 'element-plus/dist/locale/zh-cn.mjs'

const app = createApp(App)
app.use(ElementPlus, {
  locale: zhCn,
})
```

---

## Vue 3 组件开发

### 基础组件模板
```vue
<template>
  <div class="user-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>用户列表</span>
          <el-button type="primary" @click="handleAdd">
            <el-icon><Plus /></el-icon>
            新增用户
          </el-button>
        </div>
      </template>

      <!-- 搜索栏 -->
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="用户名">
          <el-input v-model="searchForm.username" placeholder="请输入" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 数据表格 -->
      <el-table v-loading="loading" :data="tableData" style="width: 100%">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" />
        <el-table-column prop="email" label="邮箱" />
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'">
              {{ row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleEdit(row)">
              编辑
            </el-button>
            <el-button link type="danger" @click="handleDelete(row)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :total="total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
      />
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="form.email" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import type { FormInstance, FormRules } from 'element-plus'
import { getUserList, createUser, updateUser, deleteUser } from '@/api/user'

// 类型定义
interface User {
  id: number
  username: string
  email: string
  status: number
}

// 响应式数据
const loading = ref(false)
const tableData = ref<User[]>([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)

// 搜索表单
const searchForm = reactive({
  username: ''
})

// 对话框
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formRef = ref<FormInstance>()
const form = reactive<Partial<User>>({
  username: '',
  email: '',
  status: 1
})

// 表单验证规则
const rules = reactive<FormRules<User>>({
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '长度在 3 到 20 个字符', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ]
})

// 获取列表数据
const getList = async () => {
  loading.value = true
  try {
    const res = await getUserList({
      page: currentPage.value,
      pageSize: pageSize.value,
      ...searchForm
    })
    tableData.value = res.data.list
    total.value = res.data.total
  } catch (error) {
    ElMessage.error('获取数据失败')
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  currentPage.value = 1
  getList()
}

// 重置
const handleReset = () => {
  searchForm.username = ''
  handleSearch()
}

// 新增
const handleAdd = () => {
  dialogTitle.value = '新增用户'
  form.id = undefined
  form.username = ''
  form.email = ''
  form.status = 1
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row: User) => {
  dialogTitle.value = '编辑用户'
  Object.assign(form, row)
  dialogVisible.value = true
}

// 删除
const handleDelete = async (row: User) => {
  try {
    await ElMessageBox.confirm('确定要删除该用户吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    await deleteUser(row.id)
    ElMessage.success('删除成功')
    getList()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (form.id) {
          await updateUser(form as User)
          ElMessage.success('更新成功')
        } else {
          await createUser(form as User)
          ElMessage.success('创建成功')
        }
        dialogVisible.value = false
        getList()
      } catch (error) {
        ElMessage.error('操作失败')
      }
    }
  })
}

// 分页
const handleSizeChange = (val: number) => {
  pageSize.value = val
  getList()
}

const handleCurrentChange = (val: number) => {
  currentPage.value = val
  getList()
}

// 生命周期
onMounted(() => {
  getList()
})
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.el-pagination {
  margin-top: 20px;
  justify-content: flex-end;
}
</style>
```

---

## Pinia 状态管理

### Store 定义
```typescript
// stores/user.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { login, logout, getUserInfo } from '@/api/auth'
import { ElMessage } from 'element-plus'

export const useUserStore = defineStore('user', () => {
  // State
  const token = ref(localStorage.getItem('token') || '')
  const userInfo = ref<UserInfo | null>(null)
  const permissions = ref<string[]>([])

  // Getters
  const isLoggedIn = computed(() => !!token.value)
  const username = computed(() => userInfo.value?.username || '')
  const hasPermission = computed(() => {
    return (permission: string) => permissions.value.includes(permission)
  })

  // Actions
  const loginAction = async (loginForm: LoginForm) => {
    try {
      const res = await login(loginForm)
      token.value = res.data.token
      localStorage.setItem('token', token.value)

      // 获取用户信息
      await getUserInfoAction()

      ElMessage.success('登录成功')
      return true
    } catch (error) {
      ElMessage.error('登录失败')
      return false
    }
  }

  const getUserInfoAction = async () => {
    try {
      const res = await getUserInfo()
      userInfo.value = res.data.userInfo
      permissions.value = res.data.permissions
    } catch (error) {
      ElMessage.error('获取用户信息失败')
    }
  }

  const logoutAction = async () => {
    try {
      await logout()
    } finally {
      token.value = ''
      userInfo.value = null
      permissions.value = []
      localStorage.removeItem('token')
    }
  }

  return {
    // State
    token,
    userInfo,
    permissions,
    // Getters
    isLoggedIn,
    username,
    hasPermission,
    // Actions
    login: loginAction,
    getUserInfo: getUserInfoAction,
    logout: logoutAction
  }
})
```

### 在组件中使用
```vue
<script setup lang="ts">
import { useUserStore } from '@/stores/user'
import { useRouter } from 'vue-router'

const userStore = useUserStore()
const router = useRouter()

const handleLogin = async () => {
  const success = await userStore.login({
    username: 'admin',
    password: '123456'
  })

  if (success) {
    router.push('/dashboard')
  }
}

// 使用计算属性
const isAdmin = computed(() => userStore.hasPermission('admin'))
</script>
```

---

## API 请求封装

### Axios 配置
```typescript
// utils/request.ts
import axios from 'axios'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'

const request = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  timeout: 10000
})

// 请求拦截器
request.interceptors.request.use(
  (config) => {
    const userStore = useUserStore()
    if (userStore.token) {
      config.headers.Authorization = `Bearer ${userStore.token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// 响应拦截器
request.interceptors.response.use(
  (response) => {
    const { code, data, message } = response.data

    // 根据后端约定处理
    if (code === 0) {
      return data
    } else {
      ElMessage.error(message || '请求失败')
      return Promise.reject(new Error(message))
    }
  },
  (error) => {
    // 处理 HTTP 错误状态
    if (error.response) {
      const { status } = error.response

      switch (status) {
        case 401:
          ElMessage.error('登录已过期，请重新登录')
          const userStore = useUserStore()
          userStore.logout()
          window.location.href = '/login'
          break
        case 403:
          ElMessage.error('没有权限访问')
          break
        case 404:
          ElMessage.error('请求的资源不存在')
          break
        case 500:
          ElMessage.error('服务器错误')
          break
        default:
          ElMessage.error('网络错误')
      }
    } else {
      ElMessage.error('网络连接失败')
    }

    return Promise.reject(error)
  }
)

export default request
```

### API 模块化
```typescript
// api/user.ts
import request from '@/utils/request'

// 用户列表
export const getUserList = (params: PageParams) => {
  return request.get('/api/users', { params })
}

// 创建用户
export const createUser = (data: UserForm) => {
  return request.post('/api/users', data)
}

// 更新用户
export const updateUser = (data: User) => {
  return request.put(`/api/users/${data.id}`, data)
}

// 删除用户
export const deleteUser = (id: number) => {
  return request.delete(`/api/users/${id}`)
}
```

---

## 路由配置

### 路由设置
```typescript
// router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: 'Login',
      component: () => import('@/views/login/index.vue'),
      meta: { public: true }
    },
    {
      path: '/',
      component: () => import('@/layouts/MainLayout.vue'),
      redirect: '/dashboard',
      children: [
        {
          path: 'dashboard',
          name: 'Dashboard',
          component: () => import('@/views/dashboard/index.vue'),
          meta: { title: '仪表盘', icon: 'Dashboard' }
        },
        {
          path: 'users',
          name: 'Users',
          component: () => import('@/views/users/index.vue'),
          meta: { title: '用户管理', icon: 'User', permission: 'user:list' }
        }
      ]
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'NotFound',
      component: () => import('@/views/error/404.vue')
    }
  ]
})

// 路由守卫
router.beforeEach(async (to, from, next) => {
  const userStore = useUserStore()

  // 白名单页面直接放行
  if (to.meta.public) {
    next()
    return
  }

  // 检查登录状态
  if (!userStore.isLoggedIn) {
    next({ name: 'Login', query: { redirect: to.fullPath } })
    return
  }

  // 检查权限
  if (to.meta.permission) {
    if (userStore.hasPermission(to.meta.permission as string)) {
      next()
    } else {
      ElMessage.error('没有访问权限')
      next(false)
    }
  } else {
    next()
  }
})

export default router
```

---

## 常见场景解决方案

### 表单验证
```typescript
// 自定义验证规则
const validatePhone = (rule: any, value: any, callback: any) => {
  const reg = /^1[3-9]\d{9}$/
  if (!value) {
    callback(new Error('请输入手机号'))
  } else if (!reg.test(value)) {
    callback(new Error('请输入正确的手机号'))
  } else {
    callback()
  }
}

const rules = {
  phone: [
    { required: true, validator: validatePhone, trigger: 'blur' }
  ]
}
```

### 文件上传
```vue
<el-upload
  :action="uploadUrl"
  :headers="uploadHeaders"
  :on-success="handleUploadSuccess"
  :on-error="handleUploadError"
  :before-upload="beforeUpload"
>
  <el-button type="primary">点击上传</el-button>
</el-upload>

<script setup>
const beforeUpload = (file: File) => {
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('只能上传图片文件')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB')
    return false
  }
  return true
}
</script>
```

### 权限控制指令
```typescript
// directives/permission.ts
import { useUserStore } from '@/stores/user'

export default {
  mounted(el: HTMLElement, binding: any) {
    const { value } = binding
    const userStore = useUserStore()

    if (!userStore.hasPermission(value)) {
      el.parentNode?.removeChild(el)
    }
  }
}

// 使用
<el-button v-permission="'user:create'">创建用户</el-button>
```

---

## 与 React 技术栈的对比

| React 方案 | Vue 方案 | 说明 |
|------------|----------|------|
| useState | ref/reactive | Vue 的响应式更直观 |
| useEffect | watchEffect | Vue 的副作用处理更简洁 |
| Redux/Zustand | Pinia | Pinia 更轻量级 |
| MUI | Element Plus | Element Plus 更适合中后台 |
| styled-components | scoped style | Vue 的样式隔离更简单 |

---

## 最佳实践建议

1. **组件设计**
   - 使用 `<script setup>` 语法
   - 合理拆分组件，保持单一职责
   - 使用 TypeScript 增强类型安全

2. **性能优化**
   - 使用 `v-show` vs `v-if`
   - 合理使用 `computed` 和 `watch`
   - 路由懒加载
   - 组件异步加载

3. **工程化**
   - 使用 Vite 作为构建工具
   - 配置 ESLint + Prettier
   - 使用 husky + lint-staged

4. **团队协作**
   - 统一代码风格
   - 编写组件文档
   - 制定 Git 提交规范

---

## 相关资源

- [Vue 3 官方文档](https://cn.vuejs.org/)
- [Element Plus 文档](https://element-plus.org/zh-CN/)
- [Pinia 文档](https://pinia.vuejs.org/zh/)
- [Vite 文档](https://cn.vitejs.dev/)
- [Vue Router 文档](https://router.vuejs.org/zh/)