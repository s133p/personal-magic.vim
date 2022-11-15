fun! MagicGuard()
    let l:dir = split(getcwd(), '/')[-1]
    let l:f = split(expand('%:r'), '/')
    let l:guard = toupper(l:dir . '_' . join( l:f, '_' ))
    return l:guard
endfun

fun! s:MagicPreview(bang)
    if has('win32')
        let l:opener = 'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe'
    elseif has('mac')
        let l:opener = 'open'
    endif
    if executable('pandoc')
        let l:home = expand('~')
        let l:head = l:home . '/.vim/bundle/personal-magic.vim/templates/header.html'
        let l:foot = l:home . '/.vim/bundle/personal-magic.vim/templates/footer.html'
        echo system('pandoc -t html -B '.l:head.' -A '.l:foot.' --self-contained --section-divs "' . expand('%') . '" -o '.l:home.'/Desktop/preview.html')

        if executable(l:opener) && a:bang != '!'
            if has('win32')
                echo system('"'.l:opener . '" ' . l:home.'/Desktop/preview.html')
            elseif has('mac')
                system(l.opener . " " . l:home . "/Desktop/preview.html")
            endif
        endif
    endif
endfun
command! -nargs=0 -bang MagicPreview call s:MagicPreview('<bang>')

" Fuzzy esque search
fun! s:SuperSearch(what)
    let l:ss = map(range(0,len(a:what)-1), 'a:what[v:val]')
    set hlsearch
    let @/ = join(l:ss, '.\{-}')
    norm! n
    " echo join(l:ss, '.\{-}')
endfun
nnoremap <Plug>(MagicSuperSearch) :call <Sid>SuperSearch(input('> '))<cr>

" Substitutions + glob for includeexpr
function! MagicIncludeExpr(fname)
    let l:outfile = substitute(a:fname,'%APP%','','g')
    let l:candidates = glob('./**/'.l:outfile, 0, 1)
    echom string(l:outfile)
    if len(l:candidates)==1
        return l:candidates[0]
    else
        " echom string(l:candidates)
        return '**'
    endif
endfun

" Buf Wiper (close all buffers but current)
function! s:BufWipe(bang)
    let l:cBufs = a:bang=='!' ? [bufnr('%')] : tabpagebuflist()
    let l:buffers = map(copy(getbufinfo()), 'v:val.bufnr')

    for l:b in l:buffers
        if index(l:cBufs, l:b) == -1
            silent exe string(l:b).'bw'
        endif
    endfor
endfunction
command! -nargs=0 -bang BufWipe call s:BufWipe('<bang>')

" Open current directory / Document directory in appropriate file-viewer
function! s:MagicOpen(bang)
    let cmd = ''
    if has("mac")
        let cmd = 'open'
    elseif has("unix")
        let cmd = 'exec caja'
    elseif has("win32")
        let cmd = 'explorer'
    endif
    let where = a:bang=='!' ? substitute(expand("%:p:h"), '/', '\', 'g') : '.'
    exec "AsyncRun -post=cclose ".cmd." ".where
endfunction
command! -nargs=0 -bang MagicOpen call s:MagicOpen('<bang>')

" Put all trailing '>' | '/>' back on previous line
function! s:XmlCleaner()
    call s:CleanWhitespace()
    norm! gg=G'
    " Fix trailing closing >
    silent exec 'g/^\s\+\(>\|\/>\)/norm! kJ'
endfunction
command! -nargs=0 XmlClean call s:XmlCleaner()

" Clean whitespace in current file
function! s:CleanWhitespace()
    silent exe "g/^\\s\\+$/s/.\\+//"
    silent exe "g/\\t/s/\\t/    /g"
    silent exe "g/\\s\\+$/s/\\s\\+$//g"
    silent exe 'g//s///g'
endfunction
command! -nargs=0 CleanWhitespace call s:CleanWhitespace()

function! s:ClipGrab(what)
    let l:save_clipboard = &clipboard
    set clipboard= " Avoid clobbering the selection and clipboard registers.
    let l:save_reg = getreg('"')
    let l:save_regmode = getregtype('"')
    exec "normal! " . a:what
    let l:text = @@ " Your text object contents are here.
    call setreg('"', l:save_reg, l:save_regmode)
    let &clipboard = l:save_clipboard
    return l:text
endfunction

" Windows convienence for making local visual studio solution
function! s:MakeLocalSln()
    let projName = (split(getcwd(), '/')[-1])
    let vsVer = isdirectory('./vs2019') ? "vs2019" : "vs2015"
    let currsln = vsVer . "/" . projName . ".sln"
    silent exec "tabnew " . currsln
    silent exec "setlocal textwidth=0"
    silent exec "sav! ".vsVer."/local.sln"
    silent exec 'g/%/norm! f%xct%=$"lx'
    silent exec 'write'

    " update clang format
    silent exec 'vs .clang-format'
    silent exec 'norm! ggdG'
    silent exec 'r ~/.vim/bundle/personal-magic.vim/templates/.clang-format'
    silent exec 'write'

    "update magic compile
    silent exec 'vs .tasks'
    silent exec 'norm! ggdG'
    silent exec 'r ~/.vim/bundle/personal-magic.vim/templates/.tasks'
    silent exec 'write'
endfunction
command! -nargs=0 MakeLocalSln call s:MakeLocalSln()

"Format current buffer with clang-format
" Functions for using clang-format to format the current buffer
function! s:MagicFormat(copy_fmt, ...)
    if a:copy_fmt == 1 && findfile('.clang-format') ==# ''
        silent vs .clang-format
        silent r ~/.vim/bundle/personal-magic.vim/templates/.clang-format
        silent w
        silent bw
    endif

    let l:winline = line('.')
    silent exe '%!clang-format -style=file '.expand('%')
    exec l:winline
endfunction
command! -bang CFormat call s:MagicFormat('<bang>'=='!' ? 1 : 0)
