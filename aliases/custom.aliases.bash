# shellcheck shell=bash
about-alias 'custom aliases'

alias ssh='kitty +kitten ssh'
alias power='cat /sys/class/power_supply/BAT0/capacity'
alias battery='power'
alias vimrc='vim ~/Project/dotfiles/.vimrc'
alias kittyrc='vim ~/Project/dotfiles/.config/kitty/kitty.conf'
alias hyprrc='vim ~/Project/dotfiles/.config/hypr/hyprland.conf'
alias gitconfig='vim ~/Project/dotfiles/.gitconfig'

#alias l='LANG=C.UTF-8 ls -A --group-directories-first --indicator-style=classify --escape'
alias l='exa -A --group-directories-first --git --icons --color=always'
#alias ll='LANG=C.UTF-8 ls -lA --group-directories-first --indicator-style=classify --escape'
alias ll='exa -lA --group-directories-first --git --icons --color=always'
alias lt='exa -A --tree --git --color=always'

# git
alias ga='git add -A'
alias gcb='git checkout -b'
alias gcm='git commit -m'
alias gd='git diff'
alias gds='git diff --staged'
alias gcb='git checkout -b'
alias gst='git status'
alias glo='git log --oneline'
alias lazy='lazygit'

#alias diff='git diff | delta --navigate --paging always'
#alias diffs='git diff --staged | delta --navigate --paging always'
#alias show='git show | delta --navigate --paging always'
#alias log='git log --oneline'
