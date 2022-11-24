function! StatuslineRo()
    return &readonly == 1 ? '  ' : ''
endfunction

function! s:MagicGitStatus()
    let b:gitUncommitted = (system('git diff-index --quiet HEAD -- || echo 1')[0] !=# '1')
    let b:gitUnpushed = (system('git diff-index @{u} --quiet || echo 1')[0] ==# '1')
endfunction

function! StatusDiagnostic() abort
  let info = get(b:, 'coc_diagnostic_info', {})
  if empty(info) | return '' | endif
  let msgs = []
  if get(info, 'error', 0)
    call add(msgs, '🚩' . info['error'])
  endif
  if get(info, 'warning', 0)
    call add(msgs, '🔥' . info['warning'])
  endif
  return join(msgs, ' '). ' ' . get(g:, 'coc_status', '')
endfunction

function! MagicStatusLine(active)
    let l:line = ''
    let l:branchname = FugitiveHead()
    if a:active && strlen(l:branchname) > 0
        " Highlight the branch name if there are uncommitted changes
        if exists('b:gitUncommitted') && b:gitUncommitted
            let l:line.='%#Conceal#'
        else
            let l:line.='%#DiffChange#'
        endif
        let l:line.='  '.l:branchname

        " Keep branch marker highlighed if there are unpushed commits
        if exists('b:gitUnpushed') && b:gitUnpushed
            let l:line.=' %#DiffChange#'
        endif
        let l:line.='  '

        let l:line.='%#TabLineSel#'
    else
        let l:line.='%#TabLine#'
    endif


    let l:line.='  %f'
    let l:line.='%m '
    let l:line.='%='
    let l:line.='%{StatusDiagnostic()}'
    let l:line.='%y '
    " let l:line.='%#Conceal#%{StatuslineRo()}'

    if a:active && exists("g:asynctasks_last") && g:asynctasks_last != ""
        let l:line.='{' . g:asynctasks_last . ' ' . g:asynctasks_profile
        if g:asyncrun_status ==# "stopped"
            let l:line.=' 🛑'
        elseif g:asyncrun_status ==# "success"
            let l:line.=' ✅'
        elseif g:asyncrun_status ==# "running"
            let l:line.=' ⏲️ '
        else "failure
            let l:line.=' ❗'
        endif

        if exists('g:MagicStatusJob') && g:MagicStatusJob !=# ''
            let l:line.='%#StatusLine#'
            let l:line.=g:MagicStatusJob.' '
        elseif exists('g:MagicStatusWarn') && g:MagicStatusWarn !=# ''
            let l:line.='%#DiffChange#'
            let l:line.=' '.g:MagicStatusWarn.' '
        endif
        let l:line.='}'
    endif
    return l:line
endfunction


function! MyTabLine()
    let l:s = '%#TabLineFill#'
    let l:s .= has('nvim')?'    ':'   '
    for l:i in range(tabpagenr('$'))
        if l:i + 1 == tabpagenr()
            let l:s .= '%#DiffChange#'
        else
            let l:s .= '%#TabLine#'
        endif

        " set the tab page number (for mouse clicks)
        let l:s .= '%' . (l:i + 1) . 'T'
        " the label is made by MyTabLabel()
        let l:s .= ' %{MyTabLabel(' . (l:i + 1) . ')} '
    endfor
    " after the last tab fill with TabLineFill and reset tab page nr
    let l:s .= '%#TabLineFill#'

    return l:s
endfunction


function! MyTabLabel(n)
    let l:buflist = tabpagebuflist(a:n)
    let l:winnr = tabpagewinnr(a:n)
    let l:bufname = bufname(l:buflist[l:winnr - 1])
    if l:bufname ==# '' | let l:bufname='[NULL]' | endif
    return a:n.' '.substitute(l:bufname, '.\+\/\(.\+\)', '\1', 'g')
endfunction

if ( exists('g:MagicStatusEnable') && g:MagicStatusEnable==1 )
    set statusline=%!MagicStatusLine(1)
    set showtabline=2
    set tabline=%!MyTabLine()

    augroup MagicStatusLine
        au!
        au WinLeave * setlocal nocursorline statusline=%!MagicStatusLine(0)
        au WinEnter * setlocal cursorline statusline=%!MagicStatusLine(1)
        if exists('g:MagicStatusGitExtra')
            au BufWritePost,BufReadPost * call s:MagicGitStatus()
        endif
    augroup END
endif
