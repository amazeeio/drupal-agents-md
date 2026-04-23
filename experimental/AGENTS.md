# AGENTS.md: AI Agent Guide for Drupal Development

**AI Agent Instructions**: Follow these guidelines for consistent, high-quality contributions. This file contains essential rules only — detailed patterns and code examples live in the **knowledge base** at `.kb/`. Read the relevant `.kb/` files before writing any Drupal code.

## Project Overview

- **Core**: Drupal 10.x / 11.x (verify: `composer show drupal/core`)
- **PHP**: 8.3+ | **Drush**: 13+ | **Composer**: 2.0+
- **Location**: Always run commands from project root

## Code Standards (always enforced)

- **PHP**: 2-space indent, ≤80 char lines, CamelCase classes, snake_case vars, full PHPDoc
- **YAML**: 2-space indent, lowercase keys
- **Twig**: `{{ }}` output, `{% %}` logic, always `|e`
- **Lint**: `vendor/bin/phpcs --standard=Drupal .` — reject code that fails
- See → [`.kb/02-code-standards.md`](.kb/02-code-standards.md)

## Critical Rules (read before coding)

- **Use dependency injection**, never `\Drupal::` static calls in services/controllers/plugins
- **Always set `accessCheck(TRUE)`** on entity queries (required Drupal 10.2+)
- **Always add `#cache` metadata** to render arrays that depend on data
- **Never use `|raw` in Twig** or `#markup` with user input
- See → [`.kb/12-anti-patterns.md`](.kb/12-anti-patterns.md) (14 rules)

## Knowledge Base — Read What You Need

The `.kb/` folder contains focused guides with code examples. Read only the files relevant to your current task.

| File                                                             | When to read                                    |
| ---------------------------------------------------------------- | ----------------------------------------------- |
| [`.kb/00-index.md`](.kb/00-index.md)                             | **Full index** with all topics and descriptions |
| [`.kb/01-project-overview.md`](.kb/01-project-overview.md)       | Tech stack, requirements, conventions           |
| [`.kb/02-code-standards.md`](.kb/02-code-standards.md)           | Coding standards and linting                    |
| [`.kb/03-module-scaffolding.md`](.kb/03-module-scaffolding.md)   | Creating a new module                           |
| [`.kb/04-services-di.md`](.kb/04-services-di.md)                 | Services, dependency injection                  |
| [`.kb/05-entity-api.md`](.kb/05-entity-api.md)                   | Entity loading, queries, creation               |
| [`.kb/06-plugins.md`](.kb/06-plugins.md)                         | Plugin system (blocks, fields, etc.)            |
| [`.kb/07-hooks.md`](.kb/07-hooks.md)                             | Hook implementations                            |
| [`.kb/08-forms.md`](.kb/08-forms.md)                             | Forms API (simple, config, AJAX)                |
| [`.kb/09-routes-controllers.md`](.kb/09-routes-controllers.md)   | Routes, controllers, access                     |
| [`.kb/10-security.md`](.kb/10-security.md)                       | Security best practices                         |
| [`.kb/11-caching-performance.md`](.kb/11-caching-performance.md) | Caching, performance                            |
| [`.kb/12-anti-patterns.md`](.kb/12-anti-patterns.md)             | What NOT to do (14 rules)                       |
| [`.kb/13-testing.md`](.kb/13-testing.md)                         | Unit, Kernel, Functional tests                  |
| [`.kb/14-events.md`](.kb/14-events.md)                           | EventSubscribers                                |
| [`.kb/15-configuration.md`](.kb/15-configuration.md)             | Config management                               |
| [`.kb/16-batch-queue.md`](.kb/16-batch-queue.md)                 | Batch API, Queue API                            |
| [`.kb/17-render-api.md`](.kb/17-render-api.md)                   | Render arrays, #attached, lazy builders         |
| [`.kb/18-migration.md`](.kb/18-migration.md)                     | Migration API                                   |
| [`.kb/19-composer.md`](.kb/19-composer.md)                       | Composer management                             |
| [`.kb/20-javascript.md`](.kb/20-javascript.md)                   | Drupal behaviors, libraries                     |
| [`.kb/21-workflow.md`](.kb/21-workflow.md)                       | Dev commands, debugging, Drush                  |
| [`.kb/22-troubleshooting.md`](.kb/22-troubleshooting.md)         | Common issues and fixes                         |

## Before Submitting Code

```bash
vendor/bin/phpcs --standard=Drupal .    # Code style
vendor/bin/phpunit                       # Run tests
drush cr                                 # Clear caches
drush updatedb                           # Run updates
```
