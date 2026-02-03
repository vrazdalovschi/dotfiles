# --- 1. Path Setup ---
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Google Cloud SDK
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="/opt/homebrew/opt/trash/bin:$PATH"

# --- 2. Tool Initializations ---

# Mise (Runtime/Environment Manager)
eval "$(/opt/homebrew/bin/mise activate zsh)"

# Atuin (History Search - Ctrl+R)
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# Starship (Prompt)
eval "$(starship init zsh)"

# Zoxide (Smart cd)
eval "$(zoxide init zsh)"

# fzf (Fuzzy Finder - Ctrl+T for files, Option+C for dirs)
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
bindkey -r '^R'  # Let atuin handle Ctrl+R

# Direnv (per-directory env)
eval "$(direnv hook zsh)"

# --- 3. Completions ---
autoload -Uz compinit && compinit
fpath=(~/.docker/completions $fpath)

# bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Graphite (gt)
_gt_yargs_completions() {
  local reply
  local si=$IFS
  IFS=$'\n' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" gt --get-yargs-completions "${words[@]}"))
  IFS=$si
  _describe 'values' reply
}
compdef _gt_yargs_completions gt

# --- 4. Aliases ---

# File listing (eza)
alias ls="eza --icons --git"
alias ll="eza -l --icons --git"
alias la="eza -la --icons --git"
alias lt="eza --tree --level=2 --icons"

# Modern replacements
alias cat="bat"
alias find="fd"
alias rm="trash"
alias top="btop"
alias help="tldr"
alias npx="bunx"

# Git
alias gs="git status"
alias gc="git commit"
alias gp="git push"
alias lg="lazygit"

# Kubernetes
alias kdiff='kubectl diff -f - | delta --paging=never'
alias kapply='kubectl apply -f -'

# --- 5. Startup Checks ---

# Check for bun global package updates (once per day)
_check_bun_updates() {
  local global_dir="$HOME/.bun/install/global"
  local cache_file="$HOME/.cache/bun-update-check"

  [[ -f "$global_dir/package.json" ]] || return

  # Only check once per day
  if [[ -f "$cache_file" ]]; then
    local last_check=$(cat "$cache_file")
    local today=$(date +%Y-%m-%d)
    [[ "$last_check" == "$today" ]] && return
  fi

  mkdir -p "$HOME/.cache"
  date +%Y-%m-%d > "$cache_file"

  local outdated
  outdated=$(cd "$global_dir" && bun outdated 2>/dev/null | grep -v "^$")

  if [[ -n "$outdated" ]]; then
    echo "\n📦 Bun global package updates available:"
    echo "$outdated"
    echo ""
    read -q "reply?Update now? [y/N] "
    echo ""
    if [[ "$reply" =~ ^[Yy]$ ]]; then
      (cd "$global_dir" && bun update)
    fi
  fi
}
_check_bun_updates

# --- 6. Functions ---

# Google search in default browser
google() {
  open "https://www.google.com/search?q=${*// /+}"
}

# GitHub search
github() {
  open "https://github.com/search?q=${*// /+}"
}

# YouTube search
youtube() {
  open "https://www.youtube.com/results?search_query=${*// /+}"
}
