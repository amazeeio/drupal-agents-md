---
title: Troubleshooting Common Issues
description: >
  Solutions to common Drupal development problems: installation failures,
  performance issues, module/theme problems, and testing configuration.
tags: [troubleshooting, errors, debugging, fixes, common-issues]
---

# Troubleshooting Common Issues

## Installation Problems
```bash
# Composer memory issues
php -d memory_limit=-1 /usr/local/bin/composer install

# Permission issues
chmod 755 sites/default/files
chmod 644 sites/default/settings.php
chown -R www-data:www-data sites/default/files

# Database connection failed
drush sql:connect    # Test connection

# PHP extensions missing
php -m               # Check installed extensions
```

## Performance Issues
```bash
# Identify slow queries
drush sql:query "SELECT * FROM watchdog WHERE type = 'php' ORDER BY wid DESC LIMIT 10"

# Check cache settings
drush config:get system.performance
```

## Module/Theme Development Issues
```bash
# Most issues are solved by clearing caches
drush cr

# Service not found after adding a service
drush cr                                    # Rebuild service container
drush config:get core.extension             # Check module is enabled

# Twig template not loading
drush cr                                    # Clear theme registry
drush twig:debug                            # Enable debug mode to see suggestions

# Cron issues
drush cron
drush watchdog:show --type=cron
```

## Testing Issues
```bash
# PHPUnit not configured
cp web/core/phpunit.xml.dist phpunit.xml
# Edit phpunit.xml for SIMPLETEST_DB and SIMPLETEST_BASE_URL

# Database for testing
# SIMPLETEST_DB=mysql://root:password@localhost/drupal_test
# SIMPLETEST_BASE_URL=http://127.0.0.1:8888

# Browser tests failing
# Install ChromeDriver: composer require --dev drupal/drupal-driver
# Or install Selenium
```

## White Screen of Death (WSOD)
```bash
# Check PHP error logs
tail -f /var/log/apache2/error.log    # Apache
tail -f /var/log/nginx/error.log      # Nginx

# Enable error reporting in settings.php
# $config['system.logging']['error_level'] = 'verbose';

# Check watchdog
drush watchdog:show --severity=Error
```

## "The website encountered an unexpected error"
```bash
drush cr                    # Clear caches first
drush watchdog:show --severity=Error    # Read error details
drush updatedb              # Run pending updates
```

## Related Files
- [21-workflow.md](21-workflow.md) — Debugging commands
- [11-caching-performance.md](11-caching-performance.md) — Performance tuning
- [19-composer.md](19-composer.md) — Composer issues
