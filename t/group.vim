runtime vspecrc.vim

describe 'Group'
  describe '.all()'
    it 'lists all buffers including unlisted buffers'
      let bufnrs = []

      call add(bufnrs, g:Utils.open_new_buffer('b1'))
      call add(bufnrs, g:Utils.open_new_buffer('b2'))
      call add(bufnrs, g:Utils.open_new_buffer('b_unlisted1', 'setl nobuflisted'))

      tabnew
      call add(bufnrs, g:Utils.open_new_buffer('b4'))
      call add(bufnrs, g:Utils.open_new_buffer('b_unlisted2', 'setl nobuflisted'))

      wincmd s
      call add(bufnrs, g:Utils.open_new_buffer('b5'))
      call add(bufnrs, g:Utils.open_new_buffer('b_unlisted3', 'setl nobuflisted'))

      let buflister = g:bufswitcher#group#groups.all()
      for bufnr in bufnrs
        Expect has_key(buflister.bufnames, bufnr) to_be_true
      endfor
    end
  end

  describe '.listed()'
    it 'lists buffers which are listed in the buffer list'
      let bufnrs = []
      let unlisted_bufnrs = []

      call add(bufnrs, g:Utils.open_new_buffer('b1'))
      call add(bufnrs, g:Utils.open_new_buffer('b2'))
      call add(unlisted_bufnrs,
        \ g:Utils.open_new_buffer('b_unlisted1', 'setl nobuflisted'))

      tabnew
      call add(bufnrs, g:Utils.open_new_buffer('b4'))
      call add(unlisted_bufnrs,
        \ g:Utils.open_new_buffer('b_unlisted2', 'setl nobuflisted'))

      wincmd s
      call add(bufnrs, g:Utils.open_new_buffer('b5'))
      call add(unlisted_bufnrs,
        \ g:Utils.open_new_buffer('b_unlisted3', 'setl nobuflisted'))

      let buflister = g:bufswitcher#group#groups.listed()
      for bufnr in bufnrs
        Expect has_key(buflister.bufnames, bufnr) to_be_true
      endfor
      for bufnr in unlisted_bufnrs
        Expect has_key(buflister.bufnames, bufnr) to_be_false
      endfor
    end
  end
end
