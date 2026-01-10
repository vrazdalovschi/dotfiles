# dotfiles

Personal configuration files for macOS development environment.

## What's Included

| Component | Description |
|-----------|-------------|
| **zsh** | Shell config with starship prompt, modern CLI tools (eza, bat, zoxide, atuin, fzf) |
| **git** | Git config with delta pager, Zed editor |
| **mise** | Runtime version manager config (node, python, go, terraform, gcloud) |
| **zed** | Zed editor settings |
| **claude** | Claude Code settings, custom skills, statusline, and commands |
| **ghostty** | Terminal emulator configuration |
| **brew** | All Homebrew packages (Brewfile) |

## Quick Start

### New Machine Setup

```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install mise (runtime version manager)
curl https://mise.run | sh
# Or via Homebrew: brew install mise

# 3. Clone this repo
git clone https://github.com/vrazdalovschi/dotfiles.git ~/dotfiles

# 4. Run install script
cd ~/dotfiles && ./install.sh
```

The install script will:
- Create symlinks for all config files
- Backup existing configs (`.backup` suffix)
- Install all Homebrew packages
- Install mise-managed tools (node, python, pnpm)

### Existing Machine

If you already have configs and just want to sync:

```bash
cd ~/dotfiles && ./install.sh
```

## Directory Structure

```
dotfiles/
├── install.sh           # Setup script
├── brew/
│   └── Brewfile         # Homebrew packages
├── git/
│   └── .gitconfig       # Git config (delta, zed editor)
├── mise/
│   └── config.toml      # Runtime versions (node, python, go, terraform, gcloud)
├── zed/
│   └── settings.json    # Zed editor config
├── claude/
│   ├── CLAUDE.md        # Global instructions
│   ├── settings.json    # Claude Code settings
│   ├── statusline-command.sh
│   ├── skills/          # Custom skills
│   └── commands/        # Custom commands
├── ghostty/
│   └── config
└── zsh/
    └── .zshrc
```

## Symlink Mapping

| Repo Path | System Path |
|-----------|-------------|
| `zsh/.zshrc` | `~/.zshrc` |
| `git/.gitconfig` | `~/.gitconfig` |
| `mise/config.toml` | `~/.config/mise/config.toml` |
| `zed/settings.json` | `~/.config/zed/settings.json` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `claude/*` | `~/.claude/*` |

## Daily Workflow

After install, configs are symlinked. Any edits sync automatically:

```bash
# Edit config anywhere
vim ~/.zshrc
# or
vim ~/dotfiles/zsh/.zshrc

# Changes appear in repo, just commit
cd ~/dotfiles
git add -A && git commit -m "update zshrc" && git push
```

## Updating Brew Packages

When you install new packages, update the Brewfile:

```bash
brew bundle dump --file=~/dotfiles/brew/Brewfile --force
cd ~/dotfiles && git add -A && git commit -m "update brewfile" && git push
```

## Adding New Configs

1. Add the config file to appropriate folder in `dotfiles/`
2. Update `install.sh` to create the symlink
3. Commit and push

## Keyboard Shortcuts

| Shortcut | Tool | What it does |
|----------|------|--------------|
| `Ctrl+R` | [atuin](https://github.com/atuinsh/atuin) | Search command history |
| `Ctrl+T` | [fzf](https://github.com/junegunn/fzf) | Fuzzy find file and insert path |
| `Option+C` | [fzf](https://github.com/junegunn/fzf) | Fuzzy find directory and cd into it |

## Modern CLI Tools

### Navigation with zoxide

[zoxide](https://github.com/ajeetdsouza/zoxide) learns which directories you visit and lets you jump to them with minimal typing.

```bash
# First, visit some directories normally
cd ~/projects/dotfiles
cd ~/work/myapp

# Later, jump back with just a few letters
z dot        # → ~/projects/dotfiles
z myapp      # → ~/work/myapp
z work dot   # → matches directory containing both "work" and "dot"

# See your most visited directories
zoxide query -ls
```

### File Finding with fd + fzf

```bash
# fd: fast file search (replaces find)
fd .py                    # Find all .py files
fd -t d node_modules      # Find directories named node_modules
fd -e md                  # Find by extension

# fzf: interactive fuzzy finder
vim <Ctrl+T>              # Opens picker, select file, path inserted
cat $(fzf)                # Same thing, different syntax
```

### History Search with atuin

Press `Ctrl+R` to open interactive history search. Start typing to filter commands.

### Safe Delete with trash

```bash
rm file.txt               # Moves to Trash (aliased to trash)
trash -l                  # List items in trash
trash -e                  # Empty trash
```

### Git TUI with lazygit

```bash
lg                        # Opens lazygit (aliased)
# Use arrow keys to navigate, space to stage, c to commit, P to push
```

## Command Aliases

| Alias | Actual Command | Description |
|-------|----------------|-------------|
| `ls` | `eza --icons --git` | List with icons and git status |
| `ll` | `eza -l --icons --git` | Long list |
| `la` | `eza -la --icons --git` | List all including hidden |
| `lt` | `eza --tree --level=2` | Tree view |
| `cat` | `bat` | Syntax highlighted output |
| `find` | `fd` | Fast file finder |
| `rm` | `trash` | Safe delete to Trash |
| `top` | `btop` | Beautiful system monitor |
| `help` | `tldr` | Simplified man pages |
| `lg` | `lazygit` | Git TUI |
| `z` | `zoxide` | Smart directory jump |

## Search Functions

```bash
google how to exit vim    # Opens browser with Google search
github dotfiles           # Opens browser with GitHub search
youtube lofi beats        # Opens browser with YouTube search
```

## Installed Applications

### IDEs & Editors
| App | Description | Managed By |
|-----|-------------|------------|
| [Zed](https://zed.dev/) | Fast, modern code editor | Homebrew |

### Terminal & Shell
| App | Description | Managed By |
|-----|-------------|------------|
| [Ghostty](https://ghostty.org/) | GPU-accelerated terminal | Homebrew |
| [Starship](https://starship.rs/) | Minimal prompt | mise |

### DevOps & Kubernetes
| App | Description | Managed By |
|-----|-------------|------------|
| [Lens](https://k8slens.dev/) | Kubernetes IDE | Homebrew |
| k3d, kustomize, stern, kubefwd | K8s CLI tools | Homebrew |
| [Terraform](https://terraform.io/), tflint, terramate | Infrastructure as code | mise / Homebrew |

### API & Development
| App | Description | Managed By |
|-----|-------------|------------|
| [Insomnia](https://insomnia.rest/) | API client | Homebrew |
| [ngrok](https://ngrok.com/) | Tunneling | Homebrew |

### Productivity & Utilities
| App | Description | Managed By |
|-----|-------------|------------|
| [Raycast](https://raycast.com/) | Launcher (Spotlight replacement) | Homebrew |
| [Maccy](https://maccy.app/) | Clipboard manager | Homebrew |
| [AltTab](https://alt-tab-macos.netlify.app/) | Window switcher | Homebrew |
| [Stats](https://github.com/exelban/stats) | Menubar system monitor | Homebrew |

### Communication
| App | Description | Managed By |
|-----|-------------|------------|
| [Telegram](https://telegram.org/) | Messaging | Homebrew |
| [Microsoft Remote Desktop](https://aka.ms/rdmac) | RDP client | Homebrew |

### Media
| App | Description | Managed By |
|-----|-------------|------------|
| [IINA](https://iina.io/) | Video player | Homebrew |

### Voice & Dictation
| App | Description | Managed By |
|-----|-------------|------------|
| [Superwhisper](https://superwhisper.com/) | Local AI voice-to-text | Manual |

### CLI Tools (Homebrew)

**Modern Replacements:**
`bat` (cat), `eza` (ls), `fd` (find), `ripgrep` (grep), `zoxide` (cd), `trash` (rm), `btop` (top), `tldr` (man)

**Git & Dev:**
`git`, `git-delta`, `git-lfs`, `gh`, `lazygit`, `graphite`

**Networking:**
`curl`, `wget`, `nmap`, `gping`, `tailscale`, `grpcurl`

**Data:**
`jq`, `cue`

### Runtime Versions (mise)

| Tool | Description |
|------|-------------|
| node | JavaScript runtime |
| python | Python runtime |
| go | Go runtime |
| terraform | Infrastructure as code |
| gcloud | Google Cloud SDK |
| pnpm, uv, bun | Package managers |
| helm, k9s, hadolint, shellcheck, lefthook | DevOps tools |

## Tools Configured

### Shell (zsh)
- [starship](https://starship.rs/) - Minimal prompt
- [eza](https://github.com/eza-community/eza) - Modern `ls` with icons
- [bat](https://github.com/sharkdp/bat) - `cat` with syntax highlighting
- [zoxide](https://github.com/ajeetdsouza/zoxide) - Smarter `cd`
- [atuin](https://github.com/atuinsh/atuin) - Shell history search
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder
- [fd](https://github.com/sharkdp/fd) - Fast `find` replacement
- [direnv](https://direnv.net/) - Per-directory environment

### mise (Runtime Manager)
Manages versions for:
- **node** - JavaScript runtime
- **python** - Python runtime
- **go** - Go runtime
- **terraform** - Infrastructure as code
- **gcloud** - Google Cloud SDK
- **pnpm** - Fast package manager
- **uv** - Fast Python package installer

See [mise.jdx.dev](https://mise.jdx.dev) for docs.

### Claude Code
- Custom skills for PostgreSQL, SQLMesh, planning workflows
- Statusline showing git/project info
- Global instructions in CLAUDE.md
