---
title: Migration API
description: >
  Drupal's Migration API: source, process, and destination plugins with YAML
  definitions and custom process plugin example.
tags: [migration, migrate, migrate-api, process-plugin, source, destination]
---

# Migration API

## Migration YAML Definition

```yaml
# migrations/my_migration.yml
id: my_migration
label: 'My Custom Migration'
source:
  plugin: csv
  path: /path/to/data.csv
  header_row_count: 1
  keys:
    - id
  column_names:
    -
      id: [id, 'Unique ID']
    -
      title: [title, 'Title']

process:
  title: title
  body/value: body
  body/format:
    plugin: default_value
    default_value: basic_html
  type:
    plugin: default_value
    default_value: article
  uid:
    plugin: default_value
    default_value: 1
  status:
    plugin: default_value
    default_value: 1

destination:
  plugin: entity:node
  default_bundle: article
```

## Custom Process Plugin

```php
namespace Drupal\my_module\Plugin\migrate\process;

use Drupal\migrate\ProcessPluginBase;
use Drupal\migrate\MigrateExecutableInterface;
use Drupal\migrate\Row;

/**
 * Custom process plugin.
 *
 * @MigrateProcessPlugin(
 *   id = "my_custom_process"
 * )
 */
class MyCustomProcess extends ProcessPluginBase {

  public function transform($value, MigrateExecutableInterface $migrate_executable, Row $row, $destination_property): mixed {
    return strtoupper(trim($value));
  }
}
```

## Common Source Plugins
- `csv` — CSV file (requires `migrate_source_csv`)
- `d7_node`, `d7_user` — Drupal 7 migrations
- `sql` — Direct database queries
- `url` — JSON/XML from URLs
- `embedded_data` — Inline data for testing

## Common Process Plugins
- `get` — Pass through value
- `default_value` — Set default
- `callback` — PHP function callback
- `concat` — Concatenate values
- `entity_lookup` — Look up entity by property
- `skip_on_empty` — Skip row if empty

## Common Destination Plugins
- `entity:node` — Create nodes
- `entity:user` — Create users
- `entity:taxonomy_term` — Create terms
- `config` — Write to config

## Drush Migration Commands
```bash
drush migrate:import my_migration            # Run migration
drush migrate:rollback my_migration          # Rollback
drush migrate:status                         # List migrations
drush migrate:messages my_migration          # View messages/errors
```

## Related Files
- [06-plugins.md](06-plugins.md) — Plugin system (migrate uses plugins)
- [21-workflow.md](21-workflow.md) — Drush commands
