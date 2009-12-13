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
" Last Modified: Sun Dec 13, 2009  01:31PM
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

set backspace=2

" auto generated file: filename~ 
set backup
set backupdir=$HOME/.vim/backup
syntax on 
set vb

"add runtimepath to make 'vim -u ~kent/.vimrc" work properly
set runtimepath+=~kent/.vim

if &term == "xterm-color" || &term == "xterm-16color"
    set t_Co=16
elseif ! has("gui_running")
    set t_Co=256
endif 

" for GVim
if has("gui_running")
    set guioptions-=T
    colorscheme wombat
    set gfn=Consolas:h14
else
    "For Colorscheme
    set bg=dark
    colorscheme peaksea_new 
    " colorscheme ir_black 
endif

" Status Line
set laststatus=2
"set statusline=%<%f\ %m%=\ %h%r\ %-19([%p%%]\ %3l,%02c%03V%)%y
set statusline=File:\ %t\%r%h%w\ [%{&ff},%{&fileencoding},%Y]\ %m%=\ [AscII=\%03.3b]\ [Hex=\%02.2B]\ [Pos=%l,%v,%p%%]\ [LINE=%L]

set hlsearch
set showmatch
set number

set autoindent     " Auto Indent 
set smartindent    " Smart Indent
set cindent        " C-style Indent

set smarttab       " Smart handling of the tab key
set expandtab      " Use spaces for tabs
set shiftround     " Round indent to multiple of shiftwidth
set shiftwidth=4   " Number of spaces for each indent
set tabstop=4      " Number of spaces for tab key

set history=500    " keep 200 lines of command line history
set ruler          " show the cursor position all the time
set showcmd        " display incomplete commands
set incsearch      " do incremental searching

set lazyredraw     " Do not redraw while running macros (much faster) (LazyRedraw)

nmap <tab> V>
nmap <s-tab> V<
xmap <tab> >gv
xmap <s-tab> <gv

set foldmethod=marker
set foldlevel=1000
set foldnestmax=3
nnoremap ,<SPACE> za

" {{{ file encoding setting
set fileencodings=utf-8,big5,euc-jp,gbk,euc-kr,utf-bom,iso8859-1
set termencoding=utf-8
set enc=utf-8
set tenc=utf8
set fenc=utf-8
" }}}

" For ambiguous characters, ex: ”, and BBS XD
set ambiwidth=double

" Favorite file types
set ffs=unix,dos,mac

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
map <C-D> viwy:!clear; ydict <C-R>"<CR>

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
set wildignore+=*.o,*.a,*.so,*.obj,*.exe,*.lib,*.ncb,*.opt,*.plg,.svn,.git

" for :TOhtml
"let html_use_css=1
"let use_xhtml = 1
let html_number_lines = 1 
let html_no_pre = 1 
let html_ignore_folding = 1

set scrolloff=10
set sidescrolloff=10
set ignorecase
set smartcase

"show CursorLine
set cursorline

set backspace=indent,eol,start  " Allow backspacing over these

" Determining the highlight group that the word under the cursor belongs to
nmap <silent> ,c :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Spell Check
hi SpellBad term=underline cterm=underline ctermfg=red
map <F5> :set spell!<CR><BAR>:echo "Spell check: " . strpart("OffOn", 3 * &spell, 3)<CR>

"Visualize some special chars
set listchars=tab:>-,trail:-,eol:$,nbsp:%,extends:>,precedes:< 
map <F8> :set list!<bar>set list?<CR>

" Add new keyword in search under cursor (*)
map a* :exec "/\\(".getreg('/')."\\)\\\\|".expand("<cword>")<CR>

" Use Ctrl+hjkl to switch between Window
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-h> <C-w>h
nmap <C-l> <C-w>l
nmap - <C-w>-
nmap + <C-w>+
" Define different behavior in left/right window
if has("autocmd")
    autocmd BufEnter,BufLeave *
    \     if winnr() == 1 |
    \        nmap < <C-w><|
    \        nmap > <C-w>>|
    \     else            |
    \        nmap < <C-w>>|
    \        nmap > <C-w><|
    \     endif           |
endif

" this allows all window commands in insert mode and i'm not accidentally deleting words anymore :-) 
imap <C-w> <C-o><C-w> 

" useful ab
cabbrev vds vertical diffsplit

" Force to split right!
set splitright
cabbrev h vertical help
cabbrev help vertical help
"cabbrev split vsplit
"cabbrev new vnew

" Remove 'recording' key mapping
nmap q <Cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mouse + gVim-Killer Related Setting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" This is AWESOME, INCREDIBLE! Could be used do Tab-Click, window resizing, scrolling... 
"set mouse=a           " Enable use of the mouse for all modes.
set ttymouse=xterm2   " To function correctly in Screen

" Enable block-mode selection
noremap <C-LeftMouse> <LeftMouse><Esc><C-V>
noremap <C-LeftDrag> <LeftDrag>

" Copy to System-Clipboard
if OS == "Darwin"
    map <C-c> :w! ~/tmp/vimbuffer<CR>:!pbcopy < ~/tmp/vimbuffer<CR><CR>
else
    map <C-c> :w! ~/tmp/vimbuffer<CR>:!nc 172.16.2.54 4573 < ~/tmp/vimbuffer<CR><CR>
endif

map c <C-c>

" Select all
map a <ESC>ggVG

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
hi diffchange ctermbg=236
hi diffadd ctermbg=4
hi DiffDelete ctermfg=69 ctermbg=234
hi difftext ctermbg=3 ctermfg=0

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

" non-Diff mode: Use <Alt-H> move to home, <Alt-L> move to the end
"     Diff mode: Used to do diffput and diffget
" Switch key mapping in Left/Right window under DiffMode
if has("autocmd")
    autocmd BufEnter,BufLeave *
       \ if &diff                                                 |
       \     if winnr() == 1                                      |
       \        nmap h do                                       |
       \        nmap l dp                                       |
       \     else                                                 |
       \        nmap h dp                                       |
       \        nmap l do                                       |
       \     endif                                                |
       \ else                                                     |
       \     if (g:vimgdb_debug_file == "")                       |
       \         nmap <silent> <S-H> :call ToggleHomeActionN()<CR>|
       \         map  <silent> <S-L> $|
       \     endif|
       \ endif                
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Programming Language 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    """"""""""""""""""""""""""""""
    " ctags 
    """"""""""""""""""""""""""""""
    " Set tags path
    set tags=./tags,./../tags

    """"""""""""""""""""""""""""""
    " cscope 
    """"""""""""""""""""""""""""""
    " init cscope hotkey
    nnoremap <F11> <ESC>:cs add ../cscope.out ..<CR>:cs add /home/kent/cscope_ctag/Horus/cscope.out /home/kent/Project/Horus/apps<CR>

    " To avoid using wrong cscope(/opt/montavista/pro5.0/bin/cscope) once sourcing devel_IP8161_VVTK
    set cscopeprg=~/usr/bin/cscope

    """"""""""""""""""""""""""""""
    " Vi Man
    """"""""""""""""""""""""""""""
    " color/paged man 
    runtime! ftplugin/man.vim
    nmap K <esc>:Man <cword><cr>

    """"""""""""""""""""""""""""""
    " Javascript
    """"""""""""""""""""""""""""""
    autocmd FileType javascript set dictionary=~/.vim/dict/javascript.dict

    """"""""""""""""""""""""""""""
    " C/C++
    """"""""""""""""""""""""""""""
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
    au BufReadPre *.bin,*.hex,*.pkg,*.img,*.out setlocal binary
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

nnoremap <C-x> :Hexmode<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    """"""""""""""""""""""""
    " EasyGrep
    """"""""""""""""""""""""
    "Grep 'pattern' in the indicate range (need EasyGrep.vim plugin)
    map <F3> <ESC>\vv
    let g:EasyGrepRecursive = 1
    let g:EasyGrepIgnoreCase= 0 
    let g:EasyGrepJumpToMatch= 1

    """"""""""""""""""""""""""""""
    " VCSCommand
    """"""""""""""""""""""""""""""
    nmap d <Esc>:VCSVimDiff<Enter>

    """"""""""""""""""""""""""""""
    " Smooth Scroll
    """"""""""""""""""""""""""""""
    "Smooth Scroll
    map <PageDown> :call SmoothPageScrollDown()<CR>
    map <PageUp>   :call SmoothPageScrollUp()<CR> 

    """"""""""""""""""""""""
    " Trinity related Start
    """"""""""""""""""""""""
    " Open and close all the three plugins on the same time ,wired toggle Trinity,  will caue hlsearch to no effect, add set hlsearch again manually
    nmap <F12>   :TrinityToggleTagList<CR>
    " nmap <F9>   :TrinityToggleSourceExplorer<CR>
    " nmap <F10>  :TrinityToggleTagList<CR>
    " nmap <F11>  :TrinityToggleNERDTree<CR> 
    let Tlist_Use_Right_Window=1

   """"""""""""""""""""""""""""""
   " Minibuffer
   """"""""""""""""""""""""""""""
   let g:miniBufExplModSelTarget = 1 
   hi MBENormal ctermfg=7
   hi MBEVisibleNormal ctermfg=2
   hi MBEChanged ctermfg=14
   hi MBEVisibleChanged ctermfg=2

   """"""""""""""""""""""""""""""
   " SrcExplorer 
   """"""""""""""""""""""""""""""
   "let s:SrcExpl_tagsPath = '/home/kent/cscope_ctag/lsp/'
   "let s:SrcExpl_workPath = '/home/kent/cscope_ctag/lsp/'
   " Let the Source Explorer update the tags file when opening
   let g:SrcExpl_updateTags = 0

   """"""""""""""""""""""""""""""
   " vimgdb
   """"""""""""""""""""""""""""""
    let g:vimgdb_debug_file = ""
    run macros/gdb_mappings.vim 

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions & autocmd
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" set vim to chdir for each file
if exists('+autochdir')
    set autochdir
else
    autocmd BufEnter * silent! lcd %:p:h:gs/ /\\ /
endif
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
"if has("autocmd")
    "autocmd BufRead *.txt set tw=78
    "autocmd BufReadPost *
       "\ if line("'\"") > 0 && line ("'\"") <= line("$") |
       "\   exe "normal g'\"" |
       "\ endif
"endif

"autocmd BufWinLeave * if expand("%") != "" | mkview | endif
"autocmd BufWinEnter * if expand("%") != "" | loadview | endif
"Restore cursor to file position in previous editing session
autocmd BufReadPost * if line ("'\"") > 0 && line ("'\"") <= line("$") | exe "normal g'\"" | endif


" QUICKFIX WINDOW for :make
command -bang -nargs=? QFix call QFixToggle(<bang>0)
function! QFixToggle(forced)
    if exists("g:qfix_win") && a:forced == 0
        cclose
        unlet g:qfix_win
    else
        copen 6 
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

" Visual Search : From an idea by Michael Naumann
function! VisualSearch(direction) range
    let l:saved_reg = @"
    execute "normal! vgvy"
    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")
    if a:direction == 'b'
        execute "normal ?" . l:pattern . "^M"
    else
        execute "normal /" . l:pattern . "^M"
    endif
    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

"Basically you press * or # to search for the current selection !! Really useful
vnoremap <silent> * :call VisualSearch('f')<CR>
vnoremap <silent> # :call VisualSearch('b')<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MISC
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
