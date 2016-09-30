require 'minitest/assertions'

module Minitest::Assertions
  
  # Fails unless the given items are all connected, in order, and are complete.
  # For the chain to be complete it must start with the first item, end in the
  # last and contain the correct count.
  
  def assert_chain(*items)
    head = items[0]
    tail = items[-1]
        
    assert head.first?, 'The first item is not first in the chain'
    assert tail.last?, 'The last item is not last in the chain'
    assert_equal items.count, head.count, 'The chain count is not correct'
        
    items.each_cons(2) do |a, b|
      assert_same b, a.next, '#next returns the wrong item'
      assert_same a, b.prev, '#prev returns the wrong item'
      
      # Check that all items correctly point to head
      assert_same head, b.first, '#first does not return the first item'
    end
    
    assert_same tail, head.last, '#last does not return the last item'
  end
  
  def assert_list_contains(list, *items)
    assert_equal items.length, list.count, 'The list count does not match'
    
    list.each.with_index do |item, index|
      assert_same items[index], item
    end
  end
end