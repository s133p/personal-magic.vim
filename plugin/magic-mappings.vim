" Setup mappings
if exists('g:MagicMapAll') && g:MagicMapAll == 1
    " Commands
    command! -nargs=1 -complete=buffer VGall exe "noautocmd vimgrep /" . <q-args> . "/j **/* \| copen"
    command! -nargs=1 -complete=buffer VGsrc exe "noautocmd vimgrep /" . <q-args> . "/j src/**/* \| copen"
    command! -nargs=1 -complete=buffer VGlay exe "noautocmd vimgrep /" . <q-args> . "/j data/layout*/**/* \| copen"
    command! -nargs=1 -complete=buffer VGset exe "noautocmd vimgrep /" . <q-args> . "/j settings/**/* \| copen"
    command! -nargs=1 -complete=buffer VGcin exe "noautocmd vimgrep /" . <q-args> . "/j ~/code/ds_cinder/**/src/ds/**/*.{cpp,h} \| copen"

    " Git
    nmap <leader>gp :8MagicJobS git push<cr>
    nmap <leader>gu :8MagicJobS git pull<cr>

    " Compile for OSX & Windows using MagicJob()
    nmap <silent> <leader>b :MCompile DEBUG<cr>
    nmap <silent> <leader>B :MCompile RELEASE<cr>
    nmap <silent> <leader>r :MCRun<cr>
    nmap <silent> <leader>jk :call MagicJobKill()<cr>

    vmap <leader>t <Plug>(MagicTemplate)

    nmap <leader>ab :call MagicBuffers('')<cr>/
    nmap <leader>aB :call MagicBuffers('!')<cr>/

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
    nnoremap <silent> coS :MakeLocalSln<cr>
    nnoremap <silent> cow :CleanWhitespace<cr>
    nnoremap <silent> cox :XmlClean<cr>
    nnoremap <silent> cob :BufWipe<cr>
    nnoremap <silent> coB :BufWipe!<cr>
    nnoremap <silent> com :MagicBufferOpen<cr>
    nnoremap cof :up<cr>:CFormat<cr>:up<cr>
    nnoremap coF :up<cr>:CFormat!<cr>:up<cr>

    augroup MagicMapAugroup
        autocmd!
        " Mappings for ease ds_cinder engine resizing
        autocmd BufReadPost engine.xml nnoremap <buffer> <leader>ef :DsFillEngine<cr>
        autocmd BufReadPost engine.xml nnoremap <buffer> <leader>es :DsScaleEngine<cr>
        autocmd FileType c,cpp,xml setlocal includeexpr=MagicIncludeExpr(v:fname)
        " Call yaml generator
        if has('win32')
            autocmd BufReadPost model.yml nnoremap <buffer> <leader>G :!start /Users/luke.purcell/Documents/git/ds_cinder/utility/yaml_importer/yaml_importer.exe %<cr>
        endif
    augroup END
endif
