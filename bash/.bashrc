#
# ~/.bashrc
#

# ==========================================
# PROMPT PERSONALIZADO (PS1)
# ==========================================
# Se reconstruye antes de cada comando para capturar
# el código de salida ($) y el estado de git en tiempo real.

__build_prompt() {
  local last=$?

  # Paleta de colores
  local c_reset='\[\e[0m\]'
  local c_gray='\[\e[90m\]'
  local c_user='\[\e[1;32m\]'
  local c_host='\[\e[1;36m\]'
  local c_path='\[\e[1;34m\]'
  local c_git='\[\e[0;35m\]'
  local c_ok='\[\e[1;32m\]'
  local c_err='\[\e[1;31m\]'

  # Segmento git: rama + '*' si hay cambios sin commitear
  local git_seg='' branch mark=''
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ -n $branch ]]; then
    [[ -n $(git status --porcelain 2>/dev/null) ]] && mark='*'
    git_seg=" ${c_gray}│${c_git} $branch$mark${c_reset}"
  fi

  # Símbolo de estado: ❯ verde si ok, ✗ rojo si el último comando falló
  local sym="${c_ok}❯${c_reset}"
  ((last != 0)) && sym="${c_err}✗${c_reset}"

  PS1="\n${c_gray}┌─ ${c_user}\u${c_gray}@${c_host}\h ${c_gray}│ ${c_path}\w${git_seg}${c_reset}\n${c_gray}└─ ${sym} "
}

PROMPT_COMMAND='__build_prompt'

# ==========================================
# LOCAL SOURCING
# ==========================================
if [ -f "$HOME/.bashrc.local" ]; then
  source "$HOME/.bashrc.local"
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ==========================================
# ENVIRONMENT
# ==========================================
export PATH="$HOME/.local/bin:$PATH"

# ==========================================
# GIT CONFIGURATION (global defaults)
# ==========================================
# Estos settings mejoran el comportamiento por defecto de git
git config --global init.defaultBranch main 2>/dev/null
git config --global pull.rebase true 2>/dev/null
git config --global push.autoSetupRemote true 2>/dev/null
git config --global fetch.prune true 2>/dev/null
git config --global rerere.enabled true 2>/dev/null
git config --global rebase.autoSquash true 2>/dev/null
git config --global branch.sort -committerdate 2>/dev/null
git config --global diff.algorithm histogram 2>/dev/null
git config --global merge.conflictStyle zdiff3 2>/dev/null

# Delta (git diff pager)
git config --global core.pager delta 2>/dev/null
git config --global interactive.diffFilter "delta --color-only" 2>/dev/null
git config --global delta.navigate true 2>/dev/null
git config --global delta.line-numbers true 2>/dev/null

# ==========================================
# BASIC ALIASES
# ==========================================
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# ==========================================
# MODERN CLI - reemplazos visuales
# ==========================================

# ls -> eza (iconos, git status, tree)
alias ls='eza --icons=auto --group-directories-first'
alias l='eza --icons=auto -l --group-directories-first --git'
alias ll='eza --icons=auto -lh --group-directories-first --git'
alias la='eza --icons=auto -lah --group-directories-first --git'
alias lt='eza --icons=auto --tree --level=2 --group-directories-first'

# cat -> bat (syntax highlighting, marcas de diff)
alias cat='bat --paging=never'
alias catn='bat --paging=never'
alias catp='bat'

# bat theme (delega en paleta de terminal para theming dinámico)
export BAT_THEME="base16-256"

# man pages con highlight
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# top -> btop | du -> dust | df -> duf | diff -> delta
alias top='btop'
alias htop='btop'
alias du='dust'
alias df='duf --hide special'
alias diff='delta --side-by-side'

# markdown renderizado en terminal
alias md='glow -p'

# lazygit
alias lg='lazygit'

# Tree visual limpio
alias tree='eza --tree --icons=auto --group-directories-first --git-ignore'
alias treea='eza --tree --icons=auto --group-directories-first -a --ignore-glob=.git'
alias tree2='eza --tree --icons=auto --group-directories-first --level=2 --git-ignore'
alias tree3='eza --tree --icons=auto --group-directories-first --level=3 --git-ignore'

# ==========================================
# GIT ALIASES
# ==========================================
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull --rebase'
alias gf='git fetch --prune'
alias gb='git branch -vv'
alias gco='git switch'
alias gcb='git switch -c'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'
alias gds='git diff --staged'

# ==========================================
# FZF CONFIGURATION
# ==========================================
# Keybindings (Ctrl+R historial, Ctrl+T archivos, Alt+C cd)
source /usr/share/fzf/shell/key-bindings.bash 2>/dev/null
source /usr/share/fzf/shell/completion.bash 2>/dev/null

export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --exclude .git"

# ==========================================
# NAVIGATION FUNCTIONS
# ==========================================

# Git: ir a la raíz del repo actual
groot() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "No estás dentro de un repo git"
    return 1
  }

  cd "$root" || return 1
}

# Git: abrir repo actual en GitHub si tiene origin
gopen() {
  local url
  url=$(git remote get-url origin 2>/dev/null) || {
    echo "Este repo no tiene remote origin"
    return 1
  }

  url="${url/git@github.com:/https:\/\/github.com\/}"
  url="${url%.git}"

  xdg-open "$url" >/dev/null 2>&1 &
}

# Git: switch de rama con fzf
gsw() {
  local br
  br=$(
    git branch --sort=-committerdate --format='%(refname:short)' |
      fzf --height=40% --border --prompt='Rama  ' \
        --preview='git log --oneline -5 {}'
  )

  [[ -n "$br" ]] && git switch "$br"
}

# Git: diff interactivo por archivo
gdf() {
  local files
  files=$(
    git diff --name-only |
      fzf -m --height=50% --border --prompt='Diff  '
  )

  [[ -n "$files" ]] && git diff -- $files
}

# ==========================================
# DOTFILES & PROJECTS
# ==========================================
export PROJECTS_DIR="$HOME/GitHub-Repo"

# clone: clona dentro de $PROJECTS_DIR y entra al repo
#   clone user/repo          -> GitHub por SSH
#   clone https://... | git@...  -> URL tal cual
#   clone -s user/repo       -> shallow (--depth 1)
#   clone user/repo mi-nombre -> nombre de carpeta custom
clone() {
  local depth="" repo name url target_dir
  if [[ "$1" == "-s" ]]; then
    depth="--depth 1"
    shift
  fi
  repo="$1" name="$2"
  [[ -z "$repo" ]] && {
    echo "uso: clone [-s] user/repo|url [nombre]"
    return 1
  }

  # Distinguir shorthand de URL
  if [[ "$repo" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
    url="git@github.com:${repo}.git"
  else
    url="$repo"
  fi

  # Normalizar: sin trailing slash (previene la //)
  PROJECTS_DIR="${PROJECTS_DIR%/}"
  # Si no se pasó nombre, derivarlo de la URL
  name="${name:-$(basename "$url" .git)}"
  target_dir="$PROJECTS_DIR/$name"

  # Si ya existe, no reclonar: entrar directo
  if [[ -d "$target_dir" ]]; then
    echo "✓  $target_dir ya existe, entrando"
    cd "$target_dir" || return 1
    return 0
  fi

  mkdir -p "$PROJECTS_DIR"
  git clone $depth "$url" "$target_dir" && cd "$target_dir"
}

# repos: selector fuzzy de repos clonados
repos() {
  local dir
  dir=$(
    find "$PROJECTS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null |
      sort |
      fzf --height=40% --layout=reverse --border --prompt="Repo  "
  )

  [[ -n "$dir" ]] && cd "$dir"
}

# ==========================================
# DOTFILES HELPERS
# ==========================================
alias dot="cd ~/dotfiles/"
alias bar="pkill waybar && waybar >/tmp/waybar.log 2>&1 &"

# ==========================================
# YAZI & ZOXIDE
# ==========================================

# Yazi wrapper function for cd on quit
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# Zoxide (smart cd)
eval "$(zoxide init bash)"
