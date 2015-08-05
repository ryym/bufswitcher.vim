runtime vspecrc.vim

let s:default_configs = copy(g:bufswitcher_configs)


describe 'Default settings'
  it 'provides configuration dictionary with default values'
    Expect exists('g:bufswitcher_configs') to_be_true

    let configs = g:bufswitcher_configs
    Expect len(configs) == 1
    Expect configs.current_group ==# 'listed'
  end
end


describe 'Basic functions:'
  after
    let g:bufswitcher_configs = copy(s:default_configs)
    call bufswitcher#hide()
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
  end

  describe '#hide()'
    it 'restores statuslines of all buffers'
      TODO
    end
  end
end
