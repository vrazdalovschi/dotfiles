#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Create necessary directories
mkdir -p ~/.config/ghostty
mkdir -p ~/.config/mise
mkdir -p ~/.config/zed
mkdir -p ~/.bun/install/global
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

# Ensure the destination exists as a real directory (not a symlink).
ensure_directory() {
    local dir="$1"

    if [ -L "$dir" ]; then
        rm "$dir"
    elif [ -e "$dir" ] && [ ! -d "$dir" ]; then
        echo "Backing up $dir to $dir.backup"
        mv "$dir" "$dir.backup"
    fi

    mkdir -p "$dir"
}

# Link skill directories from source root into destination.
# Precedence is defined by call order: later calls override earlier ones.
sync_skill_source() {
    local src_root="$1"
    local dest_root="$2"
    local source_label="$3"

    if [ ! -d "$src_root" ]; then
        return
    fi

    for skill_dir in "$src_root"/*; do
        [ -d "$skill_dir" ] || continue
        [ -f "$skill_dir/SKILL.md" ] || continue

        local skill_name
        skill_name="$(basename "$skill_dir")"
        local dest_path="$dest_root/$skill_name"

        if [ -e "$dest_path" ] && [ ! -L "$dest_path" ]; then
            echo "Skipping $dest_path (exists and is not a symlink)"
            continue
        fi

        ln -sfn "$skill_dir" "$dest_path"
        echo "Linked $source_label skill $skill_name"
    done
}

# List skill names discovered in a source root.
list_skill_names() {
    local src_root="$1"

    if [ ! -d "$src_root" ]; then
        return
    fi

    for skill_dir in "$src_root"/*; do
        [ -d "$skill_dir" ] || continue
        [ -f "$skill_dir/SKILL.md" ] || continue
        basename "$skill_dir"
    done
}

# Remove stale symlinks that point to managed sources but no longer exist in desired names.
remove_stale_managed_symlinks() {
    local dest_root="$1"
    local desired_names="$2"
    shift 2
    local managed_roots=("$@")

    for existing in "$dest_root"/*; do
        [ -L "$existing" ] || continue

        local skill_name
        skill_name="$(basename "$existing")"
        if [ -n "$desired_names" ] && printf '%s\n' "$desired_names" | grep -Fxq "$skill_name"; then
            continue
        fi

        local target
        target="$(readlink "$existing" || true)"

        local is_managed_target=0
        for root in "${managed_roots[@]}"; do
            case "$target" in
                "$root"/*)
                    is_managed_target=1
                    break
                    ;;
            esac
        done

        if [ "$is_managed_target" -eq 1 ]; then
            rm -f "$existing"
            echo "Removed stale managed skill $skill_name"
        fi
    done
}

# Sync skills for a specific agent:
# 1) shared repo skills
# 2) agent-specific repo skills
# 3) codex system skills (codex only)
# 4) optional local, non-versioned skills
sync_agent_skills() {
    local agent="$1"
    local repo_agent_root="$2"
    local dest_root="$3"
    local shared_root="$DOTFILES_DIR/agents/skills/shared"
    local local_root="$HOME/.agents/skills-local/$agent"
    local codex_system_root="$DOTFILES_DIR/codex/skills/.system"
    local desired_names=""

    ensure_directory "$dest_root"

    if [ "$agent" = "codex" ]; then
        desired_names="$(
            {
                list_skill_names "$shared_root"
                list_skill_names "$repo_agent_root"
                list_skill_names "$codex_system_root"
                list_skill_names "$local_root"
            } | sort -u
        )"
        remove_stale_managed_symlinks "$dest_root" "$desired_names" \
            "$shared_root" "$repo_agent_root" "$codex_system_root" "$local_root"
    else
        desired_names="$(
            {
                list_skill_names "$shared_root"
                list_skill_names "$repo_agent_root"
                list_skill_names "$local_root"
            } | sort -u
        )"
        remove_stale_managed_symlinks "$dest_root" "$desired_names" \
            "$shared_root" "$repo_agent_root" "$local_root"
    fi

    sync_skill_source "$shared_root" "$dest_root" "shared"
    sync_skill_source "$repo_agent_root" "$dest_root" "$agent"
    if [ "$agent" = "codex" ]; then
        sync_skill_source "$codex_system_root" "$dest_root" "codex-system"
    fi
    sync_skill_source "$local_root" "$dest_root" "local-$agent"
}

echo ""
echo "==> Linking Claude Code configs..."
mkdir -p ~/.claude
link "$DOTFILES_DIR/claude/CLAUDE.md" ~/.claude/CLAUDE.md
link "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json
link "$DOTFILES_DIR/claude/statusline-command.sh" ~/.claude/statusline-command.sh
link "$DOTFILES_DIR/claude/commands" ~/.claude/commands
link "$DOTFILES_DIR/claude/hooks" ~/.claude/hooks
sync_agent_skills "claude" "$DOTFILES_DIR/claude/skills" "$HOME/.claude/skills"

echo ""
echo "==> Linking Codex configs..."
mkdir -p ~/.codex
link "$DOTFILES_DIR/AGENTS.md" ~/.codex/AGENTS.md
sync_agent_skills "codex" "$DOTFILES_DIR/codex/skills" "$HOME/.codex/skills"

echo ""
echo "==> Linking Gemini CLI configs..."
mkdir -p ~/.gemini
link "$DOTFILES_DIR/gemini/GEMINI.md" ~/.gemini/GEMINI.md
link "$DOTFILES_DIR/gemini/settings.json" ~/.gemini/settings.json
sync_agent_skills "gemini" "$DOTFILES_DIR/gemini/skills" "$HOME/.gemini/skills"

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
