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

  let bufnrs = filter(range(1, bufnr('$')), is_target)

  let s:order = conf.order
  return sort(bufnrs, funcref('s:compare_bufs', [conf.order]))
endfunction

function! bufswitcher#lister#normalize_conf(raw_conf)
  let keys = [
    \ ['listed', 0],
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
