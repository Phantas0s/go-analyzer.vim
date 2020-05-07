" TODO see if every possible message are documented somewhere (to get rid of these signs everywhere even if somebody don't want them)
" TODO 

let s:go_analyzer_signs = {}
let s:go_analyzer_enabled = 0

function! go_analyzer#Analyze()
    call go_analyzer#reset()

    let l:decision_level = '-m'
    if g:go_analyzer_decision_level ==# 2
        let l:decision_level = '-m -m'
    endif
        
    let l:lines = systemlist('go build -gcflags "'. l:decision_level . '" ' .expand('%:h').'/*.go')

    let l:list_items = {}
    for line in l:lines
        if  line =~# expand('%')
            let l:pos = split(line, ':')
            let l:lineNo = 0 + l:pos[1]

            let l:sign_type = ''
            if len(g:go_analyzer_regex) ==# 0 
                " TODO doesn't make sense... 
                let l:sign_type = "inline"
            else
            for [type, regex] in items(g:go_analyzer_regex)
                if line =~# regex
                    let l:sign_type = type
                endif
            endfor
            endif

            " TODO needs another way to verify if we include the line, signs shouldn't be the way...
            if len(l:sign_type) > 0 && get(s:go_analyzer_signs, l:lineNo, '') !~# l:sign_type
                let s:go_analyzer_enabled = 1
                " sign concatenation
                let s:go_analyzer_signs[l:lineNo] = get(s:go_analyzer_signs, l:lineNo, '') . l:sign_type
                " TODO shouldn't add to list before sorting all of that
                call go_analyzer#add_to_list(line)
            endif
        endif
    endfor

    if g:go_analyzer_show_signs ==# 1
        call go_analyzer#add_signs()
    endif

    cwindow
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

function! go_analyzer#Toggle()
    if s:go_analyzer_enabled == 0
        call go_analyzer#Analyze()
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
