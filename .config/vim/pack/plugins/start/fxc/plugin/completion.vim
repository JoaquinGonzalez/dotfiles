" This file contains my config for auto-completion using LSP servers with the
" vim-lsc client. The following servers are configured:
" - clangd for C
" - pyls for Python
" For C, there is a nice setup to automate CFLAGS detection and indexing all
" project files.
"-fxc

set completeopt=menu,longest,menuone,preview
" Too buggy rn, vim does not respect noinsert change
let g:lsc_enable_autocomplete=v:false
let g:lsc_enable_diagnostics=v:true
let g:lsc_auto_completeopt="menu,menuone,noinsert,preview"
let g:lsc_enable_snippet_support=v:true
let g:lsc_enable_popup_syntax=v:true
let g:lsc_enable_apply_edit=v:true
let g:lsc_reference_highlights=v:false
let g:lsc_server_commands={}

highlight lscDiagnosticError cterm=bold ctermbg=1 ctermfg=7
highlight lscDiagnosticWarning cterm=bold ctermbg=3 ctermfg=0

autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

if executable("pylsp")
    let s:pylscfg={"plugins": {
        \ "autopep8": {"enabled": v:false},
        \ "mccabe": {"enabled": v:false},
        \ "pycodestyle": {"enabled": v:false},
        \ "pydocstyle": {"enabled": v:false},
        \ "pyflakes": {"enabled": v:true},
        \ "pylint": {"enabled": v:false},
        \ "rope_completion": {"enabled": v:false},
        \ "rope_rename": {"enabled": v:false},
        \ "yapf": {"enabled": v:false},
        \ "flake8": {"enabled": v:false},
        \ "folding": {"enabled": v:false},
        \ "jedi_completion": {"enabled": v:true},
        \ "jedi_definition": {"enabled": v:true},
        \ "jedi_highlight": {"enabled": v:true},
        \ "jedi_hover": {"enabled": v:true},
        \ "jedi_references": {"enabled": v:true},
        \ "jedi_rename": {"enabled": v:true},
        \ "jedi_signature_help": {"enabled": v:true},
        \ "jedi_symbols": {"enabled": v:true},
        \ "preload": {"enabled": v:false}
        \ }}
    let g:lsc_server_commands["python"] = {
        \ "name": "pyls",
        \ "command": "pylsp",
        \ "workspace_config": {"pylsp": s:pylscfg},
        \ "suppress_stderr": v:true,
        \ }
endif

if executable("clangd")
    " Alternate source/header with clangd, bound to :A[SVT] like a.vim.
    function! s:clangd_alternate(scmd, ...)
        let l:params={"uri": call(function("lsc#uri#documentUri"), a:000)}
        let l:servers=filter(lsc#server#forFileType(&filetype), {i, v -> v.config.name is# "clangd"})
        if len(l:servers) == 0 | echoerr "clangd not available" | return | endif
        let l:server=l:servers[0]
        function! s:clangd_alternate_callback(uri) closure
            let l:path=lsc#uri#documentPath(a:uri)
            call timer_start(100, {-> execute(":" . a:scmd . " " . l:path)})
        endfunction
        call l:server.request('textDocument/switchSourceHeader', l:params, function("s:clangd_alternate_callback"))
    endfunction
    comm! -nargs=? -bang A call s:clangd_alternate("e<bang>", <f-args>)
    comm! -nargs=? -bang AS call s:clangd_alternate("sp<bang>", <f-args>)
    comm! -nargs=? -bang AV call s:clangd_alternate("vs<bang>", <f-args>)
    comm! -nargs=? -bang AT call s:clangd_alternate("tab sp<bang>", <f-args>)

    " Find root of C project using .git and Makefile, falling back to file directory.
    function! s:clangd_find_root()
        let l:path=expand("%:p:h")
        let l:makefile=findfile("Makefile", l:path . ";")
        let l:git=finddir(".git", l:path . ";")
        if !empty(l:git)
            let l:path=fnamemodify(fnamemodify(l:git, ":h"), ":p")
        elseif !empty(l:makefile)
            let l:path=fnamemodify(fnamemodify(l:makefile, ":h"), ":p")
        endif
        return l:path
    endfunction

    let s:clangd_root = "."
    let s:clangd_cflags = []
    let s:clangd_compile_commands = {}

    " Find CFLAGS for C project.
    " This takes the CFLAGS value after evaluating the Makefile,
    " or falls back to sane defaults (ie. C89 #pedantic).
    function! s:clangd_find_cflags(path)
        let l:makefile=a:path . "/Makefile"
        let l:cflags=["-x", "c", "-std=c89", "-pedantic", "-Wall"]
        if filereadable(l:makefile)
            let l:makefile=readfile(l:makefile)
            call add(l:makefile, "__cflags:")
            call add(l:makefile, "\t@printf \"%s\\n\" $(CFLAGS)")
            let l:cflags=split(system("make --no-print-directory -C " . shellescape(a:path) . " -f - __cflags", join(l:makefile, "\n") . "\n"), "\n")
            let l:cflags=filter(l:cflags, {i, v -> match(v, '^-march=') < 0 && match(v, '^-O[s0123]$') < 0})
        endif
        return l:cflags
    endfunction

    " Computes init params for clangd (root URI, cflags, ...).
    " Note that fallbackFlags is not taken into account if a compilation database is found (compile_flags.txt/compile_commands.json).
    " And that rootUri is largely ignored by clangd despite the importance of it (eg. for relative -I flags).
    " We work around that by generating a compilation database on the fly:
    " 1) a list of C files is generated by enumerating all the *.c targets as seen by make (falling back to just the current file)
    " 2) for each C file, a compilation command is crafted (cc $(CFLAGS) -c $<), and the working directory is set to the root URI
    " Not only this ensures that the working directory is correct for every file (and thus relative -I flags work),
    " but also registering compile commands for every flags has the added benefit of making clangd index all source files in the project.
    " That way, finding references in files that are not opened works, among other things.
    function! s:clangd_init(method, params)
        let l:cfiles=[expand("%:p")]
        let l:path=s:clangd_find_root()
        let l:cflags=s:clangd_find_cflags(l:path)
        let l:makefile=l:path . "/Makefile"
        if filereadable(l:makefile)
            let l:cfiles=map(split(system("make -C " . shellescape(l:path) . " -nd | sed -n \"s/^[ \\\\t]*Considering target file '\\\\(.*\\\\.c\\\\)'\\\\.\\$\"/\\\\1/p"), "\n"), {i, v -> fnamemodify(l:path . "/" . v, ":p:gs?//?/?")})
        endif
        let l:commands={}
        for l:cfile in l:cfiles
            let l:commands[l:cfile] = {"workingDirectory": l:path, "compilationCommand": ["cc"] + l:cflags + ["-c", l:cfile]}
        endfor
        let s:clangd_root = l:path
        let s:clangd_compile_commands = l:commands
        let s:clangd_cflags = l:cflags
        return {
            \ "initializationOptions": {
            \     "fallbackFlags": l:cflags,
            \     "compilationDatabasePath": l:path,
            \     "compilationDatabaseChanges": l:commands,
            \ },
            \ "rootUri": lsc#uri#documentUri(l:path)
            \ }
    endfunction

    " The function above works at init time, for source files only.
    " It does not register headers, thus the flags won't be used when opening headers.
    " This is because a compilation database is used (the one we generated),
    " so clangd won't use fallbackFlags. Annoying.
    " We work around that by generating a fake compile command (for a header!)
    " when the file is opened, ie. a BufRead *.h autocmd.
    function s:clangd_header()
        let l:servers=filter(lsc#server#forFileType(&filetype), {i, v -> v.config.name is# "clangd"})
        if len(l:servers) == 0 | return | endif
        let l:clangd=l:servers[0]
        let l:path=expand("%:p")
        let l:compile_cmd = {"workingDirectory": s:clangd_root, "compilationCommand": ["cc", "-x", "c"] + s:clangd_cflags + ["-Wno-empty-translation-unit", "-c", l:path]}
        let l:settings = {"compilationDatabaseChanges": {l:path: l:compile_cmd}}
        let s:clangd_compile_commands[l:path] = l:compile_cmd
        call clangd.notify("workspace/didChangeConfiguration", {"settings": l:settings})
    endfunction
    autocmd BufNewFile,BufRead *.h call s:clangd_header()

    function! s:cflags(...)
        let l:servers=filter(lsc#server#forFileType(&filetype), {i, v -> v.config.name is# "clangd"})
        if len(l:servers) == 0 | return | endif
        let l:clangd=l:servers[0]
        let l:path=expand("%:p")
        if has_key(s:clangd_compile_commands, l:path)
            let l:root = s:clangd_compile_commands[l:path].workingDirectory
        else
            let l:root = s:clangd_root
        endif
        let l:compile_cmd = {"workingDirectory": l:root, "compilationCommand": ["cc", "-x", "c"] + a:000 + ["-c", l:path]}
        let l:settings = {"compilationDatabaseChanges": {l:path: l:compile_cmd}}
        let s:clangd_compile_commands[l:path] = l:compile_cmd
        call clangd.notify("workspace/didChangeConfiguration", {"settings": l:settings})
    endfunction
    comm! -nargs=* Cflags call s:cflags(<f-args>)

    function! s:croot(root)
        let l:servers=filter(lsc#server#forFileType(&filetype), {i, v -> v.config.name is# "clangd"})
        if len(l:servers) == 0 | return | endif
        let l:clangd=l:servers[0]
        let l:path=expand("%:p")
        if has_key(s:clangd_compile_commands, l:path)
            let l:cmd = s:clangd_compile_commands[l:path].compilationCommand
        else
            let l:cmd = ["cc", "-x", "c", "-c", l:path]
        endif
        let l:compile_cmd = {"workingDirectory": a:root, "compilationCommand": l:cmd}
        let l:settings = {"compilationDatabaseChanges": {l:path: l:compile_cmd}}
        let s:clangd_compile_commands[l:path] = l:compile_cmd
        call clangd.notify("workspace/didChangeConfiguration", {"settings": l:settings})
    endfunction
    comm! -nargs=1 Croot call s:croot(<f-args>)

    function! s:cinfo()
        let l:path=expand("%:p")
        if has_key(s:clangd_compile_commands, l:path)
            echom s:clangd_compile_commands[l:path]
        else
            echom {}
        endif
    endfunction
    comm! -nargs=0 Cinfo call s:cinfo()

    function! s:cfiles()
        echom keys(s:clangd_compile_commands)
    endfunction
    comm! -nargs=0 Cfiles call s:cfiles()

    function! s:cgrep_args(...)
        if len(a:000) > 0
            return [a:1] + keys(s:clangd_compile_commands)
        endif
        return [expand("<cword>")] + keys(s:clangd_compile_commands)
    endfunction

    comm! -nargs=? Cgrep call choice#egrep(s:cgrep_args(<f-args>))
    comm! -nargs=? CHgrep call choice#hgrep(s:cgrep_args(<f-args>))
    comm! -nargs=? CVgrep call choice#vgrep(s:cgrep_args(<f-args>))

    " -pch-storage=memory: because otherwise clangd will fill /tmp with
    "  hundreds of precompiled headers and won't clean them ever.
    " -header-insertion=never: because otherwise clangd will insert headers
    "  in insertion mode when adding a function whose header has not been
    "  included yet. But no thanks, really. Please do not touch my code!
    let g:lsc_server_commands["c"] = {
        \ "name": "clangd",
        \ "command": "clangd -pch-storage=memory -header-insertion=never -clang-tidy=0",
        \ "message_hooks": {
        \     "initialize": function("s:clangd_init")
        \ },
        \ "suppress_stderr": v:true,
        \ }
endif

let g:lsc_auto_map = {
    \ "defaults": v:false,
    \ "Completion": "omnifunc",
    \ "ShowHover": v:false,
    \ "GoToDefinition": "<C-]>",
    \ "FindReferences": "<C-\>",
    \ "FindCodeActions": "<C-F>",
    \ }

let s:popupid = 0
function! s:update_sighelp()
    if s:popupid != 0
        call popup_close(s:popupid)
        let s:popupid = 0
    endif
    function! s:sighelp_popup_close(id, res)
        let s:popupid = 0
    endfunction
    function! s:sighelp_popup_open(result)
        if empty(a:result) || empty(a:result.signatures) || type(a:result.signatures) != type([])
            return
        endif
        let l:n = len(a:result.signatures)
        if l:n == 0
            return
        endif
        if has_key(a:result, "activeSignature") && a:result.activeSignature < l:n
            let l:sig = a:result.signatures[a:result.activeSignature]
        else
            let l:sig = a:result.signatures[0]
        endif
        if !has_key(l:sig, "label")
            return
        endif
        let l:msg = [l:sig.label]
        if has_key(l:sig, "documentation")
            let l:msg += split(l:sig.documentation, "\n")
        endif
        let s:popupid = popup_create(l:msg, {"line": "cursor-1", "col": "cursor", "pos": "botleft", "moved": "any", "callback":  function("s:sighelp_popup_close")})
        call setbufvar(winbufnr(s:popupid), "&filetype", &filetype)
        if has_key(l:sig, "parameters") && has_key(a:result, "activeParameter") && a:result.activeParameter < len(l:sig.parameters)
            let l:param = l:sig.parameters[a:result.activeParameter].label
            call matchadd("lscCurrentParameter", "\\V\\<" . l:param . "\\>", 1, -1, {"window": s:popupid})
        endif
    endfunction
    call lsc#server#userCall("textDocument/signatureHelp", lsc#params#documentPosition(), function("s:sighelp_popup_open"))
endfunction

function! s:init_lsp()
    if !has_key(g:, "loaded_lsc") || g:loaded_lsc != 1 | return | endif
    let l:servers=lsc#server#forFileType(&filetype)
    if len(l:servers) == 0 | return | endif
    if !lsc#server#filetypeActive(&filetype) | return | endif
    au TextChangedI,InsertEnter,CursorMovedI <buffer> call s:update_sighelp()
    "lsc#signaturehelp#getSignatureHelp()
endfunction

au BufNewFile,BufRead * call s:init_lsp()

function! s:action_menu(actions, callback)
    let l:choices = []
    let l:idx = 0
    for l:action in a:actions
        call add(l:choices, l:idx . " " . l:action["title"])
        let l:idx = l:idx + 1
    endfor
    let l:r = choice#choice(l:choices)
    if l:r isnot# ""
        call a:callback(a:actions[l:r])
    endif
endfunction

let g:LSC_action_menu = function("s:action_menu")
