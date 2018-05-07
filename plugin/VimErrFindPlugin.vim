" VimErrFindPlugin.vim
"   Author: Charles E. Campbell
"   Date:   Apr 17, 2012
" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || exists("g:loaded_VimErrFindPlugin")
 finish
endif
let s:keepcpo = &cpo
set cpo&vim

" ---------------------------------------------------------------------
"  Public Interface: {{{1
com! -count -nargs=* -complete=function	VEF			:call VimErrFind#VEF(<count>,<f-args>)
com! -count -nargs=* -complete=function	VimErrFind	:call VimErrFind#VEF(<count>,<f-args>)

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker
