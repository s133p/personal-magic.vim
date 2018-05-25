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

" Toggle quickfix visibility
function! s:QuickfixToggle()
    let nr = winnr()
    let cnt = winnr('$')
    silent copen | wincmd J
    let cnt2 = winnr()
    if cnt == cnt2
        silent cclose
    else
        silent exe nr."wincmd w"
    endif
endfunction
command! -nargs=0 QfToggle call s:QuickfixToggle()

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

" Set ds_cinder engine dimensions.
"  type='f' for fill/center
"  type='s' to manually enter scale
"  TODO: Autodetect old/new settings (possibly with 2013 vs 2015 folder)
function! s:DsEngineConfig(type)
    let l:reservedx = 62.0
    let l:reservedy = 0.0
    let l:screenx = 2560.0 - l:reservedx
    let l:screeny = 1440.0 - l:reservedy

    " Start at top of file
    normal! gg
    " find world_dimensions
    exec "normal! /world_dimensions\<cr>"

    " save x dimension
    exec "normal! /x=\"/e\<cr>"
    let l:x = str2float(s:ClipGrab('yi"'))

    " save y dimension
    exec "normal! /y=\"/e\<cr>"
    let l:y = str2float(s:ClipGrab('yi"'))

    let l:scale = 1.0
    if a:type == 'f'
        let l:scalex = l:screenx / l:x
        let l:scaley = l:screeny / l:y
        let l:scale = l:scalex <= l:scaley ? l:scalex : l:scaley
        let l:scale = l:scale < 1.0 ? l:scale : 1.0
    elseif a:type == 's'
        let l:scale = str2float(inputdialog("Scale: ", '0.', '1.0'))
    endif

    let l:x = float2nr(round(l:x * l:scale))
    let l:y = float2nr(round(l:y * l:scale))

    let l:offsetx = float2nr(round((l:screenx / 2.0) - (l:x / 2.0) + l:reservedx))
    let l:offsety = float2nr(round((l:screeny / 2.0) - (l:y / 2.0) + l:reservedy))

    exec "normal! /dst_rect\<cr>"
    " Replace tag with updated values
    exec "normal! ci>rect name=\"dst_rect\" l=\"" . string(l:offsetx) . "\" w=\"" . string(l:x) . "\" t=\"" .  string(l:offsety) . "\" h=\"" . string(l:y) . "\" /"
endfunction
command! -nargs=0 DsFillEngine call s:DsEngineConfig('f')
command! -nargs=0 DsScaleEngine call s:DsEngineConfig('s')


" Windows convienence for making local visual studio solution
function! s:MakeLocalSln()
    let projName = (split(getcwd(), '/')[-1])
    let vsVer = isdirectory('./vs2015') ? "vs2015" : "vs2013"
    let currsln = vsVer . "/" . projName . ".sln"
    silent exec "vs " . currsln
    silent exec "sav ".vsVer."/local.sln"
    silent exec 'g/%/norm! f%xct%=$"lx'
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
