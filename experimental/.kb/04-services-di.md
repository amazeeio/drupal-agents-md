---
title: Services & Dependency Injection
description: >
  How to define, register, and use Drupal services with dependency injection.
  Covers service definitions, constructor injection, ContainerFactoryPluginInterface,
  and core service discovery. ALWAYS prefer DI over static \Drupal:: calls.
tags: [services, dependency-injection, di, container, service-container]
---

# Services & Dependency Injection

## Define a Service

**my_module.services.yml**:
```yaml
services:
  my_module.my_service:
    class: Drupal\my_module\Service\MyService
    arguments: ['@entity_type.manager', '@logger.factory', '@config.factory']
    tags:
      - { name: backend_overridable }
```

## Use Dependency Injection

### In Controllers
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
    return ['#theme' => 'item_list', '#items' => []];
  }
}
```

### In Plugins
```php
use Drupal\Core\Plugin\ContainerFactoryPluginInterface;

class MyBlock extends BlockBase implements ContainerFactoryPluginInterface {

  public function __construct(
    array $configuration,
    string $plugin_id,
    mixed $plugin_definition,
    protected EntityTypeManagerInterface $entityTypeManager,
  ) {
    parent::__construct($configuration, $plugin_id, $plugin_definition);
  }

  public static function create(ContainerInterface $container, array $configuration, $plugin_id, $plugin_definition): static {
    return new static(
      $configuration,
      $plugin_id,
      $plugin_definition,
      $container->get('entity_type.manager'),
    );
  }
}
```

## Common Core Services
| Service ID | Purpose |
|---|---|
| `@entity_type.manager` | Entity loading and queries |
| `@config.factory` | Read/write configuration |
| `@logger.factory` | Logging (watchdog) |
| `@current_user` | Current user account |
| `@database` | Database connection |
| `@module_handler` | Module system |
| `@renderer` | Render API |
| `@string_translation` | Translation (`t()`) |
| `@messenger` | Status messages to user |
| `@request_stack` | HTTP request |
| `@state` | State API (transient data) |

## Service Discovery
```bash
drush php:eval "print_r(\Drupal::getContainer()->getServiceIds());"
```

## Rules
- **ALWAYS** use dependency injection in services, controllers, and plugins
- **NEVER** use `\Drupal::` static calls in services/controllers/plugins — see [12-anti-patterns.md](12-anti-patterns.md)
- The only acceptable `\Drupal::` use is in `.module` hook functions — and even there, delegate to a service

## Related Files
- [05-entity-api.md](05-entity-api.md) — Using entity_type.manager service
- [06-plugins.md](06-plugins.md) — DI in plugins
- [12-anti-patterns.md](12-anti-patterns.md) — Why static calls are bad
