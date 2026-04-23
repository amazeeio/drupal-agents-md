---
title: Hooks
description: >
  Drupal hook system: implementation patterns, common hooks with code examples,
  and best practices. Hooks live in modulename.module files — keep them thin
  and delegate complex logic to services.
tags: [hooks, hook-form-alter, hook-theme, hook-cron, hook-entity-presave]
---

# Hooks

Hooks are implemented in `modulename.module` files. Keep them thin — delegate complex logic to services.

## Common Hooks with Examples

### hook_form_alter()
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
```

### hook_theme()
```php
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
```

### hook_entity_presave()
```php
/**
 * Implements hook_entity_presave().
 */
function my_module_entity_presave(\Drupal\Core\Entity\EntityInterface $entity): void {
  if ($entity->getEntityTypeId() === 'node' && $entity->bundle() === 'article') {
    $entity->set('field_last_updated', \Drupal::time()->getRequestTime());
  }
}
```

### hook_cron()
```php
/**
 * Implements hook_cron().
 */
function my_module_cron(): void {
  \Drupal::queue('my_module_processor')->createItem(['type' => 'cleanup']);
}
```

## Key Points
- **Naming**: Custom hooks follow `hook_modulename_action()` pattern
- **Type hints**: Always use type hints on parameters
- **Order**: Hooks fire in module weight order (lowest first)
- **Best practice**: Keep hooks focused — call services for complex logic. See [12-anti-patterns.md](12-anti-patterns.md) #14.

## Other Common Hooks
- `hook_menu_links_discovered_alter()` — Modify menu links
- `hook_theme_registry_alter()` — Modify theme hooks
- `hook_entity_delete()` — React to entity deletion
- `hook_user_insert()` / `hook_user_update()` — User lifecycle
- `hook_field_info()` — Define field types

## Related Files
- [04-services-di.md](04-services-di.md) — Where complex logic should live
- [08-forms.md](08-forms.md) — Form-related hooks
- [14-events.md](14-events.md) — EventSubscribers (alternative to many hooks)
