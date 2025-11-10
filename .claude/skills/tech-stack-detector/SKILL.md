---
name: tech-stack-detector
version: 1.0.0
description: Intelligent tech stack detection and guidance router. Automatically detects project technology stack (React/Vue, Express/Spring/Egg) and provides appropriate development guidelines. Use this when starting work on any project to ensure correct tech-specific guidance.
priority: critical
tags: [detection, routing, vue, react, spring-boot, eggjs, china-tech-stack]
---

# Tech Stack Detector

## Purpose

Automatically detect your project's technology stack and provide the most relevant development guidelines. Supports both international (React/Express) and China-preferred (Vue/Spring Boot) tech stacks.

## When to Use This Skill

This skill automatically activates when:
- Starting work on a new project
- Unsure which development guidelines to follow
- Working with mixed technology stacks
- Switching between different projects

---

## Quick Detection

### Frontend Stack Detection

```javascript
// Auto-detection logic
if (package.json.dependencies.vue) → Vue guidelines
if (package.json.dependencies.react) → React guidelines
if (*.vue files exist) → Vue project
if (*.tsx files exist) → React project
```

### Backend Stack Detection

```javascript
// Auto-detection logic
if (pom.xml exists) → Spring Boot (Java)
if (package.json.dependencies.egg) → Egg.js
if (package.json.dependencies.express) → Express
if (package.json.dependencies["@nestjs/core"]) → NestJS
```

---

## Tech Stack Routing Map

### Frontend Development

| Detected Stack | Recommended Guidelines | Key Patterns |
|---------------|----------------------|--------------|
| **React + MUI** | Use existing `frontend-dev-guidelines` | Hooks, JSX, styled-components |
| **Vue 3 + Element Plus** | See Vue section below | Composition API, Template syntax |
| **Vue 2** | See Vue 2 legacy section | Options API |
| **Angular** | See Angular section | RxJS, Decorators |

### Backend Development

| Detected Stack | Recommended Guidelines | Key Patterns |
|---------------|----------------------|--------------|
| **Express + Prisma** | Use existing `backend-dev-guidelines` | Middleware, async/await |
| **Spring Boot** | See Spring Boot section below | @RestController, @Service |
| **Egg.js** | See Egg.js section below | Controller/Service pattern |
| **NestJS** | See NestJS section below | Decorators, DI |

---

## Vue 3 Development Guidelines

### Project Setup
```bash
npm create vue@latest
# Choose: TypeScript, Vue Router, Pinia, Vitest
npm install element-plus @element-plus/icons-vue
```

### Component Pattern (Vue 3 Composition API)
```vue
<template>
  <el-card>
    <el-form :model="form" :rules="rules">
      <el-form-item label="Name" prop="name">
        <el-input v-model="form.name" />
      </el-form-item>
    </el-form>
  </el-card>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'

// Compare with React:
// React: const [form, setForm] = useState({})
// Vue:   const form = reactive({})

const form = reactive({
  name: ''
})

const rules = {
  name: [{ required: true, message: 'Required' }]
}

// Compare with React:
// React: const handleSubmit = () => {}
// Vue:   const handleSubmit = () => {} (same!)

const handleSubmit = () => {
  ElMessage.success('Submitted')
}
</script>
```

### State Management (Pinia vs Redux)
```typescript
// stores/user.ts - Pinia approach
export const useUserStore = defineStore('user', () => {
  const user = ref(null)
  const isLoggedIn = computed(() => !!user.value)

  const login = async (credentials) => {
    const res = await api.login(credentials)
    user.value = res.data
  }

  return { user, isLoggedIn, login }
})

// Usage in component (much simpler than Redux!)
const userStore = useUserStore()
await userStore.login({ username, password })
```

---

## Spring Boot Development Guidelines

### Project Structure
```
src/main/java/com/example/
├── controller/
│   └── UserController.java
├── service/
│   ├── UserService.java
│   └── impl/UserServiceImpl.java
├── mapper/
│   └── UserMapper.java
├── entity/
│   └── User.java
└── common/
    └── Result.java
```

### Controller Pattern
```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    // Compare with Express:
    // Express: router.get('/users', (req, res) => {})
    // Spring:  @GetMapping with method

    @GetMapping
    public Result<List<User>> list(
        @RequestParam(defaultValue = "1") Integer page,
        @RequestParam(defaultValue = "10") Integer size
    ) {
        PageInfo<User> pageInfo = userService.findPage(page, size);
        return Result.success(pageInfo);
    }

    @PostMapping
    public Result<User> create(@RequestBody @Valid UserDTO dto) {
        User user = userService.create(dto);
        return Result.success(user);
    }

    @PutMapping("/{id}")
    public Result<Void> update(
        @PathVariable Long id,
        @RequestBody @Valid UserDTO dto
    ) {
        userService.update(id, dto);
        return Result.success();
    }
}
```

### Service Layer
```java
@Service
@Slf4j
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;

    @Override
    @Transactional
    public User create(UserDTO dto) {
        // Compare with Node.js:
        // Node: await prisma.user.create({ data: dto })
        // Spring: mapper + entity

        User user = new User();
        BeanUtils.copyProperties(dto, user);
        userMapper.insert(user);
        return user;
    }
}
```

---

## Egg.js Development Guidelines

### Directory Structure
```
app/
├── controller/
│   └── user.js
├── service/
│   └── user.js
├── middleware/
│   └── auth.js
├── model/
│   └── user.js
└── router.js
```

### Controller Pattern
```javascript
// app/controller/user.js
module.exports = app => {
  class UserController extends app.Controller {
    // Compare with Express:
    // Express: router.get('/users', async (req, res) => {})
    // Egg:     class method with ctx

    async index() {
      const { ctx } = this;
      const { page = 1, size = 10 } = ctx.query;

      const result = await ctx.service.user.list(page, size);
      ctx.body = {
        code: 0,
        data: result,
        message: 'success'
      };
    }

    async create() {
      const { ctx } = this;

      // Validation (similar to Zod in Express)
      ctx.validate({
        username: { type: 'string', required: true },
        email: { type: 'email', required: true }
      });

      const user = await ctx.service.user.create(ctx.request.body);
      ctx.body = { code: 0, data: user };
    }
  }

  return UserController;
};
```

---

## NestJS Development Guidelines

### Module Architecture
```typescript
// user.module.ts
@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UserController],
  providers: [UserService],
  exports: [UserService]
})
export class UserModule {}
```

### Controller with Decorators
```typescript
@Controller('users')
@UseGuards(AuthGuard)
export class UserController {
  constructor(private userService: UserService) {}

  // Compare with Express:
  // Express: router.get('/users', middleware, handler)
  // NestJS:  @Get() with @UseGuards()

  @Get()
  @UseInterceptors(CacheInterceptor)
  async findAll(@Query() query: PageDto) {
    return this.userService.findAll(query);
  }

  @Post()
  @UsePipes(ValidationPipe)
  async create(@Body() dto: CreateUserDto) {
    return this.userService.create(dto);
  }
}
```

---

## Tech Stack Comparison Matrix

### Frontend Comparison

| Feature | React | Vue 3 | When to Use |
|---------|--------|--------|------------|
| **State** | `useState()` | `ref()`/`reactive()` | Vue is more intuitive |
| **Effects** | `useEffect()` | `watchEffect()` | Vue is cleaner |
| **Component** | JSX | Template | Vue separates concerns |
| **Props** | `props.value` | `props.value` | Same concept |
| **Events** | `onChange` | `@change` | Vue uses @ prefix |
| **Conditional** | `{show && <div>}` | `v-if` / `v-show` | Vue is more readable |
| **List** | `map()` | `v-for` | Vue is more declarative |
| **Style** | CSS-in-JS | `<style scoped>` | Vue is simpler |

### Backend Comparison

| Feature | Express | Spring Boot | Egg.js |
|---------|---------|-------------|---------|
| **Routing** | `router.get()` | `@GetMapping` | Controller methods |
| **Middleware** | `app.use()` | Interceptors | `middleware/` |
| **Validation** | Zod | `@Valid` | `ctx.validate()` |
| **DI** | Manual | `@Autowired` | Built-in |
| **ORM** | Prisma | MyBatis/JPA | Sequelize |
| **Config** | `.env` | `application.yml` | `config/` |

---

## Smart Detection Algorithm

```typescript
// This runs automatically when you start working
async function detectTechStack() {
  const detection = {
    frontend: 'unknown',
    backend: 'unknown',
    ui: 'unknown',
    database: 'unknown'
  };

  // Check package.json
  if (await fileExists('package.json')) {
    const pkg = await readJSON('package.json');

    // Frontend detection
    if (pkg.dependencies?.vue || pkg.devDependencies?.vue) {
      detection.frontend = 'vue3';
      if (pkg.dependencies?.['element-plus']) {
        detection.ui = 'element-plus';
      }
    } else if (pkg.dependencies?.react) {
      detection.frontend = 'react';
      if (pkg.dependencies?.['@mui/material']) {
        detection.ui = 'mui';
      }
    }

    // Backend detection
    if (pkg.dependencies?.express) {
      detection.backend = 'express';
    } else if (pkg.dependencies?.egg) {
      detection.backend = 'egg';
    } else if (pkg.dependencies?.['@nestjs/core']) {
      detection.backend = 'nestjs';
    }
  }

  // Java project detection
  if (await fileExists('pom.xml')) {
    detection.backend = 'spring-boot';
    detection.database = 'mybatis';
  }

  // File-based detection
  const hasVueFiles = await globMatch('**/*.vue');
  const hasTsxFiles = await globMatch('**/*.tsx');

  if (hasVueFiles && detection.frontend === 'unknown') {
    detection.frontend = 'vue3';
  }
  if (hasTsxFiles && detection.frontend === 'unknown') {
    detection.frontend = 'react';
  }

  return detection;
}
```

---

## Usage Examples

### Scenario 1: Vue Developer
```
User: "Create a user list component"
Detector: ✓ Detected Vue 3 + Element Plus
Response: Here's a Vue 3 component with el-table...
```

### Scenario 2: Spring Boot Developer
```
User: "Create user CRUD API"
Detector: ✓ Detected Spring Boot project
Response: Here's the @RestController pattern...
```

### Scenario 3: Mixed Stack
```
User: "Setup full-stack project"
Detector: ✓ Detected: Vue 3 frontend + Spring Boot backend
Response: Here's the recommended structure...
```

---

## Progressive Disclosure

For detailed information about specific stacks, see:
- [Vue 3 Patterns](resources/vue3-patterns.md)
- [Spring Boot Patterns](resources/spring-patterns.md)
- [Egg.js Patterns](resources/eggjs-patterns.md)
- [Tech Migration Guide](resources/migration-guide.md)

---

## Key Takeaway

**You don't need to specify your tech stack** - this detector figures it out automatically and provides the right guidelines for your specific technology choices.