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
  return sort(bufnrs, funcref('s:compare_bufs', [conf.order]))
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

function! s:compare_bufs(order, a, b)
  if a:order == 'recent'
    " TODO: implement
  endif
  return a:a - a:b
endfunction

function! bufswitcher#lister#setup()
  augroup bufswitcher_lister
    autocmd!
    autocmd BufEnter,BufWinEnter,BufFilePost * call <SID>add_tabbuf()
  augroup END
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
