---
title: Project Overview
description: >
  Core technology stack, environment requirements, and project conventions
  for Drupal 10.x/11.x development. Read this file to understand the project's
  technical foundation.
tags: [overview, setup, prerequisites, stack]
---

# Project Overview

## Technology Stack
- **Core**: Drupal 10.x / 11.x — verify version with `composer show drupal/core`
- **PHP**: 8.3+ with extensions: gd, xml, mbstring, json, pdo, curl, zip
- **Database**: MySQL 8.0+ or PostgreSQL 12+
- **Web Server**: Apache 2.4+ or Nginx 1.18+
- **Package Manager**: Composer 2.0+
- **CLI Tool**: Drush 13+
- **Version Control**: Git

## Key Components
- Custom modules → `modules/custom/<module_name>` (or `web/modules/custom/`)
- Custom themes → `themes/custom/<theme_name>` (or `web/themes/custom/`)
- Configuration → managed via Drush `config:export` / `config:import`
- Profiles → `profiles/custom/<profile_name>`
- Composer dependencies → managed via `composer.json` / `composer.lock`

## Important Conventions
- Always run commands from the **project root** unless specified otherwise
- Never commit database credentials — use environment variables or `settings.local.php`
- Follow Drupal coding standards — see [02-code-standards.md](02-code-standards.md)
- Use dependency injection — see [04-services-di.md](04-services-di.md)
- Always add cacheability metadata — see [11-caching-performance.md](11-caching-performance.md)

## Verify Your Environment
```bash
php -v                    # PHP 8.3+
composer --version        # Composer 2.0+
drush --version           # Drush 13+
php -m                    # Check required extensions
drush status              # Verify Drupal installation
```

## Related Files
- [02-code-standards.md](02-code-standards.md) — Coding standards and linting
- [21-workflow.md](21-workflow.md) — Development commands and debugging
- [19-composer.md](19-composer.md) — Composer management
