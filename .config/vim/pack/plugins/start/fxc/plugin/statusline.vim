function! s:check_trailing_whitespace()
    let l:l = match(getline(1, "$"), "[ \\t]\\+$") + 1
    let b:fxc_ws = ""
    if l:l
        let b:fxc_ws = "ws:" . l:l
    endif
    let &ro = &ro
endfunction
autocmd BufRead,InsertLeave,TextChanged * call s:check_trailing_whitespace()

function! s:statusline_hunks()
    let b:fxc_hunks = join(map(range(3), '["+", "~", "-"][v:val] . GitGutterGetHunkSummary()[v:val]'), " ")
    let &ro = &ro
endfunction
autocmd User GitGutter call s:statusline_hunks()

function! s:statusline_diagnostics()
    let w:fxc_errors = ""
    let w:fxc_warnings = ""
    if exists('w:lsc_diagnostics')
        let l:diags = w:lsc_diagnostics.ListItems()
        let l:errors = filter(copy(l:diags), {i, v -> v.type is# "E"})
        let l:warnings = filter(copy(l:diags), {i, v -> v.type is# "W"})
        if len(l:errors) > 0
            let w:fxc_errors = "E:" . len(l:errors) . "(L" . l:errors[0].lnum . ")"
        endif
        if len(l:warnings) > 0
            let w:fxc_warnings = "W:" . len(l:warnings) . "(L" . l:warnings[0].lnum . ")"
        endif
    endif
    let &ro = &ro
endfunction
autocmd User LSCDiagnosticsChange call s:statusline_diagnostics()

function! FXC_statusline()
    let l:r = ""
    let l:nc = "NC"
    if bufwinid(bufnr("%")) == get(g:, "statusline_winid", bufwinid(bufnr("%")))
        let l:nc = ""
        let l:mode = mode()
        let l:modemap = {
        \   "n": "NORMAL", "i": "INSERT", "R": "REPLACE", "v": "VISUAL", "V": "V-LINE", "\<C-v>": "V-BLOCK",
        \   "c": "COMMAND", "s": "SELECT", "S": "S-LINE", "\<C-s>": "S-BLOCK", "t": "TERMINAL"
        \}
        let l:modeclrmap = {
        \   "\<C-v>": "V", "\<C-s>": "S",
        \}
        let l:r = l:r . "%#FXCMode" . get(l:modeclrmap, l:mode, l:mode) . "#" . get(l:modemap, l:mode, l:mode)
		if &paste | let l:r = l:r . ' PASTE' | endif
		let l:r = l:r . "%#StatusLine# "
    endif
    let l:r = l:r . '%#FXCHunk#%{exists("b:fxc_hunks") ? b:fxc_hunks : ""}%#StatusLine' . l:nc . '# '
    let l:r = l:r . '%<%f %{&modified ? "+" : ""} %{&readonly ? "" : ""}%='
    let l:r = l:r . '%{&filetype} %{&fenc !=# "utf-8" ? &fenc : ""} %{&ff !=# "unix" ? &ff : ""}'
    let l:r = l:r . ' %#FXCLineNum#%3p%% %3l/%L:%-2v'
    let l:r = l:r . '%#FXCTodo#%{exists("b:fxc_ws") ? ("  " . b:fxc_ws) : ""}'
    let l:r = l:r . '%#FXCTodo#%{exists("w:fxc_warnings") ? ("  " . w:fxc_warnings) : ""}'
    let l:r = l:r . '%#FxcError#%{exists("w:fxc_errors") ? ("  " . w:fxc_errors) : ""}'
    return l:r
endfunction

highlight FXCError          term=reverse cterm=bold ctermbg=0 ctermfg=1 guifg=Red
highlight FXCTodo           term=reverse cterm=bold ctermbg=0 ctermfg=3 guifg=Yellow
highlight FXCModeN          term=reverse cterm=bold ctermbg=0 ctermfg=2 guifg=Green
highlight FXCModeI          term=reverse cterm=bold ctermbg=0 ctermfg=3 guifg=Yellow
highlight FXCModeR          term=reverse cterm=bold ctermbg=0 ctermfg=1 guifg=Red
highlight FXCModeV          term=reverse cterm=bold ctermbg=0 ctermfg=4 guifg=Blue
highlight FXCHunk           term=reverse cterm=NONE ctermbg=0 ctermfg=3 guifg=Blue
highlight FXCLineNum        term=reverse cterm=bold ctermbg=0 ctermfg=6 guifg=Cyan
set laststatus=2 noshowmode
set statusline=%!FXC_statusline()
