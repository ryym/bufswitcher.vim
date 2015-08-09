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
  let buflister = deepcopy( bufswitcher#_states().current_buflister )
  let options   = s:make_exe_options()
  let args      = extend([buflister, options], a:000)
  let Action    = actions[a:action]

  let new_buflister = call(Action, args, actions)
  if ! empty(new_buflister)
    call bufswitcher#action#update(new_buflister)
  endif
endfunction

" Update statusline by the specified Buflister.
" If the selected bufnr is changed, switch to the buffer.
function! bufswitcher#action#update(buflister)
  let states  = bufswitcher#_states()
  let current = states.current_buflister
  if type(a:buflister) != type({}) || current == a:buflister
    return
  endif

  call bufswitcher#restore_prev_statusline(current.selected_nr)

  if current.selected_nr != a:buflister.selected_nr
    silent execute 'buffer' a:buflister.selected_nr
  endif
  call states.set_current_buflister(a:buflister)

  let new_stl = bufswitcher#make_statusline(a:buflister)
  call bufswitcher#replace_statusline(new_stl, 1)
  call bufswitcher#_states().skip_next_autoclose()
endfunction

function! s:make_exe_options()
  return {}
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
  if a:buflister.selected_nr == a:bufnr
    return
  endif
  call bufswitcher#restore_prev_statusline(a:buflister.selected_nr)
  call a:buflister.select(a:bufnr)
  silent execute 'buffer' a:bufnr
  call g:bufswitcher#action#actions.refresh(a:buflister, 1)
  call bufswitcher#_states().skip_next_autoclose()
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
