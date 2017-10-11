" Put all trailing '>' | '/>' back on previous line
function! s:XmlCleaner()
    norm! gg=G'
    exec 'g/^\s\+\(>\|\/>\)/norm! kJ'
endfunction
command! -nargs=0 XmlClean call s:XmlCleaner()

" Toggle between showing & hiding tab characters
function! s:ListTabToggle()
    if &list == 0
        return
    endif

    let currtab = split(&listchars, ',')[-1]

    if !exists("s:savetab")
        let s:savetab = currtab
    endif

    if currtab == s:savetab
        exe "set listchars-=" . s:savetab
        set listchars+=tab:\ \ 
    else
        set listchars-=tab:\ \ 
        exe "set listchars+=" . s:savetab
    endif
endfunction
command! -nargs=0 ListTabToggle call s:ListTabToggle()

" Toggle quickfix visibility
function! s:QuickfixToggle()
    let nr = winnr("$")
    cwindow
    let nr2 = winnr("$")
    if nr == nr2
        cclose
    endif
endfunction
command! -nargs=0 QfToggle call s:QuickfixToggle()

" Clean whitespace in current file
function! s:CleanWhitespace()
    silent exe "g/^\\s\\+$/s/.\\+//"
    silent exe "g/\\t/s/\\t/    /g"
    silent exe "g/\\s\\+$/s/\\s\\+$//g"
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

" Goto file for ds_cinder %APP% paths (Can be expanded to others)
function! s:GoAppFile(type)
    let l:text = s:ClipGrab('yi"')
    if len(l:text) > 0
        let l:file = substitute(l:text, '%APP%', getcwd(), 'g')
        if filereadable(l:file)
            exec a:type . " " . l:file
        endif
    endif
endfunction
command! -nargs=0 EFile call s:GoAppFile('e')
command! -nargs=0 VFile call s:GoAppFile('vs')
command! -nargs=0 TFile call s:GoAppFile('tabedit')

" Set ds_cinder engine dimensions.
"  type='f' for fill/center
"  type='s' to manually enter scale
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
command! -nargs=0 DstFConifg call s:DsEngineConfig('f')
command! -nargs=0 DstSConifg call s:DsEngineConfig('s')
