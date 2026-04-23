---
title: Entity API & Queries
description: >
  Loading, creating, querying, and accessing field values on Drupal entities.
  Covers EntityTypeManager, entity queries with accessCheck(TRUE), and field
  access patterns.
tags: [entity, node, entity-query, field-api, entity-type-manager]
---

# Entity API & Queries

## Loading Entities

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

## Entity Queries (always prefer over raw SQL)

```php
// With injected service (preferred)
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

> ⚠️ **`accessCheck(TRUE)` is required** on Drupal 10.2+. Omitting it throws deprecation warnings. See [12-anti-patterns.md](12-anti-patterns.md) #7.

## Creating Entities

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

## Field Access

```php
// ✅ Correct — explicit field access
$node->get('field_my_field')->value;
$node->get('field_my_field')->entity;      // Entity reference
$node->get('field_my_field')->target_id;   // Entity reference ID

// ❌ Avoid — magic __get (works but less explicit)
$node->field_my_field->value;
```

## Common Operations

```php
$node->label();                          // Get title/label
$node->bundle();                         // Get content type
$node->getEntityTypeId();                // Get entity type ('node', 'user', etc.)
$node->id();                             // Get entity ID
$node->isPublished();                    // Check published status
$node->set('title', 'New Title');        // Set a field value
$node->save();                           // Save changes
$node->delete();                         // Delete entity
```

## Related Files
- [04-services-di.md](04-services-di.md) — Injecting entity_type.manager
- [11-caching-performance.md](11-caching-performance.md) — Cache tags for entities
- [12-anti-patterns.md](12-anti-patterns.md) — accessCheck, deprecated functions
