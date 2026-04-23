---
title: Module Scaffolding Template
description: >
  Complete file structure and minimal starter files for creating a new Drupal
  custom module. Use this as a reference every time you create a new module.
tags: [module, scaffolding, template, structure, info-yml, composer]
---

# Module Scaffolding Template

When creating a new custom module, follow this structure:

```
modules/custom/my_module/
├── my_module.info.yml              # Module metadata (required)
├── my_module.module                # Hook implementations
├── my_module.routing.yml           # Route definitions
├── my_module.services.yml          # Service definitions
├── my_module.permissions.yml       # Permission definitions
├── my_module.links.menu.yml        # Menu links
├── my_module.links.action.yml      # Action links
├── my_module.links.task.yml        # Task (tab) links
├── my_module.libraries.yml         # CSS/JS libraries
├── composer.json                   # PSR-4 autoloading
├── src/
│   ├── Controller/
│   ├── Form/
│   ├── Plugin/
│   │   ├── Block/
│   │   ├── Field/
│   │   │   ├── FieldFormatter/
│   │   │   ├── FieldWidget/
│   │   │   └── FieldType/
│   │   └── QueueWorker/
│   ├── EventSubscriber/
│   ├── Access/
│   ├── Entity/
│   └── Service/
├── config/
│   ├── install/                    # Config installed with module
│   ├── optional/                   # Config if dependencies met
│   └── schema/                     # Config schema
├── templates/
├── css/
├── js/
└── tests/
    └── src/
        ├── Unit/
        ├── Kernel/
        └── Functional/
```

## Minimal Required Files

**my_module.info.yml**:
```yaml
name: 'My Module'
type: module
description: 'Custom module description.'
core_version_requirement: ^10 || ^11
package: Custom
dependencies:
  - drupal:node
  - drupal:user
```

**composer.json** (PSR-4 autoloading for tests):
```json
{
  "name": "drupal/my_module",
  "type": "drupal-custom-module",
  "description": "Custom module description.",
  "autoload": {
    "psr-4": {
      "Drupal\\my_module\\": "src/"
    }
  },
  "autoload-dev": {
    "psr-4": {
      "Drupal\\Tests\\my_module\\": "tests/src/"
    }
  }
}
```

## Related Files
- [04-services-di.md](04-services-di.md) — How to define services
- [07-hooks.md](07-hooks.md) — What goes in `.module` files
- [09-routes-controllers.md](09-routes-controllers.md) — Route definitions
- [15-configuration.md](15-configuration.md) — Config install/optional/schema
