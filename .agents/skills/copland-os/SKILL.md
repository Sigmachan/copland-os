```markdown
# copland-os Development Patterns

> Auto-generated skill from repository analysis

## Overview

This skill provides guidance on contributing to the `copland-os` TypeScript codebase. It covers coding conventions, commit patterns, documentation workflows, and testing practices. By following these patterns, contributors ensure consistency, maintainability, and clarity across the project.

## Coding Conventions

### File Naming

- Use **kebab-case** for file names.
  - Example:  
    ```
    user-profile.ts
    agent-manager.test.ts
    ```

### Import Style

- Use **relative imports** for modules within the project.
  - Example:
    ```typescript
    import { AgentManager } from './agent-manager';
    ```

### Export Style

- Use **named exports** rather than default exports.
  - Example:
    ```typescript
    // agent-manager.ts
    export function createAgent() { ... }
    export const AGENT_VERSION = '1.0.0';
    ```

### Commit Messages

- Follow **conventional commit** format.
- Common prefixes: `docs:`, `feat:`
  - Example:
    ```
    docs: update AGENTS.md with new agent profile
    feat: add user authentication module
    ```

## Workflows

### Update Documentation Files

**Trigger:**  
When you need to document new features, update flagship status, or provide setup instructions.

**Command:**  
`/update-docs`

**Step-by-step Instructions:**

1. **Edit or create** relevant markdown documentation files:
    - `AGENTS.md`
    - `README.md`
    - `PROMPT.md`
2. **Commit your changes** using a commit message starting with `docs:`.  
   Example:
   ```
   docs: add setup instructions to README.md
   ```
3. **Add co-author attribution** in the commit message if others contributed.
4. **Push your changes** and open a pull request if required.

## Testing Patterns

- Test files follow the `*.test.*` naming convention.
  - Example:  
    ```
    agent-manager.test.ts
    ```
- The specific testing framework is **unknown**, but tests are colocated with source files or in the same directory.

## Commands

| Command       | Purpose                                                        |
|---------------|----------------------------------------------------------------|
| /update-docs  | Start the documentation update workflow (see above)            |
```