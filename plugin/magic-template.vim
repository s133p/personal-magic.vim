fun! OpenSpecialBufs(names, filetype, isTop)
    let l:isFirst = 1
    let l:buffers = {}
    for l:name in a:names
        if bufnr(l:name) ==# -1
            silent exe 'vnew ' . l:name
        elseif bufwinnr(l:name) !=# -1
            silent exe bufwinnr(l:name) . 'wincmd w'
        endif

        setlocal bufhidden=delete buftype=nofile nobuflisted nolist noswapfile nowrap
        silent exe 'setlocal filetype='.a:filetype

        if l:isFirst
            let l:isFirst = 0
            if a:isTop
                wincmd K
            else
                wincmd J
            endif
            silent resize 16
        endif
        let l:buffers[l:name] = bufwinnr(l:name)

    endfor

    return l:buffers

endfun

fun! s:MakeTemplateMap(input)
    let l:template = a:input
    let l:templateVars = []
    let l:m = matchstrpos(l:template, '%\w\{-}%')
    while l:m[1] != -1
        if index(l:templateVars, l:m[0]) == -1
            let l:templateVars = add(l:templateVars, l:m[0])
        endif
        let l:m = matchstrpos(l:template, '%\w\{-}%', l:m[2])
    endwhile
    return l:templateVars

    " let l:output = l:template
    " for l:item in l:templateVars
    "     let l:output = substitute(l:output, l:item, input(l:item. ': '), 'g')
    " endfor
    " let @" = l:output
    " exe 'norm! gvp'
endfun

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
    let g:magicTemplate = @"
    let g:templateMap = {}

    let l:templateBufs = OpenSpecialBufs([':MagicTemplate:',':MagicTemplateInput:',':MagicTemplateOutput:'], l:cft, 1)
    nmap <Plug>(GoToTemplateMain) :silent exe bufwinnr(':MagicTemplate:')."wincmd w"<cr>
    nmap <Plug>(GoToTemplateInput) :silent exe bufwinnr(':MagicTemplateInput:')."wincmd w"<cr>
    nmap <Plug>(GoToTemplateOutput) :silent exe bufwinnr(':MagicTemplateOutput:')."wincmd w"<cr>

    " Template Buffer setup
    silent exe bufwinnr(':MagicTemplate:') . 'wincmd w'
    silent exe 'norm! ggVGp'
    nmap <buffer><Plug>(StarReplace) *:%s//%%/g<left><left><left>
    nmap <buffer> <leader>* <Plug>(StarReplace)

    vmap <buffer><Plug>(VStarReplace) "xy:%s/<c-r>=escape(@x, '/\\*.+^$')<cr>/%%/g<left><left><left>
    vmap <buffer> <leader>* <Plug>(VStarReplace)

    nmap <buffer><Plug>(UpdateInputs) ggVGy:let g:magicTemplate=@"<cr><Plug>(GoToTemplateInput)<Plug>(FullInputUpdate)
    nmap <buffer> <leader>w <Plug>(UpdateInputs)


    nmap <buffer><Plug>(CloseAllTemplates) <Plug>(GoToTemplateInput):bw<cr><Plug>(GoToTemplateOutput)ggVGy:bw<cr><Plug>(GoToTemplateMain):bw<cr>
    nmap <buffer> <leader>x <Plug>(CloseAllTemplates)
    nmap <buffer> Q <Plug>(CloseAllTemplates)

    " Input Buffer Setup
    silent exe bufwinnr(':MagicTemplateInput:') . 'wincmd w'

    " Map some shit
    nmap <buffer><Plug>(MakeTemplateMapFromQuote) :let g:templateVars = map(<Sid>MakeTemplateMap(g:magicTemplate), 'v:val . " : "')<cr>
    nmap <buffer><Plug>(UpdateInputBuf) :%d\|call append(line('$'), g:templateVars)<cr>dd:%EasyAlign/:/dr<cr>f:
    nmap <buffer><Plug>(FullInputUpdate) <Plug>(MakeTemplateMapFromQuote)<Plug>(UpdateInputBuf)
    nmap <buffer><leader>r <Plug>(FullInputUpdate)
    nmap <buffer><leader>z <Plug>(UpdateInputBuf)

    silent exe 'nmap <buffer><Plug>(DoTemplateOut) ' . bufwinnr(':MagicTemplateOutput:').'<c-w><c-w>:%d \| call append(0, split(g:templateOutput, "\n"))<cr>gg'
    nmap <buffer><Plug>(DoFormat) :%s/\(%\w\+%\)\s\+:\(.\+\)/['\1']='\2'/g<cr>
    nmap <buffer><Plug>(DoMakeMap) :let g:templateMap={}<cr>:g/\['/exe "let g:templateMap".getline('.')<cr>
    nmap <buffer><Plug>(DoBuildTemplate) :let g:templateOutput = MakeTemplate(g:magicTemplate, g:templateMap)<cr>
    nmap <buffer> <leader>w <Plug>(DoFormat)<Plug>(DoMakeMap)<Plug>(DoBuildTemplate)u<Plug>(DoTemplateOut)

    " Back to main template
    silent exe bufwinnr(':MagicTemplate:') . 'wincmd w'

    let &selection = l:sel_save
    let @@ = l:reg_save
endfun

nnoremap <Plug>(MagicTemplateBuffer) :set opfunc=<SID>OpenTemplateBuf<CR>g@
vnoremap <Plug>(MagicTemplateBuffer) :<C-U>call <SID>OpenTemplateBuf(visualmode())<CR>
map ;T <Plug>(MagicTemplateBuffer)

fun! MakeTemplate(template, input)
    let l:template = a:template

    for l:item in keys(a:input)
        let l:template = substitute(l:template, l:item, a:input[l:item], 'g')
    endfor
    return l:template
endfun

" %PROJECT%         :test
" %INSTALL_SITES%   :home
" %DS_BRANCH%       :091
" %CINDER_BRANCH%   :091
" %CMS_URL%         :localhost
" %DESIGNERS%       :luke
" %PROJECT_MANAGER% :also luke

" vnoremap <Plug>(MagicTemplate) <esc>:call <SID>MakeTemplate()<cr>
