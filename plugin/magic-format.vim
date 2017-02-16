function! FormatCallback(job, status)
    let pos_save = getpos('.')
    let @f = s:final_result
    if a:status == 0
        silent exec "normal! ggVG\"fp"
    else
        echo "MagicFormat: Error"
        echo s:final_result
    endif
    let s:FmtJob=""
    call setpos('.', pos_save)
endfunction

function! FormatOutHandler(job, message)
    let s:final_result = s:final_result . a:message . "\n"
endfunction

function! MagicFormat()
    let finalcmd = "clang-format -style=file"
    let s:final_result = ""
    let opts = {}
    let opts['in_io']='buffer'
    let opts['in_name']=expand("%")
    let opts['out_io']='pipe'
    let opts['err_io']='pipe'
    let opts["out_cb"]=function('FormatOutHandler')
    let opts["err_cb"]=function('FormatOutHandler')
    let opts['exit_cb']=function('FormatCallback')
    let s:FmtJob = job_start([&shell, &shellcmdflag, finalcmd], opts)
    echo "MagicFormat: ". finalcmd
endfunction

"Format current buffer with clang-format
command! CFormat call MagicFormat()
