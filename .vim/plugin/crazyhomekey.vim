" ============================================================================
" File:          crazyhomekey.vim
" Description:   Finetune Home key operation for Programmer
" Maintainer:    Kent Chen <chenkaie at gmail dot com>
" Version:       1.0
" Last Modified: Fri Sep 04, 2009  03:54PM
" License:       This program is free software. It comes without any warranty,
"                to the extent permitted by applicable law. You can redistribute
"                it and/or modify it under the terms of the Do What The Fuck You
"                Want To Public License, Version 2, as published by Sam Hocevar.
"                See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" Usage:
" Trigger <Home> key arbitrarily in vim or follow below steps:
"
"    a. Normal mode
"        1. Press <Home> key in the middle of a line
"        2. Press <Home> key again
"
"    b. Insert mode
"        do the same as above. It works well ^_^
"
" Installation:
" Place in ~/.vim/plugin (to load at start up)
"
" Recommended: 
" Add below mapping to your .vimrc or uncomment below 
" Use <Alt-H> move to home, <Alt-L> move to the end
"     nmap h      :call ToggleHomeActionN()<CR>
"     imap h <ESC>:call ToggleHomeActionI()<CR>
"     map l $
"
" History:
"    1.0  Initial Release
"    1.1  Fine tune this script and layout
" ============================================================================

if v:version < 700
    finish
endif

" finetune <Home> key action to fit programmer
function! GetPrevChar()
    if col('.') == 1
        return "\0"
    endif
    return strpart(getline('.'), col('.')-2, 1)
endfunction

function! ToggleHomeActionN()
    if (GetPrevChar() == " " || GetPrevChar() == "\t") 
        call feedkeys("0", 'n')
        " This works too!
        " call setpos('.', [0, line('.'), 1])
    else   
        call feedkeys("^", 'n')
    endif
endfunction

function! ToggleHomeActionI()
    if (GetPrevChar() == " " || GetPrevChar() == "\t") 
        " call setpos('.', [0, line('.'), 1])
        call feedkeys("\<Home>i")
    else   
        call feedkeys("\<Esc>^i")
    endif
endfunction

nmap [1~      :call ToggleHomeActionN()<CR>
imap [1~ <ESC>:call ToggleHomeActionI()<CR>

" vim:set ft=vim et sw=4 sts=4:
