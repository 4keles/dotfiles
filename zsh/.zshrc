# PATH / alias eklerken buraya değil ~/.shell_common.sh'a ekle (bash+zsh ortak, aksi halde bash'ta görünmez)
[ -f ~/.shell_common.sh ] && source ~/.shell_common.sh

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Powerlevel10k instant prompt - en başta olmalı
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_THEME="powerlevel10k/powerlevel10k"

# Pluginler
plugins=(
  git
  fzf
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
  you-should-use
  sudo
  copypath
  copyfile
  dirhistory
  web-search
)

source $ZSH/oh-my-zsh.sh

# ── Geçmiş ayarları ──────────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY

# ── Tamamlama ayarları ────────────────────────────────────────────────────────
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --color=always $realpath 2>/dev/null || ls $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --tree --color=always $realpath 2>/dev/null || ls $realpath'

# ── fzf ayarları ──────────────────────────────────────────────────────────────
export FZF_DEFAULT_OPTS="
  --height=50%
  --layout=reverse
  --border=rounded
  --color=fg:#ffebc3,bg:#3c4c55,hl:#a9dd9d
  --color=fg+:#ffebc3,bg+:#485b66,hl+:#a9dd9d
  --color=info:#f0aa8a,prompt:#bdd0e5,pointer:#daccf0
  --color=marker:#fd8489,spinner:#a9dd9d,header:#7f8f9f
"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :50 {}' 2>/dev/null"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {}' 2>/dev/null"

# ── zoxide (akıllı cd) ────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

# ── Aliaslar ──────────────────────────────────────────────────────────────────
# eza (modern ls)
if command -v eza &>/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -lah --icons --group-directories-first --git'
  alias lt='eza --tree --icons --level=2'
  alias ltt='eza --tree --icons --level=3'
else
  alias ll='ls -lah --color=auto'
fi

# bat (modern cat)
if command -v bat &>/dev/null; then
  alias cat='bat --style=auto'
fi

# git kısayolları
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias glog='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# sistem
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -pv'
alias df='df -h'
alias du='du -sh'
alias free='free -h'
alias ports='ss -tulnp'
alias myip='curl -s ifconfig.me'

# editör
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# config kısayolları
alias zshrc='${EDITOR:-nvim} ~/.zshrc && source ~/.zshrc'
alias kittyrc='${EDITOR:-nvim} ~/.config/kitty/kitty.conf'

# ── history-substring-search tuş bağlamaları ─────────────────────────────────
# kitty ^[OA/^[OB gönderiyor, ^[[A değil
zmodload zsh/terminfo
bindkey "${terminfo[kcuu1]}" history-substring-search-up
bindkey "${terminfo[kcud1]}" history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# ── Autosuggestions rengi ─────────────────────────────────────────────────────
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#7f8f9f,italic"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ── you-should-use ────────────────────────────────────────────────────────────
YSU_MESSAGE_POSITION="after"

# ── Powerlevel10k konfigürasyonu ──────────────────────────────────────────────
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh


# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"
