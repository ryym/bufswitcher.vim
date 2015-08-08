runtime vspecrc.vim

let s:actions = bufswitcher#action#actions

let g:W = {}
let g:W.mock_actions = g:Utils.make_mock_actions()
let g:bufswitcher#action#actions = g:W.mock_actions

describe 'action'
  before
    let g:W.bufnrs = []
    call add(g:W.bufnrs, g:Utils.tmp_buffer('b1'))
    call add(g:W.bufnrs, g:Utils.tmp_buffer('b2'))
    call add(g:W.bufnrs, g:Utils.tmp_buffer('b3'))
    call add(g:W.bufnrs, g:Utils.tmp_buffer('b4'))
    call add(g:W.bufnrs, g:Utils.tmp_buffer('b5'))

    silent execute 'buffer' g:W.bufnrs[0]
    let &l:statusline = 'previous-statusline'
    let g:W.buflister = bufswitcher#new_buflister('test-buffers', g:W.bufnrs, g:W.bufnrs[0])
    call bufswitcher#show(g:W.buflister)
  end

  after
    call bufswitcher#hide()
    call g:Utils.wipeout_all(g:W.bufnrs)
    call g:W.mock_actions._clear()
  end

  it 'executes an action of the specified name'
    call bufswitcher#action#execute('refresh', 0)

    Expect bufswitcher#is_shown() to_be_true
    Expect g:W.mock_actions.status() to_be_called 'refresh', [0]
  end

  describe '.switch_to()'
    it 'switches to the specified buffer'
      let new_bufnr = g:W.bufnrs[1]
      call s:actions.switch_to(g:W.buflister, new_bufnr)

      Expect bufnr('%') == new_bufnr
      Expect g:W.buflister.selected_nr == new_bufnr
      Expect g:W.mock_actions.status() to_be_called 'refresh', [1]
      Expect bufswitcher#_states().will_skip_next_autoclose to_be_true
    end

    it 'restores statusline of the previous buffer'
      let before_bufnr = g:W.bufnrs[0]
      call s:actions.switch_to(g:W.buflister, g:W.bufnrs[1])

      silent execute 'buffer' before_bufnr
      Expect &l:statusline ==# 'previous-statusline'
    end
  end

  describe '.go_prev()'
    it 'opens the previous buffer'
      let prev_bufnr = g:W.bufnrs[0]
      let next_bufnr = g:W.bufnrs[1]
      call s:actions.switch_to(g:W.buflister, next_bufnr)
      call s:actions.go_prev(g:W.buflister)

      Expect g:W.mock_actions.status() to_be_called 'switch_to', [prev_bufnr]
    end
  end

  describe '.go_next()'
    it 'opens the next buffer'
      let prev_bufnr = g:W.bufnrs[0]
      let next_bufnr = g:W.bufnrs[1]
      call s:actions.switch_to(g:W.buflister, prev_bufnr)
      call s:actions.go_next(g:W.buflister)

      Expect g:W.mock_actions.status() to_be_called 'switch_to', [next_bufnr]
    end
  end

  describe '.go_first()'
    it 'opens the first buffer'
      let first_bufnr = g:W.bufnrs[0]
      call s:actions.switch_to(g:W.buflister, g:W.bufnrs[2])
      call s:actions.go_first(g:W.buflister)

      Expect g:W.mock_actions.status() to_be_called 'switch_to', [first_bufnr]
    end
  end

  describe '.go_last()'
    it 'opens the last buffer'
      let last_bufnr = g:W.bufnrs[-1]
      call s:actions.switch_to(g:W.buflister, g:W.bufnrs[2])
      call s:actions.go_last(g:W.buflister)

      Expect g:W.mock_actions.status() to_be_called 'switch_to', [last_bufnr]
    end
  end
end
