---
title: Composer Management
description: >
  Managing Drupal dependencies with Composer: adding modules, applying patches, updating core, and composer.json best practices.


tags: [composer, dependencies, patches, composer-json]
---

# Composer Management

## Common Commands

```bash
# Add a module
composer require drupal/admin_toolbar

# Add a dev dependency
composer require --dev drupal/devel

# Update a single module
composer update drupal/admin_toolbar --with-dependencies

# Update Drupal core
composer update drupal/core --with-all-dependencies

# Run post-update Drush commands
drush updatedb
drush config:import
drush cr
```

## Applying Patches

Add the `composer-patches` plugin, then add patches to `composer.json`:

```json
{
  "extra": {
    "patches": {
      "drupal/some_module": {
        "Fix description": "https://www.drupal.org/files/issues/2024-01-01/issue-12345-1.patch"
      }
    }
  }
}
```

## composer.json Best Practices

- Use `drupal/core-recommended` for production
- Use `drupal/core-dev` for development (PHPUnit, PHPCS, etc.)
- Pin major versions: `"drupal/core-recommended": "^11"`
- Commit `composer.lock` to version control
- Use the `drupal.org` composer endpoint:

  ```bash
  composer config repositories.drupal composer https://packages.drupal.org/8
  ```

## Troubleshooting

```bash
# Composer memory issues
php -d memory_limit=-1 /usr/local/bin/composer install

# Resolve merge conflicts in composer.lock
git checkout --theirs composer.lock
composer install
```

## Related Files

- [01-project-overview.md](01-project-overview.md) — Tech stack
- [22-troubleshooting.md](22-troubleshooting.md) — Common issues
