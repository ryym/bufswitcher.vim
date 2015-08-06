runtime vspecrc.vim

let s:default_configs = copy(g:bufswitcher_configs)

function! s:tmp_buffer(name, another_command)
  let bufnr = g:Utils.tmp_buffer(a:name, a:another_command)
  call add(s:tmp_bufnrs, bufnr)
  return bufnr
endfunction


describe 'Default settings'
  it 'provides configuration dictionary with default values'
    Expect exists('g:bufswitcher_configs') to_be_true

    let configs = g:bufswitcher_configs
    Expect len(configs) == 1
    Expect configs.current_group ==# 'listed'
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


  describe '#show_group()'
    it 'changes the current group'
      let g:bufswitcher_configs.current_group = 'listed'
      call bufswitcher#show_group('all')

      Expect g:bufswitcher_configs.current_group ==# 'all'
    end

    it 'shows buffers which belong to the specified group'
      let prev_statusline = 'previous-statusline'
      let &statusline = prev_statusline
      call bufswitcher#show_group('listed')

      Expect bufswitcher#is_shown() to_be_true
      Expect &statusline not ==# prev_statusline
      Expect g:bufswitcher_configs.current_group ==# 'listed'
    end

    it 'shows buffers of current group if group is not specified'
      let g:bufswitcher_configs.current_group = 'listed'
      call bufswitcher#show_group()

      Expect bufswitcher#is_shown() to_be_true
      Expect g:bufswitcher_configs.current_group ==# 'listed'
    end

    it 'does nothing if the buffer list is already opened'
      call bufswitcher#show_group()
      Expect bufswitcher#is_shown() to_be_true

      let another_bufnr = s:tmp_buffer('b1', '')
      silent execute 'buffer' another_bufnr
      let &statusline = 'another-buffer-statusline'
      call bufswitcher#show_group()

      Expect &statusline ==# 'another-buffer-statusline'
    end
  end

  describe '#hide()'
    it 'restores statusline'
      let &statusline = 'prev-statusline'
      call bufswitcher#show_group()

      call bufswitcher#hide()
      Expect bufswitcher#is_shown() to_be_false
      Expect &statusline ==# 'prev-statusline'
    end

    it 'restores statusline even if it opened in another buffer'
      let &statusline   = 'prev-statusline'
      let current_bufnr = bufnr('%')
      call bufswitcher#show_group()

      let bufnr = s:tmp_buffer('b', '')
      silent execute 'buffer' bufnr
      Expect bufswitcher#is_shown() to_be_true

      call bufswitcher#hide()

      Expect bufswitcher#is_shown() to_be_false
      silent execute 'buffer' current_bufnr
      Expect &statusline ==# 'prev-statusline'
    end
  end
end
