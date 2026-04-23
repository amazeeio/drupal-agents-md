# AGENTS.md: AI Agent Guide for Drupal Development

**AI Agent Instructions**: This guide provides comprehensive instructions for AI coding agents working on Drupal projects using traditional server setups. Follow these guidelines for consistent, high-quality contributions. Human contributors should use README.md instead.

## Table of Contents

- [Project Overview](#project-overview)
- [Prerequisites](#prerequisites)
- [Module Scaffolding Template](#module-scaffolding-template)
- [Code Style and Standards](#code-style-and-standards)
- [Drupal Development Patterns](#drupal-development-patterns)
- [Security & Performance Guidelines](#security--performance-guidelines)
- [Anti-Patterns — Never Do This](#anti-patterns--never-do-this)
- [Testing & Quality Assurance](#testing--quality-assurance)
- [Development Workflow](#development-workflow)
- [Advanced Development Patterns](#advanced-development-patterns)
- [Additional Topics](#additional-topics)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)

## Project Overview
- **Core Technology**: Drupal 10.x / 11.x (verify via `composer show drupal/core`)
- **Key Components**: Custom modules, themes, configuration management, Composer dependencies
- **Environment**: PHP 8.3+, MySQL/PostgreSQL, Apache/Nginx
- **Development Tools**: Composer, Drush 13+, Git
- **Important**: Always run commands from project root unless specified

## Prerequisites
```bash
# System requirements
PHP 8.3+ with required extensions (gd, xml, mbstring, json, pdo, curl, zip)
MySQL 8.0+ or PostgreSQL 12+
Apache 2.4+ or Nginx 1.18+
Composer 2.0+
Drush 13+

# Verify requirements
php -v
composer --version
drush --version
php -m  # Check installed extensions
```

## Module Scaffolding Template

When creating a new custom module, follow this structure:

```
modules/custom/my_module/
├── my_module.info.yml              # Module metadata (required)
├── my_module.module                # Hook implementations
├── my_module.routing.yml           # Route definitions
├── my_module.services.yml          # Service definitions
├── my_module.permissions.yml       # Permission definitions
├── my_module.links.menu.yml        # Menu links
├── my_module.links.action.yml      # Action links
├── my_module.links.task.yml        # Task (tab) links
├── my_module.libraries.yml         # CSS/JS libraries
├── my_module.routing.yml           # Route definitions
├── composer.json                   # PSR-4 autoloading
├── src/
│   ├── Controller/
│   │   └── MyController.php
│   ├── Form/
│   │   ├── SettingsForm.php        # ConfigFormBase
│   │   └── CustomForm.php          # FormBase
│   ├── Plugin/
│   │   ├── Block/
│   │   │   └── MyBlock.php
│   │   ├── Field/
│   │   │   ├── FieldFormatter/
│   │   │   │   └── MyFormatter.php
│   │   │   ├── FieldWidget/
│   │   │   │   └── MyWidget.php
│   │   │   └── FieldType/
│   │   │       └── MyFieldItem.php
│   │   └── QueueWorker/
│   │       └── MyQueueWorker.php
│   ├── EventSubscriber/
│   │   └── MyEventSubscriber.php
│   ├── Access/
│   │   └── MyAccessChecker.php
│   ├── Entity/
│   │   └── MyEntity.php
│   └── Service/
│       └── MyService.php
├── config/
│   ├── install/                    # Config installed with module
│   │   └── my_module.settings.yml
│   ├── optional/                   # Config installed only if dependencies met
│   │   └── field.field.node.article.field_my_field.yml
│   └── schema/                     # Config schema for typed data
│       └── my_module.schema.yml
├── templates/
│   └── my-module-template.html.twig
├── css/
│   └── my-module.css
├── js/
│   └── my-module.js
└── tests/
    └── src/
        ├── Unit/
        │   └── MyServiceTest.php
        ├── Kernel/
        │   └── MyModuleKernelTest.php
        └── Functional/
            └── MyModuleFunctionalTest.php
```

### Minimal Module Files

**my_module.info.yml**:
```yaml
name: 'My Module'
type: module
description: 'Custom module description.'
core_version_requirement: ^10 || ^11
package: Custom
dependencies:
  - drupal:node
  - drupal:user
```

**composer.json** (for PSR-4 autoloading in tests):
```json
{
  "name": "drupal/my_module",
  "type": "drupal-custom-module",
  "description": "Custom module description.",
  "autoload": {
    "psr-4": {
      "Drupal\\my_module\\": "src/"
    }
  },
  "autoload-dev": {
    "psr-4": {
      "Drupal\\Tests\\my_module\\": "tests/src/"
    }
  }
}
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

**Create services** in `modulename.services.yml`:
```yaml
# my_module.services.yml
services:
  my_module.my_service:
    class: Drupal\my_module\Service\MyService
    arguments: ['@entity_type.manager', '@logger.factory', '@config.factory']
    tags:
      - { name: backend_overridable }
```

**Use dependency injection** in controllers, forms, and plugins:
```php
namespace Drupal\my_module\Controller;

use Drupal\Core\Controller\ControllerBase;
use Drupal\Core\Entity\EntityTypeManagerInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;

class MyController extends ControllerBase {

  public function __construct(
    protected EntityTypeManagerInterface $entityTypeManager,
  ) {}

  public static function create(ContainerInterface $container): static {
    return new static(
      $container->get('entity_type.manager'),
    );
  }

  public function content(): array {
    $nodes = $this->entityTypeManager->getStorage('node')->loadMultiple();
    // ...
    return $build;
  }
}
```

- **Core services** like `@current_user`, `@entity_type.manager`, `@database`, `@config.factory`, `@logger.factory` are available
- **Best practice**: Avoid static `\Drupal::` calls in favor of dependency injection
- **Service discovery**: Use `drush php:eval "print_r(\Drupal::getContainer()->getServiceIds());"` to see available services
- **Location**: Place service classes in `src/` directory with proper namespace

### Entity API & Queries

**Loading entities**:
```php
// Single entity
$node = \Drupal::entityTypeManager()->getStorage('node')->load(123);

// Multiple entities
$nodes = \Drupal::entityTypeManager()->getStorage('node')->loadMultiple([1, 2, 3]);

// Load by properties
$nodes = \Drupal::entityTypeManager()->getStorage('node')->loadByProperties([
  'type' => 'article',
  'status' => 1,
]);
```

**Entity queries** (always prefer over raw SQL):
```php
use Drupal\Core\Entity\Query\QueryInterface;

// Modern entity query with injected service
$ids = $this->entityTypeManager->getStorage('node')->getQuery()
  ->condition('type', 'article')
  ->condition('status', 1)
  ->condition('field_category', $categoryId)
  ->sort('created', 'DESC')
  ->range(0, 10)
  ->accessCheck(TRUE)   // ALWAYS set explicitly in Drupal 10.2+
  ->execute();

$nodes = $this->entityTypeManager->getStorage('node')->loadMultiple($ids);
```

**Creating entities**:
```php
$node = \Drupal::entityTypeManager()->getStorage('node')->create([
  'type' => 'article',
  'title' => 'My Article',
  'body' => [
    'value' => 'Content here',
    'format' => 'full_html',
  ],
  'status' => 1,
  'uid' => 1,
]);
$node->save();
```

**Field access**: Use entity field API instead of direct property access:
```php
// Correct
$node->get('field_my_field')->value;
$node->get('field_my_field')->entity;    // For entity reference fields

// Avoid
$node->field_my_field->value;  // Magic __get — works but less explicit
```

### Plugin System

**Block plugin example**:
```php
namespace Drupal\my_module\Plugin\Block;

use Drupal\Core\Block\BlockBase;
use Drupal\Core\Plugin\ContainerFactoryPluginInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;

/**
 * Provides a 'My Custom Block' block.
 *
 * @Block(
 *   id = "my_custom_block",
 *   admin_label = @Translation("My Custom Block"),
 *   category = @Translation("Custom"),
 *   context_definitions = {
 *     "node" = @ContextDefinition("entity:node", label = @Translation("Node"))
 *   }
 * )
 */
class MyCustomBlock extends BlockBase implements ContainerFactoryPluginInterface {

  public static function create(ContainerInterface $container, array $configuration, $plugin_id, $plugin_definition): static {
    return new static($configuration, $plugin_id, $plugin_definition);
  }

  public function build(): array {
    return [
      '#markup' => $this->t('Hello from my custom block!'),
      '#cache' => [
        'tags' => ['node_list'],
        'contexts' => ['user.roles'],
      ],
    ];
  }
}
```

- **Plugin types**: Blocks, field formatters, field widgets, field types, menu links, QueueWorker, Condition, Action, and more
- **Plugin discovery**: Use annotation-based discovery (as shown above) or YAML discovery
- **Plugin base classes**: Extend appropriate base classes (`BlockBase`, `FormatterBase`, `WidgetBase`, etc.)
- **Plugin placement**: Place plugins in `src/Plugin/Type/` directory structure
- **Derivative plugins**: Use `DeriverBase` for creating multiple plugins from one definition

### Hooks

**Implement hooks** in `modulename.module` file:

```php
/**
 * Implements hook_form_alter().
 */
function my_module_form_alter(&$form, \Drupal\Core\Form\FormStateInterface $form_state, $form_id): void {
  if ($form_id === 'node_article_form') {
    $form['title']['#title'] = t('Article Title');
    $form['actions']['submit']['#value'] = t('Publish Article');
  }
}

/**
 * Implements hook_theme().
 */
function my_module_theme($existing, $type, $theme, $path): array {
  return [
    'my_template' => [
      'variables' => [
        'title' => '',
        'items' => [],
      ],
      'template' => 'my-template',
    ],
  ];
}

/**
 * Implements hook_entity_presave().
 */
function my_module_entity_presave(\Drupal\Core\Entity\EntityInterface $entity): void {
  if ($entity->getEntityTypeId() === 'node' && $entity->bundle() === 'article') {
    // Auto-set a field before saving.
    $entity->set('field_last_updated', \Drupal::time()->getRequestTime());
  }
}

/**
 * Implements hook_cron().
 */
function my_module_cron(): void {
  // Process items during cron runs.
  \Drupal::queue('my_module_processor')->createItem(['type' => 'cleanup']);
}
```

- **Hook naming**: Follow pattern `hook_modulename_action()` for custom hooks
- **Hook parameters**: Use type hints and proper parameter documentation
- **Core hooks**: Common hooks include `hook_form_alter()`, `hook_theme()`, `hook_entity_presave()`, `hook_cron()`, `hook_menu_links_discovered_alter()`
- **Hook order**: Hooks fire in module weight order (lowest first)
- **Best practice**: Keep hook implementations focused and delegate complex logic to services

### Forms API

**Simple form**:
```php
namespace Drupal\my_module\Form;

use Drupal\Core\Form\FormBase;
use Drupal\Core\Form\FormStateInterface;

class CustomForm extends FormBase {

  public function getFormId(): string {
    return 'my_module_custom_form';
  }

  public function buildForm(array $form, FormStateInterface $form_state): array {
    $form['email'] = [
      '#type' => 'email',
      '#title' => $this->t('Email Address'),
      '#required' => TRUE,
    ];

    $form['category'] = [
      '#type' => 'select',
      '#title' => $this->t('Category'),
      '#options' => [
        'news' => $this->t('News'),
        'events' => $this->t('Events'),
        'blog' => $this->t('Blog'),
      ],
      '#ajax' => [
        'callback' => '::categoryChanged',
        'wrapper' => 'subcategory-wrapper',
        'event' => 'change',
      ],
    ];

    $form['subcategory'] = [
      '#type' => 'container',
      '#attributes' => ['id' => 'subcategory-wrapper'],
      'value' => [
        '#type' => 'textfield',
        '#title' => $this->t('Subcategory'),
      ],
    ];

    $form['actions']['submit'] = [
      '#type' => 'submit',
      '#value' => $this->t('Submit'),
    ];

    return $form;
  }

  public function categoryChanged(array &$form, FormStateInterface $form_state): array {
    return $form['subcategory'];
  }

  public function validateForm(array &$form, FormStateInterface $form_state): void {
    $email = $form_state->getValue('email');
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
      $form_state->setErrorByName('email', $this->t('Please enter a valid email address.'));
    }
  }

  public function submitForm(array &$form, FormStateInterface $form_state): void {
    $this->messenger()->addStatus($this->t('Form submitted successfully.'));
    $form_state->setRedirect('<front>');
  }
}
```

**Configuration form**:
```php
namespace Drupal\my_module\Form;

use Drupal\Core\Form\ConfigFormBase;
use Drupal\Core\Form\FormStateInterface;

class SettingsForm extends ConfigFormBase {

  public function getFormId(): string {
    return 'my_module_settings';
  }

  protected function getEditableConfigNames(): array {
    return ['my_module.settings'];
  }

  public function buildForm(array $form, FormStateInterface $form_state): array {
    $config = $this->config('my_module.settings');

    $form['api_key'] = [
      '#type' => 'textfield',
      '#title' => $this->t('API Key'),
      '#default_value' => $config->get('api_key'),
      '#required' => TRUE,
    ];

    $form['max_items'] = [
      '#type' => 'number',
      '#title' => $this->t('Maximum Items'),
      '#default_value' => $config->get('max_items') ?? 50,
      '#min' => 1,
      '#max' => 500,
    ];

    return parent::buildForm($form, $form_state);
  }

  public function submitForm(array &$form, FormStateInterface $form_state): void {
    $this->config('my_module.settings')
      ->set('api_key', $form_state->getValue('api_key'))
      ->set('max_items', $form_state->getValue('max_items'))
      ->save();

    parent::submitForm($form, $form_state);
  }
}
```

### Routes & Controllers

**Route definition** (`my_module.routing.yml`):
```yaml
my_module.content:
  path: '/my-module/{node}'
  defaults:
    _controller: '\Drupal\my_module\Controller\MyController::content'
    _title: 'My Module Page'
  requirements:
    _permission: 'access content'
    node: \d+

my_module.settings:
  path: '/admin/config/my-module/settings'
  defaults:
    _form: '\Drupal\my_module\Form\SettingsForm'
    _title: 'My Module Settings'
  requirements:
    _permission: 'administer site configuration'

my_module.custom_access:
  path: '/my-module/custom/{node}'
  defaults:
    _controller: '\Drupal\my_module\Controller\MyController::customPage'
    _title_callback: '\Drupal\my_module\Controller\MyController::pageTitle'
  requirements:
    _custom_access: '\Drupal\my_module\Access\MyAccessChecker::access'
```

**Controller**:
```php
namespace Drupal\my_module\Controller;

use Drupal\Core\Controller\ControllerBase;
use Drupal\Core\Entity\EntityTypeManagerInterface;
use Drupal\node\NodeInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;

class MyController extends ControllerBase {

  public function __construct(
    protected EntityTypeManagerInterface $entityTypeManager,
  ) {}

  public static function create(ContainerInterface $container): static {
    return new static(
      $container->get('entity_type.manager'),
    );
  }

  public function content(NodeInterface $node): array {
    return [
      '#theme' => 'my_template',
      '#title' => $node->label(),
      '#items' => $this->getItems($node),
      '#cache' => [
        'tags' => ['node:' . $node->id()],
        'contexts' => ['user.permissions'],
      ],
      '#attached' => [
        'library' => ['my_module/my_module.styles'],
      ],
    ];
  }

  public function pageTitle(NodeInterface $node): string {
    return $this->t('Page: @title', ['@title' => $node->label()]);
  }
}
```

**Custom access checker**:
```php
namespace Drupal\my_module\Access;

use Drupal\Core\Access\AccessResult;
use Drupal\Core\Routing\Access\AccessInterface;
use Drupal\node\NodeInterface;

class MyAccessChecker implements AccessInterface {

  public function access(NodeInterface $node): AccessResult {
    return AccessResult::allowedIf($node->isPublished())
      ->addCacheTags(['node:' . $node->id()])
      ->cachePerUser();
  }
}
```

Register in `my_module.services.yml`:
```yaml
  my_module.access_checker:
    class: Drupal\my_module\Access\MyAccessChecker
    tags:
      - { name: access_check }
```

## Security & Performance Guidelines

### Security Requirements
- **Always sanitize user input**: Use `#plain_text` for untrusted content
- **CSRF protection**: Include `#token` for forms with side effects
- **Permissions**: Implement proper access checks and route requirements
- **SQL Injection**: Use Entity Query or proper parameter binding
- **XSS Prevention**: Always use `|e` filter in Twig, `#markup` for trusted HTML only
- **File uploads**: Validate file types and sizes; use Drupal's file API
- **Database credentials**: Never commit credentials to version control
- **Render arrays**: Never use `#markup` with unsanitized user input; use `#plain_text` or `check_plain()`

### Performance Best Practices
- **Render caching**: Always add `#cache` array to render arrays with appropriate `tags` and `contexts`
- **Cache tags**: Use entity-based tags like `['node:123']` or list-based tags like `['node_list']`
- **Cache contexts**: Apply user-specific contexts like `['user.roles']` for personalized content
- **Lazy loading**: Use `#lazy_builder` for expensive operations that can be loaded separately
- **Placeholder strategy**: Set `#create_placeholder` => TRUE for lazy builders to improve initial page load
- **Cache max-age**: Set appropriate `max-age` values based on content freshness requirements
- **Avoid premature optimization**: Profile first, then optimize based on actual bottlenecks
- **Database queries**: Use entity queries instead of raw SQL for better caching and security
- **Entity loading**: Load multiple entities at once with `loadMultiple()` instead of individual loads

**Render array with caching**:
```php
$build = [
  '#theme' => 'item_list',
  '#items' => $items,
  '#cache' => [
    'keys' => ['my_module:item_list:' . $categoryId],
    'tags' => ['node_list', 'taxonomy_term:' . $categoryId],
    'contexts' => ['user.roles'],
    'max-age' => 3600,
  ],
];
```

**Lazy builder for expensive operations**:
```php
$build['expensive_content'] = [
  '#lazy_builder' => [
    '\Drupal\my_module\Service\MyLazyBuilder::renderExpensiveContent',
    [$param1, $param2],
  ],
  '#create_placeholder' => TRUE,
];
```

### Caching Strategies
- **Render cache**: Cache complex markup with proper tags/contexts
- **Dynamic page cache**: Automatically handles cacheability for anonymous users
- **Internal page cache**: Serves full cached pages for anonymous users
- **Entity cache**: Core entity caching is automatic — invalidate with cache tags
- **Redis/Memcache**: Configure for distributed caching in production

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

## Anti-Patterns — Never Do This

These are common mistakes that an AI agent must avoid:

1. **Never use `\Drupal::` static calls in services, controllers, or plugins** — Use dependency injection instead. The only acceptable use is in `hook_` functions in `.module` files (and even there, consider delegating to a service).

2. **Never query the database directly when Entity Query suffices** — Use `\Drupal::entityQuery()` or injected `$this->entityTypeManager->getStorage()->getQuery()`.

3. **Never use `|raw` in Twig** — Use `|e` (or rely on auto-escaping). If you need raw HTML, use `#type => 'processed_text'` or `check_markup()`.

4. **Never create monolithic `hook_form_alter()` functions** — If the alter logic is complex, delegate to a service. Break large hooks into focused helper methods.

5. **Never store configuration in state that belongs in config** — State (`\Drupal::state()`) is for ephemeral/transient data (last cron run, temporary flags). Config (`\Drupal::configFactory()`) is for structured, exportable settings.

6. **Never use `#markup` with unsanitized user input** — Always use `#plain_text` for untrusted content or `check_plain()` / `Html::escape()` for escaping.

7. **Never skip `accessCheck(TRUE)` on entity queries** — Drupal 10.2+ requires explicit access checking on entity queries. Omitting it throws deprecation warnings and will be required in Drupal 12.

8. **Never hardcode entity IDs, user IDs, or paths** — Use configuration, route names, and dynamic lookups instead.

9. **Never use `hook_views_data()` without proper table aliases** — Always prefix table columns clearly to avoid SQL ambiguity.

10. **Never ignore cacheability metadata** — Every render array that depends on data must specify `#cache` tags, contexts, and max-age. Missing cache metadata causes stale content or unnecessary cache invalidation.

11. **Never commit `settings.php` with database credentials** — Use environment variables or `settings.local.php` (excluded from VCS).

12. **Never use `node_load()` or other deprecated procedural functions** — Use the entity type manager: `\Drupal::entityTypeManager()->getStorage('node')->load()`.

13. **Never use global variables like `$_GET`, `$_POST`, `$_SERVER`** — Use Symfony's `Request` object via dependency injection.

14. **Never put business logic in `.module` files** — Delegate to services. The `.module` file should be thin: route hooks, theme hooks, and thin wrappers that call services.

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

### Unit Test Example
```php
// tests/src/Unit/MyServiceTest.php
namespace Drupal\Tests\my_module\Unit;

use Drupal\Tests\UnitTestCase;
use Drupal\my_module\Service\MyService;
use Prophecy\PhpUnit\ProphecyTrait;

class MyServiceTest extends UnitTestCase {
  use ProphecyTrait;

  public function testProcessReturnsExpectedValue(): void {
    $logger = $this->prophesize('\Psr\Log\LoggerInterface');
    $service = new MyService($logger->reveal());
    $result = $service->process('input');
    $this->assertEquals('expected_output', $result);
  }

  public function testProcessThrowsOnEmptyInput(): void {
    $logger = $this->prophesize('\Psr\Log\LoggerInterface');
    $service = new MyService($logger->reveal());
    $this->expectException(\InvalidArgumentException::class);
    $service->process('');
  }
}
```

### Kernel Test Example
```php
// tests/src/Kernel/MyModuleKernelTest.php
namespace Drupal\Tests\my_module\Kernel;

use Drupal\KernelTests\KernelTestBase;
use Drupal\node\Entity\Node;
use Drupal\node\Entity\NodeType;

class MyModuleKernelTest extends KernelTestBase {

  protected static $modules = ['system', 'node', 'user', 'my_module'];

  protected function setUp(): void {
    parent::setUp();
    $this->installEntitySchema('node');
    $this->installEntitySchema('user');
    $this->installConfig(['my_module']);

    // Create a node type for testing.
    NodeType::create(['type' => 'article', 'name' => 'Article'])->save();
  }

  public function testNodeCreation(): void {
    $node = Node::create([
      'type' => 'article',
      'title' => 'Test Article',
      'status' => 1,
    ]);
    $node->save();

    $this->assertNotNull($node->id());
    $this->assertEquals('article', $node->bundle());
  }
}
```

### Functional Test Example
```php
// tests/src/Functional/MyModuleFunctionalTest.php
namespace Drupal\Tests\my_module\Functional;

use Drupal\Tests\BrowserTestBase;

class MyModuleFunctionalTest extends BrowserTestBase {

  protected $defaultTheme = 'stark';
  protected static $modules = ['node', 'my_module'];

  protected function setUp(): void {
    parent::setUp();
    // Create a test user with permissions.
    $this->drupalCreateContentType(['type' => 'article', 'name' => 'Article']);
    $user = $this->drupalCreateUser(['access content', 'create article content']);
    $this->drupalLogin($user);
  }

  public function testArticleCreation(): void {
    $this->drupalGet('/node/add/article');
    $this->assertSession()->statusCodeEquals(200);

    // Submit the node form.
    $edit = [
      'title[0][value]' => 'Test Article Title',
    ];
    $this->submitForm($edit, 'Save');
    $this->assertSession()->pageTextContains('Article Test Article Title has been created.');
  }

  public function testMyModulePageAccess(): void {
    // Anonymous users should not access custom pages.
    $this->drupalGet('/my-module/custom/1');
    $this->assertSession()->statusCodeEquals(403);
  }
}
```

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
| Command                          | Purpose                                                                 |
|----------------------------------|-------------------------------------------------------------------------|
| `drush status`                   | Shows Drupal root, site path, database connection, Drush version       |
| `drush watchdog:show` / `drush ws` | Lists recent log messages. Filters: `--severity=Error`, `--type=php` |
| `drush watchdog:delete all`      | Clears the watchdog log                                                |
| `drush sql:query "SELECT * FROM watchdog ORDER BY wid DESC LIMIT 50"` | Direct SQL access to logs |

#### Cache Debugging
| Command                          | Purpose                                                                 |
|----------------------------------|-------------------------------------------------------------------------|
| `drush cache:rebuild` / `drush cr` | Rebuilds all caches                                                   |
| `drush cache:get <bin>:<cid>`    | Retrieve a specific cache item                                        |
| `drush cache:clear <bin>`        | Clear only one cache bin                                              |

#### Configuration Debugging
| Command                                      | Purpose                                                                 |
|----------------------------------------------|-------------------------------------------------------------------------|
| `drush config:get <name>`                    | Show a single configuration value                                      |
| `drush config:set <name> <key> <value>`      | Temporarily change a config value                                      |
| `drush config:export` / `drush cex`          | Export active config to sync directory                                 |
| `drush config:import` / `drush cim`          | Import config                                                           |
| `drush config:delete <name>`                 | Remove a config object                                                  |

#### Module/Theming Debugging
| Command                                | Purpose                                                                 |
|----------------------------------------|-------------------------------------------------------------------------|
| `drush pm:list --type=module --status=enabled` | List enabled modules                           |
| `drush pm:enable <module>` / `drush en <module>` | Enable a module                              |
| `drush pm:uninstall <module>` / `drush puninstall <module>` | Fully uninstall a module    |
| `drush theme:debug`                    | Lists all theme suggestions                                            |

#### Database & Entity Debugging
| Command                                      | Purpose                                                                 |
|----------------------------------------------|-------------------------------------------------------------------------|
| `drush sql:connect`                          | Outputs the CLI command to connect to the DB                           |
| `drush sql:query`                            | Run arbitrary SQL                                                       |
| `drush entity:info`                          | Show entity type definitions                                            |
| `drush php`                                  | Opens an interactive PHP shell with Drupal bootstrapped                |
| `drush php:eval "code"`                      | Execute arbitrary PHP code in Drupal context                           |

#### Performance & Query Debugging
```bash
drush sql:query --db-prefix          # See queries with table prefixes expanded
drush twig:debug                     # Turn Twig debugging on/off
drush state:get/set/delete           # Inspect or override Drupal state values
```

### Performance Profiling
```bash
# Performance analysis
drush cr                     # Rebuild caches
drush sql:query "EXPLAIN ANALYZE SELECT ..."  # Query analysis
drush site:status           # System status check

# Use Webprofiler module for detailed profiling
# Access at /admin/config/development/devel/webprofiler
```

### Version Control Workflow
- **Commit messages**: Format `[#123456] Brief descriptive title`
- **Branch from**: `develop` branch for features
- **Atomic commits**: One logical change per commit
- **Before pushing**: Run linting and tests

## Advanced Development Patterns

### Events & EventSubscribers

Prefer EventSubscribers over hooks for many use cases. They are more testable and follow Symfony conventions.

**EventSubscriber example**:
```php
namespace Drupal\my_module\EventSubscriber;

use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\KernelEvents;
use Symfony\Component\HttpKernel\Event\RequestEvent;

class MyEventSubscriber implements EventSubscriberInterface {

  public static function getSubscribedEvents(): array {
    return [
      KernelEvents::REQUEST => ['onKernelRequest', 100],
      KernelEvents::RESPONSE => ['onKernelResponse'],
    ];
  }

  public function onKernelRequest(RequestEvent $event): void {
    // Act on every request.
    $request = $event->getRequest();
    // ...
  }

  public function onKernelResponse(\Symfony\Component\HttpKernel\Event\ResponseEvent $event): void {
    // Modify response.
  }
}
```

Register in `my_module.services.yml`:
```yaml
  my_module.event_subscriber:
    class: Drupal\my_module\EventSubscriber\MyEventSubscriber
    tags:
      - { name: event_subscriber }
```

**Drupal-specific events**: `HookEventDispatcher` module provides events for most Drupal hooks. Core events include entity events and kernel events.

### Configuration Management

**Config schema** (`config/schema/my_module.schema.yml`):
```yaml
my_module.settings:
  type: config_object
  label: 'My Module settings'
  mapping:
    api_key:
      type: string
      label: 'API Key'
    max_items:
      type: integer
      label: 'Maximum items'
    enabled_types:
      type: sequence
      label: 'Enabled content types'
      sequence:
        type: string
        label: 'Content type'
```

**Config install** (`config/install/my_module.settings.yml`):
```yaml
api_key: ''
max_items: 50
enabled_types:
  - article
```

**Reading config**:
```php
// In a service/controller (injected)
$value = $this->configFactory->get('my_module.settings')->get('api_key');

// In a .module file (less preferred)
$value = \Drupal::config('my_module.settings')->get('api_key');
```

**Config workflow**:
```bash
# Export all configuration
drush config:export

# Import configuration
drush config:import

# View a single config value
drush config:get system.site

# Edit config interactively
drush config:edit my_module.settings
```

- **`config/install/`**: Required config installed when module is enabled
- **`config/optional/`**: Config installed only if dependencies are met
- **Config override**: Use `$config['system.performance']['css']['preprocess'] = FALSE;` in `settings.php` for environment-specific overrides
- **Config split**: Use `config_split` module for per-environment configuration (dev/staging/prod)

### Batch API for Long Operations

```php
use Drupal\Core\Batch\BatchBuilder;

function my_module_process_items(array $items): void {
  $batch = (new BatchBuilder())
    ->setTitle(t('Processing items'))
    ->setInitMessage(t('Initializing...'))
    ->setProgressMessage(t('Processed @current out of @total.'))
    ->setErrorMessage(t('An error occurred during processing.'))
    ->setFile(\Drupal::service('extension.list.module')->getPath('my_module') . '/my_module.batch.inc')
    ->setFinishCallback('my_module_batch_finished')
    ->addOperation('my_module_batch_process', [$items]);

  batch_set($batch->toArray());
}

// In my_module.batch.inc
function my_module_batch_process(array $items, array &$context): void {
  if (!isset($context['sandbox']['progress'])) {
    $context['sandbox']['progress'] = 0;
    $context['sandbox']['max'] = count($items);
    $context['sandbox']['items'] = $items;
  }

  $limit = 10;
  $items_to_process = array_slice($context['sandbox']['items'], $context['sandbox']['progress'], $limit);

  foreach ($items_to_process as $item) {
    // Process each item.
    $context['sandbox']['progress']++;
  }

  $context['finished'] = $context['sandbox']['progress'] / $context['sandbox']['max'];
  $context['message'] = t('Processed @progress of @max items', [
    '@progress' => $context['sandbox']['progress'],
    '@max' => $context['sandbox']['max'],
  ]);
}

function my_module_batch_finished(bool $success, array $results, array $operations): void {
  $messenger = \Drupal::messenger();
  if ($success) {
    $messenger->addStatus(t('Batch completed successfully.'));
  }
  else {
    $messenger->addError(t('An error occurred during batch processing.'));
  }
}
```

- **Purpose**: Process large datasets without PHP timeout issues
- **Use cases**: Data migration, bulk updates, file processing, API calls
- **Memory management**: Processes data in chunks to prevent memory exhaustion

### Queue API for Background Processing

```php
namespace Drupal\my_module\Plugin\QueueWorker;

use Drupal\Core\Queue\QueueWorkerBase;
use Drupal\Core\Plugin\ContainerFactoryPluginInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;

/**
 * Processes my module items.
 *
 * @QueueWorker(
 *   id = "my_module_processor",
 *   title = @Translation("My Module Processor"),
 *   cron = {"time" = 60}
 * )
 */
class MyQueueWorker extends QueueWorkerBase implements ContainerFactoryPluginInterface {

  public static function create(ContainerInterface $container, array $configuration, $plugin_id, $plugin_definition): static {
    return new static($configuration, $plugin_id, $plugin_definition);
  }

  public function processItem($data): void {
    // Process the queue item.
    if (!isset($data['type'])) {
      throw new \InvalidArgumentException('Missing type in queue item.');
    }
    // Do work...
  }
}
```

**Adding items to the queue**:
```php
\Drupal::queue('my_module_processor')->createItem(['type' => 'cleanup', 'node_id' => 123]);
```

- **Cron integration**: `cron = {"time" = 60}` processes items during cron for up to 60 seconds
- **Reliability**: Failed items are released back to the queue automatically
- **Logging**: Always log queue processing outcomes

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

### Render API Deep Dive

```php
// Full render array with all common properties
$build = [
  '#type' => 'container',
  '#attributes' => ['class' => ['my-wrapper']],
  'heading' => [
    '#type' => 'html_tag',
    '#tag' => 'h2',
    '#value' => $this->t('My Heading'),
  ],
  'content' => [
    '#theme' => 'item_list',
    '#items' => $items,
    '#empty' => $this->t('No items found.'),
  ],
  '#cache' => [
    'keys' => ['my_module', 'list', $categoryId],
    'tags' => ['node_list', 'taxonomy_term:' . $categoryId],
    'contexts' => ['user.roles', 'languages:language_content'],
    'max-age' => 3600,
  ],
  '#attached' => [
    'library' => ['my_module/my_module.styles'],
    'drupalSettings' => [
      'my_module' => ['endpoint' => '/api/items'],
    ],
  ],
  '#weight' => 10,
];
```

- **`#pre_render` / `#post_render`**: Callbacks to modify render arrays before/after rendering
- **`#lazy_builder`**: Defers rendering of expensive content
- **`#create_placeholder`**: Generates a placeholder for BigPipe-style loading
- **`#attached`**: Attach CSS/JS libraries, settings, HTML head links, and HTTP headers

### Migration API

```yaml
# In migrations/my_migration.yml — source plugin
source:
  plugin: csv
  path: /path/to/data.csv
  header_row_count: 1
  keys:
    - id
  column_names:
    -
      id: [id, 'Unique ID']
    -
      title: [title, 'Title']

# Process plugin
process:
  title: title
  body/value: body
  body/format:
    plugin: default_value
    default_value: basic_html
  type:
    plugin: default_value
    default_value: article
  uid:
    plugin: default_value
    default_value: 1

# Destination plugin
destination:
  plugin: entity:node
  default_bundle: article
```

**Custom process plugin**:
```php
namespace Drupal\my_module\Plugin\migrate\process;

use Drupal\migrate\ProcessPluginBase;
use Drupal\migrate\MigrateExecutableInterface;
use Drupal\migrate\Row;

/**
 * Custom process plugin.
 *
 * @MigrateProcessPlugin(
 *   id = "my_custom_process"
 * )
 */
class MyCustomProcess extends ProcessPluginBase {

  public function transform($value, MigrateExecutableInterface $migrate_executable, Row $row, $destination_property): mixed {
    // Transform the value during migration.
    return strtoupper(trim($value));
  }
}
```

### Composer Management

```bash
# Add a module
composer require drupal/admin_toolbar

# Add a module with a patch
composer require drupal/some_module
# Then add patch to composer.json extras:
# "patches": {
#     "drupal/some_module": {
#         "Fix description": "https://www.drupal.org/files/issues/2024-01-01/issue-12345-1.patch"
#     }
# }

# Update Drupal core
composer update drupal/core --with-all-dependencies

# Run post-install steps
drush updatedb
drush config:import
drush cr
```

**composer.json best practices**:
- Use `drupal/core-recommended` for production, `drupal/core-dev` for development
- Pin major versions: `"drupal/core-recommended": "^11"`
- Use `composer-patches` plugin for community patches
- Commit `composer.lock` to version control
- Use `drupal.org` composer endpoint: `composer config repositories.drupal composer https://packages.drupal.org/8`

### JavaScript & Frontend

**Drupal behaviors** (not jQuery document.ready):
```javascript
// js/my-module.js
(function (Drupal, drupalSettings) {
  'use strict';

  Drupal.behaviors.myModuleBehavior = {
    attach: function (context, settings) {
      // Run on every page load and AJAX response.
      const elements = context.querySelectorAll('.my-element');
      elements.forEach(function (element) {
        element.addEventListener('click', handleClick);
      });
    },
    detach: function (context, settings, trigger) {
      // Clean up when content is removed (AJAX, etc.).
      const elements = context.querySelectorAll('.my-element');
      elements.forEach(function (element) {
        element.removeEventListener('click', handleClick);
      });
    }
  };

  function handleClick(event) {
    // Handle click.
  }
})(Drupal, drupalSettings);
```

**Library definition** (`my_module.libraries.yml`):
```yaml
my_module.styles:
  version: VERSION
  css:
    component:
      css/my-module.css: {}
  js:
    js/my-module.js: {}
  dependencies:
    - core/drupal
    - core/drupalSettings
```

**Attaching libraries**:
```php
// In render array
$build['#attached']['library'][] = 'my_module/my_module.styles';

// In twig
{{
  attach_library('my_module/my_module.styles')
}}
```

### Content Moderation & Workflows

```php
// Workflows are typically configured via UI, but modules can interact:
use Drupal\workflows\Entity\Workflow;

// Load a workflow
$workflow = Workflow::load('editorial');

// Check moderation state of a node
if ($node->hasField('moderation_state')) {
  $state = $node->get('moderation_state')->value;
}

// Transition a node to a new state
$node->set('moderation_state', 'published');
$node->save();
```

## Troubleshooting Common Issues

### Installation Problems
```bash
# Composer memory issues
php -d memory_limit=-1 /usr/local/bin/composer install

# Permission issues
chmod 755 sites/default/files
chmod 644 sites/default/settings.php
chown -R www-data:www-data sites/default/files

# Database connection failed — check settings.php and database server status
drush sql:connect  # Test database connection

# PHP extensions missing
php -m  # Check installed extensions
```

### Performance Issues
```bash
# Identify slow queries
drush sql:query "SELECT * FROM watchdog WHERE type = 'php' ORDER BY wid DESC LIMIT 10"

# Check cache settings
drush config:get system.performance
```

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
# PHPUnit configuration — ensure phpunit.xml.dist exists and is configured
cp web/core/phpunit.xml.dist phpunit.xml

# Database setup for testing — edit phpunit.xml for SIMPLETEST_DB and SIMPLETEST_BASE_URL
# SIMPLETEST_DB=mysql://root:password@localhost/drupal_test
# SIMPLETEST_BASE_URL=http://127.0.0.1:8888

# Browser tests failing — install Selenium or ChromeDriver
# Ensure test environment variables are set
```

## Additional Resources

### Official Documentation
- **Drupal API**: https://api.drupal.org
- **Developer Guide**: https://www.drupal.org/docs/develop
- **Coding Standards**: https://www.drupal.org/docs/develop/standards
- **Security Best Practices**: https://www.drupal.org/docs/develop/security
- **Configuration Management**: https://www.drupal.org/docs/administering-a-drupal-site/configuration-management
- **Migration API**: https://www.drupal.org/docs/8/api/migrate-api

### Community Resources
- **DrupalAtYourFingertips**: https://www.drupalatyourfingertips.com
- **Drupal Answers**: https://drupal.stackexchange.com
- **Drupal.org**: https://www.drupal.org
- **Drupal Slack**: https://drupal.slack.com
