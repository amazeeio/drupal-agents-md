# AGENTS.md: AI Agent Guide for Drupal Development on Lagoon

**AI Agent Instructions**: This guide provides comprehensive instructions for AI coding agents working on Drupal projects deployed on amazee.io Lagoon (Kubernetes-based hosting). Follow these guidelines for consistent, high-quality contributions. Human contributors should use README.md instead.

## Table of Contents

- [Project Overview](#project-overview)
- [Lagoon Quick Setup](#lagoon-quick-setup)
- [Module Scaffolding Template](#module-scaffolding-template)
- [Code Style and Standards](#code-style-and-standards)
- [Drupal Development Patterns](#drupal-development-patterns)
- [Security & Performance Guidelines](#security--performance-guidelines)
- [Anti-Patterns — Never Do This](#anti-patterns--never-do-this)
- [Testing & Quality Assurance](#testing--quality-assurance)
- [Lagoon Development Workflow](#lagoon-development-workflow)
- [Advanced Development Patterns](#advanced-development-patterns)
- [Additional Topics](#additional-topics)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)

## Project Overview
- **Core Technology**: Drupal 10.x / 11.x (verify via `composer show drupal/core`)
- **Hosting Platform**: amazee.io Lagoon (Kubernetes-based)
- **Local Development**: DDEV or Docker Compose (Lagoon-compatible)
- **Key Components**: Custom modules, themes, configuration management, Composer dependencies
- **Environment**: PHP 8.3+, MariaDB, Nginx, Varnish (managed by Lagoon)
- **Development Tools**: Composer, Drush 13+, Git, Lagoon CLI, lagoon-sync
- **Important**: Use Drush aliases for remote operations. Local commands run directly or via DDEV.

## Lagoon Quick Setup

### Prerequisites
```bash
# Install Lagoon CLI (macOS)
brew tap uselagoon/lagoon-cli
brew install lagoon

# Or download from https://github.com/uselagoon/lagoon-cli/releases
# Verify installation
lagoon --version

# Install lagoon-sync for database/file synchronization
brew install uselagoon/lagoon-sync/lagoon-sync

# Configure Lagoon CLI connection
lagoon config add \
  --graphql YOUR-API-URL/graphql \
  --ui YOUR-UI-URL \
  --hostname YOUR.DOMAIN
```

### Lagoon Project Files
Lagoon requires these files in the repository root:

**`.lagoon.yml`** — Lagoon configuration:
```yaml
docker-compose-yaml: docker-compose.yml

# Environment variables
environment_variables:
  git_sha: "true"

# Environments that auto-deploy
environments:
  main:
    routes:
      - nginx:
          - example.com
          - www.example.com
    cronjobs:
      - name: drush cron
        schedule: "*/15 * * * *"
        command: drush cron
        service: nginx

# Post-rollout tasks
tasks:
  post-rollout:
    - run:
        name: drush updb
        command: drush updatedb --no-cache-clear
        service: nginx
        shell: bash
    - run:
        name: drush cim
        command: drush config:import --yes
        service: nginx
        shell: bash
    - run:
        name: drush cr
        command: drush cache:rebuild
        service: nginx
        shell: bash
```

**`docker-compose.yml`** (Lagoon-flavored):
```yaml
# Must use the Lagoon-compatible docker-compose format
# See: https://docs.lagoon.sh/lagoon/using-lagoon-the-basics/docker-compose-yml/
```

### Essential Lagoon Commands
```bash
# Deployment
lagoon deploy branch --project <project> --branch <branch>  # Deploy a branch
lagoon deploy promote --project <project> --source <branch> --destination <env>  # Promote to production

# Environment management
lagoon list environments --project <project>                 # List environments
lagoon get environment --project <project> --environment <env>  # Get env details
lagoon delete environment --project <project> --environment <env>  # Delete env

# Logs & debugging
lagoon logs --project <project> --environment <env>          # View environment logs
lagoon ssh --project <project> --environment <env>           # SSH into pod

# Variables
lagoon list variables --project <project> --environment <env>
lagoon add variable --project <project> --environment <env> --name NAME --value VALUE
```

### Database & File Synchronization
```bash
# Sync database from production to local
lagoon-sync sync mariadb -p <project> -e main -t local

# Sync database from staging to local
lagoon-sync sync mariadb -p <project> -e staging -t local

# Sync files from production to local
lagoon-sync sync files -p <project> -e main -t local

# Using Drush aliases (alternative)
drush sql:sync @lagoon.main @self
drush rsync @lagoon.main:%files @self:%files
```

### Environment Variables
Lagoon automatically injects these variables:

| Variable | Description |
|---|---|
| `LAGOON_PROJECT` | Project name |
| `LAGOON_ENVIRONMENT` | Environment name (branch) |
| `LAGOON_ENVIRONMENT_TYPE` | `production`, `staging`, or `development` |
| `LAGOON_GIT_BRANCH` | Git branch name |
| `LAGOON_GIT_SHA` | Full Git commit SHA |
| `LAGOON_ROUTE` | Primary route/URL of the environment |
| `LAGOON_ROUTES` | Comma-separated list of all routes |

Use these in `settings.php` for environment-aware configuration:
```php
// settings.php — Lagoon environment detection
$lagoon_env_type = getenv('LAGOON_ENVIRONMENT_TYPE') ?: 'local';
$is_production = $lagoon_env_type === 'production';

if ($is_production) {
  $config['system.performance']['css']['preprocess'] = TRUE;
  $config['system.performance']['js']['preprocess'] = TRUE;
}
else {
  // Development settings.
  $config['system.performance']['css']['preprocess'] = FALSE;
  $config['system.performance']['js']['preprocess'] = FALSE;
  $settings['cache']['bins']['render'] = 'cache.backend.null';
}
```

### Drush Aliases
Lagoon provides Drush aliases automatically. Use them for remote operations:

```bash
# List available aliases
drush site:alias

# Run Drush commands on remote environments
drush @lagoon.main status
drush @lagoon.staging config:export
drush @lagoon.main cache:rebuild

# Sync between environments
drush sql:sync @lagoon.main @lagoon.staging
drush rsync @lagoon.main:%files @lagoon.staging:%files
```

## Module Scaffolding Template

When creating a new custom module, follow this structure:

```
web/modules/custom/my_module/
├── my_module.info.yml              # Module metadata (required)
├── my_module.module                # Hook implementations
├── my_module.routing.yml           # Route definitions
├── my_module.services.yml          # Service definitions
├── my_module.permissions.yml       # Permission definitions
├── my_module.links.menu.yml        # Menu links
├── my_module.links.action.yml      # Action links
├── my_module.links.task.yml        # Task (tab) links
├── my_module.libraries.yml         # CSS/JS libraries
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

- **Linting** (run locally or via DDEV):
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
- **Database credentials**: Never commit credentials — Lagoon injects them via environment variables
- **Render arrays**: Never use `#markup` with unsanitized user input; use `#plain_text` or `check_plain()`

### Performance Best Practices
- **Render caching**: Always add `#cache` array to render arrays with appropriate `tags` and `contexts`
- **Cache tags**: Use entity-based tags like `['node:123']` or list-based tags like `['node_list']`
- **Cache contexts**: Apply user-specific contexts like `['user.roles']` for personalized content
- **Lazy loading**: Use `#lazy_builder` for expensive operations that can be loaded separately
- **Placeholder strategy**: Set `#create_placeholder` => TRUE for lazy builders to improve initial page load
- **Cache max-age**: Set appropriate `max-age` values based on content freshness requirements
- **Varnish**: Lagoon provides Varnish by default — ensure proper cache headers and invalidation
- **Redis**: Lagoon supports Redis — configure in `settings.php` for distributed caching
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

**Redis configuration for Lagoon** (in `settings.php`):
```php
// Redis configuration for Lagoon
if (getenv('LAGOON')) {
  $settings['redis.connection']['interface'] = 'PhpRedis';
  $settings['redis.connection']['host'] = getenv('REDIS_HOST') ?: 'redis';
  $settings['redis.connection']['port'] = getenv('REDIS_SERVICE_PORT') ?: 6379;
  $settings['cache']['default'] = 'cache.backend.redis';
  $settings['container_yamls'][] = DRUPAL_ROOT . '/sites/redis.services.yml';
}
```

### Caching Strategies
- **Varnish (Lagoon default)**: Full-page caching for anonymous users with automatic purge
- **Redis**: Persistent object cache — configure via `settings.php`
- **Render cache**: Cache complex markup with proper tags/contexts
- **Dynamic page cache**: Automatically handles cacheability for anonymous users
- **Entity cache**: Core entity caching is automatic — invalidate with cache tags

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

11. **Never commit `settings.php` with database credentials** — On Lagoon, credentials are injected via environment variables automatically.

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
vendor/bin/phpunit web/modules/custom/my_module/tests/src/Unit/

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
    $this->drupalCreateContentType(['type' => 'article', 'name' => 'Article']);
    $user = $this->drupalCreateUser(['access content', 'create article content']);
    $this->drupalLogin($user);
  }

  public function testArticleCreation(): void {
    $this->drupalGet('/node/add/article');
    $this->assertSession()->statusCodeEquals(200);

    $edit = [
      'title[0][value]' => 'Test Article Title',
    ];
    $this->submitForm($edit, 'Save');
    $this->assertSession()->pageTextContains('Article Test Article Title has been created.');
  }

  public function testMyModulePageAccess(): void {
    $this->drupalGet('/my-module/custom/1');
    $this->assertSession()->statusCodeEquals(403);
  }
}
```

### Code Quality Tools
```bash
# Static analysis
vendor/bin/phpstan analyse
vendor/bin/psalm

# Security scanning
vendor/bin/drupal-check
composer audit

# Accessibility testing
vendor/bin/phpunit --group accessibility
```

### Before Submitting Code
```bash
# Quality checklist
vendor/bin/phpcs --standard=Drupal .
vendor/bin/phpunit
drush cr
drush updatedb
```

## Lagoon Development Workflow

### Project Structure
- **Modules** → `web/modules/custom/<module_name>`
- **Themes** → `web/themes/custom/<theme_name>`
- **Configuration** → Export with `drush config:export`
- **Profiles** → `web/profiles/custom/<profile_name>`
- **Lagoon config** → `.lagoon.yml` in project root
- **Docker Compose** → `docker-compose.yml` in project root

### Deployment Workflow
```bash
# Feature development workflow
git checkout -b feature/my-feature
# ... make changes ...
git push origin feature/my-feature
# Lagoon auto-deploys the branch as a new environment

# Check deployment status
lagoon get environment --project <project> --environment feature-my-feature

# View deployment logs
lagoon logs --project <project> --environment feature-my-feature

# After review, merge to main
git checkout main
git merge feature/my-feature
git push origin main
# Lagoon auto-deploys to production
```

### Remote Drush Commands
```bash
# Run Drush on a remote Lagoon environment
drush @lagoon.main status
drush @lagoon.main config:export
drush @lagoon.main config:import --yes
drush @lagoon.main cache:rebuild
drush @lagoon.main updatedb
drush @lagoon.main pm:enable my_module

# Sync production DB to local for development
lagoon-sync sync mariadb -p <project> -e main -t local
drush cr  # Rebuild caches after sync

# Sync files from production
lagoon-sync sync files -p <project> -e main -t local
```

### Version Control Workflow
- **Commit messages**: Format `[#123456] Brief descriptive title`
- **Branch from**: `main` branch for features (auto-deployed by Lagoon)
- **Atomic commits**: One logical change per commit
- **Before pushing**: Run linting and tests locally

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
    if (!isset($data['type'])) {
      throw new \InvalidArgumentException('Missing type in queue item.');
    }
    // Do work...
  }
}
```

### AJAX Forms
- **Trigger elements**: Add `#ajax` property to form elements (select, checkbox, button)
- **Callback method**: Reference callback method using `::methodName` syntax
- **Wrapper element**: Specify target element ID for AJAX response replacement
- **Error handling**: Implement try-catch blocks in AJAX callbacks
- **Form state**: Use `$form_state->getTriggeringElement()` to identify trigger

### Render API Deep Dive

```php
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
];
```

### Migration API

```yaml
# migrations/my_migration.yml
source:
  plugin: csv
  path: /path/to/data.csv
  header_row_count: 1
  keys:
    - id

process:
  title: title
  body/value: body
  body/format:
    plugin: default_value
    default_value: basic_html
  type:
    plugin: default_value
    default_value: article

destination:
  plugin: entity:node
  default_bundle: article
```

### Composer Management

```bash
# Add a module
composer require drupal/admin_toolbar

# Update Drupal core
composer update drupal/core --with-all-dependencies

# Run post-install steps
drush updatedb
drush config:import
drush cr
```

### JavaScript & Frontend

**Drupal behaviors**:
```javascript
(function (Drupal, drupalSettings) {
  'use strict';

  Drupal.behaviors.myModuleBehavior = {
    attach: function (context, settings) {
      const elements = context.querySelectorAll('.my-element');
      elements.forEach(function (element) {
        element.addEventListener('click', handleClick);
      });
    },
    detach: function (context, settings, trigger) {
      const elements = context.querySelectorAll('.my-element');
      elements.forEach(function (element) {
        element.removeEventListener('click', handleClick);
      });
    }
  };
})(Drupal, drupalSettings);
```

## Troubleshooting

### Lagoon Deployment Issues
```bash
# Check deployment status
lagoon get environment --project <project> --environment <env>

# View deployment logs
lagoon logs --project <project> --environment <env>

# SSH into a pod for debugging
lagoon ssh --project <project> --environment <env>

# Check remote Drush status
drush @lagoon.<env> status
```

### Database Sync Issues
```bash
# If lagoon-sync fails, try Drush
drush sql:sync @lagoon.main @self

# Clear caches after sync
drush cr
```

### Performance Issues
```bash
# Check remote cache settings
drush @lagoon.main config:get system.performance

# Check watchdog for errors
drush @lagoon.main watchdog:show --severity=Error

# Check Redis connection
drush @lagoon.main php:eval "var_dump(\Drupal::service('cache.default')->get('test'));"
```

## Additional Resources

### Lagoon Documentation
- **Lagoon Docs**: https://docs.lagoon.sh
- **Lagoon CLI**: https://github.com/uselagoon/lagoon-cli
- **lagoon-sync**: https://github.com/uselagoon/lagoon-sync
- **Drupal on Lagoon**: https://docs.lagoon.sh/lagoon/using-lagoon-the-basics/drupal/

### Drupal Documentation
- **Drupal API**: https://api.drupal.org
- **Developer Guide**: https://www.drupal.org/docs/develop
- **Coding Standards**: https://www.drupal.org/docs/develop/standards
- **Security Best Practices**: https://www.drupal.org/docs/develop/security

### Community Resources
- **amazee.io Blog**: https://amazee.io/blog
- **DrupalAtYourFingertips**: https://www.drupalatyourfingertips.com
- **Drupal Answers**: https://drupal.stackexchange.com
- **Drupal Slack**: https://drupal.slack.com
