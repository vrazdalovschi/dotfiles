#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Create necessary directories
mkdir -p ~/.claude/skills
mkdir -p ~/.claude/commands
mkdir -p ~/.config/ghostty
mkdir -p ~/.config/mise
mkdir -p ~/.config/zed

# Function to create symlink with backup
link_file() {
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

# Function to link directory contents
link_dir_contents() {
    local src_dir="$1"
    local dest_dir="$2"

    for item in "$src_dir"/*; do
        if [ -e "$item" ]; then
            local name=$(basename "$item")
            link_file "$item" "$dest_dir/$name"
        fi
    done
}

echo ""
echo "==> Linking Claude Code configs..."
link_file "$DOTFILES_DIR/claude/CLAUDE.md" ~/.claude/CLAUDE.md
link_file "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json
link_file "$DOTFILES_DIR/claude/statusline-command.sh" ~/.claude/statusline-command.sh
link_dir_contents "$DOTFILES_DIR/claude/skills" ~/.claude/skills
link_dir_contents "$DOTFILES_DIR/claude/commands" ~/.claude/commands

echo ""
echo "==> Linking zsh config..."
link_file "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc

echo ""
echo "==> Linking git config..."
link_file "$DOTFILES_DIR/git/.gitconfig" ~/.gitconfig

echo ""
echo "==> Linking Ghostty config..."
link_file "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config

echo ""
echo "==> Linking mise config..."
link_file "$DOTFILES_DIR/mise/config.toml" ~/.config/mise/config.toml

echo ""
echo "==> Linking Zed config..."
link_file "$DOTFILES_DIR/zed/settings.json" ~/.config/zed/settings.json

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
echo "Done! Restart your terminal for changes to take effect."
