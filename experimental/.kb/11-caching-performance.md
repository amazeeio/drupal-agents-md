---
title: Caching & Performance
description: >
  Drupal caching strategies: render cache, cache tags, contexts, max-age, lazy builders, placeholder strategy, and Redis/Memcache. Every render array that depends on data MUST specify cache metadata.


tags: [cache, performance, render-cache, cache-tags, lazy-builder, redis]
---

# Caching & Performance

## Cache Metadata (Required on Every Render Array)

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

## Cache Tags

Invalidate when the underlying data changes:

```php
// Entity-specific
['node:123', 'node:456']

// List-level (invalidated when ANY node changes)
['node_list']

// Config
['config:system.site']
```

## Cache Contexts

Vary output by:

```php
['user.roles']              // Different per role
['user.permissions']        // Different per permission set
['languages:language_content']  // Different per language
['url']                     // Different per URL
['ip']                      // Different per IP
```

## Lazy Builders (for expensive operations)

```php
$build['expensive'] = [
  '#lazy_builder' => [
    '\Drupal\my_module\Service\MyLazyBuilder::renderExpensiveContent',
    [$param1, $param2],
  ],
  '#create_placeholder' => TRUE,
];
```

## Caching Strategies

| Strategy                | Use Case                                |
| ----------------------- | --------------------------------------- |
| **Render cache**        | Cache complex markup with tags/contexts |
| **Dynamic page cache**  | Auto-cached for anonymous users         |
| **Internal page cache** | Full page cache for anonymous           |
| **Entity cache**        | Automatic — invalidate via cache tags   |
| **Redis/Memcache**      | Production distributed caching          |

## Performance Rules

- Always add `#cache` to render arrays that depend on data
- Use `loadMultiple()` instead of individual `load()` calls
- Use entity queries instead of raw SQL — see [05-entity-api.md](05-entity-api.md)
- Profile before optimizing — identify actual bottlenecks

## Server Tuning

```bash
# php.ini
memory_limit = 256M
max_execution_time = 300

# my.cnf
innodb_buffer_pool_size = 1G
```

## Related Files

- [17-render-api.md](17-render-api.md) — Full render array reference
- [05-entity-api.md](05-entity-api.md) — Entity queries
- [12-anti-patterns.md](12-anti-patterns.md) — Missing cache metadata (#10)
