augroup filetypedetect
    " cappuccino, objective j
    au BufNewFile,BufRead *.j setf objj
    au BufNewFile,BufRead *.objj setf objj
    " filetype for mkd
    au BufNewFile,BufRead *.mkd,*.markdown      setfiletype mkd
    " lowlight ^M symbol.
    au BufRead *.c,*.h match Ignore /\r$/ | hi Ignore ctermfg=bg
    " use better colorscheme to edit HTML
    au BufRead *.htm*,*.css,*.js colorscheme ir_black_cterm
    " Set default fdm for *.c,*.h file
    au BufRead *.c,*.h set fdm=syntax
    " set Spell check: ON when svn,git commit
    au BufRead svn-commit.*.tmp,COMMIT_EDITMSG :set spell
augroup END
