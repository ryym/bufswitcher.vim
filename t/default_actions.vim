runtime vspecrc.vim

let s:actions = bufswitcher#action#actions

function s:make_test_buflister(bufnrs, selected_nr)
  let buflister = bufswitcher#new_buflist([])
  let buflister.selected_nr = a:selected_nr
  let buflister.bufnrs = a:bufnrs
  for bufnr in a:bufnrs
    let buflister.bufnames[bufnr] = bufnr
  endfor
  return buflister
endfunction


describe 'Default actions'
  describe '.switch_to()'
    it 'selects to the specified buffer'
      let buflister = s:make_test_buflister([1, 2, 3], 1)

      let new_buflister = s:actions.switch_to(buflister, {}, 3)
      Expect new_buflister.selected_nr == 3

      let new_buflister = s:actions.switch_to(buflister, {}, 2)
      Expect new_buflister.selected_nr == 2
    end
  end

  describe '.go_prev()'
    it 'selects the previous buffer'
      let buflister = s:make_test_buflister([1, 2, 3], 3)

      let buflister = s:actions.go_prev(buflister, {})
      Expect buflister.selected_nr == 2

      let buflister = s:actions.go_prev(buflister, {})
      Expect buflister.selected_nr == 1
    end
  end

  describe '.go_next()'
    it 'selects the next buffer'
      let buflister = s:make_test_buflister([1, 2, 3], 1)

      let buflister = s:actions.go_next(buflister, {})
      Expect buflister.selected_nr == 2

      let buflister = s:actions.go_next(buflister, {})
      Expect buflister.selected_nr == 3
    end
  end

  describe '.go_first()'
    it 'selects the first buffer'
      let buflister = s:make_test_buflister([1, 2, 3], 3)

      let buflister = s:actions.go_first(buflister, {})
      Expect buflister.selected_nr == 1
    end
  end

  describe '.go_last()'
    it 'selects the next buffer'
      let buflister = s:make_test_buflister([1, 2, 3], 1)

      let buflister = s:actions.go_last(buflister, {})
      Expect buflister.selected_nr == 3
    end
  end
end
