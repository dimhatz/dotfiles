#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
# Base16 Shell
BASE16_SHELL="$HOME/.dark-term-theme.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL
