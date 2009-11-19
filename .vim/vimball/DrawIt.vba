" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/DrawItPlugin.vim	[[[1
57
" DrawItPlugin.vim: a simple way to draw things in Vim -- just put this file in
"             your plugin directory, use \di to start (\ds to stop), and
"             just move about using the cursor keys.
"
"             You may also use visual-block mode to select endpoints and
"             draw lines, arrows, and ellipses.
"
" Date:			May 20, 2008
" Maintainer:	Charles E. Campbell, Jr.  <NdrOchipS@PcampbellAfamily.Mbiz>
" Copyright:    Copyright (C) 1999-2005 Charles E. Campbell, Jr. {{{1
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               DrawIt.vim is provided *as is* and comes with no warranty
"               of any kind, either expressed or implied. By using this
"               plugin, you agree that in no event will the copyright
"               holder be liable for any damages resulting from the use
"               of this software.
"
" Required:  this script requires Vim 7.0 (or later) {{{1
" To Enable: simply put this plugin into your ~/.vim/plugin directory {{{2
"
" GetLatestVimScripts: 40 1 :AutoInstall: DrawIt.vim
"
"  (Zeph 3:1,2 WEB) Woe to her who is rebellious and polluted, the {{{1
"  oppressing city! She didn't obey the voice. She didn't receive
"  correction.  She didn't trust in Yahweh. She didn't draw near to her God.

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_DrawItPlugin")
 finish
endif
let g:loaded_DrawItPlugin = "v11g"
let s:keepcpo             = &cpo
set cpo&vim

" ---------------------------------------------------------------------
" Public Interface: {{{1
if !hasmapto('<Plug>StartDrawIt')
  map <unique> <Leader>di <Plug>StartDrawIt
endif
map <silent> <Plug>StartDrawIt  :set lz<cr>:call DrawIt#StartDrawIt()<cr>:set nolz<cr>
com! -nargs=0 DIstart set lz|call DrawIt#StartDrawIt()|set nolz
com! -nargs=0 -bang DrawIt set lz|if <bang>0|call DrawIt#StopDrawIt()|else|call DrawIt#StartDrawIt()|endif|set nolz

if !hasmapto('<Plug>StopDrawIt')
  map <unique> <Leader>ds <Plug>StopDrawIt
endif
map <silent> <Plug>StopDrawIt :set lz<cr>:call DrawIt#StopDrawIt()<cr>:set nolz<cr>
com! -nargs=0 DIstop set lz|call DrawIt#StopDrawIt()|set nolz

" ---------------------------------------------------------------------
"  Cleanup And Modelines:
"  vim: fdm=marker
let &cpo= s:keepcpo
unlet s:keepcpo
plugin/cecutil.vim	[[[1
515
" cecutil.vim : save/restore window position
"               save/restore mark position
"               save/restore selected user maps
"  Author:	Charles E. Campbell, Jr.
"  Version:	18d	ASTRO-ONLY
"  Date:	Aug 20, 2009
"
"  Saving Restoring Destroying Marks: {{{1
"       call SaveMark(markname)       let savemark= SaveMark(markname)
"       call RestoreMark(markname)    call RestoreMark(savemark)
"       call DestroyMark(markname)
"       commands: SM RM DM
"
"  Saving Restoring Destroying Window Position: {{{1
"       call SaveWinPosn()        let winposn= SaveWinPosn()
"       call RestoreWinPosn()     call RestoreWinPosn(winposn)
"		\swp : save current window/buffer's position
"		\rwp : restore current window/buffer's previous position
"       commands: SWP RWP
"
"  Saving And Restoring User Maps: {{{1
"       call SaveUserMaps(mapmode,maplead,mapchx,suffix)
"       call RestoreUserMaps(suffix)
"
" GetLatestVimScripts: 1066 1 :AutoInstall: cecutil.vim
"
" You believe that God is one. You do well. The demons also {{{1
" believe, and shudder. But do you want to know, vain man, that
" faith apart from works is dead?  (James 2:19,20 WEB)

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_cecutil")
 finish
endif
let g:loaded_cecutil = "v18d"
let s:keepcpo        = &cpo
set cpo&vim
"DechoRemOn

" =======================
"  Public Interface: {{{1
" =======================

" ---------------------------------------------------------------------
"  Map Interface: {{{2
if !hasmapto('<Plug>SaveWinPosn')
 map <unique> <Leader>swp <Plug>SaveWinPosn
endif
if !hasmapto('<Plug>RestoreWinPosn')
 map <unique> <Leader>rwp <Plug>RestoreWinPosn
endif
nmap <silent> <Plug>SaveWinPosn		:call SaveWinPosn()<CR>
nmap <silent> <Plug>RestoreWinPosn	:call RestoreWinPosn()<CR>

" ---------------------------------------------------------------------
" Command Interface: {{{2
com! -bar -nargs=0 SWP	call SaveWinPosn()
com! -bar -nargs=0 RWP	call RestoreWinPosn()
com! -bar -nargs=1 SM	call SaveMark(<q-args>)
com! -bar -nargs=1 RM	call RestoreMark(<q-args>)
com! -bar -nargs=1 DM	call DestroyMark(<q-args>)

if v:version < 630
 let s:modifier= "sil "
else
 let s:modifier= "sil keepj "
endif

" ===============
" Functions: {{{1
" ===============

" ---------------------------------------------------------------------
" SaveWinPosn: {{{2
"    let winposn= SaveWinPosn()  will save window position in winposn variable
"    call SaveWinPosn()          will save window position in b:cecutil_winposn{b:cecutil_iwinposn}
"    let winposn= SaveWinPosn(0) will *only* save window position in winposn variable (no stacking done)
fun! SaveWinPosn(...)
"  echomsg "Decho: SaveWinPosn() a:0=".a:0
  if line(".") == 1 && getline(1) == ""
"   echomsg "Decho: SaveWinPosn : empty buffer"
   return ""
  endif
  let so_keep   = &l:so
  let siso_keep = &siso
  let ss_keep   = &l:ss
  setlocal so=0 siso=0 ss=0

  let swline    = line(".")                        " save-window line in file
  let swcol     = col(".")                         " save-window column in file
  if swcol >= col("$")
   let swcol= swcol + virtcol(".") - virtcol("$")  " adjust for virtual edit (cursor past end-of-line)
  endif
  let swwline   = winline() - 1                    " save-window window line
  let swwcol    = virtcol(".") - wincol()          " save-window window column
"  echomsg "Decho: sw[".swline.",".swcol."] sww[".swwline.",".swwcol."]"
  let savedposn = "call GoWinbufnr(".winbufnr(0).")|silent ".swline
  let savedposn = savedposn."|".s:modifier."norm! 0z\<cr>"
  if swwline > 0
"   let savedposn= savedposn.":".s:modifier."norm! ".swwline."\<c-y>\<cr>"
   let savedposn= savedposn.":while winline() != ".(swwline+1)."\<bar>".s:modifier."norm! \<c-y>\<cr>\<bar>endwhile\<cr>"
  endif
  if swwcol > 0
   let savedposn= savedposn.":".s:modifier."norm! 0".swwcol."zl\<cr>"
  endif
  let savedposn = savedposn.":".s:modifier."call cursor(".swline.",".swcol.")\<cr>"

  " save window position in
  " b:cecutil_winposn_{iwinposn} (stack)
  " only when SaveWinPosn() is used
  if a:0 == 0
   if !exists("b:cecutil_iwinposn")
    let b:cecutil_iwinposn= 1
   else
    let b:cecutil_iwinposn= b:cecutil_iwinposn + 1
   endif
"   echomsg "Decho: saving posn to SWP stack"
   let b:cecutil_winposn{b:cecutil_iwinposn}= savedposn
  endif

  let &l:so = so_keep
  let &siso = siso_keep
  let &l:ss = ss_keep

"  if exists("b:cecutil_iwinposn")                                                                  " Decho
"   echomsg "Decho: b:cecutil_winpos{".b:cecutil_iwinposn."}[".b:cecutil_winposn{b:cecutil_iwinposn}."]"
"  else                                                                                             " Decho
"   echomsg "Decho: b:cecutil_iwinposn doesn't exist"
"  endif                                                                                            " Decho
"  echomsg "Decho: SaveWinPosn [".savedposn."]"
  return savedposn
endfun

" ---------------------------------------------------------------------
" RestoreWinPosn: {{{2
"      call RestoreWinPosn()
"      call RestoreWinPosn(winposn)
fun! RestoreWinPosn(...)
"  call Dfunc("RestoreWinPosn() a:0=".a:0)
"  call Decho("getline(1)<".getline(1).">")
"  call Decho("line(.)=".line("."))
  if line(".") == 1 && getline(1) == ""
"   call Dfunc("RestoreWinPosn : empty buffer")
   return ""
  endif
  let so_keep   = &l:so
  let siso_keep = &l:siso
  let ss_keep   = &l:ss
  setlocal so=0 siso=0 ss=0

  if a:0 == 0 || a:1 == ""
   " use saved window position in b:cecutil_winposn{b:cecutil_iwinposn} if it exists
   if exists("b:cecutil_iwinposn") && exists("b:cecutil_winposn{b:cecutil_iwinposn}")
"   	call Decho("using stack b:cecutil_winposn{".b:cecutil_iwinposn."}<".b:cecutil_winposn{b:cecutil_iwinposn}.">")
	try
     exe "silent! ".b:cecutil_winposn{b:cecutil_iwinposn}
	catch /^Vim\%((\a\+)\)\=:E749/
	 " ignore empty buffer error messages
	endtry
    " normally drop top-of-stack by one
    " but while new top-of-stack doesn't exist
    " drop top-of-stack index by one again
	if b:cecutil_iwinposn >= 1
	 unlet b:cecutil_winposn{b:cecutil_iwinposn}
	 let b:cecutil_iwinposn= b:cecutil_iwinposn - 1
	 while b:cecutil_iwinposn >= 1 && !exists("b:cecutil_winposn{b:cecutil_iwinposn}")
	  let b:cecutil_iwinposn= b:cecutil_iwinposn - 1
	 endwhile
	 if b:cecutil_iwinposn < 1
	  unlet b:cecutil_iwinposn
	 endif
	endif
   else
   	echohl WarningMsg
	echomsg "***warning*** need to SaveWinPosn first!"
	echohl None
   endif

  else	 " handle input argument
"   call Decho("using input a:1<".a:1.">")
   " use window position passed to this function
   exe "silent ".a:1
   " remove a:1 pattern from b:cecutil_winposn{b:cecutil_iwinposn} stack
   if exists("b:cecutil_iwinposn")
    let jwinposn= b:cecutil_iwinposn
    while jwinposn >= 1                     " search for a:1 in iwinposn..1
        if exists("b:cecutil_winposn{jwinposn}")    " if it exists
         if a:1 == b:cecutil_winposn{jwinposn}      " and the pattern matches
       unlet b:cecutil_winposn{jwinposn}            " unlet it
       if jwinposn == b:cecutil_iwinposn            " if at top-of-stack
        let b:cecutil_iwinposn= b:cecutil_iwinposn - 1      " drop stacktop by one
       endif
      endif
     endif
     let jwinposn= jwinposn - 1
    endwhile
   endif
  endif

  " Seems to be something odd: vertical motions after RWP
  " cause jump to first column.  The following fixes that.
  " Note: was using wincol()>1, but with signs, a cursor
  " at column 1 yields wincol()==3.  Beeping ensued.
  if virtcol('.') > 1
   silent norm! hl
  elseif virtcol(".") < virtcol("$")
   silent norm! lh
  endif

  let &l:so   = so_keep
  let &l:siso = siso_keep
  let &l:ss   = ss_keep

"  call Dret("RestoreWinPosn")
endfun

" ---------------------------------------------------------------------
" GoWinbufnr: go to window holding given buffer (by number) {{{2
"   Prefers current window; if its buffer number doesn't match,
"   then will try from topleft to bottom right
fun! GoWinbufnr(bufnum)
"  call Dfunc("GoWinbufnr(".a:bufnum.")")
  if winbufnr(0) == a:bufnum
"   call Dret("GoWinbufnr : winbufnr(0)==a:bufnum")
   return
  endif
  winc t
  let first=1
  while winbufnr(0) != a:bufnum && (first || winnr() != 1)
  	winc w
	let first= 0
   endwhile
"  call Dret("GoWinbufnr")
endfun

" ---------------------------------------------------------------------
" SaveMark: sets up a string saving a mark position. {{{2
"           For example, SaveMark("a")
"           Also sets up a global variable, g:savemark_{markname}
fun! SaveMark(markname)
"  call Dfunc("SaveMark(markname<".a:markname.">)")
  let markname= a:markname
  if strpart(markname,0,1) !~ '\a'
   let markname= strpart(markname,1,1)
  endif
"  call Decho("markname=".markname)

  let lzkeep  = &lz
  set lz

  if 1 <= line("'".markname) && line("'".markname) <= line("$")
   let winposn               = SaveWinPosn(0)
   exe s:modifier."norm! `".markname
   let savemark              = SaveWinPosn(0)
   let g:savemark_{markname} = savemark
   let savemark              = markname.savemark
   call RestoreWinPosn(winposn)
  else
   let g:savemark_{markname} = ""
   let savemark              = ""
  endif

  let &lz= lzkeep

"  call Dret("SaveMark : savemark<".savemark.">")
  return savemark
endfun

" ---------------------------------------------------------------------
" RestoreMark: {{{2
"   call RestoreMark("a")  -or- call RestoreMark(savemark)
fun! RestoreMark(markname)
"  call Dfunc("RestoreMark(markname<".a:markname.">)")

  if strlen(a:markname) <= 0
"   call Dret("RestoreMark : no such mark")
   return
  endif
  let markname= strpart(a:markname,0,1)
  if markname !~ '\a'
   " handles 'a -> a styles
   let markname= strpart(a:markname,1,1)
  endif
"  call Decho("markname=".markname." strlen(a:markname)=".strlen(a:markname))

  let lzkeep  = &lz
  set lz
  let winposn = SaveWinPosn(0)

  if strlen(a:markname) <= 2
   if exists("g:savemark_{markname}") && strlen(g:savemark_{markname}) != 0
	" use global variable g:savemark_{markname}
"	call Decho("use savemark list")
	call RestoreWinPosn(g:savemark_{markname})
	exe "norm! m".markname
   endif
  else
   " markname is a savemark command (string)
"	call Decho("use savemark command")
   let markcmd= strpart(a:markname,1)
   call RestoreWinPosn(markcmd)
   exe "norm! m".markname
  endif

  call RestoreWinPosn(winposn)
  let &lz       = lzkeep

"  call Dret("RestoreMark")
endfun

" ---------------------------------------------------------------------
" DestroyMark: {{{2
"   call DestroyMark("a")  -- destroys mark
fun! DestroyMark(markname)
"  call Dfunc("DestroyMark(markname<".a:markname.">)")

  " save options and set to standard values
  let reportkeep= &report
  let lzkeep    = &lz
  set lz report=10000

  let markname= strpart(a:markname,0,1)
  if markname !~ '\a'
   " handles 'a -> a styles
   let markname= strpart(a:markname,1,1)
  endif
"  call Decho("markname=".markname)

  let curmod  = &mod
  let winposn = SaveWinPosn(0)
  1
  let lineone = getline(".")
  exe "k".markname
  d
  put! =lineone
  let &mod    = curmod
  call RestoreWinPosn(winposn)

  " restore options to user settings
  let &report = reportkeep
  let &lz     = lzkeep

"  call Dret("DestroyMark")
endfun

" ---------------------------------------------------------------------
" QArgSplitter: to avoid \ processing by <f-args>, <q-args> is needed. {{{2
" However, <q-args> doesn't split at all, so this one returns a list
" with splits at all whitespace (only!), plus a leading length-of-list.
" The resulting list:  qarglist[0] corresponds to a:0
"                      qarglist[i] corresponds to a:{i}
fun! QArgSplitter(qarg)
"  call Dfunc("QArgSplitter(qarg<".a:qarg.">)")
  let qarglist    = split(a:qarg)
  let qarglistlen = len(qarglist)
  let qarglist    = insert(qarglist,qarglistlen)
"  call Dret("QArgSplitter ".string(qarglist))
  return qarglist
endfun

" ---------------------------------------------------------------------
" ListWinPosn: {{{2
"fun! ListWinPosn()                                                        " Decho 
"  if !exists("b:cecutil_iwinposn") || b:cecutil_iwinposn == 0             " Decho 
"   call Decho("nothing on SWP stack")                                     " Decho
"  else                                                                    " Decho
"   let jwinposn= b:cecutil_iwinposn                                       " Decho 
"   while jwinposn >= 1                                                    " Decho 
"    if exists("b:cecutil_winposn{jwinposn}")                              " Decho 
"     call Decho("winposn{".jwinposn."}<".b:cecutil_winposn{jwinposn}.">") " Decho 
"    else                                                                  " Decho 
"     call Decho("winposn{".jwinposn."} -- doesn't exist")                 " Decho 
"    endif                                                                 " Decho 
"    let jwinposn= jwinposn - 1                                            " Decho 
"   endwhile                                                               " Decho 
"  endif                                                                   " Decho
"endfun                                                                    " Decho 
"com! -nargs=0 LWP	call ListWinPosn()                                    " Decho 

" ---------------------------------------------------------------------
" SaveUserMaps: this function sets up a script-variable (s:restoremap) {{{2
"          which can be used to restore user maps later with
"          call RestoreUserMaps()
"
"          mapmode - see :help maparg for details (n v o i c l "")
"                    ex. "n" = Normal
"                    The letters "b" and "u" are optional prefixes;
"                    The "u" means that the map will also be unmapped
"                    The "b" means that the map has a <buffer> qualifier
"                    ex. "un"  = Normal + unmapping
"                    ex. "bn"  = Normal + <buffer>
"                    ex. "bun" = Normal + <buffer> + unmapping
"                    ex. "ubn" = Normal + <buffer> + unmapping
"          maplead - see mapchx
"          mapchx  - "<something>" handled as a single map item.
"                    ex. "<left>"
"                  - "string" a string of single letters which are actually
"                    multiple two-letter maps (using the maplead:
"                    maplead . each_character_in_string)
"                    ex. maplead="\" and mapchx="abc" saves user mappings for
"                        \a, \b, and \c
"                    Of course, if maplead is "", then for mapchx="abc",
"                    mappings for a, b, and c are saved.
"                  - :something  handled as a single map item, w/o the ":"
"                    ex.  mapchx= ":abc" will save a mapping for "abc"
"          suffix  - a string unique to your plugin
"                    ex.  suffix= "DrawIt"
fun! SaveUserMaps(mapmode,maplead,mapchx,suffix)
"  call Dfunc("SaveUserMaps(mapmode<".a:mapmode."> maplead<".a:maplead."> mapchx<".a:mapchx."> suffix<".a:suffix.">)")

  if !exists("s:restoremap_{a:suffix}")
   " initialize restoremap_suffix to null string
   let s:restoremap_{a:suffix}= ""
  endif

  " set up dounmap: if 1, then save and unmap  (a:mapmode leads with a "u")
  "                 if 0, save only
  let mapmode  = a:mapmode
  let dounmap  = 0
  let dobuffer = ""
  while mapmode =~ '^[bu]'
   if     mapmode =~ '^u'
    let dounmap = 1
    let mapmode = strpart(a:mapmode,1)
   elseif mapmode =~ '^b'
    let dobuffer = "<buffer> "
    let mapmode  = strpart(a:mapmode,1)
   endif
  endwhile
"  call Decho("dounmap=".dounmap."  dobuffer<".dobuffer.">")
 
  " save single map :...something...
  if strpart(a:mapchx,0,1) == ':'
"   call Decho("save single map :...something...")
   let amap= strpart(a:mapchx,1)
   if amap == "|" || amap == "\<c-v>"
    let amap= "\<c-v>".amap
   endif
   let amap                    = a:maplead.amap
   let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|:silent! ".mapmode."unmap ".dobuffer.amap
   if maparg(amap,mapmode) != ""
    let maprhs                  = substitute(maparg(amap,mapmode),'|','<bar>','ge')
	let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|:".mapmode."map ".dobuffer.amap." ".maprhs
   endif
   if dounmap
	exe "silent! ".mapmode."unmap ".dobuffer.amap
   endif
 
  " save single map <something>
  elseif strpart(a:mapchx,0,1) == '<'
"   call Decho("save single map <something>")
   let amap       = a:mapchx
   if amap == "|" || amap == "\<c-v>"
    let amap= "\<c-v>".amap
"	call Decho("amap[[".amap."]]")
   endif
   let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|silent! ".mapmode."unmap ".dobuffer.amap
   if maparg(a:mapchx,mapmode) != ""
    let maprhs                  = substitute(maparg(amap,mapmode),'|','<bar>','ge')
	let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|".mapmode."map ".dobuffer.amap." ".maprhs
   endif
   if dounmap
	exe "silent! ".mapmode."unmap ".dobuffer.amap
   endif
 
  " save multiple maps
  else
"   call Decho("save multiple maps")
   let i= 1
   while i <= strlen(a:mapchx)
    let amap= a:maplead.strpart(a:mapchx,i-1,1)
	if amap == "|" || amap == "\<c-v>"
	 let amap= "\<c-v>".amap
	endif
	let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|silent! ".mapmode."unmap ".dobuffer.amap
    if maparg(amap,mapmode) != ""
     let maprhs                  = substitute(maparg(amap,mapmode),'|','<bar>','ge')
	 let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|".mapmode."map ".dobuffer.amap." ".maprhs
    endif
	if dounmap
	 exe "silent! ".mapmode."unmap ".dobuffer.amap
	endif
    let i= i + 1
   endwhile
  endif
"  call Dret("SaveUserMaps : restoremap_".a:suffix.": ".s:restoremap_{a:suffix})
endfun

" ---------------------------------------------------------------------
" RestoreUserMaps: {{{2
"   Used to restore user maps saved by SaveUserMaps()
fun! RestoreUserMaps(suffix)
"  call Dfunc("RestoreUserMaps(suffix<".a:suffix.">)")
  if exists("s:restoremap_{a:suffix}")
   let s:restoremap_{a:suffix}= substitute(s:restoremap_{a:suffix},'|\s*$','','e')
   if s:restoremap_{a:suffix} != ""
"   	call Decho("exe ".s:restoremap_{a:suffix})
    exe "silent! ".s:restoremap_{a:suffix}
   endif
   unlet s:restoremap_{a:suffix}
  endif
"  call Dret("RestoreUserMaps")
endfun

" ==============
"  Restore: {{{1
" ==============
let &cpo= s:keepcpo
unlet s:keepcpo

" ================
"  Modelines: {{{1
" ================
" vim: ts=4 fdm=marker
autoload/DrawIt.vim	[[[1
1775
" DrawIt.vim: a simple way to draw things in Vim
"
" Maintainer:	Charles E. Campbell, Jr.
" Authors:	Charles E. Campbell, Jr. <NdrOchipS@PcampbellAfamily.Mbiz> - NOSPAM
"   		Sylvain Viart (molo@multimania.com)
" Version:	11g	ASTRO-ONLY
" Date:		Sep 02, 2009
"
" Quick Setup: {{{1
"              tar -oxvf DrawIt.tar
"              Should put DrawItPlugin.vim in your .vim/plugin directory,
"                     put DrawIt.vim       in your .vim/autoload directory
"                     put DrawIt.txt       in your .vim/doc directory.
"             Then, use \di to start DrawIt,
"                       \ds to stop  Drawit, and
"                       draw by simply moving about using the cursor keys.
"
"             You may also use visual-block mode to select endpoints and
"             draw lines, arrows, and ellipses.
"
" Copyright:    Copyright (C) 1999-2005 Charles E. Campbell, Jr. {{{1
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               DrawIt.vim is provided *as is* and comes with no warranty
"               of any kind, either expressed or implied. By using this
"               plugin, you agree that in no event will the copyright
"               holder be liable for any damages resulting from the use
"               of this software.
"
" Required:		THIS SCRIPT REQUIRES VIM 7.0 (or later) {{{1
" GetLatestVimScripts: 40 1 :AutoInstall: DrawIt.vim
" GetLatestVimScripts: 1066 1 cecutil.vim
"
"  Woe to her who is rebellious and polluted, the oppressing {{{1
"  city! She didn't obey the voice. She didn't receive correction.
"  She didn't trust in Yahweh. She didn't draw near to her God. (Zeph 3:1,2 WEB)

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_DrawIt")
 finish
endif
let g:loaded_DrawIt= "v11g"
if v:version < 700
 echohl WarningMsg
 echo "***warning*** this version of DrawIt needs vim 7.0"
 echohl Normal
 finish
endif
let s:keepcpo= &cpo
set cpo&vim

if !exists("g:drawit_xstrlen")
 if &enc == "latin1" || $LANG == "en_US.UTF-8" || !has("multi_byte")
  let g:drawit_xstrlen= 0
 else
  let g:drawit_xstrlen= 1
 endif
endif

" ---------------------------------------------------------------------
" DrChip Menu Support: {{{1
if has("gui_running") && has("menu") && &go =~ 'm'
 if !exists("g:DrChipTopLvlMenu")
  let g:DrChipTopLvlMenu= "DrChip."
 endif
 exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Start\ DrawIt<tab>\\di		<Leader>di'
endif

" ---------------------------------------------------------------------
"  Script Variables: {{{1
if !exists("s:saveposn_count")
 let s:saveposn_count= 0
endif
"DechoTabOn

" =====================================================================
" DrawIt Functions: (by Charles E. Campbell, Jr.) {{{1
" =====================================================================

" ---------------------------------------------------------------------
" DrawIt#StartDrawIt: this function maps the cursor keys, sets up default {{{2
"              drawing characters, and makes some settings
fun! DrawIt#StartDrawIt()
"  call Dfunc("StartDrawIt()")

  " StartDrawIt: report on [DrawIt] mode {{{3
  if exists("b:dodrawit") && b:dodrawit == 1
   " already in DrawIt mode
    echo "[DrawIt] (already on, use ".((exists("mapleader") && mapleader != "")? mapleader : '\')."ds to stop)"
"   call Dret("StartDrawIt")
   return
  endif
  let b:dodrawit= 1

  " indicate in DrawIt mode
  echo "[DrawIt]"

  " StartDrawIt: turn on mouse {{{3
  if !exists("b:drawit_keep_mouse")
   let b:drawit_keep_mouse= &mouse
  endif
  setlocal mouse=a

  " StartDrawIt: set up type of strlen() calculation that's needed {{{3
  if !exists("g:drawit_xstrlen")
   if exists("g:Align_xstrlen")
    let g:drawit_xstrlen= g:Align_xstrlen
   endif
   if !exists("g:drawit_xstrlen")
    let g:drawit_xstrlen= 1
   endif
  endif

  " StartDrawIt: set up DrawIt commands {{{3
  com! -nargs=1 -range SetBrush <line1>,<line2>call DrawIt#SetBrush(<q-args>)
  com! -count Canvas call s:Spacer(line("."),line(".") + <count> - 1,0)

  " StartDrawIt: set up default drawing characters {{{3
  if !exists("b:di_vert")
   let b:di_vert= "|"
  endif
  if !exists("b:di_horiz")
   let b:di_horiz= "-"
  endif
  if !exists("b:di_plus")
   let b:di_plus= "+"
  endif
  if !exists("b:di_upright")  " also downleft
   let b:di_upright= "/"
  endif
  if !exists("b:di_upleft")   " also downright
   let b:di_upleft= "\\"
  endif
  if !exists("b:di_cross")
   let b:di_cross= "X"
  endif
  if !exists("b:di_ellipse")
   let b:di_ellipse= '*'
  endif

  " set up initial DrawIt behavior (as opposed to erase behavior)
  let b:di_erase     = 0

  " StartDrawIt: option recording {{{3
  let b:di_aikeep    = &l:ai
  let b:di_cinkeep   = &l:cin
  let b:di_cpokeep   = &l:cpo
  let b:di_etkeep    = &l:et
  let b:di_fokeep    = &l:fo
  let b:di_gdkeep    = &l:gd
  let b:di_gokeep    = &l:go
  let b:di_magickeep = &l:magic
  let b:di_remapkeep = &l:remap
  let b:di_repkeep   = &l:report
  let b:di_sikeep    = &l:si
  let b:di_stakeep   = &l:sta
  let b:di_vekeep    = &l:ve
  setlocal cpo&vim
  setlocal nocin noai nosi nogd sta et ve=all report=10000
  setlocal go-=aA
  setlocal fo-=a
  setlocal remap magic

  " StartDrawIt: save and unmap user maps {{{3
  let b:lastdir    = 1
  if exists("mapleader")
   let usermaplead  = mapleader
  else
   let usermaplead  = "\\"
  endif
  call SaveUserMaps("bn","","><^v","DrawIt")
  call SaveUserMaps("bv",usermaplead,"abceflsy","DrawIt")
  call SaveUserMaps("bn","","<c-v>","DrawIt")
  call SaveUserMaps("bn",usermaplead,"h><v^","DrawIt")
  call SaveUserMaps("bn","","<left>","DrawIt")
  call SaveUserMaps("bn","","<right>","DrawIt")
  call SaveUserMaps("bn","","<up>","DrawIt")
  call SaveUserMaps("bn","","<down>","DrawIt")
  call SaveUserMaps("bn","","<left>","DrawIt")
  call SaveUserMaps("bn","","<s-right>","DrawIt")
  call SaveUserMaps("bn","","<s-up>","DrawIt")
  call SaveUserMaps("bn","","<s-down>","DrawIt")
  call SaveUserMaps("bn","","<space>","DrawIt")
  call SaveUserMaps("bn","","<home>","DrawIt")
  call SaveUserMaps("bn","","<end>","DrawIt")
  call SaveUserMaps("bn","","<pageup>","DrawIt")
  call SaveUserMaps("bn","","<pagedown>","DrawIt")
  call SaveUserMaps("bn","","<c-leftdrag>","DrawIt")
  call SaveUserMaps("bn","","<c-leftmouse>","DrawIt")
  call SaveUserMaps("bn","","<c-leftrelease>","DrawIt")
  call SaveUserMaps("bn","","<leftdrag>","DrawIt")
  call SaveUserMaps("bn","","<leftmouse>","DrawIt")
  call SaveUserMaps("bn","","<middlemouse>","DrawIt")
  call SaveUserMaps("bn","","<rightmouse>","DrawIt")
  call SaveUserMaps("bn","","<s-leftdrag>","DrawIt")
  call SaveUserMaps("bn","","<s-leftmouse>","DrawIt")
  call SaveUserMaps("bn","","<s-leftrelease>","DrawIt")
  call SaveUserMaps("bv","","<c-leftmouse>","DrawIt")
  call SaveUserMaps("bv","","<leftmouse>","DrawIt")
  call SaveUserMaps("bv","","<middlemouse>","DrawIt")
  call SaveUserMaps("bv","","<rightmouse>","DrawIt")
  call SaveUserMaps("bv","","<s-leftmouse>","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pa","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pb","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pc","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pd","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pe","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pf","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pg","DrawIt")
  call SaveUserMaps("bn",usermaplead,":ph","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pi","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pj","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pk","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pl","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pm","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pn","DrawIt")
  call SaveUserMaps("bn",usermaplead,":po","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pp","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pq","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pr","DrawIt")
  call SaveUserMaps("bn",usermaplead,":ps","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pt","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pu","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pv","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pw","DrawIt")
  call SaveUserMaps("bn",usermaplead,":px","DrawIt")
  call SaveUserMaps("bn",usermaplead,":py","DrawIt")
  call SaveUserMaps("bn",usermaplead,":pz","DrawIt")
  call SaveUserMaps("bn",usermaplead,":ra","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rb","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rc","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rd","DrawIt")
  call SaveUserMaps("bn",usermaplead,":re","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rf","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rg","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rh","DrawIt")
  call SaveUserMaps("bn",usermaplead,":ri","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rj","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rk","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rl","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rm","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rn","DrawIt")
  call SaveUserMaps("bn",usermaplead,":ro","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rp","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rq","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rr","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rs","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rt","DrawIt")
  call SaveUserMaps("bn",usermaplead,":ru","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rv","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rw","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rx","DrawIt")
  call SaveUserMaps("bn",usermaplead,":ry","DrawIt")
  call SaveUserMaps("bn",usermaplead,":rz","DrawIt")
  if exists("g:drawit_insertmode") && g:drawit_insertmode
   call SaveUserMaps("bi","","<left>","DrawIt")
   call SaveUserMaps("bi","","<right>","DrawIt")
   call SaveUserMaps("bi","","<up>","DrawIt")
   call SaveUserMaps("bi","","<down>","DrawIt")
   call SaveUserMaps("bi","","<left>","DrawIt")
   call SaveUserMaps("bi","","<s-right>","DrawIt")
   call SaveUserMaps("bi","","<s-up>","DrawIt")
   call SaveUserMaps("bi","","<s-down>","DrawIt")
   call SaveUserMaps("bi","","<home>","DrawIt")
   call SaveUserMaps("bi","","<end>","DrawIt")
   call SaveUserMaps("bi","","<pageup>","DrawIt")
   call SaveUserMaps("bi","","<pagedown>","DrawIt")
   call SaveUserMaps("bi","","<leftmouse>","DrawIt")
  endif
  call SaveUserMaps("bn","",":\<c-v>","DrawIt")

  " StartDrawIt: DrawIt maps (Charles Campbell) {{{3
  nmap <silent> <buffer> <script> <left>     :set lz<CR>:silent! call <SID>DrawLeft()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <right>    :set lz<CR>:silent! call <SID>DrawRight()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <up>       :set lz<CR>:silent! call <SID>DrawUp()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <down>     :set lz<CR>:silent! call <SID>DrawDown()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <s-left>   :set lz<CR>:silent! call <SID>MoveLeft()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <s-right>  :set lz<CR>:silent! call <SID>MoveRight()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <s-up>     :set lz<CR>:silent! call <SID>MoveUp()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <s-down>   :set lz<CR>:silent! call <SID>MoveDown()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <space>    :set lz<CR>:silent! call <SID>DrawErase()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> >          :set lz<CR>:silent! call <SID>DrawSpace('>',1)<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <          :set lz<CR>:silent! call <SID>DrawSpace('<',2)<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> ^          :set lz<CR>:silent! call <SID>DrawSpace('^',3)<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> v          :set lz<CR>:silent! call <SID>DrawSpace('v',4)<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <home>     :set lz<CR>:silent! call <SID>DrawSlantUpLeft()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <end>      :set lz<CR>:silent! call <SID>DrawSlantDownLeft()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <pageup>   :set lz<CR>:silent! call <SID>DrawSlantUpRight()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <pagedown> :set lz<CR>:silent! call <SID>DrawSlantDownRight()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <Leader>>	:set lz<CR>:silent! call <SID>DrawFatRArrow()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <Leader><	:set lz<CR>:silent! call <SID>DrawFatLArrow()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <Leader>^	:set lz<CR>:silent! call <SID>DrawFatUArrow()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <Leader>v	:set lz<CR>:silent! call <SID>DrawFatDArrow()<CR>:set nolz<CR>
  nmap <silent> <buffer> <script> <Leader>f  :call <SID>Flood()<cr>

  " StartDrawIt: Set up insertmode maps {{{3
  if exists("g:drawit_insertmode") && g:drawit_insertmode
   imap <silent> <buffer> <script> <left>     <Esc><left>a
   imap <silent> <buffer> <script> <right>    <Esc><right>a
   imap <silent> <buffer> <script> <up>       <Esc><up>a
   imap <silent> <buffer> <script> <down>     <Esc><down>a
   imap <silent> <buffer> <script> <left>     <Esc><left>a
   imap <silent> <buffer> <script> <s-right>  <Esc><s-right>a
   imap <silent> <buffer> <script> <s-up>     <Esc><s-up>a
   imap <silent> <buffer> <script> <s-down>   <Esc><s-down>a
   imap <silent> <buffer> <script> <home>     <Esc><home>a
   imap <silent> <buffer> <script> <end>      <Esc><end>a
   imap <silent> <buffer> <script> <pageup>   <Esc><pageup>a
   imap <silent> <buffer> <script> <pagedown> <Esc><pagedown>a
  endif

  " StartDrawIt: set up drawing mode mappings (Sylvain Viart) {{{3
  nnoremap <silent> <buffer> <script> <c-v>      :call <SID>LeftStart()<CR><c-v>
  vmap     <silent> <buffer> <script> <Leader>a  :<c-u>call <SID>CallBox('Arrow')<CR>
  vmap     <silent> <buffer> <script> <Leader>b  :<c-u>call <SID>CallBox('DrawBox')<cr>
  nmap              <buffer> <script> <Leader>c  :call <SID>Canvas()<cr>
  vmap     <silent> <buffer> <script> <Leader>l  :<c-u>call <SID>CallBox('DrawPlainLine')<CR>
  vmap     <silent> <buffer> <script> <Leader>s  :<c-u>call <SID>Spacer(line("'<"), line("'>"),0)<cr>

  " StartDrawIt: set up drawing mode mappings (Charles Campbell) {{{3
  " \pa ... \pz : blanks are transparent
  " \ra ... \rz : blanks copy over
  vmap <buffer> <silent> <Leader>e   :<c-u>call <SID>CallBox('DrawEllipse')<CR>
  
  let allreg= "abcdefghijklmnopqrstuvwxyz"
  while strlen(allreg) > 0
   let ireg= strpart(allreg,0,1)
   exe "nmap <silent> <buffer> <Leader>p".ireg.'  :<c-u>set lz<cr>:silent! call <SID>PutBlock("'.ireg.'",0)<cr>:set nolz<cr>'
   exe "nmap <silent> <buffer> <Leader>r".ireg.'  :<c-u>set lz<cr>:silent! call <SID>PutBlock("'.ireg.'",1)<cr>:set nolz<cr>'
   let allreg= strpart(allreg,1)
  endwhile

  " StartDrawIt: mouse maps  (Sylvain Viart) {{{3
  " start visual-block with leftmouse
  nnoremap <silent> <buffer> <script> <leftmouse>    <leftmouse>:call <SID>LeftStart()<CR><c-v>
  vnoremap <silent> <buffer> <script> <rightmouse>   <leftmouse>:<c-u>call <SID>RightStart(1)<cr>
  vnoremap <silent> <buffer> <script> <middlemouse>  <leftmouse>:<c-u>call <SID>RightStart(0)<cr>
  vnoremap <silent> <buffer> <script> <c-leftmouse>  <leftmouse>:<c-u>call <SID>CLeftStart()<cr>

  " StartDrawIt: mouse maps (Charles Campbell) {{{3
  " Draw with current brush
  nnoremap <silent> <buffer> <script> <s-leftmouse>  <leftmouse>:call <SID>SLeftStart()<CR><c-v>
  nnoremap <silent> <buffer> <script> <c-leftmouse>  <leftmouse>:call <SID>CLeftStart()<CR><c-v>

 " StartDrawIt: Menu support {{{3
 if has("gui_running") && has("menu") && &go =~ 'm'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Stop\ \ DrawIt<tab>\\ds				<Leader>ds'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Toggle\ Erase\ Mode<tab><space>	<space>'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Arrow<tab>\\a					<Leader>a'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Box<tab>\\b						<Leader>b'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Make\ Blank\ Zone<tab>\\c			<Leader>c'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Ellipse<tab>\\e					<Leader>e'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Flood<tab>\\e					<Leader>f'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Line<tab>\\l						<Leader>l'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Append\ Blanks<tab>\\s				<Leader>s'
  exe 'silent! unmenu '.g:DrChipTopLvlMenu.'DrawIt.Start\ DrawIt'
 endif
" call Dret("StartDrawIt")
endfun

" ---------------------------------------------------------------------
" DrawIt#StopDrawIt: this function unmaps the cursor keys and restores settings {{{2
fun! DrawIt#StopDrawIt()
"  call Dfunc("StopDrawIt()")
 
  " StopDrawIt: report on [DrawIt off] mode {{{3
  if !exists("b:dodrawit")
   echo "[DrawIt off]"
"   call Dret("StopDrawIt")
   return
  endif

  " StopDrawIt: restore mouse {{{3
  if exists("b:drawit_keep_mouse")
   let &mouse= b:drawit_keep_mouse
   unlet b:drawit_keep_mouse
  endif
  unlet b:dodrawit
  echo "[DrawIt off]"

  if exists("b:drawit_canvas_used")
   " StopDrawIt: clean up trailing white space {{{3
   call s:SavePosn()
   silent! %s/\s\+$//e
   unlet b:drawit_canvas_used
   call s:RestorePosn()
  endif

  " StopDrawIt: remove drawit commands {{{3
  delc SetBrush

  " StopDrawIt: insure that erase mode is off {{{3
  " (thanks go to Gary Johnson for this)
  if b:di_erase == 1
  	call s:DrawErase()
  endif

  " StopDrawIt: restore user map(s), if any {{{3
  call RestoreUserMaps("DrawIt")

  " StopDrawIt: restore user's options {{{3
  let &l:ai     = b:di_aikeep
  let &l:cin    = b:di_cinkeep
  let &l:cpo    = b:di_cpokeep
  let &l:et     = b:di_etkeep
  let &l:fo     = b:di_fokeep
  let &l:gd     = b:di_gdkeep
  let &l:go     = b:di_gokeep
  let &l:magic  = b:di_magickeep
  let &l:remap  = b:di_remapkeep
  let &l:report = b:di_repkeep
  let &l:si     = b:di_sikeep
  let &l:sta    = b:di_stakeep
  let &l:ve     = b:di_vekeep
  unlet b:di_aikeep  
  unlet b:di_cinkeep 
  unlet b:di_cpokeep 
  unlet b:di_etkeep  
  unlet b:di_fokeep  
  unlet b:di_gdkeep  
  unlet b:di_gokeep  
  unlet b:di_magickeep
  unlet b:di_remapkeep
  unlet b:di_repkeep
  unlet b:di_sikeep  
  unlet b:di_stakeep 
  unlet b:di_vekeep  

 " StopDrawIt: DrChip menu support: {{{3
 if has("gui_running") && has("menu") && &go =~ 'm'
  exe 'menu   '.g:DrChipTopLvlMenu.'DrawIt.Start\ DrawIt<tab>\\di		<Leader>di'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Stop\ \ DrawIt'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Toggle\ Erase\ Mode'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Arrow'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Box'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Ellipse'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Flood'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Line'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Make\ Blank\ Zone'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Append\ Blanks'
 endif
" call Dret("StopDrawIt")
endfun

" ---------------------------------------------------------------------
" SetDrawIt: this function allows one to change the drawing characters {{{2
fun! SetDrawIt(di_vert,di_horiz,di_plus,di_upleft,di_upright,di_cross,di_ellipse)
"  call Dfunc("SetDrawIt(vert<".a:di_vert."> horiz<".a:di_horiz."> plus<".a:di_plus."> upleft<".a:di_upleft."> upright<".a:di_upright."> cross<".a:di_cross."> ellipse<".a:di_ellipse.">)")
  let b:di_vert    = a:di_vert
  let b:di_horiz   = a:di_horiz
  let b:di_plus    = a:di_plus
  let b:di_upleft  = a:di_upleft
  let b:di_upright = a:di_upright
  let b:di_cross   = a:di_cross
  let b:di_ellipse = a:di_ellipse
"  call Dret("SetDrawIt")
endfun

" =====================================================================
" s:DrawLeft: {{{2
fun! s:DrawLeft()
"  call Dfunc("s:DrawLeft()")
  let curline   = getline(".")
  let curcol    = virtcol(".")
  let b:lastdir = 2

  if curcol > 0
    let curchar= strpart(curline,curcol-1,1)

    " replace
   if curchar == b:di_vert || curchar == b:di_plus
     exe "norm! r".b:di_plus
   else
     exe "norm! r".b:di_horiz
   endif

   " move and replace
   if curcol >= 2
    call s:MoveLeft()
    let curchar= strpart(curline,curcol-2,1)
    if curchar == b:di_vert || curchar == b:di_plus
     exe "norm! r".b:di_plus
    else
     exe "norm! r".b:di_horiz
    endif
   endif
  endif
"  call Dret("s:DrawLeft")
endfun

" ---------------------------------------------------------------------
" s:DrawRight: {{{2
fun! s:DrawRight()
"  call Dfunc("s:DrawRight()")
  let curline   = getline(".")
  let curcol    = virtcol(".")
  let b:lastdir = 1

  " replace
  if curcol == virtcol("$")
   exe "norm! a".b:di_horiz."\<Esc>"
  else
    let curchar= strpart(curline,curcol-1,1)
    if curchar == b:di_vert || curchar == b:di_plus
     exe "norm! r".b:di_plus
    else
     exe "norm! r".b:di_horiz
    endif
  endif

  " move and replace
  call s:MoveRight()
  if curcol == virtcol("$")
   exe "norm! i".b:di_horiz."\<Esc>"
  else
   let curchar= strpart(curline,curcol,1)
   if curchar == b:di_vert || curchar == b:di_plus
    exe "norm! r".b:di_plus
   else
    exe "norm! r".b:di_horiz
   endif
  endif
"  call Dret("s:DrawRight")
endfun

" ---------------------------------------------------------------------
" s:DrawUp: {{{2
fun! s:DrawUp()
"  call Dfunc("s:DrawUp()")
  let curline   = getline(".")
  let curcol    = virtcol(".")
  let b:lastdir = 3

  " replace
  if curcol == 1 && virtcol("$") == 1
   exe "norm! i".b:di_vert."\<Esc>"
  else
   let curchar= strpart(curline,curcol-1,1)
   if curchar == b:di_horiz || curchar == b:di_plus
    exe "norm! r".b:di_plus
   else
    exe "norm! r".b:di_vert
   endif
  endif

  " move and replace/insert
  call s:MoveUp()
  let curline= getline(".")
  let curchar= strpart(curline,curcol-1,1)

  if     curcol == 1 && virtcol("$") == 1
   exe "norm! i".b:di_vert."\<Esc>"
  elseif curchar == b:di_horiz || curchar == b:di_plus
   exe "norm! r".b:di_plus
  else
   exe "norm! r".b:di_vert
   endif
  endif
"  call Dret("s:DrawUp")
endfun

" ---------------------------------------------------------------------
" s:DrawDown: {{{2
fun! s:DrawDown()
"  call Dfunc("s:DrawDown()")
  let curline   = getline(".")
  let curcol    = virtcol(".")
  let b:lastdir = 4

  " replace
  if curcol == 1 && virtcol("$") == 1
   exe "norm! i".b:di_vert."\<Esc>"
  else
    let curchar= strpart(curline,curcol-1,1)
    if curchar == b:di_horiz || curchar == b:di_plus
     exe "norm! r".b:di_plus
    else
     exe "norm! r".b:di_vert
    endif
  endif

  " move and replace/insert
  call s:MoveDown()
  let curline= getline(".")
  let curchar= strpart(curline,curcol-1,1)
  if     curcol == 1 && virtcol("$") == 1
   exe "norm! i".b:di_vert."\<Esc>"
  elseif curchar == b:di_horiz || curchar == b:di_plus
   exe "norm! r".b:di_plus
  else
   exe "norm! r".b:di_vert
  endif
"  call Dret("s:DrawDown")
endfun

" ---------------------------------------------------------------------
" s:DrawErase: toggle [DrawIt on] and [DrawIt erase] modes {{{2
fun! s:DrawErase()
"  call Dfunc("s:DrawErase() b:di_erase=".b:di_erase)
  if b:di_erase == 0
   let b:di_erase= 1
   echo "[DrawIt erase]"
   let b:di_vert_save    = b:di_vert
   let b:di_horiz_save   = b:di_horiz
   let b:di_plus_save    = b:di_plus
   let b:di_upright_save = b:di_upright
   let b:di_upleft_save  = b:di_upleft
   let b:di_cross_save   = b:di_cross
   let b:di_ellipse_save = b:di_ellipse
   call SetDrawIt(' ',' ',' ',' ',' ',' ',' ')
  else
   let b:di_erase= 0
   echo "[DrawIt]"
   call SetDrawIt(b:di_vert_save,b:di_horiz_save,b:di_plus_save,b:di_upleft_save,b:di_upright_save,b:di_cross_save,b:di_ellipse_save)
  endif
"  call Dret("s:DrawErase")
endfun

" ---------------------------------------------------------------------
" s:DrawSpace: clear character and move right {{{2
fun! s:DrawSpace(chr,dir)
"  call Dfunc("s:DrawSpace(chr<".a:chr."> dir<".a:dir.">)")
  let curcol= virtcol(".")

  " replace current location with arrowhead/space
  if curcol == virtcol("$")-1
   exe "norm! r".a:chr
  else
   exe "norm! r".a:chr
  endif

  if a:dir == 0
   let dir= b:lastdir
  else
   let dir= a:dir
  endif

  " perform specified move
  if dir == 1
   call s:MoveRight()
  elseif dir == 2
   call s:MoveLeft()
  elseif dir == 3
   call s:MoveUp()
  else
   call s:MoveDown()
  endif
"  call Dret("s:DrawSpace")
endfun

" ---------------------------------------------------------------------
" s:DrawSlantDownLeft: / {{{2
fun! s:DrawSlantDownLeft()
"  call Dfunc("s:DrawSlantDownLeft()")
  call s:ReplaceDownLeft()		" replace
  call s:MoveDown()				" move
  call s:MoveLeft()				" move
  call s:ReplaceDownLeft()		" replace
"  call Dret("s:DrawSlantDownLeft")
endfun

" ---------------------------------------------------------------------
" s:DrawSlantDownRight: \ {{{2
fun! s:DrawSlantDownRight()
"  call Dfunc("s:DrawSlantDownRight()")
  call s:ReplaceDownRight()	" replace
  call s:MoveDown()			" move
  call s:MoveRight()		" move
  call s:ReplaceDownRight()	" replace
"  call Dret("s:DrawSlantDownRight")
endfun

" ---------------------------------------------------------------------
" s:DrawSlantUpLeft: \ {{{2
fun! s:DrawSlantUpLeft()
"  call Dfunc("s:DrawSlantUpLeft()")
  call s:ReplaceDownRight()	" replace
  call s:MoveUp()			" move
  call s:MoveLeft()			" move
  call s:ReplaceDownRight()	" replace
"  call Dret("s:DrawSlantUpLeft")
endfun

" ---------------------------------------------------------------------
" s:DrawSlantUpRight: / {{{2
fun! s:DrawSlantUpRight()
"  call Dfunc("s:DrawSlantUpRight()")
  call s:ReplaceDownLeft()	" replace
  call s:MoveUp()			" move
  call s:MoveRight()		" replace
  call s:ReplaceDownLeft()	" replace
"  call Dret("s:DrawSlantUpRight")
endfun

" ---------------------------------------------------------------------
" s:MoveLeft: {{{2
fun! s:MoveLeft()
"  call Dfunc("s:MoveLeft()")
  norm! h
  let b:lastdir= 2
"  call Dret("s:MoveLeft : b:lastdir=".b:lastdir)
endfun

" ---------------------------------------------------------------------
" s:MoveRight: {{{2
fun! s:MoveRight()
"  call Dfunc("s:MoveRight()")
  if virtcol(".") >= virtcol("$") - 1
   exe "norm! A \<Esc>"
  else
   norm! l
  endif
  let b:lastdir= 1
"  call Dret("s:MoveRight : b:lastdir=".b:lastdir)
endfun

" ---------------------------------------------------------------------
" s:MoveUp: {{{2
fun! s:MoveUp()
"  call Dfunc("s:MoveUp()")
  if line(".") == 1
   let curcol= virtcol(".") - 1
   if curcol == 0 && virtcol("$") == 1
     exe "norm! i \<Esc>"
   elseif curcol == 0
     exe "norm! YP:s/./ /ge\<CR>0r "
   else
     exe "norm! YP:s/./ /ge\<CR>0".curcol."lr "
   endif
  else
   let curcol= virtcol(".")
   norm! k
   while virtcol("$") <= curcol
     exe "norm! A \<Esc>"
   endwhile
  endif
  let b:lastdir= 3
"  call Dret("s:MoveUp : b:lastdir=".b:lastdir)
endfun

" ---------------------------------------------------------------------
" s:MoveDown: {{{2
fun! s:MoveDown()
"  call Dfunc("s:MoveDown()")
  if line(".") == line("$")
   let curcol= virtcol(".") - 1
   if curcol == 0 && virtcol("$") == 1
    exe "norm! i \<Esc>"
   elseif curcol == 0
    exe "norm! Yp:s/./ /ge\<CR>0r "
   else
    exe "norm! Yp:s/./ /ge\<CR>0".curcol."lr "
   endif
  else
   let curcol= virtcol(".")
   norm! j
   while virtcol("$") <= curcol
    exe "norm! A \<Esc>"
   endwhile
  endif
  let b:lastdir= 4
"  call Dret("s:MoveDown : b:lastdir=".b:lastdir)
endfun

" ---------------------------------------------------------------------
" s:ReplaceDownLeft: / X  (upright) {{{2
fun! s:ReplaceDownLeft()
"  call Dfunc("s:ReplaceDownLeft()")
  let curcol = virtcol(".")
  if curcol != virtcol("$")
   let curchar= strpart(getline("."),curcol-1,1)
   if curchar == "\\" || curchar == "X"
    exe "norm! r".b:di_cross
   else
    exe "norm! r".b:di_upright
   endif
  else
   exe "norm! i".b:di_upright."\<Esc>"
  endif
"  call Dret("s:ReplaceDownLeft")
endfun

" ---------------------------------------------------------------------
" s:ReplaceDownRight: \ X  (upleft) {{{2
fun! s:ReplaceDownRight()
"  call Dfunc("s:ReplaceDownRight()")
  let curcol = virtcol(".")
  if curcol != virtcol("$")
   let curchar= strpart(getline("."),curcol-1,1)
   if curchar == "/" || curchar == "X"
    exe "norm! r".b:di_cross
   else
    exe "norm! r".b:di_upleft
   endif
  else
   exe "norm! i".b:di_upleft."\<Esc>"
  endif
"  call Dret("s:ReplaceDownRight")
endfun

" ---------------------------------------------------------------------
" s:DrawFatRArrow: ----|> {{{2
fun! s:DrawFatRArrow()
"  call Dfunc("s:DrawFatRArrow()")
  call s:MoveRight()
  norm! r|
  call s:MoveRight()
  norm! r>
"  call Dret("s:DrawFatRArrow")
endfun

" ---------------------------------------------------------------------
" s:DrawFatLArrow: <|---- {{{2
fun! s:DrawFatLArrow()
"  call Dfunc("s:DrawFatLArrow()")
  call s:MoveLeft()
  norm! r|
  call s:MoveLeft()
  norm! r<
"  call Dret("s:DrawFatLArrow")
endfun

" ---------------------------------------------------------------------
"                 .
" s:DrawFatUArrow: /_\ {{{2
"                 |
fun! s:DrawFatUArrow()
"  call Dfunc("s:DrawFatUArrow()")
  call s:MoveUp()
  norm! r_
  call s:MoveRight()
  norm! r\
  call s:MoveLeft()
  call s:MoveLeft()
  norm! r/
  call s:MoveRight()
  call s:MoveUp()
  norm! r.
"  call Dret("s:DrawFatUArrow")
endfun

" ---------------------------------------------------------------------
" s:DrawFatDArrow: _|_ {{{2
"                  \ /
"                   '
fun! s:DrawFatDArrow()
"  call Dfunc("s:DrawFatDArrow()")
  call s:MoveRight()
  norm! r_
  call s:MoveLeft()
  call s:MoveLeft()
  norm! r_
  call s:MoveDown()
  norm! r\
  call s:MoveRight()
  call s:MoveRight()
  norm! r/
  call s:MoveDown()
  call s:MoveLeft()
  norm! r'
"  call Dret("s:DrawFatDArrow")
endfun

" ---------------------------------------------------------------------
" s:DrawEllipse: Bresenham-like ellipse drawing algorithm {{{2
"      2   2      can
"     x   y       be             2 2   2 2   2 2
"     - + - = 1   rewritten     b x + a y = a b
"     a   b       as
"
"     Take step which has minimum error
"     (x,y-1)  (x+1,y)  (x+1,y-1)
"
"             2 2   2 2   2 2
"     Ei = | b x + a y - a b |
"
"     Algorithm only draws arc from (0,b) to (a,0) and uses
"     DrawFour() to reflect points to other three quadrants
fun! s:DrawEllipse(x0,y0,x1,y1)
"  call Dfunc("s:DrawEllipse(x0=".a:x0." y0=".a:y0." x1=".a:x1." y1=".a:y1.")")
  let x0   = a:x0
  let y0   = a:y0
  let x1   = a:x1
  let y1   = a:y1
  let xoff = (x0+x1)/2
  let yoff = (y0+y1)/2
  let a    = s:Abs(x1-x0)/2
  let b    = s:Abs(y1-y0)/2
  let a2   = a*a
  let b2   = b*b
  let twoa2= a2 + a2
  let twob2= b2 + b2

  let xi= 0
  let yi= b
  let ei= 0
  call s:DrawFour(xi,yi,xoff,yoff,a,b)
  while xi <= a && yi >= 0

     let dy= a2 - twoa2*yi
     let ca= ei + twob2*xi + b2
     let cb= ca + dy
     let cc= ei + dy

     let aca= s:Abs(ca)
     let acb= s:Abs(cb)
     let acc= s:Abs(cc)

     " pick case: (xi+1,yi) (xi,yi-1) (xi+1,yi-1)
     if aca <= acb && aca <= acc
        let xi= xi + 1
        let ei= ca
     elseif acb <= aca && acb <= acc
        let ei= cb
        let xi= xi + 1
        let yi= yi - 1
     else
        let ei= cc
        let yi= yi - 1
     endif
     if xi > a:x1
        break
     endif
     call s:DrawFour(xi,yi,xoff,yoff,a,b)
  endw
"  call Dret("s:DrawEllipse")
endf

" ---------------------------------------------------------------------
" s:DrawFour: reflect a point to four quadrants {{{2
fun! s:DrawFour(x,y,xoff,yoff,a,b)
"  call Dfunc("s:DrawFour(xy[".a:x.",".a:y."] off[".a:xoff.",".a:yoff."] a=".a:a." b=".a:b.")")
  let x  = a:xoff + a:x
  let y  = a:yoff + a:y
  let lx = a:xoff - a:x
  let by = a:yoff - a:y
  call s:SetCharAt(b:di_ellipse,  x, y)
  call s:SetCharAt(b:di_ellipse, lx, y)
  call s:SetCharAt(b:di_ellipse, lx,by)
  call s:SetCharAt(b:di_ellipse,  x,by)
"  call Dret("s:DrawFour")
endf

" ---------------------------------------------------------------------
" s:SavePosn: saves position of cursor on screen so NetWrite can restore it {{{2
fun! s:SavePosn()
"  call Dfunc("s:SavePosn() saveposn_count=".s:saveposn_count.' ['.line('.').','.virtcol('.').']')
  let s:saveposn_count= s:saveposn_count + 1

  " Save current line and column
  let b:drawit_line_{s:saveposn_count} = line(".")
  let b:drawit_col_{s:saveposn_count}  = virtcol(".") - 1

  " Save top-of-screen line
  norm! H
  let b:drawit_hline_{s:saveposn_count}= line(".")

  " restore position
  exe "norm! ".b:drawit_hline_{s:saveposn_count}."G0z\<CR>"
  if b:drawit_col_{s:saveposn_count} == 0
   exe "norm! ".b:drawit_line_{s:saveposn_count}."G0"
  else
   exe "norm! ".b:drawit_line_{s:saveposn_count}."G0".b:drawit_col_{s:saveposn_count}."l"
  endif
"  call Dret("s:SavePosn : saveposn_count=".s:saveposn_count)
endfun

" ------------------------------------------------------------------------
" s:RestorePosn: {{{2
fun! s:RestorePosn()
"  call Dfunc("s:RestorePosn() saveposn_count=".s:saveposn_count)
  if s:saveposn_count <= 0
"  	call Dret("s:RestorePosn : s:saveposn_count<=0")
  	return
  endif
  " restore top-of-screen line
  exe "norm! ".b:drawit_hline_{s:saveposn_count}."G0z\<CR>"

  " restore position
  if b:drawit_col_{s:saveposn_count} == 0
   exe "norm! ".b:drawit_line_{s:saveposn_count}."G0"
  else
   exe "norm! ".b:drawit_line_{s:saveposn_count}."G0".b:drawit_col_{s:saveposn_count}."l"
  endif
  if s:saveposn_count > 0
	unlet b:drawit_hline_{s:saveposn_count}
	unlet b:drawit_line_{s:saveposn_count}
	unlet b:drawit_col_{s:saveposn_count}
   let s:saveposn_count= s:saveposn_count - 1
  endif
"  call Dret("s:RestorePosn : saveposn_count=".s:saveposn_count)
endfun

" ------------------------------------------------------------------------
" s:Flood: this function begins a flood of a region {{{2
"        based on b:di... characters as boundaries
"        and starting at the current cursor location.
fun! s:Flood()
"  call Dfunc("s:Flood()")

  let s:bndry  = b:di_vert.b:di_horiz.b:di_plus.b:di_upright.b:di_upleft.b:di_cross.b:di_ellipse
  let row      = line(".")
  let col      = virtcol(".")
  let athold   = @0
  let s:DIrows = line("$")
  call s:SavePosn()

  " get fill character from user
  " Put entire fillchar string into the s:bndry (boundary characters),
  " although only use the first such character for filling
  call inputsave()
  let s:fillchar= input("Enter fill character: ")
  call inputrestore()
  let s:bndry= "[".escape(s:bndry.s:fillchar,'\-]^')."]"
  if s:Strlen(s:fillchar) > 1
   let s:fillchar= strpart(s:fillchar,0,1)
  endif

  " flood the region
  call s:DI_Flood(row,col)

  " restore
  call s:RestorePosn()
  let @0= athold
  unlet s:DIrows s:bndry s:fillchar

"  call Dret("s:Flood")
endfun

" ------------------------------------------------------------------------
" s:DI_Flood: fill up to the boundaries all characters to the left and right. {{{2
"           Then, based on the left/right column extents reached, check
"           adjacent rows to see if any characters there need filling.
fun! s:DI_Flood(frow,fcol)
"  call Dfunc("s:DI_Flood(frow=".a:frow." fcol=".a:fcol.")")
  if a:frow <= 0 || a:fcol <= 0 || s:SetPosn(a:frow,a:fcol) || s:IsBoundary(a:frow,a:fcol)
"   call Dret("s:DI_Flood")
   return
  endif

  " fill current line
  let colL= s:DI_FillLeft(a:frow,a:fcol)
  let colR= s:DI_FillRight(a:frow,a:fcol+1)

  " do a filladjacent on the next line up
  if a:frow > 1
   call s:DI_FillAdjacent(a:frow-1,colL,colR)
  endif

  " do a filladjacent on the next line down
  if a:frow < s:DIrows
   call s:DI_FillAdjacent(a:frow+1,colL,colR)
  endif

"  call Dret("s:DI_Flood")
endfun

" ------------------------------------------------------------------------
"  s:DI_FillLeft: Starting at (frow,fcol), non-boundary locations are {{{2
"               filled with the fillchar.  The leftmost extent reached
"               is returned.
fun! s:DI_FillLeft(frow,fcol)
"  call Dfunc("s:DI_FillLeft(frow=".a:frow." fcol=".a:fcol.")")
  if s:SetPosn(a:frow,a:fcol)
"   call Dret("s:DI_FillLeft ".a:fcol)
   return a:fcol
  endif

  let Lcol= a:fcol
  while Lcol >= 1
   if !s:IsBoundary(a:frow,Lcol)
    exe  "silent! norm! r".s:fillchar."h"
   else
    break
   endif
   let Lcol= Lcol - 1
  endwhile

 let Lcol= (Lcol < 1)? 1 : Lcol + 1

" call Dret("s:DI_FillLeft ".Lcol)
 return Lcol
endfun

" ---------------------------------------------------------------------
"  s:DI_FillRight: Starting at (frow,fcol), non-boundary locations are {{{2
"                filled with the fillchar.  The rightmost extent reached
"                is returned.
fun! s:DI_FillRight(frow,fcol)
"  call Dfunc("s:DI_FillRight(frow=".a:frow." fcol=".a:fcol.")")
  if s:SetPosn(a:frow,a:fcol)
"   call Dret("s:DI_FillRight ".a:fcol)
   return a:fcol
  endif

  let Rcol   = a:fcol
  while Rcol <= virtcol("$")
   if !s:IsBoundary(a:frow,Rcol)
    exe "silent! norm! r".s:fillchar."l"
   else
    break
   endif
   let Rcol= Rcol + 1
  endwhile

  let DIcols = virtcol("$")
  let Rcol   = (Rcol > DIcols)? DIcols : Rcol - 1

"  call Dret("s:DI_FillRight ".Rcol)
  return Rcol
endfun

" ---------------------------------------------------------------------
"  s:DI_FillAdjacent: {{{2
"     DI_Flood does FillLeft and FillRight, so the run from left to right
"    (fcolL to fcolR) is known to have been filled.  FillAdjacent is called
"    from (fcolL to fcolR) on the lines one row up and down; if any character
"    on the run is not a boundary character, then a flood is needed on that
"    location.
fun! s:DI_FillAdjacent(frow,fcolL,fcolR)
"  call Dfunc("s:DI_FillAdjacent(frow=".a:frow." fcolL=".a:fcolL." fcolR=".a:fcolR.")")

  let icol  = a:fcolL
  while icol <= a:fcolR
	if !s:IsBoundary(a:frow,icol)
	 call s:DI_Flood(a:frow,icol)
	endif
   let icol= icol + 1
  endwhile

"  call Dret("s:DI_FillAdjacent")
endfun

" ---------------------------------------------------------------------
" s:SetPosn: set cursor to given position on screen {{{2
"    srow,scol: -s-creen    row and column
"   Returns  1 : failed sanity check
"            0 : otherwise
fun! s:SetPosn(row,col)
"  call Dfunc("s:SetPosn(row=".a:row." col=".a:col.")")
  " sanity checks
  if a:row < 1
"   call Dret("s:SetPosn 1")
   return 1
  endif
  if a:col < 1
"   call Dret("s:SetPosn 1")
   return 1
  endif

  exe "norm! ".a:row."G".a:col."\<Bar>"

"  call Dret("s:SetPosn 0")
  return 0
endfun

" ---------------------------------------------------------------------
" s:IsBoundary: returns 0 if not on boundary, 1 if on boundary {{{2
"             The "boundary" also includes the fill character.
fun! s:IsBoundary(row,col)
"  call Dfunc("s:IsBoundary(row=".a:row." col=".a:col.")")

  let orow= line(".")
  let ocol= virtcol(".")
  exe "norm! ".a:row."G".a:col."\<Bar>"
  norm! vy
  let ret= @0 =~ s:bndry
  if a:row != orow || a:col != ocol
   exe "norm! ".orow."G".ocol."\<Bar>"
  endif

"  call Dret("s:IsBoundary ".ret." : @0<".@0.">")
  return ret
endfun

" ---------------------------------------------------------------------
" s:PutBlock: puts a register's contents into the text at the current {{{2
"           cursor location
"              replace= 0: Blanks are transparent
"                     = 1: Blanks copy over
"                     = 2: Erase all drawing characters
"
"DechoTabOn
fun! s:PutBlock(block,replace)
"  call Dfunc("s:PutBlock(block<".a:block."> replace=".a:replace.") g:drawit_xstrlen=".g:drawit_xstrlen)
  call s:SavePosn()
  exe "let block  = @".a:block
  let blocklen    = strlen(block)
  let drawit_line = line('.')
  let drawchars   = '['.escape(b:di_vert.b:di_horiz.b:di_plus.b:di_upright.b:di_upleft.b:di_cross,'\-').']'
"  call Decho("blocklen=".blocklen." block<".string(block).">")

  " insure that putting a block will do so in a region containing spaces out to textwidth
  exe "let blockrows= s:Strlen(substitute(@".a:block.",'[^[:cntrl:]]','','g'))"
  exe 'let blockcols= s:Strlen(substitute(@'.a:block.",'^\\(.\\{-}\\)\\n\\_.*$','\\1',''))"
  let curline= line('.')
  let curcol = virtcol('.')
"  call Decho("blockrows=".blockrows." blockcols=".blockcols." curline=".curline." curcol=".curcol)
  call s:AutoCanvas(curline-1,curline + blockrows+1,curcol + blockcols)

  let iblock= 0
  while iblock < blocklen
   " the following logic should permit 1, 2, or 4 byte glyphs (I've only tested it with 1 and 2)
  	let chr= strpart(block,iblock,4)
	if char2nr(chr) <= 255
  	 let chr= strpart(block,iblock,1)
	elseif char2nr(chr) <= 65536
  	 let chr= strpart(block,iblock,2)
	 let iblock= iblock + 1
	else
	 let iblock= iblock + 3
	endif
"	call Decho("iblock=".iblock." chr#".char2nr(chr)."<".string(chr).">")

	if char2nr(chr) == 10
	 " handle newline
	 let drawit_line= drawit_line + 1
     if b:drawit_col_{s:saveposn_count} == 0
      exe "norm! ".drawit_line."G0"
     else
      exe "norm! ".drawit_line."G0".b:drawit_col_{s:saveposn_count}."l"
     endif

	elseif a:replace == 2
	 " replace all drawing characters with blanks
	 if match(chr,drawchars) != -1
	  norm! r l
	 else
	  norm! l
	 endif

	elseif chr == ' ' && a:replace == 0
	 " allow blanks to be transparent
	 norm! l

	else
	 " usual replace character
	 exe "norm! r".chr."l"
	endif
  	let iblock = iblock + 1
  endwhile
  call s:RestorePosn()

"  call Dret("s:PutBlock")
endfun

" ---------------------------------------------------------------------
" s:AutoCanvas: automatic "Canvas" routine {{{2
fun! s:AutoCanvas(linestart,linestop,cols)
"  call Dfunc("s:AutoCanvas(linestart=".a:linestart." linestop=".a:linestop." cols=".a:cols.")  line($)=".line("$"))

  " insure there's enough blank lines at end-of-file
  if line("$") < a:linestop
"   call Decho("append ".(a:linestop - line("$"))." empty lines")
   call s:SavePosn()
   exe "norm! G".(a:linestop - line("$"))."o\<esc>"
   call s:RestorePosn()
  endif

  " insure that any tabs contained within the selected region are converted to blanks
  let etkeep= &l:et
  set et
"  call Decho("exe ".a:linestart.",".a:linestop."retab")
  exe a:linestart.",".a:linestop."retab"
  let &l:et= etkeep

  " insure that there's whitespace to textwidth/screenwidth/a:cols
  if a:cols <= 0
   let tw= &tw
   if tw <= 0
    let tw= &columns
   endif
  else
   let tw= a:cols
  endif
"  Decho("tw=".tw)
  if search('^$\|.\%<'.(tw+1).'v$',"cn",(a:linestop+1)) > 0
"   call Decho("append trailing whitespace")
   call s:Spacer(a:linestart,a:linestop,tw)
  endif

"  call Dret("s:AutoCanvas : tw=".tw)
endfun

" ---------------------------------------------------------------------
" s:Strlen: this function returns the length of a string, even if its {{{2
"           using two-byte etc characters.
"           Currently, its only used if g:Align_xstrlen is set to a
"           nonzero value.  Solution from Nicolai Weibull, vim docs
"           (:help strlen()), Tony Mechelynck, and my own invention.
fun! s:Strlen(x)
"  call Dfunc("s:Strlen(x<".a:x.">")
  
  if g:drawit_xstrlen == 1
   " number of codepoints (Latin a + combining circumflex is two codepoints)
   " (comment from TM, solution from NW)
   let ret= strlen(substitute(a:x,'.','c','g'))

  elseif g:drawit_xstrlen == 2
   " number of spacing codepoints (Latin a + combining circumflex is one spacing 
   " codepoint; a hard tab is one; wide and narrow CJK are one each; etc.)
   " (comment from TM, solution from TM)
   let ret= strlen(substitute(a:x, '.\Z', 'x', 'g')) 

  elseif g:drawit_xstrlen == 3
   " virtual length (counting, for instance, tabs as anything between 1 and 
   " 'tabstop', wide CJK as 2 rather than 1, Arabic alif as zero when immediately 
   " preceded by lam, one otherwise, etc.)
   " (comment from TM, solution from me)
   let modkeep= &l:mod
   exe "norm! o\<esc>"
   call setline(line("."),a:x)
   let ret= virtcol("$") - 1
   d
   let &l:mod= modkeep

  else
   " at least give a decent default
   let ret= strlen(a:x)
  endif

"  call Dret("s:Strlen ".ret)
  return ret
endfun

" =====================================================================
"  DrawIt Functions: (by Sylvain Viart) {{{1
" =====================================================================

" ---------------------------------------------------------------------
" s:Canvas: {{{2
fun! s:Canvas()
"  call Dfunc("s:Canvas()")

  let lines  = input("how many lines under the cursor? ")
  let curline= line('.')
  if curline < line('$')
   exe "norm! ".lines."o\<esc>"
  endif
  call s:Spacer(curline+1,curline+lines,0)
  let b:drawit_canvas_used= 1

"  call Dret("s:Canvas")
endf

" ---------------------------------------------------------------------
" s:Spacer: fill end of line with space {{{2
"         if a:cols >0: to the virtual column specified by a:cols
"                  <=0: to textwidth (if nonzero), otherwise
"                       to display width (&columns)
fun! s:Spacer(debut, fin, cols) range
"  call Dfunc("s:Spacer(debut=".a:debut." fin=".a:fin." cols=".a:cols.")")
  call s:SavePosn()

  if a:cols <= 0
   let width = &textwidth
   if width <= 0
    let width= &columns
   endif
  else
   let width= a:cols
  endif

  let l= a:debut
  while l <= a:fin
   call setline(l,printf('%-'.width.'s',getline(l)))
   let l = l + 1
  endwhile

  call s:RestorePosn()

"  call Dret("s:Spacer")
endf

" ---------------------------------------------------------------------
" s:CallBox: call the specified function using the current visual selection box {{{2
fun! s:CallBox(func_name)
"  call Dfunc("s:CallBox(func_name<".a:func_name.">)")

  if exists("b:xmouse_start")
   let xdep = b:xmouse_start
  else
   let xdep= 0
  endif
  if exists("b:ymouse_start")
   let ydep = b:ymouse_start
  else
   let ydep= 0
  endif
  let col0   = virtcol("'<")
  let row0   = line("'<")
  let col1   = virtcol("'>")
  let row1   = line("'>")
"  call Decho("TL corner[".row0.",".col0."] original")
"  call Decho("BR corner[".row1.",".col1."] original")
"  call Decho("xydep     [".ydep.",".xdep."]")

  if col1 == xdep && row1 == ydep
     let col1 = col0
     let row1 = row0
     let col0 = xdep
     let row0 = ydep
  endif
"  call Decho("TL corner[".row0.",".col0."]")
"  call Decho("BR corner[".row1.",".col1."]")

  " insure that the selected region has blanks to that specified by col1
  call s:AutoCanvas((row0 < row1)? row0 : row1,(row1 > row0)? row1 : row0,(col1 > col0)? col1 : col0)

"  call Decho("exe call s:".a:func_name."(".col0.','.row0.','.col1.','.row1.")")
  exe "call s:".a:func_name."(".col0.','.row0.','.col1.','.row1.")"
  let b:xmouse_start= 0
  let b:ymouse_start= 0

"  call Dret("s:CallBox")
endf

" ---------------------------------------------------------------------
" s:DrawBox: {{{2
fun! s:DrawBox(x0, y0, x1, y1)
"  call Dfunc("s:DrawBox(xy0[".a:x0.",".a:y0." xy1[".a:x1.",".a:y1."])")
  " loop each line
  let x0= (a:x1 > a:x0)? a:x0 : a:x1
  let x1= (a:x1 > a:x0)? a:x1 : a:x0
  let y0= (a:y1 > a:y0)? a:y0 : a:y1
  let y1= (a:y1 > a:y0)? a:y1 : a:y0
  let l = y0
  while l <= y1
   let c = x0
   while c <= x1
    if l == y0 || l == y1
     let remp = '-'
     if c == x0 || c == x1
      let remp = '+'
     endif
    else
     let remp = '|'
     if c != x0 && c != x1
      let remp = '.'
     endif
    endif

    if remp != '.'
     call s:SetCharAt(remp, c, l)
    endif
    let c  = c + 1
   endw
   let l = l + 1
  endw

"  call Dret("s:DrawBox")
endf

" ---------------------------------------------------------------------
" s:SetCharAt: set the character at the specified position (must exist) {{{2
fun! s:SetCharAt(char, x, y)
"  call Dfunc("s:SetCharAt(char<".a:char."> xy[".a:x.",".a:y."])")

  let content = getline(a:y)
  if g:drawit_xstrlen == 0
   let long    = strlen(content)
   let deb     = strpart(content, 0, a:x - 1)
   let fin     = strpart(content, a:x, long)
  else
   let long    = s:Strlen(content)
   let xm1  = a:x - 1
   let extra= 0
   while s:Strlen(strpart(content,0,xm1+extra)) < xm1
	let extra= extra + 1
   endwhile
   let deb     = strpart(content, 0, xm1 + extra)
   let fin     = strpart(content, xm1 + extra + 1, long)
  endif
  call setline(a:y, deb.a:char.fin)

"  call Dret("s:SetCharAt")
endf

" ---------------------------------------------------------------------
" s:DrawLine: Bresenham line-drawing algorithm {{{2
" taken from :
" http://www.graphics.lcs.mit.edu/~mcmillan/comp136/Lecture6/Lines.html
fun! s:DrawLine(x0, y0, x1, y1, horiz)
"  call Dfunc("s:DrawLine(xy0[".a:x0.",".a:y0."] xy1[".a:x1.",".a:y1."] horiz=".a:horiz.")")

  if ( a:x0 < a:x1 && a:y0 > a:y1 ) || ( a:x0 > a:x1 && a:y0 > a:y1 )
    " swap direction
    let x0   = a:x1
    let y0   = a:y1
    let x1   = a:x0
    let y1   = a:y0
  else
    let x0 = a:x0
    let y0 = a:y0
    let x1 = a:x1
    let y1 = a:y1
  endif
  let dy = y1 - y0
  let dx = x1 - x0

  if dy < 0
     let dy    = -dy
     let stepy = -1
  else
     let stepy = 1
  endif

  if dx < 0
     let dx    = -dx
     let stepx = -1
  else
     let stepx = 1
  endif

  let dy = 2*dy
  let dx = 2*dx

  if dx > dy
     " move under x
     let char = a:horiz
     call s:SetCharAt(char, x0, y0)
     let fraction = dy - (dx / 2)  " same as 2*dy - dx
     while x0 != x1
        let char = a:horiz
        if fraction >= 0
           if stepx > 0
              let char = '\'
           else
              let char = '/'
           endif
           let y0 = y0 + stepy
           let fraction = fraction - dx    " same as fraction -= 2*dx
        endif
        let x0 = x0 + stepx
        let fraction = fraction + dy	" same as fraction = fraction - 2*dy
        call s:SetCharAt(char, x0, y0)
     endw
  else
     " move under y
     let char = '|'
     call s:SetCharAt(char, x0, y0)
     let fraction = dx - (dy / 2)
     while y0 != y1
        let char = '|'
        if fraction >= 0
           if stepy > 0 || stepx < 0
              let char = '\'
           else
              let char = '/'
           endif
           let x0 = x0 + stepx
           let fraction = fraction - dy
        endif
        let y0 = y0 + stepy
        let fraction = fraction + dx
        call s:SetCharAt(char, x0, y0)
     endw
  endif

"  call Dret("s:DrawLine")
endf

" ---------------------------------------------------------------------
" s:Arrow: {{{2
fun! s:Arrow(x0, y0, x1, y1)
"  call Dfunc("s:Arrow(xy0[".a:x0.",".a:y0."] xy1[".a:x1.",".a:y1."])")

  call s:DrawLine(a:x0, a:y0, a:x1, a:y1,'-')
  let dy = a:y1 - a:y0
  let dx = a:x1 - a:x0
  if s:Abs(dx) > <SID>Abs(dy)
     " move x
     if dx > 0
        call s:SetCharAt('>', a:x1, a:y1)
     else
        call s:SetCharAt('<', a:x1, a:y1)
     endif
  else
     " move y
     if dy > 0
        call s:SetCharAt('v', a:x1, a:y1)
     else
        call s:SetCharAt('^', a:x1, a:y1)
     endif
  endif

"  call Dret("s:Arrow")
endf

" ---------------------------------------------------------------------
" s:Abs: return absolute value {{{2
fun! s:Abs(val)
  if a:val < 0
   return - a:val
  else
   return a:val
  endif
endf

" ---------------------------------------------------------------------
" s:DrawPlainLine: {{{2
fun! s:DrawPlainLine(x0,y0,x1,y1)
"  call Dfunc("s:DrawPlainLine(xy0[".a:x0.",".a:y0."] xy1[".a:x1.",".a:y1."])")

"   call Decho("exe call s:DrawLine(".a:x0.','.a:y0.','.a:x1.','.a:y1.',"_")')
   exe "call s:DrawLine(".a:x0.','.a:y0.','.a:x1.','.a:y1.',"_")'

"  call Dret("s:DrawPlainLine")
endf

" =====================================================================
"  Mouse Functions: {{{1
" =====================================================================

" ---------------------------------------------------------------------
" s:LeftStart: Read visual drag mapping {{{2
" The visual start point is saved in b:xmouse_start and b:ymouse_start
fun! s:LeftStart()
"  call Dfunc("s:LeftStart()")
  let b:xmouse_start = virtcol('.')
  let b:ymouse_start = line('.')
  vnoremap <silent> <buffer> <script> <leftrelease> <leftrelease>:<c-u>call <SID>LeftRelease()<cr>gv
"  call Dret("s:LeftStart : [".b:ymouse_start.",".b:xmouse_start."]")
endf!

" ---------------------------------------------------------------------
" s:LeftRelease: {{{2
fun! s:LeftRelease()
"  call Dfunc("s:LeftRelease()")
  vunmap <buffer> <leftrelease>
"  call Dret("s:LeftRelease : [".line('.').','.virtcol('.').']')
endf

" ---------------------------------------------------------------------
" s:SLeftStart: begin drawing with a brush {{{2
fun! s:SLeftStart()
  if !exists("b:drawit_brush")
   let b:drawit_brush= "a"
  endif
"  call Dfunc("s:SLeftStart() brush=".b:drawit_brush.' ['.line('.').','.virtcol('.').']')
  noremap <silent> <buffer> <script> <s-leftdrag>    <leftmouse>:<c-u>call <SID>SLeftDrag()<cr>
  noremap <silent> <buffer> <script> <s-leftrelease> <leftmouse>:<c-u>call <SID>SLeftRelease()<cr>
"  call Dret("s:SLeftStart")
endfun

" ---------------------------------------------------------------------
" s:SLeftDrag: {{{2
fun! s:SLeftDrag()
"  call Dfunc("s:SLeftDrag() brush=".b:drawit_brush.' ['.line('.').','.virtcol('.').']')
  call s:SavePosn()
  call s:PutBlock(b:drawit_brush,0)
  call s:RestorePosn()
"  call Dret("s:SLeftDrag")
endfun

" ---------------------------------------------------------------------
" s:SLeftRelease: {{{2
fun! s:SLeftRelease()
"  call Dfunc("s:SLeftRelease() brush=".b:drawit_brush.' ['.line('.').','.virtcol('.').']')
  call s:SLeftDrag()
  nunmap <buffer> <s-leftdrag>
  nunmap <buffer> <s-leftrelease>
"  call Dret("s:SLeftRelease")
endfun

" ---------------------------------------------------------------------
" s:CLeftStart: begin moving a block of text {{{2
fun! s:CLeftStart()
  if !exists("b:drawit_brush")
   let b:drawit_brush= "a"
  endif
"  call Dfunc("s:CLeftStart() brush=".b:drawit_brush)
  if !line("'<") || !line("'>")
   redraw!
   echohl Error
   echo "must visual-block select a region first"
"   call Dret("s:CLeftStart : must visual-block select a region first")
   return
  endif
  '<,'>call DrawIt#SetBrush(b:drawit_brush)
  let s:cleft_width= virtcol("'>") - virtcol("'<")
  if s:cleft_width < 0
   let s:cleft_width= -s:cleft_width
  endif
  let s:cleft_height= line("'>") - line("'<")
  if s:cleft_height < 0
   let s:cleft_height= -s:cleft_height
  endif
  if exists("s:cleft_oldblock")
   unlet s:cleft_oldblock
  endif
"  call Decho("blocksize: ".s:cleft_height."x".s:cleft_width)
  noremap <silent> <buffer> <script> <c-leftdrag>    :<c-u>call <SID>CLeftDrag()<cr>
  noremap <silent> <buffer> <script> <c-leftrelease> <leftmouse>:<c-u>call <SID>CLeftRelease()<cr>
"  call Dret("s:CLeftStart")
endfun

" ---------------------------------------------------------------------
" s:CLeftDrag: {{{2
fun! s:CLeftDrag()
"  call Dfunc("s:CLeftDrag() cleft_width=".s:cleft_width." cleft_height=".s:cleft_height)
  exe 'let keepbrush= @'.b:drawit_brush
"  call Decho("keepbrush<".keepbrush.">")

  " restore prior contents of block zone
  if exists("s:cleft_oldblock")
"   call Decho("draw prior contents: [".line(".").",".virtcol(".")."] line($)=".line("$"))
"   call Decho("draw prior contents<".s:cleft_oldblock.">")
   exe 'let @'.b:drawit_brush.'=s:cleft_oldblock'
   call s:PutBlock(b:drawit_brush,1)
  endif

  " move cursor to <leftmouse> position
  exe "norm! \<leftmouse>"

  " save new block zone contents
"  call Decho("save contents: [".line(".").",".virtcol(".")."] - [".(line(".")+s:cleft_height).",".(virtcol(".")+s:cleft_width)."]")
  let curline= line(".")
  call s:AutoCanvas(curline,curline + s:cleft_height,virtcol(".")+s:cleft_width)
  if s:cleft_width > 0 && s:cleft_height > 0
   exe "silent! norm! \<c-v>".s:cleft_width."l".s:cleft_height.'j"'.b:drawit_brush.'y'
  elseif s:cleft_width > 0
   exe "silent! norm! \<c-v>".s:cleft_width.'l"'.b:drawit_brush.'y'
  else
   exe "silent! norm! \<c-v>".s:cleft_height.'j"'.b:drawit_brush.'y'
  endif
  exe "let s:cleft_oldblock= @".b:drawit_brush
"  call Decho("s:cleft_oldblock=@".b:drawit_brush)
"  call Decho("cleft_height=".s:cleft_height." cleft_width=".s:cleft_width)
"  call Decho("save contents<".s:cleft_oldblock.">")

  " draw the brush
"  call Decho("draw brush")
"  call Decho("draw brush ".b:drawit_brush.": [".line(".").",".virtcol(".")."] line($)=".line("$"))
  exe 'let @'.b:drawit_brush.'=keepbrush'
  call s:PutBlock(b:drawit_brush,1)

"  call Dret("s:CLeftDrag")
endfun

" ---------------------------------------------------------------------
" s:CLeftRelease: {{{2
fun! s:CLeftRelease()
"  call Dfunc("s:CLeftRelease()")
  call s:CLeftDrag()
  nunmap <buffer> <c-leftdrag>
  nunmap <buffer> <c-leftrelease>
  unlet s:cleft_oldblock s:cleft_height s:cleft_width
"  call Dret("s:CLeftRelease")
endfun

" ---------------------------------------------------------------------
" DrawIt#SetBrush: {{{2
fun! DrawIt#SetBrush(brush) range
"  call Dfunc("DrawIt#SetBrush(brush<".a:brush.">)")
  let b:drawit_brush= a:brush
"  call Decho("visualmode<".visualmode()."> range[".a:firstline.",".a:lastline."] visrange[".line("'<").",".line("'>")."]")
  if visualmode() == "\<c-v>" && ((a:firstline == line("'>") && a:lastline == line("'<")) || (a:firstline == line("'<") && a:lastline == line("'>")))
   " last visual mode was visual block mode, and
   " either [firstline,lastline] == ['<,'>] or ['>,'<]
   " Assuming that SetBrush called from a visual-block selection!
   " Yank visual block into selected register (brush)
"   call Decho("yanking visual block into register ".b:drawit_brush)
   exe 'norm! gv"'.b:drawit_brush.'y'
  endif
"  call Dret("DrawIt#SetBrush : b:drawit_brush=".b:drawit_brush)
endfun

" ------------------------------------------------------------------------
" Modelines: {{{1
" vim: fdm=marker
let &cpo= s:keepcpo
unlet s:keepcpo
doc/DrawIt.txt	[[[1
404
*drawit.txt*	The DrawIt Tool				Mar 24, 2009

Authors:  Charles E. Campbell, Jr.  <NdrchipO@ScampbellPfamily.AbizM> {{{1
          Sylvain Viart             <molo@multimania.com>
	  (remove NOSPAM from Campbell's email first)
Copyright:    Copyright (C) 2004-2007 Charles E. Campbell, Jr. {{{1
              Permission is hereby granted to use and distribute this code,
              with or without modifications, provided that this copyright
              notice is copied with it. Like anything else that's free,
              DrawIt.vim is provided *as is* and comes with no warranty
              of any kind, either expressed or implied. By using this
              plugin, you agree that in no event will the copyright
              holder be liable for any damages resulting from the use
              of this software.


==============================================================================
1. Contents						*drawit-contents* {{{1

	1. Contents......................: |drawit-contents|
	2. DrawIt Manual.................: |drawit|
	3. DrawIt Usage..................: |drawit-usage|
	     Starting....................: |drawit-start|
	     Stopping....................: |drawit-stop|
	     User Map Protection.........: |drawit-protect|
	     Drawing.....................: |drawit-drawing|
	     Changing Drawing Characters.: |drawit-setdrawit|
	     Moving......................: |drawit-moving|
	     Erasing.....................: |drawit-erase|
	     Example.....................: |drawit-example|
	     Visual Block Mode...........: |drawit-visblock|
	     Brushes.....................: |drawit-brush|
	     DrawIt Modes................: |drawit-modes|
	4. DrawIt History................: |drawit-history|


==============================================================================
2. DrawIt Manual					*drawit* {{{1
							*drawit-manual*
 /===============+============================================================\
 || Starting &   |                                                           ||
 || Stopping     | Explanation                                               ||
 ++--------------+-----------------------------------------------------------++
 ||  \di         | start DrawIt       |drawit-start|                         ||
 ||  \ds         | stop  DrawIt       |drawit-stop|                          ||
 ||  :DIstart    | start DrawIt       |drawit-start|                         ||
 ||  :DIstop     | stop  DrawIt       |drawit-stop|                          ||
 ||  :DrawIt[!]  | start/stop DrawIt  |drawit-start| |drawit-stop|           ||
 ||              |                                                           ||
 ++==============+===========================================================++
 ||   Maps       | Explanation                                               ||
 ++--------------+-----------------------------------------------------------++
 ||              | The DrawIt routines use a replace, move, and              ||
 ||              | replace/insert strategy.  The package also lets one insert||
 ||              | spaces, draw arrows by using the following characters or  ||
 ||              | keypad characters:                                        ||
 ||              +-----------------------------------------------------------++
 || <left>       | move and draw left                       |drawit-drawing| ||
 || <right>      | move and draw right, inserting lines/space as needed      ||
 || <up>         | move and draw up, inserting lines/space as needed         ||
 || <down>       | move and draw down, inserting lines/space as needed       ||
 || <s-left>     | move cursor left                            |drawit-move| ||
 || <s-right>    | move cursor right, inserting lines/space as needed        ||
 || <s-up>       | move cursor up, inserting lines/space as needed           ||
 || <s-down>     | move cursor down, inserting lines/space as needed         ||
 || <space>      | toggle into and out of erase mode                         ||
 || >            | insert a > and move right    (draw -> arrow)              ||
 || <            | insert a < and move left     (draw <- arrow)              ||
 || ^            | insert a ^ and move up       (draw ^  arrow)              ||
 || v            | insert a v and move down     (draw v  arrow)              ||
 || <pgdn>       | replace with a \, move down and right, and insert a \     ||
 || <end>        | replace with a /, move down and left,  and insert a /     ||
 || <pgup>       | replace with a /, move up   and right, and insert a /     ||
 || <home>       | replace with a \, move up   and left,  and insert a \     ||
 || \>           | insert a fat > and move right    (draw -> arrow)          ||
 || \<           | insert a fat < and move left     (draw <- arrow)          ||
 || \^           | insert a fat ^ and move up       (draw ^  arrow)          ||
 || \v           | insert a fat v and move down     (draw v  arrow)          ||
 ||<s-leftmouse> | drag and draw with current brush          |drawit-brush|  ||
 ||<c-leftmouse> | drag and move current brush               |drawit-brush|  ||
 ||              |                                                           ||
 ||==============+===========================================================++
 ||Visual Cmds   | Explanation                                               ||
 ||--------------+-----------------------------------------------------------++
 ||              | The drawing mode routines use visual-block mode to        ||
 ||              | select endpoints for lines, arrows, and ellipses. Bresen- ||
 ||              | ham and Bresenham-like algorithms are used for this.      ||
 ||              |                                                           ||
 ||              | These routines need a block of spaces, and so the canvas  ||
 ||              | routine must first be used to create such a block.  The   ||
 ||              | canvas routine will query the user for the number of      ||
 ||              | lines to hold |'textwidth'| spaces.                       ||
 ||              +-----------------------------------------------------------++
 || \a           | draw arrow from corners of visual-block selected region   ||
 || \b           | draw box on visual-block selected region                  ||
 || \c           | the canvas routine (will query user, see above)           ||
 || \e           | draw an ellipse on visual-block selected region           ||
 || \f           | flood figure with a character (you will be prompted)      ||
 || \l           | draw line from corners of visual-block selected region    ||
 || \s           | spacer: appends spaces up to the textwidth (default: 78)  ||
 ||              |                                                           ||
 ++==============+===========================================================++
 || Function and Explanation                                                 ||
 ++--------------+-----------------------------------------------------------++
 ||  :call SetDrawIt('vertical','horizontal','crossing','\','/','X','*')     ||
 ||            set drawing characters for motions for moving                 ||
 ||            and for the ellipse drawing boundary                          ||
 ||  default   motion                                                        ||
 ||  |         up/down,                                                      ||
 ||  -         left/right,                                                   ||
 ||  +         -| crossing,                                                  ||
 ||  \         downright,                                                    ||
 ||  /         downleft, and                                                 ||
 ||  X         \/ crossing                                                   ||
 ++=======================+==================================================++
 ||  Commands             | Explanation                                      ||
 ++-----------------------+--------------------------------------------------++
 ||  :SetBrush a-z        | sets brush (register) to given register          ||
 ||  :'<,'>SetBrush a-z   | yanks visual block to brush (register)           ||
 \============================================================================/


==============================================================================
3. DrawIt Usage						*drawit-usage* {{{1

STARTING						*drawit-start* {{{2
\di

Typically one puts <drawit.vim> into the .vim/plugin directory
(vimfiles\plugin for Windows) where it becomes always available.  It uses a
minimal interface (\di: you can think of it as *D*raw*I*t or *D*rawIt
*I*nitialize) to start it and (\ds: *D*rawIt *S*top) to stop it.  Instead of
using "\" you may specify your own preference for a map leader (see
|mapleader|).

A message, "[DrawIt]", will appear on the message line.


STOPPING						*drawit-stop* {{{2
\ds

When you are done with DrawIt, use \ds to stop DrawIt mode.  Stopping DrawIt
will restore your usual options and remove the maps DrawIt set up.

A message, "[DrawIt off]", will appear on the message line.


USER MAP PROTECTION					*drawit-protect* {{{2

Starting DrawIt causes it to set up a number of maps which facilitate drawing.
DrawIt accommodates users with conflicting maps by saving both maps and user
options and before setting them to what DrawIt needs.  When you stop DrawIt
(|drawit-stop|), DrawIt will restore the user's maps and options as they were
before DrawIt was started.


OPTIONS                                               	*drawit-options* {{{2

							*g:drawit_insertmode*
g:drawit_insertmode : if this variable exists and is 1 then maps are
	              made which make cursor-control drawing available
		      while in insert mode, too.  Otherwise, DrawIt's
		      maps only affect normal mode.

DRAWING							*drawit-drawing* {{{2

After DrawIt is started, use the number pad or arrow keys to move the cursor
about.  As the cursor moves, DrawIt will then leave appropriate "line"
characters behind as you move horizontally, vertically, or diagonally, and
will transparently enlarge your file to accommodate your drawing as needed.
The trail will consist of -, |, \, / characters (depending on which direction
and SetDrawIt() changes), and + and X characters where line crossings occur.
You may use h-j-k-l to move about your display and generally use editing
commands as you wish even while in DrawIt mode.


CHANGING DRAWING CHARACTERS				*drawit-setdrawit* {{{2

The SetDrawIt() function is available for those who wish to change the
characters that DrawIt uses. >

    ex. :call SetDrawIt('*','*','*','*','*','*','*')
    ex. :call SetDrawIt('-','|','-','\','/','/','*')
<
The first example shows how to change all the DrawIt drawing characters to
asterisks, and the second shows how to give crossing priority to - and /.
The default setting is equivalent to: >

	:call SetDrawIt('|','-','+','\','/','X','*')
<
where SetDrawit()'s arguments refer, in order, to the >

	vertical			drawing character
    	horizontal			drawing character
    	horizontal/vertical crossing	drawing character
    	down right			drawing character
    	down left			drawing character
    	diagonal crossing		drawing character
	ellipse boundary                drawing character
<

MOVING					*drawit-move* *drawit-moving* {{{2

DrawIt supports shifting the arrow keys to cause motion of the cursor.  The
motion of the cursor will not modify what's below the cursor.  The cursor
will move and lines and/or spaces will be inserted to support the move as
required.  Your terminal may not support shifted arrow keys, however, or Vim
may not catch them as such.  For example, on the machine I use, shift-up
(<s-up>) produced <Esc>[161q, but vim didn't know that sequence was a <s-up>.
I merely made a nmap:

	nmap <Esc>[161q	<s-up>

and vim thereafter recognized the <s-up> command.


ERASING							*drawit-erase* {{{2
<space>

The <space> key will toggle DrawIt's erase mode/DrawIt mode.  When in [DrawIt
erase] mode, a message "[DrawIt erase]" will appear and the number pad will
now cause spaces to be drawn instead of the usual drawing characters.  The
drawing behavior will be restored when the <space> key toggles DrawIt back
to regular DrawIt mode.


EXAMPLES						*drawit-example* {{{2

Needless to say, the square spirals which follow were done with DrawIt and
a bit of block editing with Vim: >

   +------------ -----------+ +------------ -----------+ +------------
   |+----------+ +---------+| |+----------+ +---------+| |+----------+
   ||+--------+| |+-------+|| ||+--------+| |+-------+|| ||+--------+|
   |||-------+|| ||+------||| |||-------+|| ||+------||| |||-------+||
   ||+-------+|| ||+------+|| ||+-------+|| ||+------+|| ||+-------+||
   |+---------+| |+--------+| |+---------+| |+--------+| |+---------+|
   +-----------+ +----------+ +-----------+ +----------+ +-----------+

VISUAL BLOCK MODE FOR ARROWS LINES BOXES AND ELLIPSES	*drawit-visblock* {{{2

\a : draw arrow from corners of visual-block selected region	*drawit-a*
\b : draw box on visual-block selected region			*drawit-b*
\c : the canvas routine (will query user, see above)		*drawit-c*
\e : draw an ellipse on visual-block selected region		*drawit-e*
\f : flood figure with a character (you will be prompted)	*drawit-f*
\l : draw line from corners of visual-block selected region	*drawit-l*
\s : spacer: appends spaces up to the textwidth (default: 78)	*drawit-s*

The DrawIt package has been merged with Sylvain Viart's drawing package (by
permission) which provides DrawIt with visual-block selection of
starting/ending point drawing of arrows (\a), lines (\l), and boxes (\b).
Additionally I wrote an ellipse drawing function using visual block
specification (|drawit-e|).

One may create a block of spaces for these maps to operate in; the "canvas"
routine (\c) will help create such blocks.  First, the s:Canvas() routine will
query the user for the number of lines s/he wishes to have, and will then fill
those lines with spaces out to the |'textwidth'| if user has specified it;
otherwise, the display width will be used.

The Sylvain Viart functions and the ellipse drawing function depend
upon using visual block mode.  As a typical use: >

	Example: * \h
                   DrawIt asks: how many lines under the cursor? 10
                   DrawIt then appends 10 lines filled with blanks
                   out to textwidth (if defined) or 78 columns.
                 * ctrl-v (move) \b
                   DrawIt then draws a box
		 * ctrl-v (move) \e
                   DrawIt then draws an ellipse
<
Select the first endpoint with ctrl-v and then move to the other endpoint.
One may then select \a for arrows, \b for boxes, \e for ellipses, or \l for
lines.  The internal s:AutoCanvas() will convert tabs to spaces and will
extend with spaces as needed to support the visual block.  Note that when
DrawIt is enabled, virtualedit is also enabled (to "all").
>
        Examples:

        __                _         ***************           +-------+
          \_            _/      ****               ****       |       |
            \_        _/      **      --------->       **     |       |
              \_    _/          ****               ****       |       |
                \__/   <-------     ***************           +-------+

		\l        \a           \e and \a                  \b
<
							*drawit-setbrush*
BRUSHES							*drawit-brush* {{{2
>
 :SetBrush [a-z]
<
	Set the current brush to the selected brush register:
>
		ex.  :SetBrush b

 :'<,'>SetBrush [a-z]
<
	Select text for the brush by using visual-block mode: ctrl-v, move .
	Then set the current text into the brush register:  (default brush: a)
>
 <leftmouse>
<
	Select a visual-block region.  One may use "ay, for example,
	to yank selected text to register a.
>
 <shift-leftmouse>
<
	One may drag and draw with the current brush (default brush: a)
	by holding down the shift key and the leftmouse button and moving
	the mouse.  Blanks in the brush are considered to be transparent.
>
 <ctrl-leftmouse>
<
	One may drag and move a selection with <ctrl-leftmouse>.  First,
	select the region using the <leftmouse>.  Release the mouse button,
	then press ctrl and the <leftmouse> button; while continuing to press
	the button, move the mouse.  The selected block of text will then
	move along with the cursor.
>
 \ra ... \rz
<
	Replace text with the given register's contents (ie. the brush).
>
 \pa ... \pz
<
	Like \ra ... \rz, except that blanks are considered to be transparent.

	Example: Draw the following >
			\ \
			o o
			 *
			---
<		Then use ctrl-v, move, "ay to grab a copy into register a.
		By default, the current brush uses register a (change brush
		with :SetBrush [reg]).  Hold the <shift> and <leftbutton>
		keys down and move the mouse; as you move, a copy of the
		brush will be left behind.
	

DRAWIT MODES						*drawit-modes* {{{2

  -[DrawIt]       regular DrawIt mode                     (|drawit-start|)
  -[DrawIt off]   DrawIt is off                           (|drawit-stop| )
  -[DrawIt erase] DrawIt will erase using the number pad  (|drawit-erase|)

  g:DrChipTopLvlMenu: by default its "DrChip"; you may set this to whatever
                  you like in your <.vimrc>.  This variable controls where
		  DrawIt's menu items are placed.


==============================================================================
4. History						*drawit-history* {{{1

	10 Jun 12, 2008	* Fixed a bug with ctrl-leftmouse (which was leaving
			  a space in the original selected text)
	   Mar 24, 2009 * :DrawIt starts, :DrawIt! stops DrawIt mode.
	   Mar 24, 2009 * I've included <script> modifiers to the maps to
	                  cause rhs remapping only with mappings local to
			  the script (see |:map-script|)
	09 Sep 14, 2007 * Johann-Guenter Simon fixed a bug with s:DrawErase();
	                  it called SetDrawIt() and that call hadn't been
			  updated to account for the new b:di_ellipse
			  parameter.
	08 Feb 12, 2007 * fixed a bug which prevented multi-character user
	                  maps from being restored properly
	   May 03, 2007 * Extended SetDrawIt() to handle b:di_ellipse, the
	                  ellipse boundary drawing character
			* Changed "Holer" to "Canvas", and wrote AutoCanvas(),
			  which allows one to use the visual-block drawing
			  maps without creating a canvas first.
			* DrawIt now uses the ctrl-leftmouse to move a visual
			 block selected region.
			* Floods can now be done inside an ellipse
			* DrawIt's maps are now all users of <buffer>
	 7 Feb 16, 2005 * now checks that "m" is in &go before attempting to
			  use menus
	  Aug 17, 2005  * report option workaround
	  Nov 01, 2005  * converted DrawIt to use autoload feature of vim 7.0
	  Dec 28, 2005  * now uses cecutil to save/restore user maps
	  Jan 18, 2006  * cecutil now updated to use keepjumps
	  Jan 23, 2006  * :DIstart and :DIstop commands provided; thus users
			  using  "set noremap" can still use DrawIt.
	  Jan 26, 2006  * DrawIt menu entry now keeps its place
	  Apr 10, 2006  * Brushes were implemented
	 6 Feb 24, 2003 * The latest DrawIt now provides a fill function.
			  \f will ask for a character to fill the figure
			  surrounding the current cursor location.  Plus
			  I suggest reading :he drawit-tip for those whose
			  home/pageup/pagedown/end keys aren't all working
			  properly with DrawIt.
	   08/18/03     : \p[a-z] and \r[a-z] implemented
	   08/04/03     : b:..keep variables renamed to b:di_..keep variables
	                  StopDrawIt() now insures that erase mode is off
	   03/11/03     : included g:drawit_insertmode handling
	   02/21/03     : included flood function
	   12/11/02     : deletes trailing whitespace only if holer used
	    8/27/02     : fat arrowheads included
	                : shift-arrow keys move but don't modify

 ---------------------------------------------------------------------
vim:tw=78:ts=8:ft=help:fdm=marker
