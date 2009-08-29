au BufNewFile,BufRead *.j setf objj
au BufNewFile,BufRead *.objj setf objj

augroup filetypedetect
    au BufNewFile,BufRead *.mkd,*.markdown      setfiletype mkd
augroup END
