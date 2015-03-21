#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# Base16 Shell - setting colors
BASE16_SHELL="$HOME/.dark-term-theme.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

# Disable freezing screen with c-s (and unfreezing with c-q)
stty -ixon

# Set eof char to ^Q instead of ^D - works, not sure if needed
#stty eof ^Q

# now we can use arrows/vi-style in sml interactive mode
alias sml='rlwrap sml'
