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
  return '0.0.0'
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

" Configuration {{{

" All options are stored in this dictionary.
let s:configs = g:bufswitcher_configs

" }}}

" Buflister object {{{

" Buflister is an object which has some informations and functions
" to display buffer list in statusline.
let s:Buflister = {}

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

" Show buffer list which belong to the specified group.
" If group name is omitted, show 'g:bufswitcher_config.current_group'.
function! bufswitcher#show_group(...)
  if bufswitcher#is_shown()
    return
  endif
  let group = get(a:, '1', s:configs.current_group)

  let buflister = bufswitcher#group#get_buflister_from(group)
  if ! empty(buflister)
    call bufswitcher#show(buflister)
    call bufswitcher#group#change_current_group(buflister)
  endif
endfunction

" Show buffer list.
function! bufswitcher#show(buflister)
  let s:bsw.current  = a:buflister
  let new_statusline = bufswitcher#make_statusline(a:buflister)
  call bufswitcher#replace_statusline(new_statusline, 1)

  if s:configs.auto_close
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
  call s:bsw.clear_current_buflister()
endfunction

" Return non-zero if buffer list is shown in statusline.
function! bufswitcher#is_shown()
  return s:bsw.is_shown()
endfunction

" An event to hide buffer list automatically.
function! s:on_actions_while_opened()
  if s:bsw.states.in_operation
    let s:bsw.states.in_operation = 0
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

" Get saved previous statusline if it's exists.
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

" Work object {{{

let s:bsw = {
  \ 'states' : {
  \   'in_operation' : 0
  \   }
  \ }

function! s:bsw.clear_current_buflister() dict
  let self.states.in_operation = 0
  unlet! self.current
endfunction

function! s:bsw.is_shown() dict
  return has_key(self, 'current')
endfunction

" }}}

" Restore 'cpoptions' {{{

let &cpo = s:save_cpo
unlet s:save_cpo

" }}}

" vim: foldmethod=marker
