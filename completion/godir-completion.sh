# file: godir.sh
# godir completion

_test_filenames()
{
	for f in "${COMPREPLY[@]}"; do
		if [ -n "`echo \"$f\" | grep /$`" ]; then
			return 1
		fi
	done 
	return 0
}

_godir()
{
	[ -z "$PRODUCTDIR" ] && return 0
	[ ! -f "$PRODUCTDIR/.filelist" ] && return 0

	local cur
	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	COMPREPLY=($(grep "/$cur[^/]*/\?$" "$PRODUCTDIR/.filelist" | perl -pe "s,.*?/$cur,$cur,"))

	_test_filenames
	if [ $? -eq 0 ]; then
		# If a file name is completed, let the completion trail a space
		compopt -o filenames
	else
		compopt -o nospace
	fi

	return 0
}

complete -F _godir godir gofile
