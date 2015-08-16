runtime vspecrc.vim

let g:W = {}
let s:this_bufnr = bufnr('%')


describe 'action executor'
  describe '#action#execute()'
    before
      function! g:bufswitcher#action#actions.test(buflister, options, ...)
        let g:W.test_called = 1
        let g:W.test_args = a:000
        let a:buflister.is_updated = 1
        return a:buflister
      endfunction
    end

    after
      delfunction g:bufswitcher#action#actions.test
      unlet! g:W.test_called g:W.test_args
    end


    it 'executes the specified action with arbitrary arguments'
      call bufswitcher#action#execute('test', 1, 2, 3)
      Expect g:W.test_called to_be_true
      Expect g:W.test_args == [1, 2, 3]
    end

    it 'opens buffer list'
      call bufswitcher#action#execute('test')
      Expect bufswitcher#is_shown() to_be_true
    end

    it 'updates buffer list by Buflister the action returns'
      call bufswitcher#action#execute('test')
      Expect bufswitcher#_get_states().buflister.is_updated to_be_true
    end
  end

  describe '#action#update()'
    before
      let bufnrs = [s:this_bufnr, g:Utils.open_new_buffer('b2')]
      silent execute 'buffer' s:this_bufnr

      let s:current_buflister = bufswitcher#new_buflister('test', bufnrs, bufnrs[0])
      let &l:statusline = 'prev-statusline'
      call bufswitcher#show(s:current_buflister)
    end

    after
      silent execute 'buffer' s:this_bufnr
      call g:Utils.wipeout_all(s:current_buflister.bufnrs[1:])
      call bufswitcher#hide()
    end


    it 'does nothing if no changes are detected'
      let current_bufnr = bufnr('%')
      let current_stl = bufswitcher#make_statusline(s:current_buflister)
      Expect bufswitcher#is_shown() to_be_true

      call bufswitcher#action#update( deepcopy(s:current_buflister) )
      Expect bufswitcher#is_shown() to_be_true
      Expect &l:statusline ==# current_stl
      Expect bufnr('%') == current_bufnr
    end

    it 'updates buffer list on statusline if the list is changed'
      let new_buflister = deepcopy(s:current_buflister)
      call reverse(new_buflister.bufnrs)
      call bufswitcher#action#update(new_buflister)

      Expect &l:statusline ==# bufswitcher#make_statusline(new_buflister)
    end

    context 'with changing selected buffer'
      it 'opens the new buffer and shows buffer list'
        let new_buflister = deepcopy(s:current_buflister)
        let prev_bufnr = s:current_buflister.selected_nr
        Expect bufnr('%') == prev_bufnr

        let new_buflister.selected_nr = new_buflister.bufnrs[1]
        call bufswitcher#action#update(new_buflister)

        Expect bufnr('%') == new_buflister.selected_nr
        Expect &l:statusline ==# bufswitcher#make_statusline(new_buflister)
        Expect bufswitcher#_get_states().will_skip_next_autoclose to_be_true
      end

      it 'restores statusline of the previous buffer'
        let new_buflister = deepcopy(s:current_buflister)
        let prev_bufnr = s:current_buflister.selected_nr
        Expect bufnr('%') == prev_bufnr

        let new_buflister.selected_nr = new_buflister.bufnrs[1]
        call bufswitcher#action#update(new_buflister)

        Expect bufnr('%') != prev_bufnr
        silent execute 'buffer' prev_bufnr
        Expect &l:statusline ==# 'prev-statusline'
      end
    end
  end
end
