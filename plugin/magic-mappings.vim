" Setup mappings
if exists('g:MagicMapAll') && g:MagicMapAll == 1
    " Close quickfix if async job returned success
    fun! s:AsyncDone(onsuccess)
        if g:asyncrun_code == 0
            if a:onsuccess != ""
                exec a:onsuccess
            else
                cclose
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
        let l:ignore_list = ['build', 'vs2013', 'vs2015', 'lib', 'example']
        let l:ignore_string = join(map(l:ignore_list, '"--ignore ".v:val'))
        silent exe "AsyncRun! ".l:pgm . l:ignore_string . " " . a:searchy
    endfun
    command! -nargs=1 -bang AsyncGrep call s:AsyncGrep(<q-args>)

    command! -nargs=1 VGall silent exe "AsyncGrep " .<q-args>
    command! -nargs=1 VGsrc silent exe "AsyncGrep --cpp " .<q-args>. " ./src"
    command! -nargs=1 VGlay silent exe "AsyncGrep " .<q-args>. " ./data"
    command! -nargs=1 VGset silent exe "AsyncGrep " .<q-args>. " ./settings"
    command! -nargs=1 VGcin silent exe "AsyncGrep --cpp " .<q-args>. " ". expand('$DS_PLATFORM_090')

    let g:asyncrun_status = "stopped"

    " Git
    nmap <leader>gp :AsyncRun git push<cr>
    nmap <leader>gu :AsyncRun git pull<cr>

    " Compile for OSX & Windows using MagicJob()
    nnoremap <silent> <leader>bb :MCompile DEBUG<cr>
    nnoremap <silent> <leader>br :MCompile RELEASE<cr>
    nnoremap <silent> <leader>bt :MCompile! TEST<cr>
    nnoremap <silent> <leader>bd :MCompile DOC<cr>
    nnoremap <silent> <leader>B :MCompile! RELEASE<cr>
    nnoremap <silent> <leader>r :MCRun<cr>
    nnoremap <silent> <leader>bk :AsyncStop!<cr>

    " Alternate files (from LucHermitte/alternate-lite)
    nnoremap <silent> <leader>av :AV<cr>
    nnoremap <silent> <leader>ah :AS<cr>
    nnoremap <silent> <leader>as :A<cr>

    " Helpful ds_cinder jumps
    nnoremap <leader>em :e data/model/content_model.xml<cr>
    nnoremap <leader>el :e data/layouts/
    nnoremap <leader>es :e src/
    nnoremap <leader>es :e src/
    nnoremap <leader>sa :sav <c-r>=expand('%:h')<cr>/

    " Quickfix / MagicJob output
    nnoremap <leader>z :cclose<cr>
    nnoremap <leader>Z :copen<cr>
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
    augroup END
endif
