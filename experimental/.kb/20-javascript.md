---
title: JavaScript & Frontend
description: >
  Drupal's JavaScript system: Drupal behaviors, library definitions,
  drupalSettings, and attaching assets to render arrays and Twig templates.
tags: [javascript, js, drupal-behaviors, libraries, drupal-settings, frontend]
---

# JavaScript & Frontend

## Drupal Behaviors (NOT jQuery document.ready)

```javascript
// js/my-module.js
(function (Drupal, drupalSettings) {
  'use strict';

  Drupal.behaviors.myModuleBehavior = {
    attach: function (context, settings) {
      // Runs on every page load AND AJAX response.
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

**Key differences from jQuery document.ready**:
- `attach()` fires on initial page load AND every AJAX response
- `context` scopes to the added/changed DOM fragment
- `detach()` handles cleanup for removed content
- Use vanilla JS — jQuery is deprecated in Drupal

## Library Definition (my_module.libraries.yml)
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

CSS weight categories (lightest to heaviest): `base`, `layout`, `component`, `state`, `theme`.

## Attaching Libraries

```php
// In render array (PHP)
$build['#attached']['library'][] = 'my_module/my_module.styles';
```

```twig
{# In Twig template #}
{{ attach_library('my_module/my_module.styles') }}
```

## Passing Data to JS (drupalSettings)
```php
$build['#attached']['drupalSettings']['my_module'] = [
  'endpoint' => '/api/items',
  'apiKey' => $config->get('api_key'),
];
```

Access in JS: `drupalSettings.my_module.endpoint`

## Related Files
- [17-render-api.md](17-render-api.md) — #attached property
- [08-forms.md](08-forms.md) — AJAX forms
