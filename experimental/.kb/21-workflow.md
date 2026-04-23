---
title: Development Workflow & Debugging
description: >
  Essential Drush commands for development, debugging tables for cache, config, modules, entities, and performance profiling. Version control workflow conventions.


tags: [drush, debugging, workflow, commands, profiling, version-control]
---

# Development Workflow & Debugging

## Essential Commands

```bash
drush cr                    # Clear all caches
drush config:export         # Export configuration
drush config:import         # Import configuration
drush config:diff           # Compare config with directory
drush sql:dump              # Export database
drush sql:cli               # Access database CLI
drush updatedb              # Run database updates
```

## Core Debugging

| Command                     | Purpose                                                      |
| --------------------------- | ------------------------------------------------------------ |
| `drush status`              | Drupal root, DB connection, Drush version                    |
| `drush watchdog:show`       | Recent log entries. Filters: `--severity=Error` `--type=php` |
| `drush watchdog:delete all` | Clear watchdog log                                           |
| `drush sql:query "..."`     | Direct SQL for large logs                                    |

## Cache Debugging

| Command                            | Purpose                      |
| ---------------------------------- | ---------------------------- |
| `drush cache:rebuild` / `drush cr` | Rebuild all caches           |
| `drush cache:get <bin>:<cid>`      | Retrieve specific cache item |
| `drush cache:clear <bin>`          | Clear one cache bin          |

## Config Debugging

| Command                                 | Purpose                |
| --------------------------------------- | ---------------------- |
| `drush config:get <name>`               | Show config value      |
| `drush config:set <name> <key> <value>` | Temp change            |
| `drush config:export` / `drush cex`     | Export config          |
| `drush config:import` / `drush cim`     | Import config          |
| `drush config:delete <name>`            | Remove orphaned config |

## Module/Theme Debugging

| Command                                        | Purpose                                 |
| ---------------------------------------------- | --------------------------------------- |
| `drush pm:list --type=module --status=enabled` | List enabled modules                    |
| `drush pm:enable <module>`                     | Enable module                           |
| `drush pm:uninstall <module>`                  | Fully uninstall (removes config + data) |
| `drush theme:debug`                            | Theme suggestions                       |

## Entity & DB Debugging

| Command                 | Purpose                           |
| ----------------------- | --------------------------------- |
| `drush sql:connect`     | Show DB connection command        |
| `drush entity:info`     | Entity type definitions           |
| `drush php`             | Interactive PHP shell with Drupal |
| `drush php:eval "code"` | Execute PHP in Drupal context     |

## Performance Profiling

```bash
drush cr                                          # Rebuild caches
drush sql:query "EXPLAIN ANALYZE SELECT ..."      # Query analysis
drush config:get system.performance               # Check perf settings
# Enable Webprofiler module for detailed profiling
```

## Twig Debugging

```bash
drush twig:debug              # Enable/disable Twig debug mode
```

## Version Control

- **Commit format**: `[#123456] Brief descriptive title`
- **Branch from**: `develop` for features
- **Atomic commits**: One logical change per commit
- **Before push**: lint + test + `drush cr` + `drush updatedb`

## Related Files

- [15-configuration.md](15-configuration.md) — Config workflow
- [11-caching-performance.md](11-caching-performance.md) — Caching strategies
- [22-troubleshooting.md](22-troubleshooting.md) — Common issues
