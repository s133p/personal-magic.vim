function! DoFancyBoxMenu( line, path, ft, type )
    let curline = line(".")
    if curline < g:MagicMenuSaveLineTop+1 || curline > g:MagicMenuSaveLineBot-1
        let @_ = input( "Out of bounds" )
        exe "bd %"
        return
    endif

    let doing = substitute( a:line, '\v^.\s+([a-zA-Z -_.].+'.a:ft.").+$", "\\1", "g" )
    let toOpen = a:path."/".doing
    exe "q"
    exe a:type . " " . substitute(toOpen, ' ', '\\ ', 'g')
    exe "setlocal bufhidden=delete"
    exe "vertical resize 80"
    exe "syn enable"
endfunction

function! FancyFileBox( title, path, ft, globbit )
    exe "nnoremap <silent> <buffer> <cr> :call DoFancyBoxMenu(getline('.'), \"".a:path."\", \"".a:ft."\", \"vsp\")<cr>"
    exe "nnoremap <silent> <buffer> t :call DoFancyBoxMenu(getline('.'), \"".a:path."\", \"".a:ft."\", \"tabnew\")<cr>"
    exe "nnoremap <silent> <buffer> V :call DoFancyBoxMenu(getline('.'), \"".a:path."\", \"".a:ft."\", \"sp\")<cr>"
    exe "normal! i| |"
    exe "normal! o| " . a:title ." |"
    exe "normal! o| |"

    let g:MagicMenuSaveLineTop = line(".")
    let notesfiles = split(globpath(a:path, a:globbit . a:ft), '\n')
    if len(notesfiles) != 0
        for notefile in notesfiles
            exe "normal! o| " . notefile[len(expand(a:path))+1: len(notefile)] . " |"
        endfor
        exe "normal! o| |"
        call feedkeys("gaip*|")
        call feedkeys(":g/|\\s\\+|/s/\ /-/g\<cr>")
        call feedkeys(":g/|-\\+|/s/\|/+/g\<cr>", 'x')
        let g:MagicMenuSaveLineBot = line(".")
        exe "normal! " . g:MagicMenuSaveLineTop . "Gj0"
    else
        let @_ = input( "No files (".a:globbit.a:ft.") in " . a:path )
        exe "bd %"
    endif
endfunction


function! DoMagicMenu( menuLine )
    exe "normal! ggVGd"
    let doing = substitute( a:menuLine, "\\v\\[ \\] (.+)$", "\\1", "g" )
    let path = g:magicMenu[doing][0]
    let ft = g:magicMenu[doing][1]
    if exists("g:magicMenu[\"".doing."\"][2]")
        let globbit = "*".g:magicMenu[doing][2]
    else
        let globbit = "*"
    endif
    call FancyFileBox(doing, path, ft, globbit)
endfunction

function! MagicMenu()
    autocmd!
    exe "vnew MagicBox"
    exe "vertical resize 80"
    exe "nnoremap <silent> <buffer> <esc> :q<cr>"
    exe "nnoremap <silent> <buffer> <cr> :call DoMagicMenu(getline('.'))<cr>"
    exe "setlocal buftype=nowrite bufhidden=wipe noswapfile"
    autocmd! bufLeave MagicBox exe "bd MagicBox"

    exe "normal! iMagicBox"
    exe "normal! yypVr=o"

    for key in keys(g:magicMenu)
        exe "normal! o[ ] ".key
    endfor
    exe "normal! 0l4G"
endfunction


" Example Config
" let g:magicMenu={"VIM-NOTES":["~/Dropbox/vim-notes",".md",""], "NV-NOTES":["~/Dropbox/NV-Notes",".txt",""], "CODE":["~/Desktop/CODE",".cpp","*\/*"]}
" let g:magicMenu["SCRIPT"]=["~/Desktop/script", ".vim"]
" let g:magicMenu[".VIM"]=["~/.vim/bundle/vim-magic-template", ".vim", "*\/*"]
" let g:magicMenu["GO"]=["~/Documents/goproj/src/github.com", ".go", "*\/*"]
" let g:magicMenu["MY_GO"]=["~/Documents/goproj/src/github.com/s133p", ".go", "*\/*"]
" nmap <leader>z :call MagicMenu()<cr>
