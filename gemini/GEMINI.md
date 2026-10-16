1. .npmrc files can contain secrets. Always ask before reading file data

## Gemini Added Memories
- For multi-step tasks, create a TODO list in a markdown file in a Gemini-only temporary directory (e.g., `~/.gemini/tmp/`) named with a unique project-workspace and conversation-specific format (e.g., `<workspace-name>-<conversation-id>-todo.md`) to avoid conflicts and version control tracking. Update this file after each step is completed to track progress. The user will review each step after completion.
- Learnings from previous sessions are stored in ~/.gemini/learnings/.
- To retrieve specific learnings, list the contents of the '~/.gemini/learnings/' directory and read the file corresponding to the topic (e.g., 'aerospace.md' for AeroSpace learnings).
- The user prefers commit messages without parentheses in the scope (e.g., use `refactor: scope message` instead of `refactor(scope): message`).
- The user's personal GitHub account is 'thedomguy'.
- Never generate Personal Access Tokens (PATs) or any other security tokens without explicit user confirmation, regardless of the operating mode (including YOLO).
