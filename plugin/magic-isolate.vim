" fun! MagicIsolateFinish()
" endfun
fun! OpenIsolateBuf(contents, parent, filetype)
    let l:name = 'mIso://'.a:parent
    silent exe 'e ' . l:name
    setlocal bufhidden=wipe buftype=nofile nobuflisted nolist noswapfile nowrap
    silent exe 'setlocal filetype='.a:filetype
    norm! pggdd
    nmap <buffer> <Leader>w ggVGygbgvp
    nmap <buffer> <Leader>x gb
    nmap <buffer> <Esc> gb
    "call append(0, split(a:contents, ''))
endfun

fun! MagicIsolate(type)
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
    let l:contents = @"


    call OpenIsolateBuf(l:contents, expand('%:t'), &ft)

    let &selection = l:sel_save
    let @@ = l:reg_save

endfun

nnoremap <Plug>(MagicIsolate) :set opfunc=MagicIsolate<CR>g@
vnoremap <Plug>(MagicIsolate) :<C-U>call MagicIsolate(visualmode())<CR>
map ;i <Plug>(MagicIsolate)

fun! MagicBuffers(bang)
    let l:name = 'MagicBuffers://ls'
    silent exe 'e ' . l:name
    setlocal bufhidden=wipe buftype=nofile nobuflisted nolist noswapfile nowrap noreadonly

    norm! ggVGd
    let l:buffers = filter(range(1, bufnr('$')), a:bang==#'!' ? 'bufexists(v:val)' : 'buflisted(v:val)')

    call append(line('$'), map(l:buffers, 'bufname(v:val)'))
    norm! dd
    setlocal readonly
    redraw!
    " silent exe l:outWin." wincmd w | call append(line('$'), " . string(s:outList) . ")". " | norm!G"

    nmap <silent><buffer> <cr> 0Y:b <c-r>"<cr>

    nmap <silent><buffer> <Leader>x gb
    nmap <silent><buffer> <Esc> gb
    "call append(0, split(a:contents, ''))
endfun
