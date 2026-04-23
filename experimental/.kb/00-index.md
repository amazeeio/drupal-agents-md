---
title: Drupal Development Knowledge Base — Index
description: >
  Master index for the Drupal AI Agent knowledge base. Read this file first to
  discover which files to load for your current task. Each file is self-contained
  with code examples, best practices, and cross-references to related topics.
tags: [index, overview, meta]
---

# Knowledge Base Index

This knowledge base contains focused, self-contained guides for Drupal 10.x/11.x development. Each file covers one topic with concrete code examples. Files are numbered for discovery — read only what you need.

## Quick Reference — When to Read What

| You are working on... | Read this file |
|---|---|
| Setting up a new module | [03-module-scaffolding.md](03-module-scaffolding.md) |
| Creating a service or using DI | [04-services-di.md](04-services-di.md) |
| Loading/querying entities | [05-entity-api.md](05-entity-api.md) |
| Building a plugin (block, field, etc.) | [06-plugins.md](06-plugins.md) |
| Implementing hooks | [07-hooks.md](07-hooks.md) |
| Building a form | [08-forms.md](08-forms.md) |
| Defining routes or controllers | [09-routes-controllers.md](09-routes-controllers.md) |
| Security concerns (XSS, CSRF, etc.) | [10-security.md](10-security.md) |
| Caching or performance | [11-caching-performance.md](11-caching-performance.md) |
| Want to know what NOT to do | [12-anti-patterns.md](12-anti-patterns.md) |
| Writing tests | [13-testing.md](13-testing.md) |
| Subscribing to events | [14-events.md](14-events.md) |
| Managing configuration | [15-configuration.md](15-configuration.md) |
| Batch or Queue processing | [16-batch-queue.md](16-batch-queue.md) |
| Render arrays, #attached, lazy builders | [17-render-api.md](17-render-api.md) |
| Data migration | [18-migration.md](18-migration.md) |
| Managing Composer dependencies | [19-composer.md](19-composer.md) |
| JavaScript or Drupal behaviors | [20-javascript.md](20-javascript.md) |
| Dev commands, debugging, Drush | [21-workflow.md](21-workflow.md) |
| Something is broken | [22-troubleshooting.md](22-troubleshooting.md) |

## Always Read First

- [01-project-overview.md](01-project-overview.md) — Tech stack, requirements, project conventions
- [02-code-standards.md](02-code-standards.md) — Coding standards and linting rules (must always be followed)

## File Listing

```
.kb/
├── 00-index.md              ← You are here
├── 01-project-overview.md   ← Tech stack, prerequisites
├── 02-code-standards.md     ← PHP/YAML/Twig coding standards
├── 03-module-scaffolding.md ← Module file structure template
├── 04-services-di.md        ← Services & dependency injection
├── 05-entity-api.md         ← Entity loading, queries, creation
├── 06-plugins.md            ← Plugin system (blocks, fields, etc.)
├── 07-hooks.md              ← Hook implementations
├── 08-forms.md              ← Forms API (simple, config, AJAX)
├── 09-routes-controllers.md ← Routes, controllers, access control
├── 10-security.md           ← Security best practices
├── 11-caching-performance.md← Caching strategies & performance
├── 12-anti-patterns.md      ← 14 "Never Do This" guidelines
├── 13-testing.md            ← Unit, Kernel, Functional tests
├── 14-events.md             ← EventSubscribers
├── 15-configuration.md      ← Config schema, install, optional, split
├── 16-batch-queue.md        ← Batch API & Queue API
├── 17-render-api.md         ← Render arrays, #attached, lazy builders
├── 18-migration.md          ← Migration API
├── 19-composer.md           ← Composer management
├── 20-javascript.md         ← Drupal behaviors, libraries
├── 21-workflow.md           ← Dev commands, debugging, profiling
└── 22-troubleshooting.md    ← Common issues and fixes
```
