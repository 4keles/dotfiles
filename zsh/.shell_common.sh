# Hem bash hem zsh tarafından source edilir (bkz. .bashrc / .zshrc)
# PATH ve shell-agnostic alias'lar burada tutulur ki iki shell birbirinden sapmasın.

export PATH="$HOME/anaconda3/condabin:$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/var/lib/snapd/snap/bin:$HOME/anaconda3/bin:$HOME/apps"
export GOPATH="$HOME/go"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# opencode / npm
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.local/share/npm/bin:$PATH"

