runtime vspecrc.vim

let s:default_configs = copy(g:bufswitcher_configs)

function! s:open_new_buffer(name, another_command)
  let bufnr = g:Utils.open_new_buffer(a:name, a:another_command)
  call add(s:tmp_bufnrs, bufnr)
  return bufnr
endfunction


describe 'Default settings'
  it 'provides configuration dictionary with default values'
    Expect exists('g:bufswitcher_configs') to_be_true
  end
end


describe 'Basic functions:'
  before
    let s:tmp_bufnrs = []
  end

  after
    let g:bufswitcher_configs = copy(s:default_configs)
    call bufswitcher#hide()
    call g:Utils.wipeout_all(s:tmp_bufnrs)
  end

  describe '#start()'
    it 'starts buffer switching'
      let prev_statusline = 'previous-statusline'
      let &l:statusline = prev_statusline
      call bufswitcher#start()

      Expect bufswitcher#is_shown() to_be_true
      Expect &l:statusline not ==# prev_statusline
    end

    it 'does nothing if the buffer list is already opened'
      call bufswitcher#start()
      Expect bufswitcher#is_shown() to_be_true

      let another_bufnr = s:open_new_buffer('b1', '')
      silent execute 'buffer' another_bufnr
      let &l:statusline = 'another-buffer-statusline'
      call bufswitcher#start()

      Expect &l:statusline ==# 'another-buffer-statusline'
    end
  end

  describe '#hide()'
    it 'restores statusline'
      let &l:statusline = 'prev-statusline'
      call bufswitcher#start()

      call bufswitcher#hide()
      Expect bufswitcher#is_shown() to_be_false
      Expect &l:statusline ==# 'prev-statusline'
    end

    it 'restores statusline even if it opened in another buffer'
      let &l:statusline   = 'prev-statusline'
      let current_bufnr = bufnr('%')
      call bufswitcher#start()

      let bufnr = s:open_new_buffer('b', '')
      silent execute 'buffer' bufnr
      Expect bufswitcher#is_shown() to_be_true

      call bufswitcher#hide()

      Expect bufswitcher#is_shown() to_be_false
      silent execute 'buffer' current_bufnr
      Expect &l:statusline ==# 'prev-statusline'
    end

    it 'will be called automatically on the specific events'
      function s:should_be_called_on(event_name)
        call bufswitcher#start()
        Expect bufswitcher#is_shown() to_be_true
        silent execute 'doautocmd bufswitcher' a:event_name
        Expect bufswitcher#is_shown() to_be_false
      endfunction

      call s:should_be_called_on('CursorMoved')
      call s:should_be_called_on('InsertEnter')
      call s:should_be_called_on('CursorHold')
      call s:should_be_called_on('WinLeave')
    end
  end
end
