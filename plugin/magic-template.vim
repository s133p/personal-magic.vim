fun! s:MakeTemplate()
    let g:template = @"
    let g:templateVars = []
    let l:m = matchstrpos(g:template, '%\w\{-}%')
    while l:m[1] != -1
        if index(g:templateVars, l:m[0]) == -1
            let g:templateVars = add(g:templateVars, l:m[0])
        endif
        let l:m = matchstrpos(g:template, '%\w\{-}%', l:m[2])
    endwhile

    let l:output = g:template
    for l:item in g:templateVars
        let l:output = substitute(l:output, l:item, input(l:item. ': '), 'g')
    endfor
    return l:output
endfun

vnoremap <Plug>(MagicTemplate) c<c-r>=<SID>MakeTemplate()<cr>

