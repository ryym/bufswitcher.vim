runtime vspecrc.vim


function s:open_tmp_buffers(n_buffers)
  let bufnrs = []
  for i in range(1, a:n_buffers)
    let bufnr = g:Utils.tmp_buffer('b' . (i+1))
    call add(bufnrs, bufnr)
  endfor

  let s:bufnrs = bufnrs
  return bufnrs
endfunction


describe 'Buflister'
  before
    let s:bufnrs = []
  end

  after
    call g:Utils.wipeout_all(s:bufnrs)
  end


  describe '.new()'
    it 'has fields used to write statusline'
      let this_bufnr   = bufnr('%')
      let this_bufname = fnamemodify(bufname('%'), ':t')
      let buflister    = bufswitcher#new_buflister('TITLE', [this_bufnr], this_bufnr)

      Expect buflister.title ==# 'TITLE'
      Expect buflister.bufnrs == [this_bufnr]
      Expect buflister.bufnames[this_bufnr] ==# this_bufname
      Expect buflister.selected_nr == this_bufnr
    end

    it 'selects the current bufnr by default'
      let this_bufnr = bufnr('%')

      let buflister = bufswitcher#new_buflister('', [this_bufnr])
      Expect buflister.selected_nr == this_bufnr

      let buflister = bufswitcher#new_buflister('', [this_bufnr], -100)
      Expect buflister.selected_nr == this_bufnr
    end
  end

  describe '.get_next_bufnr()'
    it 'returns a bufnr which is ahead of the current one'
      let bufnrs    = s:open_tmp_buffers(3)
      let buflister = bufswitcher#new_buflister('bufnrs', bufnrs, bufnrs[0])
      Expect buflister.bufnrs == bufnrs
      Expect buflister.get_next_bufnr(1) == bufnrs[1]
      Expect buflister.get_next_bufnr(2) == bufnrs[2]
      Expect buflister.get_next_bufnr(3) == bufnrs[0]
      Expect buflister.get_next_bufnr(4) == bufnrs[1]
    end

    it 'returns a bufnr which is behind the current one'
      let bufnrs    = s:open_tmp_buffers(3)
      let buflister = bufswitcher#new_buflister('bufnrs', bufnrs, bufnrs[2])
      Expect buflister.bufnrs == bufnrs
      Expect buflister.get_next_bufnr(-1) == bufnrs[1]
      Expect buflister.get_next_bufnr(-2) == bufnrs[0]
      Expect buflister.get_next_bufnr(-3) == bufnrs[2]
      Expect buflister.get_next_bufnr(-4) == bufnrs[1]
    end
  end
end
