" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
after/syntax/c/blockhl.vim	[[[1
148
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
doc/blockhl.txt	[[[1
68
*blockhl.txt*	Block Highlighting			Mar 15, 2010

Author:    Charles E. Campbell, Jr.  <NdrOchip@ScampbellPfamily.AbizM>
           (remove NOSPAM from Campbell's email first)
Copyright: (c) 2002-2010 by Charles E. Campbell, Jr.	*blockhl-copyright*
           The VIM LICENSE applies to blockhl.vim, and blockhl.txt
           (see |copyright|) except use "blockhl" instead of "Vim"
           NO WARRANTY, EXPRESS OR IMPLIED.  USE AT-YOUR-OWN-RISK.

==============================================================================
1. Contents					*blockhl-contents* {{{1

	1. Contents.................: |blockhl-contents|
	2. Manual...................: |blockhl-manual|
	3. History..................: |blockhl-history|

==============================================================================
2. Manual				*blockhl* *blockhl-manual*

This plugin modifies the highlighting for C and C++ files, producing various
colors of gray for leading white space based upon the current indentation
level.
>
 :ToggleBlockHL
<	This command toggles indentation block highlighting.
>
 DrChip.Toggle Block Highlighting
<	This menu item uses :ToggleBlockHL to toggle indentation block
	highlighting (gvim only, menus must be enabled)
>
 let g:blockhl_enabled= 1
<	This variable causes block highlighting to be enabled at startup if
	placed in one's .vimrc
>
 let g:DrChipTopLvlMenu= "DrChip."
<	This variable controls the name of the top-level menu blockhl
	produces.  The default value is shown.  You may change this by
	putting a similar line in your .vimrc with your own custom string.

==============================================================================
3. History						*blockhl-history*

 6  : Aug 29, 2008: added "default" qualifier to highlighting commands
      Mar 15, 2010: added -bar to ToggleBlockHL so the Colorscheme autocmd
                    doesn't complain
      Mar 15, 2010: if g:blockhl_enabled is 1, then this plugin will begin
                    enabled (otherwise needs :ToggleBlockHL to be enabled/disabled)
      Mar 15, 2010: added DrChip menu item
 5  : Aug 23, 2004: ToggleBlockHL() function provided which toggles
                    between block-highlighting and no such highlighting
      Apr 12, 2005  vim version 700+ now uses the ColorScheme event
                    instead of CursorHold to restore block-highlighting
                    when the colorscheme is changed
 4  : Jul 01, 2004: optionally supports entire-line rather than just
                    leading whitespace
                    uses cursorhold to restore highlighting after a
                    colorscheme change
                    bugfix: an ALLBUT in cParen caused cCurly7
                    to do inside-() highlighting.
 3  : Jun 30, 2004: now supports dark and light background settings
 2  : Jun 24, 2002: has("menu") now part of test
 1  : the epoch   :



==============================================================================
Modelines: {{{1
vim:tw=78:ts=8:ft=help:fdm=marker:
