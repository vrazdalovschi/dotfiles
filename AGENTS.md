# Dotfiles

Personal macOS development environment configuration managed via symlinks.

## Critical Rules

1. **Update README when adding apps** - Any new application added to Brewfile or mise config MUST be documented in the "Installed Applications" section of README.md with its category and management method.

2. **No hardcoded paths** - Never use `/Users/username/` in config files. Use `$HOME` or `~` instead.

3. **Prefer mise over Homebrew** - For CLI tools that benefit from version switching (node, python, go, terraform), add to `mise/config.toml` instead of Brewfile.

4. **No private data anywhere** - Before writing, adding, or modifying any file — configs, skills, scripts, aliases, commit messages — check for personal/sensitive data: API keys, tokens, passwords, private IPs, email addresses, license keys, and machine-specific paths (e.g. `/Users/<name>/`). If found, extract the value into an environment variable or remove it. This applies to all actions (installing, creating skills, editing configs, committing), not just commits. Raise it as an issue if the user attempts to add sensitive data.

5. **Check for duplicates before adding** - Before adding any package, tool, plugin, skill, alias, or config entry, check whether it already exists in the relevant file (Brewfile, mise config, .zshrc, settings, etc.). Never create duplicate entries.

6. **Re-run install.sh after any skill changes** - Any time a skill is added, removed, renamed, or moved (shared or tool-specific), run `./install.sh` to refresh skill symlinks.

7. **Use shared vs tool-specific skill locations correctly** - Put skills used by multiple tools in `agents/skills/shared/`. Put tool-only skills in `codex/skills/`, `claude/skills/`, or `gemini/skills/` as appropriate.

## Commands

```bash
./install.sh              # Create symlinks, install brew packages, mise tools
brew bundle dump --file=brew/Brewfile --force  # Export current brew packages
```

## Structure

| Path | Purpose |
|------|---------|
| `brew/Brewfile` | Homebrew packages and casks |
| `mise/config.toml` | Runtime versions (node, python, go, etc.) |
| `zsh/.zshrc` | Shell configuration |
| `git/.gitconfig` | Git settings (delta, zed editor) |
| `ghostty/config` | Terminal config |
| `zed/settings.json` | Editor settings |
| `agents/skills/shared/` | Skills shared across Codex, Claude, and Gemini |
| `codex/skills/` | Codex-specific skills |
| `claude/` | Claude Code skills and settings |
| `gemini/` | Gemini CLI settings and skills |

## Symlink Mapping

All configs are symlinked from this repo to their system locations. After `install.sh`, editing `~/.zshrc` automatically updates the repo.

## Adding New Applications

1. **Homebrew app**: Add to `brew/Brewfile`, run `brew bundle`
2. **mise tool**: Add to `mise/config.toml`, run `mise install`
3. **Manual install**: Document in README under "Voice & Dictation" or appropriate category
4. **Always**: Update README.md "Installed Applications" section with category and "Managed By"

## Adding New Config Files

1. Add config to appropriate folder in this repo
2. Update `install.sh` to create the symlink
3. Update README.md with new symlink mapping

## Adding or Updating Skills

1. **Shared skill**: Add to `agents/skills/shared/<skill-name>/SKILL.md`
2. **Tool-specific skill**: Add to `codex/skills/`, `claude/skills/`, or `gemini/skills/`
3. **Check duplicates first**: Ensure no existing skill with the same name in the same target scope
4. **Always run installer**: Run `./install.sh` after any skill add/remove/rename/move so symlinks are refreshed
