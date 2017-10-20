" Functions for using clang-format to format the current buffer

function! FormatCallback(job, status)
    let l:pos_save = getpos('.')
    let @f = s:final_result
    if a:status == 0
        silent exec "normal! ggVG\"fp"
    else
        echo 'MagicFormat: Error'
        echo s:final_result
    endif
    let s:FmtJob=''
    call setpos('.', l:pos_save)
endfunction

function! FormatOutHandler(job, message)
    let s:final_result = s:final_result . a:message . '\n'
endfunction

function! MagicFormat(copy_fmt, ...)
    echo a:1
    let l:finalcmd = 'clang-format -style=file'

    if a:copy_fmt == 1
        call s:CheckClangFormat()
    endif

    if a:1 !=# '!'
        let s:final_result = ''
        let l:opts = {}
        let l:opts['in_io']='buffer'
        let l:opts['in_name']=expand('%')
        let l:opts['out_io']='pipe'
        let l:opts['err_io']='pipe'
        let l:opts['out_cb']=function('FormatOutHandler')
        let l:opts['err_cb']=function('FormatOutHandler')
        let l:opts['exit_cb']=function('FormatCallback')
        let s:FmtJob = job_start([&shell, &shellcmdflag, l:finalcmd], l:opts)
        echo 'MagicFormat: '. l:finalcmd
    else
        let l:winview = winsaveview()
        "let pos_save = getpos('.')
        exe '%! ' . l:finalcmd . ' ' . expand('%')
        "call setpos('.', pos_save)
        call winrestview(l:winview)
    endif
endfunction

function! s:CheckClangFormat()
    if findfile('.clang-format') ==# ''
        silent exe 'vs .clang-format'
        silent exe 'r ~/.vim/bundle/personal-magic.vim/templates/.clang-format'
        silent exe 'w \| bw'
    endif
endfunction

"Format current buffer with clang-format
command! -bang CFormat call MagicFormat(0, '<bang>')
command! -bang CFormatCopy call MagicFormat(1, '<bang>')
