function! MagicCallback(job, status)
    if a:status == 0
        exec "cclose"
    else
        let currentWin = winnr()
        exec 'copen'
        exec 'normal! G'
        exe currentWin . "wincmd w"
    endif
    let s:mahJob=""
endfunction

function! OutHandler(job, message)
    caddexpr a:message
endfunction

function! MagicJobKill()
    if exists("s:mahJob") && s:mahJob != ""
        echo "Killing running Job"
        call job_stop(s:mahJob)
        let s:mahJob=""
    else
        echo "No running job"
    endif
endfunction

function! MagicJob( command, useEfm )
    if exists("s:mahJob") && s:mahJob != ""
        call MagicJobKill()
    endif
    let finalcmd = a:command
    let opts = {}
    let opts['out_io']='pipe'
    let opts['err_io']='pipe'
    let opts["out_cb"]=function('OutHandler')
    let opts["err_cb"]=function('OutHandler')
    let opts['exit_cb']=function('MagicCallback')
    let s:mahJob = job_start([&shell, &shellcmdflag, finalcmd], opts)
    echo "MagicJob: ". finalcmd


    call setqflist([], 'r')
    let currentWin = winnr()

    " Not to be trusted! Specific to my usecase!
    if has("mac") && !exists("a:useEfm")
        let g:mahErrorFmt=&efm
    endif

    exec 'copen'

    " Not to be trusted! Specific to my usecase!
    if has("mac") && !exists("a:useEfm")
        exe "set efm=" . escape(g:mahErrorFmt, " \\")
    endif

    exe currentWin . "wincmd w"
endfunction

" nnoremap <leader>z :call MagicJob("make")<cr>
" nnoremap <leader>Z :call MagicJob("make release")<cr>
