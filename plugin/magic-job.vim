function! MagicJob(qf, command)
    call s:SaveWin()
    if exists("s:mahJob") && s:mahJob != ""
        call MagicJobKill()
    endif

    if a:qf == '!'
        let s:MagicJobType = 'qf'
        call s:OpenOutBuf('qf')
    else
        let s:MagicJobType = 'magic'
        call s:OpenOutBuf('magic')
    endif


    let finalcmd = a:command

    let OutFn = function('s:JobPipeHandle')
    let CallbackFn = function('s:MagicCallback')
    let opts = {}
    let opts['out_io']='pipe'
    let opts['err_io']='pipe'
    let opts["out_cb"]=OutFn
    let opts["err_cb"]=OutFn
    let opts['exit_cb']=CallbackFn
    let s:mahJob = job_start([&shell, &shellcmdflag, finalcmd], opts)
    call s:StatusUpdate("[".finalcmd."]", 1)
    call s:RestoreWin()
endfunction

command! -nargs=? -bang -complete=shellcmd MagicJob call MagicJob('<bang>', <q-args>)
command! -nargs=? -bang -complete=shellcmd J call MagicJob('<bang>', <q-args>)

function! s:MagicCallback(job, status)
    call s:SaveWin()
    call s:StatusUpdate(a:status == 0 ? "[DONE]" : "[FAIL]" , a:status)
    if a:status == 0
        call s:CloseOutBufs()
    endif
    let s:mahJob=""

    call s:RestoreWin()
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

function! MagicJobKill()
    if exists("s:mahJob") && s:mahJob != ""
        echo "Killing running Job"
        call job_stop(s:mahJob)
        sleep 4
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

" Helper Functions
fun! s:SaveWin()
    let s:currentBuf = bufnr('%')
    let s:currentWin = winbufnr(s:currentBuf)
    let s:currentTab = tabpagenr()
endfun

fun! s:RestoreWin()
    silent exe "normal! ".s:currentTab."gt"
    silent exe s:currentWin."wincmd w"
endfun

fun! s:OpenOutBuf(which)
    if !exists('g:MagicUseEfm')
        let g:MagicUseEfm = 0
    endif

    echom a:which
    if a:which == 'qf'
        call setqflist([], 'r')
        " Not to be trusted! Specific to my usecase!
        if g:MagicUseEfm == 1
            let s:mahErrorFmt=&efm
        elseif g:MagicUseEfm == 2
            let s:mahErrorFmt=&grepformat
        endif

        silent exec 'copen'
        silent exec "wincmd J"

        " Not to be trusted! Specific to my usecase!
        if g:MagicUseEfm != 0
            exe 'set efm='.escape(s:mahErrorFmt, " ")
        endif
    else
        if bufnr("MagicOutput") == -1
            silent new MagicOutput
            wincmd J
        elseif bufwinnr("MagicOutput") != -1
            silent exe bufwinnr("MagicOutput") . "wincmd w"
            silent exe "%d"
        elseif bufwinnr("MagicOutput") == -1
            silent split
            silent exe "b " . bufnr("MagicOutput")
            silent exe "wincmd J"
            silent exe "%d"
        endif
        setlocal bufhidden=hide buftype=nofile nobuflisted nolist
        setlocal noswapfile nowrap
        set ft=log

        silent resize 12
    endif

endfun

fun! s:CloseOutBufs()
    call s:SaveWin()
    tabdo cclose
    tabdo if bufwinnr("MagicOutput")!=-1 | silent exe bufwinnr("MagicOutput")."close" | endif
    call s:RestoreWin()
endfun

fun! s:JobPipeHandle(job, message)
    if s:MagicJobType == 'qf'
        caddexpr a:message
    else
        call s:SaveWin()

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

        call s:RestoreWin()
    endif
endfun
