"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" (Generate by Cowsay)
"  ----------------------
" < .vimrc by Kent@rd1-2 >
"  ----------------------
"        \   ^__^
"         \  (oo)\_______
"            (__)\       )\/\
"                ||----w |
"                ||     ||
"
" Author:        Kent Chen <chenkaie at gmail.com>
" Last Modified: Thu Sep 03, 2009  10:23PM
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General Setting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Use Vim settings, rather then Vi settings (much better!). This must be first, because it changes other options as a side effect.
set nocompatible

"has("mac") & has("macunix") just work for MacVim
if match(system('uname'),'Darwin') == 0
    let OS = "Darwin"
elseif has("unix")
    let OS = "Unix"
elseif has("win32")
    let OS = "Win32"
endif

if OS != "Darwin"
"change to the directory containing the file which was opened or selected
set autochdir
endif

" 游標移動後, 一樣可以用 backsapce, del 等刪除動作
set bs=2

" auto generated file: filename~ 
set backup
set backupdir=$HOME/.vim/backup

syntax on

set vb
"add runtimepath to make 'vim -u ~kent/.vimrc" work properly
set runtimepath+=~kent/.vim

if ! has("gui_running")
    set t_Co=256
endif 

"For Colorscheme
"colorscheme peaksea
set bg=dark
colorscheme peaksea_new
"colorscheme inkpot
"GuiColorScheme rdark

"for GVim
"colorscheme wombat 

" Status Line
set laststatus=2
"set statusline=%<%f\ %m%=\ %h%r\ %-19([%p%%]\ %3l,%02c%03V%)%y
set statusline=File:\ %t\%r%h%w\ [%{&ff},%{&fileencoding},%Y]\ %m%=\ [AscII=\%03.3b]\ [Hex=\%02.2B]\ [Pos=%l,%v,%p%%]\ [LINE=%L]
highlight StatusLine ctermfg=black ctermbg=white

set hlsearch
set showmatch
set number
set cindent

"set autoindent    " Use indent from previous line
set smarttab       " Smart handling of the tab key
set expandtab      " Use spaces for tabs
set shiftround     " Round indent to multiple of shiftwidth
set shiftwidth=4   " Number of spaces for each indent
set tabstop=4      " Number of spaces for tab key

set history=500    " keep 200 lines of command line history
set ruler          " show the cursor position all the time
set showcmd        " display incomplete commands
set incsearch      " do incremental searching

nmap <tab> V>
nmap <s-tab> V<
xmap <tab> >gv
xmap <s-tab> <gv

set foldmethod=marker
"set foldmethod=syntax
set foldlevel=1000
set foldnestmax=3
nnoremap <SPACE> za

" {{{ file encoding setting
set fileencodings=utf-8,big5,euc-jp,gbk,euc-kr,utf-bom,iso8859-1
set termencoding=utf-8
set enc=utf-8
set tenc=utf8
set fenc=utf-8
" }}}

" Edit your .vimrc in new tab
nmap ,s :source $MYVIMRC <CR>
nmap ,v :tabedit $MYVIMRC <CR>

" Edit your .bashrc in new tab
nmap ,b :tabedit ~/.bashrc <CR>

" Edit(e) & Generate(g) help tags
nmap ,he :tabedit $HOME/.vim/doc/MyNote.txt <CR>
nmap ,hg :helptags $HOME/.vim/doc <CR>

" Toggle on/off paste mode
map <F7> :set paste!<bar>set paste?<CR>
" For Insert Mode to function
set pastetoggle=<F7>

"Toggle on/off show line number
map <F6> :set nu!<bar>set nu?<CR>

map <F2> <ESC>:cn<CR>
map ,<F2> <ESC>:cp<CR>

"nnoremap <F8> <ESC>:w \| !make test && ./a.out
"compile a c file and execute it.
nnoremap <F9> <ESC>:w \| !gcc -Wall -ansi -pedantic -Wextra -std=c99 % && ./a.out

"replace 'SHIFT+:' with ';' COOL! 
nnoremap ; :

"Yahoo Dictionary
map <C-D> viwy:!ydict <C-R>"<CR>

"tab function hotkey
nmap tl :tabnext<CR>
nmap th :tabprev<CR>
nmap tn :tabnew<CR>
nmap tc :tabclose<CR>

filetype plugin indent on
set completeopt=longest,menu,menuone
set wildmenu
"in ESC: (command mode), disbled auto completion next part, Cool!
set wildmode=list:longest

" for :TOhtml
"let html_use_css=1
"let use_xhtml = 1
let html_number_lines = 1 
let html_no_pre = 1 
let html_ignore_folding = 1

set scrolloff=25
set sidescrolloff=4
set ignorecase
set smartcase

"show CursorLine
set cursorline

set backspace=indent,eol,start  " Allow backspacing over these

" Spell Check
hi SpellBad term=underline cterm=underline ctermfg=red
map <F5> :set spell!<CR><BAR>:echo "Spell check: " . strpart("OffOn", 3 * &spell, 3)<CR>

" Add new keyword in search under cursor (*)
map a* :exec "/\\(".getreg('/')."\\)\\\\|".expand("<cword>")<CR>

" Use Ctrl+hjkl to switch between Window
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-h> <C-w>h
nmap <C-l> <C-w>l

" move to 'first non-whitespace character of a line' <Alt-(>
" move to 'end of a line' <Alt-)>
nmap 9 ^
nmap 0 $
imap 9 <ESC>^i
imap 0 <ESC>$i

" useful abbrev
ab vds vertical diffsplit

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tab Operation Mac-Mapping by Klaymen
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" default 1000
set timeoutlen=500
nmap q <Esc>:qall<Enter>
nmap Q <Esc>:qall!<Enter>
nmap w <Esc>:close<Enter>
nmap W <Esc>:close!<Enter>
nmap s <Esc>:write<Enter>
nmap , <Esc>:tabprev<Enter>
" Vim-Style alt+h, used for diff
"nmap h <Esc>:tabprev<Enter>
"ALT+ <-
nmap OD <Esc>:tabprev<Enter>

nmap . <Esc>:tabnext<Enter>
"Vim-Style alt+l, used for diff
"nmap l <Esc>:tabnext<Enter>
"ALT+ ->
nmap OC <Esc>:tabnext<Enter>
nmap t <Esc>:tabnew<Enter>

nmap 1 <Esc>:tabn 1<Enter>
nmap 2 <Esc>:tabn 2<Enter>
nmap 3 <Esc>:tabn 3<Enter>
nmap 4 <Esc>:tabn 4<Enter>
nmap 5 <Esc>:tabn 5<Enter>
nmap 6 <Esc>:tabn 6<Enter>
nmap 7 <Esc>:tabn 7<Enter>
nmap 8 <Esc>:tabn 8<Enter>

"reload this file
nmap r <Esc>:edit<Enter>

"Tab Highlight color
hi TabLine	ctermfg=fg	ctermbg=28	cterm=NONE
hi TabLineFill	ctermfg=fg	ctermbg=28	cterm=NONE
hi TabLineSel	ctermfg=fg	ctermbg=NONE	cterm=NONE
hi TabLine	cterm=underline  
hi TabLineFill	cterm=underline

autocmd TabLeave * let g:LastUsedTabPage = tabpagenr()
function! SwitchLastUsedTab()
    if exists("g:LastUsedTabPage")
        execute "tabnext " g:LastUsedTabPage
    endif
endfunction
nmap tt :call SwitchLastUsedTab()<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Diff related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"force vim diff to ignore whitespace
set diffopt+=iwhite
" highlight diff color
hi diffchange ctermbg=7 ctermfg=0
hi diffadd ctermbg=4 ctermfg=7
hi difftext ctermbg=1 ctermfg=3

function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()
nmap ,d :DiffSaved<CR>

"DirDiff
let g:DirDiffExcludes = "*.git,*.svn,.*.swp,tags,cscope.*"
let g:DirDiffWindowSize = 10

" WinMerge-style (Alt + hjkl) mapping for vimdiff
nmap j ]c
nmap k [c
" Switch key mapping for Left/Right window
if has("autocmd")
    autocmd BufEnter *
       \ if winnr() == 1  |
       \    nmap h do   |
       \    nmap l dp   |
       \ else             |
       \    nmap h dp   |
       \    nmap l do   |
       \ endif
endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Programming Language 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set tags path
set tags=./tags,./../tags

" init cscope hotkey
nnoremap <F11> <ESC>:cs add ../cscope.out ..<CR>:cs add /home/kent/cscope_ctag/Horus/cscope.out /home/kent/Project/Horus<CR>

" To avoid using wrong cscope(/opt/montavista/pro5.0/bin/cscope) once sourcing devel_IP8161_VVTK
set cscopeprg=/usr/bin/cscope

" color/paged man 
runtime! ftplugin/man.vim
nmap K <esc>:Man <cword><cr>

autocmd FileType javascript set dictionary=~/.vim/dict/javascript.dict

"if filename is test.c => make test
"set makeprg=make
"set errorformat=%f:%l:\ %m

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Hex/Binary Edit                                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" autocmds to automatically enter hex mode and handle file writes properly
if has("autocmd")
  " vim -b : edit binary using xxd-format!
  augroup Binary
    au!
    au BufReadPre *.bin,*.hex,*.pkg,*.img setlocal binary
    au BufReadPost *
          \ if &binary | Hexmode | endif
    au BufWritePre *
          \ if exists("b:editHex") && b:editHex && &binary |
          \  let oldro=&ro | let &ro=0 |
          \  let oldma=&ma | let &ma=1 |
          \  exe "%!xxd -r" |
          \  let &ma=oldma | let &ro=oldro |
          \  unlet oldma | unlet oldro |
          \ endif
    au BufWritePost *
          \ if exists("b:editHex") && b:editHex && &binary |
          \  let oldro=&ro | let &ro=0 |
          \  let oldma=&ma | let &ma=1 |
          \  exe "%!xxd" |
          \  exe "set nomod" |
          \  let &ma=oldma | let &ro=oldro |
          \  unlet oldma | unlet oldro |
          \ endif
  augroup END
endif

" ex command for toggling hex mode - define mapping if desired
command -bar Hexmode call ToggleHex()
" helper function to toggle hex mode
function ToggleHex()
    " hex mode should be considered a read-only operation
    " save values for modified and read-only for restoration later,
    " and clear the read-only flag for now
    let l:modified=&mod
    let l:oldreadonly=&readonly
    let &readonly=0
    let l:oldmodifiable=&modifiable
    let &modifiable=1
    if !exists("b:editHex") || !b:editHex
        " save old options
        let b:oldft=&ft
        let b:oldbin=&bin
        " set new options
        setlocal binary " make sure it overrides any textwidth, etc.
        let &ft="xxd"
        " set status
        let b:editHex=1
        " switch to hex editor
        %!xxd
    else
        " restore old options
        let &ft=b:oldft
        if !b:oldbin
            setlocal nobinary
        endif
        " set status
        let b:editHex=0
        " return to normal editing
        %!xxd -r
    endif
    " restore values for modified and read only state
    let &mod=l:modified
    let &readonly=l:oldreadonly
    let &modifiable=l:oldmodifiable
endfunction

nnoremap b :Hexmode<CR>
inoremap b <Esc>:Hexmode<CR>
vnoremap b :<C-U>Hexmode<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Grep 'pattern' in the indicate range (need EasyGrep.vim plugin)
map <F3> <ESC>\vv
" EasyGrep
let g:EasyGrepRecursive = 1
let g:EasyGrepIgnoreCase= 1
let g:EasyGrepJumpToMatch=0

"VCS
nmap d <Esc>:VCSVimDiff<Enter>

"Smooth Scroll
map <PageDown> :call SmoothPageScrollDown()<CR>
map <PageUp>   :call SmoothPageScrollUp()<CR> 

""""""""""""""""""""""""
" Trinity related Start
""""""""""""""""""""""""
" Open and close all the three plugins on the same time ,wired toggle Trinity,  will caue hlsearch to no effect, add set hlsearch again manually
nmap <F12>   :TrinityToggleTagList<CR> :set hlsearch<CR>
" nmap <F9>   :TrinityToggleSourceExplorer<CR>
" nmap <F10>  :TrinityToggleTagList<CR>
" nmap <F11>  :TrinityToggleNERDTree<CR> 

"let s:SrcExpl_tagsPath = '/home/kent/cscope_ctag/lsp/'
"let s:SrcExpl_workPath = '/home/kent/cscope_ctag/lsp/'
" Let the Source Explorer update the tags file when opening
let g:SrcExpl_updateTags = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions & autocmd
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Automatically update 'Last Modified' field
" If buffer modified, update any 'Last modified: ' in the first 20 lines.
function! LastModified()
  if &modified
    normal ms
    let n = min([20, line("$")])
    exe '1,' . n . 's#^\(.\{,10}Last Modified: \).*#\1' .
          \ strftime('%a %b %d, %Y  %I:%M%p') . '#e'
    normal `s
  endif
endfun
autocmd BufWritePre * call LastModified()

" Remember the line number been edited last time
if has("autocmd")
    autocmd BufRead *.txt set tw=78
    autocmd BufReadPost *
       \ if line("'\"") > 0 && line ("'\"") <= line("$") |
       \   exe "normal g'\"" |
       \ endif
endif

" QUICKFIX WINDOW for :make
command -bang -nargs=? QFix call QFixToggle(<bang>0)
function! QFixToggle(forced)
    if exists("g:qfix_win") && a:forced == 0
        cclose
        unlet g:qfix_win
    else
        copen 8
        let g:qfix_win = bufnr("$")
    endif
endfunction
nnoremap <leader>q :QFix<CR>

" Remove unnecessary spaces in the end of line
"autocmd FileType c,cpp,perl,python,sh,html,js autocmd FileWritePre,BufWritePre <buffer> :call setline(1,map(getline(1,"$"),'substitute(v:val,"\\s\\+$","","")'))

" [Highlight column matching { } pattern], A very cool stuff(Kent)
"let s:hlflag=0
"function! ColumnHighlight()
"   let c=getline(line('.'))[col('.') - 1]
"   if c=='{' || c=='}'
"       set cuc
"       let s:hlflag=1
"   else
"       if s:hlflag==1
"           set nocuc
"           let s:hlflag=0
"       endif
"   endif
"endfunction
"
"autocmd CursorMoved * call ColumnHighlight()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MISC
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
