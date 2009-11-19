" Decho.vim:   Debugging support for VimL
" Maintainer:  Charles E. Campbell, Jr. PhD <cec@NgrOyphSon.gPsfAc.nMasa.gov>
" Date:        Sep 02, 2009
" Version:     21g	ASTRO-ONLY
"
" Usage: {{{1
"   Decho "a string"
"   call Decho("another string")
"   let g:decho_bufname = "ANewDBGBufName"
"   let g:decho_bufenter= 1    " tells Decho to ignore BufEnter, WinEnter,
"                              " WinLeave events while Decho is working
"   call Decho("one","thing","after","another")
"   DechoOn     : removes any first-column '"' from lines containing Decho
"   DechoOff    : inserts a '"' into the first-column in lines containing Decho
"   DechoMsgOn  : use echomsg instead of DBG buffer
"   DechoMsgOff : turn debugging off
"   DechoRemOn  : turn remote Decho messaging on
"   DechoRemOff : turn remote Decho messaging off
"   DechoVarOn [varname] : use variable to write debugging messages to
"   DechoVarOff : turn debugging off
"   DechoTabOn  : turn debugging on (uses a separate tab)
"   DechoTabOff : turn debugging off
"
" GetLatestVimScripts: 120 1 :AutoInstall: Decho.vim
" GetLatestVimScripts: 1066 1 :AutoInstall: cecutil.vim
" redraw!|call inputsave()|call input("Press <cr> to continue")|call inputrestore()

" ---------------------------------------------------------------------
" Load Once: {{{1
if exists("g:loaded_Decho") || &cp
 finish
endif
let g:loaded_Decho = "v21g"
let s:keepcpo      = &cpo
set cpo&vim

" ---------------------------------------------------------------------
"  Default Values For Variables: {{{1
if !exists("g:decho_bufname")
 let g:decho_bufname= "DBG"
endif
if !exists("s:decho_depth")
 let s:decho_depth  = 0
endif
if !exists("g:decho_winheight")
 let g:decho_winheight= 5
endif
if !exists("g:decho_bufenter")
 let g:decho_bufenter= 0
endif
if !exists("g:dechomode") || !exists("s:DECHOWIN")
 let s:DECHOWIN = 1
 let s:DECHOMSG = 2
 let s:DECHOVAR = 3
 let s:DECHOREM = 4
 let s:DECHOTAB = 5
 let g:dechomode= s:DECHOWIN
endif
if !exists("g:dechovarname")
 let g:dechovarname = "g:dechovar"
endif

" ---------------------------------------------------------------------
"  User Interface: {{{1
com! -nargs=+ -complete=expression Decho	call Decho(<args>)
com! -nargs=+ -complete=expression Dredir	call Dredir(<args>)
com! -nargs=0 Dhide    						call s:Dhide(1)
com! -nargs=0 Dshow    						call s:Dhide(0)
com! -nargs=? DechoSep						call DechoSep(<args>)
com! -nargs=? Dsep						    call DechoSep(<args>)
com! -nargs=0 DechoMsgOn					call s:DechoCtrlInit(s:DECHOMSG,expand("<sfile>"))
com! -nargs=0 DechoMsgOff					call s:DechoMsg(0)
com! -nargs=0 -range=% DechoOn				call DechoOn(<line1>,<line2>)
com! -nargs=0 -range=% DechoOff				call DechoOff(<line1>,<line2>)
if has("clientserver") && executable("gvim")
 com! -nargs=0 DechoRemOn					call s:DechoCtrlInit(s:DECHOREM,expand("<sfile>"))
 com! -nargs=0 DechoRemOff					call s:DechoRemote(0)
endif
com! -nargs=? DechoVarOn					call s:DechoCtrlInit(s:DECHOVAR,expand("<sfile>"),<args>)
com! -nargs=0 DechoVarOff					call s:DechoVarOff()
if v:version >= 700
 com! -nargs=? DechoTabOn                   call s:DechoCtrlInit(s:DECHOTAB,expand("<sfile>"))
 com! -nargs=? DechoTabOff                  set lz|call s:DechoTab(0)|set nolz
endif
com! -nargs=0 DechoPause					call DechoPause()
au Filetype Decho nmap <silent> <buffer> <F1> :setlocal noro ma<cr>

" ---------------------------------------------------------------------
" Decho: the primary debugging function: splits the screen as necessary and {{{1
"        writes messages to a small window (g:decho_winheight lines)
"        on the bottom of the screen
fun! Decho(...)
 
  " make sure that SaveWinPosn() and RestoreWinPosn() are available
  if !exists("g:loaded_cecutil")
   runtime plugin/cecutil.vim
   if !exists("g:loaded_cecutil") && exists("g:loaded_AsNeeded")
   	AN SWP
   endif
   if !exists("g:loaded_cecutil")
   	echoerr "***Decho*** need to load <cecutil.vim>"
	return
   endif
  endif

  " set up ctrl mode as user specified earlier
  call s:DechoCtrl()

  " open DBG window (if dechomode is dechowin)
  if g:dechomode == s:DECHOWIN
   let swp   = SaveWinPosn(0)
   let curbuf= bufnr("%")
   if g:decho_bufenter
    let eikeep= &ei
	let eakeep= &ea
	set ei=BufEnter,WinEnter,WinLeave,ShellCmdPost,FocusGained noea
   endif
 
   " As needed, create/switch-to the DBG buffer
   if !bufexists(g:decho_bufname) && bufnr("*/".g:decho_bufname."$") == -1
    " if requested DBG-buffer doesn't exist, create a new one
    " at the bottom of the screen.
	exe "keepjumps silent! bot ".g:decho_winheight."new ".fnameescape(g:decho_bufname)
    setlocal noswf
	keepjumps silent! %d
 
   elseif bufwinnr(g:decho_bufname) > 0
    " if requested DBG-buffer exists in a window,
    " go to that window (by window number)
    exe "keepjumps ".bufwinnr(g:decho_bufname)."wincmd W"
    exe "res ".g:decho_winheight
 
   else
    " user must have closed the DBG-buffer window.
    " create a new one at the bottom of the screen.
    exe "keepjumps silent bot ".g:decho_winheight."new"
    setlocal noswf
    exe "keepjumps b ".bufnr(g:decho_bufname)
   endif
 
   set ft=Decho
   setlocal noswapfile noro nobl fo=n2croql
 
   "  make sure DBG window is on the bottom
   wincmd J
  endif

  " Build Message
  let i  = 1
  let msg= ""
  while i <= a:0
   try
    exe "let msg=msg.a:".i
   catch /^Vim\%((\a\+)\)\=:E730/
       " looks like a:i is a list
    exe "let msg=msg.string(a:".i.")"
   endtry
   if i < a:0
    let msg=msg." "
   endif
   let i=i+1
  endwhile

  " Initialize message
  let smsg   = ""
  let idepth = 0
  while idepth < s:decho_depth
   let smsg   = "|".smsg
   let idepth = idepth + 1
  endwhile

  " Handle special characters (\t \r \n)
  " and append msg to smsg
  let i    = 1
  while msg != ""
   let chr  = strpart(msg,0,1)
   let msg  = strpart(msg,1)
   if char2nr(chr) < 32
   	let smsg = smsg.'^'.nr2char(64+char2nr(chr))
   else
    let smsg = smsg.chr
   endif
  endwhile

"  echomsg "g:dechomode=".g:dechomode
  if g:dechomode == s:DECHOMSG
   " display message with echomsg
   exe "echomsg '".substitute(smsg,"'","'.\"'\".'","ge")."'"

  elseif g:dechomode == s:DECHOVAR
   " "display" message by appending to variable named by g:dechovarname
   let smsg= substitute(smsg,"'","''","ge")
   if exists(g:dechovarname)
    exe "let ".g:dechovarname."= ".g:dechovarname.".'\n".smsg."'"
   else
    exe "let ".g:dechovarname."= '".smsg."'"
   endif

  elseif g:dechomode == s:DECHOREM
   " display message by appending it to remote DECHOREMOTE vim server
   let smsg= substitute(smsg,"\<esc>","\<c-v>\<esc>","ge")
   try
    call remote_send("DECHOREMOTE",'Go'.smsg."\<esc>".':set nomod'."\<cr>")
   catch /^Vim\%((\a\+)\)\=:E241/
       let g:dechomode= s:DECHOWIN
   endtry

  elseif g:dechomode == s:DECHOTAB
   " display message by appending it to the debugging tab window
   let eikeep= &ei
   let lzkeep= &lz
   set ei=all lz
   let g:dechotabcur = tabpagenr()
   exe "silent! tabn ".g:dechotabnr
   if !exists("t:dechotabpage")
	" looks like a new tab has been inserted -- look for a tab having t:dechotabpage
	let g:dechotabnr= 1
	silent! tabn 1
	while !exists("t:dechotabpage")
	 let g:dechotabnr= g:dechotabnr + 1
	 if g:dechotabnr > tabpagenr("$")
	  " re-generate the "Decho Tab" tab -- looks like it was closed!
	  call s:DechoTab(1)
      exe "tabn".g:dechotabnr
	  break
	 endif
     exe "tabn".g:dechotabnr
    endwhile
   endif

   " check that the debugging tab still has a debugging window left in it; use it
   " if present
   let dbgwin= bufwinnr(bufname("Decho Tab"))
   if dbgwin == -1
	" looks like only non-debugging windows are left in what had been the debugging tab.
	" Regenerate it.
	unlet t:dechotabpage
	call s:DechoTab(1)
    exe "tabn".g:dechotabnr
   else
	exe dbgwin."wincmd w"
   endif

   " append message to "Decho Tab" window in the debugging tab
   " echomsg "appending message to tab#".tabpagenr()
   setlocal ma noro
   call setline(line("$")+1,smsg)
   setlocal noma nomod
   " restore tab# to original user tab
   exe "tabn ".g:dechotabcur
   " echomsg "returning to tab#".tabpagenr()
   let &ei= eikeep
   let &lz= lzkeep

  else
   " Write Message to DBG buffer
   setlocal ma
   keepjumps $
   keepjumps let res= append("$",smsg)
   setlocal nomod
 
   " Put cursor at bottom of DBG window, then return to original window
   exe "res ".g:decho_winheight
   keepjumps norm! G
   if exists("g:decho_hide") && g:decho_hide > 0
    setlocal hidden
    q
   endif
   keepjumps wincmd p
   if exists("swp")
    call RestoreWinPosn(swp)
   endif
 
   if g:decho_bufenter
    let &ei= eikeep
	let &ea= eakeep
   endif
  endif
endfun

" ---------------------------------------------------------------------
"  Dfunc: just like Decho, except that it also bumps up the depth {{{1
"         It also appends a "{" to facilitate use of %
"         Usage:  call Dfunc("functionname([opt arglist])")
fun! Dfunc(...)
  " Build Message
  let i  = 1
  let msg= ""
  while i <= a:0
   exe "let msg=msg.a:".i
   if i < a:0
    let msg=msg." "
   endif
   let i=i+1
  endwhile
  let msg= msg." {"
  call Decho(msg)
  let s:decho_depth= s:decho_depth + 1
  let s:Dfunclist_{s:decho_depth}= substitute(msg,'[( \t].*$','','')
endfun

" ---------------------------------------------------------------------
"  Dret: just like Decho, except that it also bumps down the depth {{{1
"        It also appends a "}" to facilitate use of %
"         Usage:  call Dret("functionname [optional return] [: optional extra info]")
fun! Dret(...)
  " Build Message
  let i  = 1
  let msg= ""
  while i <= a:0
   exe "let msg=msg.a:".i
   if i < a:0
    let msg=msg." "
   endif
   let i=i+1
  endwhile
  let msg= msg." }"
  call Decho("return ".msg)
  if s:decho_depth > 0
   let retfunc= substitute(msg,'\s.*$','','e')
   if  retfunc != s:Dfunclist_{s:decho_depth}
   	echoerr "Dret: appears to be called by<".s:Dfunclist_{s:decho_depth}."> but returning from<".retfunc.">"
   endif
   unlet s:Dfunclist_{s:decho_depth}
   let s:decho_depth= s:decho_depth - 1
  endif
endfun

" ---------------------------------------------------------------------
" DechoOn: {{{1
fun! DechoOn(line1,line2)
  let ickeep= &ic
  set noic
  let swp    = SaveWinPosn(0)
  let dbgpat = '\<D\%(echo\|func\|redir\|ret\|echo\%(Msg\|Rem\|Tab\|Var\)O\%(n\|ff\)\)\>'
  if search(dbgpat,'cnw') == 0
   echoerr "this file<".expand("%")."> does not contain any Decho/Dfunc/Dret commands or function calls!"
  else
   exe "keepjumps ".a:line1.",".a:line2.'g/'.dbgpat.'/s/^"\+//'
  endif
  call RestoreWinPosn(swp)
  let &ic= ickeep
endfun

" ---------------------------------------------------------------------
" DechoOff: {{{1
fun! DechoOff(line1,line2)
  let ickeep= &ic
  set noic
  let swp=SaveWinPosn(0)
  let swp= SaveWinPosn(0)
  exe "keepjumps ".a:line1.",".a:line2.'g/\<D\%(echo\|func\|redir\|ret\|echo\%(Msg\|Rem\|Tab\|Var\)O\%(n\|ff\)\)\>/s/^[^"]/"&/'
  call RestoreWinPosn(swp)
  let &ic= ickeep
endfun

" ---------------------------------------------------------------------
" DechoDepth: allow user to force depth value {{{1
fun! DechoDepth(depth)
  let s:decho_depth= a:depth
endfun

" ---------------------------------------------------------------------
" s:DechoCtrlInit: initializes DechoCtrl variables {{{2
"    One of the DechoCMDOn commands calls this function with the associated CMD's mode
"    Instead of being immediate, the command's effect is deferred until the first Decho call.
"    Decho() calls DechoCtrl(), which in turn sets up the CMD's mode.
fun! s:DechoCtrlInit(mode,...)
  let s:DechoCtrlmode = a:mode
  if a:0 > 0
   let s:DechoCtrlfname= a:1
  endif
  if a:0 > 1
   let s:DechoCtrlargs = a:2
  elseif exists("s:DechoCtrlargs")
   unlet s:DechoCtrlargs
  endif
endfun

" ---------------------------------------------------------------------
" DechoCtrl: sets up the deferred CMD's mode {{{2
"            Also see DechoCtrlInit()
fun! s:DechoCtrl()

  if !exists("s:DechoCtrlmode")
   return
	
  elseif s:DechoCtrlmode == s:DECHOWIN
   let g:dechomode= s:DECHOWIN

  elseif s:DechoCtrlmode == s:DECHOMSG
   call s:DechoMsg(1,s:DechoCtrlfname)

  elseif s:DechoCtrlmode == s:DECHOVAR
   if exists("s:DechoCtrlargs")
	call s:DechoVarOn(s:DechoCtrlfname,s:DechoCtrlargs)
   else
	call s:DechoVarOn(s:DechoCtrlfname)
   endif

  elseif s:DechoCtrlmode == s:DECHOREM
   call s:DechoRemote(1,s:DechoCtrlfname)

  elseif s:DechoCtrlmode == s:DECHOTAB
   set lz
   call s:DechoTab(1,s:DechoCtrlfname)
   set nolz

  else
   echoerr "(s:DechoCtrl) bad mode#".s:DechoCtrlmode
  endif

  if exists("s:DechoCtrlmode") |unlet s:DechoCtrlmode |endif
  if exists("s:DechoCtrlfname")|unlet s:DechoCtrlfname|endif
  if exists("s:DechoCtrlargs") |unlet s:DechoCtrlargs |endif

endfun

" ---------------------------------------------------------------------
" s:DechoMsg: {{{2
fun! s:DechoMsg(onoff,...)
"  call Dfunc("s:DechoMsg(onoff=".a:onoff.") a:0=".a:0)
  if a:onoff
   let g:dechomode = s:DECHOMSG
   let g:dechofile = (a:0 > 0)? a:1 : ""
  else
   let g:dechomode= s:DECHOWIN
  endif
"  call Dret("s:DechoMsg")
endfun

" ---------------------------------------------------------------------
" Dhide: (un)hide DBG buffer {{{1
fun! <SID>Dhide(hide)

  if !bufexists(g:decho_bufname) && bufnr("*/".g:decho_bufname."$") == -1
   " DBG-buffer doesn't exist, simply set g:decho_hide
   let g:decho_hide= a:hide

  elseif bufwinnr(g:decho_bufname) > 0
   " DBG-buffer exists in a window, so its not currently hidden
   if a:hide == 0
   	" already visible!
    let g:decho_hide= a:hide
   else
   	" need to hide window.  Goto window and make hidden
	let curwin = winnr()
	let dbgwin = bufwinnr(g:decho_bufname)
    exe bufwinnr(g:decho_bufname)."wincmd W"
	setlocal hidden
	q
	if dbgwin != curwin
	 " return to previous window
     exe curwin."wincmd W"
	endif
   endif

  else
   " The DBG-buffer window is currently hidden.
   if a:hide == 0
	let curwin= winnr()
    exe "silent bot ".g:decho_winheight."new"
    setlocal bh=wipe
    exe "b ".bufnr(g:decho_bufname)
    exe curwin."wincmd W"
   else
   	let g:decho_hide= a:hide
   endif
  endif
  let g:decho_hide= a:hide
endfun

" ---------------------------------------------------------------------
" Dredir: this function performs a debugging redir by temporarily using {{{1
"         register a in a redir @a of the given command.  Register a's
"         original contents are restored.
"   Usage:  Dredir(["string","string",...,]"cmd")
fun! Dredir(...)
  if a:0 <= 0
   return
  endif
  let icmd = 1
  while icmd < a:0
   call Decho(a:{icmd})
   let icmd= icmd + 1
  endwhile
  let cmd= a:{icmd}

  " save register a, initialize
  let keep_rega = @a
  let v:errmsg  = ''

  " do the redir of the command to the register a
  try
   redir @a
    exe "keepjumps silent ".cmd
  catch /.*/
   let v:errmsg= substitute(v:exception,'^[^:]\+:','','e')
  finally
   redir END
   if v:errmsg == ''
   	let output= @a
   else
   	let output= v:errmsg
   endif
   let @a= keep_rega
  endtry

  " process output via Decho()
  while output != ""
   if output =~ "\n"
   	let redirline = substitute(output,'\n.*$','','e')
   	let output    = substitute(output,'^.\{-}\n\(.*$\)$','\1','e')
   else
   	let redirline = output
   	let output    = ""
   endif
   call Decho("redir<".cmd.">: ".redirline)
  endwhile
endfun

" ---------------------------------------------------------------------
" DechoSep: puts a separator with counter into debugging output {{{2
fun! DechoSep(...)
"  call Dfunc("DechoSep() a:0=".a:0)
  if !exists("s:dechosepcnt")
   let s:dechosepcnt= 1
  else
   let s:dechosepcnt= s:dechosepcnt + 1
  endif
  let eikeep= &ei
  set ei=all
  call Decho("--sep".s:dechosepcnt."--".((a:0 > 0)? " ".a:1 : ""))
  let &ei= eikeep
"  call Dret("DechoSep")
endfun

" ---------------------------------------------------------------------
" DechoPause: puts a pause-until-<cr> into operation; will place a {{{2
"             separator into the debug output for reporting
fun! DechoPause()
"  call Dfunc("DechoPause()")
  redraw!
  call DechoSep("(pause)")
  call inputsave()
  call input("Press <cr> to continue")
  call inputrestore()
"  call Dret("DechoPause")
endfun

 " ---------------------------------------------------------------------
 " DechoRemote: supports sending debugging to a remote vim {{{1
if has("clientserver") && executable("gvim")
 fun! s:DechoRemote(mode,...)
   if a:mode == 0
    " turn remote debugging off
    if g:dechomode == s:DECHOREM
    	let g:dechomode= s:DECHOWIN
    endif
 
   elseif a:mode == 1
    " turn remote debugging on
    if g:dechomode != s:DECHOREM
 	 let g:dechomode= s:DECHOREM
    endif
	let g:dechofile= (a:0 > 0)? a:1 : ""
    if serverlist() !~ '\<DECHOREMOTE\>'
 "   " start up remote Decho server
 "   call Decho("start up DECHOREMOTE server")
     if has("win32") && executable("start")
      call system("start gvim --servername DECHOREMOTE")
	 else
      call system("gvim --servername DECHOREMOTE")
	 endif
     while 1
      try
 	   call remote_send("DECHOREMOTE",':set ft=Decho fo-=at'."\<cr>")
       call remote_send("DECHOREMOTE",':file [Decho\ Remote\ Server]'."\<cr>")
 	   call remote_send("DECHOREMOTE",":put ='-----------------------------'\<cr>")
 	   call remote_send("DECHOREMOTE",":put ='Remote Decho Debugging Window'\<cr>")
 	   call remote_send("DECHOREMOTE",":put ='-----------------------------'\<cr>")
 	   call remote_send("DECHOREMOTE","1GddG")
	   call remote_send("DECHOREMOTE",':set noswf nomod nobl nonu ch=1 fo=n2croql nosi noai'."\<cr>")
 	   call remote_send("DECHOREMOTE",':'."\<cr>")
 	   call remote_send("DECHOREMOTE",':set ft=Decho'."\<cr>")
 	   call remote_send("DECHOREMOTE",':syn on'."\<cr>")
 	   break
      catch /^Vim\%((\a\+)\)\=:E241/
 	   sleep 200m
      endtry
     endwhile
    endif
 
   else
    echohl Warning | echomsg "DechoRemote(".a:mode.") not supported" | echohl None
   endif
 
 endfun
endif

" ---------------------------------------------------------------------
"  DechoVarOn: turu debugging-to-a-variable on.  The variable is given {{{1
"  by the user;   DechoVarOn [varname]
fun! s:DechoVarOn(...)
  let g:dechomode= s:DECHOVAR
  
  if a:0 > 0
   let g:dechofile= a:1
   if a:2 =~ '^g:'
    exe "let ".a:2.'= ""'
   else
    exe "let g:".a:2.'= ""'
   endif
  else
   let g:dechovarname= "g:dechovar"
  endif
endfun

" ---------------------------------------------------------------------
" DechoVarOff: {{{1
fun! s:DechoVarOff()
  if exists("g:dechovarname")
   if exists(g:dechovarname)
    exe "unlet ".g:dechovarname
   endif
  endif
  let g:dechomode= s:DECHOWIN
endfun

 " --------------------------------------------------------------------
 " DechoTab: {{{1
if v:version >= 700
 fun! s:DechoTab(mode,...)
   " call Dfunc("DechoTab(mode=".a:mode.") a:0=".a:0)
   echomsg "DechoTab(mode=".a:mode.") a:0=".a:0
 
   if a:mode
    let g:dechomode = s:DECHOTAB
	let g:dechofile = (a:0 > 0)? a:1 : ""
    let dechotabcur = tabpagenr()
"	echomsg "dechotabcur#".dechotabcur." g:dechotabnr".(exists("g:dechotabnr")? "#".g:dechotabnr : "-doesn't exist")
    if !exists("g:dechotabnr")
	 let eikeep= &ei
	 set ei=all
	 tabnew
	 file Decho\ Tab
	 let t:dechotabpage= 1
	 let g:dechotabnr  = tabpagenr()
"	 echomsg "setting g:dechotabnr#".g:dechotabnr." dechofile<".g:dechofile.">"
	 setlocal ma
	 put ='---------'
	 put ='Decho Tab '.g:dechofile
	 put ='---------'
	 norm! 1GddG
	 let &ei          = ""
	 set ft=Decho
	 set ei=all
	 setlocal noma nomod nobl noswf ch=1 fo=n2croql
	 exe "tabn ".dechotabcur
	 let &ei= eikeep
"	 echomsg "return to tab#".dechotabcur.": file<".expand("%").">"
	endif
   else
    let g:dechomode= s:DECHOWIN
   endif
 
   " call Dret("DechoTab")
 endfun
endif

" ---------------------------------------------------------------------
"  End Plugin: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" ---------------------------------------------------------------------
"  vim: ts=4 fdm=marker
