" Common settings for unit tests

runtime plugin/bufswitcher.vim

" Test utilities {{{

let g:Utils = {}

" Open a dummy buffer for tests with multiple buffers.
" This ensures that buffers opened while tests have
" deferrent bufnr from the first one.
silent edit ___

" Open a new buffer and return its buffer number.
function! Utils.open_new_buffer(name, ...)
  silent execute 'edit' a:name
  let another_command = get(a:, '1', '')
  if ! empty(another_command)
    silent execute another_command
  endif
  return bufnr('%')
endfunction

" Wipeout all specified buffers.
function! Utils.wipeout_all(bufnrs)
  for bufnr in a:bufnrs
    silent execute 'bwipeout' bufnr
  endfor
endfunction

" Remove buffer numbers which is not created in the tests.
function! Utils.remove_test_buffers(bufnrs)
  let results = []
  for n in a:bufnrs
    let name = bufname(n)
    if !empty(name) && !isdirectory(name) && name !~ 't/.\+\.vim' && name !~ '___'
      call add(results, n)
    end
  endfor
  return results
endfunction

" }}}

" vim: foldmethod=marker
