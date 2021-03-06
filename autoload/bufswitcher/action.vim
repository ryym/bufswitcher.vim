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

  call bufswitcher#start()
  let buflister = deepcopy( bufswitcher#_get_states().buflister )
  let args      = extend([buflister], a:000)
  let Action    = actions[a:action]

  let new_buflister = call(Action, args, actions)
  if ! empty(new_buflister)
    call bufswitcher#action#update(new_buflister)
  endif
endfunction

" Update statusline by the specified Buflist.
" If the selected bufnr is changed, switch to the buffer.
function! bufswitcher#action#update(buflister)
  let states  = bufswitcher#_get_states()
  let current = states.buflister
  if type(a:buflister) != type({}) || current == a:buflister
    return
  endif

  call bufswitcher#restore_prev_statusline(current.selected_nr)

  if current.selected_nr != a:buflister.selected_nr
    " Update alternate buffer properly:
    " If you move like `a -> b -> c`, `c` is the alt.
    " If you move like `a -> b -> a`, do not change the alt.
    let keepalt = 'keepalt'
    if current.selected_nr == states.start_nr || a:buflister.selected_nr == states.start_nr
      let keepalt = ''
    end

    silent execute keepalt 'buffer' a:buflister.selected_nr
  endif
  call states.set_buflister(a:buflister)

  let new_stl = bufswitcher#make_statusline(a:buflister)
  call bufswitcher#replace_statusline(new_stl)
  call states.skip_next_autoclose()
endfunction

" }}}

" Default actions {{{

" The dictionary which stores functions to operate buffer list.
let bufswitcher#action#actions = {}
let s:actions = bufswitcher#action#actions

" Open the specified buffer. It continues showing buffer list.
function! s:actions.switch_to(buflister, idx_or_bufnr) dict
  let bufnr = g:bufswitcher_configs.show_index
    \ ? a:buflister.bufnrs[a:idx_or_bufnr - 1]
    \ : a:idx_or_bufnr
  call a:buflister.select(bufnr)
  return a:buflister
endfunction

" Go to previous buffer in buffer list.
function! s:actions.go_prev(buflister)
  let prev_bufnr = a:buflister.get_next_bufnr(-1)
  call a:buflister.select(prev_bufnr)
  return a:buflister
endfunction

" Go to previous buffer in buffer list.
function! s:actions.go_next(buflister)
  let next_bufnr = a:buflister.get_next_bufnr(1)
  call a:buflister.select(next_bufnr)
  return a:buflister
endfunction

" Go to first buffer in buffer list.
function! s:actions.go_first(buflister)
  let first_bufnr = a:buflister.bufnrs[0]
  call a:buflister.select(first_bufnr)
  return a:buflister
endfunction

" Go to last buffer in buffer list.
function! s:actions.go_last(buflister)
  let last_bufnr = a:buflister.bufnrs[-1]
  call a:buflister.select(last_bufnr)
  return a:buflister
endfunction

unlet s:actions

" }}}
