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

unlet s:actions

" }}}
