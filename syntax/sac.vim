" Vim syntax file
" Language: SaC
" Maintainer: Hans-Nikolai Viessmann <hans at viess dot mn>
" Maintainer: Artem Shinkarov <artyom.shinkaroff@gmail.com>
" Last Revision: 2020 Nov 20

" This syntax file is partially based on the official VIM
" syntax file for the C programming language.

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" Keyords
syn keyword     sacStatement        return step width
syn keyword     sacConditional      if else
syn keyword     sacRepeat           while for do with
syn keyword     sacBoolean          true false
syn keyword     sacStatement        module import export provide
syn keyword     sacStatement        use all except depecated
syn keyword     sacStatement        objdef
syn keyword     sacTodo             contained TODO FIXME XXX

" It's easy to accidentally add a space after a backslash that was intended
" for line continuation.  Some compilers allow it, which makes it
" unpredictable and should be avoided.
syn match	    sacBadContinuation  contained "\\\s\+$"

" cCommentGroup allows adding matches for special things in comments
syn cluster	    sacCommentGroup     contains=sacTodo,sacBadContinuation

" String and Character constants
" Highlight special characters (those which have a backslash) differently
syn match       sacSpecial          display contained "\\\(x\x\+\|\o\{1,3}\|.\|$\)"
syn match       sacSpecial          display contained "\\\(u\x\{4}\|U\x\{8}\)"
" TODO check the format we use in SaC
syn match       sacFormat           display "%\(\d\+\$\)\=[-+' #0*]*\(\d*\|\*\|\*\d\+\$\)\(\.\(\d*\|\*\|\*\d\+\$\)\)\=\([hlL]\|ll\)\=\([bdiuoxXDOUfeEgGcCsSpn]\|\[\^\=.[^]]*\]\)" contained
syn match       sacFormat           display "%%" contained
" sacCppString: same as sacString, but ends at end of line
syn region      sacString           start=+L\="+ skip=+\\\\\|\\"+ end=+"+ contains=sacSpecial,sacFormat,@Spell extend
syn region      sacCppString        start=+L\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=sacSpecial,sacFormat,@Spell
syn region      sacCppSkip          contained start="^\s*\(%:\|#\)\s*\(if\>\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" contains=sacSpaceError,sacCppSkip
syn cluster     sacStringGroup      contains=sacCppString,sacCppSkip

" If we want we can add support for special characters like '\xff'
syn match       sacCharacter        "L\='[^\\]'"
syn match       sacCharacter        "L'[^']*'" contains=sacSpecial
syn match       sacSpecialError     "L\='\\[^'\"?\\abfnrtv]'"
syn match       sacSpecialCharacter "L\='\\['\"?\\abfnrtv]'"
syn match       sacSpecialCharacter display "L\='\\\o\{1,3}'"
syn match       sacSpecialCharacter display "'\\x\x\{1,2}'"
syn match       sacSpecialCharacter display "L'\\x\x\+'"

" when wanted, highlight trailing white space
if exists("sac_space_errors")
  if !exists("sac_no_trail_space_error")
    syn match   sacSpaceError	    display excludenl "\s\+$"
  endif
  if !exists("sac_no_tab_space_error")
    syn match	sacSpaceError	    display " \+\t"me=e-1
  endif
endif

" Numbers
syn case ignore
syn match      saccNumbers         display transparent "\<\d\|\.\d" contains=sacNumber,sacFloat,sacOctalError,sacOctal
syn match      sacNumbersCom       display contained transparent "\<\d\|\.\d" contains=sacNumber,sacFloat,sacOctal
"syn match      sacNumber           display contained "\d\+\(u\=[bsil]\|u\=ll\)\=\>"
syn match      sacNumber           display contained "\d\+\(u\=l\{0,2}\|ll\=u\)\>"
" hex number
" FIXME we cannot currently have hex number with u?(b|s|i|u|l|ll)
" 0x[0-9a-f]* (b|s|i|l|ll)?
syn match      sacNumber           display contained "0x\x\+\>"

" Flag the first zero of an octal number as something special
" FIXME Again we cannot have postfix in octal numbers
syn match      sacOctal            display contained "0\o\+\>" contains=sacOctalZero
syn match      sacOctalZero        display contained "\<0"
syn match      sacFloat            display contained "\d\+[fd]"
" floating point number, with dot, optional exponent
syn match      sacFloat            display contained "\d\+\.\d*\(e[-+]\=\d\+\)\=[fd]\="
" floating point number, starting with a dot, optional exponent
syn match      sacFloat            display contained "\.\d\+\(e[-+]\=\d\+\)\=[fd]\=\>"
"floating point number, without dot, with exponent
syn match      sacFloat            display contained "\d\+e[-+]\=\d\+[fd]\=\>"
" flag an octal number with wrong digits
syn match      sacOctalError       display contained "0\o*[89]\d*"
syn case match

" With loop modifiers
syn match       sacWlModify        /:\s*modarray/
syn match       sacWlModify        /:\s*genarray\>/
syn match       sacWlModify        /:\s*fold\(fix\)\=/
syn match       sacWlModify        /:\s*propagate/

" Fold written without : is most likely an error
syn match       sacModifyErr       /\<fold\(fix\)\=\>/
syn match       sacModifyErr       /\<propagate>/

syn region      sacBlock           start="{" end="}" transparent fold

" Wrong parenthesis and bracket errors
syn cluster     sacParenGroup      contains=sacParenError,sacInclude,sacSpecial,sacCommentSkip,sacCommentString,sacComment2String,@sacCommentGroup,sacCommentStartError,sacOctalZero,@sacCppOutInGroup,sacFormat,sacNumber,sacFloat,sacOctal,sacOctalError,sacNumbersCom
syn region      sacParen           transparent start='(' end=')' end='}'me=s-1 contains=ALLBUT,sacBlock,@sacParenGroup,sacCppParen,sacErrInBracket,@sacStringGroup,@Spell
syn region      sacCppParen        transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@sacParenGroup,sacErrInBracket,sacParen,sacBracket,sacString,@Spell
syn match       sacParenError      display "[\])]"
syn match       sacErrInParen      display contained "[\]{}]\|<%\|%>"
syn region      sacBracket         transparent start='\[\|<::\@!' end=']\|:>' end='}'me=s-1 contains=ALLBUT,sacBlock,@sacParenGroup,sacErrInParen,sacCppParen,sacCppBracket,@sacStringGroup,@Spell

syn region      sacCppBracket      transparent start='\[\|<::\@!' skip='\\$' excludenl end=']\|:>' end='$' contained contains=ALLBUT,@sacParenGroup,sacErrInParen,sacParen,sacBracket,sacString,@Spell
syn match       sacErrInBracket    display contained "[);{}]\|<%\|%>"

syn region      sacBadBlock        keepend start="{" end="}" contained containedin=sacParen,sacBracket,sacBadBlock transparent fold

" Dot matchs
syn match       sacRexpDot         display contained /\./
syn match       sacRexpPlusStar    display contained /+\|\*/

" Comments
syn match       sacCommentSkip     contained "^\s*\*\($\|\s\+\)"
syn region      sacCommentString   contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end=+\*/+me=s-1 contains=sacSpecial,sacCommentSkip
syn region      sacComment2String  contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end="$" contains=sacSpecial
syn region      sacCommentL        start="//" skip="\\$" end="$" keepend contains=@sacCommentGroup,sacComment2String,sacCharacter,sacNumbersCom,sacSpaceError,sacCommentError,@Spell
syn region      sacComment         matchgroup=sacCommentStart start="/\*" end="\*/" contains=@sacCommentGroup,sacCommentStartError,sacCommentString,sacCharacter,sacNumbersCom,sacSpaceError,@Spell fold extend

syn match       sacCommentError    display "\*/"
syn match       sacCommentStartError display "/\*"me=e-1 contained

" Accept %: for # (C99)
syn region      sacPreCondit        start="^\s*\zs\(%:\|#\)\s*\(if\|ifdef\|ifndef\|elif\)\>" skip="\\$" end="$" keepend contains=sacComment,sacCommentL,sacCppString,sacCharacter,sacCppParen,sacParenError,sacNumbers,sacCommentError,sacSpaceError
syn match       sacPreConditMatch   display "^\s*\zs\(%:\|#\)\s*\(else\|endif\)\>"
syn cluster     sacCppOutInGroup    contains=sacCppInIf,sacCppInElse,sacCppInElse2,sacCppOutIf,sacCppOutIf2,sacCppOutElse,sacCppInSkip,sacCppOutSkip
syn region      sacCppOutWrapper    start="^\s*\zs\(%:\|#\)\s*if\s\+0\+\s*\($\|//\|/\*\|&\)" end=".\@=\|$" contains=sacCppOutIf,sacCppOutElse,@NoSpell fold
syn region      sacCppOutIf         contained start="0\+" matchgroup=sacCppOutWrapper end="^\s*\(%:\|#\)\s*endif\>" contains=sacCppOutIf2,sacCppOutElse
if !exists("sac_no_if0_fold")
  syn region    sacCppOutIf2        contained matchgroup=sacCppOutWrapper start="0\+" end="^\s*\(%:\|#\)\s*\(else\>\|elif\s\+\(0\+\s*\($\|//\|/\*\|&\)\)\@!\|endif\>\)"me=s-1 contains=sacSpaceError,sacCppOutSkip,@Spell fold
else
  syn region    sacCppOutIf2        contained matchgroup=sacCppOutWrapper start="0\+" end="^\s*\(%:\|#\)\s*\(else\>\|elif\s\+\(0\+\s*\($\|//\|/\*\|&\)\)\@!\|endif\>\)"me=s-1 contains=sacSpaceError,sacCppOutSkip,@Spell
endif
syn region      sacCppOutElse       contained matchgroup=sacCppOutWrapper start="^\s*\(%:\|#\)\s*\(else\|elif\)" end="^\s*\(%:\|#\)\s*endif\>"me=s-1 contains=TOP,sacPreCondit
syn region      sacCppInWrapper     start="^\s*\zs\(%:\|#\)\s*if\s\+0*[1-9]\d*\s*\($\|//\|/\*\||\)" end=".\@=\|$" contains=sacCppInIf,sacCppInElse fold
syn region      sacCppInIf          contained matchgroup=sacCppInWrapper start="\d\+" end="^\s*\(%:\|#\)\s*endif\>" contains=TOP,sacPreCondit
if !exists("sac_no_if0_fold")
  syn region    sacCppInElse        contained start="^\s*\(%:\|#\)\s*\(else\>\|elif\s\+\(0*[1-9]\d*\s*\($\|//\|/\*\||\)\)\@!\)" end=".\@=\|$" containedin=sacCppInIf contains=sacCppInElse2 fold
else
  syn region    sacCppInElse        contained start="^\s*\(%:\|#\)\s*\(else\>\|elif\s\+\(0*[1-9]\d*\s*\($\|//\|/\*\||\)\)\@!\)" end=".\@=\|$" containedin=sacCppInIf contains=sacCppInElse2
endif
syn region      sacCppInElse2       contained matchgroup=sacCppInWrapper start="^\s*\(%:\|#\)\s*\(else\|elif\)\([^/]\|/[^/*]\)*" end="^\s*\(%:\|#\)\s*endif\>"me=s-1 contains=sacSpaceError,sacCppOutSkip,@Spell
syn region      sacCppOutSkip       contained start="^\s*\(%:\|#\)\s*\(if\>\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" contains=sacSpaceError,sacCppOutSkip
syn region      sacCppInSkip        contained matchgroup=sacCppInWrapper start="^\s*\(%:\|#\)\s*\(if\s\+\(\d\+\s*\($\|//\|/\*\||\|&\)\)\@!\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" containedin=sacCppOutElse,sacCppInIf,sacCppInSkip contains=TOP,sacPreProc

syn region      sacIncluded         display contained start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match       sacIncluded         display contained "<[^>]*>"
syn match       sacInclude          display "^\s*\(%:\|#\)\s*include\>\s*["<]" contains=sacIncluded

syn cluster     sacPreProcGroup     contains=sacPreCondit,sacIncluded,sacInclude,sacDefine,sacErrInParen,sacErrInBracket,sacSpecial,sacOctalZero,sacCppOutWrapper,sacCppInWrapper,@sacCppOutInGroup,sacFormat,sacNumber,sacFloat,sacOctal,sacOctalError,sacNumbersCom,sacString,sacCommentSkip,sacCommentString,sacComment2String,@sacCommentGroup,sacCommentStartError,sacParen,sacBracket,sacBadBlock
syn region      sacDefine           start="^\s*\zs\(%:\|#\)\s*\(define\|undef\)\>" skip="\\$" end="$" keepend contains=ALLBUT,@sacPreProcGroup,@Spell
syn region      sacPreProc          start="^\s*\zs\(%:\|#\)\s*\(pragma\>\|line\>\|warning\>\|warn\>\|error\>\)" skip="\\$" end="$" keepend contains=ALLBUT,@sacPreProcGroup,@Spell

" Type-related definitions
syn keyword     sacStructure        typedef classtype class
syn keyword     sacStorageClass     external inline noinline

" SaC types
syn keyword     sacType             float bool unsigned byte short int
syn keyword     sacType             long longlong ubyte ushort uint ulong
syn keyword     sacType             ulonglong char double void

" SaC primitive functions
syn keyword     sacOperator         _dim_A_ _shape_A_ _reshape_VxA_
syn keyword     sacOperator         _sel_VxA_ _modarray_AxVxS_
syn keyword     sacOperator         _hideValue_SxA_ _hideShape_SxA_ _hideDim_SxA_
syn keyword     sacOperator         _cat_VxV_ _take_SxV_ _drop_SxV_ _add_SxS_
syn keyword     sacOperator         _add_SxV_ _add_VxS_ _add_VxV_ _sub_SxS_
syn keyword     sacOperator         _sub_SxV_ _sub_VxS_ _sub_VxV_ _mul_SxS_
syn keyword     sacOperator         _mul_SxV_ _mul_VxS_ _mul_VxV_ _div_SxS_
syn keyword     sacOperator         _div_SxV_ _div_VxS_ _div_VxV_ _mod_SxS_
syn keyword     sacOperator         _mod_SxV_ _mod_VxS_ _mod_VxV_ _min_SxS_
syn keyword     sacOperator         _min_SxV_ _min_VxS_ _min_VxV_ _max_SxS_
syn keyword     sacOperator         _max_SxV_ _max_VxS_ _max_VxV_ _abs_S_
syn keyword     sacOperator         _abs_V_ _neg_S_ _neg_V_ _reciproc_S_ _reciproc_V_
syn keyword     sacOperator         _mesh_VxVxV_
syn keyword     sacOperator         _eq_SxS_ _eq_SxV_ _eq_VxS_ _eq_VxV_
syn keyword     sacOperator         _neq_SxS_ _neq_SxV_ _neq_VxS_ _neq_VxV_
syn keyword     sacOperator         _le_SxS_ _le_SxV_ _le_VxS_ _le_VxV_
syn keyword     sacOperator         _lt_SxS_ _lt_SxV_ _lt_VxS_ _lt_VxV_
syn keyword     sacOperator         _ge_SxS_ _ge_SxV_ _ge_VxS_ _ge_VxV_
syn keyword     sacOperator         _gt_SxS_ _gt_SxV_ _gt_VxS_ _gt_VxV_
syn keyword     sacOperator         _and_SxS_ _and_SxV_ _and_VxS_ _and_VxV_
syn keyword     sacOperator         _or_SxS_ _or_SxV_ _or_VxS_ _or_VxV_
syn keyword     sacOperator         _not_S_ _not_V_
syn keyword     sacOperator         _tob_S_ _tos_S_ _toi_S_ _tol_S_ _toll_S_
syn keyword     sacOperator         _toub_S_ _tous_S_ _toui_S_ _toul_S_ _toull_S_
syn keyword     sacOperator         _tof_S_ _tod_S_ _toc_S_ _tobool_S_


hi def link     sacFormat           sacSpecial
hi def link     sacCppString        sacString
hi def link     sacStatement        Statement
hi def link     sacRepeat           Repeat
hi def link     sacConditional      Conditional
hi def link     sacOperator         Operator
hi def link     sacSpecialCharacter sacSpecial
hi def link     sacSpecial          SpecialChar
hi def link     sacString           String
hi def link     sacCharacter        Character
hi def link     sacTodo             Todo
hi def link     sacType             Type
hi def link     sacBoolean          Boolean
hi def link     sacOctalZero        PreProc
hi def link     sacNumber           Number
hi def link     sacOctal            Number
hi def link     sacFloat            Float
hi def link     sacStructure        Structure
hi def link     sacStorageClass     StorageClass
hi def link     sacWlModify         Operator
hi def link     sacWith             Repeat
hi def link     sacCommentL         Comment
hi def link     sacComment          Comment
hi def link     sacModifyErr        Error
hi def link     sacParenError       Error
hi def link     sacErrInParen       Error
hi def link     sacErrInBracket     Error
hi def link     sacSpecialError     Error
hi def link     sacRexpDot          Operator
hi def link     sacRexpPlusStar     Operator
hi def link     sacCommentL         Comment
hi def link     sacComment          Comment
hi def link     sacCommentStart     Comment
hi def link     sacCommentError     Error
hi def link     sacCommentString    String
hi def link     sacPreConditMatch   sacPreCondit
hi def link     sacPreCondit        PreCondit
hi def link     sacPreProc          PreProc
hi def link     sacDefine           Macro
hi def link     sacInclude          Include
hi def link     sacCppOutSkip       Comment
hi def link     sacCppInElse2       Comment
hi def link     sacCppOutIf2        Comment
hi def link     sacCppOut           Comment
hi def link     sacIncluded         String

let b:current_syntax = "sac"
