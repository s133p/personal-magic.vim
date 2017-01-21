" Cycles forwared or back through splits in tab -> next tab
" If no tabs or splits, cycles through listed buffers
function! TabOrSwitch( shifted )
    let wn = winnr()
    let hastab = tabpagewinnr(tabpagenr()+1) != 0 || tabpagewinnr(tabpagenr()-1) != 0
    let hasLeftSplit = (winbufnr(wn-1) != -1 && wn-1 != 0)
    let hasRightSplit = winbufnr(wn+1) != -1

    if (a:shifted && hasLeftSplit) || (!a:shifted && hasRightSplit)
        silent exe "wincmd " . ( a:shifted?"W":"w" )
    elseif hastab
        silent exe ":tab" . ( a:shifted?"p":"n" )
        if !a:shifted
            silent exe "0wincmd w"
        endif
    else
        silent exe ":b" . ( a:shifted?"p":"n" )
    endif
endfunction


" Toggle quickfix visibility
function! QuickfixToggle()
    let nr = winnr("$")
    cwindow
    let nr2 = winnr("$")
    if nr == nr2
        cclose
    endif
endfunction


" Open personal notes dir with unite
function! OpenPersonalNotes(type)
    if !exists("g:personal_notes_dir")
        let g:personal_notes_dir="~/Dropbox/vim-notes"
    endif
    if !exists("g:personal_nv_notes_dir")
        let g:personal_nv_notes_dir="~/Dropbox/NV-Notes"
    endif

    " Open Unite in notes directory
    if a:type == 'n'
        execute "Unite -path=" . g:personal_notes_dir . " -start-insert -no-split file_rec"
    elseif a:type == 'v'
        execute "Unite -path=" . g:personal_nv_notes_dir . " -start-insert -no-split file_rec"
    endif
endfunction


" Dont try file_rec in my homedir, do file and mru instead
function! MyUniteSpecial()
    if expand("%:p:h") == expand("~")
        execute "UniteWithProjectDir -start-insert -no-split file"
    else
        execute "UniteWithProjectDir -start-insert -no-split file_rec"
    endif
endfunction

" Personal compilation shortcut function
function! MagicCompile(isRelease)
    if has("mac")
        " Compiles an xcode project in the cinder folder structure (from the root of the project)
        " (requires xcpretty)
        setlocal makeprg=make
        set errorformat=[x]\ %f:%l:%c:\ %m,[x]%m

        let l:mode = a:isRelease ? "Release" : "Debug"
        exe "call MagicJob(\"" . &makeprg . " ". l:mode ."\", 1)"

        " Set s:magicToRun to the run correct version of app
        let l:appPath = expand(getcwd() . "/xcode/build/". l:mode ."/*.app")
        let l:appName = substitute( l:appPath, "\\v^.{-}([a-zA-Z_0-9]+)\.app", "\\1", "g")

        let l:runFG = l:appPath . "/Contents/MacOS/". l:appName .";"
        let l:runSleep = a:isRelease ? "1" : "2"
        let l:runBG = "osascript  -e 'delay ". l:runSleep ."' -e 'tell application \"" .  l:appName ."\" to activate' &;"

        let s:magicToRun = l:runBG . l:runFG

    elseif has("win32")
        " Compiles a visual studio project in the dsCinder folder structure
        " (requires creation of local.sln with env-vars expanded)
        compiler msvc
        set makeprg=msbuild

        let l:solution = "./vs2013/local.sln"
        let l:mode = a:isRelease ? "Release" : "Debug"
        let l:configuration = "/p:Configuration=" . l:mode
        let l:flags = "/m /verbosity:quiet /nologo"

        exe "call MagicJob(\"" . &makeprg ." ". l:solution ." ".  l:configuration ." ". l:flags ."\", 0)"

        " Set s:magicToRun to the run correct version of app
        let l:appPath = expand(getcwd() . "/vs2013/". l:mode ."/".  split(getcwd(), '/')[-1] .".exe")
        let l:appName = substitute( l:appPath, "\\v^.{-}([a-zA-Z]+)\.exe", "\\1", "g")

        let l:runBG = l:appPath
        let s:magicToRun = l:runBG
    endif
endfunction

" Run the saved "run" command from last MagicCompile
function! MagicCompileRun()
    call MagicBufferJob(s:magicToRun)
endfunction

" Get info on what will be run w/ MagicCompileRun
function! MagicCompileRunInfo()
    echo "Run Cmd: ". s:magicToRun
endfunction

" " Clear empty no-names
" function! CleanIfNoName()
"     let bnum = bufnr(expand("%"))
"     let isCurrentNoName = (expand("%")=="")
"     let isCurrentEmpty = (getbufline(bnum, 1, "$") == [""])
"     if isCurrentNoName && isCurrentEmpty
"         exe "bd " . bnum
"     endif
" endfunction
"
" augroup CleanOnLeave
"     autocmd!
"     autocmd BufHidden "" silent bd
" augroup END
