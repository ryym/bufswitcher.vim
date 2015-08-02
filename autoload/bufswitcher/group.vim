" Vim plugin for switching buffers using statusline
" Maintainer: ryym <ryym64@gmail.com>
" License: The file is placed in the public domain.

" Group operations {{{

" Change the current group.
function! bufswitcher#group#change_current_group(group)
  let g:bufswitcher_configs.current_group = a:group
endfunction

" Get a Buflister created by the specified group.
function! bufswitcher#group#get_buflister_from(group)
  if has_key(g:bufswitcher#group#groups, a:group)
    return g:bufswitcher#group#groups[a:group]()
  else
    echoerr "The '" . a:group . "' group doesn't exist."
  endif
endfunction

" }}}

" Default groups {{{

" The dictionary which stores functions to group some buffers.
let bufswitcher#group#groups = {}
let s:groups = bufswitcher#group#groups

" List all exists buffers.
function! s:groups.all()
  let bufnrs = s:get_all_exists_buffers()
  return bufswitcher#new_buflister('All', bufnrs)
endfunction

" List all exists and 'buflisted' buffers.
function! s:groups.listed()
  let bufnrs = filter( s:get_all_exists_buffers(), 'buflisted(v:val)' )
  return bufswitcher#new_buflister('Listed', bufnrs)
endfunction

" }}}

" Utils {{{

function! s:get_all_exists_buffers()
  return filter( range(1, bufnr('$')), 'bufexists(v:val)' )
endfunction

" }}}
