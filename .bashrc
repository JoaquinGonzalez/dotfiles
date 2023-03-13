#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# alias ls='ls --color=auto'
# PS1='[\u@\h \W]\$ '

alias ls='ls -lah --color=auto'

export VIMINIT='source ~/.config/vim/vimrc'

export PATH=$PATH:~/.local/bin
export BROWSER=firefox
export EDITOR=nvim
