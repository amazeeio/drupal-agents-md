# AGENTS.md: AI Agent Guide for Drupal Development

**AI Agent Instructions**: This guide provides comprehensive instructions for AI coding agents working on Drupal projects using traditional server setups. Follow these guidelines for consistent, high-quality contributions. Human contributors should use README.md instead.

## Project Overview
- **Core Technology**: Drupal 10.x+ (verify via `composer show drupal/core`)
- **Key Components**: Custom modules, themes, configuration management, Composer dependencies
- **Environment**: PHP 8.1+, MySQL/PostgreSQL 8.0+, Apache/Nginx
- **Development Tools**: Composer, Drush 12+, Git
- **Important**: Always run commands from project root unless specified

## Quick Setup Commands

### Prerequisites
```bash
# System requirements
PHP 8.1+ with required extensions
MySQL 8.0+ or PostgreSQL 12+
Apache 2.4+ or Nginx 1.18+
Composer 2.0+
Drush 12+
```



## Code Style and Standards
Adhere to Drupal coding standards (PSR-12 with Drupal extensions). Use Coder and PHPCS for enforcement.

- **PHP**:
  - Indentation: 2 spaces (no tabs)
  - Line length: ≤ 80 characters
  - Naming: CamelCase classes/methods, snake_case variables/functions
  - Always use braces; prefer early returns
  - Full PHPDoc blocks with `@param`, `@return`, `@throws`

- **YAML**: 2-space indentation, lowercase keys
- **Twig**: `{{ }}` for output, `{% %}` for logic; always escape with `|e`

- **Linting**:
  ```bash
  vendor/bin/phpcs --standard=Drupal --extensions=php,inc,module,install,info,yml src/
  vendor/bin/phpcs --standard=DrupalPractice --extensions=php,inc,module,install,info,yml src/
  vendor/bin/phpcs --standard=Drupal --fix src/
  ```

**Reject any code that fails Drupal Coder sniffs.**

## Drupal Development Patterns

### Services & Dependency Injection
- **Create services** in `modulename.services.yml` file for reusable logic
- **Use dependency injection** to inject services into controllers, forms, and plugins
- **Core services** like `@current_user`, `@entity_type.manager`, `@database` are available
- **Best practice**: Avoid static `\Drupal::` calls in favor of dependency injection
- **Service discovery**: Use `drush eval "print_r(\Drupal::getContainer()->getServiceIds());"` to see available services
- **Location**: Place service classes in `src/` directory with proper namespace

### Entity API & Queries
- **Entity loading**: Use `Entity::load($id)` for single entities or `entityTypeManager()->getStorage()` for multiple
- **Entity queries**: Use `\Drupal::entityQuery()` for database operations instead of raw SQL
- **Query conditions**: Chain multiple conditions with `->condition()`, `->sort()`, `->range()`
- **Entity creation**: Create entities with `Entity::create(['type' => 'bundle_name'])`
- **Field access**: Use entity field API instead of direct property access
- **Performance**: Use entity query cache tags and contexts for optimal caching

### Plugin System
- **Plugin types**: Blocks, field formatters, field widgets, menu links, and more
- **Plugin discovery**: Use annotation-based discovery in docblocks
- **Plugin configuration**: Define plugin ID, label, and other metadata in annotations
- **Plugin base classes**: Extend appropriate base classes (BlockBase, FormatterBase, etc.)
- **Plugin placement**: Place plugins in `src/Plugin/Type/` directory structure
- **Derivative plugins**: Use for creating multiple plugins from one definition

### Hooks
- **Hook implementation**: Implement hooks in `modulename.module` file
- **Hook naming**: Follow pattern `hook_modulename_action()` for custom hooks
- **Hook parameters**: Use type hints and proper parameter documentation
- **Core hooks**: Common hooks include `hook_form_alter()`, `hook_theme()`, `hook_menu_links_discovered_alter()`
- **Hook order**: Hooks fire in module weight order (lowest first)
- **Best practice**: Keep hook implementations focused and use services for complex logic

### Forms API
- **Form classes**: Extend `FormBase` for simple forms or `ConfigFormBase` for configuration forms
- **Form structure**: Use render array structure with `#type`, `#title`, `#description` properties
- **Form validation**: Implement `validateForm()` method for custom validation
- **Form submission**: Implement `submitForm()` method for processing form data
- **Form elements**: Use proper form element types (textfield, select, checkbox, etc.)
- **AJAX forms**: Add `#ajax` property to form elements for dynamic behavior
- **Form caching**: Forms are automatically cached with CSRF protection

### Routes & Controllers
- **Routing file**: Define routes in `modulename.routing.yml` with path, defaults, and requirements
- **Controllers**: Create controller classes extending `ControllerBase` in `src/Controller/`
- **Route parameters**: Use `{parameter}` placeholders in paths and inject into controller methods
- **Access control**: Implement `_permission`, `_role`, or custom access callbacks
- **Route naming**: Use `modulename.action` naming convention for clarity
- **Controller injection**: Use constructor injection for dependencies
- **Return values**: Return render arrays or Symfony Response objects

## Security & Performance Guidelines

### Security Requirements
- **Always sanitize user input**: Use `#plain_text` for untrusted content
- **CSRF protection**: Include `#token` for forms with side effects
- **Permissions**: Implement proper access checks and route requirements
- **SQL Injection**: Use Entity Query or proper parameter binding
- **XSS Prevention**: Always use `|e` filter in Twig, `#markup` for trusted HTML only
- **File uploads**: Validate file types and sizes
- **Database credentials**: Never commit credentials to version control

### Performance Best Practices
- **Render caching**: Always add `#cache` array to render arrays with appropriate `tags` and `contexts`
- **Cache tags**: Use entity-based tags like `['node:123']` or list-based tags like `['node_list']`
- **Cache contexts**: Apply user-specific contexts like `['user.roles']` for personalized content
- **Lazy loading**: Use `#lazy_builder` for expensive operations that can be loaded separately
- **Placeholder strategy**: Set `#create_placeholder: TRUE` for lazy builders to improve initial page load
- **Cache max-age**: Set appropriate `max-age` values based on content freshness requirements
- **Avoid premature optimization**: Profile first, then optimize based on actual bottlenecks
- **Database queries**: Use entity queries instead of raw SQL for better caching and security
- **Entity loading**: Load multiple entities at once when possible for better performance

### Caching Strategies
- **Render cache**: Cache complex markup with proper tags/contexts
- **Dynamic page cache**: Configure for anonymous users
- **Internal page cache**: Enable for authenticated users
- **Entity cache**: Leverage core entity caching
- **Redis/Memcache**: Configure for distributed caching

### Server Optimization
```bash
# PHP configuration (php.ini)
memory_limit = 256M
max_execution_time = 300
upload_max_filesize = 64M
post_max_size = 64M

# MySQL configuration (my.cnf)
innodb_buffer_pool_size = 1G
query_cache_size = 64M
```

## Development Workflow

### Project Structure
- **Modules** → `modules/custom/<module_name>`
- **Themes** → `themes/custom/<theme_name>`
- **Configuration** → Export with `drush config:export`
- **Profiles** → `profiles/custom/<profile_name>`

### Essential Development Commands
```bash
# Cache management
drush cr                    # Clear all caches
drush cache:rebuild         # Alternative cache clear

# Configuration management
drush config:export         # Export configuration
drush config:import         # Import configuration
drush config:diff           # Compare config with directory

# Database operations
drush sql:dump              # Export database
drush sql:cli               # Access database CLI
drush updatedb              # Run database updates
```

### Debugging Tools

#### Core Debugging & Information Commands
| Command                          | Purpose                                                                 | Why it’s useful for debugging                                      |
|----------------------------------|-------------------------------------------------------------------------|--------------------------------------------------------------------|
| `drush status`                   | Shows Drupal root, site path, database connection, Drush version, etc. | Quickly verify that Drush is pointing to the correct site and DB is connected. |
| `drush core-status` (D8+)        | Same as above but more detailed in newer versions.                      |                                                                    |
| `drush watchdog:show` / `drush ws` | Lists recent log messages (dblog entries).                              | Primary command to read the Drupal error/log messages without going to /admin/reports/dblog. Supports filters: `--severity=Error`, `--type=php`, etc. |
| `drush watchdog:delete all`      | Clears the watchdog log.                                                | Useful when logs become huge and slow down `ws`.                   |
| `drush sql:query "SELECT * FROM watchdog ORDER BY wid DESC LIMIT 50"` | Direct SQL access to logs when the database is very large.             | Faster than `ws` on sites with millions of log entries.            |

#### Cache Debugging
| Command                          | Purpose                                                                 |
|----------------------------------|-------------------------------------------------------------------------|
| `drush cache:rebuild` / `drush cr` | Rebuilds all caches (equivalent to “drush cc all” in D7).              | Essential after any code or configuration change to ensure you’re not seeing cached behavior. |
| `drush cache:get <bin>:<cid>`    | Retrieve a specific cache item (e.g., `drush cache:get config:core.extension`). | Verify whether a particular cache entry is present or corrupted. |
| `drush cache:clear <bin>`        | Clear only one cache bin (render, config, discovery, etc.).            |

#### Configuration Debugging
| Command                                      | Purpose                                                                 |
|----------------------------------------------|-------------------------------------------------------------------------|
| `drush config:get <name>`                    | Show a single configuration value (e.g., `drush config:get system.site`). |
| `drush config:set <name> <key> <value>`      | Temporarily change a config value without using the UI.                 |
| `drush config:export` / `drush cex`          | Export active config to sync directory.                                 |
| `drush config:import` / `drush cim`          | Import config – very useful to test if config issues cause errors.      |
| `drush config:delete <name>`                 | Remove a config object (helps when orphaned config causes fatal errors).|

#### Module/Theming Debugging
| Command                                | Purpose                                                                 |
|----------------------------------------|-------------------------------------------------------------------------|
| `drush pm:list --type=module --status=enabled` | List enabled modules.                                                  |
| `drush pm:enable <module>` / `drush en <module>` | Enable a module.                                                       |
| `drush pm:uninstall <module>` / `drush puninstall <module>` | Fully uninstall a module (removes config and data).                    |
| `drush pm:uninstall` without arguments → interactive mode is excellent for disabling suspected problematic modules quickly. |
| `drush theme:debug` (Drupal 9.4+)      | Lists all theme suggestions for a given route or render array.         |

#### Database & Entity Debugging
| Command                                      | Purpose                                                                 |
|----------------------------------------------|-------------------------------------------------------------------------|
| `drush sql:connect`                          | Outputs the CLI command to connect to the DB (useful for manual queries). |
| `drush sql:query`                            | Run arbitrary SQL.                                                      |
| `drush entity:info`                          | Show entity type definitions (useful when entity schema errors occur). |
| `drush php`                                  | Opens an interactive PHP shell with Drupal bootstrapped (like `drush php:eval`). |
| `drush php:eval "code"`                      | Execute arbitrary PHP code in Drupal context (great for quick debugging). Example: `drush php:eval "dpm(\Drupal::state()->get('system.cron_last'));"` (with Devel) |

#### Development & Error Reproduction
| Command                                | Purpose                                                                 |
|----------------------------------------|-------------------------------------------------------------------------|
| `drush php:eval "var_dump(function_exists('my_problematic_function'));"` | Quick test if a function exists or what it returns.                     |
| `drush state:edit` / `drush state:get/set/delete` | Inspect or override Drupal state values (often used by broken modules).|
| `drush variable:get/set/delete` (D7 only) | Legacy equivalent of state commands.                                    |
| `drush twig:debug`                     | Turn Twig debugging on/off and verify template suggestions.            |
| `drush eval` (alias of php:eval)       | Same as above.                                                          |

#### Performance & Query Debugging
| Command                                | Purpose                                                                 |
|----------------------------------------|-------------------------------------------------------------------------|
| `drush sql:query --db-prefix`          | See queries with table prefixes expanded (helps reading raw SQL).      |
| Enable Devel + `drush kint` or `dpm()` in code → instant output in terminal. |                                                                 |

### Performance Profiling
```bash
# Performance analysis
drush cr                     # Rebuild caches
drush sql:query "EXPLAIN ANALYZE SELECT ..."  # Query analysis
drush site:status           # System status check

# Use Webprofiler module for detailed profiling
# Access at http://127.0.0.1:8888/admin/config/development/devel/webprofiler
```

### Version Control Workflow
- **Commit messages**: Format `[#123456] Brief descriptive title`
- **Branch from**: `develop` branch for features
- **Atomic commits**: One logical change per commit
- **Before pushing**: Run linting and tests

## Testing & Quality Assurance

### PHPUnit Testing Framework
Aim for ≥ 80% code coverage. Drupal provides multiple test types:

```bash
# Run all tests with coverage
vendor/bin/phpunit -v --coverage-html coverage/

# Run specific test suites
vendor/bin/phpunit --testsuite unit          # Unit tests (fast)
vendor/bin/phpunit --testsuite kernel         # Kernel tests
vendor/bin/phpunit --testsuite functional     # Functional tests (slower)
vendor/bin/phpunit --testsuite javascript     # JavaScript tests

# Run specific tests
vendor/bin/phpunit --filter MyModuleUnitTest
vendor/bin/phpunit modules/custom/my_module/tests/src/Unit/

# Run with custom configuration
SIMPLETEST_DB=sqlite://localhost/tmp.sqlite vendor/bin/phpunit
```

### Test Types and Examples

#### Unit Tests (fastest)
- **Purpose**: Test individual classes and methods in isolation
- **Base class**: Extend `UnitTestCase` from `Drupal\Tests\UnitTestCase`
- **Speed**: Fastest test type, no Drupal bootstrap required
- **Isolation**: Test one piece of functionality at a time
- **Dependencies**: Mock external dependencies and services
- **Location**: Place in `tests/src/Unit/` directory
- **Use cases**: Service logic calculations, utility functions, data transformations
- **Best practices**: Keep tests small, focused, and deterministic

#### Kernel Tests (with database)
- **Purpose**: Test Drupal interactions with minimal Drupal environment
- **Base class**: Extend `KernelTestBase` from `Drupal\KernelTests\KernelTestBase`
- **Environment**: Partial Drupal bootstrap with in-memory database
- **Modules**: Declare required modules in `$modules` static property
- **Database**: Uses SQLite in-memory database for speed
- **Location**: Place in `tests/src/Kernel/` directory
- **Use cases**: Entity CRUD operations, configuration validation, service registration
- **Setup**: Install modules and configuration in `setUp()` method

#### Functional Tests (with browser)
- **Purpose**: Test complete user interactions through browser simulation
- **Base class**: Extend `BrowserTestBase` from `Drupal\Tests\BrowserTestBase`
- **Environment**: Full Drupal bootstrap with real browser
- **Speed**: Slowest test type, full page loads required
- **Theme**: Set `$defaultTheme` property (usually 'stark' or 'claro')
- **Location**: Place in `tests/src/Functional/` directory
- **Use cases**: Form submissions, page access, user permissions, JavaScript interactions
- **Browser simulation**: Uses Goutte/ChromeDriver for browser automation
- **Assertions**: Use `$this->assertSession()` for web assertions

### Code Quality Tools
```bash
# Static analysis (add to composer require)
vendor/bin/phpstan analyse                      # PHPStan analysis
vendor/bin/psalm                               # Psalm analysis

# Security scanning
vendor/bin/drupal-check                        # Check for deprecated code
composer audit                                 # Check for security advisories

# Accessibility testing
vendor/bin/phpunit --group accessibility       # Accessibility tests
```

### JavaScript Testing
```bash
# Install JavaScript dependencies
npm install

# Run JavaScript tests
npm run test                                   # Jest tests
npm run test:a11y                             # Accessibility tests
```

### Before Submitting Code
```bash
# Quality checklist
vendor/bin/phpcs --standard=Drupal .          # Code style
vendor/bin/phpunit                             # Run tests
drush cr                                       # Clear caches
drush updatedb                                 # Run updates
```

## Pull Request Guidelines

### Before Opening PR
1. **Create feature branch**: `git checkout -b feature/issue-123`
2. **Run quality checks**:
   ```bash
   drush cr
   vendor/bin/phpcs --standard=Drupal .
   vendor/bin/phpcs --standard=DrupalPractice .
   vendor/bin/phpunit
   drush updatedb
   ```
3. **Test manually**: Verify the feature works as expected
4. **Check for regressions**: Ensure no existing functionality is broken

### PR Requirements
- **Title format**: `[#123456] Brief descriptive title`
- **Description must include**:
  - Problem statement and solution approach
  - Testing steps and verification methods
  - Screenshots for UI changes
  - Security considerations
  - Accessibility impact
  - Performance implications

### Review Process
- **Automated checks**: Code style, tests, security scanning
- **Manual review**: Architecture, best practices, maintainability
- **Approval required**: At least one maintainer approval

## Troubleshooting Common Issues

### Installation Problems
```bash
# Composer memory issues
php -d memory_limit=-1 /usr/local/bin/composer install

# Permission issues
chmod 755 sites/default/files
chmod 644 sites/default/settings.php
chown -R www-data:www-data sites/default/files

# Database connection failed
# Check settings.php and database server status
drush sql:connect  # Test database connection

# PHP extensions missing
php -m  # Check installed extensions
# Required: gd, xml, mbstring, json, pdo, curl
```

### Performance Issues
```bash
# Identify slow queries
drush sql:query "SELECT * FROM watchdog WHERE type = 'php' ORDER BY wid DESC LIMIT 10"

# Check cache settings
drush config:get system.performance

### Module/Theme Development Issues
```bash
drush cr

# Service not found
drush config:get core.extension

# Twig template not loading
drush cr

# Cron issues
drush cron
drush watchdog:show --type=cron
```

### Testing Issues
```bash
# PHPUnit configuration problems
# Ensure phpunit.xml.dist exists and is configured
cp web/core/phpunit.xml.dist phpunit.xml

# Database setup for testing
# Edit phpunit.xml for SIMPLETEST_DB and SIMPLETEST_BASE_URL
SIMPLETEST_DB=mysql://root:password@localhost/drupal_test
SIMPLETEST_BASE_URL=http://127.0.0.1:8888

# Browser tests failing
# Install Selenium or ChromeDriver
# Ensure test environment variables are set
```

## Advanced Development Patterns

### Batch API for Long Operations
- **Purpose**: Process large datasets without PHP timeout issues
- **Use cases**: Data migration, bulk updates, file processing, API calls
- **Batch structure**: Create associative array with title, operations, and finished callback
- **Operations**: Array of callable methods and their arguments
- **Progress tracking**: Automatically shows progress bar to users
- **Error handling**: Implement proper exception handling in batch operations
- **User experience**: Provides real-time feedback during long operations
- **Memory management**: Processes data in chunks to prevent memory exhaustion

### Queue API for Background Processing
- **Purpose**: Process tasks in the background without blocking user interaction
- **Queue creation**: Use `\Drupal::queue('queue_name')` to get queue instance
- **Item addition**: Use `createItem()` to add tasks to the queue
- **Processing**: Claim items with `claimItem()` and delete with `deleteItem()`
- **Cron integration**: Process queue items during cron runs for regular background tasks
- **Reliability**: Failed items can be released back to the queue
- **Worker plugins**: Create QueueWorker plugins for structured queue processing
- **Logging**: Implement proper logging for queue processing monitoring
- **Performance**: Process multiple items per cron run for efficiency

### AJAX Forms
- **Trigger elements**: Add `#ajax` property to form elements (select, checkbox, button)
- **Callback method**: Reference callback method using `::methodName` syntax
- **Wrapper element**: Specify target element ID for AJAX response replacement
- **Response format**: Return form element or render array from callback
- **Event types**: Use 'change', 'click', 'blur' events as needed
- **Progress indicator**: Automatically shows loading indicator during AJAX requests
- **Error handling**: Implement try-catch blocks in AJAX callbacks
- **Form state**: Use `$form_state->getTriggeringElement()` to identify trigger
- **Multiple triggers**: Can have multiple AJAX elements in same form
- **Dynamic forms**: Update form options, show/hide fields based on user input

## Additional Resources

### Official Documentation
- **Drupal API**: https://api.drupal.org
- **Developer Guide**: https://www.drupal.org/docs/develop
- **Coding Standards**: https://www.drupal.org/docs/develop/standards
- **Security Best Practices**: https://www.drupal.org/docs/develop/security

### Community Resources
- **DrupalAtYourFingertips**: https://www.drupalatyourfingertips.com
- **Drupal Answers**: https://drupal.stackexchange.com
- **Drupal.org**: https://www.drupal.org
- **Drupal Slack**: https://drupal.slack.com
