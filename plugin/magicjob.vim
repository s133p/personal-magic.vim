function! MagicCallback(job, status)
    if a:status == 0
        silent exec "cclose"
    else
        echo "Done with exit status: " . a:status
        let currentWin = winnr()
        silent exec 'copen'
        silent exe "wincmd J"
        silent exe "resize 12"
        " silent exec 'normal! G'
        silent exe currentWin . "wincmd w"
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
        sleep 1
        let s:mahJob=""
    else
        echo "No running job"
    endif
endfunction

function! MagicJobInfo()
    if exists("s:mahJob") && s:mahJob != ""
        echo "MagicJob Status: " . job_status(s:mahJob)
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
    if a:useEfm == 1
        let s:mahErrorFmt=&efm
    elseif a:useEfm == 2
        let s:mahErrorFmt=&grepformat
    endif

    silent exec 'copen'
    silent exec "wincmd J"

    " Not to be trusted! Specific to my usecase!
    if a:useEfm != 0
        exe 'set efm='.escape(s:mahErrorFmt, " ")
    endif

    exe currentWin . "wincmd w"
endfunction

function! MagicBufferCallback(job, status)
    if a:status == 0
        let outBuf = bufnr("MagicOutput")
        silent exe "close " . outBuf
    endif
    let s:mahJob=""
endfunction

function! OutBufferHandler(job, message)
    let currentBuf = bufnr('%')
    let outBuf = bufnr("MagicOutput")
    let outWin = bufwinnr(outBuf)
    if outWin == -1
        silent exe "b".outBuf
        silent exe "normal! Gi" . a:message
        silent exe "normal! o"
        silent exe "b ".currentBuf
    else
        let currWin = bufwinnr("%")
        silent exe outWin."wincmd w"
        silent exe "normal! Gi" . a:message
        silent exe "normal! o"
        silent exe currWin."wincmd w"
    endif
endfunction

function! MagicBufferOpen()
    if bufnr("MagicOutput") == -1
        silent new MagicOutput
        silent exe "wincmd J"
    elseif bufwinnr("MagicOutput") != -1
        silent exe bufwinnr("MagicOutput") . "wincmd w"
    elseif bufwinnr("MagicOutput") == -1
        silent split
        silent exe "b " . bufnr("MagicOutput")
        silent exe "wincmd J"
    endif
    setlocal bufhidden=hide buftype=nofile nobuflisted nolist
    setlocal noswapfile nowrap

    silent resize 12
endfunction

function! MagicBufferJob(command)
    if exists("s:mahJob") && s:mahJob != ""
        call MagicJobKill()
    endif

    let finalcmd = a:command
    let opts = {}
    let opts['out_io']='pipe'
    let opts['err_io']='pipe'
    let opts["out_cb"]=function('OutBufferHandler')
    let opts["err_cb"]=function('OutBufferHandler')
    let opts['exit_cb']=function('MagicBufferCallback')
    let s:mahJob = job_start([&shell, &shellcmdflag, finalcmd], opts)
    echo "MagicJob: ". finalcmd

    let currentWin = winnr()
    call MagicBufferOpen()
    silent exe "%d"

    exe currentWin . "wincmd w"
endfunction

command! -nargs=1 -bang -complete=shellcmd MagicJob call MagicBufferJob('<bang>' != '!' ? <q-args>  : <q-args> . ";return 1")
command! -nargs=1 -bang -complete=shellcmd J call MagicBufferJob('<bang>' != '!' ? <q-args>  : <q-args> . ";return 1")

command! -nargs=1 -complete=file_in_path Mgrep call MagicJob("grep -Hsni " . <q-args> . ";return 1", 2)
