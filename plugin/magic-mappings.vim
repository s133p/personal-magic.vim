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
        let l:ignore_list = ['build', 'vs2015', 'vs2019', 'lib', 'example']
        let l:ignore_string = join(map(l:ignore_list, '"--ignore ".v:val'))
        silent exe "AsyncRun! ".l:pgm . l:ignore_string . " " . a:searchy
    endfun
    command! -nargs=1 -bang AsyncGrep call s:AsyncGrep(<q-args>)

    command! -nargs=1 VGall silent exe "AsyncGrep " .<q-args>
    command! -nargs=1 VGsrc silent exe "AsyncGrep --cpp " .<q-args>. " ./src"
    command! -nargs=1 VGlay silent exe "AsyncGrep " .<q-args>. " ./data"
    command! -nargs=1 VGset silent exe "AsyncGrep " .<q-args>. " ./settings"
    command! -nargs=1 VGcin silent exe "AsyncGrep --cpp " .<q-args>. " ../ds_cinder"
    command! -nargs=1 VGnot silent exe "AsyncGrep --markdown " .<q-args>. " C:/Users/luke.purcell/zettelkasten"

    let g:asyncrun_status = "stopped"

    " Git
    nmap <leader>gp :AsyncRun git push<cr>
    nmap <leader>gu :AsyncRun git pull<cr>

    " Compile for OSX & Windows using MagicJob()
    nnoremap <silent> <leader>bb :AsyncTaskProfile debug<cr>:AsyncTask build<cr>
    nnoremap <silent> <leader>br :AsyncTaskProfile release<cr>:AsyncTask build<cr>
    nnoremap <silent> <leader>bt :AsyncTask test<cr>
    nnoremap <silent> <leader>r :AsyncTask run<cr>
    nnoremap <silent> <leader>bk :AsyncStop<cr>
    nnoremap <silent> <leader>bK :AsyncStop<cr>

    " Helpful ds_cinder jumps
    nnoremap <leader>sa :sav <c-r>=expand('%:h')<cr>/

    " Quickfix / MagicJob output
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

    map <leader>ms <Plug>(MagicSearch)
    map <leader>mw <Plug>(MagicWikiSearch)
    map <leader>mc <Plug>(MagicCinderSearch)
    map <leader>mn <Plug>(MagicNoteSearch)

    nmap <leader>sb <Plug>(MagicSuperSearch)

    "Replacements for vim-unimpaired
    nnoremap <silent> coh :set hlsearch!<cr>
    nnoremap <silent> cos :set spell!<cr>
    nnoremap <silent> cox :XmlClean<cr>
    nnoremap <silent> cob :BufWipe<cr>
    nnoremap <silent> coB :BufWipe!<cr>

    augroup MagicMapAugroup
        autocmd!
        " Mappings for ease ds_cinder engine resizing
        autocmd FileType c,cpp,xml setlocal includeexpr=MagicIncludeExpr(v:fname)
    augroup END
endif
