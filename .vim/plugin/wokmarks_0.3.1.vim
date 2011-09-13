" Vim plugin - local marks usage more similar to other editors
" File:		wokmarks.vim
" Created:	2009 Jan 18
" Last Change:	2010 Aug 17
" Rev Days:     14
" Author:	Andy Wokula <anwoku@yahoo.de>
" Version:	0.3.1
" Vim Version:	7.0+
"
" Description:
"   Lets you set and toggle a mark on a line without specifying which mark
"   to use exactly.  wokmarks will choose an unused mark from a pool of
"   allowed marks.  The script is quite verbose: you will get info which
"   mark was set, removed or jumped to.
"
"   In other editors, you can find for example:
"	CTRL-F2	    toggle a mark on/off for current line
"	F2	    jump to next mark below
"	SHIFT-F2    jump to previous mark above
"
"   You can enable (only) the above keys with
"	:let g:wokmarks_do_maps = 2
"
"   in your vimrc.  But the default keys are the following:

" Usage: key	action
"   tm		set pool mark for current line (if no local mark exists)
"   tt		toggle pool mark for current line
"   tk tj	jump to the [count]th local mark above/below (like [' and ]'
"		which are less verbose)
"   tl		list local marks
"   tD		remove all pool marks from the buffer or pool marks in range
"
" "t" actually is a built-in command; see the "<Plug>-maps" section in the
" code if you want to map other keys in the vimrc.
"
" Local marks = pool marks + user marks.  User marks will not be set or
" removed by the script.

" Global Functions: (not for normal use)
"   Wokmarks_UpdMarkLists()	make updated g:wokmarks_pool take effect
"   Wokmarks_Type({mark})	get type of mark (pool or user mark)
"   Wokmarks_GetMark({lnum})	for given {lnum}, get a pool mark and its
"   				status, don't set it yet (for use in
"   				scripts)

" TODO
" - marks highlighting? check other scripts
" - maybe enable those "at mark" messages also with visual mode? if not,
"   then do  :xmap tk ['  and  :xmap tj ]'  and simplify PrevMarkWok and
"   NextMarkWok
" - extract parts to autoload script?
" - check out what it needs to make Wokmarks_GetMark() really useful
" v0.1
" + jumping with count
" + <Plug>maps - allow for the F2 mappings
" + make SetMark() usable in scripts
" + init folklore, cpo
" v0.2
" + tj tk set the ' mark, to allow jumping back with CTRL-O
" + added Omap mode for <Plug>NextMarkWok, <Plug>PrevMarkWok
" + let Wokmarks_GetMark() also accept ".", "$", etc.
" + if g:wokmarks_do_maps == 2, then F2 maps are used (Tom Link)
" + prev/next mark searches wrap around (Tom Link)
" v0.3
" + added toggle hook (:au User WokmarksChange) (Tom Link)
" + added Wokmarks_GetLocalMarks()
" v0.3.1
" + :doautocmd executes the modelines (bug in Vim?); reset 'modeline'

" Script Init Folklore:
if exists("loaded_wokmarks")
    finish
endif
let loaded_wokmarks = 1

if v:version < 700
    echomsg "Wokmarks: you need at least Vim 7.0"
    finish
endif

let s:cpo_save = &cpo
set cpo&vim

" Customization:
" pool marks
if !exists("g:wokmarks_pool")
    let g:wokmarks_pool = "abcdfghijklmnopqrtuvwxyz"
    " marks s and e excluded, common use for start and end position
endif

" should we map the default keys?
if !exists("g:wokmarks_do_maps")
    let g:wokmarks_do_maps = 1
endif

" <Plug>-maps for use in the vimrc, needs g:wokmarks_do_maps = 0 then
nnoremap <silent> <Plug>PrevMarkWok   :<C-U>call<sid>PrevMarkWok(0)<CR>
vnoremap <silent> <Plug>PrevMarkWok   :<C-U>call<sid>PrevMarkWok(1)<CR>
onoremap	  <Plug>PrevMarkWok   ['
nnoremap <silent> <Plug>NextMarkWok   :<C-U>call<sid>NextMarkWok(0)<CR>
vnoremap <silent> <Plug>NextMarkWok   :<C-U>call<sid>NextMarkWok(1)<CR>
onoremap	  <Plug>NextMarkWok   ]'
nnoremap <silent> <Plug>ToggleMarkWok :<C-U>call<sid>ToggleMarkWok()<CR>
nnoremap <silent> <Plug>SetMarkWok    :<C-U>call<sid>SetMarkWok()<CR>
nnoremap <silent> <Plug>KillMarksWok  :call<sid>KillMarksWok(0)<CR>
vnoremap <silent> <Plug>KillMarksWok  :call<sid>KillMarksWok(1)<CR>

if g:wokmarks_do_maps == 1
    map tk <Plug>PrevMarkWok
    sunmap tk
    map tj <Plug>NextMarkWok
    sunmap tj
    nmap tt <Plug>ToggleMarkWok
    nmap tm <Plug>SetMarkWok
    map tD <Plug>KillMarksWok
    sunmap tD
    nnoremap <silent> tl :WokListMarks<CR>
elseif g:wokmarks_do_maps == 2
    map <F2> <Plug>NextMarkWok
    map <S-F2> <Plug>PrevMarkWok
    nmap <C-F2> <Plug>ToggleMarkWok
    " nmap <F2> <Plug>SetMarkWok
endif
command! -range=% WokKillMarks <line1>,<line2>call <sid>KillMarksWok(1)
command! WokListMarks marks abcdefghijklmnopqrstuvwxyz

" toggle pool mark for current line
func! <sid>ToggleMarkWok()
    " if current line has a user mark, don't set a pool mark to avoid two
    " marks on the same line
    let curlnum = line(".")
    let poolnrlist = map(copy(s:poolmarks), "line(\"'\".v:val)")
    let idx = index(poolnrlist, curlnum)
    if idx >= 0
	" line has a pool mark, turn it off
	let mark = s:poolmarks[idx]
	exec "delmarks" mark
	echo "Mark" mark "removed"
	call s:ExecToggleHook(0, [mark])
	return
    endif
    let lnrlist = map(copy(s:usermarks), "line(\"'\".v:val)")
    let idx = index(lnrlist, curlnum)
    if idx >= 0
	" line has a user mark, don't touch it
	echo "Line has user mark" s:usermarks[idx] "(will not toggle it)"
	return
    endif
    " set new mark for current line, find unused pool mark
    let newidx = index(poolnrlist, 0)
    if newidx < 0
	echo "All" len(s:poolmarks) "marks in use!"
	return
	" maybe maintain a history, and use the oldest mark?
    endif
    let mark = s:poolmarks[newidx]
    exec "mark" mark 
    echo "Mark" mark "set"
    call s:ExecToggleHook(1, [mark])
endfunc

" still experimental regarding its usefulness:
func! Wokmarks_GetMark(lnum_expr)
    let lnum = a:lnum_expr==0 ? line(a:lnum_expr) : a:lnum_expr
    return <sid>SetMarkWok(lnum)
endfunc

" set a pool mark (not if a mark exists)
func! <sid>SetMarkWok(...)
    " a:1 (lnum) - (default current line) if provided, be quiet and don't
    "	set a mark, instead return [{mark}, {status}] to let the caller set
    "	the mark himself.  {status} = one of "atline", "nofree", "fresh".
    let non_interact = a:0>=1 && a:1>=1
    let curlnum = non_interact ? a:1 : line(".")
    let lnrlist = map(copy(s:localmarks), "line(\"'\".v:val)")
    let idx = index(lnrlist, curlnum)
    if idx >= 0
	if non_interact
	    return [s:localmarks[idx], "atline"]
	else
	    echo "Line already has mark" s:localmarks[idx]
	    return
	endif
    endif
    " set new mark for current line, find unused pool mark
    let lnrlist = map(copy(s:poolmarks), "line(\"'\".v:val)")
    let newidx = index(lnrlist, 0)
    if newidx < 0
	if non_interact
	    return ["", "nofree"] 
	else
	    echo "All" len(s:poolmarks) "marks in use!"
	    return
	endif
	" ? maybe maintain a history, and use the oldest mark
    endif
    if non_interact
	return [s:poolmarks[newidx], "fresh"]
    else
	let mark = s:poolmarks[newidx]
	exec "mark" mark
	echo "Mark" mark "set"
	call s:ExecToggleHook(1, [mark])
    endif
endfunc

" jump upwards to any of the local marks a-z
func! <sid>PrevMarkWok(vmode)
    if a:vmode
	normal! gv
    endif
    let curlnum = line(".")
    let cnt = v:count
    let lnrlist = map(copy(s:localmarks), "line(\"'\".v:val)")
    let abolnrlist = map(copy(lnrlist), 'v:val >= curlnum ? 0 : v:val')
    let prevlnum = max(abolnrlist)
    if prevlnum >= 1
	if cnt > 0
	    let lnrsdesc = sort(filter(abolnrlist, 'v:val>0'), "s:NcmpD")
	    let prevlnum = lnrsdesc[cnt>len(lnrsdesc) ? -1 : cnt-1]
	endif
    elseif cnt == 0
	let prevlnum = max(lnrlist)
	if prevlnum == 0
	    echo "No local marks"
	    return
	endif
    else
	echo "No local mark above cursor position"
	return
    endif
    let mark = s:localmarks[index(lnrlist, prevlnum)]
    mark '
    exec "'". mark
    if !a:vmode || !&showmode
	redraw
	echo "At mark" mark
    endif
endfunc

" Jumps to next following mark after current cursor
" any mark a-z
func! <sid>NextMarkWok(vmode)
    if a:vmode
	normal! gv
    endif
    let curlnum = line(".")
    let cnt = v:count
    let lnrlist = map(copy(s:localmarks), "line(\"'\".v:val)")
    let bellnrlist = filter(copy(lnrlist), 'v:val>curlnum')
    " hehe we must exclude the zeros
    let nextlnum = min(bellnrlist)
    if nextlnum >= 1
	if cnt > 0
	    let lnrsasc = sort(bellnrlist, "s:NcmpA")
	    let nextlnum = lnrsasc[cnt>len(lnrsasc) ? -1 : cnt-1]
	endif
    elseif cnt == 0
	let marklnums = filter(copy(lnrlist), 'v:val>0')
	if empty(marklnums)
	    echo "No local marks"
	    return
	    " don't depend on min([]) == 0
	endif
	let nextlnum = min(marklnums)
    else
	echo "No local mark below cursor position"
	return
    endif
    let mark = s:localmarks[index(lnrlist, nextlnum)]
    mark '
    exec "'". mark
    if !a:vmode || !&showmode
	redraw
	echo "At mark" mark
    endif
endfunc

" kill marks (pool marks only) from the buffer
func! <sid>KillMarksWok(userange) range
    let marklist = copy(s:poolmarks)
    call filter(marklist, "line(\"'\".v:val) > 0")
    if a:userange || v:count > 0
	" kill marks within range of lines
	call filter(marklist, "line(\"'\".v:val) >= a:firstline"
	    \. " && line(\"'\".v:val) <= a:lastline")
    endif
    if empty(marklist)
	echo "No marks killed"
    else
	exec "delmarks" join(marklist)
	echo "Marks killed:" join(marklist)
	call s:ExecToggleHook(0, marklist)
    endif
endfunc

" after changing g:wokmarks_pool
func! Wokmarks_UpdMarkLists()
    let s:marktype = {}
    " P pool, U local mark not from pool (user mark)
    let s:poolmarks = split(g:wokmarks_pool, '\s*')
    for pm in s:poolmarks
	let s:marktype[pm] = "P"
    endfor
    let s:localmarks = split("abcdefghijklmnopqrstuvwxyz", '\m')
    let s:usermarks = []
    for um in s:localmarks
	if !has_key(s:marktype, um)
	    let s:marktype[um] = "U"
	    call add(s:usermarks, um)
	endif
    endfor
endfunc

func! Wokmarks_GetLocalMarks()
    return filter(copy(s:localmarks), "line(\"'\".v:val)>=1")
endfunc

" check if {mark} is a pool mark (return "P") or a user mark (return "U");
" return "" for unknown mark (e.g. a global mark)
func! Wokmarks_Type(mark)
    return get(s:marktype, a:mark, "")
endfunc

" sort() cannot sort after numbers outofbox
func! s:NcmpA(i1, i2)
    return a:i1 - a:i2
endfunc

func! s:NcmpD(i1, i2)
    return a:i2 - a:i1
endfunc

func! s:ExecToggleHook(added, marks)
    " {added}	indicates that the argument marks have been added (1) or
    "		removed (0)
    " {marks}	(list) list of marks
    try
	let sav_ml = &ml
	setlocal nomodeline
	let b:wokmarks_changed = [a:added, a:marks]
	sil doautocmd User WokmarksChange
    finally
	unlet! b:wokmarks_changed
	let &l:ml = sav_ml
    endtry
endfunc

" Credits: original script _vim_wok_visualcpp.vim
"   Wolfram 'Der WOK' Esser, 2001-08-21
"   mailto:wolfram(at)derwok(dot)de
"   http://www.derwok.de/
"   Version 0.1, 2001-08-21 - initial release

" Init:

call Wokmarks_UpdMarkLists()

" Cleanup And Modeline:
let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set ts=8 sts=4 sw=4 noet:
