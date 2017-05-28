" Vim plugin for switching buffers using statusline
" Maintainer: ryym <ryym64@gmail.com>
" License: The file is placed in the public domain.

" List buffer numbers
function! bufswitcher#lister#list(raw_conf)
  let conf = bufswitcher#lister#normalize_conf(a:raw_conf)
  let is_target = 'bufexists(v:val)'

  if conf.listed
    let is_target .= ' && buflisted(v:val)'
  endif

  if conf.per_tab && exists('t:bfs_tabbufs')
    let is_target .= ' && has_key(t:bfs_tabbufs, v:val)'
  endif

  let bufnrs = filter(range(1, bufnr('$')), is_target)

  let s:order = conf.order
  return sort(bufnrs, function('s:compare_bufs'))
endfunction

function! bufswitcher#lister#normalize_conf(raw_conf)
  let keys = [
    \ ['listed', 0],
    \ ['per_tab', 0],
    \ ['order', 'bufnr'],
    \ ]
  let conf = {}
  for [key, default] in keys
    let conf[key] = has_key(a:raw_conf, key) ? a:raw_conf[key] : default
  endfor
  return conf
endfunction

function! s:compare_bufs(a, b)
  if s:order == 'recent'
    let times = g:bufswitcher_buf_enter_times
    let at = has_key(times, a:a) ? times[a:a] : 0
    let bt = has_key(times, a:b) ? times[a:b] : 0
    return bt - at
  endif
  return a:a - a:b
endfunction

function! bufswitcher#lister#setup()
  let g:bufswitcher_buf_enter_times = {}

  augroup bufswitcher_lister
    autocmd!
    autocmd BufEnter,BufWinEnter,BufFilePost * call <SID>add_tabbuf()
    autocmd BufWinEnter * call <SID>touch_buf()
  augroup END

  call bufswitcher#on_hide(function('<SNR>' . s:SID() . '_touch_buf'))
endfunction

function! s:add_tabbuf()
  if !exists('t:bfs_tabbufs')
    let t:bfs_tabbufs = {}
  endif

  let bufnr = bufnr('%')
  if bufnr == expand('<abuf>')
    let t:bfs_tabbufs[bufnr] = 1
  endif
endfunction

let s:last_entered = 0

" Touch opened buffer for 'recent' buffer list order.
" It skips touching while switching.
function! s:touch_buf(...)
  if bufswitcher#is_shown()
    return
  endif

  let bufnr = get(a:, '1', bufnr('%'))
  let entered = s:last_entered + 1
  let g:bufswitcher_buf_enter_times[bufnr] = entered
  let s:last_entered = entered
endfunction

function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction
