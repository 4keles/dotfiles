# Powerlevel10k konfigürasyonu
# p10k configure ile wizard üzerinden de değiştirebilirsin

# Sol prompt segmentleri
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  custom_tmux
  os_icon
  dir
  time
  vcs
  newline
  prompt_char
)

# Show a label only inside a tmux session.
function p10k_tmux_label() {
  if [[ -n "$TMUX" ]]; then
    print -r -- '[tmux]'
  fi
}
typeset -g POWERLEVEL9K_CUSTOM_TMUX='p10k_tmux_label'
typeset -g POWERLEVEL9K_CUSTOM_TMUX_FOREGROUND='#ff6b6b'

# Sağ prompt segmentleri
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status
  command_execution_time
  background_jobs
  node_version
  virtualenv
)

# ── Genel ─────────────────────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_MODE=nerdfont-v3
typeset -g POWERLEVEL9K_ICON_PADDING=moderate
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
typeset -g POWERLEVEL9K_BACKGROUND=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=same-dir
typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

# ── OS icon ───────────────────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=212

# ── Prompt karakteri ──────────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=76
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196
typeset -g POWERLEVEL9K_PROMPT_CHAR_CONTENT_EXPANSION='❯'

# ── Dizin ─────────────────────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_DIR_FOREGROUND=31
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=103
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=39
typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3

# ── Git (vcs) ─────────────────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=76
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=76
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=178
typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED}_BACKGROUND=
typeset -g POWERLEVEL9K_VCS_LOADING_TEXT=

# ── Komut süresi ──────────────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=1
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=101
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION=

# ── Hata kodu ────────────────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
typeset -g POWERLEVEL9K_STATUS_OK=false
typeset -g POWERLEVEL9K_STATUS_ERROR=true
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=160
typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION=
typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=160
typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=160

# ── Arka plan işleri ─────────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=37

# ── Saat ──────────────────────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'
typeset -g POWERLEVEL9K_TIME_FOREGROUND=82
typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION=
typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false

# ── Node version ──────────────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=70
typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true

# ── Python virtualenv ─────────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=37
typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false
