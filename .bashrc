#!/bin/bash

# If not running interactively, don't do anything. 
# This snippet helps to fix scp, sftp "Received message too long" issue..
[ -z "$PS1" ] && return

# Source global definitions

[ -f /etc/bashrc ] && . /etc/bashrc
[ -f /etc/profile ] && . /etc/profile

export TERM=xterm-256color
export EDITOR=vim
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export dotfiles="$HOME/Repos/DotFiles"

exist () { type "$1" &> /dev/null; }
#######################
# JOB Related         # 
#######################

#export MAKEINC=/home/project/makcomm
export LINTDIR=/usr/share/pclint
export MANSECT=8:2:1:3:4:5:6:7:9:0p:1p:3p:tcl:n:l:p:o

# GIT daily repo commit variable (A.K.A GIT Time Machine)
export GIT_MANAGED_DIRECTORY="$HOME/Project $HOME/ArmTools $HOME/Repos $HOME/practice $HOME/usr $HOME/makcomm-debug"

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
        export PATH=$HOME/Tools:$HOME/Tools/subversion-scripts:$HOME/Tools/git-scripts:$HOME/usr/bin:$PATH
        # MANPATH
        export MANPATH=$HOME/usr/man:$HOME/usr/share/man:$MANPATH
        # PERL5LIB
        export PERL5LIB=$HOME/usr/lib/perl5/site_perl/5.10.1:$HOME/usr/lib/perl5/5.10.1:$PERL5LIB
        ;;

    Linux)
        # enable color support of ls and also add handy aliases
        if [ "$TERM" != "dumb" ]; then
            eval `dircolors -b`
        fi

        # Note that, Ubuntu have been already done sourcing /etc/bash_completion in /etc/profile,
        # Source this file twice will cause user fail to login GNOME.
        # You can check this file ~/.xsession-errors to find out why you login GNOME failed.
        IsUbuntu=$(lsb_release -a | grep Ubuntu)
        # enable bash completion 
        if [ -z "$IsUbuntu" ] && [ -f /etc/bash_completion ]; then
            . /etc/bash_completion
        fi
        # PATH
        export PATH=$HOME/hr:$HOME/perl5/bin:$HOME/Tools:$HOME/Tools/subversion-scripts:$HOME/Tools/git-scripts:$HOME/usr/bin:$HOME/usr/sbin:$PATH
        # MANPATH
        export MANPATH=$HOME/usr/man:$HOME/usr/share/man:$HOME/usr/cpan/share/man:$MANPATH

        # PERL5
        source $HOME/perl5/perlbrew/etc/bashrc
        export PERL_CPANM_OPT="-l ~/perl5"
        export PERL5LIB=$HOME/perl5/lib/perl5:$PERL5LIB
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
        # By installing Macports: GNU coreutils, alias as Linux-way
        alias ls='ls -FN --color=auto --time-style=long-iso'
        ;;
    Linux)
        alias ls='ls -FN --color=auto --time-style=long-iso'
        ;;
esac

alias l='ls -FG'
alias ll='ls -al'                   # long list format
alias lk='ls -lk'                   # --block-size=1K
alias lt='ls -ltr'                  # sort by date (mtime)
alias lc='ls -ltcr'                 # sort by and show change time
alias la='ls -ltur'                 # sort by and show access time
alias lx='ls -lXB'                  # sort by extension
alias lz='ls -lSr'                  # sort by size 
alias ld='ls -d */'                 # es only Dirs
alias l.='ls -dAFh .[^.]*'          # ls only Dotfiles
alias lst='ls -hFtal | grep $(date +%Y-%m-%d)' #ls Today

#alias tree='tree -Cs'              # nice alternative to 'ls'
alias vim='vim -X -p'
alias vi='vim'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias df='df -kTh'
alias ln='ln -i -n'
alias psg='ps -ef | grep $1'
alias h='history | grep $1'
alias j='jobs'
alias less='less -R --tabs=4'       # colorful 'less', tab stops = 4
alias more='less'
alias mkdir='mkdir -p -v'
alias reload='source ~/.bashrc'
alias wget='wget -c'
alias which='type -a'
alias quota='quota -vs'
alias grep='grep --mmap --color'

# have to check exist()
alias top='htop'
alias xmllint='xmllint --noout'

#export GREP_OPTIONS="--exclude-dir=\*/.svn/\* --exclude=\*~ --exclude=\*.swp"
#alias wcgrep='wcgrep -inh --colour=auto' has been defined in wcgrep
alias mdiff='diff -ruN --exclude=.svn'
alias diff='colordiff.pl'

# Moving around & all that jazz
#alias cd='pushd > /dev/null' 
#alias back='popd > /dev/null'
alias b='cd -' # back to $OLDPWD
alias cd..='cd ..'

alias path='echo -e ${PATH//:/\\n}'
# Generate Windows CIFS path prepend with Network Drive id: "Z:"
alias pwd-win='pwd | sed '"'"'s/\//\\/g'"'"' | sed '"'"'s/\(.*\)/Z:\1/'"'"''
# A simple python http file server
alias hfs='python -m SimpleHTTPServer 8080'

#Personal Help
alias l?='cat ~/.bashrc | grep "alias l.*=.ls" | grep ^a' 
alias a?='alias'
alias f?='cat $dotfiles/.function.help'
alias dn='OPTIONS=$(\ls -F | grep /$); select s in $OPTIONS; do cd $PWD/$s; break;done'
#alias help='OPTIONS=$(\ls $dotfiles/.tips -F);select s in $OPTIONS; do less $dotfiles/.tips/$s; break;done' 

#delete
alias del='mv --target-directory=$HOME/.Trash/'

#aliases and export for Project
alias pcd='cd ${PRODUCTDIR}'
alias icd='cd ${IMAGEDIR}'
alias scd='cd ${PRODUCTDIR}/build/scripts'
alias rcd='cd ${PRODUCTDIR}/release;pwd'
alias pd='echo ${PRODUCTDIR}'
alias rmrd='[ -n "$PRODUCTDIR" ] && cd ${PRODUCTDIR}/release; rm -rf app_cluster_Build/ flashfs/ rootfs/; cd -'

#make for fun
alias make='cmake'
alias m='make'
alias mc='m clean'
alias mca='m cleanall'
alias mi='m install'
alias mall='mca && m && mi'

#gcc
alias agcc='arm-linux-gcc -Wall -g3 -fno-omit-frame-pointer -fno-inline -Wcast-align -Wpadded -Wpacked -std=gnu99'
alias gcc='gcc -Wall -g3 -fno-omit-frame-pointer -fno-inline -Wcast-align -Wpadded -Wpacked -std=gnu99'
alias objdump='objdump -d -S -hrt'
alias gdb='gdb --command=$HOME/Repos/DotFiles/.gdbinit-7.3'

#Lint related
exist jsl  && alias jsl='jsl -conf ~/Tools/jsl.conf -process'
if exist lint ; then
    alias lint-gnu='lint ~/makcomm/env-vim.lnt'
    alias lint-gnu-xml='lint-gnu ~/makcomm/env-xml.lnt'
    alias lint-gnu-html='lint-gnu ~/makcomm/env-html.lnt'
    alias lint-arm='lint ~/makcomm/env-vim.lnt'
    alias lint-arm-xml='lint-arm ~/makcomm/env-xml.lnt'
    alias lint-arm-html='lint-arm ~/makcomm/env-html.lnt'
fi

# ccache & distcc
alias enjoy-ccache-distcc="source $HOME/Tools/use_distcc_ccache"

#######################
# Bash SHell opts     # 
#######################

#history control, ignorespace & ignoredups
export HISTCONTROL=ignoreboth
export HISTSIZE=100000
export HISTTIMEFORMAT="%Y-%m-%d_%H:%M:%S_%a  "
export HISTIGNORE="&:bg:fg:ll:h"

#Specify that it (Ctrl+D) must pressed twice to exit Bash
export IGNOREEOF=1

set -o noclobber 
set -o notify
#set -o xtrace          # Useful for debuging.

# Enable options:
# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize
shopt -s histappend
shopt -s no_empty_cmd_completion
shopt -s cdspell
shopt -s checkhash

#######################
# Default             # 
#######################

# Define Colors {{{
TXTBLK="\[\033[0;30m\]" # Black - Regular
TXTRED="\[\033[0;31m\]" # Red
TXTGRN="\[\033[0;32m\]" # Green
TXTYLW="\[\033[0;33m\]" # Yellow
TXTBLU="\[\033[0;34m\]" # Blue
TXTPUR="\[\033[0;35m\]" # Purple
TXTCYN="\[\033[0;36m\]" # Cyan
TXTWHT="\[\033[0;37m\]" # White
BLDBLK="\[\033[1;30m\]" # Black - Bold
BLDRED="\[\033[1;31m\]" # Red
BLDGRN="\[\033[1;32m\]" # Green
BLDYLW="\[\033[1;33m\]" # Yellow
BLDBLU="\[\033[1;34m\]" # Blue
BLDPUR="\[\033[1;35m\]" # Purple
BLDCYN="\[\033[1;36m\]" # Cyan
BLDWHT="\[\033[1;37m\]" # White
UNDBLK="\[\033[4;30m\]" # Black - Underline
UNDRED="\[\033[4;31m\]" # Red
UNDGRN="\[\033[4;32m\]" # Green
UNDYLW="\[\033[4;33m\]" # Yellow
UNDBLU="\[\033[4;34m\]" # Blue
UNDPUR="\[\033[4;35m\]" # Purple
UNDCYN="\[\033[4;36m\]" # Cyan
UNDWHT="\[\033[4;37m\]" # White
BAKBLK="\[\033[40m\]"   # Black - Background
BAKRED="\[\033[41m\]"   # Red
BAKGRN="\[\033[42m\]"   # Green
BAKYLW="\[\033[43m\]"   # Yellow
BAKBLU="\[\033[44m\]"   # Blue
BAKPUR="\[\033[45m\]"   # Purple
BAKCYN="\[\033[46m\]"   # Cyan
BAKWHT="\[\033[47m\]"   # White
TXTRST="\[\033[0m\]"    # Text Reset
# }}}

# Git shell prompt
if [ "\$(type -t __git_ps1)" ]; then
    PROMPT_GIT='$(__git_ps1 "|%s")'
fi

case $OS in
    Darwin|*BSD)
        PROMPT_HOSTCOLOR=$TXTRED
        ;;
    Linux)
        PROMPT_HOSTCOLOR=$TXTPUR
        ;;
esac

PS1=$TXTYLW'\u'$TXTWHT'@'${PROMPT_HOSTCOLOR}'\h'$TXTWHT':'$TXTGRN'\W'$TXTWHT${PROMPT_GIT}$BLDBLK'$(counter)'$TXTGRN' >'$BLDGRN'>'$BLDWHT'> '$TXTWHT

# add for screen to dynamically update title
#PROMPT_COMMAND='echo -n -e "\033k\033\134"'


export PROMPT_COMMAND='history -a'

#export MANPAGER="most -s"
# For colourful man pages (CLUG-Wiki style)
#export LESS_TERMCAP_mb=$'\E[01;31m'
#export LESS_TERMCAP_md=$'\E[01;31m'
#export LESS_TERMCAP_me=$'\E[0m'
#export LESS_TERMCAP_se=$'\E[0m'
#export LESS_TERMCAP_so=$'\E[01;44;33m'
#export LESS_TERMCAP_ue=$'\E[0m'
#export LESS_TERMCAP_us=$'\E[01;32m'

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

# Completion support
source $dotfiles/completion/bash-completion/bash_completion
source $dotfiles/completion/svn_completion
source $dotfiles/completion/git-completion
source $dotfiles/completion/cdargs-bash.sh
source $dotfiles/completion/cdots.sh
source $dotfiles/completion/git-flow-completion.bash

# make less more friendly for non-text input files, see lesspipe(1)
exist lesspipe && eval "$(lesspipe)"

#export LESS='-i -N -w  -z-4 -g -e -M -X -F -R -P%t?f%f :stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'

#######################
# Functions           # 
#######################

# Easy extract
extract () 
{
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
compress ()
{
    if [ -n "$1" ] ; then
        FILE=$1
        case $FILE in
        *.tar) shift && tar cf $FILE $* ;;
        *.tar.bz2) shift && tar cjf $FILE $* ;;
        *.tar.gz) shift && tar czf $FILE $* ;;
        *.tgz) shift && tar czf $FILE $* ;;
        *.zip) shift && zip $FILE $* ;;
        *.rar) shift && rar $FILE $* ;;
        esac
    else
        echo "usage: compress <foo.tar.gz> ./foo ./bar"
    fi
}

# get current host related info
function sysinfo()
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
function myip 
{
    myip=`elinks -dump http://checkip.dyndns.org:8245/`
    echo "${myip}"
}

encrypt () { gpg -ac --no-options "$1"; }
decrypt () { gpg --no-options "$1"; }

# finds directory sizes and lists them for the current directory
dirsize ()
{
    du -shx * .[a-zA-Z0-9_]* . 2> /dev/null | \
    egrep '^ *[0-9.]*[MG]' | sort -n > /tmp/list
    egrep '^ *[0-9.]*M' /tmp/list
    egrep '^ *[0-9.]*G' /tmp/list
    rm -rf /tmp/list
}

# ls when cd, it's useful
function cd () 
{
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
function repeat()
{
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do
        eval "$@";
    done
}

# Find a file with pattern $1 in name and Execute $2 on it:
function fe()
{ wcfind . -type f -iname '*'${1:-}'*' -exec ${2:-ls} {} \;  ; }

# lazy gcc, default outfile: filename_prefix.out, eg: hello.c -> hello.out
function lgcc () 
{
    gcc -o ${1%.*}{.out,.${1##*.}}
}

# lazy arm-linux-gcc, default outfile: filename_prefix.platform.out, eg: hello.c -> hello.arm.out
function lagcc () 
{
    # add '-a' for print all matching executables in PATH, not just the first to resolve ccache caused problem.
    platform=`\which -a arm-linux-gcc 2> /dev/null`
    case $platform in
        *vivaldi*)
            outfilesuffix="vivaldi"
            ;;
        *bach*)
            outfilesuffix="bach"
            ;;
        *haydn*)
            outfilesuffix="haydn"
            ;;
        *mozart*)
            outfilesuffix="mozart"
            ;;
        *montavista*)
            outfilesuffix="dm365"
            ;;
        *arm*)
            outfilesuffix="arm"
            ;;
        "")
            echo "[Error] arm-linux-gcc not found."
            return 1
            ;;
    esac

    echo "[Info] You are building on ${outfilesuffix} platform."
    agcc -o ${1%.*}{.${outfilesuffix}.out,.${1##*.}}
}

function counter()
{
    case $1 in *-h*) echo "(jobnum|dirnum)" ;; esac

    jobnum="$(jobs | wc -l | tr -d " ")"
    dirnum="$(dirs -v | tail -n 1 | awk '{print $1}')"

    if [ `expr $jobnum + $dirnum` -gt 0 ]; then
        echo -n " (${jobnum}/${dirnum})"
    fi
}

# vim: fdm=marker ts=4 sw=4 et:
