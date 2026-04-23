---
title: Code Style and Standards
description: >
  Drupal coding standards, linting rules, and code quality enforcement. These rules MUST be followed on every code change. Reject any code that fails Drupal Coder sniffs.


tags: [standards, php, yaml, twig, linting, phpcs, code-style]
---

# Code Style and Standards

Adhere to Drupal coding standards (PSR-12 with Drupal extensions). Use Coder and PHPCS for enforcement.

## PHP

- **Indentation**: 2 spaces (no tabs)
- **Line length**: ≤ 80 characters
- **Naming**: CamelCase for classes/methods, snake_case for variables/functions
- **Braces**: Always use braces, even for single-line if/else
- **Returns**: Prefer early returns to reduce nesting
- **Docblocks**: Full PHPDoc blocks with `@param`, `@return`, `@throws`
- **Type hints**: Always use return type declarations and parameter types

## YAML

- 2-space indentation, lowercase keys
- Quote strings that contain special characters

## Twig

- Output: `{{ variable }}`
- Logic: `{% if condition %}{% endif %}`
- **Always escape** with `|e` filter (auto-escaping is on by default, but be explicit for safety)
- Never use `|raw` — see [12-anti-patterns.md](12-anti-patterns.md)

## Linting Commands

```bash
# Check code style
vendor/bin/phpcs --standard=Drupal --extensions=php,inc,module,install,info,yml src/

# Check best practices
vendor/bin/phpcs --standard=DrupalPractice --extensions=php,inc,module,install,info,yml src/

# Auto-fix style issues
vendor/bin/phpcs --standard=Drupal --fix src/
```

## Static Analysis

```bash
vendor/bin/phpstan analyse           # PHPStan
vendor/bin/psalm                     # Psalm
vendor/bin/drupal-check              # Check for deprecated code
composer audit                       # Security advisories
```

**Reject any code that fails Drupal Coder sniffs.**

## Related Files

- [12-anti-patterns.md](12-anti-patterns.md) — What NOT to do
- [13-testing.md](13-testing.md) — Testing standards
