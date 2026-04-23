# Experimental: Knowledge Base Architecture

> **⚠️ Experimental** — This is a new approach. The slim AGENTS.md + `.kb/` folder pattern is being tested alongside the traditional monolithic AGENTS.md files.

## The Problem

Traditional AGENTS.md files for Drupal are massive (~1,500 lines, ~8K tokens). Every time an AI agent processes a request — even a simple one like fixing a typo — it loads the entire file. This wastes tokens and slows down responses.

## The Solution

Split the monolithic AGENTS.md into a **slim entry point** (60 lines) + a **knowledge base** of focused files that the agent reads on demand.

```
your-drupal-project/
├── AGENTS.md          ← 60 lines (~400 tokens) — always loaded
└── .kb/               ← loaded on demand per task
    ├── 00-index.md       Full topic map
    ├── 01-project-overview.md
    ├── 02-code-standards.md
    ├── 03-module-scaffolding.md
    ├── 04-services-di.md
    ├── 05-entity-api.md
    ├── 06-plugins.md
    ├── 07-hooks.md
    ├── 08-forms.md
    ├── 09-routes-controllers.md
    ├── 10-security.md
    ├── 11-caching-performance.md
    ├── 12-anti-patterns.md
    ├── 13-testing.md
    ├── 14-events.md
    ├── 15-configuration.md
    ├── 16-batch-queue.md
    ├── 17-render-api.md
    ├── 18-migration.md
    ├── 19-composer.md
    ├── 20-javascript.md
    ├── 21-workflow.md
    └── 22-troubleshooting.md
```

### How It Works

1. **AGENTS.md** is always loaded — contains project overview, critical rules, and a table telling the agent which `.kb/` file to read for each task
2. **Agent reads on demand** — When the user asks "build a form", the agent reads `.kb/08-forms.md`. When they ask "create a block plugin", it reads `.kb/06-plugins.md`
3. **Cross-references** — Each `.kb/` file links to related files so the agent can chain-read when needed
4. **Front matter** — Every file has YAML front matter with `title`, `description`, and `tags` for agent discovery

### Token Savings

| Scenario                                     | Monolithic    | Knowledge Base           |
| -------------------------------------------- | ------------- | ------------------------ |
| Simple task (fix typo)                       | ~8,000 tokens | ~400 tokens              |
| Build a form                                 | ~8,000 tokens | ~400 + ~1,200 (forms.md) |
| Complex task (services + entities + caching) | ~8,000 tokens | ~400 + ~3,500 (3 files)  |

## Install

### Quick Install (recommended)

Run this from your Drupal project's root directory:

```bash
curl -fsSL https://raw.githubusercontent.com/amazeeio/drupal-agents-md/main/experimental/install.sh | bash
```

Or with wget:

```bash
wget -qO- https://raw.githubusercontent.com/amazeeio/drupal-agents-md/main/experimental/install.sh | bash
```

### Install Options

| Option              | Description                                 |
| ------------------- | ------------------------------------------- |
| `--branch=<name>`   | Use a specific git branch (default: `main`) |
| `--kb-only`         | Install only `.kb/` folder (no AGENTS.md)   |
| `--no-kb`           | Install only AGENTS.md (no `.kb/` folder)   |
| `--force`           | Overwrite without prompting                 |
| `--help`            | Show help message                           |

### Manual Install

```bash
# Clone the repo
git clone https://github.com/amazeeio/drupal-agents-md.git /tmp/drupal-agents-md

# Copy files to your project
cp /tmp/drupal-agents-md/experimental/AGENTS.md /path/to/your/drupal-project/
cp -r /tmp/drupal-agents-md/experimental/.kb /path/to/your/drupal-project/

# Clean up
rm -rf /tmp/drupal-agents-md
```

## After Install

Open your AI coding tool (Cursor, Claude Code, GitHub Copilot, etc.) in the project directory. It will automatically read `AGENTS.md` and follow its guidance to load `.kb/` files as needed.

## File Reference

Each `.kb/` file is self-contained with:

- **Front matter** — `title`, `description`, `tags` for discovery
- **Code examples** — Copy-pasteable PHP, YAML, Twig, JavaScript snippets
- **Cross-references** — Links to related `.kb/` files
- **Related Files section** — At the bottom of every file

## Feedback

This is experimental. If you try it, open an issue at [amazeeio/drupal-agents-md](https://github.com/amazeeio/drupal-agents-md/issues) with:

- Which AI tool you used (Cursor, Claude Code, Copilot, etc.)
- Whether the agent correctly loaded `.kb/` files on demand
- Any tasks where the agent needed info that wasn't in the `.kb/` files
