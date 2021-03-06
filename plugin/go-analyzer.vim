""
" @section Introduction, intro
" go-analyzer.vim provides a wrapper around `go build -gcflags -m`

if !exists('g:go_analyzer_list_type')
    ""
    " Display the analysis results in (locationlist|quickfix)
    let g:go_analyzer_list_type = 'quickfix'
endif

if !exists('g:go_analyzer_regex')
    ""
    " Only display lines of the analyzer matching some regex
    let g:go_analyzer_regex = {'inline': 'inlining call', 'escape': 'escapes to heap'}
endif

if !exists('g:go_analyzer_show_signs')
    ""
    " Show signs in the gutter
    let g:go_analyzer_show_signs = 1
endif

if !exists('g:go_analyzer_custom_signs')
    ""
    " Default highlighting, use let g:go_analyzer_custom_signs = 0 to disable
    " and define your own.
    "
    " If you provide your own regex with g:go_analyzer_show_regex, you can choose a sign with the value of 
    " each key, i.e go_analyzer_default_<g:go_analyzer_regex key>
    "
    " sign define go_analyzer_default text=x 
    "
    " sign define go_analyzer_inline text=i texthl=Search
    "
    " sign define go_analyzer_escape text=e texthl=Error
    "
    " sign define go_analyzer_escapeinline text=ei texthl=Error
    "
    " sign define go_analyzer_inlineescape text=ei texthl=Error
    "
    let g:go_analyzer_custom_signs = 0
endif

if g:go_analyzer_custom_signs == 0
    sign define go_analyzer_default text=o texthl=Search
    sign define go_analyzer_inline text=i texthl=Search
    sign define go_analyzer_escape text=e texthl=Error
    sign define go_analyzer_escapeinline text=ei texthl=Error
    sign define go_analyzer_inlineescape text=ei texthl=Error
endif

command! -nargs=? GoAnalyzeToggle :call go_analyzer#Toggle(<args>)
