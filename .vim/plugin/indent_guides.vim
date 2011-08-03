" Author:   Nate Kane <nathanaelkane AT gmail DOT com>
" Homepage: http://github.com/nathanaelkane/vim-indent-guides

if exists('g:loaded_indent_guides') || &cp
  finish
endif
let g:loaded_indent_guides = 1
call indent_guides#define_default_highlights()

function! s:IndentGuidesToggle()
  call indent_guides#toggle()
endfunction

function! s:IndentGuidesEnable()
  call indent_guides#enable()
endfunction

function! s:IndentGuidesDisable()
  call indent_guides#disable()
endfunction

" Commands
command! IndentGuidesToggle  call s:IndentGuidesToggle()
command! IndentGuidesEnable  call s:IndentGuidesEnable()
command! IndentGuidesDisable call s:IndentGuidesDisable()

"
" Initializes a given variable to a given value. The variable is only
" initialized if it does not exist prior.
"
function s:InitVariable(var, value)
  if !exists(a:var)
    if type(a:var) == type("")
      exec 'let ' . a:var . ' = ' . "'" . a:value . "'"
    else
      exec 'let ' . a:var . ' = ' .  a:value
    endif
  endif
endfunction

" Fixed global variables
let g:indent_guides_autocmds_enabled         = 0
let g:indent_guides_color_hex_pattern        = '#[0-9A-Fa-f]\{6\}'
let g:indent_guides_color_hex_guibg_pattern  = 'guibg=\zs' . g:indent_guides_color_hex_pattern . '\ze'
let g:indent_guides_color_name_guibg_pattern = "guibg='\\?\\zs[0-9A-Za-z ]\\+\\ze'\\?"

" Configurable global variables
call s:InitVariable('g:indent_guides_indent_levels',        30)
call s:InitVariable('g:indent_guides_auto_colors',          1 )
call s:InitVariable('g:indent_guides_color_change_percent', 5 ) " ie. 5%
call s:InitVariable('g:indent_guides_guide_size',           0 )
call s:InitVariable('g:indent_guides_start_level',          1 )
call s:InitVariable('g:indent_guides_debug',                0 )

" Default mapping
nmap <Leader>ig :IndentGuidesToggle<CR>

" Auto commands
augroup indent_guides
  autocmd!
  autocmd BufEnter,WinEnter * call indent_guides#process_autocmds()
augroup END

