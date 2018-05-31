" Setup mappings
if exists('g:MagicMapAll') && g:MagicMapAll == 1
    " Close quickfix if async job returned success
    fun! s:AsyncDone(onsuccess)
        if g:asyncrun_code == 0
            cclose
            if a:onsuccess != ""
                exec a:onsuccess
            endif
        else
            cwindow
        endif
    endfun
    command! -nargs=0 AsyncRunDone call s:AsyncDone("")
    command! -nargs=0 AsyncRunPost call s:AsyncDone("MCRun")

    fun! s:AsyncRunAutoClose(bang, cmd, post)
        if a:post != ""
            silent exe "AsyncRun".a:bang." -post=AsyncRunPost ".a:cmd
        else
            silent exe "AsyncRun".a:bang." -post=AsyncRunDone ".a:cmd
        endif
    endfun
    command! -nargs=1 -bang AsyncRunAutoClose call s:AsyncRunAutoClose('<bang>', <q-args>, "")
    command! -nargs=1 -bang AsyncRunAutoPost call s:AsyncRunAutoClose('<bang>', <q-args>, "MCRun")

    " Magicified grep commands my common use cases
    fun! s:AsyncGrep(searchy)
        " echom a:searchy
        let l:pgm = '-program=grep '
        let l:ignore_prefix = '--ignore '
        let l:ignore_list = ['build', 'vs2013', 'vs2015', 'lib']
        let l:ignore_string = join(map(l:ignore_list, '"--ignore ".v:val'))
        silent exe "AsyncRun! ".l:pgm . l:ignore_string . " " . a:searchy
    endfun
    command! -nargs=1 -bang AsyncGrep call s:AsyncGrep(<q-args>)

    command! -nargs=1 VGall silent exe "AsyncGrep " .<q-args>
    command! -nargs=1 VGsrc silent exe "AsyncGrep --cpp " .<q-args>. " ./src"
    command! -nargs=1 VGlay silent exe "AsyncGrep " .<q-args>. " ./data"
    command! -nargs=1 VGset silent exe "AsyncGrep " .<q-args>. " ./settings"
    command! -nargs=1 VGcin silent exe "AsyncGrep --cpp " .<q-args>. " ". expand('$DS_PLATFORM_090')

    " Git
    nmap <leader>gp :AsyncRun git push<cr>
    nmap <leader>gu :AsyncRun git pull<cr>

    " Compile for OSX & Windows using MagicJob()
    nmap <silent> <leader>bb :MCompile DEBUG<cr>
    nmap <silent> <leader>br :MCompile RELEASE<cr>
    nmap <silent> <leader>bt :MCompile! TEST<cr>
    nmap <silent> <leader>bd :MCompile DOC<cr>
    nmap <silent> <leader>B :MCompile! RELEASE<cr>
    nmap <silent> <leader>r :MCRun<cr>
    nmap <silent> <leader>bk :AsyncStop!<cr>

    nnoremap <silent> <leader>ep :e ~/.vim/bundle/personal-magic.vim/<cr>

    " Quickfix / MagicJob output
    nmap <leader>z :cclose<cr>
    nnoremap <silent> <leader>o :MagicOpen<cr>
    nnoremap <silent> <leader>O :MagicOpen!<cr>
    nmap <leader>gx <Plug>(DevOpen)

    " Custom operator-pending mappings & pairings
    map s <Plug>(MagicStamp)
    nmap S v$h<Plug>(MagicStamp)
    nmap ss V<Plug>(MagicStamp)

    map <leader>y <Plug>(MagicClip)
    nmap <leader>Y v$h<Plug>(MagicClip)

    map <leader>s <Plug>(MagicPaste)
    nmap <leader>S v$h<Plug>(MagicPaste)
    nnoremap <leader>p "*p
    nnoremap <leader>P "*P

    map <leader>c <Plug>(MagicCalc)
    nmap <leader>C v$h<Plug>(MagicCalc)

    map <leader>ms <Plug>(MagicSearch)
    map <leader>mc <Plug>(MagicCinderSearch)

    nmap <leader>sb <Plug>(MagicSuperSearch)

    "Replacements for vim-unimpaired
    nnoremap <silent> coh :set hlsearch!<cr>
    nnoremap <silent> cos :set spell!<cr>
    nnoremap <silent> cow :CleanWhitespace<cr>
    nnoremap <silent> cox :XmlClean<cr>
    nnoremap <silent> cob :BufWipe<cr>
    nnoremap <silent> coB :BufWipe!<cr>
    nnoremap cof :up<cr>:CFormat<cr>:up<cr>
    nnoremap coF :up<cr>:CFormat!<cr>:up<cr>

    augroup MagicMapAugroup
        autocmd!
        " Mappings for ease ds_cinder engine resizing
        autocmd FileType c,cpp,xml setlocal includeexpr=MagicIncludeExpr(v:fname)
        if v:version >= 700
            au BufLeave * let b:winview = winsaveview()
            au BufEnter * if(exists('b:winview')) | call winrestview(b:winview) | unlet b:winview | endif
        endif
    augroup END
endif
