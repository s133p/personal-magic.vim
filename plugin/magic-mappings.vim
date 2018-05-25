" Setup mappings
if exists('g:MagicMapAll') && g:MagicMapAll == 1
    " Commands
    command! -nargs=1 VGall silent exe "AsyncRun! -program=grep --ignore build --ignore vs2015 --ignore vs2013 " .<q-args>
    command! -nargs=1 VGsrc silent exe "AsyncRun! -program=grep --cpp --ignore build --ignore vs2015 --ignore vs2013 " .<q-args>. " ./src"
    command! -nargs=1 VGlay silent exe "AsyncRun! -program=grep --ignore build --ignore vs2015 --ignore vs2013 " .<q-args>. " ./data"
    command! -nargs=1 VGset silent exe "AsyncRun! -program=grep --ignore build --ignore vs2015 --ignore vs2013 " .<q-args>. " ./settings"
    command! -nargs=1 VGcin silent exe "AsyncRun! -program=grep --cpp --ignore build --ignore vs2015 --ignore vs2013 --ignore example " .<q-args>. " ". expand('$DS_PLATFORM_090')

    " Git
    nmap <leader>gp :AsyncRun git push<cr>
    nmap <leader>gu :AsyncRun git pull<cr>

    " Compile for OSX & Windows using MagicJob()
    nmap <silent> <leader>bd :MCompile DEBUG<cr>
    nmap <silent> <leader>br :MCompile RELEASE<cr>
    nmap <silent> <leader>B :MCompile RELEASE<cr>
    nmap <silent> <leader>r :MCRun<cr>
    nmap <silent> <leader>jk :AsyncStop!<cr>

    nnoremap <silent> <leader>ep :e ~/.vim/bundle/personal-magic.vim/<cr>

    " Quickfix / MagicJob output
    nmap <leader>z :QfToggle<cr>
    nmap <leader>Z :MagicBufferOpen<cr>
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
