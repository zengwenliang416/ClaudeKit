# Vue 3 Patterns for Frontend Development

## Overview

This guide provides Vue 3 equivalents for React patterns, helping you work with both technologies.

## Component Patterns Comparison

### React Pattern
```jsx
function UserCard({ user, onEdit }) {
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    // side effect
  }, [user.id]);

  return (
    <Card>
      <Typography>{user.name}</Typography>
      <Button onClick={() => onEdit(user)}>Edit</Button>
    </Card>
  );
}
```

### Vue 3 Equivalent
```vue
<template>
  <el-card>
    <div>{{ user.name }}</div>
    <el-button @click="$emit('edit', user)">Edit</el-button>
  </el-card>
</template>

<script setup>
import { ref, watchEffect } from 'vue'

const props = defineProps(['user'])
const emit = defineEmits(['edit'])

const loading = ref(false)

watchEffect(() => {
  // side effect when user.id changes
})
</script>
```

## State Management Patterns

### Pinia Store (Vue)
```typescript
// stores/user.ts
export const useUserStore = defineStore('user', () => {
  const users = ref<User[]>([])
  const loading = ref(false)

  const fetchUsers = async () => {
    loading.value = true
    try {
      const res = await api.getUsers()
      users.value = res.data
    } finally {
      loading.value = false
    }
  }

  return { users, loading, fetchUsers }
})
```

### Usage in Component
```vue
<script setup>
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()
await userStore.fetchUsers()
</script>
```

## Form Handling

### Element Plus Form
```vue
<template>
  <el-form ref="formRef" :model="form" :rules="rules">
    <el-form-item label="Email" prop="email">
      <el-input v-model="form.email" />
    </el-form-item>
    <el-form-item>
      <el-button type="primary" @click="submitForm">Submit</el-button>
    </el-form-item>
  </el-form>
</template>

<script setup>
import { reactive, ref } from 'vue'

const formRef = ref()
const form = reactive({
  email: ''
})

const rules = {
  email: [
    { required: true, message: 'Please input email' },
    { type: 'email', message: 'Invalid email' }
  ]
}

const submitForm = async () => {
  await formRef.value.validate()
  // submit logic
}
</script>
```

## Data Fetching Patterns

### Composable for API Calls
```typescript
// composables/useApi.ts
export function useApi<T>(url: string) {
  const data = ref<T | null>(null)
  const loading = ref(false)
  const error = ref<Error | null>(null)

  const fetch = async () => {
    loading.value = true
    error.value = null
    try {
      const response = await axios.get(url)
      data.value = response.data
    } catch (e) {
      error.value = e as Error
    } finally {
      loading.value = false
    }
  }

  return { data, loading, error, fetch }
}
```

### Usage
```vue
<script setup>
const { data: users, loading, fetch } = useApi('/api/users')
onMounted(() => fetch())
</script>
```

## Routing Patterns

### Vue Router Setup
```typescript
// router/index.ts
const routes = [
  {
    path: '/',
    component: MainLayout,
    children: [
      {
        path: 'users',
        component: () => import('@/views/Users.vue'),
        meta: { requiresAuth: true }
      }
    ]
  }
]

// Route guard
router.beforeEach((to, from, next) => {
  const userStore = useUserStore()
  if (to.meta.requiresAuth && !userStore.isLoggedIn) {
    next('/login')
  } else {
    next()
  }
})
```

## UI Component Library Integration

### Element Plus Table
```vue
<template>
  <el-table :data="tableData" v-loading="loading">
    <el-table-column prop="name" label="Name" />
    <el-table-column prop="email" label="Email" />
    <el-table-column label="Actions">
      <template #default="{ row }">
        <el-button @click="handleEdit(row)">Edit</el-button>
      </template>
    </el-table-column>
  </el-table>
</template>
```

### Ant Design Vue Alternative
```vue
<template>
  <a-table :columns="columns" :data-source="data" :loading="loading">
    <template #action="{ record }">
      <a-button @click="handleEdit(record)">Edit</a-button>
    </template>
  </a-table>
</template>
```

## Performance Optimization

### Component Lazy Loading
```typescript
// Async component
const UserProfile = defineAsyncComponent(() =>
  import('./UserProfile.vue')
)
```

### Virtual List for Large Data
```vue
<template>
  <virtual-list :data-sources="items" :data-key="'id'">
    <template v-slot="{ source }">
      <user-item :user="source" />
    </template>
  </virtual-list>
</template>
```

## Testing Patterns

### Vitest Component Test
```typescript
import { mount } from '@vue/test-utils'
import UserCard from '@/components/UserCard.vue'

describe('UserCard', () => {
  it('displays user name', () => {
    const wrapper = mount(UserCard, {
      props: {
        user: { id: 1, name: 'John' }
      }
    })

    expect(wrapper.text()).toContain('John')
  })
})
```

## Common Pitfalls & Solutions

### Reactivity Issues
```javascript
// ❌ Won't trigger updates
const user = { name: 'John' }
user.name = 'Jane'

// ✅ Reactive
const user = reactive({ name: 'John' })
user.name = 'Jane'

// ✅ Or use ref
const user = ref({ name: 'John' })
user.value.name = 'Jane'
```

### v-model with Components
```vue
<!-- Parent -->
<custom-input v-model="searchText" />

<!-- Child component -->
<template>
  <input
    :value="modelValue"
    @input="$emit('update:modelValue', $event.target.value)"
  />
</template>

<script setup>
defineProps(['modelValue'])
defineEmits(['update:modelValue'])
</script>
```