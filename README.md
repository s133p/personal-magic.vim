# Personal-Magic.vim
A collection of personal vim-functions to power my [vimrc][]

## Magic-Pending.vim

[magic-pending.vim][] provides operator pending mappings to augment vim's
built in copy and paste functionality.

- `map <KEY> <Plug>MagicStamp`

  Maps <KEY>{motion} to "stamp" last yanked text over motion,
  or replaces visual selection in visual mode.

- `map <KEY> <Plug>MagicClip`

  Maps <KEY>{motion} to "clip" motion/visual selection to system
  clipboard.

- `map <KEY> <Plug>MagicPaste`

  Maps <KEY>{motion} to "paste" system clipboard over
  motion / visual selection.

## MagicJob.vim

[magicjob.vim][] provides functions that leverage vim8 jobs to run
commands asynchronously and displays the results in real time
without blocking. **Rough and undocumented!**


## Magic-Functions.vim

[magic-functions.vim][] provides various helper and misc functions
for use in my vimrc. In particular, the `MagicCompile()` function
which compiles either a visual studio project, or an xcode project
depending on the host system. Along with its companion function
`MagicCompileRun()` which runs the last built project/configuration.

## Magic-Template.vim

[magic-template.vim][] Provides two useful functions:

- `MakeCppTemplate()`

  Takes a relative path, namespace, and class name, and creates
  a header & cpp file using the template code in ./templates/

- `MakeHtmlPreview()`

  Takes a specified folder of markdown files, and uses markdown
  to generate a nicely formatted index.html.




[vimrc]: https://github.com/s133p/dotfiles/blob/master/.vimrc
[magic-pending.vim]: https://github.com/s133p/personal-magic.vim/blob/master/plugin/magic-pending.vim
[magicjob.vim]: https://github.com/s133p/personal-magic.vim/blob/master/plugin/magicjob.vim
[magic-functions.vim]: https://github.com/s133p/personal-magic.vim/blob/master/plugin/magic-functions.vim
[magic-template.vim]: https://github.com/s133p/personal-magic.vim/blob/master/plugin/magic-template.vim
