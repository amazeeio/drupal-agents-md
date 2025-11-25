# AGENTS.md: AI Agent Guide for Drupal Development with DDEV

**AI Agent Instructions**: This guide provides comprehensive instructions for AI coding agents working on Drupal projects using DDEV. Follow these guidelines for consistent, high-quality contributions. Human contributors should use README.md instead.

## Project Overview
- **Core Technology**: Drupal 10.x+ (verify via `composer show drupal/core`)
- **Development Environment**: DDEV (Docker-based development environment)
- **Key Components**: Custom modules, themes, configuration management, Composer dependencies
- **Environment**: PHP 8.1+, MySQL/MariaDB, Nginx (all managed by DDEV)
- **Development Tools**: Composer, Drush 12+, Git, DDEV CLI
- **Important**: All DDEV commands should be run from project root. Use `ddev exec` for Drupal-specific commands.

## DDEV Quick Setup

### Prerequisites
```bash
# Install DDEV (macOS)
brew install ddev/ddev/ddev

# Or download from https://ddev.readthedocs.io/en/stable/users/installation/
# Verify installation
ddev --version
```

### Initialize DDEV Project
```bash
# Clone the repository
git clone <repository-url> my-drupal-project
cd my-drupal-project

# Initialize DDEV configuration
ddev config --project-type=drupal --docroot=web --php-version=8.1

# Start DDEV environment
ddev start

# Install Composer dependencies
ddev composer install

# Install Drupal
ddev exec drush site:install standard \
  --db-url=mysql://db:db@db/db \
  --account-name=admin \
  --account-pass=admin \
  --yes

# Enable development modules
ddev exec drush pm:enable devel kint webprofiler -y

# Clear caches
ddev exec drush cr

# Launch site in browser
ddev launch
```

### Essential DDEV Commands
```bash
# Environment management
ddev start                # Start development environment
ddev stop                 # Stop environment
ddev restart              # Restart environment
ddev delete               # Delete environment (careful!)

# Database operations
ddev snapshot             # Create database snapshot
ddev restore-snapshot     # Restore database snapshot
ddev import-db            # Import database from file
ddev export-db            # Export database to file

# Development tools
ddev exec <command>       # Execute command in container
ddev ssh                  # SSH into web container
ddev logs                 # View container logs
ddev describe             # Show environment details
ddev launch               # Open site in browser
```

### DDEV Configuration
Create `.ddev/config.yaml` for project-specific settings:

```yaml
# .ddev/config.yaml
type: drupal
docroot: web
php_version: "8.1"
webserver_type: nginx-fpm
router_http_port: "80"
router_https_port: "443"
xdebug_enabled: false
additional_hostnames: []
additional_fqdns: []

# Drupal-specific settings
disable_settings_management: false
web_environment:
  - DRUSH_OPTIONS_URI=https://my-drupal-project.ddev.site
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
  ddev exec vendor/bin/phpcs --standard=Drupal --extensions=php,inc,module,install,info,yml src/
  ddev exec vendor/bin/phpcs --standard=DrupalPractice --extensions=php,inc,module,install,info,yml src/
  ddev exec vendor/bin/phpcs --standard=Drupal --fix src/
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

## DDEV Development Workflow

### Project Structure
- **Modules** → `web/modules/custom/<module_name>`
- **Themes** → `web/themes/custom/<theme_name>`
- **Configuration** → Export with `ddev exec drush config:export`
- **Profiles** → `web/profiles/custom/<profile_name>`

### Essential Development Commands
```bash
# Cache management (run inside DDEV)
ddev exec drush cr                    # Clear all caches
ddev exec drush cache:rebuild         # Alternative cache clear

# Configuration management
ddev exec drush config:export         # Export configuration
ddev exec drush config:import         # Import configuration

# Database operations
ddev snapshot                         # Create snapshot before changes
ddev exec drush updatedb              # Run database updates
```

### Debugging in DDEV
```bash
# Enable debugging in sites/development.services.yml
# Add to .ddev/config.yaml:
# xdebug_enabled: true

# Debugging functions (use with devel module)
ddev exec php -r "kint(\Drupal::config('system.site')->get());"

# Log monitoring
ddev logs -f web                       # Follow web container logs
ddev exec drush watchdog:show --tail   # View watchdog logs

# Access PHP error logs
ddev exec tail -f /var/log/apache2/error.log
```

### Performance Profiling in DDEV
```bash
# Performance analysis
ddev exec drush cr                     # Rebuild caches
ddev exec drush sql:query "EXPLAIN ANALYZE SELECT ..."  # Query analysis
ddev exec drush site:status           # System status check

# Use Webprofiler module for detailed profiling
# Access at https://my-drupal-project.ddev.site/admin/config/development/devel/webprofiler
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
ddev exec vendor/bin/phpunit -v --coverage-html coverage/

# Run specific test suites
ddev exec vendor/bin/phpunit --testsuite unit          # Unit tests (fast)
ddev exec vendor/bin/phpunit --testsuite kernel         # Kernel tests
ddev exec vendor/bin/phpunit --testsuite functional     # Functional tests (slower)
ddev exec vendor/bin/phpunit --testsuite javascript     # JavaScript tests

# Run specific tests
ddev exec vendor/bin/phpunit --filter MyModuleUnitTest
ddev exec vendor/bin/phpunit web/modules/custom/my_module/tests/src/Unit/

# Run with custom configuration
SIMPLETEST_DB=sqlite://localhost/tmp.sqlite ddev exec vendor/bin/phpunit
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

### Code Quality Tools in DDEV
```bash
# Static analysis (add to composer require)
ddev exec vendor/bin/phpstan analyse                      # PHPStan analysis
ddev exec vendor/bin/psalm                               # Psalm analysis

# Security scanning
ddev exec vendor/bin/drupal-check                        # Check for deprecated code
ddev exec composer audit                                 # Check for security advisories

# Accessibility testing
ddev exec vendor/bin/phpunit --group accessibility       # Accessibility tests
```

### JavaScript Testing
```bash
# Install JavaScript dependencies
ddev exec npm install

# Run JavaScript tests
ddev exec npm run test                                   # Jest tests
ddev exec npm run test:a11y                             # Accessibility tests
```

### Before Submitting Code
```bash
# Quality checklist
ddev exec vendor/bin/phpcs --standard=Drupal .          # Code style
ddev exec vendor/bin/phpunit                             # Run tests
ddev exec drush cr                                       # Clear caches
ddev exec drush updatedb                                 # Run updates
```

## DDEV-Specific Troubleshooting

### Common DDEV Issues
```bash
# DDEV won't start
ddev poweroff && ddev start

# Port conflicts
# Edit .ddev/config.yaml to change ports
router_http_port: "8080"
router_https_port: "8443"

# Memory issues
# Increase PHP memory in .ddev/php/php.ini
memory_limit = 512M

# Composer memory issues
ddev exec php -d memory_limit=-1 /usr/local/bin/composer install

# Database connection issues
ddev describe    # Check environment status
ddev exec drush sql:connect  # Test database connection
```

### Performance Issues in DDEV
```bash
# Identify slow queries
ddev exec drush sql:query "SELECT * FROM watchdog WHERE type = 'php' ORDER BY wid DESC LIMIT 10"

# Check cache settings
ddev exec drush config:get system.performance

# Enable performance modules
ddev exec drush pm:enable memcache redis -y
```

### Testing Issues in DDEV
```bash
# PHPUnit configuration problems
# Ensure phpunit.xml.dist exists and is configured
cp web/core/phpunit.xml.dist phpunit.xml

# Database setup for testing
# Edit phpunit.xml for SIMPLETEST_DB and SIMPLETEST_BASE_URL
SIMPLETEST_DB=mysql://db:db@db/db_test
SIMPLETEST_BASE_URL=http://my-drupal-project.ddev.site
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

### DDEV Documentation
- **DDEV Official Docs**: https://ddev.readthedocs.io
- **DDEV Quick Start**: https://ddev.readthedocs.io/en/stable/users/quickstart/
- **DDEV Drupal Guide**: https://ddev.readthedocs.io/en/stable/users/topics/drupal/

### Drupal Documentation
- **Drupal API**: https://api.drupal.org
- **Developer Guide**: https://www.drupal.org/docs/develop
- **Coding Standards**: https://www.drupal.org/docs/develop/standards
- **Security Best Practices**: https://www.drupal.org/docs/develop/security

### Community Resources
- **DrupalAtYourFingertips**: https://www.drupalatyourfingertips.com
- **Drupal Answers**: https://drupal.stackexchange.com
- **Drupal.org**: https://www.drupal.org
- **Drupal Slack**: https://drupal.slack.com

### Essential Tools
- **Drush**: `ddev exec drush help` - Command-line interface
- **Drupal Check**: `ddev exec drupal-check` - Deprecated code detection
- **Webprofiler**: Development toolbar and profiling
- **Composer**: `ddev exec composer` - Package management
