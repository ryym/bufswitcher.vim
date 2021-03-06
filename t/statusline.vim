runtime vspecrc.vim

function! s:open_new_buffer(name, another_command)
  let bufnr = g:Utils.open_new_buffer(a:name, a:another_command)
  call add(s:tmp_bufnrs, bufnr)
  return bufnr
endfunction


describe 'Statusline editing'
  before
    let &l:statusline = 'CURRENT-STATUSLINE'
    unlet! b:bufswitcher_prev_statusline
    let s:tmp_bufnrs = []
  end

  after
    call g:Utils.wipeout_all(s:tmp_bufnrs)
  end


  describe '#save_current_statusline()'
    it 'saves current statusline to a buffer scope variable'
      let prev_statusline = &l:statusline
      call bufswitcher#save_current_statusline()
      let &l:statusline = 'new-statusline'
      Expect b:bufswitcher_prev_statusline ==# prev_statusline
    end
  end

  describe '#replace_statusline()'
    it 'replaces statusline and saves the previous one'
      let prev_statusline = &l:statusline
      let new_statusline  = 'new-statusline'
      call bufswitcher#replace_statusline(new_statusline)

      Expect &l:statusline ==# new_statusline
      Expect b:bufswitcher_prev_statusline ==# prev_statusline
    end

    it 'remembers the first statusline after multiple replacing'
      let prev_statusline = &l:statusline
      call bufswitcher#replace_statusline('new-stl1')
      call bufswitcher#replace_statusline('new-stl2')
      call bufswitcher#replace_statusline('new-stl3')

      Expect &l:statusline ==# 'new-stl3'
      Expect bufswitcher#get_prev_statusline(bufnr('%')) ==# prev_statusline
    end

    it 'does not change statuslines of other buffers'
      let current_bufnr = bufnr('%')
      let bufnrs = []
      call add(bufnrs, s:open_new_buffer('b1', ''))
      call add(bufnrs, s:open_new_buffer('b2', ''))

      silent execute 'buffer' current_bufnr
      call bufswitcher#replace_statusline('new-statusline')
      Expect &l:statusline ==# 'new-statusline'

      for bufnr in bufnrs
        silent execute 'buffer' bufnr
        Expect &l:statusline ==# ''
      endfor
    end
  end

  describe '#restore_prev_statusline()'
    it 'restores previous statusline'
      let this_bufnr = bufnr('%')
      let prev_statusline = &l:statusline
      call bufswitcher#save_current_statusline()

      let &l:statusline = 'new-statsuline'
      call bufswitcher#restore_prev_statusline(this_bufnr)

      Expect &l:statusline ==# prev_statusline
      Expect exists('b:bufswitcher_prev_statusline') not to_be_true
    end
  end
end
