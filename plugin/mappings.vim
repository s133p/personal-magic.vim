" Setup mappings
if exists('g:MagicMapAll') && g:MagicMapAll == 1

    " Git
    nmap <leader>gp :MagicJobS git push<cr>
    nmap <leader>gu :MagicJobS git pull<cr>

    " Compile for OSX & Windows using MagicJob()
    nmap <silent> <leader>b :MCompile DEBUG<cr>
    nmap <silent> <leader>B :MCompile RELEASE<cr>
    nmap <silent> <leader>r :MCRun<cr>
    nmap <silent> <leader>jk :call MagicJobKill()<cr>

    vmap <leader>t <Plug>(MagicTemplate)

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
    map <leader>mm <Plug>(MagicMathBuf)
    "Replacements for vim-unimpaired
    nnoremap <silent> coh :set hlsearch!<cr>
    nnoremap <silent> cos :set spell!<cr>
    nnoremap <silent> cow :CleanWhitespace<cr>
    nnoremap cof :up<cr>:CFormat!<cr>:up<cr>

    augroup MagicMapAugroup
        autocmd!
        " Mappings for ease ds_cinder engine resizing
        autocmd BufReadPost engine.xml nnoremap <buffer> <leader>ef :DsFillEngine<cr>
        autocmd BufReadPost engine.xml nnoremap <buffer> <leader>es :DsScaleEngine<cr>
        " Call yaml generator
        if has('win32')
            autocmd BufReadPost model.yml nnoremap <buffer> <leader>G :!start /Users/luke.purcell/Documents/git/ds_cinder/utility/yaml_importer/yaml_importer.exe %<cr>
        endif
    augroup END
endif
