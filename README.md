# Drupal AI Agent Development Guides

This repository contains specialized AGENTS.md files designed for AI coding agents working on Drupal projects. These guides provide comprehensive instructions for Drupal development following modern best practices.

> **⚠️ Warning: Work in Progress**
> This is an evolving project. The guides are actively being refined and updated. Use with caution and always test in development environments.

## Table of Contents

- [Available Guides](#available-guides)
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

## What's Included

Each AGENTS.md file contains:

### 📚 **Development Patterns**
- Services & Dependency Injection
- Entity API & Queries
- Plugin System
- Hooks Implementation
- Forms API
- Routes & Controllers
- Batch API & Queue API
- AJAX Forms

### 🛡️ **Security & Performance**
- Security best practices
- Performance optimization
- Caching strategies
- Render caching techniques

### 🧪 **Testing & Quality**
- PHPUnit testing framework
- Unit, Kernel, and Functional tests
- Code quality tools
- JavaScript testing

### 🔧 **Development Workflow**
- Essential commands
- Debugging tools
- Performance profiling
- Troubleshooting common issues

### 📋 **Best Practices**
- Drupal coding standards
- Version control workflow
- Pull request guidelines

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
   - If you use traditional server setup:
     - Navigate to the `Vanilla` folder
     - Copy the `AGENTS.md` file
     - Paste it in your Drupal project's main folder

## Key Features

### ✅ **What We Provide**
- Comprehensive Drupal development patterns
- Environment-specific instructions
- Security and performance guidelines
- Testing strategies and quality assurance
- Troubleshooting common issues

### ❌ **What We Don't Include**
- Infrastructure setup tutorials
- Server configuration details
- Environment variable examples
- Apache/Nginx configuration
- Basic Drupal installation

## Architecture

The guides follow the [agents.md](https://agents.md) standard format:
- **Simple, open format** for AI coding agents
- **Living documentation** that evolves with Drupal
- **Environment-specific versions** for different setups
- **Pattern-focused content** rather than code snippets

## Contributing

This is a work in progress. Areas for improvement:
- Additional development patterns
- Environment-specific optimizations
- Real-world examples and use cases
- Integration with modern development tools

## Resources

- **Drupal Documentation**: [drupal.org/docs](https://www.drupal.org/docs)
- **Drupal API**: [api.drupal.org](https://api.drupal.org)
- **DrupalAtYourFingertips**: [drupalatyourfingertips.com](https://www.drupalatyourfingertips.com)
- **agents.md Standard**: [agents.md](https://agents.md)

---

**Note**: These guides focus on Drupal 10.x+ development patterns and modern best practices. Always adapt instructions to your specific project requirements and environment constraints.
