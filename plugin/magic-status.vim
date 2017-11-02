"   master  ~/Documents/git/dotfiles/.vimrc  vim  utf-8[unix]   Help  syntax.txt  
function! GitBranch()
  return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatuslineGit()
  " let l:branchname = substitute(fugitive#statusline(), 'Git(\(.\+\))', '\1', 'g')
  let l:branchname = fugitive#head()
  let l:out = '  '.l:branchname.'  '
  return strlen(l:branchname) > 0 ? l:out : ''
endfunction

function! StatuslineRo()
    return &readonly == 1 ? '  ' : ''
endfunction

function! MagicStatusLine(active)
    let l:line = ''
    if a:active
        let l:line.='%#Conceal#'
        " let l:line.='%#CursorLineNr#'
        let l:line.='%{StatuslineGit()}'
        " let l:line.='%{fugitive#statusline()}'
    endif
    let l:line.='%#LineNr#'
    let l:line.=' %f'
    let l:line.='%m '
    let l:line.='%='
    let l:line.=' %y '
    let l:line.='%#Conceal#%{StatuslineRo()}'

    if a:active
        if exists('g:MagicStatusJob') && g:MagicStatusJob !=# ''
            let l:line.='%#StatusLine#'
            let l:line.=g:MagicStatusJob.' '
        elseif exists('g:MagicStatusWarn') && g:MagicStatusWarn !=# ''
            let l:line.='%#CursorLineNr#'
            let l:line.=' '.g:MagicStatusWarn.' '
        endif
    endif
    return l:line
endfunction


function! MyTabLine()
    let l:s = '%#Conceal#'
    let l:s .= has('nvim')?'    ':'   '
    for l:i in range(tabpagenr('$'))
        " l:select the highlighting
        if l:i + 1 == tabpagenr()
            " let l:s .= '%#DiffChange#'
            let l:s .= '%#Conceal#'
            " let l:s .= '%#PmenuSel#'
        else
            " let l:s .= '%#Conceal#'
            let l:s .= '%#NonText#'
        endif

        " l:set the tab page number (for mouse clicks)
        let l:s .= '%' . (l:i + 1) . 'T'

        " the label is made by MyTabLabel()
        let l:s .= ' %{MyTabLabel(' . (l:i + 1) . ')} '
    endfor

    " after the last tab fill with TabLineFill and reset tab page nr
    let l:s .= '%#Conceal#'

    return l:s
endfunction


function! MyTabLabel(n)
    let l:buflist = tabpagebuflist(a:n)
    let l:winnr = tabpagewinnr(a:n)
    let l:bufname = bufname(l:buflist[l:winnr - 1])
    if l:bufname ==# '' | let l:bufname='[NULL]' | endif
    return a:n.' '.substitute(l:bufname, '.\+\/\(.\+\)', '\1', 'g')
endfunction

if exists('g:MagicStatusEnable')
    set statusline=%!MagicStatusLine(1)
    set showtabline=2
    set tabline=%!MyTabLine()
endif
