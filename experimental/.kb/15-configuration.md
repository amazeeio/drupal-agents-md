---
title: Configuration Management
description: >
  Drupal's Configuration API: schema definition, install vs optional config, reading/writing config, config split for per-environment settings, and Drush config workflow commands.


tags: [configuration, config, config-schema, config-split, drush-cex]
---

# Configuration Management

## Config Schema (config/schema/my_module.schema.yml)

```yaml
my_module.settings:
  type: config_object
  label: "My Module settings"
  mapping:
    api_key:
      type: string
      label: "API Key"
    max_items:
      type: integer
      label: "Maximum items"
    enabled_types:
      type: sequence
      label: "Enabled content types"
      sequence:
        type: string
        label: "Content type"
```

## Install vs Optional Config

- **`config/install/`** — Installed when module is enabled (required)

  ```yaml
  # config/install/my_module.settings.yml
  api_key: ""
  max_items: 50
  enabled_types:
    - article
  ```

- **`config/optional/`** — Installed only if dependencies are met (e.g., a field config that requires a content type from another module)

## Reading Config

```php
// In a service/controller (injected — preferred)
$value = $this->configFactory->get('my_module.settings')->get('api_key');

// In a .module file (less preferred)
$value = \Drupal::config('my_module.settings')->get('api_key');
```

## Writing Config

```php
$this->configFactory->getEditable('my_module.settings')
  ->set('api_key', 'new-value')
  ->save();
```

## Config Override (settings.php)

```php
// Environment-specific overrides (not exported)
$config['system.performance']['css']['preprocess'] = FALSE;
$config['system.performance']['js']['preprocess'] = FALSE;
```

## Drush Config Workflow

```bash
drush config:export         # Export active config to sync directory
drush config:import         # Import from sync directory
drush config:get <name>     # Show config value
drush config:set <name> <key> <value>  # Change config
drush config:edit <name>    # Edit in editor
drush config:delete <name>  # Remove config object
```

## Config Split (per-environment)

Use the `config_split` module to manage different configurations for dev/staging/prod:

- Dev: disable CSS aggregation, enable Devel
- Staging: disable CSS aggregation, disable Devel
- Prod: enable everything

## Related Files

- [08-forms.md](08-forms.md) — ConfigFormBase for config UIs
- [15-configuration.md](15-configuration.md) — This file (self-reference)
