" Vim plugin for switching buffers using statusline
" Maintainer: ryym <ryym64@gmail.com>
" License: The file is placed in the public domain.

" Functions for actions {{{

" Execute the specified action. All actions first
" show buffer list in statusline.
function! bufswitcher#action#execute(action, ...)
  let actions = g:bufswitcher#action#actions
  if ! has_key(actions, a:action)
    echoerr "The '" . a:action . "' action doesn't exist."
    return
  endif

  call bufswitcher#show_group()
  let buflister = bufswitcher#get_current_buflister()
  let args      = extend([buflister], a:000)
  let Action    = actions[a:action]
  call call(Action, args, actions)
endfunction

" }}}

" Default actions {{{

" The dictionary which stores functions to operate buffer list.
let bufswitcher#action#actions = {}
let s:actions = bufswitcher#action#actions

" Refresh the current statusline.
function! s:actions.refresh(buflister, is_new_buffer)
  let new_statusline = bufswitcher#make_statusline(a:buflister)
  call bufswitcher#replace_statusline(new_statusline, a:is_new_buffer)
endfunction

" Open the specified buffer. It continues showing buffer list.
function! s:actions.switch_to(buflister, bufnr) dict
  call bufswitcher#restore_prev_statusline(a:buflister.selected_nr)
  call a:buflister.select(a:bufnr)
  silent execute 'buffer' a:bufnr
  call g:bufswitcher#action#actions.refresh(a:buflister, 1)
endfunction

" Go to previous buffer in buffer list.
function! s:actions.go_prev(buflister)
  let prev_bufnr = a:buflister.get_next_bufnr(-1)
  call g:bufswitcher#action#actions.switch_to(a:buflister, prev_bufnr)
endfunction

" Go to previous buffer in buffer list.
function! s:actions.go_next(buflister)
  let next_bufnr = a:buflister.get_next_bufnr(1)
  call g:bufswitcher#action#actions.switch_to(a:buflister, next_bufnr)
endfunction

" Go to first buffer in buffer list.
function! s:actions.go_first(buflister)
  let first_bufnr = a:buflister.bufnrs[0]
  call g:bufswitcher#action#actions.switch_to(a:buflister, first_bufnr)
endfunction

" Go to last buffer in buffer list.
function! s:actions.go_last(buflister)
  let last_bufnr = a:buflister.bufnrs[-1]
  call g:bufswitcher#action#actions.switch_to(a:buflister, last_bufnr)
endfunction

unlet s:actions

" }}}
