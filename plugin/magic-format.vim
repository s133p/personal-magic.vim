" Functions for using clang-format to format the current buffer
function! MagicFormat(copy_fmt, ...)
    let l:clangcmd = 'clang-format -style=file'

    if a:copy_fmt == 1
        call s:CheckClangFormat()
    endif

    let l:winview = winsaveview()
    exe '%! ' . l:clangcmd . ' ' . expand('%')
    call winrestview(l:winview)
endfunction

function! s:CheckClangFormat()
    if findfile('.clang-format') ==# ''
        silent exe 'vs .clang-format'
        silent exe 'r ~/.vim/bundle/personal-magic.vim/templates/.clang-format'
        silent exe 'w \| bw'
    endif
endfunction

"Format current buffer with clang-format
command! -bang CFormat call MagicFormat('<bang>'=='!' ? 1 : 0)
