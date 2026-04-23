# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased] — 2025-04-23

### Added
- **Lagoon/AGENTS.md**: New variant for amazee.io Lagoon (Kubernetes-based hosting)
  - Lagoon CLI commands and configuration
  - lagoon-sync for database and file synchronization
  - Environment variables (`LAGOON_PROJECT`, `LAGOON_ENVIRONMENT_TYPE`, etc.)
  - Drush alias integration for remote operations
  - Post-rollout task configuration
  - Redis and Varnish configuration for Lagoon
- **CONTRIBUTING.md**: Structured contributing guide with PR template and review criteria
- **CHANGELOG.md**: This file
- **CI workflow**: GitHub Actions for markdown linting, YAML validation, and link checking
- **Internal table of contents** in all AGENTS.md variants for quick navigation
- **Module scaffolding template**: Full file structure with minimal module files (info.yml, composer.json)
- **Anti-patterns section**: 14 "Never Do This" guidelines across all variants
- **Concrete code examples** for all major patterns:
  - Services with dependency injection (YAML + PHP)
  - Entity queries with `accessCheck(TRUE)`
  - Block plugin with annotations
  - Hooks: `hook_form_alter`, `hook_theme`, `hook_entity_presave`, `hook_cron`
  - Forms: simple form with AJAX + config form
  - Routes with custom access checker
  - EventSubscriber with service tag
  - Batch API with `BatchBuilder`
  - QueueWorker plugin
  - Render API with caching
  - Migration source/process/destination
  - Drupal behaviors (JavaScript)
  - Configuration schema and install files
- **New development topics** across all variants:
  - Events & EventSubscribers
  - Configuration Management (schema, install, optional, config split)
  - Render API deep dive
  - Migration API with custom process plugin
  - Composer management best practices
  - JavaScript & Drupal behaviors
  - Content Moderation & Workflows
- **Complete test examples**:
  - Unit test with Prophecy mocking
  - Kernel test with entity schema
  - Functional test with browser assertions
- **Version compatibility table** in README

### Changed
- Updated PHP requirement from 8.1+ to **8.3+**
- Updated Drupal version from "10.x+" to **"10.x / 11.x"**
- Updated Drush version from 12+ to **13+**
- DDEV config updated to use PHP 8.3
- README updated with Lagoon variant, version compatibility table, and improved structure

### Fixed
- Fixed broken markdown code fence in Vanilla/AGENTS.md (Performance Issues section)
- Expanded `.gitignore` with `.cursor`, `.DS_Store`, and `*.swp`
