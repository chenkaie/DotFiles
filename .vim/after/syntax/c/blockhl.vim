" blockhl.vim: highlights indentation blocks with different shades of gray, based on {} level.
"              Only good for gvim and C/C++.
"  Author: Charles E. Campbell, Jr.
"  Date:   Mar 15, 2010
"  Version: 6d	ASTRO-ONLY
"
" GetLatestVimScripts: 104 1 blockhl.vim
if !exists("g:loaded_blockhl")
 let g:loaded_blockhl= 1
else
 let g:loaded_blockhl= 2
endif
let g:blockhl_version= "v6d"

if has("gui_running")

 " ---------------------------------------------------------------------
 "  Do Once: {{{1
 if g:loaded_blockhl == 1
"  call Decho("gui_running and loaded_blockhl=".g:loaded_blockhl)
  com! -bar ToggleBlockHL call s:ToggleBlockHL()
  let s:blockhl_path    = expand("<sfile>")

" DrChip Menu Support: {{{1
  if has("gui_running") && has("menu") && &go =~ 'm'
   if !exists("g:DrChipTopLvlMenu")
	let g:DrChipTopLvlMenu= "DrChip."
   endif
   exe 'menu '.g:DrChipTopLvlMenu.'Toggle\ Block\ Highlighting<tab>:ToggleBlockHL	:ToggleBlockHL<cr>'
  endif

 " ---------------------------------------------------------------------
  " s:HLTest: tests if a highlighting group has been set up {{{2
  "         This function is used by the CursorHold below, which
  "         is there primarily to support continued blockhl
  "         highlighting after the colorscheme has been changed
  fun! s:BlockHLTest(hlname)
"  	call Dfunc("s:BlockHLTest(hlname<".a:hlname.">)")
    let id_hlname= hlID(a:hlname)
    if id_hlname == 0
"  	 call Dret("s:BlockHLTest 0 : id_hlname==0")
     return 0
    endif
    let id_trans = synIDtrans(id_hlname)
    if id_trans == 0
"  	 call Dret("s:BlockHLTest 0 : id_trans==0")
     return 0
    endif
    let fg_hlname= synIDattr(id_trans,"fg")
    let bg_hlname= synIDattr(id_trans,"bg")
    if fg_hlname == "" && bg_hlname == ""
"  	 call Dret("s:BlockHLTest 0 : fg_hlname<".fg_hlname."> bg_hlname<".bg_hlname.">")
     return 0
    endif
"  	 call Dret("s:BlockHLTest 1")
    return 1
  endfun

 " ---------------------------------------------------------------------
 " s:ToggleBlockHL: calling this function toggles indentation block-highlighting {{{2
  fun! s:ToggleBlockHL()

    if !exists("b:blockhl_enabled")
     let b:blockhl_enabled= 0
"    call Dfunc("s:ToggleBlockHL() blockhl_enabled=".b:blockhl_enabled)
    endif

    if b:blockhl_enabled
     " Disable blockhl-highlighting
     augroup AU_BlockHL
      au!
     augroup END
     augroup! AU_BlockHL
     let b:blockhl_enabled= 0
     hi clear cLead1
     hi clear cLead2
     hi clear cLead3
     hi clear cLead4
     hi clear cLead5
     hi clear cLead6
     hi clear cLead7
	 setf c

    else
     " Enable blockhl-highlighting
	 " block highlighting syntax
"     call Decho("Setting up block highlighting syntax")
	 syn cluster cCurlyGroup	  contains=cConditional,cConstant,cLabel,cOperator,cRepeat,cStatement,cStorageClass,cStructure,cType,cBitField,cCharacter,cCommentError,cInclude,cNumbers,cParenError,cPreCondit,cSpaceError,cSpecialCharacter,cSpecialError,cUserCont,cBracket,cComment,cCommentL,cCppOut,cCppString,cDefine,cMulti,cParen,cPreCondit,cPreProc,cString
	 syn cluster cParenGroup	  add=cCurly1,cCurly2,cCurly3,cCurly4,cCurly5,cCurly6,cCurly7,cLead1,cLead2,cLead3,cLead4,cLead5,cLead6,cLead7
	 syn region cCurly1			  transparent	matchgroup=Delimiter start="{" matchgroup=Delimiter end="}" contains=cLead1,cCurly2,@cCurlyGroup
	 syn region cCurly2 contained transparent   matchgroup=Delimiter start="{" matchgroup=Delimiter end="}" contains=cLead2,cCurly3,@cCurlyGroup
	 syn region cCurly3 contained transparent   matchgroup=Delimiter start="{" matchgroup=Delimiter end="}" contains=cLead3,cCurly4,@cCurlyGroup
	 syn region cCurly4 contained transparent   matchgroup=Delimiter start="{" matchgroup=Delimiter end="}" contains=cLead4,cCurly5,@cCurlyGroup
	 syn region cCurly5 contained transparent   matchgroup=Delimiter start="{" matchgroup=Delimiter end="}" contains=cLead5,cCurly6,@cCurlyGroup
	 syn region cCurly6 contained transparent   matchgroup=Delimiter start="{" matchgroup=Delimiter end="}" contains=cLead6,cCurly7,@cCurlyGroup
	 syn region cCurly7 contained transparent   matchgroup=Delimiter start="{" matchgroup=Delimiter end="}" contains=cLead7,cCurly1,@cCurlyGroup

	 syn match  cLead1  contained   "^\s\+"
	 syn match  cLead2  contained   "^\s\+"
	 syn match  cLead3  contained   "^\s\+"
	 syn match  cLead4  contained   "^\s\+"
	 syn match  cLead5  contained   "^\s\+"
	 syn match  cLead6  contained   "^\s\+"
	 syn match  cLead7  contained   "^\s\+"

     " Colorscheme change handling
     let b:blockhl_enabled = 1
"     call Decho("blockhl_path<".s:blockhl_path.">")
     if &bg == "dark"
      hi default cLead1 term=NONE cterm=NONE gui=NONE guibg=grey10
      hi default cLead2 term=NONE cterm=NONE gui=NONE guibg=grey20
      hi default cLead3 term=NONE cterm=NONE gui=NONE guibg=grey25
      hi default cLead4 term=NONE cterm=NONE gui=NONE guibg=grey30
      hi default cLead5 term=NONE cterm=NONE gui=NONE guibg=grey35
      hi default cLead6 term=NONE cterm=NONE gui=NONE guibg=grey40
      hi default cLead7 term=NONE cterm=NONE gui=NONE guibg=grey45
     else
      hi default cLead1 term=NONE cterm=NONE gui=NONE guibg=grey90
      hi default cLead2 term=NONE cterm=NONE gui=NONE guibg=grey80
      hi default cLead3 term=NONE cterm=NONE gui=NONE guibg=grey75
      hi default cLead4 term=NONE cterm=NONE gui=NONE guibg=grey70
      hi default cLead5 term=NONE cterm=NONE gui=NONE guibg=grey65
      hi default cLead6 term=NONE cterm=NONE gui=NONE guibg=grey60
      hi default cLead7 term=NONE cterm=NONE gui=NONE guibg=grey55
     endif
     augroup AU_BlockHL
      au!
      if v:version >= 700
       exe 'au ColorScheme *.c if !<SID>BlockHLTest("cLead1")|let b:blockhl_enabled=0|ToggleBlockHL|endif'
      else
       exe 'au CursorHold *.c  if !<SID>BlockHLTest("cLead1")|let b:blockhl_enabled=0|ToggleBlockHL|endif'
    endif
     augroup END
    endif

"  call Dret("s:ToggleBlockHL : blockhl_enabled=".b:blockhl_enabled)
  endfun

  " following command responsible for first turning on BlockHL highlighting
  if exists("g:blockhl_enabled") && g:blockhl_enabled
   ToggleBlockHL
  endif
 endif

" }}}1
endif
" ---------------------------------------------------------------------
" vim: ts=4 fdm=marker ft=vim
