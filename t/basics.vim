runtime vspecrc.vim

describe 'Basic functions:'
  it 'shows buffer list in statusline and restores previous one'
    let prev_statusline = 'previous-statusline'
    let &statusline = prev_statusline

    call bufswitcher#show_group('all')
    Expect &statusline not ==# prev_statusline

    call bufswitcher#hide()
    Expect &statusline ==# prev_statusline
  end
end
