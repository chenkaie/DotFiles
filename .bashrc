export PATH=$HOME/hr:$HOME/Tools:$HOME/Tools/subversion-scripts:$HOME/Tools/git-scripts:$HOME/usr/bin:/sbin/:/opt/Vivotek/lsp/buildroot-2.0.0.0/build_arm_nofpu/staging_dir/bin/:$PATH
export MANPATH=$HOME/usr/man:$HOME/usr/share/man:$MANPATH

#export MAKEINC=/home/project/makcomm
export LINTDIR=/usr/share/pclint
export MANSECT=8:2:1:3:4:5:6:7:9:0p:1p:3p:tcl:n:l:p:o
#export PROJ_ROOT=~/ProjectRoot
export EDITOR=vim

# other environment variables
export MANPATH=$HOME/usr/man:$HOME/usr/share/man:$HOME/usr/cpan/share/man:$MANPATH

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    eval `dircolors -b`
fi

HOST=$(hostname)        # for host info function
OS=$(uname)             # for resolving pesky os differing switches
PROC=$(uname -p)

#######################
# Alias               # 
#######################

[ $OSTYPE == "Linux" ]
alias ls='ls --color=yes -F -N'
alias ll='ls -al'
alias lk='ls -lk'
alias lt='ls -ltr'        # sort by date
alias lx='ls -lXB'        # sort by extension
#alias tree='tree -Cs'    # nice alternative to 'ls'
alias vim="vim -X -p"
alias vi="vim"
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias df='df -h'
alias ln='ln -i'
alias top='htop'
alias gdb='cgdb'
# colorful 'less'
alias cless="less -R"
alias mkdir='mkdir -p -v'
alias reload='source ~/.bashrc'
alias wget='wget -c'
alias xmllint='xmllint --noout'

alias grep='grep -i --colour=auto'
#alias wcgrep='wcgrep -inh --colour=auto' has been defined in wcgrep
alias mdiff="diff -ruN --exclude=.svn"
alias diff="colordiff.pl"

#aliases and export for Project
alias cdpd='cd ${PRODUCTDIR}'
alias cdrd='cd ${IMAGEDIR}'
alias pd='echo ${PRODUCTDIR}'
#export PD=$PRODUCTDIR

#make for fun
alias make='cmake'
alias m='make'
alias mc="m cleanall"
alias mi="m install"
alias mall='mc && m && mi'
alias rm-release='rm -rf app_cluster_Build/ flashfs/ rootfs/'
#gcc
alias agcc='arm-linux-gcc -Wall'
alias gcc='gcc -Wall'

#Lint related
alias jsl='jsl -conf ~/Tools/jsl.conf -process'
alias lint-gnu='lint +v ~/makcomm/std_gnu_kent.lnt ~/makcomm/env-vim.lnt'
alias lint-gnu-xml='lint-gnu ~/makcomm/env-xml.lnt'
alias lint-gnu-html='lint-gnu ~/makcomm/env-html.lnt'
alias lint-arm='lint +v ~/makcomm/std_armgcc_kent.lnt ~/makcomm/env-vim.lnt'
alias lint-arm-xml='lint-arm ~/makcomm/env-xml.lnt'
alias lint-arm-html='lint-arm ~/makcomm/env-html.lnt'

## Moving around & all that jazz
alias back='cd $OLDPWD'
alias cd..='cd ..'
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

#######################
# Default             # 
#######################
set -o noclobber 

# A fancy prompt
COLOR1="\[\033[0;33m\]"
COLOR2="\[\033[0;35m\]"
COLOR3="\[\033[0;39m\]"
COLOR4="\[\033[0;32m\]"
COLOR5="\[\033[0;31m\]"
PS1=$COLOR1'[\u]'$COLOR3'@'$COLOR2'\h'$COLOR3':'$COLOR4'\W'$COLOR3'\$ '

# add for screen to dynamically update title
PROMPT_COMMAND='echo -n -e "\033k\033\134"'

#history control, ignorespace & ignoredups
export HISTCONTROL=ignoreboth
export HISTSIZE=5000

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
alias tunnel='ssh -R 7322:rd1-2:22 chenkaie.no-ip.org'
alias tunnel-ap='ssh -R 7322:rd1-2:22 chenkaie.no-ip.org -lroot -p2222'
#alias sshTunnel=`ssh localhost -p 7322`
alias rd1wiki='ssh -R 8080:rd1-1:80 chenkaie.no-ip.org'
alias dd-wrt='ssh chenkaie.no-ip.org -p2222 -lroot'
#alias wikiTunnel=`http://localhost:8080`
#alias syncToRD1-3='rsync -r -a -v -e "ssh -l kent" --delete ~/Tools rd1-3:Tools'
#alias syncToMac-3='rsync -r -a -v -e "ssh -l kent" --delete ~/Tools chenkaie.no-ip.org:RD1-2/Tools'

# funny  stuff cowsay
echo "Welcome to RD1-2" | cowsay -f default

# source bash related script
source $HOME/rcfiles/completion/bash_completion
source $HOME/rcfiles/completion/svn_completion
source $HOME/rcfiles/completion/git-completion
source $HOME/rcfiles/completion/cdargs-bash.sh

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

# Creates an archive from given directory
mktar() { tar cvf  "${1%%/}.tar"     "${1%%/}/"; }
mktgz() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }
mktbz() { tar cvjf "${1%%/}.tar.bz2" "${1%%/}/"; }

function sysinfo() # get current host related info
{
    echo -e "\nYou are logged on ${RED}$HOST"
    echo -e "\nAdditionnal information:$NC " ; uname -a
    echo -e "\n${RED}Users logged on:$NC " ; w -h
    echo -e "\n${RED}Current date :$NC " ; date
    echo -e "\n${RED}Machine stats :$NC " ; uptime
    echo -e "\n${RED}Memory stats :$NC " ; free
    echo -e "\n${RED}Local IP Address :$NC" ; myip
    echo
}

# Get IP (call with myip)
function myip {
    myip=`elinks -dump http://checkip.dyndns.org:8245/`
    echo "${myip}"
}

encrypt () { gpg -ac --no-options "$1"; }
decrypt () { gpg --no-options "$1"; }

