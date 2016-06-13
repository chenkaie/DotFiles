# .bashrc

# If not running interactively, don't do anything.
# This snippet helps to fix scp, sftp "Received message too long" issue..
[ -z "$PS1" ] && return

# Automatically attach tmux session if exist
tmux attach-session > /dev/null 2>&1

# Source global definitions
[ -f /etc/bashrc ] && . /etc/bashrc
[ -f /etc/profile ] && . /etc/profile

# Source extra local definitions, ~/.extra can be used for settings you don't want to commit
[ -r ~/.extra ] && . ~/.extra

DOTFILES="${DOTFILES:-$HOME/Repos/unix-env-deploy/DotFiles}"
TOOLS="${TOOLS:-$HOME/Repos/unix-env-deploy/Tools}"

infocmp screen-256color > /dev/null 2>&1
[ $? -eq 0 -a -n "$TMUX" ] && export TERM=screen-256color || export TERM=xterm-256color

export EDITOR=vim
export LC_ALL=en_US.UTF-8
export LANG=en_US

# helper function to check/detect beforehand
exist () { type "$1" &> /dev/null; }
support () { eval "$1" > /dev/null 2>&1; }

# Disable CTRL-S and CTRL-Q
[[ $- =~ i ]] && stty -ixoff -ixon

#######################
# JOB Related         #
#######################

#export MAKEINC=/home/project/makcomm
export LINTDIR=/usr/share/pclint
export MANSECT=8:2:1:3:4:5:6:7:9:0p:1p:3p:tcl:n:l:p:o

# GIT daily repo commit variable (A.K.A GIT Time Machine)
export GIT_MANAGED_DIRECTORY="$HOME/Project $HOME/ArmTools $HOME/Repos $HOME/practice $HOME/usr $HOME/makcomm-debug"

# Add new pkg search path by specifying below environment variable. (man pkg-config)
export PKG_CONFIG_PATH="$HOME/usr/lib/pkgconfig/"

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

		# Homebrew stuff
		if [ -x /usr/local/bin/brew ]; then
			export PATH=$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:/usr/local/sbin:$PATH
			export MANPATH=/usr/local/share/man:$MANPATH

			# bash_completion if installed
			if [ -f `brew --prefix`/etc/bash_completion ]; then
				. `brew --prefix`/etc/bash_completion
			fi

			# brew_bash_completion.sh
			if [ -f `brew --prefix`/Library/Contributions/brew_bash_completion.sh ]; then
				. `brew --prefix`/Library/Contributions/brew_bash_completion.sh
			fi
		fi

		# PATH
		export PATH=$TOOLS:$TOOLS/subversion-scripts:$TOOLS/git-scripts:$TOOLS/tmux-scripts:$HOME/usr/bin:$PATH
		# MANPATH
		export MANPATH=$HOME/usr/man:$HOME/usr/share/man:$MANPATH
		# PERL5LIB
		export PERL5LIB=$HOME/usr/lib/perl5/site_perl/5.10.1:$HOME/usr/lib/perl5/5.10.1:$PERL5LIB

		# Simple Ruby version management
		exist rbenv && eval "$(rbenv init -)"

		# cd into whatever is the forefront Finder window. (GH:paulirish/dotfiles)
		cdf() {  # short for cdfinder
			cd "`osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)'`"
		}
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

		# Linuxbrew
		if [ -x $HOME/.linuxbrew/bin/brew ]; then
			export PATH="$HOME/.linuxbrew/bin:$PATH"
			export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"
			export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"

			# brew_bash_completion.sh
			source $(brew --repository)/Library/Contributions/brew_bash_completion.sh
		fi

		# PATH
		export PATH=$HOME/hr:$HOME/perl5/bin:$TOOLS:$TOOLS/subversion-scripts:$TOOLS/git-scripts:$TOOLS/tmux-scripts:$HOME/usr/bin:$HOME/usr/sbin:$PATH
		# MANPATH
		export MANPATH=$HOME/usr/man:$HOME/usr/share/man:$HOME/usr/cpan/share/man:$MANPATH

		# PERL5
        [ -s "$HOME/.perlbrew/etc/bashrc" ] && source "$HOME/.perlbrew/etc/bashrc"
		export PERL_CPANM_OPT="-l ~/usr"
		export PERL5LIB=$HOME/usr/lib/perl5:$HOME/perl5/lib/perl5:$PERL5LIB

		# Python
		[ -s "$HOME/.pythonbrew/etc/bashrc" ] && source "$HOME/.pythonbrew/etc/bashrc"

		exist colorgcc && export CC="colorgcc"

		# UBNT
		#export UBNT_SECURITY=off
		export UBNT_MIDDLEWARE_LOCAL=on
		export DLDIR=$HOME/dl
		export UBNT_CACHE_DIR=$HOME/ubnt_cache_dir
		export PATH=/usr/lib/ccache:$PATH
		export CCACHE_DIR=$UBNT_CACHE_DIR/ccache
		ccache --max-size=10G -s > /dev/null 2>&1
		;;

	*)
		echo "Your OS Type is : `uname -s`"
		# openbsd doesn't do much for color, some others may..
		export CLICOLOR=1
		;;
esac

# golang
export GOPATH=$HOME/usr/gocode

#######################
# Alias               #
#######################

# enable color for `ls` by auto detection
if support "ls --color"; then
    # GNU
    alias ls='ls -FN --color=auto --time-style=long-iso'
else
    # OS X / BSD
    export CLICOLOR=1
    export LSCOLORS=ExFxCxDxBxegedabagacad
    alias ls='ls -FG'
fi

alias l='ls -FG'
alias ll='ls -al'                               # long list format
alias lk='ls -lk'                               # --block-size=1K
alias lt='ls -ltr'                              # sort by date (mtime)
alias lc='ls -ltcr'                             # sort by and show change time
alias la='ls -ltur'                             # sort by and show access time
alias lx='ls -lXB'                              # sort by extension
alias lz='ls -lSr'                              # sort by size
alias ld='ls -d */'                             # es only Dirs
alias l.='ls -dAFh .[^.]*'                      # ls only Dotfiles
alias lst='ls -hFtal | grep $(date +%Y-%m-%d)'  # ls Today
alias lsd='ls --group-directories-first'        # cool... but break the autocompletion when no "dirs" pattern matching, so not default it to ls

alias vim='vim -X -p'
alias vi='vim'
alias cp='cp -i -v'
alias mv='mv -i -v'
alias rm='rm -i -v'
alias df='df -kTH'
alias ln='ln -i -n'
alias psg='ps -ef | grep $1'
alias h='history | grep $1'
alias j='jobs'
alias less='less -R --tabs=4'                   # colorful 'less', tab stops = 4
alias more='less'
alias mkdir='mkdir -p -v'
alias reload='source ~/.bashrc'
alias wget='wget -c'
alias which='type -a'
alias quota='quota -vs'
alias grep='grep --color'
alias head='head -n $((${LINES:-12}-2))'        # As many as possible without scrolling
alias g='git'
alias netstat='netstat -np'
alias strings='strings -a'
alias dig="dig +nocmd any +multiline +noall +answer"
alias xmllint='xmllint --noout'

# more responsive -f
support "tail -s.1 /dev/null" && alias tail='tail -n $((${LINES:-12}-2)) -s.1'

# have to check exist()
exist htop && alias top='htop'

# `cat` with beautiful colors. (GH:paulirish/dotfiles)
alias c='pygmentize -O style=monokai -f console256 -g'
alias brew_update="brew -v update; brew -v upgrade --all; brew cleanup; brew cask cleanup; brew prune; brew doctor"

#export GREP_OPTIONS="--exclude-dir=\*/.svn/\* --exclude=\*~ --exclude=\*.swp"
#alias wcgrep='wcgrep -inh --colour=auto' has been defined in wcgrep
alias mdiff='diff -ruN --exclude=.svn'
alias diff='colordiff.pl'

# Moving around & all that jazz
#alias cd='pushd > /dev/null'
#alias back='popd > /dev/null'
alias b='cd -' # back to $OLDPWD
alias up='cd `realpath ..`'
alias cd..='cd ..'

alias path='echo -e ${PATH//:/\\n}'
alias perlpath='perl -le "print foreach @INC"'
# Generate Windows CIFS path prepend with Network Drive id: "Z:"
alias pwd-win='pwd | sed '"'"'s/\//\\/g'"'"' | sed '"'"'s/\(.*\)/Z:\1/'"'"''
alias pwd-mac='pwd | sed "s/^\/home/\/Volumes/"'
# A simple python http file server
alias hfs='python -m SimpleHTTPServer 8080'
#
alias python="PYTHONSTARTUP=$TOOLS/inpy python"

#Personal Help
alias l?='cat ~/.bashrc | grep "alias l.*=.ls" | grep ^a'
alias a?='alias'
alias f?='cat $DOTFILES/.function.help'
alias dn='OPTIONS=$(\ls -F | grep /$); select s in $OPTIONS; do cd $PWD/$s; break;done'
#alias help='OPTIONS=$(\ls $DOTFILES/.tips -F);select s in $OPTIONS; do less $DOTFILES/.tips/$s; break;done'

#delete
alias del='mv --target-directory=$HOME/.Trash/'

#aliases and export for Project
alias pcd='cd ${PRODUCTDIR}'
alias icd='cd ${IMAGEDIR}'
alias scd='cd ${PRODUCTDIR}/build/scripts'
alias rcd='cd ${PRODUCTDIR}/release;pwd'
alias mcd='cd ${MWDIR}'
alias pd='echo ${PRODUCTDIR}'
alias rmrd='[ -n "$PRODUCTDIR" ] && cd ${PRODUCTDIR}/release; rm -rf app_cluster_Build/ flashfs/ rootfs/; cd -'

#make for fun
#alias make='colormake'
alias m='make'
alias mc='m clean'
alias mca='m cleanall'
alias mi='m install'
alias mall='mca && m && mi'

#gcc
exist colorgcc && MY_GCC=colorgcc || MY_GCC=gcc
MY_CC_FLAGS='-Wall -Wextra -Wconversion -ggdb3 -fno-omit-frame-pointer -fno-inline -Wcast-align -Wpadded -Wpacked -std=gnu99'

alias agcc='arm-linux-gcc ${MY_CC_FLAGS}'
alias gcc='$MY_GCC ${MY_CC_FLAGS}'
alias objdump='objdump -d -S -l -shrt'
#alias gdb='gdb --command=$HOME/Repos/DotFiles/.gdbinit-7.3'
#alias strace='strace -f -v -x -s 128'

#Lint related
exist jsl  && alias jsl="jsl -conf $TOOLS/jsl.conf -process"
if exist lint ; then
	alias lint-gnu='lint ~/makcomm/env-vim.lnt'
	alias lint-gnu-xml='lint-gnu ~/makcomm/env-xml.lnt'
	alias lint-gnu-html='lint-gnu ~/makcomm/env-html.lnt'
	alias lint-arm='lint ~/makcomm/env-vim.lnt'
	alias lint-arm-xml='lint-arm ~/makcomm/env-xml.lnt'
	alias lint-arm-html='lint-arm ~/makcomm/env-html.lnt'
fi

# ccache & distcc
alias enjoy-ccache-distcc="source $TOOLS/use_distcc_ccache"

# enjoy proxy
alias enjoy-proxy="source $TOOLS/use_proxy"

#mkid
alias mkid='mkid -m $DOTFILES/id-lang.map'

# list serial console devices: Linux -> ttyUSB/ttyACM Darwin -> /dev/cu.usb*
alias lstty='while true; do ll /dev/tty[AU]* /dev/cu.usb* 2>/dev/null; echo; sleep 1; done'

# One of @janmoesen’s ProTip™s
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
    alias "$method"="lwp-request -m '$method'"
done

# View HTTP traffic
alias sniffHTTP="sudo ngrep -d 'eth0' -t '^(GET|POST) ' 'tcp and port 7080'"

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
#Use a vi-style command line editing interface, enter by <Esc> or <C-[>
#Note that some emacs mode "C-x" prefix key binding are gone. $ bind -p | grep "C-x"
set -o vi

#set -o xtrace          # Useful for debuging.
#set +o OOXX            # Turn off OOXX

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
	PROMPT_GIT='$(__git_ps1 "|'$BLDCYN'git'$TXTRST':%s")'
fi

# SVN shell prompt
# Ref: https://github.com/l0b0/tilde/blob/master/scripts/__svn_ps1.sh
__svn_ps1 ()
{
	svn info > /dev/null 2>&1 || return
	local result=$(
		svn info 2>/dev/null | \
		perl -ne 'print if s;^URL: .*?/((trunk)|(branches|tags)/([^/]*)).*;\2\4 ;')

	test -n "$result" || result="rev"
	local revision=$(svn info | grep Revision | awk '{print $2}')
	printf "${1:- (%s:%s)}" $result $revision
}

PROMPT_SVN='$(__svn_ps1 "|'$TXTCYN'svn'$TXTRST':%s-r%s")'

ps1_set()
{
	local prompt_char="$" separator="\n" prompt_time="" workding_dir="\w" prompt_verbose=$TXTYLW'\u@''\h'$TXTWHT':'

	# root privilege
	[ $UID -eq 0 ] && prompt_charclr=$TXTRED || prompt_charclr=$TXTWHT

	while [ $# -gt 0 ]; do
		local token="$1"; shift

		case "$token" in
		-x|--trace)
			[ "$1" == "off" ] && set +o xtrace || set -o xtrace
			shift
			;;
		-p|--prompt)
			prompt_char="$1"
			shift
			;;
		-s|--separator)
			separator="$1"
			shift
			;;
		-t|--time)
			prompt_time="$1"
			shift
			;;
		-w|--workingdir)
			workding_dir="$1"
			shift
			;;
		-v|--verbose)
			prompt_verbose="$1"
			shift
			;;
		*)
			true # Ignore everything else.
			;;
		esac
	done
	PS1=$BLDBLK'['${prompt_time}${prompt_verbose}$TXTWHT'pts/\l'$TXTWHT${PROMPT_GIT}${PROMPT_SVN}$BLDBLK'$(ps1_counter)''] '$BLDWHT${workding_dir}${separator}${prompt_charclr}${prompt_char}$TXTWHT
}

#PS1=$TXTYLW'\u'$TXTWHT'@'${PROMPT_HOSTCOLOR}'\h'$TXTWHT':'$TXTGRN'\W'$TXTWHT${PROMPT_GIT}${PROMPT_SVN}$BLDBLK'$(ps1_counter)'$TXTGRN' >'$BLDGRN'>'$BLDWHT'> '$TXTWHT

ps1_set_ox()
{
	[ "$1" = "X" ] && TXT_EXIT=$BLDRED || TXT_EXIT=$BLDWHT
	case $OS in
		Darwin|*BSD)
			[ -n "$TMUX" ] && ps1_set -p "$TXTGRN>$BLDGRN>$TXT_EXIT>$TXTWHT " -v "" \
						   || ps1_set -p "$TXTGRN>$BLDGRN>$TXT_EXIT>$TXTWHT " -t "\D{%H:%M:%S} "
			;;
		Linux)
			[ -n "$TMUX" ] && ps1_set -p "$TXTGRN>$BLDGRN>$TXT_EXIT>$TXTWHT " -v "" \
						   || ps1_set -p "$TXTGRN>$BLDGRN>$TXT_EXIT>$TXTWHT " -s " " -w "\W"
			#ps1_set -p "$TXTGRNʕ•ᴥ•ʔ " -s " " -w "\W"
			;;
	esac
}

ps1_chk_exitcode()
{
	[ $? -eq 0 ] && ps1_set_ox "O" || ps1_set_ox "X"
}

ps1_set_ox

# When debugging a shell script via `set -x` this tricked-out prompt is used.
export PS4='+ \011\e[1;30m\t\011\e[1;34m${BASH_SOURCE}\e[0m:\e[1;36m${LINENO}\e[0m \011 ${FUNCNAME[0]:+\e[0;35m${FUNCNAME[0]}\e[1;30m()\e[0m:\011\011 }'

# add for screen to dynamically update title
#PROMPT_COMMAND='echo -n -e "\033k\033\134"'

# enable commands in one terminal to be instantly be available in another
#export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

export PROMPT_COMMAND="ps1_chk_exitcode; history -a; $PROMPT_COMMAND"

#export MANPAGER="most -s"
# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[01;44;33m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

#for X-Win32
#export DISPLAY="172.16.2.54:0:0"

# cool CMatrix
# exist cmatrix && cmatrix -ab

# funny stuff cowsay
# exist cowsay && echo "Welcome to $HOSTNAME" | cowsay -f default

# icat (Image cat) generated 256-color ascii images
if [ -d "$DOTFILES/ascii-photo" ]; then
	filepath=($DOTFILES/ascii-photo/*)
	nfile=${#filepath[@]}
	asciiwp="${filepath[RANDOM % nfile]}"
	cat $asciiwp
fi

# Completion support
[ -z "$BASH_COMPLETION_COMPAT_DIR" ] && source $DOTFILES/completion/bash-completion/bash_completion
source $DOTFILES/completion/svn_completion
source $DOTFILES/completion/git-completion.bash
source $DOTFILES/completion/git-prompt.sh
source $DOTFILES/completion/cdargs-bash.sh
source $DOTFILES/completion/cdots.sh
source $DOTFILES/completion/git-flow-completion.bash
source $DOTFILES/completion/acd_func.sh
source $DOTFILES/completion/hub.bash_completion.sh
source $DOTFILES/completion/bash_completion_tmux.sh
source $DOTFILES/completion/godir-completion.sh
source $DOTFILES/completion/repo.bash_completion
# aws cli completion
complete -C aws_completer aws

# make less more friendly for non-text input files, see lesspipe(1)
exist lesspipe && eval "$(lesspipe)"

#export LESS='-i -N -w  -z-4 -g -e -M -X -F -R -P%t?f%f :stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'
export LESS='-FRXM --tabs=4 -i'

#######################
# Developer stuff     #
#######################

# Enable gcc colours, available since gcc 4.8.0
export GCC_COLORS=1

# print the corresponding error message
strerror() { python -c "import os,locale as l; l.setlocale(l.LC_ALL, ''); print os.strerror($1)"; }

#######################
# Terminal info       #
#######################
# Related CMD: tput, resize, reset, stty -a
COLUMNS=$(tput cols)
LINES=$(tput lines)

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
		*.tar.xz)    tar xvJf $1    ;;
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
	echo -e "\n${RED}Public IP Address :$NC" ; myip
	echo -e "\n${RED}Local IP Address :$NC" ; ips
}

# get public IP
function myip ()
{
	echo "$(dig +short myip.opendns.com @resolver1.opendns.com)"
}

# get all IPs
function ips ()
{
	case $OS in
	Darwin|*BSD)
		local ip=$(ifconfig  | grep -E 'inet.[0-9]' | grep -v '127.0.0.1' | awk '{ print $2}')
		;;
	Linux)
		local ip=$(ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
		;;
	esac

	echo "${ip}"
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
	# replace "builtin cd" with cd_func() to enable "cd with history"
	if [ -n "$1" ]; then
		# builtin cd "$@"&& ls
		cd_func "$@" && [ "$1" != "--" ] && ls
	else
		# builtin cd ~&& ls
		cd_func ~ && ls
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

# Find with pattern $1 in name
function fnd()
{ wcfind . -iname '*'${1:-}'*' ; }

# lazy gcc, default outfile: filename_prefix.out, eg: hello.c -> hello.out
function lgcc ()
{
	gcc -o ${1%.*}{.out,.${1##*.}} $2 $3 $4 $5
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
		*dm8127*)
			outfilesuffix="dm385"
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
	agcc -o ${1%.*}{.${outfilesuffix}.out,.${1##*.}} $2 $3 $4 $5
}

function ps1_counter()
{
	case $1 in *-h*) echo "(jobnum|dirnum)" ;; esac

	jobnum="$(jobs | wc -l | tr -d " ")"
	dirnum="$(dirs -v | tail -n 1 | awk '{print $1}')"

	if [ `expr $jobnum + $dirnum` -gt 0 ]; then
		echo -n " (${jobnum}/${dirnum})"
	fi
}

complete -c command see
function see()
{
	$EDITOR `\which $1`
}

# Returns the ASCII value of the first character of a string
ord() { printf "0x%x\n" "'$1"; }

# Returns a character from a specified ASCII value
chr() { printf $(printf '\\%03o\\n' "$1"); }

export GODIR_IGNORE=".*~$\|\./\..*\|.*/\(.git\|.hg\|.svn\|openwrt-gen.*\|builders\)\(/\|$\)"
# Steal from AOSP
function godir ()
{
	if [[ -z "$PRODUCTDIR" ]]; then
		echo "Please source a devel file"
		return
	fi
	if [[ -z "$1" ]]; then
		echo "Usage: godir <regex> [e]"
		echo "       e: edit one/all matched file"
		return
	fi
	if [[ ! -f $PRODUCTDIR/.filelist ]]; then
		echo -n "Creating index..."
		(\cd $PRODUCTDIR; find -P . -regex $GODIR_IGNORE -prune -o -type f -print -o -type d -printf "%p/\n" > .filelist)
		echo " Done"
		echo ""
	fi
	local lines
	[[ "$2" != "e" ]] && lines=($(\grep "$1" $PRODUCTDIR/.filelist | sed -e 's/\/[^/]*$//' | sort | uniq)) || lines=($(\grep -F "$1" $PRODUCTDIR/.filelist | sort | uniq))
	if [[ ${#lines[@]} = 0 ]]; then
		echo "Not found"
		return
	fi
	local pathname
	local choice
	if [[ ${#lines[@]} > 1 ]]; then
		while [[ -z "$pathname" ]]; do
			local index=1
			local line
			local pathnames
			for line in ${lines[@]}; do
				printf "%6s %s\n" "[$index]" $line
				index=$(($index + 1))
				pathnames="${pathnames} $line"
			done
			echo
			[[ "$2" != "e" ]] && echo -n "Select one: " || echo -n "Select one ([a] -> all): "
			unset choice
			read choice
			if [[ "$2" = "e" && $choice = "a" ]]; then
				pathname=${pathnames}
			elif [[ $choice -gt ${#lines[@]} || $choice -lt 1 ]]; then
				echo "Invalid choice"
				continue
			else
				pathname=${lines[$(($choice-1))]}
			fi
		done
	else
		pathname=${lines[0]}
	fi

	[[ "$2" != "e" ]] && \cd $PRODUCTDIR/$pathname || (cd $PRODUCTDIR; $EDITOR -p $pathname)
}

function gofile () { godir "$1" e; }

# Trick a process to think it's stdout is tty(terminal) ALWAYS to avoid buffering issue
function faketty { script -qfc "$(printf "'%s' " "$@")"; }

# Display ANSI colours. Found this on the interwebs, credited
# to "HH".
function ansicolors() {
	esc="\033["
	echo -e "\t  40\t   41\t   42\t    43\t      44       45\t46\t 47"
	for fore in 30 31 32 33 34 35 36 37; do
		line1="$fore  "
		line2="    "
		for back in 40 41 42 43 44 45 46 47; do
			line1="${line1}${esc}${back};${fore}m Normal  ${esc}0m"
			line2="${line2}${esc}${back};${fore};1m Bold    ${esc}0m"
		done
		echo -e "$line1\n$line2"
	done

	echo ""
	echo "# Example:"
	echo "#"
	echo "# Type a Blinkin TJEENARE in Swedens colours (Yellow on Blue)"
	echo "#"
	echo "#           ESC"
	echo "#            |  CD"
	echo "#            |  | CD2"
	echo "#            |  | | FG"
	echo "#            |  | | |  BG + m"
	echo "#            |  | | |  |         END-CD"
	echo "#            |  | | |  |            |"
	echo "# echo -e '\033[1;5;33;44mTJEENARE\033[0m'"
	echo "#"
	echo "# Sedika Signing off for now ;->"
}

# Copy w/ progress (by paulirish)
cp_p () {
	rsync -WavP --human-readable --progress $1 $2
}

# Start an HTTP server from a directory, optionally specifying the port (by paulirish)
function server () {
	local port="${1:-8000}"
	exist open && open "http://localhost:${port}/"
	# Set the default Content-Type to `text/plain` instead of `application/octet-stream`
	# And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
	python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

# whois a domain or a URL (by paulirish)
function whois () {
	local domain=$(echo "$1" | awk -F/ '{print $3}') # get domain from URL
	if [ -z $domain ] ; then
		domain=$1
	fi
	echo "Getting whois record for: $domain …"

	# avoid recursion
                    # this is the best whois server
                                                   # strip extra fluff
    /usr/bin/whois -h whois.internic.net $domain | sed '/NOTICE:/q'
}

# param 1: file
# param 2: offset (decimal)
# param 3: value  (decimal)
function replaceByte() {
	printf "$(printf '\\x%02X' $3)" | dd of="$1" bs=1 seek=$2 count=1 conv=notrunc
}

# Automatically add completion for all aliases to commands having completion functions
function alias_completion {
    local namespace="alias_completion"

    # parse function based completion definitions, where capture group 2 => function and 3 => trigger
    local compl_regex='complete( +[^ ]+)* -F ([^ ]+) ("[^"]+"|[^ ]+)'
    # parse alias definitions, where capture group 1 => trigger, 2 => command, 3 => command arguments
    local alias_regex="alias ([^=]+)='(\"[^\"]+\"|[^ ]+)(( +[^ ]+)*)'"

    # create array of function completion triggers, keeping multi-word triggers together
    eval "local completions=($(complete -p | sed -Ene "/$compl_regex/s//'\3'/p"))"
    (( ${#completions[@]} == 0 )) && return 0

    # create temporary file for wrapper functions and completions
    rm -f "/tmp/${namespace}-*.tmp" # preliminary cleanup
    local tmp_file; tmp_file="$(mktemp "/tmp/${namespace}-${RANDOM}XXX.tmp")" || return 1

    # read in "<alias> '<aliased command>' '<command args>'" lines from defined aliases
    local line; while read line; do
        eval "local alias_tokens; alias_tokens=($line)" 2>/dev/null || continue # some alias arg patterns cause an eval parse error
        local alias_name="${alias_tokens[0]}" alias_cmd="${alias_tokens[1]}" alias_args="${alias_tokens[2]# }"

        # skip aliases to pipes, boolan control structures and other command lists
        # (leveraging that eval errs out if $alias_args contains unquoted shell metacharacters)
        eval "local alias_arg_words; alias_arg_words=($alias_args)" 2>/dev/null || continue

        # skip alias if there is no completion function triggered by the aliased command
        [[ " ${completions[*]} " =~ " $alias_cmd " ]] || continue
        local new_completion="$(complete -p "$alias_cmd")"

        # create a wrapper inserting the alias arguments if any
        if [[ -n $alias_args ]]; then
            local compl_func="${new_completion/#* -F /}"; compl_func="${compl_func%% *}"
            # avoid recursive call loops by ignoring our own functions
            if [[ "${compl_func#_$namespace::}" == $compl_func ]]; then
                local compl_wrapper="_${namespace}::${alias_name}"
                    echo "function $compl_wrapper {
                        (( COMP_CWORD += ${#alias_arg_words[@]} ))
                        COMP_WORDS=($alias_cmd $alias_args \${COMP_WORDS[@]:1})
                        (( COMP_POINT -= \${#COMP_LINE} ))
                        COMP_LINE=\${COMP_LINE/$alias_name/$alias_cmd $alias_args}
                        (( COMP_POINT += \${#COMP_LINE} ))
                        $compl_func
                    }" >> "$tmp_file"
                    new_completion="${new_completion/ -F $compl_func / -F $compl_wrapper }"
            fi
        fi

        # replace completion trigger by alias
        new_completion="${new_completion% *} $alias_name"
        echo "$new_completion" >> "$tmp_file"
    done < <(alias -p | sed -Ene "s/$alias_regex/\1 '\2' '\3'/p")
    source "$tmp_file" && rm -f "$tmp_file"
}; alias_completion

#######################
# EXIT                #
#######################

# Function to run upon exit of shell.
function _exit() {
	echo "Logged out actively at `date`"
}

# run function on logout
trap _exit EXIT

# vim: fdm=marker ts=4 sw=4:

