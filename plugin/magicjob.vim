function! s:JobRun(qf, command )
    if exists("s:mahJob") && s:mahJob != ""
        call MagicJobKill()
    endif

    if a:qf
        let OutFn = function('s:OutHandler')
        let CallbackFn = function('s:MagicCallback')
    else
        let OutFn = function('s:OutBufferHandler')
        let CallbackFn = function('s:MagicBufferCallback')
    endif
    let finalcmd = a:command
    let opts = {}
    let opts['out_io']='pipe'
    let opts['err_io']='pipe'
    let opts["out_cb"]=OutFn
    let opts["err_cb"]=OutFn
    let opts['exit_cb']=CallbackFn
    let s:mahJob = job_start([&shell, &shellcmdflag, finalcmd], opts)
    call s:StatusUpdate("[".finalcmd."]", 1)
endfunction

function! MagicJob( command, useEfm )
    call s:JobRun(1, a:command)

    let currentWin = winnr()
    call s:MagicQf(a:useEfm)
    exe currentWin . "wincmd w"
endfunction

function! MagicBufferJob(...)
    if a:1 == '!'
        let s:buffer_job_kill = 0
    else
        let s:buffer_job_kill = 1
    endif

    if a:2 != ''
        let finalcmd = a:2
        let s:lastcmd = a:2
    elseif exists('s:lastcmd')
        let finalcmd = s:lastcmd
    else
        call s:StatusUpdate("[No Job]", 1)
        return
    endif

    call s:JobRun(0, finalcmd)

    let currentWin = winnr()
    call MagicBufferOpen(1)
    exe currentWin . "wincmd w"
endfunction

function! s:StatusUpdate(msg, type)
    if a:type == 0
        let g:airline_section_z=a:msg
        let g:airline_section_warning=''
    else
        let g:airline_section_z=''
        let g:airline_section_warning=a:msg
    endif
    exe ":AirlineRefresh"
endfunction

function! s:MagicCallback(job, status)
    call s:StatusUpdate(a:status == 0 ? "[DONE]" : "[FAIL]" , a:status)
    if a:status == 0
        silent exec "cclose"
    else
        let currentWin = winnr()
        silent exec 'copen'
        silent exe "wincmd J"
        silent exe "resize 12"
        " silent exec 'normal! G'
        silent exe currentWin . "wincmd w"
    endif
    let s:mahJob=""
endfunction

function! s:OutHandler(job, message)
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

function! s:MagicBufferCallback(job, status)
    call s:StatusUpdate(a:status == 0 ? "[DONE]" : "[FAIL]" , a:status)
    if a:status == 0 && s:buffer_job_kill == 1
        let outBuf = bufnr("MagicOutput")
        silent exe "close " . outBuf
    endif
    let s:mahJob=""
endfunction

function! s:OutBufferHandler(job, message)
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

function! MagicBufferOpen(...)
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
    set ft=log

    silent resize 12
    if a:0 != 0
        silent exe "%d"
    endif
endfunction

function! s:MagicQf(useEfm)
    call setqflist([], 'r')
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
endfunction


" :MagicJob[!] {commands} - run {commands} showing results.
"  Bang forces results to remain open
"  If {commands} returns success, results are closed
"  If {commands} returns failure, results remain open
command! -nargs=? -bang -complete=shellcmd MagicJob call MagicBufferJob('<bang>', <q-args>)
command! -nargs=? -bang -complete=shellcmd J call MagicBufferJob('<bang>', <q-args>)

command! -nargs=1 -complete=file_in_path Mgrep call MagicJob("grep -Hsni " . <q-args> . ";return 1", 2)
