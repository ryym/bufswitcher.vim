" Vim plugin for switching buffers using statusline
" Maintainer: ryym <ryym64@gmail.com>
" License: The file is placed in the public domain.

" Startup {{{

if exists('s:bufswitcher_loaded')
  finish
endif
let s:bufswitcher_loaded = 1

let s:save_cpo = &cpo
set cpo&vim

" }}}

" Configurations {{{

if ! exists('g:bufswitcher_configs') || type(g:bufswitcher_configs) != type({})
  let g:bufswitcher_configs = {}
endif

let g:bufswitcher_configs = extend({
  \   'current_group' : 'listed',
  \   'auto_close'    : 1
  \ }, g:bufswitcher_configs)

" }}}

" Commands {{{

command -nargs=? BufswitcherShow call bufswitcher#show_group(<f-args>)
command BufswitcherHide call bufswitcher#hide()

" }}}

" Plugin keys {{{

nnoremap <silent> <Plug>(bufswitcher-show)   :<C-u>BufswitcherShow<CR>
nnoremap <silent> <Plug>(bufswitcher-hide)   :<C-u>BufswitcherHide<CR>

" }}}

" End {{{

let &cpo = s:save_cpo
unlet s:save_cpo

" }}}

" vim: foldmethod=marker
