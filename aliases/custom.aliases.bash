# shellcheck shell=bash
about-alias 'custom aliases'

alias ssh='kitty +kitten ssh'
alias power='cat /sys/class/power_supply/BAT0/capacity'
alias battery='power'
alias vimrc='vim ~/Project/dotfiles/.vimrc'
alias kittyrc='vim ~/Project/dotfiles/.config/kitty/kitty.conf'
alias hyprrc='vim ~/Project/dotfiles/.config/hypr/hyprland.conf'
alias gitconfig='vim ~/Project/dotfiles/.gitconfig'
alias config='vim ~/Project/dotfiles/.config/waybar/config'

#alias l='LANG=C.UTF-8 ls -A --group-directories-first --indicator-style=classify --escape'
alias l='exa -A --group-directories-first --git --icons --color=always'
#alias ll='LANG=C.UTF-8 ls -lA --group-directories-first --indicator-style=classify --escape'
alias ll='exa -lA --group-directories-first --git --icons --color=always'
alias lt='exa -A --tree --git --color=always'
alias lt3='exa -A --tree --git --color=always -L 3'

# git
alias ga='git add -A'
alias gap='git add -p'
alias gcb='git checkout -b'
alias gcm='git commit -m'
alias gd='git diff'
alias gds='git diff --staged'
alias gcb='git checkout -b'
alias gst='git status'
alias glo='git log --oneline'
alias gsp='git show -p'
alias gr='git reset HEAD~1'

alias lazy='lazygit'

#alias diff='git diff | delta --navigate --paging always'
#alias diffs='git diff --staged | delta --navigate --paging always'
#alias show='git show | delta --navigate --paging always'
#alias log='git log --oneline'
