fun! s:OpenTemplateBuf(type, ...)
    let l:cft = &ft

    let l:sel_save = &selection
    let &selection = 'inclusive'
    let l:reg_save = @@

    if a:type ==? 'v'  " Invoked from Visual mode, use gv command.
        silent exe 'normal! gvy'
    elseif a:type ==? 'line'
        silent exe "normal! '[V']y"
    else
        silent exe 'normal! `[v`]y'
    endif


    if bufnr(':MagicTemplate:') ==# -1
        silent new :MagicTemplate:
        wincmd K
    elseif bufwinnr(':MagicTemplate:') !=# -1
        silent exe bufwinnr(':MagicTemplate:') . 'wincmd w'
    elseif bufwinnr(':MagicTemplate:') ==# -1
        silent split
        silent exe 'b ' . bufnr(':MagicTemplate:')
        silent exe 'wincmd K'
    endif

    setlocal bufhidden=delete buftype=nofile nobuflisted nolist noswapfile nowrap
    exe 'setlocal filetype='.l:cft
    silent resize 12
    exe 'norm! ggVGp'
    nmap <buffer> ;b ggVG<Plug>(MagicTemplate)
    nmap <buffer> q ggVGy:bw<cr>


    let &selection = l:sel_save
    let @@ = l:reg_save
endfun

nnoremap <Plug>(MagicTemplateBuffer) :set opfunc=<SID>OpenTemplateBuf<CR>g@
vnoremap <Plug>(MagicTemplateBuffer) :<C-U>call <SID>OpenTemplateBuf(visualmode())<CR>
map ;T <Plug>(MagicTemplateBuffer)

fun! s:MakeTemplate()
    exe 'norm! gvy'
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
    let @" = l:output
    exe 'norm! gvp'
endfun

vnoremap <Plug>(MagicTemplate) <esc>:call <SID>MakeTemplate()<cr>
