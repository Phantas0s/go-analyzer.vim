" TODO see if every possible message are documented somewhere (to get rid of these signs everywhere even if somebody don't want them)
" TODO 

let s:go_analyzer_signs = {}
let s:go_analyzer_enabled = 0

function! go_analyzer#Analyze()
    call go_analyzer#reset()
    let l:lines = systemlist('go build -gcflags -m '.expand('%:h').'/*.go')

    let l:list_items = {}
    for line in l:lines
        if  line =~# expand('%')
            let l:pos = split(line, ':')
            let l:lineNo = 0 + l:pos[1]

            " let l:sign_type = ''
            " if line =~# 'escapes to heap'
            "     let l:sign_type = 'escape'
            " elseif line =~# 'inlining call'
            "     let l:sign_type = 'inline'
            " else
            "     continue
            " endif

            let l:sign_type = ''
            for [sign_type, regex] in items(g:go_analyzer_regex)
                if line =~# regex
                    let l:sign_type = sign_type
                endif
            endfor

            if len(l:sign_type) > 0 && get(s:go_analyzer_signs, l:lineNo, '') !~# l:sign_type
                let s:go_analyzer_enabled = 1
                let s:go_analyzer_signs[l:lineNo] = get(s:go_analyzer_signs, l:lineNo, '') . l:sign_type
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
