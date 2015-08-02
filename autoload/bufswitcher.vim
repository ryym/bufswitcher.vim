" Vim plugin for switching buffer using statusline
" Maintainer: ryym <ryym64@gmail.com>
" License: The file is placed in the public domain.

" Save 'cpoptions' {{{

let s:save_cpo = &cpo
set cpo&vim

" }}}

" Version {{{

" Return the current version of bufswitcher.vim.
function! bufswitcher#version()
  return '0.0.1'
endfunction

" }}}

" Highlights {{{

" Default highlights settings.
highlight      BufswitcherBackGround guifg=gray guibg=black
highlight link BufswitcherTitle      Title
highlight link BufswitcherBufNumber  CursorLineNr
highlight link BufswitcherBufName    Normal
highlight link BufswitcherSelected   Search

" }}}

" Buflister object {{{

" Buflister is an object which has some informations and functions
" to display buffer list in statusline.
let s:Buflister = {}

" Select the specified buffer number.
function! s:Buflister.select(bufnr) dict
  let self.selected_nr = a:bufnr
endfunction

" Return a bufnr which is ahead of or behind the currently selected one
" by the specified number of indexes.
function! s:Buflister.get_next_bufnr(step) dict
  let current_nr_idx = index(self.bufnrs, self.selected_nr)
  let next_nr_idx    = (current_nr_idx + a:step) % len(self.bufnrs)
  return self.bufnrs[next_nr_idx]
endfunction

" Create a new Buflister object.
function! bufswitcher#new_buflister(title, bufnrs, ...)
  let bufnames = {}
  for bufnr in filter(a:bufnrs, 'bufexists(v:val)')
    let bufnames[bufnr] = fnamemodify(bufname(bufnr), ':t')
  endfor

  let selected_nr = (a:0 == 1 && bufexists(a:1)) ? a:1 : bufnr('%')
  return extend({
    \ 'title'       : a:title,
    \ 'bufnrs'      : a:bufnrs,
    \ 'bufnames'    : bufnames,
    \ 'selected_nr' : selected_nr
    \ }, s:Buflister)
endfunction

" }}}

" Show and hide buffer list {{{

" Show buffers which belong to the specified group.
" If group name is omitted, show 'g:bufswitcher_config.current_group'.
function! bufswitcher#show_group(...)
  if bufswitcher#is_shown()
    return
  endif
  let group = get(a:, '1', g:bufswitcher_configs.current_group)

  let buflister = bufswitcher#group#get_buflister_from(group)
  if ! empty(buflister)
    call bufswitcher#show(buflister)
    call bufswitcher#group#change_current_group(group)
  endif
endfunction

" Show buffer list.
function! bufswitcher#show(buflister)
  call bufswitcher#_states().set_current_buflister(a:buflister)
  let new_statusline = bufswitcher#make_statusline(a:buflister)
  call bufswitcher#replace_statusline(new_statusline, 1)

  if g:bufswitcher_configs.auto_close
    augroup bufswitcher
      autocmd CursorMoved,InsertEnter,CursorHold * call s:on_actions_while_opened()
    augroup END
  endif
endfunction

" Hide (close) buffer list in statusline of all windows.
function! bufswitcher#hide()
  if ! bufswitcher#is_shown()
    return
  endif

  let current_bufnr = bufnr('%')
  for nr in filter( range(1, bufnr('$')), 'bufexists(v:val)' )
    call bufswitcher#restore_prev_statusline(nr)
  endfor
  silent execute 'buffer' current_bufnr

  augroup bufswitcher
    autocmd!
  augroup END
  call bufswitcher#_states().clear_current_buflister()
endfunction

" Return non-zero if buffer list is shown in statusline.
function! bufswitcher#is_shown()
  return bufswitcher#_states().is_shown()
endfunction

" An event to hide buffer list automatically.
function! s:on_actions_while_opened()
  let states = bufswitcher#_states()
  if states.will_skip_next_autoclose
    let states.will_skip_next_autoclose = 0
    return
  endif
  call bufswitcher#hide()
endfunction

" }}}

" Edit statusline {{{

" Set the specified string to statusline and save previous one if necessary.
function! bufswitcher#replace_statusline(new_statusline, save_prev_stl)
  if a:save_prev_stl
    call bufswitcher#save_current_statusline()
  endif
  let &statusline = a:new_statusline
endfunction

" Save the current statusline in a buffer scope variable.
function! bufswitcher#save_current_statusline()
  let b:bufswitcher_prev_statusline = &statusline
endfunction

" Restore the previous statusline from the buffer scope variable.
" This open the specified buffer to restore.
function! bufswitcher#restore_prev_statusline(bufnr)
  let prev_statusline = bufswitcher#get_prev_statusline(a:bufnr)
    if ! empty(prev_statusline)
      silent execute 'buffer' a:bufnr
      let &l:statusline = prev_statusline
      unlet b:bufswitcher_prev_statusline
    endif
endfunction

" Get saved previous statusline if it exists.
function! bufswitcher#get_prev_statusline(bufnr)
  return getbufvar(a:bufnr, 'bufswitcher_prev_statusline')
endfunction

" Create the string to be set to statusline based on the 'buflister'.
function! bufswitcher#make_statusline(buflister)
  let selected_nr = a:buflister.selected_nr
  let line = '%#BufswitcherTitle#' . a:buflister.title . ' :%#BufswitcherBackGround#'

  for bufnr in a:buflister.bufnrs
    let buffer_name = a:buflister.bufnames[bufnr]
    if buffer_name == ''
      let buffer_name = '[No name]'
    endif
    let is_selected_nr = (selected_nr == bufnr)

    let line .= '%#BufswitcherBufNumber# ' . bufnr . ' %#BufswitcherBackGround#'
    let line .= (is_selected_nr ? '%#BufswitcherSelected#' : '%#BufswitcherBufName#')
    let line .= ' ' . buffer_name . (getbufvar(bufnr, '&modified') ? '[+]' : '') . ' '
    let line .= '%#BufswitcherBackGround#  '
  endfor

  return line
endfunction

" }}}

" State object {{{

" Get a state object.
function! bufswitcher#_states()
  return s:_states
endfunction

let s:_states = {}

" If this flag is on, next autoclose event will be skipped.
" So statusline continues showing buffer list.
let s:_states.will_skip_next_autoclose = 0

function! s:_states.skip_next_autoclose() dict
  let self.will_skip_next_autoclose = 1
endfunction

function! s:_states.set_current_buflister(buflister) dict
  let self.current_buflister = a:buflister
endfunction

function! s:_states.clear_current_buflister() dict
  let self.will_skip_next_autoclose = 0
  unlet! self.current_buflister
endfunction

function! s:_states.is_shown() dict
  return has_key(self, 'current_buflister')
endfunction

" }}}

" Restore 'cpoptions' {{{

let &cpo = s:save_cpo
unlet s:save_cpo

" }}}

" vim: foldmethod=marker
