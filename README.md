# vim-magic-template
A personal Vim plugin for C++ templates

## Short description

This plugin defines a mapping for <leader>z that asks for a *file-path* (relative to ./src/), a *namespace*, and a *class name*. 
Those parameters are then used to generate a .cpp and .h in the directory specified

- filenames are based on the *class name* (in the form ClassName) which would produce class_name.(cpp & h)
- **%INCL_GUARD%** is replaced with _NAMESPACENAME_FOLDER_FOLDER_CLASS_NAME_H_
- **%NAMESPACE%** is replaced with *namespace*
- **%CLASS_NAME%** is replaced with *ClassName*
- **%POUND_INCL%** is replaced with *class_name.h*
