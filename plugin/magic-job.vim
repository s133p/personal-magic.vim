function! MagicJob(qf, command, ...)
    if exists('s:mahJob') && s:mahJob !=# ''
        call MagicJobKill()
        echo 'killing job... once again with gusto'
        return
    endif

    call s:SaveWin()
    call s:CloseOutBufs()
    let s:MagicJobType = a:qf ==# '!' ? 'qf' : 'magic'
    let s:outList = []
    let l:finalcmd = a:command

    if a:qf !=# '' && a:qf != '!'
        call s:OpenOutBuf(s:MagicJobType, 1, a:qf)
    else
        call s:OpenOutBuf(s:MagicJobType, 1)
    endif

    if a:0 == 1 && a:1 ==# '!'
        let l:finalcmd .= has('win32') ? ' && exit 1' : '; return 1'
    endif

    let l:opts = {}
    let l:cb = function('s:MagicCallback')
    if !has('nvim')
        let l:outfn = function('s:JobPipeHandle')
        let l:opts = { 'out_io': 'pipe', 'err_io': 'pipe', 'out_cb': l:outfn, 'err_cb': l:outfn, 'exit_cb': l:cb }
        let s:mahJob = job_start([&shell, &shellcmdflag, l:finalcmd], l:opts)
    else
        let l:opts = { 'on_stdout': l:cb, 'on_stderr': l:cb, 'on_exit': l:cb }
        let s:mahJob = jobstart(l:finalcmd, l:opts)
    endif

    " Update Status
    if matchstr(l:finalcmd, 'msbuild') != '' || matchstr(l:finalcmd, 'make') != ''
        let l:statusMsg =  'Build ' . (matchstr(l:finalcmd, 'Debug')!='' ? 'DEBUG' : 'RELEASE')
    elseif matchstr(l:finalcmd, '\.exe') != '' || matchstr(l:finalcmd, '\.app') != ''
        let l:statusMsg = (matchstr(l:finalcmd, 'Debug')!='' ? 'DEBUG' : 'RELEASE') . ' ' . split(getcwd(), '/')[-1]
    else
        let l:statusMsg = l:finalcmd
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
        if !has('nvim')
            call job_stop(s:mahJob)
        else
            call jobstop(s:mahJob)
        endif
    else
        echo 'No running job'
    endif
    let g:MagicStatusWarn = ''
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
    call s:SaveWin()
    if a:which ==? 'qf'
        call setqflist([], 'r')

        silent exec 'copen | wincmd J'

        if exists('g:MagicUseEfm')
            exe 'set efm='.escape(g:MagicUseEfm, ' ')
        endif
    else
        let l:mbufwin = bufwinnr('MagicOutput')
        let l:mbuf = bufnr('MagicOutput')

        if l:mbuf == -1 || l:mbufwin == -1
            silent exe l:mbuf==-1 ? 'new MagicOutput' : 'split | b '.l:mbuf
            silent wincmd J
        elseif l:mbufwin != -1
            silent exe l:mbufwin.'wincmd w'
        endif

        setlocal bufhidden=hide buftype=nofile nobuflisted nolist noswapfile nowrap filetype=log
        if a:clear | silent exe '%d' | endif
        let l:sz = a:0 == 0 ? 12 : a:1
        exe 'silent resize '.l:sz
    endif
    call s:RestoreWin()
endfun
command! -nargs=0 MagicBufferOpen call s:OpenOutBuf('magic', 0)

fun! s:CloseOutBufs()
    call s:SaveWin()
    silent tabdo cclose
    silent tabdo if bufwinnr('MagicOutput')!=#-1 | silent exe bufwinnr('MagicOutput').'close' | endif
    call s:RestoreWin()
endfun

fun! s:BufferPiper(message, flush)
    let l:out = ""
    if type(a:message)==type("")
        let l:out = a:message
    elseif type(a:message)==type([])
        let l:out = join(a:message)
    endif
    let l:out = split(l:out)

    if s:MagicJobType ==# 'qf'
        caddexpr l:out
    else
        let s:outList = extend(s:outList, l:out)
        if len(s:outList) > 4 || a:flush == 1
            let l:outBuf = bufnr('MagicOutput')
            let l:outWin = bufwinnr('MagicOutput')
            let l:saveWin = winnr()
            silent exe l:outWin !=# -1 ? l:outWin.' wincmd w' : 'b'.l:outBuf
            call append(line('$'), s:outList)
            silent norm! G
            if l:outWin !=# -1 && l:outWin !=# l:saveWin
                silent exe l:saveWin.' wincmd w'
            elseif l:outWin ==# -1
                silent exe 'b#'
            endif
            let s:outList = []
        endif
    endif
endfun

fun! s:JobPipeHandle(job, message)
    call s:BufferPiper(a:message, 0)
endfun

