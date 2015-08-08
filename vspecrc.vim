" Common settings for unit tests

runtime plugin/bufswitcher.vim

" Test utilities {{{

let g:Utils = {}

" Open a dummy buffer for tests with multiple buffers.
" This ensures that buffers opened while tests have
" deferrent bufnr from the first one.
silent edit ___

" Open a temporary buffer and return its buffer number.
function! Utils.tmp_buffer(name, ...)
  silent execute 'edit' a:name
  let another_command = get(a:, '1', '')
  if ! empty(another_command)
    silent execute another_command
  endif
  return bufnr('%')
endfunction

" Wipeout all specified buffers.
function! Utils.wipeout_all(bufnrs)
  for bufnr in a:bufnrs
    silent execute 'bwipeout' bufnr
  endfor
endfunction

" Mock actions {{{

" Create a mock actions dictionary that remembers what actions were called.
function! g:Utils.make_mock_actions()
  let mock_actions = { '_status' : {'_called' : {}} }

  function! mock_actions._clear() dict
    let self._status._called = {}
  endfunction

  function! mock_actions.status() dict
    return self._status
  endfunction

  for s:action in keys(g:bufswitcher#action#actions)
    exec "function! mock_actions[s:action](...) dict\n"
      \ ."  let self._status._called." . s:action . " = a:000[1:]\n"
      \ ."endfunction"
  endfor
  return mock_actions
endfunction

" Custom matcher for actions {{{

" Custom matcher to check if the specified action was called.
let s:actions_matcher = {}

function! s:actions_matcher.match(status, action, arguments)
  if ! has_key(a:status._called, a:action)
    return 0
  endif

  let actual_args = a:status._called[a:action]
  return actual_args ==# a:arguments
endfunction

function! s:actions_matcher._generic_message(not, status, action, arguments)
  let verb        = a:not ? "doesn't call" : "calls"
  let called      = has_key(a:status._called, a:action)
  let actual_args = called ? a:status._called[a:action] : '-'

  return printf(join([
    \ "Expected it %s the '%s' action with the arguments %s.",
    \ "#     Result:",
    \ "#       action: %s",
    \ "#       arguments: %s"
    \ ], "\n"),
    \ verb, a:action, string(a:arguments),
    \ called ? "called" : "not called", string(actual_args)
    \ )
endfunction

function! s:actions_matcher.failure_message_for_should(status, action, arguments) dict
  return self._generic_message(0, a:status, a:action, a:arguments)
endfunction

function! s:actions_matcher.failure_message_for_should_not(status, action, arguments) dict
  return self._generic_message(1, a:status, a:action, a:arguments)
endfunction

call vspec#customize_matcher('to_be_called', s:actions_matcher)

" }}}

" }}}

" }}}

" vim: foldmethod=marker
