# Dotfiles

Personal macOS development environment configuration managed via symlinks.

## Critical Rules

1. **Update README when adding apps** - Any new application added to Brewfile or mise config MUST be documented in the "Installed Applications" section of README.md with its category and management method.

2. **No hardcoded paths** - Never use `/Users/username/` in config files. Use `$HOME` or `~` instead.

3. **Prefer mise over Homebrew** - For CLI tools that benefit from version switching (node, python, go, terraform), add to `mise/config.toml` instead of Brewfile.

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
| `claude/` | Claude Code skills and settings |

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
