" MAKE_TEMPLATE {{{
" Path> src/test/folder
" namespace> void_engine
" ClassName> MyAwesomeClass
"  = src/test/folder/my_awesome_class.h
"    src/test/folder/my_awesome_class.cpp
"    header guard: _VOID_ENGINE_TEST_FOLDER_MY_AWESOME_HEADER_H_
function! MakeTemplate()
    let template_relative_path=input("Path> src/")
    let template_namespace=input("namespace> ")
    let template_class_name=input("ClassName> ")
    " let template_relative_path="src/".template_relative_path
    echo "\r"
    "echo template_relative_path
    let template_header_guard=toupper("_" . template_namespace . "_" . substitute(template_relative_path, "\/", "_", "g") . "_" . substitute(template_class_name, "\\v\\C([a-z])([A-Z])", "\\1_\\2", "g") . "_H_")
    let template_filename_stub=tolower( substitute(template_class_name, "\\v\\C([a-z])([A-Z])", "\\L\\1_\\2", "g") )
    call system("mkdir -p ./src/". template_relative_path)
    "call system("cp ~/.vim/bundle/vim-template/templates/t.h " . getcwd() . "/src/". template_relative_path . "/" . template_filename_stub . ".h")
    "call system("cp ~/.vim/bundle/vim-template/templates/t.cpp " . getcwd() . "./src/". template_relative_path . "/" . template_filename_stub . ".cpp")

    let template_cwd=getcwd()
    let template_vim_path="~/.vim/bundle/vim-magic-template/templates/"

    execute "tabnew " . template_cwd . "/src/" . template_relative_path . "/" . template_filename_stub . ".cpp"
    execute "r " . template_vim_path . "t.cpp"

    execute "vsplit " . template_cwd . "/src/" . template_relative_path . "/" . template_filename_stub . ".h"
    execute "r " . template_vim_path . "t.h"

    execute "%s\/%INCL_GUARD%\/" . template_header_guard . "\/g"
    execute "%s\/%NAMESPACE%\/" . template_namespace . "\/g"
    execute "%s\/%CLASS_NAME%\/" . template_class_name . "\/g"
    execute "normal! ggdd"
    execute "w"

    execute "normal gs"
    execute "%s\/%POUND_INCL%\/" . template_filename_stub . ".h" . "\/g"
    execute "%s\/%NAMESPACE%\/" . template_namespace . "\/g"
    execute "%s\/%CLASS_NAME%\/" . template_class_name . "\/g"
    execute "normal! ggdd"
    execute "w"
endfunction
" }}}
nnoremap <leader>z :call MakeTemplate()<cr>
