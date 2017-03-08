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

" Personal compilation shortcut function
function! s:MagicCompile(buildType)
    let compileSettings = s:GetBuildSettings()
    if compileSettings == {}
        let s:magicToRun = ''
        return
    endif

    let useefm = 0
    " Apply settings
    if has_key(compileSettings, "SETTINGS")
        for setting in compileSettings["SETTINGS"]
            exe setting
            if setting[0:6] == "set efm"
                let useefm = 1
            endif
        endfor
    endif

    if has_key(compileSettings, a:buildType) && len(compileSettings[a:buildType]) == 2

        let s:magicToRun = substitute(compileSettings[a:buildType][1], "\$FULLWD", getcwd(), 'g')
        let s:magicToRun = substitute(s:magicToRun, "\$WD", split(getcwd(), '/')[-1], 'g')
        let s:magicToRun = substitute(s:magicToRun, "%", expand("%"), 'g')
        exe "call MagicJob(\"" . compileSettings[a:buildType][0] ."\", ".useefm.")"
    else
        echo a:buildType . " is invalid. Valid options: " . string(keys(compileSettings))
        let s:magicToRun = ''
    endif
endfunction

function! s:GetBuildSettings()
    " Look for local settings
    let looker = globpath(getcwd(), ".magic-compile")
    if looker == ''
        " Then check ft-specific
        let looker = globpath("~/.vim/bundle/personal-magic.vim/templates/", ".".&ft."-magic-compile")

        if looker == ''
            " Then check os-ft-specific
            let os = 'osx'
            if has("win32")
                let os = 'win'
            endif

            let looker = globpath("~/.vim/bundle/personal-magic.vim/templates/", ".".os."-".&ft."-magic-compile")
            if looker == ''
                echo "No .magic-compile found in current directory"
                return {}
            endif
        endif
    endif

    let cont = readfile(looker)
    let settings = {}
    let currentSetting = ""
    for line in cont
        if line[0] == ':'
            let settings[line[1:]] = []
            let currentSetting = line[1:]
        elseif line[0] == '#'
            "comment
        elseif line != ""
            let settings[currentSetting] = add(settings[currentSetting], line)
        endif
    endfor
    return settings
endfunction

" Run the saved "run" command from last MagicCompile
" :J repeats, :J! repeats, keeping results open
function! s:MagicCompileRun(bang)
    let settings = s:GetBuildSettings()

    if exists("s:magicToRun") && s:magicToRun != ''
        exe "MagicJob". a:bang . " " . s:magicToRun
    else
        if has_key(settings, "RUN") && len(settings["RUN"]) >= 1
            let run = substitute(settings["RUN"][0], "\$FULLWD", getcwd(), 'g')
            let run = substitute(run, "\$WD", split(getcwd(), '/')[-1], 'g')
            let run = substitute(run, "%", expand("%"), 'g')
            exe "MagicJob". a:bang . " " . run
        endif
    endif
endfunction

command! -nargs=1 MCompile call s:MagicCompile(<q-args>)
command! -bang MCRun call s:MagicCompileRun('<bang>')
