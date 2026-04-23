---
title: Security Best Practices
description: >
  Drupal security requirements: input sanitization, XSS prevention, CSRF protection, SQL injection avoidance, and secure coding patterns.


tags: [security, xss, csrf, sql-injection, sanitization, permissions]
---

# Security Best Practices

## Input Sanitization

- **Render arrays**: Use `#plain_text` for untrusted content
- **Twig**: Always use `|e` filter (or rely on auto-escaping)
- **Never** use `#markup` with unsanitized user input
- **Never** use `|raw` in Twig

## CSRF Protection

- Forms with side effects automatically include CSRF tokens
- For custom forms, ensure `#token` is set

## SQL Injection

- **Always** use Entity Query — see [05-entity-api.md](05-entity-api.md)
- If you must use raw SQL, use parameterized queries:

  ```php
  $result = $this->database->query(
    "SELECT * FROM {node} WHERE type = :type",
    [':type' => $type]
  );
  ```

## XSS Prevention

```php
// ✅ Correct — safe
$build['output'] = ['#plain_text' => $user_input];

// ❌ Wrong — XSS vulnerability
$build['output'] = ['#markup' => $user_input];
```

In Twig:

```twig
{# ✅ Correct — auto-escaped #}
{{ user_input }}

{# ❌ Never do this #}
{{ user_input|raw }}
```

## Access Control

- Always set `_permission`, `_role`, or `_custom_access` on routes — see [09-routes-controllers.md](09-routes-controllers.md)
- Always use `->accessCheck(TRUE)` on entity queries — see [05-entity-api.md](05-entity-api.md)
- Check entity access: `$entity->access('view')`, `$entity->access('update')`

## File Uploads

- Validate file types and sizes via Drupal's file API
- Never trust MIME types from the client

## Credentials

- Never commit `settings.php` with credentials
- Use environment variables or `settings.local.php` (excluded from VCS)
- Never hardcode API keys — use Drupal's config or key module

## Related Files

- [12-anti-patterns.md](12-anti-patterns.md) — Security anti-patterns
- [09-routes-controllers.md](09-routes-controllers.md) — Route access control
- [05-entity-api.md](05-entity-api.md) — Safe entity queries
