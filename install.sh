#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Create necessary directories
mkdir -p ~/.config/ghostty
mkdir -p ~/.config/mise
mkdir -p ~/.config/zed
mkdir -p ~/.bun/install/global
mkdir -p ~/agents/logs/errors
mkdir -p ~/agents/logs/successes

# Initialize agents logs metadata if not exists
if [ ! -f ~/agents/logs/metadata.json ]; then
    cat > ~/agents/logs/metadata.json << 'EOF'
{
  "lastErrorId": 0,
  "lastSuccessId": 0,
  "description": "Tracks ID counters for error and success logs"
}
EOF
    echo "Created ~/agents/logs/metadata.json"
fi

# Create symlink (works for files and directories)
link() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        echo "Backing up $dest to $dest.backup"
        mv "$dest" "$dest.backup"
    fi

    ln -s "$src" "$dest"
    echo "Linked $src -> $dest"
}

echo ""
echo "==> Linking Claude Code configs..."
link "$DOTFILES_DIR/claude/CLAUDE.md" ~/.claude/CLAUDE.md
link "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json
link "$DOTFILES_DIR/claude/statusline-command.sh" ~/.claude/statusline-command.sh
link "$DOTFILES_DIR/claude/skills" ~/.claude/skills
link "$DOTFILES_DIR/claude/commands" ~/.claude/commands
link "$DOTFILES_DIR/claude/hooks" ~/.claude/hooks

echo ""
echo "==> Linking Codex configs..."
mkdir -p ~/.codex
link "$DOTFILES_DIR/AGENTS.md" ~/.codex/AGENTS.md
link "$DOTFILES_DIR/codex/skills" ~/.codex/skills

echo ""
echo "==> Linking Gemini CLI configs..."
mkdir -p ~/.gemini
link "$DOTFILES_DIR/gemini/GEMINI.md" ~/.gemini/GEMINI.md
link "$DOTFILES_DIR/gemini/settings.json" ~/.gemini/settings.json
link "$DOTFILES_DIR/gemini/skills" ~/.gemini/skills

echo ""
echo "==> Linking zsh config..."
link "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc

echo ""
echo "==> Linking git config..."
link "$DOTFILES_DIR/git/.gitconfig" ~/.gitconfig
link "$DOTFILES_DIR/git/.gitignore_global" ~/.gitignore_global

echo ""
echo "==> Linking Ghostty config..."
link "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config

echo ""
echo "==> Linking mise config..."
link "$DOTFILES_DIR/mise/config.toml" ~/.config/mise/config.toml

echo ""
echo "==> Linking Zed config..."
link "$DOTFILES_DIR/zed/settings.json" ~/.config/zed/settings.json

echo ""
echo "==> Installing Homebrew packages..."
if command -v brew &> /dev/null; then
    brew bundle --file="$DOTFILES_DIR/brew/Brewfile"
else
    echo "Homebrew not installed. Install from https://brew.sh first."
    echo "Then run: brew bundle --file=$DOTFILES_DIR/brew/Brewfile"
fi

echo ""
echo "==> Installing mise tools..."
if command -v mise &> /dev/null; then
    mise install
else
    echo "mise not installed yet. Run 'mise install' after brew completes."
fi

echo ""
echo "==> Installing Claude Code (native)..."
if command -v claude &> /dev/null; then
    echo "Claude Code already installed, checking for updates..."
    claude update 2>/dev/null || true
else
    curl -fsSL https://claude.ai/install.sh | bash
fi

echo ""
echo "==> Linking bun global packages..."
link "$DOTFILES_DIR/bun/package.json" ~/.bun/install/global/package.json

echo ""
echo "==> Installing bun global packages..."
if command -v bun &> /dev/null; then
    (cd ~/.bun/install/global && bun install)
else
    echo "bun not installed yet. Run 'cd ~/.bun/install/global && bun install' after mise completes."
fi

echo ""
echo "==> Configuring SSH..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

SSH_INCLUDE="Include $DOTFILES_DIR/ssh/config.d/*"
if [ ! -f ~/.ssh/config ]; then
    echo "$SSH_INCLUDE" > ~/.ssh/config
    echo "" >> ~/.ssh/config
    chmod 600 ~/.ssh/config
    echo "Created ~/.ssh/config with Include directive"
elif ! grep -qF "$SSH_INCLUDE" ~/.ssh/config; then
    # Prepend Include directive to existing config
    echo "$SSH_INCLUDE" | cat - ~/.ssh/config > ~/.ssh/config.tmp
    mv ~/.ssh/config.tmp ~/.ssh/config
    chmod 600 ~/.ssh/config
    echo "Added Include directive to ~/.ssh/config"
else
    echo "SSH config already includes dotfiles"
fi

echo ""
echo "Done! Restart your terminal for changes to take effect."
