" Improved Vim plugin for showing matching parens
" Features:      Not limited to on-screen paren pairs; prints
"                line containing matching paren in status line
" Original Author:  Bram Moolenaar <Bram@vim.org>
" Maintainer:    Erik Falor <ewfalor@gmail.com>
" Last Change:   2008 Apr 10
" Version:       1.0.2
"
" Changes {{{
" 1.0.2 2008-04-10
"   DoMatchParen command re-loads this plugin instead of matchparen.vim.
"   Thanks to James Marshall for this idea.
"
" 1.0.1 2008-03-19
"   Catch exception when searchpairpos doesn't accept a timeout argument;
"   Use old flavor of searchpairpos() instead.
"
" 1.0 2008-03-17
"   Using timeout feature of searchpairpos() to avoid a long delay while
"   finding a matching paren.  Borrowed from Bram's patch #7.1.269.
"
" 0.1.99 2007-11-05
"   Using Bram's matchparen.vim plugin from standard distribution as starting point 
"   for this version.  
"
"   Print line containing matching brace with echo instead of echomsg so as to
"   not fill message history with non-message items.
"
"   Truncate matching brace line when it's gonna be too long - this avoids the
"   dreaded "Press ENTER or type command to continue" message that would be
"   so disruptive to workflow.
"
"   To do this, the plugin must take the &showcmd, &ruler and &laststatus
"   options into consideration.  If you use a custom &rulerformat, you will
"   want to set the global variable g:MP_rulerwidth to the width of your
"   ruler.
"
"   The variable g:MP_stmt_thresh lets the user specify how far back
"   the plugin may scan for a statement beginning a code block.
"
" 0.1 2007-11-01
"   Initial Version.  Improves over standard matchparen.vim plugin by echoing
"   line containing matching bracket in the status line so you can quickly
"   see which block is terminated by this paren.  Also scans for braces/parens
"   which are off-screen.
"   If you write functions or blocks like this:
"   if (condition)
"   {
"       ...
"   }
"   the plugin will echo the line "if (condition)" and not the lone "{".
"   By default, the plugin scans the line containing the opening brace and the
"   two lines above that, looking for the statement that begins the block, be
"   it a loop or function definition.  If you want more or less, set it in the
"   variable g:stmt_thresh.
"}}}

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - the original matchparen.vim plugin was already loaded
" - when 'compatible' is set
" - the "CursorMoved" autocmd event is not availble.
" - Vim version doesn't support exception handling
if exists("g:loaded_matchparen") || &cp || !exists("##CursorMoved") || v:version < 700
	finish
endif

let g:loaded_matchparen = 1

augroup matchparen
	" Replace all matchparen autocommands
	autocmd! CursorMoved,CursorMovedI * call s:Highlight_Matching_Pair()
augroup END

" Skip the rest if it was already done.
if exists("*s:Highlight_Matching_Pair")
	finish
endif

let cpo_save = &cpo
set cpo-=C

" FUNCTIONS {{{
" The function that is invoked (very often) to define a ":match" highlighting
" for any matching paren.
function! s:Highlight_Matching_Pair() "{{{
	" Remove any previous match.
	if exists('w:paren_hl_on') && w:paren_hl_on
		3match none
		let w:paren_hl_on = 0
	endif

	" Remove echoed matching line
	if exists('w:match_line_on') && w:match_line_on
		let w:match_line_on = 0
		echo
	endif

	" Avoid that we remove the popup menu.
	" Return when there are no colors (looks like the cursor jumps).
	if pumvisible() || (&t_Co < 8 && !has("gui_running"))
		return
	endif

	" Get the character under the cursor and check if it's in 'matchpairs'.
	let c_lnum = line('.')
	let c_col = col('.')
	let before = 0

	let c = getline(c_lnum)[c_col - 1]
	let plist = split(&matchpairs, '.\zs[:,]')
	let i = index(plist, c)
	if i < 0
		" not found, in Insert mode try character before the cursor
		if c_col > 1 && (mode() == 'i' || mode() == 'R')
			let before = 1
			let c = getline(c_lnum)[c_col - 2]
			let i = index(plist, c)
		endif
		if i < 0
			" not found, nothing to do
			return
		endif
	endif

	" Figure out the arguments for searchpairpos().
	if i % 2 == 0
		let s_flags = 'nW'
		let c2 = plist[i + 1]
		let stopline = line('$')
	else
		let s_flags = 'nbW'
		let c2 = c
		let c = plist[i - 1]
		let stopline = 0
	endif
	if c == '['
		let c = '\['
		let c2 = '\]'
	endif

	" Find the match.  When it was just before the cursor move it there for a
	" moment.
	if before > 0
		let save_cursor = winsaveview()
		call cursor(c_lnum, c_col - before)
	endif

	" When not in a string or comment ignore matches inside them.
	let s_skip ='synIDattr(synID(line("."), col("."), 0), "name") ' .
				\ '=~?  "string\\|character\\|singlequote\\|comment"'
	execute 'if' s_skip '| let s_skip = 0 | endif'

	" Borrowed from patch 7.1.269
	" Limit the search time to 500 msec to avoid a hang on very long lines.
	try
		let [m_lnum, m_col] = searchpairpos(c, '', c2, s_flags, s_skip, stopline, 500)
	catch /E118/ "when searchpairpos() doesn't take a seventh argument
		let [m_lnum, m_col] = searchpairpos(c, '', c2, s_flags, s_skip, stopline)
	endtry

	if before > 0
		call winrestview(save_cursor)
	endif

	" If a match is found setup match highlighting.
	if m_lnum > 0 && m_lnum >= line('w0') && m_lnum <= line('w$')
		exe '3match MatchParen /\(\%' . c_lnum . 'l\%' . (c_col - before) .
					\ 'c\)\|\(\%' . m_lnum . 'l\%' . m_col . 'c\)/'
		let w:paren_hl_on = 1
	endif

	" Print the line containing the matching paren in the statusline
	if m_lnum < c_lnum && m_lnum > 0 && 'i' != mode()
		" The matching paren is ABOVE cursor
		let w:match_line_on = 1
		
		" Number of lines to scan backward looking for a statement
		" which begins a block
		if exists('g:MP_stmt_thresh')
			let s:stmt_thresh = g:MP_stmt_thresh
		else
			let s:stmt_thresh = 3
		endif

		let m_stmt = m_lnum
		let i = 0
		while getline(m_stmt) =~ '^\s*' . c . '\s*$\|^\s*$' 
					\&& i <= s:stmt_thresh && m_stmt > 1
			let i += 1
			let m_stmt = m_lnum - i
		endwhile
		if i > s:stmt_thresh
			let text = s:TreatText(m_lnum)
			redraw | echo text
		else
			let text = s:TreatText(m_stmt)
			redraw | echo text
		endif
	elseif m_lnum > c_lnum && 'i' != mode()
		" The matching paren is BELOW cursor
		let text = s:TreatText(m_lnum)
		let w:match_line_on = 1
		redraw | echo text
	endif
endfunction "}}}

" If the line containing the matching brace is too long, echoing it will
" cause a 'Hit ENTER' prompt to appear.  This function cleans up the line
" so that doesn't happen.
" The echoed line is too long if it is wider than the width of the window,
" minus cmdline space taken up by the ruler and showcmd features.
function! s:TreatText(linenum) "{{{
	let text = substitute(getline(a:linenum), '\t', repeat(' ', &ts), 'g')

	" If length of text with tabs converted into spaces + length
	" of line number + 2 (for the ': ' that follows the line number)
	" is greater than the width of the screen, truncate in the middle
	let filler = '...'
	let numlen = strlen(string(a:linenum)) + strlen(': ')
	let to_fill = &columns - numlen
	
	" Account for space used by elements in the command-line to avoid
	" 'Hit ENTER' prompts.
	" If showcmd is on, it will take up 12 columns.
	" If the ruler is enabled, but not displayed in the statusline, it
	" will in its default form take 17 columns.  If the user defines
	" a custom &rulerformat, they will need to specify how wide it is.
	if has('cmdline_info')
		if &showcmd == 1
			let to_fill -= 12
		else
			let to_fill -= 1
		endif
		if &ruler == 1
			if (&laststatus == 0) || 
						\(&laststatus == 1 && winnr('$') == 1)
				if has('statusline')
					if &rulerformat == ''
						" default ruler is 17 chars wide
						let to_fill -= 17
					elseif exists('g:MP_rulerwidth')
						let to_fill -= g:MP_rulerwidth
					endif
				endif
 			endif
		endif
	else
		let to_fill -= 1
	endif

	if strlen(text) > to_fill
		let front = to_fill / 2 -1
		let back  = front 
		if to_fill % 2 == 0 | let back -= 1 | endif
		let text = strpart(text, 0, front) . filler .
					\strpart(text, strlen(text) - back)
	endif
	return string(a:linenum) . ": " . text
endfunction "}}}

" Define commands that will disable and enable the plugin. {{{
command! NoMatchParen 3match none | unlet! g:loaded_matchparen | au! matchparen
command! DoMatchParen runtime plugin/matchparen++.vim | doau CursorMoved
"}}}

"}}}

let &cpo = cpo_save

" vim: set foldmethod=marker textwidth=76 filetype=vim:
