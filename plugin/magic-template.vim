" MAKE_TEMPLATE {{{
" Path> src/test/folder
" namespace> void_engine
" ClassName> MyAwesomeClass
"  = src/test/folder/my_awesome_class.h
"    src/test/folder/my_awesome_class.cpp
"    header guard: _VOID_ENGINE_TEST_FOLDER_MY_AWESOME_HEADER_H_
function! MakeCppTemplate()
    let template_relative_path=input("Path> src/")
    let template_namespace=input("namespace> ")
    let template_class_name=input("ClassName> ")

    let template_header_guard=toupper("_" . template_namespace . "_" . substitute(template_relative_path, "\/", "_", "g") . "_" . substitute(template_class_name, "\\v\\C([a-z])([A-Z])", "\\1_\\2", "g") . "_H_")
    let template_filename_stub=tolower( substitute(template_class_name, "\\v\\C([a-z])([A-Z])", "\\L\\1_\\2", "g") )

    if has("mac")
        call system("mkdir -p ./src/". template_relative_path)
    elseif has("win32")
        call system("mkdir src/" . template_relative_path)
    endif

    let template_cwd=getcwd()
    let template_vim_path="~/.vim/bundle/personal-magic.vim/templates/"

    execute "tabnew " . template_cwd . "/src/" . template_relative_path . "/" . template_filename_stub . ".cpp"
    execute "r " . template_vim_path . "t.cpp"

    execute "vsplit " . template_cwd . "/src/" . template_relative_path . "/" . template_filename_stub . ".h"
    execute "r " . template_vim_path . "t.h"

    execute "%s\/%INCL_GUARD%\/" . template_header_guard . "\/g"
    execute "%s\/%NAMESPACE%\/" . template_namespace . "\/g"
    execute "%s\/%CLASSNAME%\/" . template_class_name . "\/g"
    execute "normal! ggdd"
    execute "w"

    execute "normal gww"
    execute "%s\/%POUND_INCL%\/" . template_filename_stub . ".h" . "\/g"
    execute "%s\/%NAMESPACE%\/" . template_namespace . "\/g"
    execute "%s\/%CLASSNAME%\/" . template_class_name . "\/g"
    execute "normal! ggdd"
    execute "w"
endfunction
" }}}



" MAKE_HTML_NOTES {{{
function! MakeHtmlPreview()
    let template_vim_path="~/.vim/bundle/personal-magic.vim/templates/"
    let personal_notes_path="~/Dropbox/vim-notes/"
    let personal_notes_files=split(globpath(personal_notes_path, "**/*.md"), '\n')

    call system("cp " . template_vim_path . "header.html " . personal_notes_path . "index.html" )

    "Table of Contents
    call system("echo \"<div class='toc'><h1>vim-notes<\/h1>\" >> " . personal_notes_path . "index.html")
    for p_file in personal_notes_files
       let shortname=substitute(p_file, "\\v\/(.+\/)(.+\..+)", "\\2", "g")
       let toc_link="<a href='#" . shortname .  "'>" . shortname . "</a><br>"
       call system("echo '". toc_link . "' >> " . personal_notes_path . "index.html")
    endfor
    call system("echo \"<\/div><div id=\\\"contentholder\\\">\" >> " . personal_notes_path . "index.html")


    "Each 'post'
    for p_file in personal_notes_files
       let shortname=substitute(p_file, "\\v\/(.+\/)(.+\..+)", "\\2", "g")
       let post="<div class='content' id='" .shortname . "'>"
       call system("echo '". post . "' >> " . personal_notes_path . "index.html")
       call system("markdown " . personal_notes_path . shortname . " >> " .personal_notes_path . "index.html")
       call system("echo \"<\/div>\" >> " . personal_notes_path . "index.html")
    endfor

    "Cap it all off w/ the footer
    call system("cat " . template_vim_path . "footer.html >> " . personal_notes_path . "index.html" )

endfunction
" }}}
