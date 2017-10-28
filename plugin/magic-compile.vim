" Personal compilation shortcut function
function! s:MagicCompile(buildType)
    let l:compileSettings = s:GetBuildSettings()
    if l:compileSettings == {}
        let s:magicToRun = ''
        return
    endif

    let l:useefm = 0
    " Apply settings
    if has_key(l:compileSettings, 'SETTINGS')
        for l:setting in l:compileSettings['SETTINGS']
            exe l:setting
            if l:setting[0:6] ==? 'set efm'
                let g:MagicUseEfm = 1
            endif
        endfor
    endif

    if has_key(l:compileSettings, a:buildType) && len(l:compileSettings[a:buildType]) == 2

        let s:magicToRun = substitute(l:compileSettings[a:buildType][1], '\$FULLWD', getcwd(), 'g')
        let s:magicToRun = substitute(s:magicToRun, '\$WD', split(getcwd(), '/')[-1], 'g')
        let s:magicToRun = substitute(s:magicToRun, '%', expand('%'), 'g')
        silent exe 'MagicJob! '.l:compileSettings[a:buildType][0]
    else
        echo a:buildType . ' is invalid. Valid options: ' . string(keys(l:compileSettings))
        let s:magicToRun = ''
    endif
endfunction

function! s:GetBuildSettings()
    " Look for local l:settings
    let l:looker = globpath(getcwd(), '.magic-compile')
    if l:looker ==# ''
        " Then check ft-specific
        let l:looker = globpath('~/.vim/bundle/personal-magic.vim/templates/', '.'.&filetype.'-magic-compile')

        if l:looker ==# ''
            " Then check l:os-ft-specific
            let l:os = 'osx'
            if has('win32')
                let l:os = 'win'
            endif

            let l:looker = globpath('~/.vim/bundle/personal-magic.vim/templates/', '.'.l:os.'-'.&filetype.'-magic-compile')
            if l:looker ==# ''
                echo 'No .magic-compile found in current directory'
                return {}
            endif
        endif
    endif

    let l:cont = readfile(l:looker)
    let l:settings = {}
    let l:currentSetting = ''
    for l:line in l:cont
        if l:line[0] ==# ':'
            let l:settings[l:line[1:]] = []
            let l:currentSetting = l:line[1:]
        elseif l:line[0] ==# '#'
            " comment
        elseif l:line !=# ''
            let l:settings[l:currentSetting] = add(l:settings[l:currentSetting], l:line)
        endif
    endfor
    return l:settings
endfunction

" Run the saved "run" command from last MagicCompile
" :J repeats, :J! repeats, keeping results open
function! s:MagicCompileRun(bang)
    if exists('s:magicToRun') && s:magicToRun !=# ''
        silent exe 'MagicJob'. a:bang . ' ' . s:magicToRun
    else
        let l:settings = s:GetBuildSettings()
        if has_key(l:settings, 'RUN') && len(l:settings['RUN']) >= 1
            let l:run = substitute(l:settings['RUN'][0], '\$FULLWD', getcwd(), 'g')
            let l:run = substitute(l:run, '\$WD', split(getcwd(), '/')[-1], 'g')
            let l:run = substitute(l:run, '%', expand('%'), 'g')
            silent exe 'MagicJob'. a:bang . ' ' . l:run
        endif
    endif
endfunction

function! DoDevOpen()
    let l:run = ''
    if has('mac')
        let l:run = "!open xcode/*.xcodeproj"
    elseif has('win32')
        let l:dir = 'vs2015'
        if !isdirectory(l:dir)
            let l:dir = 'vs2013'
        endif
        let l:run = 'J start devenv ' . l:dir . '/' . split(getcwd(), '/')[-1] .'.sln'
    endif
    silent exec l:run
endfun
nnoremap <Plug>(DevOpen) :call DoDevOpen()<cr>

command! -nargs=1 MCompile call s:MagicCompile(<q-args>)
command! -bang MCRun call s:MagicCompileRun('<bang>')
