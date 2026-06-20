# Garuda x CachyOS zsh — opt-in shell (default login shell stays bash; run `chsh -s /bin/zsh`).
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt autocd extendedglob histignoredups sharehistory
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# Starship prompt
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Handy aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias update='paru -Syu'
