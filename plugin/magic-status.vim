function! GitBranch()
  return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatuslineGit()
  let l:branchname = GitBranch()
  let l:out = '  '.l:branchname.'  '
  return strlen(l:branchname) > 0?l:out:''
endfunction

function! StatuslineRo()
    return &readonly == 1 ? '%#CursorLineNr# ' : ''
endfunction

function! MagicStatusLine(active)
    let l:line = ''
    if a:active
        let l:line.='%#CursorLineNr#'
        let l:line.='%{StatuslineGit()}'
    endif
    let l:line.='%#StatusLine#'
    let l:line.=' %f'
    let l:line.='%m '
    let l:line.='%='
    let l:line.=' %y '
    let l:line.='%{StatuslineRo()}'

    if a:active
        if exists('g:MagicStatusJob') && g:MagicStatusJob != ''
            let l:line.='%#StatusLine#'
            let l:line.=g:MagicStatusJob.' '
        elseif exists('g:MagicStatusWarn') && g:MagicStatusWarn != ''
            let l:line.='%#CursorLineNr#'
            let l:line.=' '.g:MagicStatusWarn.' '
        endif
    endif
    return l:line
endfunction

 "  master  ~/Documents/git/dotfiles/.vimrc  vim  utf-8[unix]   Help  syntax.txt  
" set statusline+=%#CursorLineNr#
" set statusline+=%{StatuslineGit()}
" set statusline+=%#StatusLineNC#\ 
" set statusline+=%#StatusLine#
" set statusline+=\ %f
" set statusline+=%m\ 
" set statusline+=%=
" set statusline+=\ %y\ 
" set statusline+=%#CursorLineNr#
" set statusline+=%{StatuslineRo()}

set showtabline=2
set tabline=MyTabLine()
function! MyTabLine()
    let s = ''
    for i in range(tabpagenr('$'))
        " select the highlighting
        if i + 1 == tabpagenr()
            let s .= '%#CursorLineNr#'
        else
            let s .= '%#TabLine#'
        endif

        " set the tab page number (for mouse clicks)
        let s .= '%' . (i + 1) . 'T'

        " the label is made by MyTabLabel()
        let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
    endfor

    " after the last tab fill with TabLineFill and reset tab page nr
    let s .= '%#TabLineFill#%T'

    " right-align the label to close the current tab page
    if tabpagenr('$') > 1
        let s .= '%=%#TabLine#%999X[ X ]'
    endif

    return s
endfunction


function! MyTabLabel(n)
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    return a:n." ".substitute(bufname(buflist[winnr - 1]), '.\+\/\(.\+\)', '\1', 'g')
endfunction
