let g:PymodeLocList= {}


fun! pymode#tools#loclist#init() "{{{
    return
endfunction "}}}


fun! g:PymodeLocList.init(raw_list) "{{{
    let obj = copy(self)
    let loc_list = filter(copy(a:raw_list), 'v:val["valid"] == 1')
    call obj.clear()
    let obj._title = 'CodeCheck'
    return obj
endfunction "}}}


fun! g:PymodeLocList.current() "{{{
    if !exists("b:pymode_loclist")
        let b:pymode_loclist = g:PymodeLocList.init([])
    endif
    return b:pymode_loclist
endfunction "}}}


fun! g:PymodeLocList.is_empty() "{{{
    return empty(self._errlist) && empty(self._warnlist)
endfunction "}}}

fun! g:PymodeLocList.loclist() "{{{
    let loclist = copy(self._errlist)
    call extend(loclist, self._warnlist)
    return loclist
endfunction "}}}

fun! g:PymodeLocList.num_errors() "{{{
    return len(self._errlist)
endfunction "}}}

fun! g:PymodeLocList.num_warnings() "{{{
    return len(self._warnlist)
endfunction "}}}


fun! g:PymodeLocList.clear() "{{{
    let self._errlist = []
    let self._warnlist = []
    let self._messages = {}
    let self._name = expand('%:t')
endfunction "}}}


fun! g:PymodeLocList.extend(raw_list) "{{{
    let err_list = filter(copy(a:raw_list), 'v:val["type"] == "E"')
    let warn_list = filter(copy(a:raw_list), 'v:val["type"] != "E"')
    call extend(self._errlist, err_list)
    call extend(self._warnlist, warn_list)
    for issue in a:raw_list
        let self._messages[issue.lnum] = issue.text
    endfor
    return self
endfunction "}}}


fun! g:PymodeLocList.filter(filters) "{{{
    let loclist = []
    for error in self.loclist()
        let passes_filters = 1
        for key in keys(a:filters)
            if get(error, key, '') !=? a:filters[key]
                let passes_filters = 0
                break
            endif
        endfor

        if passes_filters
            call add(loclist, error)
        endif

    endfor
    return loclist
endfunction "}}}


fun! g:PymodeLocList.show() "{{{
    call setloclist(0, self.loclist())
    if self.is_empty()
        lclose
    elseif g:pymode_lint_cwindow
        let num = winnr()
        lopen
        setl nowrap
        execute max([min([line("$"), g:pymode_quickfix_maxheight]), g:pymode_quickfix_minheight]) . "wincmd _"
        if num != winnr()
            call setwinvar(winnr(), 'quickfix_title', self._title . ' <' . self._name . '>')
            exe num . "wincmd w"
        endif
    end
endfunction "}}}
