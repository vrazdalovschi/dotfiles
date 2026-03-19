# --- 1. Path & Terminal Setup ---
export PATH="$HOME/.local/share/mise/shims:$HOME/.local/share/mise/bin:$HOME/.local/bin:$PATH"
export TERM=xterm-256color
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# --- 2. Tool Initializations ---

# Mise (Runtime/Environment Manager)
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Starship (Prompt)
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Zoxide (Smart cd)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# fzf (Fuzzy Finder)
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# Direnv (per-directory env)
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Zsh plugins
[[ -f /usr/share/zsh-you-should-use/you-should-use.plugin.zsh ]] && source /usr/share/zsh-you-should-use/you-should-use.plugin.zsh
[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# --- 3. Completions ---
mkdir -p "$HOME/.cache/zsh"
autoload -Uz compinit && compinit -d "$HOME/.cache/zsh/zcompdump-${ZSH_VERSION}"

# --- 4. Aliases ---

# File listing (eza)
alias ls="eza --icons --git"
alias ll="eza -l --icons --git"
alias la="eza -la --icons --git"
alias lt="eza --tree --level=2 --icons"

# Modern replacements
alias cat="bat"
alias find="fd"
alias top="btop"
alias help="tldr"

# Git
alias gs="git status"
alias gc="git commit"
alias gp="git push"
alias lg="lazygit"

# AI agents (yolo mode — sandbox only)
alias claude="claude --dangerously-skip-permissions"
alias codex="codex --approval-mode full-auto"
alias gemini="gemini --yolo"

# Kubernetes
alias kdiff='kubectl diff -f - | delta --paging=never'
alias kapply='kubectl apply -f -'

# Syntax Highlighting (must be last)
[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
