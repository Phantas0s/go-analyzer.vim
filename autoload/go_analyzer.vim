" TODO see if every possible message are documented somewhere (to get rid of these signs everywhere even if somebody don't want them)
" TODO 

let s:go_analyzer_signs = {}
let s:go_analyzer_enabled = 0
let s:set_lines = {}
let s:set_repeated_lines = {}

function! go_analyzer#Analyze(...)
    call go_analyzer#reset()

    let l:decision_level = '-m'
    let arg1 = get(a:, 1, 0)
    if arg1 && a:1 ==# 2
        let l:decision_level = '-m -m'
    endif

    let l:lines = systemlist('go build -gcflags "'. l:decision_level . '" ' .expand('%:h').'/*.go')
    echo 'go build -gcflags "'. l:decision_level . '" ' .expand('%:h').'/*.go'
    for line in l:lines
        if  line =~# expand('%')
            let l:pos = split(line, ':')
            let l:lineNo = 0 + l:pos[1]

            let l:sign_type = ''
            if len(g:go_analyzer_regex) ==# 0 
                let l:sign_type = "default"
            else
                for [type, regex] in items(g:go_analyzer_regex)
                    if line =~# regex
                        let l:sign_type = type
                    endif
                endfor
            endif

            if len(l:sign_type) > 0
                let s:go_analyzer_enabled = 1

                if get(s:go_analyzer_signs, l:lineNo, '') !~# l:sign_type
                    " sign concatenation
                    let s:go_analyzer_signs[l:lineNo] = get(s:go_analyzer_signs, l:lineNo, '') . l:sign_type
                endif

                call go_analyzer#stack_lines(l:lineNo, line)
            endif
        endif
    endfor

    call go_analyzer#add_lines()

    if g:go_analyzer_show_signs ==# 1
        call go_analyzer#add_signs()
    endif

    cwindow
endfunction

function! go_analyzer#stack_lines(lineNo, line)
    if has_key(s:set_lines, a:lineNo)
        let s:set_lines[a:lineNo] = add(s:set_lines[a:lineNo], a:line)
    else
        let s:set_lines[a:lineNo] = []
        let s:set_lines[a:lineNo] = add(s:set_lines[a:lineNo], a:line)
    endif
endfunction

function! go_analyzer#add_lines()
	for key in sort(keys(s:set_lines))
        for content in s:set_lines[key]
            call go_analyzer#add_to_list(content)
        endfor
    endfor
endfunction

function go_analyzer#add_signs()
    for [line, type] in items(s:go_analyzer_signs)
        execute ':sign place '.line.' group=go_analyzer line='.line.' name=go_analyzer_'.type.' file='.expand('%:p')
    endfor
endfunction

function go_analyzer#remove_signs()
    for [line, type] in items(s:go_analyzer_signs)
        execute 'sign unplace '.line.' group=go_analyzer file='.expand('%:p')
    endfor
endfunction

function! go_analyzer#Toggle(...)
    let arg1 = get(a:, 1, 0)
    if s:go_analyzer_enabled ==# 0
        if arg1
            call go_analyzer#Analyze(arg1)
        else
            call go_analyzer#Analyze()
        endif
    else
        call go_analyzer#reset()
    endif
endfunction

function! go_analyzer#reset()
    call go_analyzer#close_list()
    call go_analyzer#clear_list()
    call go_analyzer#remove_signs()

    let s:go_analyzer_signs = {}
    let s:go_analyzer_enabled = 0
    let s:set_lines = {}
    let s:set_repeated_lines = {}
endfunction

function! go_analyzer#open_list()
    if g:go_analyzer_list_type ==# 'quickfix'
        cwindow
    elseif g:go_analyzer_list_type ==# 'locationlist'
        lwindow
    else
        echom 'go_analyzer.vim error: unknown list type '.g:go_analyzer_list_type
    endif
endfunction

function! go_analyzer#close_list()
    if g:go_analyzer_list_type ==# 'quickfix'
        cclose
    elseif g:go_analyzer_list_type ==# 'locationlist'
        lclose
    else
        echom 'go_analyzer.vim error: unknown list type '.g:go_analyzer_list_type
    endif
endfunction

function! go_analyzer#clear_list()
    if g:go_analyzer_list_type ==# 'quickfix'
        call setqflist([])
    elseif g:go_analyzer_list_type ==# 'locationlist'
        call setloclist([])
    else
        echom 'go_analyzer.vim error: unknown list type '.g:go_analyzer_list_type
    endif
endfunction


function! go_analyzer#add_to_list(line)
    if g:go_analyzer_list_type ==# 'quickfix'
        caddexpr a:line
    elseif g:go_analyzer_list_type ==# 'locationlist'
        laddexpr a:line
    else
        echom 'go_analyzer.vim error: unknown list type '.g:go_analyzer_list_type
    endif
endfunction
