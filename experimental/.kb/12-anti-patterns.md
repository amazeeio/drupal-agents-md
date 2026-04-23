---
title: Anti-Patterns — Never Do This
description: >
  14 critical Drupal development mistakes that AI agents must avoid. Every item on this list is a common error that leads to bugs, security vulnerabilities, or maintenance nightmares.


tags: [anti-patterns, best-practices, never-do-this, security, code-quality]
---

# Anti-Patterns — Never Do This

1. **Never use `\Drupal::` static calls in services, controllers, or plugins** — Use dependency injection. The only acceptable use is in `.module` hook functions. See [04-services-di.md](04-services-di.md).

2. **Never query the database directly when Entity Query suffices** — Use `$this->entityTypeManager->getStorage('node')->getQuery()`. See [05-entity-api.md](05-entity-api.md).

3. **Never use `|raw` in Twig** — Use `|e` or rely on auto-escaping. If you need raw HTML, use `#type => 'processed_text'` or `check_markup()`. See [10-security.md](10-security.md).

4. **Never create monolithic `hook_form_alter()` functions** — If the alter logic is complex, delegate to a service.

5. **Never store configuration in state that belongs in config** — State (`\Drupal::state()`) = ephemeral data (last cron, temp flags). Config (`\Drupal::configFactory()`) = structured, exportable settings. See [15-configuration.md](15-configuration.md).

6. **Never use `#markup` with unsanitized user input** — Always use `#plain_text` or `Html::escape()`. See [10-security.md](10-security.md).

7. **Never skip `accessCheck(TRUE)` on entity queries** — Required since Drupal 10.2. Omission throws deprecation warnings, will be fatal in Drupal 12. See [05-entity-api.md](05-entity-api.md).

8. **Never hardcode entity IDs, user IDs, or paths** — Use configuration, route names, and dynamic lookups.

9. **Never use `hook_views_data()` without proper table aliases** — Always prefix columns to avoid SQL ambiguity.

10. **Never ignore cacheability metadata** — Every render array that depends on data must specify `#cache` tags, contexts, and max-age. See [11-caching-performance.md](11-caching-performance.md).

11. **Never commit `settings.php` with credentials** — Use environment variables or `settings.local.php`. See [10-security.md](10-security.md).

12. **Never use `node_load()` or other deprecated procedural functions** — Use `\Drupal::entityTypeManager()->getStorage('node')->load()`. See [05-entity-api.md](05-entity-api.md).

13. **Never use global variables like `$_GET`, `$_POST`, `$_SERVER`** — Use Symfony's `Request` object via dependency injection.

14. **Never put business logic in `.module` files** — Delegate to services. The `.module` file should be thin: hooks that call services.
