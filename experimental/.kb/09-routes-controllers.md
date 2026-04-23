---
title: Routes & Controllers
description: >
  Drupal routing system, controller classes, route parameters, and custom access checkers. Includes complete YAML route definitions and PHP examples.


tags: [routing, controllers, routes, access-checker, permissions]
---

# Routes & Controllers

## Route Definitions (my_module.routing.yml)

```yaml
# Basic controller route with parameter upcasting
my_module.content:
  path: "/my-module/{node}"
  defaults:
    _controller: '\Drupal\my_module\Controller\MyController::content'
    _title: "My Module Page"
  requirements:
    _permission: "access content"
    node: \d+

# Form route
my_module.settings:
  path: "/admin/config/my-module/settings"
  defaults:
    _form: '\Drupal\my_module\Form\SettingsForm'
    _title: "My Module Settings"
  requirements:
    _permission: "administer site configuration"

# Route with custom access checker
my_module.custom_access:
  path: "/my-module/custom/{node}"
  defaults:
    _controller: '\Drupal\my_module\Controller\MyController::customPage'
    _title_callback: '\Drupal\my_module\Controller\MyController::pageTitle'
  requirements:
    _custom_access: '\Drupal\my_module\Access\MyAccessChecker::access'
```

## Controller with Dependency Injection

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

## Custom Access Checker

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

Register as a service with the `access_check` tag:

```yaml
# my_module.services.yml
my_module.access_checker:
  class: Drupal\my_module\Access\MyAccessChecker
  tags:
    - { name: access_check }
```

## Access Control Options

- `_permission: 'permission name'` — Permission-based
- `_role: 'role_name'` — Role-based
- `_access: 'TRUE'` — Public route
- `_custom_access: '::method'` — Custom logic
- `_entity_access: 'node.view'` — Entity-level access

## Related Files

- [04-services-di.md](04-services-di.md) — DI in controllers
- [10-security.md](10-security.md) — Security best practices
- [08-forms.md](08-forms.md) — Routing forms
