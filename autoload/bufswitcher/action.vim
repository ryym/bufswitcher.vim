" Vim plugin for switching buffers using statusline
" Maintainer: ryym <ryym64@gmail.com>
" License: The file is placed in the public domain.

" Functions for actions {{{

function! bufswitcher#action#execute(action, ...)
  " TODO: Execute the specified action.
endfunction

" }}}

" Default actions {{{

" The dictionary which stores functions to operate buffers list.
let bufswitcher#action#actions = {}
let s:actions = bufswitcher#action#actions

" Refresh the current statusline.
function! s:actions.refresh(buflister, is_new_buffer)
  let new_statusline = bufswitcher#make_statusline(a:buflister)
  call bufswitcher#replace_statusline(new_statusline, a:is_new_buffer)
endfunction

unlet s:actions

" }}}
