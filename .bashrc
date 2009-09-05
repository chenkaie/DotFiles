#!/bin/bash

# Source global definitions                                                                                                                                                         
[ -f /etc/bashrc ] && . /etc/bashrc
[ -f /etc/profile ] && . /etc/profile

export EDITOR=vim
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# MANPATH
export MANPATH=$HOME/usr/man:$HOME/usr/share/man:$HOME/usr/cpan/share/man:$MANPATH
export dotfiles="$HOME/Repos/DotFiles"

exist () { type "$1" &> /dev/null; }
#######################
# JOB Related         # 
#######################

#export MAKEINC=/home/project/makcomm
export LINTDIR=/usr/share/pclint
export MANSECT=8:2:1:3:4:5:6:7:9:0p:1p:3p:tcl:n:l:p:o

###############################
# Different OS specific stuff #
###############################

OS=$(uname)             # for resolving pesky os differing switches

case $OS in
    Darwin|*BSD)
        # MacPorts stuff 
        if [ -x /opt/local/bin/port ]; then
            export PATH=/opt/local/bin:/opt/local/sbin:$PATH
            export MANPATH=/opt/local/share/man:$MANPATH

            # bash_completion if installed 
            if [ -x /opt/local/etc/bash_completion ]; then
                . /opt/local/etc/bash_completion
            fi
        fi

        # PATH
        export PATH=$HOME/Tools:$HOME/Tools/subversion-scripts:$HOME/Tools/git-scripts:$PATH
        ;;

    Linux)
        # enable color support of ls and also add handy aliases
        if [ "$TERM" != "dumb" ]; then
            eval `dircolors -b`
        fi

        # enable bash completion 
        if [ -f /etc/bash_completion ]; then
            . /etc/bash_completion
        fi
        # PATH
        export PATH=$HOME/hr:$HOME/Tools:$HOME/Tools/subversion-scripts:$HOME/Tools/git-scripts:$HOME/usr/bin:/sbin/:/opt/Vivotek/lsp/buildroot-2.0.0.0/build_arm_nofpu/staging_dir/bin/:$PATH
        ;;

    *)
        echo "Your OS Type is : `uname -s`"
        # openbsd doesn't do much for color, some others may..
        export CLICOLOR=1
        ;;
esac

#######################
# Alias               # 
#######################

# enable color for LS 
case $OS in
    Darwin|*BSD)
        export CLICOLOR=1
        export LSCOLORS=ExFxCxDxBxegedabagacad
        alias ls='ls -FG'
        ;;
    Linux)
        alias ls='ls -FN --color=auto --time-style=long-iso'
        ;;
esac

alias ll='ls -al'                   # long list format
alias lk='ls -lk'                   # --block-size=1K
alias lt='ls -ltr'                  # sort by date
alias lx='ls -lXB'                  # sort by extension
alias lz='ls -lS'                   # sort by size 
alias ld='ls -d */'                 # es only Dirs
alias l.='ls -dAFh .[^.]*'          # ls only Dotfiles
alias lst='ls -hFtal | grep $(date +%Y-%m-%d)' #ls Today

#alias tree='tree -Cs'              # nice alternative to 'ls'
alias vim='vim -X -p'
alias vi='vim'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias df='df -h'
alias ln='ln -i'
alias psg='ps -ef | grep $1'
alias h='history | grep $1'
alias j='jobs'
alias less='less -R'                # colorful 'less'
alias more='less'
alias mkdir='mkdir -p -v'
alias reload='source ~/.bashrc'
alias wget='wget -c'

# have to check exist()
alias top='htop'
alias gdb='cgdb'
alias xmllint='xmllint --noout'

alias grep='grep -i --colour=auto'
#alias wcgrep='wcgrep -inh --colour=auto' has been defined in wcgrep
alias mdiff='diff -ruN --exclude=.svn'
alias diff='colordiff.pl'

# Moving around & all that jazz
#alias cd='pushd > /dev/null' 
#alias back='popd > /dev/null'
alias b='cd -' # back to $OLDPWD
alias cd..='cd ..'

alias path='echo -e ${PATH//:/\\n}'

#Personal Help
alias l?='cat ~/.bashrc | grep "alias l.=.ls" | grep ^a | less' 
alias a?='alias'
alias f?='cat $dotfiles/.function.help'
alias dn='OPTIONS=$(\ls -F | grep /$); select s in $OPTIONS; do cd $PWD/$s; break;done'
#alias help='OPTIONS=$(\ls $dotfiles/.tips -F);select s in $OPTIONS; do less $dotfiles/.tips/$s; break;done' 

#delete
alias del='mv --target-directory=$HOME/.Trash/'

#aliases and export for Project
alias cdpd='cd ${PRODUCTDIR}'
alias cdrd='cd ${IMAGEDIR}'
alias pd='echo ${PRODUCTDIR}'
alias rmrd='cd ${PRODUCTDIR}/release; rm -rf app_cluster_Build/ flashfs/ rootfs/'

#make for fun
alias make='cmake'
alias m='make'
alias mc='m cleanall'
alias mi='m install'
alias mall='mc && m && mi'

#gcc
alias agcc='arm-linux-gcc -Wall'
alias gcc='gcc -Wall'

#Lint related
exist jsl  && alias jsl='jsl -conf ~/Tools/jsl.conf -process'
if exist lint ; then
    alias lint-gnu='lint +v ~/makcomm/std_gnu_kent.lnt ~/makcomm/env-vim.lnt'
    alias lint-gnu-xml='lint-gnu ~/makcomm/env-xml.lnt'
    alias lint-gnu-html='lint-gnu ~/makcomm/env-html.lnt'
    alias lint-arm='lint +v ~/makcomm/std_armgcc_kent.lnt ~/makcomm/env-vim.lnt'
    alias lint-arm-xml='lint-arm ~/makcomm/env-xml.lnt'
    alias lint-arm-html='lint-arm ~/makcomm/env-html.lnt'
fi

#######################
# Default             # 
#######################
set -o noclobber 

# Define Colors {{{
TXTBLK='\e[0;30m' # Black - Regular
TXTRED='\e[0;31m' # Red
TXTGRN='\e[0;32m' # Green
TXTYLW='\e[0;33m' # Yellow
TXTBLU='\e[0;34m' # Blue
TXTPUR='\e[0;35m' # Purple
TXTCYN='\e[0;36m' # Cyan
TXTWHT='\e[0;37m' # White
BLDBLK='\e[1;30m' # Black - Bold
BLDRED='\e[1;31m' # Red
BLDGRN='\e[1;32m' # Green
BLDYLW='\e[1;33m' # Yellow
BLDBLU='\e[1;34m' # Blue
BLDPUR='\e[1;35m' # Purple
BLDCYN='\e[1;36m' # Cyan
BLDWHT='\e[1;37m' # White
UNDBLK='\e[4;30m' # Black - Underline
UNDRED='\e[4;31m' # Red
UNDGRN='\e[4;32m' # Green
UNDYLW='\e[4;33m' # Yellow
UNDBLU='\e[4;34m' # Blue
UNDPUR='\e[4;35m' # Purple
UNDCYN='\e[4;36m' # Cyan
UNDWHT='\e[4;37m' # White
BAKBLK='\e[40m'   # Black - Background
BAKRED='\e[41m'   # Red
BAKGRN='\e[42m'   # Green
BAKYLW='\e[43m'   # Yellow
BAKBLU='\e[44m'   # Blue
BAKPUR='\e[45m'   # Purple
BAKCYN='\e[46m'   # Cyan
BAKWHT='\e[47m'   # White
TXTRST='\e[0m'    # Text Reset
# }}}

PS1=$TXTYLW'[\u]'$TXTWHT'@'$TXTPUR'\h'$TXTWHT':'$TXTGRN'\W'$TXTWHT'\$ '
[ "$OS" == "Darwin" ] &&  PS1=$TXTYLW'[\u]'$TXTWHT'@'$TXTRED'\h'$TXTWHT':'$TXTGRN'\W'$TXTWHT'\$ '

# add for screen to dynamically update title
#PROMPT_COMMAND='echo -n -e "\033k\033\134"'

#history control, ignorespace & ignoredups
export HISTCONTROL=ignoreboth
export HISTSIZE=5000
export HISTTIMEFORMAT="%Y-%m-%d_%H:%M:%S_%a  "

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
shopt -s histappend
export PROMPT_COMMAND='history -a'

#export MANPAGER="most -s"
# For colourful man pages (CLUG-Wiki style)
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

#for X-Win32
#export DISPLAY="172.16.2.54:0:0"

# For all SSH (Reverse) Tunnel
case $OS in
    Darwin|*BSD)
        alias dd-wrt='ssh 192.168.1.1 -p2222 -lroot'
        alias dd-wrt_rd1-2='ssh -L 7322:127.0.0.1:7322 192.168.1.1 -lroot -p2222'
        alias rd1-2='ssh localhost -p 7322'
        alias rd1-2-proxy='ssh -D 8080 localhost -p7322'
        ;;

    Linux)
        alias tunnel-mac='ssh -R 7322:rd1-2:22 chenkaie.no-ip.org'
        alias tunnel-ap='ssh -R 7322:rd1-2:22 chenkaie.no-ip.org -lroot -p2222'
        alias rd1wiki='ssh -R 8080:rd1-1:80 chenkaie.no-ip.org'
        alias dd-wrt='ssh chenkaie.no-ip.org -p2222 -lroot'
        #alias syncToRD1-3='rsync -r -a -v -e "ssh -l kent" --delete ~/Tools rd1-3:Tools'
        #alias syncToMac='rsync -r -a -v -e "ssh -l kent" --delete ~/Tools chenkaie.no-ip.org:RD1-2/Tools'
        ;;
esac

# funny stuff cowsay
echo "Welcome to $HOSTNAME" | cowsay -f default

# source bash related script
rcfiles="$dotfiles/rcfiles"
source $rcfiles/completion/bash_completion
source $rcfiles/completion/svn_completion
source $rcfiles/completion/git-completion
source $rcfiles/completion/cdargs-bash.sh
source $rcfiles/completion/cdots.sh

# make less more friendly for non-text input files, see lesspipe(1)
exist lesspipe && eval "$(lesspipe)"

#######################
# Functions           # 
#######################

# Easy extract
extract () {
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       rar x $1       ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *)           echo "don't know how to extract '$1'..." ;;
      esac
  else
      echo "'$1' is not a valid file!"
  fi
}

# easy compress - archive wrapper
# usage: compress <foo.tar.gz> ./foo ./bar
compress ()
{
    FILE=$1
    case $FILE in
    *.tar.bz2) shift && tar cjf $FILE $* ;;
    *.tar.gz) shift && tar czf $FILE $* ;;
    *.tgz) shift && tar czf $FILE $* ;;
    *.zip) shift && zip $FILE $* ;;
    *.rar) shift && rar $FILE $* ;;
    esac
}

function sysinfo() # get current host related info
{
    echo -e "\nYou are logged on ${RED}$HOST"
    echo -e "\nAdditionnal information:$NC " ; uname -a
    echo -e "\n${RED}Users logged on:$NC " ; w -h
    echo -e "\n${RED}Current date :$NC " ; date
    echo -e "\n${RED}Machine stats :$NC " ; uptime
    echo -e "\n${RED}Memory stats :$NC " ; free
    echo -e "\n${RED}Local IP Address :$NC" ; myip
}

# Get IP (call with myip)
function myip {
    myip=`elinks -dump http://checkip.dyndns.org:8245/`
    echo "${myip}"
}

encrypt () { gpg -ac --no-options "$1"; }
decrypt () { gpg --no-options "$1"; }

# finds directory sizes and lists them for the current directory
dirsize ()
{
    du -shx * .[a-zA-Z0-9_]* 2> /dev/null | \
    egrep '^ *[0-9.]*[MG]' | sort -n > /tmp/list
    egrep '^ *[0-9.]*M' /tmp/list
    egrep '^ *[0-9.]*G' /tmp/list
    rm -rf /tmp/list
}

# ls when cd, it's useful
cd () {
    if [ -n "$1" ]; then
        builtin cd "$@"&& ls
    else
        builtin cd ~&& ls
    fi
}

# swap() -- switch 2 filenames around
function swap()
{
    local TMPFILE=tmp.$$
    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}

# repeat() -- repeat a given command N times
function repeat() # repeat n times command
{
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do
        eval "$@";
    done
}

# vim: fdm=marker ts=4 sw=4 et:
