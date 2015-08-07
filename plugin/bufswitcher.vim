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
  \ }, g:bufswitcher_configs)

" }}}

" Commands {{{

command -nargs=? BufswitcherShow call bufswitcher#show_group(<f-args>)
command BufswitcherHide call bufswitcher#hide()

command -nargs=+ BufswitcherExec call bufswitcher#action#execute(<f-args>)
command BufswitcherPrev  BufswitcherExec go_prev
command BufswitcherNext  BufswitcherExec go_next
command BufswitcherFirst BufswitcherExec go_first
command BufswitcherLast  BufswitcherExec go_last

" }}}

" Plugin keys {{{

nnoremap <silent> <Plug>(bufswitcher-show)  :<C-u>BufswitcherShow<CR>
nnoremap <silent> <Plug>(bufswitcher-hide)  :<C-u>BufswitcherHide<CR>
nnoremap <silent> <Plug>(bufswitcher-next)  :<C-u>BufswitcherNext<CR>
nnoremap <silent> <Plug>(bufswitcher-prev)  :<C-u>BufswitcherPrev<CR>
nnoremap <silent> <Plug>(bufswitcher-first) :<C-u>BufswitcherFirst<CR>
nnoremap <silent> <Plug>(bufswitcher-last)  :<C-u>BufswitcherLast<CR>

" }}}

" End {{{

let &cpo = s:save_cpo
unlet s:save_cpo

" }}}

" vim: foldmethod=marker
