au BufNewFile,BufRead *.j setf objj
au BufNewFile,BufRead *.objj setf objj

augroup filetypedetect
    au BufNewFile,BufRead *.mkd,*.markdown      setfiletype mkd
    au BufRead *.c,*.h match Ignore /\r$/ | hi Ignore ctermfg=bg
    au BufRead *.htm*,*.css,*.js colorscheme ir_black_cterm
augroup END
