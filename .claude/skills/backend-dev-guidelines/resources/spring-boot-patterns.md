# Spring Boot Patterns for Backend Development

## Overview

Spring Boot patterns for developers familiar with Node.js/Express patterns.

## Controller Layer Comparison

### Express Pattern
```javascript
// routes/user.js
router.get('/users', async (req, res) => {
  try {
    const users = await userService.findAll(req.query);
    res.json({ success: true, data: users });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});
```

### Spring Boot Equivalent
```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping
    public ResponseEntity<Result<List<User>>> getUsers(
        @RequestParam(required = false) String keyword,
        @RequestParam(defaultValue = "1") int page,
        @RequestParam(defaultValue = "10") int size
    ) {
        PageHelper.startPage(page, size);
        List<User> users = userService.findAll(keyword);
        PageInfo<User> pageInfo = new PageInfo<>(users);
        return ResponseEntity.ok(Result.success(pageInfo));
    }

    @PostMapping
    public ResponseEntity<Result<User>> createUser(
        @RequestBody @Valid UserDTO userDTO
    ) {
        User user = userService.create(userDTO);
        return ResponseEntity.ok(Result.success(user));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Result<User>> updateUser(
        @PathVariable Long id,
        @RequestBody @Valid UserDTO userDTO
    ) {
        User user = userService.update(id, userDTO);
        return ResponseEntity.ok(Result.success(user));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Result<Void>> deleteUser(@PathVariable Long id) {
        userService.delete(id);
        return ResponseEntity.ok(Result.success());
    }
}
```

## Service Layer Patterns

### Spring Boot Service
```java
@Service
@Slf4j
@Transactional
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public User create(UserDTO dto) {
        // Check if user exists
        if (userMapper.existsByEmail(dto.getEmail())) {
            throw new BusinessException("Email already exists");
        }

        // Create user entity
        User user = new User();
        BeanUtils.copyProperties(dto, user);
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setCreatedAt(LocalDateTime.now());

        // Save to database
        userMapper.insert(user);
        log.info("User created with ID: {}", user.getId());

        return user;
    }

    @Override
    @Cacheable(value = "users", key = "#id")
    public User findById(Long id) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new ResourceNotFoundException("User not found");
        }
        return user;
    }
}
```

## Database Access Patterns

### MyBatis Mapper
```java
@Mapper
public interface UserMapper {

    @Select("SELECT * FROM users WHERE id = #{id}")
    User selectById(Long id);

    @Select("SELECT * FROM users")
    List<User> selectAll();

    @Insert("INSERT INTO users(username, email, password, created_at) " +
            "VALUES(#{username}, #{email}, #{password}, #{createdAt})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(User user);

    @Update("UPDATE users SET username=#{username}, email=#{email} " +
            "WHERE id=#{id}")
    int update(User user);

    @Delete("DELETE FROM users WHERE id = #{id}")
    int deleteById(Long id);
}
```

### MyBatis XML Mapper (for complex queries)
```xml
<!-- resources/mapper/UserMapper.xml -->
<mapper namespace="com.example.mapper.UserMapper">

    <resultMap id="userResultMap" type="com.example.entity.User">
        <id property="id" column="id"/>
        <result property="username" column="username"/>
        <collection property="roles" ofType="com.example.entity.Role">
            <id property="id" column="role_id"/>
            <result property="name" column="role_name"/>
        </collection>
    </resultMap>

    <select id="selectUserWithRoles" resultMap="userResultMap">
        SELECT u.*, r.id as role_id, r.name as role_name
        FROM users u
        LEFT JOIN user_roles ur ON u.id = ur.user_id
        LEFT JOIN roles r ON ur.role_id = r.id
        WHERE u.id = #{id}
    </select>

    <select id="searchUsers" resultType="com.example.entity.User">
        SELECT * FROM users
        <where>
            <if test="keyword != null and keyword != ''">
                AND (username LIKE CONCAT('%', #{keyword}, '%')
                OR email LIKE CONCAT('%', #{keyword}, '%'))
            </if>
            <if test="status != null">
                AND status = #{status}
            </if>
        </where>
        ORDER BY created_at DESC
    </select>
</mapper>
```

## Request Validation

### Using Bean Validation
```java
// DTO with validation
public class UserDTO {

    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50, message = "Username must be 3-50 characters")
    private String username;

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Password is required")
    @Pattern(regexp = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{8,}$",
             message = "Password must contain at least 8 characters, 1 number, 1 uppercase and 1 lowercase")
    private String password;

    @Min(value = 0, message = "Age must be positive")
    @Max(value = 150, message = "Age must be less than 150")
    private Integer age;

    // getters and setters
}

// Custom validator
@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = UniqueEmailValidator.class)
public @interface UniqueEmail {
    String message() default "Email already exists";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}
```

## Exception Handling

### Global Exception Handler
```java
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<Result<?>> handleBusinessException(BusinessException e) {
        log.error("Business exception: {}", e.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
            .body(Result.error(e.getMessage()));
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<Result<?>> handleNotFoundException(ResourceNotFoundException e) {
        log.error("Resource not found: {}", e.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(Result.error(e.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Result<?>> handleValidationException(MethodArgumentNotValidException e) {
        Map<String, String> errors = new HashMap<>();
        e.getBindingResult().getFieldErrors().forEach(error ->
            errors.put(error.getField(), error.getDefaultMessage())
        );
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
            .body(Result.error("Validation failed", errors));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Result<?>> handleGeneralException(Exception e) {
        log.error("Unexpected error", e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(Result.error("Internal server error"));
    }
}
```

## Authentication & Security

### JWT Authentication with Spring Security
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;

    @Autowired
    private JwtRequestFilter jwtRequestFilter;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint(jwtAuthenticationEntryPoint)
            )
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            );

        http.addFilterBefore(jwtRequestFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
```

## Caching with Redis

### Redis Configuration
```java
@Configuration
@EnableCaching
public class RedisConfig {

    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory factory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(factory);

        // JSON serialization
        Jackson2JsonRedisSerializer<Object> jackson2JsonRedisSerializer =
            new Jackson2JsonRedisSerializer<>(Object.class);

        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(jackson2JsonRedisSerializer);
        template.setHashKeySerializer(new StringRedisSerializer());
        template.setHashValueSerializer(jackson2JsonRedisSerializer);

        return template;
    }

    @Bean
    public CacheManager cacheManager(RedisConnectionFactory factory) {
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(10))
            .disableCachingNullValues();

        return RedisCacheManager.builder(factory)
            .cacheDefaults(config)
            .build();
    }
}

// Usage in service
@Cacheable(value = "users", key = "#id")
public User findById(Long id) {
    return userMapper.selectById(id);
}

@CacheEvict(value = "users", key = "#user.id")
public void update(User user) {
    userMapper.update(user);
}
```

## Testing Patterns

### Unit Testing with JUnit 5
```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserMapper userMapper;

    @InjectMocks
    private UserServiceImpl userService;

    @Test
    void testCreateUser() {
        // Given
        UserDTO dto = new UserDTO();
        dto.setUsername("testuser");
        dto.setEmail("test@example.com");

        when(userMapper.existsByEmail(anyString())).thenReturn(false);
        when(userMapper.insert(any(User.class))).thenReturn(1);

        // When
        User result = userService.create(dto);

        // Then
        assertNotNull(result);
        assertEquals("testuser", result.getUsername());
        verify(userMapper, times(1)).insert(any(User.class));
    }
}
```

### Integration Testing
```java
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void testGetUsers() throws Exception {
        mockMvc.perform(get("/api/users")
                .param("page", "1")
                .param("size", "10"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.success").value(true))
            .andExpect(jsonPath("$.data").isArray());
    }

    @Test
    void testCreateUser() throws Exception {
        String userJson = """
            {
                "username": "newuser",
                "email": "new@example.com",
                "password": "Password123"
            }
            """;

        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(userJson))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.success").value(true))
            .andExpect(jsonPath("$.data.username").value("newuser"));
    }
}
```

## Common Utilities

### Unified Response Format
```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Result<T> {
    private boolean success;
    private String message;
    private T data;
    private Map<String, Object> extra;

    public static <T> Result<T> success() {
        return new Result<>(true, "Success", null, null);
    }

    public static <T> Result<T> success(T data) {
        return new Result<>(true, "Success", data, null);
    }

    public static <T> Result<T> error(String message) {
        return new Result<>(false, message, null, null);
    }

    public static <T> Result<T> error(String message, Map<String, Object> extra) {
        return new Result<>(false, message, null, extra);
    }
}
```

### Application Configuration
```yaml
# application.yml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/mydb?useSSL=false&serverTimezone=UTC
    username: root
    password: password
    driver-class-name: com.mysql.cj.jdbc.Driver

  redis:
    host: localhost
    port: 6379
    timeout: 2000ms
    lettuce:
      pool:
        max-active: 8
        max-idle: 8
        min-idle: 0

mybatis:
  mapper-locations: classpath:mapper/*.xml
  type-aliases-package: com.example.entity
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl

logging:
  level:
    com.example: DEBUG
    org.springframework.web: INFO
```