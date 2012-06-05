"=============================================================================
" File: filemark.vim
" Author: fourside AT gmail DOT com
" Version: 0.1
"=============================================================================

if &cp || (exists('g:loaded_filemark') && g:loaded_filemark)
  finish
endif
let g:loaded_filemark = 1

let s:save_cpo = &cpo
set cpo&vim

" run {{{1
function! s:run()
    " to check
    if !has('viminfo')
        echomsg 'your vim doesn''t have viminfo feature.'
        finish
    elseif !<SID>canUseFilemark()
        echomsg 'your viminfo option can''t use filemark'
        finish
    elseif !<SID>isLowerAlphabet(keys(g:gn_filemark))
        echomsg 'g:gn_filemark''s key has only one character a to z, lower case.'
        finish
    endif

    execute 'wviminfo'
    " to retreive viminfo filepath
    let l:viminfo = <SID>searchViminfo()
    if len(l:viminfo) == 0
        echomsg 'can''t find viminfo.'
        finish
    elseif !filereadable(l:viminfo) || !filewritable(l:viminfo)
        echomsg 'can''t read/write viminfo.'
        finish
    endif

    " to edit viminfo
    call <SID>editViminfo(l:viminfo)
    execute 'rviminfo'

    " to map
    call <SID>mapFilemark()
endfunction

" }}}1
" isLowerAlphabet {{{1
function! s:isLowerAlphabet(list)
    for c in a:list
        if len(c) != 1
            return 0
        elseif char2nr(c) < 97 || char2nr(c) > 122
            return 0
        endif
    endfor
    return 1
endfunction

" }}}1
" canUseFilemark {{{1
function! s:canUseFilemark()
    if &viminfo == '' || stridx(&viminfo, 'f0') != -1
        return 0
    endif
    return 1
endfunction

" }}}1
" searchViminfo {{{1
function! s:searchViminfo()
    let l:viminfo = ''
    " オプションで指定されているか
    let l:options = split(&viminfo, ',')
    if l:options[len(l:options) - 1][0] ==# 'n'
        let l:viminfo = l:options[len(l:options) - 1][1:]
    else
    " オプション指定なければ、OSによる規定値
        if has('win32') || has('win64')
            if exists('$HOME')
                let l:viminfo = '$HOME\_viminfo'
            elseif exists('$VIM')
                let l:viminfo = '$VIM\_viminfo'
            else
                let l:viminfo = 'c:\_viminfo'
            end
        else " Windows以外は*nix系でいい?
            let l:viminfo = '$HOME/.viminfo'
        endif
    endif
    return expand(l:viminfo)
endfunction

"}}}1
" editViminfo {{{1
function! s:editViminfo(viminfo)
    let l:output_lines = []
    for line in readfile(a:viminfo)
        if line =~ "^'[A-Z]" && has_key(g:gn_filemark, tolower(line[1]))
            continue
        elseif line =~ "^'0"
            call <SID>setFilemark(l:output_lines)
        endif
        call add(l:output_lines, line)
    endfor
    call writefile(l:output_lines, a:viminfo)
endfunction

" }}}1
" setFilemark {{{1
function! s:setFilemark(output_lines)
    for m in keys(g:gn_filemark)
        if type(g:gn_filemark[m]) == type([])
            let l:line = "'" . toupper(m) . "  " . g:gn_filemark[m][1] . "  " . g:gn_filemark[m][2] . "  " . g:gn_filemark[m][0]
        else
            let l:line = "'" . toupper(m) . "  1  0  " . g:gn_filemark[m]
        endif
        call add(a:output_lines, l:line)
    endfor
endfunction

" }}}1
" mapFilemark {{{1
function! s:mapFilemark()
    for m in keys(g:gn_filemark)
        execute "nnoremap <unique> gn". m . " `" . toupper(m)
    endfor
endfunction

" }}}1

call <SID>run()

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et:
