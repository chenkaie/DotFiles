" vim plugin for svn diff 
" description:
"   vim plugin to show svn diffs 
"   this is derived from cvsdiff.vim plugin 
"   http://www.vim.org/scripts/script.php?script_id=265
" maintainer:  Eric Ji <eji@yahoo-inc.com>
"
" usage:
" 1) install
"    copy this file to your vim plugin directory, normally ~/.vim/plugin
"    if not, can manally source this file in vim or add into ~/.vimrc
"    :source svndiff.vim
" 2) used as vim command, format :D [v] [version #]
"    :D h    
"       -- diff between opened file and lastest svn version, horizontal split
"    :D      
"       -- diff between opened file and lastest svn version, vertical split
"    :D h <version #>  example  :D 1.2
"       -- diff between opened file and svn version #, horizontal split
"    :D <version #>  example  :D v 1.2
"       -- diff between opened file and svn version #, vertical split
" 3) map to key 
"    can create key mapping by adding the following lines in ~/.vimrc, example
"    a. map <F8> <Plug>D
"         -- press F8 in vim, show diff to svn last version, horizontal split
"    b. map <F7> <Plug>Dh
"         -- press F7 in vim, show diff to svn last version, vertical split
" 4) return from diff mode to normal mode
"    :set nodiff
"
" example:
"   a) open a file in vim
"   b) use vim command line, :D <enter> to see two windows with diffs
"   c) :close to close tmp window
"   d) :set nodiff to expand the compressed view, or press a on '+' sign to expand 

if exists("loaded_svndiff") || &cp
    finish
endif
let loaded_svndiff = 1

noremap <unique> <script> <Plug>D :call <SID>Svndiff()<CR>
noremap <unique> <script> <plug>Dh :call <SID>Svndiff("h")<CR>
com! -bar -nargs=* D :call s:Svndiff(<f-args>)

" to return to the previous buffer
inoremap <silent> <F4> <C-O>:close<CR>

function! s:Svndiff(...)
    if a:0 == 1 && a:1 != "h" && a:1 != "v"
        let rev = " -r".a:1
    elseif a:0 == 2
        let rev = " -r".a:2 
    else 
        let rev = ''
    endif

    let ftype = &filetype
    let tmpfile = tempname()
    let cmd = "cat " . bufname("%") . " > " . tmpfile
    let cmd_output = system(cmd)
    let tmpdiff = tempname()
    let cmd = "svn diff" . rev . " " . bufname("%") . " > " . tmpdiff
    let cmd_output = system(cmd)
    if v:shell_error && cmd_output != ""
        echohl WarningMsg | echon cmd_output 
        return
    endif

    let cmd = "patch -R -p0 " . tmpfile . " " . tmpdiff
    let cmd_output = system(cmd)
    if v:shell_error && cmd_output != ""
        echohl WarningMsg | echon cmd_output 
        return
    endif

    if a:0 > 0 && a:1 == "h"
        exe "diffsplit" . tmpfile
    else
        exe "vert diffsplit" . tmpfile
    endif  

    exe "set filetype=" . ftype
endfunction
