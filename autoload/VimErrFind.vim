" VimErrFind.vim: find error in vim function given its name and the line number therein
"	Author:	Charles E. Campbell
"   Date:	Jul 02, 2013
"   Version: 2k	ASTRO-ONLY
"
" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || exists("loaded_VimErrFind")
 finish
endif
let g:loaded_VimErrFind = "v2k"
let s:keepcpo           = &cpo
set cpo&vim
"DechoTabOn

" ---------------------------------------------------------------------
" VEF: implements the vim error find line function {{{1
fun! VimErrFind#VEF(cnt,...) range
"  call Dfunc("VimErrFind#VEF(cnt=".a:cnt.",...) bufname<".bufname("%")."> a:0=".a:0.((a:0 > 0)? (" a:1=".a:1) : ""))

"  set up function name and linenumber
"     * if only one input argument, and its a number
"       - use current function
"       - if outside a function, use following function
"       - if no previous function, complain&exit
"     * two arguments: expecting VEF function-name line-number

" Open all folds
  norm! zR0

  if a:0 == 0 && a:cnt >= 1
   " <count>VEF  -or-  VEF linenumber
"   call Decho("case <count>VEF:  a:cnt=".a:cnt)
   let linenum = a:cnt
   let swp     = SaveWinPosn(0)
   norm! $
   let bwdfun    = search('^\s*fun\%[ction]\>\s*!\=\s*\%(<[sS][iI][dD]>\|[sS]:\|\h\w*#\)\=\s*\zs\h','bcWn')
   let fwdfun    = search('^\s*fun\%[ction]\>\s*!\=\s*\%(<[sS][iI][dD]>\|[sS]:\|\h\w*#\)\=\s*\zs\h','cWn')
   let bwdendfun = search('^\s*endf\%[unction]\>','nbcW')
"   call Decho("bwdfun   #".bwdfun)
"   call Decho("fwdfun   #".fwdfun)
"   call Decho("bwdendfun#".bwdendfun)
"   call Decho("line(.)  #".line("."))

   " Case 1             Case 2         Case 3
   " function1          function1      cursor
   "   cursor           endfunction    function1
   " endfunction        cursor         endfunction
   if      bwdfun == line(".") ||
	  \ (0 < bwdfun && bwdfun < line(".") && bwdendfun == 0) ||
	  \ (0 < bwdendfun && bwdendfun < bwdfun && bwdfun < line(".")) ||
	  \ (bwdendfun == line("."))

	" Case 1 : go to beginning of function surrounding cursor
"	call Decho("Case 1: function ... cursor ... endfunction")
    call search('^\s*fun\%[ction]\>\s*!\=\s*\%(<[sS][iI][dD]>\|[sS]:\|\h\w*#\)\=\s*\zs\h','bcW')

   elseif 0 < bwdfun && bwdfun < bwdendfun && bwdendfun < line(".") && line(".") < fwdfun
	" Case 2: go to next function
"	call Decho("Case 2: function ... endfunction ... cursor")
    call search('^\s*fun\%[ction]\>\s*!\=\s*\%(<[sS][iI][dD]>\|[sS]:\|\h\w*#\)\=\s*\zs\h','cW')

   elseif  0 == bwdfun && line(".") < fwdfun
	" Case 3: go to next function
"	call Decho("Case 3: cursor ... function ... endfunction")
    call search('^\s*fun\%[ction]\>\s*!\=\s*\%(<[sS][iI][dD]>\|[sS]:\|\h\w*#\)\=\s*\zs\h','cW')

   else
	let fail= 1
   endif

   if !exists("fail")
    let funcname= expand("<cword>")
	call RestoreWinPosn(swp)
   endif

  elseif a:0 == 1 && a:1 =~ '^\d'
   " VEF linenumber
"   call Decho("case VEF linenumber: a:1=".a:1)
   let linenum = a:1
   let swp     = SaveWinPosn(0)
"   call Decho("case VEF linenum=".linenum.": line(.)=".line("."))
   norm! $
   if search('^\s*fun\%[ction]\>\s*!\=\s*\%(<[sS][iI][dD]>\|[sS]:\|\h\w*#\)\=\s*\zs\h','bcW')
   	let funcname= expand("<cword>")
	call RestoreWinPosn(swp)

   elseif exists("s:funcname")
	" VEF
"	call Decho("case VEF: funcname<".s:funcname.">")
   	let funcname= s:funcname

   else
	let fail= 2
   endif

  elseif a:0 >= 2
   " VEF funcname linenumber
"   call Decho("case VEF ".a:1." ".a:2.":")
   let funcname= a:1
   let linenum = a:2

  else
   let fail= 3
  endif

  if exists("fail")
"   call Decho("fail#".fail)
   echoerr "***usage*** VEF [funcname] [errline]"
"   call Dret("VimErrFind#VEF : [errline#]VEF [funcname] [errline#]")
   return
  endif

  " since the patterns below already incorporate s: and <SID>, etc, remove them if present from funcname
  let funcname  = substitute(funcname,'^\s*\%([sS]:\|<[sS][iI][dD]>\|\h\w*#\)','','')
  let s:funcname= funcname
"  call Decho("using VEF funcname<".funcname."> linenum#".linenum)
"  call Decho("curline#".line("."))

  " case sensitive search
  norm! $
  if search('^\s*fun\%[ction]!\=\s\+\([sS]:\|<[sS][iI][dD]>\|\h\w*#\)\=\s*'.funcname.'\>','bcw') != 0
   let errline= line(".") + linenum
"   call Decho("errline= [search()=".line(".")."]+[linenum=".linenum."]=".errline)
   call cursor(errline,1)
   silent! norm! zMzOz.

  " case insensitive search
  elseif search('\c^\s*fun\%[ction]!\=\s\+\(s:\|<sid>\|\h\w*#\)\=\s*.\{-}'.funcname.'\>','bcw') != 0
   let errline= line(".") + linenum
"   call Decho("errline= [search()=".line(".")."]+[linenum=".linenum."]=".errline." (case insensitive search)")
   call cursor(errline,1)
   silent! norm! zMzOz.

  else
   " look for tag
"   call Decho("attempting to tag to funcname first")
   try
    let tags= taglist(funcname)
   catch /^Vim\%((\a\+)\)\=:E426/
    echoerr "unable to find function<".funcname.">"
"    call Dret("VimErrFind#VEF : line#".line("."))
	return
   endtry
"   call Decho(string(tags))

   " multiple tag matches
   if len(tags) > 1
	let tagquery= deepcopy(tags,1)
	call map(tagquery,'v:key.": ".v:val["name"]."  (".v:val["filename"].")"')
	let select= inputlist(tagquery)
	exe select."ta ".funcname
    let errline= line(".") + linenum
"    call Decho("errline= [search()=".line(".")."]+[linenum=".linenum."]=".errline)
    call cursor(errline,1)
    silent! norm! zMzOz.
	unlet tags tagquery

   " one tag match
   elseif len(tags) == 1
	exe "tj ".funcname
"    call Decho("errline= [search()=".line(".")."]+[linenum=".linenum."]=".errline)
    call cursor(errline,1)
    silent! norm! zMzOz.
	unlet tags

   else
	" failed...
"    call Decho("(failed) search('^\\s*fun\\%[ction]!\\=\\s\\+\\([sS]:\\|<[sS][iI][dD]>\\|\\h\\w*#\\)\\=\\s*".funcname."\\>','cw')=".search('^\s*fun\%[ction]!\=\s*\([sS]:\|<[sS][iI][dD]>\|\h\w*#\)\=\s*\<'.funcname.'\>','cw'))
"    call Decho("(failed) search('\\c^\\s*fun\\%[ction]!\\=\\s\\+\\(s:\\|<sid>\\|\\h\\w*#\\)\\=\\s*.\\{-}".funcname."\\>','cw')=".search('\c^\s*fun\%[ction]!\=\s*\(s:\|<sid>\|\h\w*#\)\=\s*.\{-}\<'.funcname.'\>','cw'))
"    call Decho("***error*** unable to find function<".funcname.">")
    echoerr "unable to find function<".funcname.">"
   endif
  endif
"  call Dret("VimErrFind#VEF : line#".line("."))
endfun

let &cpo= s:keepcpo
unlet s:keepcpo
" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim: ts=4 fdm=marker
