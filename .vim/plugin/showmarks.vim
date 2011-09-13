" ==============================================================================
" Name:          ShowMarks
" Description:   Visually displays the location of marks.
" Authors:       Anthony Kruize <trandor@labyrinth.net.au>
"                Michael Geddes <michaelrgeddes@optushome.com.au>
" Version:       2.2
" Modified:      17 August 2004
" License:       Released into the public domain.
" ChangeLog:     See :help showmarks-changelog
"
" Usage:         Copy this file into the plugins directory so it will be
"                automatically sourced.
"
"                Default keymappings are:
"                  <Leader>mt  - Toggles ShowMarks on and off.
"                  <Leader>mo  - Turns ShowMarks on, and displays marks.
"                  <Leader>mh  - Clears a mark.
"                  <Leader>ma  - Clears all marks.
"                  <Leader>mm  - Places the next available mark.
" ==============================================================================

" Check if we should continue loading
if exists( "loaded_showmarks" )
	finish
endif
let loaded_showmarks = 1

" Bail if Vim isn't compiled with signs support.
if v:version < 700
	echoerr "ShowMarks requires Vim version > 7.0."
	finish
elseif has( "signs" ) == 0
	echoerr "ShowMarks requires Vim to have +signs support."
	finish
endif

" Options: Set up some nice defaults
if !exists('g:showmarks_enable'      ) | let g:showmarks_enable       = 1    | endif
if !exists('g:showmarks_auto_toggle' ) | let g:showmarks_auto_toggle  = 0    | endif
if !exists('g:showmarks_no_mappings' ) | let g:showmarks_no_mappings  = 0    | endif
if !exists('g:showmarks_textlower'   ) | let g:showmarks_textlower    = ">"  | endif
if !exists('g:showmarks_textupper'   ) | let g:showmarks_textupper    = ">"  | endif
if !exists('g:showmarks_textother'   ) | let g:showmarks_textother    = ">"  | endif
if !exists('g:showmarks_ignore_type' ) | let g:showmarks_ignore_type  = "hq" | endif
if !exists('g:showmarks_hlline_lower') | let g:showmarks_hlline_lower = "0"  | endif
if !exists('g:showmarks_hlline_upper') | let g:showmarks_hlline_upper = "0"  | endif
if !exists('g:showmarks_hlline_other') | let g:showmarks_hlline_other = "0"  | endif

" This is the default, and used in ShowMarksSetup to set up info for any
" possible mark (not just those specified in the possibly user-supplied list
" of marks to show -- it can be changed on-the-fly).
let s:all_marks = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.'`^<>[]{}()\""

" Commands
com! -nargs=0 ShowMarksToggle    :call <sid>ShowMarksToggle()
com! -nargs=0 ShowMarksOn        :call <sid>ShowMarksOn()
com! -nargs=0 ShowMarksClearMark :call <sid>ShowMarksClearMark()
com! -nargs=0 ShowMarksClearAll  :call <sid>ShowMarksClearAll()
com! -nargs=0 ShowMarksPlaceMark :call <sid>ShowMarksPlaceMark()

" Mappings
nnoremap <silent> <Plug>ShowMarksToggle    :<C-U>call <SID>ShowMarksToggle()<CR>
nnoremap <silent> <Plug>ShowMarksOn        :<C-U>call <SID>ShowMarksOn()<CR>
nnoremap <silent> <Plug>ShowMarksClearMark :<C-U>call <SID>ShowMarksClearMark()<CR>
nnoremap <silent> <Plug>ShowMarksClearAll  :<C-U>call <SID>ShowMarksClearAll()<CR>
nnoremap <silent> <Plug>ShowMarksPlaceMark :<C-U>call <SID>ShowMarksPlaceMark()<CR>

if ! g:showmarks_no_mappings
	silent! nmap <silent> <unique> <leader>mt <Plug>ShowMarksToggle
	silent! nmap <silent> <unique> <leader>mo <Plug>ShowMarksOn
	silent! nmap <silent> <unique> <leader>mh <Plug>ShowMarksClearMark
	silent! nmap <silent> <unique> <leader>ma <Plug>ShowMarksClearAll
	silent! nmap <silent> <unique> <leader>mm <Plug>ShowMarksPlaceMark
endif
nnoremap <silent> <script> <unique> m :call <SID>ShowMarksHooksMark()<CR>

" AutoCommands: Only if ShowMarks is enabled
if g:showmarks_enable == 1 && g:showmarks_auto_toggle
	aug ShowMarks
		au!
		autocmd CursorHold * call s:ShowMarks()
	aug END
endif

" Highlighting: Setup some nice colours to show the mark positions.
hi default ShowMarksHLl ctermfg=darkblue ctermbg=blue cterm=bold guifg=blue guibg=lightblue gui=bold
hi default ShowMarksHLu ctermfg=darkblue ctermbg=blue cterm=bold guifg=blue guibg=lightblue gui=bold
hi default ShowMarksHLo ctermfg=darkblue ctermbg=blue cterm=bold guifg=blue guibg=lightblue gui=bold
hi default ShowMarksHLm ctermfg=darkblue ctermbg=blue cterm=bold guifg=blue guibg=lightblue gui=bold

" Function: IncludeMarks()
" Description: This function returns the list of marks (in priority order) to
" show in this buffer.  Each buffer, if not already set, inherits the global
" setting; if the global include marks have not been set; that is set to the
" default value.
fun! s:IncludeMarks()
	if exists('b:showmarks_include') && exists('b:showmarks_previous_include') && b:showmarks_include != b:showmarks_previous_include
		" The user changed the marks to include; hide all marks; change the
		" included mark list, then show all marks.  Prevent infinite
		" recursion during this switch.
		if exists('s:use_previous_include')
			" Recursive call from ShowMarksHideAll()
			return b:showmarks_previous_include
		elseif exists('s:use_new_include')
			" Recursive call from ShowMarks()
			return b:showmarks_include
		else
			let s:use_previous_include = 1
			call <sid>ShowMarksHideAll()
			unlet s:use_previous_include
			let s:use_new_include = 1
			call <sid>ShowMarks()
			unlet s:use_new_include
		endif
	endif

	if !exists('g:showmarks_include')
		let g:showmarks_include = s:all_marks
	endif
	if !exists('b:showmarks_include')
		let b:showmarks_include = g:showmarks_include
	endif

	" Save this include setting so we can detect if it was changed.
	let b:showmarks_previous_include = b:showmarks_include

	return b:showmarks_include
endf

" Function: NameOfMark()
" Paramaters: mark - Specifies the mark to find the name of.
" Description: Convert marks that cannot be used as part of a variable name to
" something that can be. i.e. We cannot use [ as a variable-name suffix (as
" in 'placed_['; this function will return something like 63, so the variable
" will be something like 'placed_63').
" 10 is added to the mark's index to avoid colliding with the numeric marks
" 0-9 (since a non-word mark could be listed in showmarks_include in the
" first 10 characters if the user overrides the default).
" Returns: The name of the requested mark.
fun! s:NameOfMark(mark)
	let name = a:mark
	if a:mark =~# '\W'
		let name = stridx(s:all_marks, a:mark) + 10
	endif
	return name
endf

" Function: LineNumberOf()
" Paramaters: mark - mark (e.g.: t) to find the line of.
" Description: Find line number of specified mark in current buffer.
" Returns: Line number.
fun! s:LineNumberOf(mark)
	let pos = getpos("'" . a:mark)
	if pos[0] && pos[0] != bufnr("%")
		return 0
	else
		return pos[1]
	endif
endf

" Function: VerifyText()
" Paramaters: which - Specifies the variable to verify.
" Description: Verify the validity of a showmarks_text{upper,lower,other} setup variable.
" Default to ">" if it is found to be invalid.
fun! s:VerifyText(which)
	if strlen(g:showmarks_text{a:which}) == 0 || strlen(g:showmarks_text{a:which}) > 2
		echohl ErrorMsg
		echo "ShowMarks: text".a:which." must contain only 1 or 2 characters."
		echohl None
		let g:showmarks_text{a:which}=">"
	endif
endf

" Function: ShowMarksSetup()
" Description: This function sets up the sign definitions for each mark.
" It uses the showmarks_textlower, showmarks_textupper and showmarks_textother
" variables to determine how to draw the mark.
fun! s:ShowMarksSetup()
	" Make sure the textlower, textupper, and textother options are valid.
	call s:VerifyText('lower')
	call s:VerifyText('upper')
	call s:VerifyText('other')

	let n = 0
	let s:maxmarks = strlen(s:all_marks)
	while n < s:maxmarks
		let c = strpart(s:all_marks, n, 1)
		let nm = s:NameOfMark(c)
		let text = '>'.c
		let lhltext = ''
		if c =~# '[a-z]'
			if strlen(g:showmarks_textlower) == 1
				let text=c.g:showmarks_textlower
			elseif strlen(g:showmarks_textlower) == 2
				let t1 = strpart(g:showmarks_textlower,0,1)
				let t2 = strpart(g:showmarks_textlower,1,1)
				if t1 == "\t"
					let text=c.t2
				elseif t2 == "\t"
					let text=t1.c
				else
					let text=g:showmarks_textlower
				endif
			endif
			let s:ShowMarksDLink{nm} = 'ShowMarksHLl'
			if g:showmarks_hlline_lower == 1
				let lhltext = 'linehl='.s:ShowMarksDLink{nm}.nm
			endif
		elseif c =~# '[A-Z]'
			if strlen(g:showmarks_textupper) == 1
				let text=c.g:showmarks_textupper
			elseif strlen(g:showmarks_textupper) == 2
				let t1 = strpart(g:showmarks_textupper,0,1)
				let t2 = strpart(g:showmarks_textupper,1,1)
				if t1 == "\t"
					let text=c.t2
				elseif t2 == "\t"
					let text=t1.c
				else
					let text=g:showmarks_textupper
				endif
			endif
			let s:ShowMarksDLink{nm} = 'ShowMarksHLu'
			if g:showmarks_hlline_upper == 1
				let lhltext = 'linehl='.s:ShowMarksDLink{nm}.nm
			endif
		else " Other signs, like ', ., etc.
			if strlen(g:showmarks_textother) == 1
				let text=c.g:showmarks_textother
			elseif strlen(g:showmarks_textother) == 2
				let t1 = strpart(g:showmarks_textother,0,1)
				let t2 = strpart(g:showmarks_textother,1,1)
				if t1 == "\t"
					let text=c.t2
				elseif t2 == "\t"
					let text=t1.c
				else
					let text=g:showmarks_textother
				endif
			endif
			let s:ShowMarksDLink{nm} = 'ShowMarksHLo'
			if g:showmarks_hlline_other == 1
				let lhltext = 'linehl='.s:ShowMarksDLink{nm}.nm
			endif
		endif

		" Define the sign with a unique highlight which will be linked when placed.
		exe 'sign define ShowMark'.nm.' '.lhltext.' text='.text.' texthl='.s:ShowMarksDLink{nm}.nm
		let b:ShowMarksLink{nm} = ''
		let n = n + 1
	endw
endf

" Set things up
call s:ShowMarksSetup()

" Function: ShowMarksOn
" Description: Enable showmarks, and show them now.
fun! s:ShowMarksOn()
	if g:showmarks_enable == 0
		call <sid>ShowMarksToggle()
	else
		call <sid>ShowMarks()
	endif
endf

" Function: ShowMarksToggle()
" Description: This function toggles whether marks are displayed or not.
fun! s:ShowMarksToggle()
	if ! exists('b:showmarks_shown')
		let b:showmarks_shown = 0
	endif

	if b:showmarks_shown == 0
		let g:showmarks_enable = 1
		call <sid>ShowMarks()
		if g:showmarks_auto_toggle
			aug ShowMarks
				au!
				autocmd CursorHold * call s:ShowMarks()
			aug END
		endif
	else
		let g:showmarks_enable = 0
		call <sid>ShowMarksHideAll()
		if g:showmarks_auto_toggle
			aug ShowMarks
				au!
				autocmd BufEnter * call s:ShowMarksHideAll()
			aug END
		endif
	endif
endf

" Function: ShowMarks()
" Description: This function runs through all the marks and displays or
" removes signs as appropriate. It is called on the CursorHold autocommand.
" We use the marked_{ln} variables (containing a timestamp) to track what marks
" we've shown (placed) in this call to ShowMarks; to only actually place the
" first mark on any particular line -- this forces only the first mark
" (according to the order of showmarks_include) to be shown (i.e., letters
" take precedence over marks like paragraph and sentence.)
fun! s:ShowMarks()
	if g:showmarks_enable == 0
		return
	endif

	if   ((match(g:showmarks_ignore_type, "[Hh]") > -1) && (&buftype    == "help"    ))
	\ || ((match(g:showmarks_ignore_type, "[Qq]") > -1) && (&buftype    == "quickfix"))
	\ || ((match(g:showmarks_ignore_type, "[Pp]") > -1) && (&pvw        == 1         ))
	\ || ((match(g:showmarks_ignore_type, "[Rr]") > -1) && (&readonly   == 1         ))
	\ || ((match(g:showmarks_ignore_type, "[Mm]") > -1) && (&modifiable == 0         ))
		return
	endif

	let n = 0
	let s:maxmarks = strlen(s:IncludeMarks())
	while n < s:maxmarks
		let c = strpart(s:IncludeMarks(), n, 1)
		let nm = s:NameOfMark(c)
		let id = n + (s:maxmarks * winbufnr(0))
		let ln = s:LineNumberOf(c)

		if ln == 0 && (exists('b:placed_'.nm) && b:placed_{nm} != ln)
			exe 'sign unplace '.id.' buffer='.winbufnr(0)
		elseif ln > 1 || c !~ '[a-zA-Z]'
			" Have we already placed a mark here in this call to ShowMarks?
			if exists('mark_at'.ln)
				" Already placed a mark, set the highlight to multiple
				if c =~# '[a-zA-Z]' && b:ShowMarksLink{mark_at{ln}} != 'ShowMarksHLm'
					let b:ShowMarksLink{mark_at{ln}} = 'ShowMarksHLm'
					exe 'hi link '.s:ShowMarksDLink{mark_at{ln}}.mark_at{ln}.' '.b:ShowMarksLink{mark_at{ln}}
				endif
			else
				if !exists('b:ShowMarksLink'.nm) || b:ShowMarksLink{nm} != s:ShowMarksDLink{nm}
					let b:ShowMarksLink{nm} = s:ShowMarksDLink{nm}
					exe 'hi link '.s:ShowMarksDLink{nm}.nm.' '.b:ShowMarksLink{nm}
				endif
				let mark_at{ln} = nm
				if !exists('b:placed_'.nm) || b:placed_{nm} != ln
					exe 'sign unplace '.id.' buffer='.winbufnr(0)
					exe 'sign place '.id.' name=ShowMark'.nm.' line='.ln.' buffer='.winbufnr(0)
					let b:placed_{nm} = ln
				endif
			endif
		endif
		let n = n + 1
	endw
	let b:showmarks_shown = 1
endf

" Function: ShowMarksClearMark()
" Description: This function hides the mark at the current line.
" Only marks a-z and A-Z are supported.
fun! s:ShowMarksClearMark()
	let ln = line(".")
	let n = 0
	let s:maxmarks = strlen(s:IncludeMarks())
	while n < s:maxmarks
		let c = strpart(s:IncludeMarks(), n, 1)
		if c =~# '[a-zA-Z]' && ln == s:LineNumberOf(c)
			let nm = s:NameOfMark(c)
			let id = n + (s:maxmarks * winbufnr(0))
			exe 'sign unplace '.id.' buffer='.winbufnr(0)
			execute "delmarks " . c
			let b:placed_{nm} = 1
		endif
		let n = n + 1
	endw
endf

" Function: ShowMarksClearAll()
" Description: This function clears all marks in the buffer.
" Only marks a-z and A-Z are supported.
fun! s:ShowMarksClearAll()
	let n = 0
	let s:maxmarks = strlen(s:IncludeMarks())
	while n < s:maxmarks
		let c = strpart(s:IncludeMarks(), n, 1)
		if c =~# '[a-zA-Z]'
			let nm = s:NameOfMark(c)
			let id = n + (s:maxmarks * winbufnr(0))
			exe 'sign unplace '.id.' buffer='.winbufnr(0)
			execute "delmarks " . c
			let b:placed_{nm} = 1
		endif
		let n = n + 1
	endw
	let b:showmarks_shown = 0
endf

" Function: ShowMarksHideAll()
" Description: This function hides all marks in the buffer.
" It simply removes the signs.
fun! s:ShowMarksHideAll()
	let n = 0
	let s:maxmarks = strlen(s:IncludeMarks())
	while n < s:maxmarks
		let c = strpart(s:IncludeMarks(), n, 1)
		let nm = s:NameOfMark(c)
		if exists('b:placed_'.nm)
			let id = n + (s:maxmarks * winbufnr(0))
			exe 'sign unplace '.id.' buffer='.winbufnr(0)
			unlet b:placed_{nm}
		endif
		let n = n + 1
	endw
	let b:showmarks_shown = 0
endf

" Function: ShowMarksPlaceMark()
" Description: This function will place the next unplaced mark (in priority
" order) to the current location. The idea here is to automate the placement
" of marks so the user doesn't have to remember which marks are placed or not.
" Hidden marks are considered to be unplaced.
" Only marks a-z are supported.
fun! s:ShowMarksPlaceMark()
	" Find the first, next, and last [a-z] mark in showmarks_include (i.e.
	" priority order), so we know where to "wrap".
	let first_alpha_mark = -1
	let last_alpha_mark  = -1
	let next_mark        = -1

	if !exists('b:previous_auto_mark')
		let b:previous_auto_mark = -1
	endif

	" Find the next unused [a-z] mark (in priority order); if they're all
	" used, find the next one after the previously auto-assigned mark.
	let n = 0
	let s:maxmarks = strlen(s:IncludeMarks())
	while n < s:maxmarks
		let c = strpart(s:IncludeMarks(), n, 1)
		if c =~# '[a-z]'
			if s:LineNumberOf(c) <= 1
				" Found an unused [a-z] mark; we're done.
				let next_mark = n
				break
			endif

			if first_alpha_mark < 0
				let first_alpha_mark = n
			endif
			let last_alpha_mark = n
			if n > b:previous_auto_mark && next_mark == -1
				let next_mark = n
			endif
		endif
		let n = n + 1
	endw

	if next_mark == -1 && (b:previous_auto_mark == -1 || b:previous_auto_mark == last_alpha_mark)
		" Didn't find an unused mark, and haven't placed any auto-chosen marks yet,
		" or the previously placed auto-chosen mark was the last alpha mark --
		" use the first alpha mark this time.
		let next_mark = first_alpha_mark
	endif

	if (next_mark == -1)
		echohl WarningMsg
		echo 'No marks in [a-z] included! (No "next mark" to choose from)'
		echohl None
		return
	endif

	let c = strpart(s:IncludeMarks(), next_mark, 1)
	let b:previous_auto_mark = next_mark
	exe 'mark '.c
	call <sid>ShowMarks()
endf

" Function: ShowMarksHooksMark()
" Description: Hooks normal m command for calling ShowMarks() with it.
fun! s:ShowMarksHooksMark()
	execute 'normal! m' . nr2char(getchar())
	call <SID>ShowMarks()
endf

" -----------------------------------------------------------------------------
" vim:ts=4:sw=4:noet
