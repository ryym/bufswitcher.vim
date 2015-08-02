runtime plugin/bufswitcher.vim

describe 'Statusline editing'
  before
    let &statusline = 'CURRENT-STATUSLINE'
    unlet! b:bufswitcher_prev_statusline
  end

  describe '#save_current_statusline'
    it 'saves current statusline to a buffer scope variable'
      let prev_statusline = &statusline
      call bufswitcher#save_current_statusline()
      let &statusline = 'new-statusline'
      Expect b:bufswitcher_prev_statusline ==# prev_statusline
    end
  end

  describe '#replace_statusline'
    it 'saves previous statusline if necessary'
      let prev_statusline = &statusline
      let new_statusline  = 'new-statusline'
      call bufswitcher#replace_statusline(new_statusline, 1)

      Expect &statusline ==# new_statusline
      Expect b:bufswitcher_prev_statusline ==# prev_statusline
    end

    it 'does not save previous statusline if unnecessary'
      let prev_statusline = &statusline
      let new_statusline  = 'new-statusline'
      call bufswitcher#replace_statusline(new_statusline, 0)

      Expect &statusline ==# new_statusline
      Expect exists('b:bufswitcher_prev_statusline') not to_be_true
    end
  end

  describe '#restore_prev_statusline'
    it 'restores previous statusline'
      let this_bufnr = bufnr('%')
      let prev_statusline = &statusline
      call bufswitcher#save_current_statusline()

      let &statusline = 'new-statsuline'
      call bufswitcher#restore_prev_statusline(this_bufnr)

      Expect &statusline ==# prev_statusline
      Expect exists('b:bufswitcher_prev_statusline') not to_be_true
    end
  end
end
