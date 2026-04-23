---
title: Plugin System
description: >
  Drupal's plugin system: annotation-based discovery, base classes, and the ContainerFactoryPluginInterface pattern. Includes a complete Block plugin example.


tags: [plugin, block, field-formatter, field-widget, queue-worker, annotation]
---

# Plugin System

## Plugin Types

Blocks, field formatters, field widgets, field types, menu links, QueueWorker, Condition, Action, and more.

## Block Plugin Example (with DI)

```php
namespace Drupal\my_module\Plugin\Block;

use Drupal\Core\Block\BlockBase;
use Drupal\Core\Entity\EntityTypeManagerInterface;
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

## Key Concepts

- **Discovery**: Annotation-based (as shown above) or YAML-based
- **Base classes**: Extend `BlockBase`, `FormatterBase`, `WidgetBase`, `QueueWorkerBase`, etc.
- **Placement**: `src/Plugin/<Type>/` — e.g., `src/Plugin/Block/MyBlock.php`
- **Derivatives**: Use `DeriverBase` to create multiple plugins from one definition
- **DI**: Always implement `ContainerFactoryPluginInterface` when your plugin needs services

## Related Files

- [04-services-di.md](04-services-di.md) — Dependency injection patterns
- [16-batch-queue.md](16-batch-queue.md) — QueueWorker plugin type
- [06-plugins.md](06-plugins.md) — This file (self-reference)
