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

#Local Sourcing
if [ -f "$HOME/.bashrc.local" ]; then
  source "$HOME/.bashrc.local"
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

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

# Yazi wrapper function for cd on quit
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
eval "$(zoxide init bash)"

alias dot="cd ~/dotfiles/"
alias bar="pkill waybar && waybar &"
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
alias catn='bat --paging=never'
alias cat='bat'

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

alias lg='lazygit'

# Tree visual limpio
alias tree='eza --tree --icons=auto --group-directories-first --git-ignore'
alias treea='eza --tree --icons=auto --group-directories-first -a --ignore-glob=.git'
alias tree2='eza --tree --icons=auto --group-directories-first --level=2 --git-ignore'
alias tree3='eza --tree --icons=auto --group-directories-first --level=3 --git-ignore'

# fzf: keybindings (Ctrl+R historial, Ctrl+T archivos, Alt+C cd)
source /usr/share/fzf/shell/key-bindings.bash 2>/dev/null
source /usr/share/fzf/shell/completion.bash 2>/dev/null
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --exclude .git"

export PATH="$HOME/.local/bin:$PATH"
