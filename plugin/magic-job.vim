function! MagicJob(qf, command, ...)
    call s:SaveWin()
    if exists('s:mahJob') && s:mahJob !=# ''
        call MagicJobKill()
    endif

    call s:CloseOutBufs()
    if a:qf ==# '!'
        let s:MagicJobType = 'qf'
        call s:OpenOutBuf('qf', 1)
    elseif a:qf !=# ''
        let s:MagicJobType = 'magic'
        call s:OpenOutBuf('magic', 1, a:qf)
    else
        let s:MagicJobType = 'magic'
        call s:OpenOutBuf('magic', 1)
    endif


    let l:finalcmd = a:command
    if a:0 == 1 && a:1 ==# '!'
        let l:finalcmd .= ';return 1'
    endif

    let l:opts = {}
    if !has('nvim')
        let l:OutFn = function('s:JobPipeHandle')
        let l:CallbackFn = function('s:MagicCallback')
        let l:opts['out_io']='pipe'
        let l:opts['err_io']='pipe'
        let l:opts['out_cb']=l:OutFn
        let l:opts['err_cb']=l:OutFn
        let l:opts['exit_cb']=l:CallbackFn
        let s:mahJob = job_start([&shell, &shellcmdflag, l:finalcmd], l:opts)
    else
        let l:CallbackFn = function('s:NvimMagicCallback')
        let l:opts['on_stdout']=l:CallbackFn
        let l:opts['on_stderr']=l:CallbackFn
        let l:opts['on_exit']=l:CallbackFn
        let s:mahJob = jobstart([&shell, &shellcmdflag, l:finalcmd], l:opts)
        echom s:mahJob
    endif

    let l:statusMsg = l:finalcmd

    if matchstr(l:finalcmd, 'msbuild') != '' || matchstr(l:finalcmd, 'make') != ''
        let l:statusMsg =  'Build ' . (matchstr(l:finalcmd, 'Debug')!='' ? 'DEBUG' : 'RELEASE')
    elseif matchstr(l:finalcmd, '\.exe') != '' || matchstr(l:finalcmd, '\.app') != ''
        " let l:statusMsg = (matchstr(l:finalcmd, 'Debug')!='' ? 'DEBUG' : 'RELEASE') . ' ' . substitute(l:finalcmd, '.\+\/\(.\{-}\.\(exe\|app\)\)', '\1', '')
        let l:statusMsg = (matchstr(l:finalcmd, 'Debug')!='' ? 'DEBUG' : 'RELEASE') . ' ' . split(getcwd(), '/')[-1]
    endif
    call s:StatusUpdate('['.l:statusMsg.']', 1)
    call s:RestoreWin()
endfunction

command! -nargs=? -bang -complete=shellcmd MagicJob call MagicJob('<bang>', <q-args>)
command! -nargs=? -bang -complete=shellcmd J call MagicJob('<bang>', <q-args>)
command! -nargs=? -bang -count=0 -complete=shellcmd MagicJobS call MagicJob(<q-count>, <q-args>, '<bang>')

if has('nvim')
    function! s:NvimMagicCallback(job, data, event)
        if a:event == 'stdout'
            call s:JobPipeHandle(a:job, a:data)
        elseif a:event == 'stderr'
            call s:JobPipeHandle(a:job, a:data)
        else
            call s:MagicCallback(s:mahJob, a:data)
        endif
    endfunction
endif

function! s:MagicCallback(job, status)
    call s:SaveWin()
    call s:StatusUpdate(a:status ==# 0 ? '[DONE]' : '[FAIL]' , a:status)
    call s:BufferPiper('', 1)
    if a:status ==# 0
        call s:CloseOutBufs()
    endif
    let s:mahJob=''

    call s:RestoreWin()
endfunction

function! s:StatusUpdate(msg, type)
    if a:type ==# 0
        let g:MagicStatusJob=''
        let g:MagicStatusWarn=''
    else
        let g:MagicStatusJob=''
        let g:MagicStatusWarn=a:msg
    endif
endfunction

function! MagicJobKill()
    if exists('s:mahJob') && s:mahJob !=# ''
        let g:MagicStatusWarn = 'Killing Job'
        call job_stop(s:mahJob)
        let s:mahJob=''
    else
        echo 'No running job'
    endif
    let g:MagicStatusWarn = ''
endfunction

function! MagicJobInfo()
    if exists('s:mahJob') && s:mahJob !=# ''
        echo 'MagicJob Status: ' . job_status(s:mahJob)
    else
        echo 'No running job'
    endif
endfunction

" Helper Functions
fun! s:SaveWin()
    let s:currentWin = winnr()
    let s:currentBuf = bufnr('%')
    let s:currentTab = tabpagenr()
endfun

fun! s:RestoreWin()
    if s:currentTab <= tabpagenr('$')
        silent exe 'normal! '.s:currentTab.'gt'
    endif
    if s:currentBuf !=# bufnr('MagicOutput')
        silent exe s:currentWin.'wincmd w'
    endif
endfun

fun! s:OpenOutBuf(which, clear, ...)
    if !exists('g:MagicUseEfm')
        let g:MagicUseEfm = 0
    endif

    call s:SaveWin()
    if a:which ==? 'qf'
        call setqflist([], 'r')
        " Not to be trusted! Specific to my usecase!
        if g:MagicUseEfm ==# 1
            let s:mahErrorFmt=&efm
        elseif g:MagicUseEfm ==# 2
            let s:mahErrorFmt=&grepformat
        endif

        silent exec 'copen'
        silent exec 'wincmd J'

        " Not to be trusted! Specific to my usecase!
        if g:MagicUseEfm !=# 0
            exe 'set efm='.escape(s:mahErrorFmt, ' ')
        endif
    else
        if bufnr('MagicOutput') ==# -1
            silent new MagicOutput
            wincmd J
        elseif bufwinnr('MagicOutput') !=# -1
            silent exe bufwinnr('MagicOutput') . 'wincmd w'
        elseif bufwinnr('MagicOutput') ==# -1
            silent split
            silent exe 'b ' . bufnr('MagicOutput')
            silent exe 'wincmd J'
        endif

        setlocal bufhidden=hide buftype=nofile nobuflisted nolist noswapfile nowrap filetype=log

        if a:clear | silent exe '%d' | endif

        if a:0 == 0
            silent resize 12
        else
            exe 'silent resize '.a:1
        endif
    endif
    call s:RestoreWin()

endfun
command! -nargs=0 MagicBufferOpen call s:OpenOutBuf('magic', 0)

fun! s:CloseOutBufs()
    call s:SaveWin()
    tabdo cclose
    tabdo if bufwinnr('MagicOutput')!=#-1 | silent exe bufwinnr('MagicOutput').'close' | endif
    call s:RestoreWin()
endfun


fun! s:BufferPiper(message, flush)
    if s:MagicJobType ==# 'qf'
        caddexpr a:message
    else

        if !exists('s:outList')
            let s:outList = []
        endif

        if type(a:message)==type("")
            call add(s:outList, a:message)
        elseif type(a:message)==type([])
            call extend(s:outList, a:message)
        endif

        if len(s:outList) > 6 || a:flush == 1
            let l:outBuf = bufnr('MagicOutput')
            let l:outWin = bufwinnr('MagicOutput')
            let l:saveWin = winnr()
            if l:outWin !=# -1
                if l:outWin ==# l:saveWin
                    silent exe l:outWin." wincmd w | call append(line('$'), " . string(s:outList) . ")". " | norm!G"
                else
                    silent exe l:outWin." wincmd w | call append(line('$'), " . string(s:outList) . ")". " | norm!G"
                    silent exe l:saveWin." wincmd w"
                endif
            else
                silent exe "b".l:outBuf." | call append(line('$'), " . string(s:outList) . ")". " | b#"
            endif
            let s:outList = []
        endif
    endif
endfun

fun! s:JobPipeHandle(job, message)
    call s:BufferPiper(a:message, 0)
endfun

