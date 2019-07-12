
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
# PS1='[\u@\h \W]\$ '
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

# Base16 Shell - setting colors
BASE16_SHELL="$HOME/.dark-term-theme.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

# Disable freezing screen with c-s (and unfreezing with c-q)
stty -ixon

# Make default esc sequence for backspace ^? (in case it was ^H) so that we can map c-h in vim
stty erase ^?

# Set eof char to ^Q instead of ^D - works, not sure if needed
#stty eof ^Q

# now we can use arrows/vi-style in sml interactive mode
alias sml='rlwrap sml'
# now we can use arrows/vi-style in prolog top level
alias swipl='rlwrap swipl'

export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=50000                   # big big history
export HISTFILESIZE=$HISTSIZE           # big big history
shopt -s histappend                     # append to history, don't overwrite it

# Not sure, but might interfere with !1 type commands (last command from history)
# Save and reload the history after each command finishes
# Should enable command completion sharing between terminals
# - requires any command first (even empty aka Enter)to reread command history
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
