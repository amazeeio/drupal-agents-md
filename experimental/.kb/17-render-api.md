---
title: Render API Deep Dive
description: >
  Drupal's Render API: render arrays, #cache, #attached, #lazy_builder,
  #create_placeholder, #pre_render, #post_render, and render element types.
tags: [render, render-array, attached, lazy-builder, placeholder, theme]
---

# Render API

## Complete Render Array Example

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
  '#weight' => 10,
];
```

## Key Properties

| Property | Purpose |
|---|---|
| `#type` | Render element type (`container`, `html_tag`, `item_list`, etc.) |
| `#theme` | Theme hook to use for rendering |
| `#markup` | Raw HTML (trusted only!) |
| `#plain_text` | Auto-escaped text output |
| `#cache` | Cache metadata (keys, tags, contexts, max-age) |
| `#attached` | Libraries, settings, HTTP headers |
| `#weight` | Sort order |
| `#attributes` | HTML attributes (class, id, data-*) |
| `#access` | Boolean access check |
| `#lazy_builder` | Deferred rendering callback |
| `#create_placeholder` | Generate BigPipe placeholder |
| `#pre_render` | Callbacks to modify before rendering |
| `#post_render` | Callbacks to modify after rendering |

## #attached — Libraries & Settings
```php
$build['#attached'] = [
  'library' => ['my_module/my_module.styles'],
  'drupalSettings' => [
    'my_module' => ['endpoint' => '/api/items'],
  ],
];
```

## #lazy_builder — Deferred Rendering
```php
$build['expensive'] = [
  '#lazy_builder' => [
    '\Drupal\my_module\Service\MyLazyBuilder::renderContent',
    [$param1, $param2],
  ],
  '#create_placeholder' => TRUE,
];
```

## Common Render Element Types
`container`, `html_tag`, `item_list`, `link`, `table`, `status_messages`, `more_link`, `operations`

## Related Files
- [11-caching-performance.md](11-caching-performance.md) — Cache metadata details
- [20-javascript.md](20-javascript.md) — Attaching JS libraries
- [08-forms.md](08-forms.md) — Forms use render arrays
