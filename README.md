# Drupal AI Agent Development Guides

This repository contains specialized AGENTS.md files designed for AI coding agents working on Drupal projects. These guides provide comprehensive instructions for Drupal development following modern best practices.

> **⚠️ Warning: Work in Progress**
> This is an evolving project. The guides are actively being refined and updated. Use with caution and always test in development environments.

## Table of Contents

- [Available Guides](#available-guides)
- [Version Compatibility](#version-compatibility)
- [What's Included](#whats-included)
- [How to Use AGENTS.md?](#how-to-use-agentsmd)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Contributing](#contributing)
- [Resources](#resources)

## Available Guides

### 🐳 [DDEV/AGENTS.md](./DDEV/AGENTS.md)
**For Docker-based development with DDEV**

- **Environment**: DDEV (Docker-based local development)
- **Setup**: DDEV configuration and initialization
- **Commands**: `ddev exec` prefixed commands
- **Features**: Container-based workflow, snapshot management, integrated debugging
- **Best for**: Modern containerized development environments

### 🖥️ [Vanilla/AGENTS.md](./Vanilla/AGENTS.md)
**For traditional server-based development**

- **Environment**: Traditional LAMP/LEMP stack
- **Setup**: Direct Apache/Nginx, MySQL, PHP installation
- **Commands**: Direct shell commands
- **Features**: Traditional server configuration, direct file system access
- **Best for**: Classic server environments, hosting providers, manual infrastructure

### ☸️ [Lagoon/AGENTS.md](./Lagoon/AGENTS.md)
**For amazee.io Lagoon (Kubernetes-based hosting)**

- **Environment**: amazee.io Lagoon with Kubernetes
- **Setup**: Lagoon CLI, lagoon-sync, Drush aliases
- **Commands**: Lagoon CLI + Drush alias commands
- **Features**: Auto-deployment, environment variables, Varnish, Redis, post-rollout tasks
- **Best for**: Projects hosted on amazee.io Lagoon or self-hosted Lagoon

## Version Compatibility

| AGENTS.md Variant | Drupal | PHP | Drush | Special Requirements |
|---|---|---|---|---|
| DDEV | 10.x / 11.x | 8.3+ | 13+ | DDEV 1.23+ |
| Vanilla | 10.x / 11.x | 8.3+ | 13+ | LAMP/LEMP stack |
| Lagoon | 10.x / 11.x | 8.3+ | 13+ | Lagoon CLI, lagoon-sync |

## What's Included

Each AGENTS.md file contains:

### 📚 **Development Patterns** (with code examples)
- Services & Dependency Injection
- Entity API & Queries
- Plugin System
- Hooks Implementation
- Forms API (simple + config forms)
- Routes & Controllers
- Access Control
- Batch API & Queue API
- AJAX Forms
- Events & EventSubscribers
- Render API
- Migration API
- Configuration Management
- Composer Management
- JavaScript & Drupal Behaviors
- Content Moderation & Workflows

### 🛡️ **Security & Performance**
- Security best practices
- Performance optimization
- Caching strategies (render, Varnish, Redis)
- Lazy builders and placeholder strategies

### 🧪 **Testing & Quality** (with code examples)
- PHPUnit testing framework
- Unit, Kernel, and Functional test stubs
- Code quality tools (PHPStan, Psalm, PHPCS)
- JavaScript testing

### 🚫 **Anti-Patterns**
- 14 common mistakes to avoid
- Clear "Never Do This" guidelines

### 🔧 **Development Workflow**
- Module scaffolding template with full file structure
- Environment-specific commands
- Debugging tools and tables
- Performance profiling
- Troubleshooting common issues

## How to Use AGENTS.md?

1. **Get the repository**
   Download or clone this repository to your computer

2. **Extract the files** (if downloading)
   Extract the downloaded ZIP file and open the folder

3. **Copy the right AGENTS.md file**
   - If you use DDEV for development:
     - Navigate to the `DDEV` folder
     - Copy the `AGENTS.md` file
     - Paste it in your Drupal project's main folder
   - If you use a traditional server setup:
     - Navigate to the `Vanilla` folder
     - Copy the `AGENTS.md` file
     - Paste it in your Drupal project's main folder
   - If you use amazee.io Lagoon:
     - Navigate to the `Lagoon` folder
     - Copy the `AGENTS.md` file
     - Paste it in your Drupal project's main folder

4. **Start your AI agent** — Open your AI coding tool (Cursor, Claude Code, etc.) in the project directory. It will automatically read the AGENTS.md file.

## Key Features

### ✅ **What We Provide**
- Comprehensive Drupal development patterns with concrete code examples
- Environment-specific instructions (DDEV, Vanilla, Lagoon)
- Security and performance guidelines
- Testing strategies with complete test class stubs
- Anti-patterns section ("Never Do This")
- Full module scaffolding template
- Configuration management guidance
- Migration API examples
- Troubleshooting guides

### ❌ **What We Don't Include**
- Infrastructure setup tutorials
- Server configuration details
- Basic Drupal installation guides
- Apache/Nginx configuration
- Drupal 7/8/9 specific guidance

## Architecture

The guides follow the [agents.md](https://agents.md) standard format:
- **Simple, open format** for AI coding agents
- **Living documentation** that evolves with Drupal
- **Environment-specific versions** for different setups
- **Code-first content** with concrete, copy-pasteable examples
- **Internal table of contents** for quick navigation within each guide

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for detailed guidelines on how to contribute to this project.

## Changelog

See [CHANGELOG.md](./CHANGELOG.md) for a history of changes.

## Resources

- **Drupal Documentation**: [drupal.org/docs](https://www.drupal.org/docs)
- **Drupal API**: [api.drupal.org](https://api.drupal.org)
- **DrupalAtYourFingertips**: [drupalatyourfingertips.com](https://www.drupalatyourfingertips.com)
- **amazee.io Docs**: [docs.lagoon.sh](https://docs.lagoon.sh)
- **agents.md Standard**: [agents.md](https://agents.md)

---

**Note**: These guides focus on Drupal 10.x+ and 11.x development patterns and modern best practices. Always adapt instructions to your specific project requirements and environment constraints.
