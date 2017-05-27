runtime vspecrc.vim

describe 'Lister'
  describe '#normalize_conf'
    it 'sets default value to required keys'
      let conf = bufswitcher#lister#normalize_conf({ 'listed': 1 })
      Expect conf == { 'listed': 1, 'order': 'bufnr' }
    end
  end

  describe '#list'
    it 'can list all buffers'
      let bufs = s:prepare_buffers([
        \ { 'listed': 0 },
        \ { 'listed': 1 },
        \ { 'run': 'tabnew' },
        \ { 'listed': 1 },
        \ { 'listed': 0 },
        \ ])

      let bufnrs = s:run_list({})
      Expect bufnrs == map(bufs, 'v:val.bufnr')
    end

    it 'can list listed buffers only'
      let bufs = s:prepare_buffers([
        \ { 'listed': 0 },
        \ { 'listed': 1 },
        \ { 'run': 'tabnew' },
        \ { 'listed': 1 },
        \ { 'listed': 0 },
        \ ])

      let bufnrs = s:run_list({ 'listed': 1 })
      Expect bufnrs == [bufs[1].bufnr, bufs[2].bufnr]
    end
  end
end

function! s:run_list(conf)
  let bufnrs = bufswitcher#lister#list(a:conf)
  return g:Utils.remove_test_buffers(bufnrs)
endfunction

function! s:prepare_buffers(actions)
  let id = 0

  let bufs = []
  for ac in a:actions
    if has_key(ac, 'run')
      silent execute ac.run
    else
      let id += 1
      let com = ac.listed ? '' : 'setl nobuflisted'
      let bufnr = g:Utils.open_new_buffer('b' . id, com)
      call add(bufs, { 'bufnr': bufnr, 'listed': ac.listed })
    endif
  endfor

  return bufs
endfunction
