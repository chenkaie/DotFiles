" description:	a simple line-based commenting toggler
"  maintainer:	kamil.stachowski@gmail.com
"     license:	gpl 3+
"     version:	0.1 (2008.11.08)

" changelog:
"	0.1:	2008.11.08
"		initial version
"		TODO: do sth about block comments



" ===============================================================================================================================

" make sure the plugin hasn't been loaded yet and save something
if exists("g:loaded_commentToggle") || &cp
	finish
endif
let g:loaded_commentToggle = "v0.1"
let s:cpoSave = &cpo
set cpo&vim

" -------------------------------------------------------------------------------------------------------------------------------

" assign a shortcut
if !hasmapto('<Plug>CommentToggle')
	map <unique> <Leader>; <Plug>CommentToggle
endif
noremap <silent> <unique> <script> <Plug>CommentToggle :call <SID>CommentToggle()<CR>
noremenu <script> Plugin.Add\ CommentToggle <SID>CommentToggle

" and a command just in case
if !exists(":commentToggle")
	command -nargs=1 CommentToggle :call s:CommentToggle()
endif

" ===============================================================================================================================

" all languages are defined as a list with the comment opening string in position 0 and the closing string in position 1
" languages which support single line comments simply have an empty string in position 1
let s:commStrings = {"abap":['*',''], "ada":['--',''], "awk":['#',''], "basic":['rem',''], "bcpl":['//',''], "cecil":['--',''], "cpp":['//',''], "cs":['//',''], "dylan":['//',''], "e":['#',''], "eiffel":['--',''], "erlang":['%',''], "forth":['\',''], "fortan":['C ',''], "fs":['//',''], "icon":['#',''], "io":['#',''], "j":['NB.',''], "java":['//',''], "javascript":['//',''], "haskell":['--',''], "html":['<!--','-->'], "lisp":[';',''], "logo":[';',''], "lua":['--',''], "matlab":['%',''], "maple":['#',''], "merd":['#',''], "mma":['(*','*)'], "modula3":['(*','*)'], "mumps":[';',''], "ocaml":['(*','*)'], "oz":['%',''], "pascal":['{','}'], "perl":['#',''], "php":['//',''], "pike":['//',''], "pliant":['#',''], "postscr":['%',''], "prolog":['%',''], "python":['#',''], "rebol":[';',''], "ruby":['#',''], "sather":['--',''], "scheme":[';',''], "sh":['#',''], "simula":['--',''], "sql":['--',''], "st":['"','"'], "tcl":['#',''], "tex":['%',''], "vim":['"',''], "xml":['<!--','-->'], "yaml":['#',''], "ycp":['//',''], "yorick":['//','']}

" ===============================================================================================================================

" check if line aLineNr begins with string aCommStr
function! s:CommentCheckCommented(aLineNr, aCommStr)
	" check if the line begins with the comment opening string, ignoring whitespace
	return match(getline(a:aLineNr), '^\s*' . a:aCommStr[0]) == ""
endfunction

" -------------------------------------------------------------------------------------------------------------------------------

" find the comment string for syntax aSynCurr
function! s:CommentCheckString(aSynCurr)
	if has_key(s:commStrings, a:aSynCurr)
		" if we have the comment strings for the current syntax defined, take those
		return s:commStrings[a:aSynCurr]
	else
		" TODO:	doesn't work for all syntaxes
		"	i don't know how to properly extract the comment string for the current syntax; &comments is probably not the way
		" check &comments and extract the one without any flags; alas, it's not always the string we're looking for
		let s:result = ""
		for s:tmp in split(&comments, ",")
			if s:tmp[0] == ":"
				let s:result = s:tmp[1:-1]
				break
			endif
		endfor
		return [s:result, ""]
	endif
endfunction

" -------------------------------------------------------------------------------------------------------------------------------

" the main part
" 	finds the comment string for the current syntax, and if the current line is already commented
" 	if it is, it uncomments it; if it's not, it uncomments it
function! s:CommentToggle()
	let s:commStr = s:CommentCheckString(&syntax)
	let s:commed = s:CommentCheckCommented(line("."), s:commStr)
	call s:CommentToggleHelper(line("."), s:commStr, s:commed)
endfunction

" -------------------------------------------------------------------------------------------------------------------------------

" toggles comment on line aLineNr with string aCommStr depending on whether the line is already commented (aCommed)
function! s:CommentToggleHelper(aLineNr, aCommStr, aCommed)
	if a:aCommed
		let s:tmp = substitute(getline(a:aLineNr), '\s*$', "", "")	" remove white space from the beginning
		let s:tmp = substitute(s:tmp, a:aCommStr[0], "", "")		" remove the comment opening string
		let s:tmp = substitute(s:tmp, a:aCommStr[1] . '$', "", "")	" remove the comment closing string
		call setline(a:aLineNr, s:tmp)
	else
		" prepend and append the comment strings
		call setline(a:aLineNr, a:aCommStr[0] . getline(a:aLineNr) . a:aCommStr[1])
	endif
endfunction


" ===============================================================================================================================


let &cpo = s:cpoSave
unlet s:cpoSave
