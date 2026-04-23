# Contributing to Drupal AGENTS.md

Thank you for your interest in improving the Drupal AI Agent Development Guides! This document provides guidelines and instructions for contributing.

## How to Contribute

### Reporting Issues

- Open a [GitHub Issue](https://github.com/amazeeio/drupal-agents-md/issues) with a clear title and description
- Specify which AGENTS.md variant is affected (DDEV, Vanilla, or Lagoon)
- Include the section heading where the issue occurs
- If suggesting a change, explain **why** the current content is incorrect or incomplete

### Making Changes

1. **Fork the repository** and create a feature branch:

   ```bash
   git checkout -b feature/my-improvement
   ```

2. **Make your changes** following the guidelines below

3. **Test your changes** — Verify that:
   - Markdown renders correctly (no broken fences, tables, or links)
   - Code examples are syntactically valid PHP/YAML/Twig/JavaScript
   - Commands are accurate for the target environment
   - Content follows the existing structure and tone

4. **Commit with a descriptive message**:

   ```bash
   git commit -m "feat: add Recipe system section to all variants"
   ```

5. **Open a Pull Request** against the `main` branch

## Commit Message Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New content or sections
- `fix:` Corrections to existing content
- `docs:` README, CONTRIBUTING, or meta-documentation changes
- `refactor:` Restructure without changing content
- `chore:` CI, gitignore, or tooling changes

## Content Guidelines

### Code Examples

- All code examples must be **syntactically valid** and **copy-pasteable**
- Use `my_module` as the placeholder module name
- Follow Drupal coding standards in all PHP examples
- Include `use` statements for all referenced classes
- Show dependency injection patterns, not static calls

### Environment-Specific Content

When adding content that applies to all variants:

- Add it to **all three** files: DDEV, Vanilla, and Lagoon
- Adapt commands to the environment:
  - DDEV: `ddev exec drush <command>`
  - Vanilla: `drush <command>`
  - Lagoon: `drush @lagoon.<env> <command>` or `lagoon-sync` commands
- Maintain consistency across variants

### Style

- Use `**bold**` for emphasis on key terms
- Use fenced code blocks with language identifiers (`php,`yaml, ```bash)
- Use markdown tables for command references
- Keep paragraphs concise — AI agents benefit from density over prose
- Add concrete code examples rather than abstract descriptions

### What to Add

Contributions are especially welcome for:

- **New Drupal patterns** — Recipe system, Typed Data, new plugin types
- **More code examples** — Real-world patterns that agents frequently need
- **Drupal version-specific notes** — Changes between Drupal 10 and 11
- **Performance patterns** — Profiling, optimization, and caching
- **Security patterns** — Common vulnerability prevention
- **Testing patterns** — More test type examples (FunctionalJavascript, etc.)
- **Decoupled/headless** — JSON:API, REST, GraphQL patterns

### What Not to Add

- Basic Drupal tutorials (installation, site building)
- Server infrastructure guides (Apache/Nginx config)
- Content that duplicates the official Drupal documentation without adding value
- Drupal 7, 8, or 9 specific guidance

## Pull Request Template

When opening a PR, please include:

```markdown
## Description

Brief description of what this PR changes and why.

## Affected Files

- [ ] DDEV/AGENTS.md
- [ ] Vanilla/AGENTS.md
- [ ] Lagoon/AGENTS.md
- [ ] README.md
- [ ] Other: \_\_\_

## Type of Change

- [ ] New content/section
- [ ] Correction/fix
- [ ] Code example addition
- [ ] Documentation/meta
- [ ] CI/tooling

## Testing

How did you verify the changes?

- [ ] Rendered markdown preview
- [ ] Checked code syntax
- [ ] Verified commands work in target environment
```

## Review Criteria

PRs will be reviewed against:

1. **Accuracy** — Code examples and commands are correct
2. **Consistency** — Changes applied to all relevant variants
3. **Style** — Follows existing structure and formatting conventions
4. **Value** — Adds useful information for AI agents working on Drupal projects

## Questions?

Open an issue with the `question` label, or start a discussion in GitHub Discussions.
