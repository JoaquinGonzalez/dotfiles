set background=dark
""highlight clear
highlight SpecialKey     term=bold cterm=bold ctermfg=4 guifg=Cyan
highlight NonText        term=bold cterm=bold ctermfg=4 gui=bold guifg=Blue
highlight Directory      term=bold cterm=bold ctermfg=6 guifg=Cyan
highlight ErrorMsg       term=standout cterm=bold ctermfg=7 ctermbg=1 guifg=White guibg=Red
highlight IncSearch      term=reverse cterm=reverse gui=reverse
highlight Search         term=reverse ctermfg=0 ctermbg=3 guifg=Black guibg=Yellow
highlight MoreMsg        term=bold cterm=bold ctermfg=2 gui=bold guifg=SeaGreen
highlight ModeMsg        term=bold cterm=bold gui=bold
highlight LineNr         term=underline cterm=bold ctermfg=3 guifg=Yellow
highlight CursorLineNr   term=bold cterm=bold ctermfg=3 gui=bold guifg=Yellow
highlight Question       term=standout cterm=bold ctermfg=2 gui=bold guifg=Green
"highlight StatusLine     term=bold,reverse cterm=bold,reverse gui=bold,reverse
highlight StatusLine     term=bold,reverse cterm=bold ctermfg=7 ctermbg=0 gui=bold,reverse
"highlight StatusLineNC   term=reverse cterm=reverse gui=reverse
highlight StatusLineNC   term=reverse cterm=NONE ctermfg=7 ctermbg=0 gui=reverse
highlight VertSplit      term=reverse cterm=reverse gui=reverse
highlight Title          term=bold cterm=bold ctermfg=5 gui=bold guifg=Magenta
highlight Visual         term=reverse cterm=reverse guibg=DarkGrey
"highlight VisualNOS      cleared
highlight WarningMsg     term=standout cterm=bold ctermfg=1 guifg=Red
highlight WildMenu       term=standout ctermfg=0 ctermbg=3 guifg=Black guibg=Yellow
highlight Folded         term=standout cterm=bold ctermfg=6 ctermbg=0 guifg=Cyan guibg=DarkGrey
highlight FoldColumn     term=standout cterm=bold ctermfg=6 ctermbg=0 guifg=Cyan guibg=Grey
highlight DiffAdd        term=bold ctermbg=1 guibg=DarkBlue
highlight DiffChange     term=bold ctermbg=5 guibg=DarkMagenta
highlight DiffDelete     term=bold cterm=bold ctermfg=4 ctermbg=6 gui=bold guifg=Blue guibg=DarkCyan
highlight DiffText       term=reverse cterm=bold ctermbg=1 gui=bold guibg=Red
""highlight SignColumn     term=standout cterm=bold ctermfg=6 ctermbg=0 guifg=Cyan guibg=Grey
highlight Conceal        ctermfg=7 ctermbg=0 guifg=LightGrey guibg=DarkGrey
highlight SpellBad       term=reverse ctermbg=1 gui=undercurl guisp=Red
highlight SpellCap       term=reverse ctermbg=4 gui=undercurl guisp=Blue
highlight SpellRare      term=reverse ctermbg=5 gui=undercurl guisp=Magenta
highlight SpellLocal     term=underline ctermbg=6 gui=undercurl guisp=Cyan
highlight Pmenu          ctermfg=0 ctermbg=5 guibg=Magenta
highlight PmenuSel       cterm=bold ctermfg=0 ctermbg=0 guibg=DarkGrey
highlight PmenuSbar      ctermbg=7 guibg=Grey
highlight PmenuThumb     ctermbg=7 guibg=White
highlight TabLine        term=underline cterm=bold,underline ctermfg=7 ctermbg=0 gui=underline guibg=DarkGrey
highlight TabLineSel     term=bold cterm=bold gui=bold
highlight TabLineFill    term=reverse cterm=reverse gui=reverse
highlight CursorColumn   term=reverse ctermbg=0 guibg=Grey40
highlight CursorLine     term=underline cterm=underline guibg=Grey40
highlight ColorColumn    term=reverse ctermbg=1 guibg=DarkRed
highlight MatchParen     term=reverse ctermbg=6 guibg=DarkCyan
highlight Comment        term=bold cterm=bold ctermfg=6 guifg=#80a0ff
highlight Constant       term=underline cterm=bold ctermfg=5 guifg=#ffa0a0
highlight Special        term=bold cterm=bold ctermfg=1 guifg=Orange
highlight Identifier     term=underline cterm=bold ctermfg=6 guifg=#40ffff
highlight Statement      term=bold cterm=bold ctermfg=3 gui=bold guifg=#ffff60
highlight PreProc        term=underline cterm=bold ctermfg=4 guifg=#ff80ff
highlight Type           term=underline cterm=bold ctermfg=2 gui=bold guifg=#60ff60
highlight Underlined     term=underline cterm=bold,underline ctermfg=4 gui=underline guifg=#80a0ff
highlight Ignore         ctermfg=0 guifg=bg
highlight Error          term=reverse cterm=bold ctermfg=7 ctermbg=1 guifg=White guibg=Red
highlight Todo           term=standout ctermfg=0 ctermbg=3 guifg=Blue guibg=Yellow
highlight link String Constant
highlight link Character Constant
highlight link Number Constant
highlight link Boolean Constant
highlight link Float Number
highlight link Function Identifier
highlight link Conditional Statement
highlight link Repeat Statement
highlight link Label Statement
highlight link Operator Statement
highlight link Keyword Statement
highlight link Exception Statement
highlight link Include PreProc
highlight link Define PreProc
highlight link Macro PreProc
highlight link PreCondit PreProc
highlight link StorageClass Type
highlight link Structure Type
highlight link Typedef Type
highlight link Tag Special
highlight link SpecialChar Special
highlight link Delimiter Special
highlight link SpecialComment Special
highlight link Debug Special
highlight link CCTreeSymbol Function
highlight link CCTreeMarkers LineNr
highlight link CCTreeArrow CCTreeMarkers
highlight link CCTreePathMark CCTreeArrow
highlight link CCTreeHiPathMark CCTreePathMark
highlight link CCTreeHiKeyword Macro
highlight link CCTreeHiSymbol Todo
highlight link CCTreeHiMarkers NonText
highlight link CCTreeHiArrow CCTreeHiMarkers
highlight link CCTreeUpArrowBlock CCTreeHiArrow
highlight link CCTreeMarkExcl Ignore
highlight link CCTreeMarkTilde Ignore
highlight link helpHeadline Statement
highlight link helpSectionDelim PreProc
highlight link helpIgnore Ignore
highlight link helpExample Comment
highlight link helpBar Ignore
highlight link helpStar Ignore
highlight link helpHyperTextJump Subtitle
highlight link helpHyperTextEntry String
highlight link helpBacktick Ignore
"highlight helpNormal     cleared
highlight link helpVim Identifier
highlight link helpOption Type
highlight link helpCommand Comment
highlight link helpHeader PreProc
"highlight helpGraphic    cleared
highlight link helpNote Todo
highlight link helpSpecial Special
"highlight helpLeadBlank  cleared
highlight link helpNotVi Special
highlight link helpComment Comment
highlight link helpConstant Constant
highlight link helpString String
highlight link helpCharacter Character
highlight link helpNumber Number
highlight link helpBoolean Boolean
highlight link helpFloat Float
highlight link helpIdentifier Identifier
highlight link helpFunction Function
highlight link helpStatement Statement
highlight link helpConditional Conditional
highlight link helpRepeat Repeat
highlight link helpLabel Label
highlight link helpOperator Operator
highlight link helpKeyword Keyword
highlight link helpException Exception
highlight link helpPreProc PreProc
highlight link helpInclude Include
highlight link helpDefine Define
highlight link helpMacro Macro
highlight link helpPreCondit PreCondit
highlight link helpType Type
highlight link helpStorageClass StorageClass
highlight link helpStructure Structure
highlight link helpTypedef Typedef
highlight link helpSpecialChar SpecialChar
highlight link helpTag Tag
highlight link helpDelimiter Delimiter
highlight link helpSpecialComment SpecialComment
highlight link helpDebug Debug
highlight link helpUnderlined Underlined
highlight link helpError Error
highlight link helpTodo Todo
highlight link helpURL String
highlight link Subtitle Identifier
highlight lscCurrentParameter term=reverse cterm=reverse gui=reverse
let g:colors_name = "fxc"
