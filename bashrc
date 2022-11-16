
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls -al --color=auto'
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

# Auto-launching ssh-agent on Git for Windows
# TODO: exit here if linux

# cd to home (on windows it starts in /)
cd ~

env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi

unset env